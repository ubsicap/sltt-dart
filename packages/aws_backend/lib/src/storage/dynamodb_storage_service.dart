import 'dart:convert';
import 'dart:io';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';

/// Lightweight DynamoDB implementation for AWS Lambda deployment.
///
/// Uses HTTP API calls instead of heavy AWS SDK to minimize cold start time.
/// This service stores change log entries in AWS DynamoDB with the following schema:
///
/// **Primary Index:**
/// - Partition key: 'pk' (String) - PROJECT_ID#{projectId}#ENTITY_ID#{entityId}
/// - Sort key: 'sk' (String) - CID#{cid}
///
/// **Secondary Index (GSI1):**
/// - Partition key: 'gsi1pk' (String) - PROJECT_ID#{projectId}
/// - Sort key: 'gsi1sk' (String) - SEQ#{seq}
///
/// This schema provides:
/// - Query by entityId to see all changes for that entity
/// - Maximum write throughput (different entities can write concurrently)
/// - Query by projectId to see all changes in sequence order
/// - Efficient range queries for syncing operations
///
/// Each project gets its own isolated partition in the same table, allowing:
/// - Multiple projects in the same DynamoDB table
/// - Project-specific sequence numbering (each project starts from 1)
/// - Efficient queries scoped to a single project
/// - Cost-effective table sharing across projects
class DynamoDBStorageService implements BaseStorageService {
  final String tableName;
  final String region;
  final bool useLocalDynamoDB;
  final String? localEndpoint;

  bool _initialized = false;
  late String _endpoint;
  late Map<String, String> _headers;

  DynamoDBStorageService({
    required this.tableName,
    this.region = 'us-east-1',
    this.useLocalDynamoDB = false,
    this.localEndpoint = 'http://localhost:8000',
  });

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    if (useLocalDynamoDB) {
      // Use DynamoDB Local for development
      _endpoint = localEndpoint!;
      _headers = {
        'Content-Type': 'application/x-amz-json-1.0',
        'Authorization':
            'AWS4-HMAC-SHA256 Credential=fake/20230101/$region/dynamodb/aws4_request, SignedHeaders=host;x-amz-date, Signature=fake',
        'X-Amz-Target': 'DynamoDB_20120810',
      };
    } else {
      // Use AWS DynamoDB - will use IAM role in Lambda
      _endpoint = 'https://dynamodb.$region.amazonaws.com';
      _headers = {
        'Content-Type': 'application/x-amz-json-1.0',
        'X-Amz-Target': 'DynamoDB_20120810',
      };
    }

    _initialized = true;

