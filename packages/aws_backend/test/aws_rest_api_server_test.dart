import 'dart:convert';

import 'package:aws_backend/aws_backend.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

import 'helpers/fake_storage.dart';

// Fake storage implementation is provided in helpers/fake_storage.dart

void main() {
  group('AwsRestApiServer basic routes', () {
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

    test('GET /api/domains/project/entities returns entity types', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'GET',
        'path': '/api/domains/project/entities',
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(200));
      final body =
          jsonDecode(response['body'] as String) as Map<String, dynamic>;
      expect(body['domainType'], equals('project'));
      expect(body['entityTypes'], isA<List<dynamic>>());
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
