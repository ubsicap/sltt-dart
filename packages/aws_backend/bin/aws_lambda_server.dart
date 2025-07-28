import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/aws_backend.dart';

/// Simple AWS Lambda handler for SLTT backend API.
///
/// This provides a basic Lambda function that can be deployed to AWS
/// without complex runtime dependencies.
Future<Map<String, dynamic>> handler(Map<String, dynamic> event) async {
  try {
    // Get configuration from environment variables
    final tableName =
        Platform.environment['DYNAMODB_TABLE'] ?? 'sltt-changes-dev';
    final projectId = Platform.environment['PROJECT_ID'] ?? 'default-project';
    final region = Platform.environment['AWS_REGION'] ?? 'us-east-1';

    // Create DynamoDB storage service
    final storage = DynamoDBStorageService(
      tableName: tableName,
      projectId: projectId,
      region: region,
      useLocalDynamoDB: false, // Always use real AWS in Lambda
    );

    // Initialize storage
    await storage.initialize();

    // Handle basic HTTP methods
    final httpMethod = event['httpMethod'] as String? ?? 'GET';

    switch (httpMethod) {
      case 'GET':
        return await _handleGetRequest(storage, event);
      case 'POST':
        return await _handlePostRequest(storage, event);
      default:
        return _errorResponse('Method not allowed', 405);
    }
  } catch (e, stackTrace) {
    print('Lambda error: $e');
    print('Stack trace: $stackTrace');
    return _errorResponse('Internal server error: $e', 500);
  }
}

/// Handle GET requests
Future<Map<String, dynamic>> _handleGetRequest(
  DynamoDBStorageService storage,
  Map<String, dynamic> event,
) async {
  final path = event['path'] as String? ?? '/';
  final queryParams =
      event['queryStringParameters'] as Map<String, dynamic>? ?? {};

  try {
    if (path.contains('/changes')) {
      if (path.contains(RegExp(r'/changes/\d+$'))) {
        // Get specific change: /api/changes/123
        final seq = int.parse(path.split('/').last);
        final change = await storage.getChange(storage.projectId, seq);

        if (change == null) {
          return _errorResponse('Change not found', 404);
        }

        return _successResponse(change);
      } else {
        // Get changes with pagination: /api/changes
        final cursor = int.tryParse(queryParams['cursor']?.toString() ?? '');
        final limit =
            int.tryParse(queryParams['limit']?.toString() ?? '100') ?? 100;

        final changes = await storage.getChangesWithCursor(
          projectId: storage.projectId,
          cursor: cursor,
          limit: limit.clamp(1, 1000),
        );

        return _successResponse({
          'changes': changes,
          'count': changes.length,
          'cursor': changes.isNotEmpty ? changes.last['seq'] : cursor,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } else if (path.contains('/stats')) {
      // Get statistics: /api/stats
      final stats = await storage.getChangeStats(storage.projectId);
      return _successResponse(stats);
    } else if (path.contains('/health')) {
      // Health check: /health
      return _successResponse({
        'status': 'healthy',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else {
      return _errorResponse('Not found', 404);
    }
  } catch (e) {
    return _errorResponse('Error processing GET request: $e', 500);
  }
}

/// Handle POST requests
Future<Map<String, dynamic>> _handlePostRequest(
  DynamoDBStorageService storage,
  Map<String, dynamic> event,
) async {
  final path = event['path'] as String? ?? '/';
  final body = event['body'] as String? ?? '{}';

  try {
    if (path.contains('/changes')) {
      // Create changes: POST /api/changes
      final data = jsonDecode(body);

      if (data is! List) {
        return _errorResponse('Request body must be an array', 400);
      }

      final changes = data.cast<Map<String, dynamic>>();
      final createdChanges = <Map<String, dynamic>>[];
      final seqMap = <String, int>{};

      for (final changeData in changes) {
        final originalSeq = changeData['seq'];
        final created = await storage.createChange(changeData);
        createdChanges.add(created);

        seqMap[originalSeq?.toString() ?? created['seq'].toString()] =
            created['seq'];
      }

      return _successResponse({
        'success': true,
        'created': createdChanges.length,
        'seqMap': seqMap,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else {
      return _errorResponse('Not found', 404);
    }
  } catch (e) {
    return _errorResponse('Error processing POST request: $e', 500);
  }
}

/// Create a successful API Gateway response
Map<String, dynamic> _successResponse(Map<String, dynamic> data) {
  return {
    'statusCode': 200,
    'headers': {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
    'body': jsonEncode(data),
  };
}

/// Create an error API Gateway response
Map<String, dynamic> _errorResponse(String message, int statusCode) {
  return {
    'statusCode': statusCode,
    'headers': {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
    'body': jsonEncode({
      'error': message,
      'timestamp': DateTime.now().toIso8601String(),
    }),
  };
}
