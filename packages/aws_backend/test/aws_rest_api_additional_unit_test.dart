import 'dart:convert';

import 'package:aws_backend/aws_backend.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

import 'helpers/fake_storage.dart';

void main() {
  group('AwsRestApiServer additional unit routes', () {
    late AwsRestApiServer server;
    late Router router;

    setUp(() {
      final storage = FakeDynamoDBStorageService();
      server = AwsRestApiServer(serverName: 'TestServer', storage: storage);
      router = server.getRouter();
    });

    test('GET /api/projects returns domain ids', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'GET',
        'path': '/api/projects',
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(200));
      final body =
          jsonDecode(response['body'] as String) as Map<String, dynamic>;
      expect(body['items'], isA<List>());
      expect(body['count'], isA<int>());
      expect(body['timestamp'], isA<String>());
    });

    test('GET /api/stats/projects/__test1 returns stats', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'GET',
        'path': '/api/stats/projects/__test1',
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(200));
      final body =
          jsonDecode(response['body'] as String) as Map<String, dynamic>;
      expect(body['projectId'], equals('__test1'));
      expect(body['changeStats'], isA<Map<String, dynamic>>());
      expect(body['entityTypeStats'], isA<Map<String, dynamic>>());
    });

    test(
      'GET /api/state/projects/__test1/document returns state structure',
      () async {
        final response = await server.handleApiGatewayEvent({
          'httpMethod': 'GET',
          'path': '/api/state/projects/__test1/documents',
          'headers': <String, String>{},
        }, router);

        expect(response['statusCode'], equals(200));
        final body =
            jsonDecode(response['body'] as String) as Map<String, dynamic>;
        expect(body['projectId'], equals('__test1'));
        expect(body['entityType'], equals('document'));
        expect(body['items'], isA<List>());
      },
    );

    test('DELETE storage reset for __test1 returns message', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'DELETE',
        'path': '/api/storage/__test/reset/projects/__test1',
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(200));
      final body =
          jsonDecode(response['body'] as String) as Map<String, dynamic>;
      expect(body['message'], contains('__test1'));
    });
  });
}
