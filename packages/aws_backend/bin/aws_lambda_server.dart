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
    final region = Platform.environment['AWS_REGION'] ?? 'us-east-1';

    // Create DynamoDB storage service (no projectId needed)
    final storage = DynamoDBStorageService(
      tableName: tableName,
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

  try {
    if (path.contains('/health')) {
      // Health check: /health
      return _successResponse({
        'status': 'healthy',
        'timestamp': DateTime.now().toIso8601String(),
        'service': 'AWS Lambda SLTT API',
        'multiProject': true,
      });
    } else if (path == '/api/projects') {
      // Get all projects: GET /api/projects
      final projects = await storage.getAllProjects();
      return _successResponse({
        'projects': projects,
        'count': projects.length,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else if (path.startsWith('/api/projects/') && path.endsWith('/changes')) {
      // Get changes for a specific project: GET /api/projects/{projectId}/changes
      final pathSegments = path.split('/');
      if (pathSegments.length >= 4) {
        final projectId = pathSegments[3];
        final queryParams =
            event['queryStringParameters'] as Map<String, dynamic>? ?? {};

        final cursor =
            int.tryParse(queryParams['cursor']?.toString() ?? '0') ?? 0;
        final limit =
            int.tryParse(queryParams['limit']?.toString() ?? '100') ?? 100;

        final changes = await storage.getChangesWithCursor(
          projectId: projectId,
          cursor: cursor > 0 ? cursor : null,
          limit: limit,
        );

        return _successResponse({
          'changes': changes,
          'projectId': projectId,
          'cursor': cursor,
          'count': changes.length,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        return _errorResponse('Invalid project changes path', 400);
      }
    } else if (path == '/api/changes') {
      // Legacy endpoint for backward compatibility
      final queryParams =
          event['queryStringParameters'] as Map<String, dynamic>? ?? {};
      final cursor =
          int.tryParse(queryParams['cursor']?.toString() ?? '0') ?? 0;

      // Get all projects and combine their changes
      final projects = await storage.getAllProjects();
      final allChanges = <Map<String, dynamic>>[];

      for (final projectId in projects) {
        final projectChanges = await storage.getChangesWithCursor(
          projectId: projectId,
          cursor: cursor > 0 ? cursor : null,
        );
        allChanges.addAll(projectChanges);
      }

      // Sort by sequence number
      allChanges.sort((a, b) => (a['seq'] as int).compareTo(b['seq'] as int));

      return _successResponse({
        'changes': allChanges,
        'cursor': cursor,
        'count': allChanges.length,
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
    if (path == '/api/changes') {
      // Create changes: POST /api/changes (multi-project)
      final data = jsonDecode(body);

      if (data is! List) {
        return _errorResponse('Request body must be an array', 400);
      }

      final changes = data.cast<Map<String, dynamic>>();
      final createdChanges = <Map<String, dynamic>>[];
      final seqMap = <String, int>{};

      for (final changeData in changes) {
        // Validate that each change has a projectId in the data
        if (changeData['projectId'] == null) {
          return _errorResponse('Each change must have a projectId field', 400);
        }

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
    } else if (path.startsWith('/api/projects/') && path.endsWith('/changes')) {
      // Create changes for a specific project: POST /api/projects/{projectId}/changes
      final pathSegments = path.split('/');
      if (pathSegments.length >= 4) {
        final projectId = pathSegments[3];
        final data = jsonDecode(body);

        if (data is! List) {
          return _errorResponse('Request body must be an array', 400);
        }

        final changes = data.cast<Map<String, dynamic>>();
        final createdChanges = <Map<String, dynamic>>[];
        final seqMap = <String, int>{};

        for (final changeData in changes) {
          // Ensure the projectId matches the URL parameter
          changeData['projectId'] = projectId;

          final originalSeq = changeData['seq'];
          final created = await storage.createChange(changeData);
          createdChanges.add(created);

          seqMap[originalSeq?.toString() ?? created['seq'].toString()] =
              created['seq'];
        }

        return _successResponse({
          'success': true,
          'projectId': projectId,
          'created': createdChanges.length,
          'seqMap': seqMap,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        return _errorResponse('Invalid project changes path', 400);
      }
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
