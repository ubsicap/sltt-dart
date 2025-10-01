import 'dart:convert';

import 'package:aws_backend/aws_backend.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

class _FakeDynamoDBStorageService extends DynamoDBStorageService {
  _FakeDynamoDBStorageService()
    : super(
        tableName: 'test-table',
        region: 'us-east-1',
        useLocalDynamoDB: true,
      );

  @override
  Future<void> initialize() async {}

  @override
  Future<String> ensureStorageId() async => 'test-storage';

  @override
  Future<String> getStorageId() async => 'test-storage';

  @override
  Future<void> close() async {}
}

void main() {
  group('AwsRestApiServer basic routes', () {
    late AwsRestApiServer server;
    late Router router;

    setUp(() {
      final storage = _FakeDynamoDBStorageService();
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
  });
}
