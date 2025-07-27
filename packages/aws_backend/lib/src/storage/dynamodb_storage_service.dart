import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';

/// Lightweight DynamoDB implementation for AWS Lambda deployment.
///
/// Uses HTTP API calls instead of heavy AWS SDK to minimize cold start time.
/// This service stores change log entries in AWS DynamoDB with the following schema:
/// - Table name: configurable (e.g., 'sltt-changes-prod')
/// - Partition key: 'pk' (String) - project ID (e.g., 'project-123')
/// - Sort key: 'seq' (Number) - auto-incremented sequence number per project
/// - Attributes: entityType, operation, timestamp, entityId, dataJson, outdatedBy
///
/// Each project gets its own isolated partition in the same table, allowing:
/// - Multiple projects in the same DynamoDB table
/// - Project-specific sequence numbering (each project starts from 1)
/// - Efficient queries scoped to a single project
/// - Cost-effective table sharing across projects
class DynamoDBStorageService implements BaseStorageService {
  final String tableName;
  final String projectId;
  final String region;
  final bool useLocalDynamoDB;
  final String? localEndpoint;

  bool _initialized = false;
  late String _endpoint;
  late Map<String, String> _headers;

  DynamoDBStorageService({
    required this.tableName,
    required this.projectId,
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
  Future<Map<String, dynamic>> createChange(Map<String, dynamic> changeData) async {
    if (!_initialized) await initialize();

    // Get next sequence number
    final seq = await _getNextSequence();

    final item = {
      'pk': {'S': projectId},
      'seq': {'N': seq.toString()},
      'entityType': {'S': changeData['entityType'] ?? ''},
      'operation': {'S': changeData['operation'] ?? ''},
      'timestamp': {'S': changeData['timestamp'] ?? DateTime.now().toIso8601String()},
      'entityId': {'S': changeData['entityId'] ?? ''},
      'dataJson': {'S': jsonEncode(changeData['data'] ?? {})},
    };

    final putRequest = {
      'TableName': tableName,
      'Item': item,
    };

    final response = await _dynamoRequest('PutItem', putRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to create change: ${response.body}');
    }

    return {
      'seq': seq,
      'entityType': changeData['entityType'],
      'operation': changeData['operation'],
      'timestamp': changeData['timestamp'] ?? DateTime.now().toIso8601String(),
      'entityId': changeData['entityId'],
      'data': changeData['data'] ?? {},
    };
  }

  @override
  Future<Map<String, dynamic>?> getChange(int seq) async {
    if (!_initialized) await initialize();

    final getRequest = {
      'TableName': tableName,
      'Key': {
        'pk': {'S': projectId},
        'seq': {'N': seq.toString()},
      },
    };

    final response = await _dynamoRequest('GetItem', getRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get change: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final item = data['Item'];

    if (item == null) return null;

    return _dynamoItemToMap(item);
  }

  @override
  Future<List<Map<String, dynamic>>> getChangesWithCursor({
    int? cursor,
    int? limit,
  }) async {
    if (!_initialized) await initialize();

    final queryRequest = {
      'TableName': tableName,
      'KeyConditionExpression': 'pk = :pk',
      'ExpressionAttributeValues': {
        ':pk': {'S': projectId},
      },
      'ScanIndexForward': true, // Sort by seq ascending
    };

    if (cursor != null) {
      queryRequest['ExclusiveStartKey'] = {
        'pk': {'S': projectId},
        'seq': {'N': cursor.toString()},
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

    return items.map<Map<String, dynamic>>((item) => _dynamoItemToMap(item)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getChangesSince(int seq) async {
    if (!_initialized) await initialize();

    final queryRequest = {
      'TableName': tableName,
      'KeyConditionExpression': 'pk = :pk AND seq > :seq',
      'ExpressionAttributeValues': {
        ':pk': {'S': projectId},
        ':seq': {'N': seq.toString()},
      },
      'ScanIndexForward': true, // Sort by seq ascending
    };

    final response = await _dynamoRequest('Query', queryRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get changes since $seq: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final items = data['Items'] as List? ?? [];

    return items.map<Map<String, dynamic>>((item) => _dynamoItemToMap(item)).toList();
  }

  @override
  Future<Map<String, dynamic>> getChangeStats() async {
    if (!_initialized) await initialize();

    // Get total count of changes for this project
    final queryRequest = {
      'TableName': tableName,
      'KeyConditionExpression': 'pk = :pk',
      'ExpressionAttributeValues': {
        ':pk': {'S': projectId},
      },
      'Select': 'COUNT',
    };

    final response = await _dynamoRequest('Query', queryRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get change stats: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final count = data['Count'] ?? 0;

    return {
      'totalChanges': count,
      'scannedCount': data['ScannedCount'] ?? 0,
    };
  }

  @override
  Future<Map<String, dynamic>> getEntityTypeStats() async {
    if (!_initialized) await initialize();

    // For DynamoDB, we use Query instead of Scan for better performance
    // since we're querying for a specific project
    final queryRequest = {
      'TableName': tableName,
      'KeyConditionExpression': 'pk = :pk',
      'ExpressionAttributeValues': {
        ':pk': {'S': projectId},
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
  Future<void> markAsOutdated(int seq, int outdatedBy) async {
    // For DynamoDB, we can add an 'outdatedBy' attribute to mark items as outdated
    if (!_initialized) await initialize();

    final updateRequest = {
      'TableName': tableName,
      'Key': {
        'pk': {'S': projectId},
        'seq': {'N': seq.toString()},
      },
      'UpdateExpression': 'SET outdatedBy = :outdatedBy',
      'ExpressionAttributeValues': {
        ':outdatedBy': {'N': outdatedBy.toString()},
      },
    };

    final response = await _dynamoRequest('UpdateItem', updateRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to mark change $seq as outdated: ${response.body}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getChangesNotOutdated() async {
    if (!_initialized) await initialize();

    final queryRequest = {
      'TableName': tableName,
      'KeyConditionExpression': 'pk = :pk',
      'FilterExpression': 'attribute_not_exists(outdatedBy)',
      'ExpressionAttributeValues': {
        ':pk': {'S': projectId},
      },
      'ScanIndexForward': true, // Sort by seq ascending
    };

    final response = await _dynamoRequest('Query', queryRequest);

    if (response.statusCode != 200) {
      throw Exception('Failed to get non-outdated changes: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final items = data['Items'] as List? ?? [];

    return items.map<Map<String, dynamic>>((item) => _dynamoItemToMap(item)).toList();
  }

  // Private helper methods

  Future<http.Response> _dynamoRequest(String target, Map<String, dynamic> payload) async {
    final headers = Map<String, String>.from(_headers);
    headers['X-Amz-Target'] = 'DynamoDB_20120810.$target';

    return await http.post(
      Uri.parse(_endpoint),
      headers: headers,
      body: jsonEncode(payload),
    );
  }

  Map<String, dynamic> _dynamoItemToMap(Map<String, dynamic> item) {
    return {
      'seq': int.tryParse(item['seq']?['N'] ?? '0') ?? 0,
      'entityType': item['entityType']?['S'] ?? '',
      'operation': item['operation']?['S'] ?? '',
      'timestamp': item['timestamp']?['S'] ?? '',
      'entityId': item['entityId']?['S'] ?? '',
      'data': _tryParseJson(item['dataJson']?['S']),
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

  Future<int> _getNextSequence() async {
    // Use atomic counter for sequence generation per project
    final updateRequest = {
      'TableName': tableName,
      'Key': {
        'pk': {'S': 'SEQUENCE#$projectId'},
        'seq': {'N': '0'},
      },
      'UpdateExpression': 'SET #val = if_not_exists(#val, :start) + :inc',
      'ExpressionAttributeNames': {
        '#val': 'value',
      },
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
    final describeRequest = {
      'TableName': tableName,
    };

    final describeResponse = await _dynamoRequest('DescribeTable', describeRequest);

    if (describeResponse.statusCode == 200) {
      // Table exists
      return;
    }

    // Create table
    final createRequest = {
      'TableName': tableName,
      'KeySchema': [
        {
          'AttributeName': 'pk',
          'KeyType': 'HASH',
        },
        {
          'AttributeName': 'seq',
          'KeyType': 'RANGE',
        },
      ],
      'AttributeDefinitions': [
        {
          'AttributeName': 'pk',
          'AttributeType': 'S',
        },
        {
          'AttributeName': 'seq',
          'AttributeType': 'N',
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
}
