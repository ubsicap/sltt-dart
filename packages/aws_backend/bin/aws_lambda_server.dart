import 'dart:convert';

import 'package:aws_backend/aws_backend.dart';
import 'package:sltt_core/sltt_core.dart' show SlttLogger;

/// AWS Lambda handler for SLTT backend API.
///
/// This handler uses the proper AwsRestApiServer class to ensure
/// consistent routing and endpoint behavior with local development.
/// It can also be used by the local debugger when LOCAL_DEBUGGER=true.
Future<Map<String, dynamic>> handler(Map<String, dynamic> event) async {
  try {
    // Create DynamoDB storage service using shared factory
    final storage = StorageFactory.createStorage();

    // Initialize storage
    await storage.initialize();

    // Create AwsRestApiServer instance
    final server = AwsRestApiServer(
      serverName: 'AWS Lambda API',
      storage: storage,
    );

    // Get router and process the API Gateway event
    final router = server.getRouter();
    final response = await server.handleApiGatewayEvent(event, router);

    // Clean up
    await storage.close();

    return response;
  } catch (e, stackTrace) {
    SlttLogger.logger.severe('Handler error: $e', e, stackTrace);
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
