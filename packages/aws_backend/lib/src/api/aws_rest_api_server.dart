import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:sltt_core/sltt_core.dart';

import '../storage/dynamodb_storage_service.dart';

/// AWS DynamoDB-backed REST API server.
///
/// This server extends the base functionality with DynamoDB storage
/// and provides the same API endpoints as local servers.
class AwsRestApiServer extends BaseRestApiServer {
  AwsRestApiServer({
    required super.serverName,
    required DynamoDBStorageService storage,
  }) : super(
          storage: storage,
        );

  @override
  String get storageTypeDescription => 'AWS DynamoDB';

  /// Handle AWS API Gateway event (for Lambda deployment)
  Future<Map<String, dynamic>> handleApiGatewayEvent(Map<String, dynamic> event) async {
    try {
      // Convert API Gateway event to Shelf request
      final request = _convertApiGatewayEventToRequest(event);

      // Get the router from the base class
      final router = buildRouter();

      // Process with router
      final response = await router(request);

      // Convert Shelf response to API Gateway response
      return _convertResponseToApiGateway(response);
    } catch (e) {
      return {
        'statusCode': 500,
        'body': jsonEncode({'error': 'Internal server error: $e'}),
        'headers': {'Content-Type': 'application/json'},
      };
    }
  }

  /// Convert API Gateway event to Shelf Request
  Request _convertApiGatewayEventToRequest(Map<String, dynamic> event) {
    final method = event['httpMethod'] as String? ?? 'GET';
    final path = event['path'] as String? ?? '/';
    final queryParams = event['queryStringParameters'] as Map<String, dynamic>? ?? {};
    final headers = event['headers'] as Map<String, dynamic>? ?? {};
    final body = event['body'] as String? ?? '';

    final uri = Uri(
      path: path,
      queryParameters: queryParams.cast<String, String>(),
    );

    return Request(
      method,
      uri,
      headers: headers.cast<String, String>(),
      body: body,
    );
  }

  /// Convert Shelf Response to API Gateway response
  Future<Map<String, dynamic>> _convertResponseToApiGateway(Response response) async {
    final body = await response.readAsString();

    return {
      'statusCode': response.statusCode,
      'headers': {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        ...response.headers,
      },
      'body': body,
    };
  }
}
