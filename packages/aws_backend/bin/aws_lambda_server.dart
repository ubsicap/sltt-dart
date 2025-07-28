import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/aws_backend.dart';

/// AWS Lambda handler for SLTT backend API.
///
/// This handler uses the proper AwsRestApiServer class to ensure
/// consistent routing and endpoint behavior with local development.
Future<Map<String, dynamic>> handler(Map<String, dynamic> event) async {
  try {
    // Get configuration from environment variables
    final tableName =
        Platform.environment['DYNAMODB_TABLE'] ?? 'sltt-changes-dev';
    final region = Platform.environment['AWS_REGION'] ?? 'us-east-1';

    // Create DynamoDB storage service
    final storage = DynamoDBStorageService(
      tableName: tableName,
      region: region,
      useLocalDynamoDB: false, // Always use real AWS in Lambda
    );

    // Initialize storage
    await storage.initialize();

    // Create AwsRestApiServer instance (but don't start HTTP server)
    final server = AwsRestApiServer(
      serverName: 'AWS Lambda API',
      storage: storage,
    );

    // Use the server's handleApiGatewayEvent method for proper routing
    final response = await server.handleApiGatewayEvent(event);

    // Clean up
    await storage.close();

    return response;
  } catch (e, stackTrace) {
    print('Lambda error: $e');
    print('Stack trace: $stackTrace');
    return {
      'statusCode': 500,
      'headers': {'Content-Type': 'application/json'},
      'body': jsonEncode({
        'error': 'Internal server error: $e',
        'timestamp': DateTime.now().toIso8601String(),
      }),
    };
  }
}
