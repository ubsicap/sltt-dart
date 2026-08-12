import 'dart:convert';

import 'package:aws_backend/aws_backend.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart' show getRegisteredEntityStateTypes;
import 'package:test/test.dart';

import 'helpers/fake_storage.dart';

// Fake storage implementation is provided in helpers/fake_storage.dart

void main() {
  group('offline - AwsRestApiServer basic routes', () {
    late AwsRestApiServer server;
    late Router router;

    setUp(() {
      final storage = FakeDynamoDBStorageService();
      server = AwsRestApiServer(serverName: 'TestServer', storage: storage);
      router = server.getRouter();
    });

    test('health route returns healthy status', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'GET',
        'path': '/health',
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(200));
      final body =
          jsonDecode(response['body'] as String) as Map<String, dynamic>;
      expect(body['status'], equals('healthy'));
      expect(body['server'], equals('TestServer'));
      expect(body['storageType'], contains('DynamoDB'));
    });

    test('api/help route provides documentation payload', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'GET',
        'path': '/api/help',
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(200));
      final body =
          jsonDecode(response['body'] as String) as Map<String, dynamic>;

      expect(body['server'], isA<Map<String, dynamic>>());
      expect(body['server']['name'], equals('TestServer'));
      expect(body['endpoints'], isA<List<dynamic>>());
      expect(body['endpoints'], isNotEmpty);
    });

    test('api/help html format returns text/html body', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'GET',
        'path': '/api/help',
        'queryStringParameters': {'format': 'html'},
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(200));
      expect(
        (response['headers'] as Map<String, dynamic>)['Content-Type'],
        contains('text/html'),
      );
      final body = response['body'] as String;
      expect(body, contains('<html'));
      expect(body, contains('AWS-specific API extensions'));
      expect(body, contains('/api/auth/register'));
    });

    test('api/help includes new project admin endpoints', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'GET',
        'path': '/api/help',
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(200));
      final body =
          jsonDecode(response['body'] as String) as Map<String, dynamic>;
      final endpoints = (body['endpoints'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      expect(
        endpoints.any(
          (endpoint) =>
              endpoint['method'] == 'PUT' &&
              endpoint['path'] == '/api/admin/project/{projectId}',
        ),
        isTrue,
      );
      expect(
        endpoints.any(
          (endpoint) =>
              endpoint['method'] == 'PUT' &&
              endpoint['path'] == '/api/super/admin/project/{projectId}',
        ),
        isTrue,
      );
      expect(
        endpoints.any(
          (endpoint) =>
              endpoint['method'] == 'DELETE' &&
              endpoint['path'] == '/api/super/admin/project/{projectId}',
        ),
        isTrue,
      );
    });

    test('GET /api/domains returns domains and collections', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'GET',
        'path': '/api/domains',
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(200));
      final body =
          jsonDecode(response['body'] as String) as Map<String, dynamic>;
      expect(body['domains'], isA<List<dynamic>>());
      expect(body['collections'], isA<List<dynamic>>());
      expect((body['domains'] as List).contains('project'), isTrue);
    });

    test('GET /api/entities/project returns project entity types', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'GET',
        'path': '/api/entities/project',
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(200));
      final body =
          jsonDecode(response['body'] as String) as Map<String, dynamic>;
      expect(body['domainType'], equals('project'));
      expect(
        body['entityTypes'],
        getRegisteredEntityStateTypes().map((esType) => esType.value),
      );
      expect((body['entityTypes'] as List).isNotEmpty, isTrue);
    });

    test('OPTIONS preflight returns CORS headers', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'OPTIONS',
        'path': '/api/domains',
        'headers': <String, String>{'Origin': 'http://example.com'},
      }, router);

      expect(response['statusCode'], equals(200));
      final headers = response['headers'] as Map<String, dynamic>?;
      expect(headers, isNotNull);
      // CORS headers present
      expect(headers!['Access-Control-Allow-Origin'], equals('*'));
      expect(headers['Access-Control-Allow-Methods'], contains('GET'));
    });

    test('Unknown route returns 404 with helpful body', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'GET',
        'path': '/this-route-does-not-exist',
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(404));
      final body =
          jsonDecode(response['body'] as String) as Map<String, dynamic>;
      expect(body['error'], contains('Endpoint not found'));
      expect(body['path'], equals('this-route-does-not-exist'));
    });
  });
}