    // Create table if it doesn't exist (for local development)
    if (useLocalDynamoDB) {
      await _createTableIfNotExists();
    }
  }

  /// Delete and recreate the table with the new schema.
  /// WARNING: This will delete all existing data!
  Future<void> recreateTableWithNewSchema() async {
    if (!_initialized) await initialize();

    print('[DynamoDBStorage] Recreating table $tableName with new schema...');

    // Delete existing table if it exists
    await _deleteTableIfExists();

    // Wait a moment for deletion to complete
    await Future.delayed(const Duration(seconds: 2));

    // Create table with new schema
    await _createTableIfNotExists();

    print('[DynamoDBStorage] Table recreation completed');
  }

  Future<void> _deleteTableIfExists() async {
    // Check if table exists
    final describeRequest = {'TableName': tableName};

    final describeResponse = await _dynamoRequest(
      'DescribeTable',
      describeRequest,
    );

    if (describeResponse.statusCode != 200) {
      // Table doesn't exist
      return;
    }

    // Delete table
    final deleteRequest = {'TableName': tableName};

    final deleteResponse = await _dynamoRequest('DeleteTable', deleteRequest);

    if (deleteResponse.statusCode != 200) {
      throw Exception('Failed to delete table: ${deleteResponse.body}');
    }

    print('[DynamoDBStorage] Table $tableName deleted');
  }

  @override
  Future<void> close() async {
    _initialized = false;
  }

  @override
  Future<ChangeLogEntry> createChange(Map<String, dynamic> changeData) async {
    if (!_initialized) await initialize();

    // Validate required fields
    final changeProjectId = changeData['projectId'] as String?;
    if (changeProjectId == null || changeProjectId.isEmpty) {
      throw ArgumentError('projectId is required in changeData');
    }

    final entityType = changeData['entityType'] as String?;
    if (entityType == null || entityType.isEmpty) {
      throw ArgumentError('entityType is required in changeData');
    }

    final operation = changeData['operation'] as String?;
    if (operation == null || operation.isEmpty) {
      throw ArgumentError('operation is required in changeData');
    }

    final entityId = changeData['entityId'] as String?;
    if (entityId == null || entityId.isEmpty) {
      throw ArgumentError('entityId is required in changeData');
    }

    // Get or generate CID
    final cid =
        changeData['cid'] as String? ?? BaseChangeLogEntry.generateCid();

    // Get next sequence number for this specific project
    final seq = await _getNextSequence(changeProjectId);

    final now = DateTime.now().toUtc();
    final originalChangeAt = changeData['changeAt'] != null
        ? changeData['changeAt'] as String
        : now.toIso8601String();

    // Create primary key: PROJECT_ID#{projectId}#ENTITY_ID#{entityId}
    final primaryKey = 'PROJECT_ID#$changeProjectId#ENTITY_ID#$entityId';
    // Create sort key: CID#{cid}
    final sortKey = 'CID#$cid';
    // Create GSI keys for project-wide queries
    final gsi1PartitionKey = 'PROJECT_ID#$changeProjectId';
    final gsi1SortKey =
        'SEQ#${seq.toString().padLeft(10, '0')}'; // Zero-padded for proper sorting

    final item = {
      'pk': {'S': primaryKey},
      'sk': {'S': sortKey},
      'gsi1pk': {'S': gsi1PartitionKey},
      'gsi1sk': {'S': gsi1SortKey},
      'seq': {'N': seq.toString()},
      'cid': {'S': cid},
      'projectId': {'S': changeProjectId},
      'entityType': {'S': entityType},
      'operation': {'S': operation},
      'changeAt': {'S': originalChangeAt},
      'entityId': {'S': entityId},
      'dataJson': {'S': jsonEncode(changeData['data'] ?? {})},
      'cloudAt': {'S': now.toIso8601String()},
    };

    final putRequest = {'TableName': tableName, 'Item': item};

    final response = await _dynamoRequest('PutItem', putRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to create change: ${response.body}');
    }

    // Create ChangeLogEntry from the stored data with DynamoDB-generated seq
    final changeEntry = ChangeLogEntry(
      projectId: changeProjectId,
      entityType: EntityType.fromString(entityType),
      operation: operation,
      changeAt: DateTime.parse(originalChangeAt),
      entityId: entityId,
      dataJson: jsonEncode(changeData['data'] ?? {}),
      cloudAt: now,
      cid: cid,
    );

    // Override the Isar autoIncrement with DynamoDB-generated sequence
    changeEntry.seq = seq;

    return changeEntry;
  }

  @override
  Future<ChangeLogEntry?> getChange(String requestProjectId, int seq) async {
    if (!_initialized) await initialize();

    // Use GSI to query by project and sequence number
    final queryRequest = {
      'TableName': tableName,
      'IndexName': 'GSI1',
      'KeyConditionExpression': 'gsi1pk = :gsi1pk AND gsi1sk = :gsi1sk',
      'ExpressionAttributeValues': {
        ':gsi1pk': {'S': 'PROJECT_ID#$requestProjectId'},
        ':gsi1sk': {'S': 'SEQ#${seq.toString().padLeft(10, '0')}'},
      },
    };

    final response = await _dynamoRequest('Query', queryRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get change: ${response.body}');
    }

    final responseData = jsonDecode(response.body);
    final items = responseData['Items'] as List<dynamic>? ?? [];

    if (items.isEmpty) {
      return null;
    }

    return _itemToChangeLogEntry(items.first);
  }

  @override
  Future<List<ChangeLogEntry>> getChangesWithCursor({
    required String projectId,
    int? cursor,
    int? limit,
  }) async {
    if (!_initialized) await initialize();

    final queryRequest = {
      'TableName': tableName,
      'IndexName': 'GSI1',
      'KeyConditionExpression': 'gsi1pk = :gsi1pk',
      'ExpressionAttributeValues': {
        ':gsi1pk': {'S': 'PROJECT_ID#$projectId'},
      },
      'ScanIndexForward': true, // Sort by seq ascending
    };

    if (cursor != null) {
      // For cursor-based pagination, we need to start from the next sequence
      final paddedSeq = (cursor + 1).toString().padLeft(10, '0');
      queryRequest['KeyConditionExpression'] =
          'gsi1pk = :gsi1pk AND gsi1sk > :cursor';
      (queryRequest['ExpressionAttributeValues']
          as Map<String, dynamic>)[':cursor'] = {
        'S': 'SEQ#$paddedSeq',
      };
    }

    if (limit != null) {
      queryRequest['Limit'] = limit;
    }

    final response = await _dynamoRequest('Query', queryRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get changes: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final items = data['Items'] as List? ?? [];

    return items
        .map<ChangeLogEntry>((item) => _itemToChangeLogEntry(item))
        .toList();
  }

  @override
  Future<List<ChangeLogEntry>> getChangesSince(
    String projectId,
    int seq,
  ) async {
    if (!_initialized) await initialize();

    final queryRequest = {
      'TableName': tableName,
      'IndexName': 'GSI1',
      'KeyConditionExpression': 'gsi1pk = :gsi1pk AND gsi1sk > :seq',
      'ExpressionAttributeValues': {
        ':gsi1pk': {'S': 'PROJECT_ID#$projectId'},
        ':seq': {'S': 'SEQ#${seq.toString().padLeft(10, '0')}'},
      },
      'ScanIndexForward': true, // Sort by seq ascending
    };

    final response = await _dynamoRequest('Query', queryRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get changes since: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final items = data['Items'] as List? ?? [];

    return items
        .map<ChangeLogEntry>((item) => _itemToChangeLogEntry(item))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getChangeStats(String requestProjectId) async {
    if (!_initialized) await initialize();

    // Get total count of changes for this project using GSI
    final queryRequest = {
      'TableName': tableName,
      'IndexName': 'GSI1',
      'KeyConditionExpression': 'gsi1pk = :gsi1pk',
      'ExpressionAttributeValues': {
        ':gsi1pk': {'S': 'PROJECT_ID#$requestProjectId'},
      },
      'Select': 'COUNT',
    };

    final response = await _dynamoRequest('Query', queryRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get change stats: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final count = data['Count'] ?? 0;

    return {'total': count, 'scannedCount': data['ScannedCount'] ?? 0};
  }

  @override
  Future<Map<String, dynamic>> getEntityTypeStats(
    String requestProjectId,
  ) async {
    if (!_initialized) await initialize();

    // Use GSI to query all changes for this project
    final queryRequest = {
      'TableName': tableName,
      'IndexName': 'GSI1',
      'KeyConditionExpression': 'gsi1pk = :gsi1pk',
      'ExpressionAttributeValues': {
        ':gsi1pk': {'S': 'PROJECT_ID#$requestProjectId'},
      },
    };

    final response = await _dynamoRequest('Query', queryRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get entity type stats: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final items = data['Items'] as List? ?? [];

    final stats = <String, int>{};
    for (final item in items) {
      final entityType = item['entityType']?['S'] ?? 'unknown';
      stats[entityType] = (stats[entityType] ?? 0) + 1;
    }

    return stats;
  }

  @override
  Future<void> markAsOutdated(String projectId, int seq, int outdatedBy) async {
    // With the new schema, we need to find the item by sequence number first
    if (!_initialized) await initialize();

    // First, find the item using GSI
    final queryRequest = {
      'TableName': tableName,
      'IndexName': 'GSI1',
      'KeyConditionExpression': 'gsi1pk = :gsi1pk AND gsi1sk = :gsi1sk',
      'ExpressionAttributeValues': {
        ':gsi1pk': {'S': 'PROJECT_ID#$projectId'},
        ':gsi1sk': {'S': 'SEQ#${seq.toString().padLeft(10, '0')}'},
      },
    };

    final queryResponse = await _dynamoRequest('Query', queryRequest);

    if (queryResponse.statusCode != 200) {
      throw Exception('Failed to find change $seq: ${queryResponse.body}');
    }

    final queryData = jsonDecode(queryResponse.body);
    final items = queryData['Items'] as List? ?? [];

    if (items.isEmpty) {
      throw Exception('Change with sequence $seq not found');
    }

    final item = items.first;
    final pk = item['pk']['S'];
    final sk = item['sk']['S'];

    // Now update the item with the outdatedBy attribute
    final updateRequest = {
      'TableName': tableName,
      'Key': {
        'pk': {'S': pk},
        'sk': {'S': sk},
      },
      'UpdateExpression': 'SET outdatedBy = :outdatedBy',
      'ExpressionAttributeValues': {
        ':outdatedBy': {'N': outdatedBy.toString()},
      },
    };

    final response = await _dynamoRequest('UpdateItem', updateRequest);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to mark change $seq as outdated: ${response.body}',
      );
    }
  }

  @override
  Future<List<ChangeLogEntry>> getChangesNotOutdated(
    String requestProjectId,
  ) async {
    if (!_initialized) await initialize();

    final queryRequest = {
      'TableName': tableName,
      'IndexName': 'GSI1',
      'KeyConditionExpression': 'gsi1pk = :gsi1pk',
      'FilterExpression': 'attribute_not_exists(outdatedBy)',
      'ExpressionAttributeValues': {
        ':gsi1pk': {'S': 'PROJECT_ID#$requestProjectId'},
      },
      'ScanIndexForward': true, // Sort by seq ascending
    };

    final response = await _dynamoRequest('Query', queryRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get non-outdated changes: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final items = data['Items'] as List? ?? [];

    return items
        .map<ChangeLogEntry>((item) => _itemToChangeLogEntry(item))
        .toList();
  }

  /// Get all changes for a specific entity (new capability with improved schema)
  Future<List<ChangeLogEntry>> getChangesForEntity({
    required String projectId,
    required String entityId,
    int? limit,
  }) async {
    if (!_initialized) await initialize();

    final queryRequest = {
      'TableName': tableName,
      'KeyConditionExpression': 'pk = :pk',
      'ExpressionAttributeValues': {
        ':pk': {'S': 'PROJECT_ID#$projectId#ENTITY_ID#$entityId'},
      },
      'ScanIndexForward': false, // Sort by CID descending (newest first)
    };

    if (limit != null) {
      queryRequest['Limit'] = limit;
    }

    final response = await _dynamoRequest('Query', queryRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get changes for entity: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final items = data['Items'] as List? ?? [];

    return items
        .map<ChangeLogEntry>((item) => _itemToChangeLogEntry(item))
        .toList();
  }

  // Private helper methods

  Future<http.Response> _dynamoRequest(
    String target,
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse(_endpoint);
    final body = jsonEncode(payload);

    if (useLocalDynamoDB) {
      // For local DynamoDB, use fake auth headers
      final headers = Map<String, String>.from(_headers);
      headers['X-Amz-Target'] = 'DynamoDB_20120810.$target';

      return await http.post(uri, headers: headers, body: body);
    } else {
      // For real AWS DynamoDB, use AWS Signature V4 authentication
      try {
        // Get AWS credentials from environment variables (Lambda provides these)
        final accessKey = Platform.environment['AWS_ACCESS_KEY_ID'];
        final secretKey = Platform.environment['AWS_SECRET_ACCESS_KEY'];
        final sessionToken = Platform.environment['AWS_SESSION_TOKEN'];

        if (accessKey == null || secretKey == null) {
          throw Exception('AWS credentials not found in environment variables');
        }

        final credentials = AWSCredentials(
          accessKey,
          secretKey,
          sessionToken, // This is important for Lambda temporary credentials
        );

        final signer = AWSSigV4Signer(
          credentialsProvider: AWSCredentialsProvider(credentials),
        );

        // Encode body as bytes to ensure consistency between signing and sending
        final encodedBody = utf8.encode(body);

        final signedRequest = await signer.sign(
          AWSHttpRequest(
            method: AWSHttpMethod.post,
            uri: uri,
            headers: {
              'Content-Type': 'application/x-amz-json-1.0',
              'X-Amz-Target': 'DynamoDB_20120810.$target',
              'host': uri.host, // Explicitly include host header for SigV4
            },
            body: encodedBody,
          ),
          credentialScope: AWSCredentialScope(
            region: region,
            service: AWSService.dynamoDb,
          ),
        );

        // Use http.Request for finer control over headers and body
        final client = http.Client();
        final request = http.Request('POST', signedRequest.uri);
        request.headers.addAll(signedRequest.headers);
        request.bodyBytes = encodedBody; // Use the same encoded bytes

        final streamedResponse = await client.send(request);
        final response = await http.Response.fromStream(streamedResponse);
        client.close();

        return response;
      } catch (e) {
        print('[DynamoDB] Signing error: $e');
        print('[DynamoDB] Region: $region');
        print('[DynamoDB] Endpoint: $_endpoint');
        rethrow;
      }
    }
  }

  Map<String, dynamic> _dynamoItemToMap(Map<String, dynamic> item) {
    return {
      'seq': int.tryParse(item['seq']?['N'] ?? '0') ?? 0,
      'projectId':
          item['pk']?['S'] ?? '', // Extract projectId from partition key
      'entityType': item['entityType']?['S'] ?? '',
      'operation': item['operation']?['S'] ?? '',
      'changeAt': item['changeAt']?['S'] ?? '',
      'entityId': item['entityId']?['S'] ?? '',
      'data': _tryParseJson(item['dataJson']?['S']),
      'cloudAt': item['cloudAt']?['S'], // Include cloudAt if present
    };
  }

  dynamic _tryParseJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return {};
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return {};
    }
  }

  Future<int> _getNextSequence(String projectId) async {
    // Use atomic counter for sequence generation per project
    final updateRequest = {
      'TableName': tableName,
      'Key': {
        'pk': {'S': 'SEQUENCE#$projectId'},
        'seq': {'N': '0'},
      },
      'UpdateExpression': 'SET #val = if_not_exists(#val, :start) + :inc',
      'ExpressionAttributeNames': {'#val': 'value'},
      'ExpressionAttributeValues': {
        ':start': {'N': '0'},
        ':inc': {'N': '1'},
      },
      'ReturnValues': 'UPDATED_NEW',
    };

    final response = await _dynamoRequest('UpdateItem', updateRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get next sequence: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final value = data['Attributes']?['value']?['N'];
    return int.tryParse(value ?? '1') ?? 1;
  }

  Future<void> _createTableIfNotExists() async {
    // Check if table exists
    final describeRequest = {'TableName': tableName};

    final describeResponse = await _dynamoRequest(
      'DescribeTable',
      describeRequest,
    );

    if (describeResponse.statusCode == 200) {
      // Table exists
      return;
    }

    // Create table with new schema
    final createRequest = {
      'TableName': tableName,
      'KeySchema': [
        {'AttributeName': 'pk', 'KeyType': 'HASH'},
        {'AttributeName': 'sk', 'KeyType': 'RANGE'},
      ],
      'AttributeDefinitions': [
        {'AttributeName': 'pk', 'AttributeType': 'S'},
        {'AttributeName': 'sk', 'AttributeType': 'S'},
        {'AttributeName': 'gsi1pk', 'AttributeType': 'S'},
        {'AttributeName': 'gsi1sk', 'AttributeType': 'S'},
      ],
      'GlobalSecondaryIndexes': [
        {
          'IndexName': 'GSI1',
          'KeySchema': [
            {'AttributeName': 'gsi1pk', 'KeyType': 'HASH'},
            {'AttributeName': 'gsi1sk', 'KeyType': 'RANGE'},
          ],
          'Projection': {'ProjectionType': 'ALL'},
        },
      ],
      'BillingMode': 'PAY_PER_REQUEST',
    };

    final createResponse = await _dynamoRequest('CreateTable', createRequest);

    if (createResponse.statusCode != 200) {
      throw Exception('Failed to create table: ${createResponse.body}');
    }

    // Wait for table to be active
    print('[DynamoDBStorage] Table $tableName created successfully');
  }

  /// Get all unique project IDs from the table
  @override
  Future<List<String>> getAllProjects() async {
    await initialize();

    // Use a scan operation to find all project IDs from projectId attribute
    final scanRequest = {
      'TableName': tableName,
      'ProjectionExpression': 'projectId',
    };

    final response = await _dynamoRequest('Scan', scanRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to scan projects: ${response.body}');
    }

    final responseData = jsonDecode(response.body);
    final items = responseData['Items'] as List<dynamic>? ?? [];

    // Extract unique project IDs
    final projectIds = <String>{};
    for (final item in items) {
      final projectId = item['projectId']?['S'] as String?;
      if (projectId != null && projectId.isNotEmpty) {
        projectIds.add(projectId);
      }
    }

    return projectIds.toList()..sort();
  }

  /// Helper method to convert DynamoDB item to ChangeLogEntry
  ChangeLogEntry _itemToChangeLogEntry(Map<String, dynamic> item) {
    final itemMap = _dynamoItemToMap(item);
    final changeEntry =
        BaseChangeLogEntry.fromApiData(itemMap) as ChangeLogEntry;
    // Override with DynamoDB sequence number
    changeEntry.seq = itemMap['seq'] as int;
    return changeEntry;
  }
}
