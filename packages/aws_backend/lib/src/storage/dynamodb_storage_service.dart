import 'dart:convert';
import 'dart:io';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';

/// Lightweight DynamoDB implementation for AWS Lambda deployment.
///
/// Uses HTTP API calls instead of heavy AWS SDK to minimize cold start time.
/// This service stores data in AWS DynamoDB with a single table design:
///
/// **Change Log Entries:**
/// - PK: 'DOMAIN_TYPE#{domainType}#DOMAIN_ID#{domainId}#ENTITY_ID#{entityId}'
/// - SK: 'CID#{cid}'
/// - GSI1PK: 'CHANGE_LOG_ID#{domainId}'
/// - GSI1SK: 'SEQ#{seq}'
///
/// **Entity State Data:**
/// - PK: 'DOMAIN_TYPE#{domainType}#DOMAIN_ID#{domainId}#ENTITY_TYPE#{entityType}'
/// - SK: '{entityId}' (entityId contains embedded entity type suffix)
/// - EntityId format: 'YYYY-mmdd-HHMMss-sss±HHmm-XXXX-{suffix}'
///   where suffix is 4-char entity type (e.g., 'proj', 'docu', 'vidZ', 'cmnt')
///
/// **Sequence Counters:**
/// - PK: 'SEQUENCE#{projectId}'
/// - SK: 'COUNTER'
///
/// Each project gets its own isolated partition, allowing:
/// - Multiple projects in the same DynamoDB table
/// - Project-specific sequence numbering (each project starts from 1)
/// - Efficient queries scoped to a single project
/// - Cost-effective table sharing across projects
/// - Fast entity state lookups by entity type
class DynamoDBStorageService extends BaseStorageService {
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

    // Get next sequence number for this specific project
    final seq = await _getNextSequence(changeProjectId);

    final now = DateTime.now().toUtc();
    final originalChangeAt = changeData['changeAt'] != null
        ? changeData['changeAt'] as String
        : now.toIso8601String();

    // Generate CID if not provided
    final cid =
        changeData['cid'] as String? ?? BaseChangeLogEntry.generateCid();

    // Extract changeBy from changeData
    final changeBy = changeData['changeBy'] as String? ?? '';

    final item = {
      'pk': {'S': 'PROJECT_ID#$changeProjectId#ENTITY_ID#$entityId'},
      'sk': {'S': 'CID#$cid'},
      'gsi1pk': {'S': 'PROJECT_ID#$changeProjectId'},
      'gsi1sk': {'S': 'SEQ#${seq.toString().padLeft(10, '0')}'},
      'seq': {'N': seq.toString()},
      'entityType': {'S': entityType},
      'operation': {'S': operation},
      'changeAt': {
        'S': originalChangeAt,
      }, // When the change was originally made
      'entityId': {'S': entityId},
      'dataJson': {'S': jsonEncode(changeData['data'] ?? {})},
      'cloudAt': {'S': now.toIso8601String()}, // When cloud storage received it
      'cid': {'S': cid},
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
      changeBy: changeBy,
    );

    // Override the Isar autoIncrement with DynamoDB-generated sequence
    changeEntry.seq = seq;

    // Store entity data for efficient querying
    await _storeEntityData(changeEntry);

    return changeEntry;
  }

  @override
  Future<ChangeLogEntry?> getChange(String domainId, int seq) async {
    if (!_initialized) await initialize();

    // Query GSI1 to find the change by sequence number
    final queryRequest = {
      'TableName': tableName,
      'IndexName': 'GSI1',
      'KeyConditionExpression': 'gsi1pk = :gsi1pk AND gsi1sk = :gsi1sk',
      'ExpressionAttributeValues': {
        ':gsi1pk': {'S': 'PROJECT_ID#$domainId'},
        ':gsi1sk': {'S': 'SEQ#${seq.toString().padLeft(10, '0')}'},
      },
      'Limit': 1,
    };

    final response = await _dynamoRequest('Query', queryRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get change: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final items = data['Items'] as List?;

    if (items == null || items.isEmpty) return null;

    final itemMap = _dynamoItemToMap(items.first);
    final changeEntry =
        BaseChangeLogEntry.fromApiData(itemMap) as ChangeLogEntry;
    // Override with DynamoDB sequence number
    changeEntry.seq = itemMap['seq'] as int;
    return changeEntry;
  }

  @override
  Future<List<ChangeLogEntry>> getChangesWithCursor({
    required String domainId,
    int? cursor,
    int? limit,
  }) async {
    if (!_initialized) await initialize();

    final queryRequest = {
      'TableName': tableName,
      'IndexName': 'GSI1',
      'KeyConditionExpression': 'gsi1pk = :gsi1pk',
      'ExpressionAttributeValues': {
        ':gsi1pk': {'S': 'PROJECT_ID#$domainId'},
      },
      'ScanIndexForward': true, // Sort by gsi1sk (SEQ) ascending
    };

    if (cursor != null) {
      queryRequest['ExclusiveStartKey'] = {
        'gsi1pk': {'S': 'PROJECT_ID#$domainId'},
        'gsi1sk': {'S': 'SEQ#${cursor.toString().padLeft(10, '0')}'},
        // Need to include the primary key attributes as well
        'pk': {
          'S': 'PROJECT_ID#$domainId#ENTITY_ID#placeholder',
        }, // This will be ignored in the actual query
        'sk': {
          'S': 'CID#placeholder',
        }, // This will be ignored in the actual query
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

    return items.map<ChangeLogEntry>((item) {
      final itemMap = _dynamoItemToMap(item);
      final changeEntry =
          BaseChangeLogEntry.fromApiData(itemMap) as ChangeLogEntry;
      // Override with DynamoDB sequence number
      changeEntry.seq = itemMap['seq'] as int;
      return changeEntry;
    }).toList();
  }

  Future<List<ChangeLogEntry>> getChangesSince(String domainId, int seq) async {
    if (!_initialized) await initialize();

    final queryRequest = {
      'TableName': tableName,
      'IndexName': 'GSI1',
      'KeyConditionExpression': 'gsi1pk = :gsi1pk AND gsi1sk > :gsi1sk',
      'ExpressionAttributeValues': {
        ':gsi1pk': {'S': 'PROJECT_ID#$domainId'},
        ':gsi1sk': {'S': 'SEQ#${seq.toString().padLeft(10, '0')}'},
      },
      'ScanIndexForward': true, // Sort by gsi1sk (SEQ) ascending
    };

    final response = await _dynamoRequest('Query', queryRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get changes since $seq: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final items = data['Items'] as List? ?? [];

    return items.map<ChangeLogEntry>((item) {
      final itemMap = _dynamoItemToMap(item);
      final changeEntry =
          BaseChangeLogEntry.fromApiData(itemMap) as ChangeLogEntry;
      // Override with DynamoDB sequence number
      changeEntry.seq = itemMap['seq'] as int;
      return changeEntry;
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getChangeStats(String domainId) async {
    if (!_initialized) await initialize();

    // Get total count of changes for this project using GSI1
    final queryRequest = {
      'TableName': tableName,
      'IndexName': 'GSI1',
      'KeyConditionExpression': 'gsi1pk = :gsi1pk',
      'ExpressionAttributeValues': {
        ':gsi1pk': {'S': 'PROJECT_ID#$domainId'},
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
  Future<BaseEntityState?> getCurrentEntityState(
    String domainId,
    String entityType,
    String entityId,
  ) async {
    if (!_initialized) await initialize();

    try {
      // Query the entity state table using the same pattern as getEntityStates()
      // This looks up the current entity state, not the change log
      final pk = 'PROJECT_ID#$domainId#ENTITY_TYPE#$entityType';
      final queryRequest = {
        'TableName': tableName,
        'KeyConditionExpression': 'pk = :pk AND sk = :sk',
        'ExpressionAttributeValues': {
          ':pk': {'S': pk},
          ':sk': {'S': entityId},
        },
        'Limit': 1,
      };

      print(
        '[getCurrentEntityState] Querying entity state for pk: $pk, sk: $entityId',
      );

      final response = await _dynamoRequest('Query', queryRequest);

      print(
        '[getCurrentEntityState] Query response status: ${response.statusCode}',
      );
      print('[getCurrentEntityState] Query response body: ${response.body}');

      if (response.statusCode != 200) {
        print('getCurrentEntityState query failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw ArgumentError(
          'Failed to query current entity state for $entityType:$entityId in project $domainId: ${response.body}',
        );
      }

      final data = jsonDecode(response.body);
      final items = data['Items'] as List? ?? [];

      print('[getCurrentEntityState] Found ${items.length} items');

      if (items.isEmpty) {
        print(
          '[getCurrentEntityState] No entity found for $entityType:$entityId',
        );
        return null; // Entity not found
      }

      // Convert the entity state to ChangeLogEntry
      // Entity state items have a different structure than change log entries
      final item = items.first;
      final entityData = <String, dynamic>{};

      // Extract entity data fields (prefixed with 'data_')
      for (final entry in item.entries) {
        final key = entry.key;
        final value = entry.value;

        if (key.startsWith('data_')) {
          // Entity field data
          final fieldName = key.substring(5); // Remove 'data_' prefix
          entityData[fieldName] = _convertAttributeValueToJson(value);
        }
      }

      return null; // todo
    } catch (e) {
      print('Error in getCurrentEntityState: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> getStateStats(String domainId) async {
    if (!_initialized) await initialize();

    // For DynamoDB, we use Query on GSI1 instead of Scan for better performance
    // since we're querying for a specific project
    final queryRequest = {
      'TableName': tableName,
      'IndexName': 'GSI1',
      'KeyConditionExpression': 'gsi1pk = :gsi1pk',
      'ExpressionAttributeValues': {
        ':gsi1pk': {'S': 'PROJECT_ID#$domainId'},
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
    // Extract projectId from pk format: PROJECT_ID#{projectId}#ENTITY_ID#{entityId}
    final pk = item['pk']?['S'] ?? '';
    String projectId = '';
    if (pk.startsWith('PROJECT_ID#')) {
      final parts = pk.split('#');
      if (parts.length >= 2) {
        projectId = parts[1];
      }
    }

    return {
      'seq': int.tryParse(item['seq']?['N'] ?? '0') ?? 0,
      'projectId': projectId,
      'entityType': item['entityType']?['S'] ?? '',
      'operation': item['operation']?['S'] ?? '',
      'changeAt': item['changeAt']?['S'] ?? '',
      'entityId': item['entityId']?['S'] ?? '',
      'data': _tryParseJson(item['dataJson']?['S']),
      'cloudAt': item['cloudAt']?['S'], // Include cloudAt if present
      'cid': item['cid']?['S'] ?? '', // Include CID from new schema
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
        'sk': {'S': 'COUNTER'},
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

    // Create table
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
  Future<List<String>> getAllDomainIds() async {
    await initialize();

    // Use a scan operation with a filter for entityType = 'project'
    final scanRequest = {
      'TableName': tableName,
      'FilterExpression': 'entityType = :entityType',
      'ExpressionAttributeValues': {
        ':entityType': {'S': 'project'},
      },
      'ProjectionExpression':
          'pk', // Only return the partition key (project ID)
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
      final pk = item['pk']?['S'] as String?;
      if (pk != null && pk.startsWith('PROJECT_ID#')) {
        // Extract project ID from pk format: PROJECT_ID#{projectId}#ENTITY_ID#{entityId}
        final parts = pk.split('#');
        if (parts.length >= 2) {
          final projectId = parts[1];
          projectIds.add(projectId);
        }
      }
    }

    return projectIds.toList()..sort();
  }

  @override
  Future<Map<String, dynamic>> getEntityStates({
    required String domainId,
    required String entityType,
    String? cursor,
    int? limit,
    bool includeMetadata = false,
  }) async {
    if (!_initialized) await initialize();

    // Validate entity type exists
    final validEntityType = EntityType.tryFromString(entityType);
    if (validEntityType == null) {
      throw ArgumentError('Invalid entity type: $entityType');
    }

    try {
      final actualLimit = limit ?? 100;
      final pk = 'PROJECT_ID#$domainId#ENTITY_TYPE#$entityType';

      final queryInput = {
        'TableName': tableName,
        'KeyConditionExpression': 'pk = :pk',
        'ExpressionAttributeValues': {
          ':pk': {'S': pk},
        },
        'Limit': actualLimit + 1, // Get one extra to check if there are more
        'ScanIndexForward': true, // Sort by SK ascending
      };

      // Add cursor for pagination
      if (cursor != null && cursor.isNotEmpty) {
        queryInput['ExclusiveStartKey'] = {
          'pk': {'S': pk},
          'sk': {'S': cursor},
        };
      }

      final response = await _dynamoRequest('Query', queryInput);

      if (response.statusCode != 200) {
        throw Exception('DynamoDB query failed: ${response.body}');
      }

      final result = jsonDecode(response.body);
      final items = result['Items'] as List<dynamic>? ?? [];

      // Check if there are more items
      final hasMore = items.length > actualLimit;
      final entitiesToReturn = hasMore
          ? items.take(actualLimit).toList()
          : items;

      // Convert DynamoDB items to entity objects
      final entities = <Map<String, dynamic>>[];
      String? nextCursor;

      for (final item in entitiesToReturn) {
        final entity = _convertDynamoItemToEntity(item, includeMetadata);
        entities.add(entity);
        nextCursor = item['sk']?['S']; // Update cursor to last processed item
      }

      return {
        'items': entities,
        'hasMore': hasMore,
        'nextCursor': hasMore ? nextCursor : null,
      };
    } catch (e) {
      throw Exception('Failed to get entity states for $entityType: $e');
    }
  }

  /// Helper method to convert DynamoDB item to entity using shared conflict resolution
  Map<String, dynamic> _convertDynamoItemToEntity(
    Map<String, dynamic> item,
    bool includeMetadata,
  ) {
    final entity = <String, dynamic>{};

    // Extract basic entity data
    final sk = item['sk']?['S'] as String? ?? '';
    entity['entityId'] = _extractEntityIdFromSK(sk);

    // Use BaseEntityState for conflict resolution if we have change data
    BaseEntityState? entityState;
    final entityTypeStr = item['entityType']?['S'] as String?;
    if (entityTypeStr != null) {
      final entityType = EntityType.tryFromString(entityTypeStr);
      if (entityType != null) {
        entityState = BaseEntityState()
          ..entityId = entity['entityId']
          ..entityType = entityType
          ..projectId = item['projectId']?['S'] as String? ?? '';
      }
    }

    // Convert entity data from DynamoDB format
    for (final entry in item.entries) {
      final key = entry.key;
      final value = entry.value;

      if (key.startsWith('data_')) {
        // Entity field data
        final fieldName = key.substring(5); // Remove 'data_' prefix
        entity[fieldName] = _convertAttributeValueToJson(value);
      } else if (includeMetadata) {
        // Include metadata fields for conflict resolution
        if (key.endsWith('_meta') ||
            key.endsWith('ChangeAt') ||
            key.endsWith('ChangeBy') ||
            key.endsWith('Cid') ||
            key == 'cid' ||
            key == 'cloudAt' ||
            key == 'changeAt' ||
            key == 'seq' ||
            key == 'operation') {
          entity[key] = _convertAttributeValueToJson(value);
        }
      }
    }

    // If we have an entity state and metadata is requested, include state metadata
    if (entityState != null && includeMetadata) {
      final stateJson = entityState.toJson();
      for (final entry in stateJson.entries) {
        if (entry.key.endsWith('ChangeAt') ||
            entry.key.endsWith('Cid') ||
            entry.key.endsWith('ChangeBy')) {
          entity[entry.key] = entry.value;
        }
      }
    }

    return entity;
  }

  /// Extract entityId from SK (SK now IS the entityId with embedded suffix)
  String _extractEntityIdFromSK(String sk) {
    // Since SK is now the entityId directly, just return it
    return sk;
  }

  /// Helper to convert AttributeValue to JSON-compatible value
  dynamic _convertAttributeValueToJson(dynamic attr) {
    if (attr is Map<String, dynamic>) {
      if (attr.containsKey('S')) return attr['S'];
      if (attr.containsKey('N')) return num.tryParse(attr['N']) ?? attr['N'];
      if (attr.containsKey('BOOL')) return attr['BOOL'];
      if (attr.containsKey('SS')) return attr['SS'];
      if (attr.containsKey('NS')) {
        return (attr['NS'] as List).map((n) => num.tryParse(n) ?? n).toList();
      }
      if (attr.containsKey('L')) {
        return (attr['L'] as List).map(_convertAttributeValueToJson).toList();
      }
      if (attr.containsKey('M')) {
        final map = <String, dynamic>{};
        for (final entry in (attr['M'] as Map<String, dynamic>).entries) {
          map[entry.key] = _convertAttributeValueToJson(entry.value);
        }
        return map;
      }
      if (attr.containsKey('NULL')) return null;
    }
    return attr;
  }

  /// Store entity data for efficient querying using single table design
  Future<void> _storeEntityData(ChangeLogEntry change) async {
    try {
      // For entity state storage, use the entityId directly since it already contains the suffix
      // The entityId should be generated using EntityType.generateEntityId() in client code
      final pk =
          'PROJECT_ID#${change.projectId}#ENTITY_TYPE#${change.entityType.value}';
      final sk = change.entityId; // Use entityId directly as sort key

      final item = <String, dynamic>{
        'pk': {'S': pk},
        'sk': {'S': sk},
        'entityId': {'S': change.entityId},
        'entityType': {'S': change.entityType.value},
        'projectId': {'S': change.projectId},
        'operation': {'S': change.operation},
        'changeAt': {'S': change.changeAt.toIso8601String()},
        'seq': {'N': change.seq.toString()},
      };

      // Store entity data fields with data_ prefix
      final data = change.data;
      for (final entry in data.entries) {
        final key = 'data_${entry.key}';
        item[key] = _convertJsonToAttributeValue(entry.value);
      }

      // Store metadata for conflict resolution
      item['changeAt_meta'] = {'S': change.changeAt.toIso8601String()};
      item['cid_meta'] = {'S': change.cid};
      if (change.changeBy.isNotEmpty) {
        item['changeBy_meta'] = {'S': change.changeBy};
      }
      if (change.cloudAt != null) {
        item['cloudAt_meta'] = {'S': change.cloudAt!.toIso8601String()};
      }

      final putRequest = {
        'TableName': tableName,
        'Item': item,
        // Use conditional expression to handle updates properly - only update if newer
        'ConditionExpression':
            'attribute_not_exists(pk) OR #changeAt < :newChangeAt',
        'ExpressionAttributeNames': {'#changeAt': 'changeAt'},
        'ExpressionAttributeValues': {
          ':newChangeAt': {'S': change.changeAt.toIso8601String()},
        },
      };

      final response = await _dynamoRequest('PutItem', putRequest);

      if (response.statusCode != 200 &&
          !response.body.contains('ConditionalCheckFailedException')) {
        print('Warning: Failed to store entity data: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('ConditionalCheckFailedException')) {
        // This is expected when trying to store an older change
        print('Skipping entity storage for older change: ${change.entityId}');
      } else {
        print('Error storing entity data: $e');
        // Don't fail the entire operation if entity storage fails
      }
    }
  }

  /// Helper to convert JSON value to DynamoDB AttributeValue format
  Map<String, dynamic> _convertJsonToAttributeValue(dynamic value) {
    if (value == null) return {'NULL': true};
    if (value is String) return {'S': value};
    if (value is num) return {'N': value.toString()};
    if (value is bool) return {'BOOL': value};
    if (value is List) {
      return {'L': value.map(_convertJsonToAttributeValue).toList()};
    }
    if (value is Map<String, dynamic>) {
      final map = <String, dynamic>{};
      for (final entry in value.entries) {
        map[entry.key] = _convertJsonToAttributeValue(entry.value);
      }
      return {'M': map};
    }
    return {'S': value.toString()};
  }
}
