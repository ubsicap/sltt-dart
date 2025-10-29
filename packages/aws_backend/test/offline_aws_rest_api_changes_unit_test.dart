import 'dart:convert';

import 'package:aws_backend/aws_backend.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

import 'helpers/fake_storage.dart';

void main() {
  group('offline - AwsRestApiServer POST /api/changes validation', () {
    late AwsRestApiServer server;
    late Router router;

    setUp(() {
      final storage = FakeDynamoDBStorageService();
      server = AwsRestApiServer(serverName: 'TestServer', storage: storage);
      router = server.getRouter();
    });

    Future<Map<String, dynamic>> post(String body) async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'POST',
        'path': '/api/changes',
        'headers': <String, String>{'Content-Type': 'application/json'},
        'body': body,
      }, router);
      return response;
    }

    test('invalid JSON returns 400', () async {
      final resp = await post('not a json');
      expect(resp['statusCode'], equals(400));
      final body = jsonDecode(resp['body'] as String) as Map<String, dynamic>;
      expect(body['error'], contains('Invalid JSON'));
    });

    test('body not an object returns 400', () async {
      final resp = await post(jsonEncode(['a', 'b']));
      expect(resp['statusCode'], equals(400));
      final body = jsonDecode(resp['body'] as String) as Map<String, dynamic>;
      expect(body['error'], contains('Request body must be an object'));
    });

    test('empty changes array returns 400', () async {
      final payload = jsonEncode({
        'changes': [],
        'srcStorageType': 'local',
        'srcStorageId': 'test',
        'storageMode': 'save',
      });
      final resp = await post(payload);
      expect(resp['statusCode'], equals(400));
      final body = jsonDecode(resp['body'] as String) as Map<String, dynamic>;
      expect(body['error'], contains('No changes provided'));
    });

    test('invalid srcStorageType returns 400', () async {
      final payload = jsonEncode({
        'changes': [
          {'domainId': '__test1', 'entityType': 'document', 'entityId': 'd1'},
        ],
        'srcStorageType': 'invalid',
        'srcStorageId': 'test',
        'storageMode': 'save',
      });
      final resp = await post(payload);
      expect(resp['statusCode'], equals(400));
      final body = jsonDecode(resp['body'] as String) as Map<String, dynamic>;
      expect(body['error'], contains('srcStorageType must be'));
    });

    test('missing srcStorageId returns 400', () async {
      final payload = jsonEncode({
        'changes': [
          {'domainId': '__test1', 'entityType': 'document', 'entityId': 'd1'},
        ],
        'srcStorageType': 'local',
        'srcStorageId': '',
        'storageMode': 'save',
      });
      final resp = await post(payload);
      expect(resp['statusCode'], equals(400));
      final body = jsonDecode(resp['body'] as String) as Map<String, dynamic>;
      expect(body['error'], contains('srcStorageId is required'));
    });

    test('invalid storageMode returns 400', () async {
      final payload = jsonEncode({
        'changes': [
          {'domainId': '__test1', 'entityType': 'document', 'entityId': 'd1'},
        ],
        'srcStorageType': 'local',
        'srcStorageId': 'test',
        'storageMode': 'badmode',
      });
      final resp = await post(payload);
      expect(resp['statusCode'], equals(400));
      final body = jsonDecode(resp['body'] as String) as Map<String, dynamic>;
      expect(body['error'], contains('storageMode must be'));
    });
  });

  group('offline - AwsRestApiServer POST /api/changes semantics', () {
    late AwsRestApiServer server;
    late Router router;

    setUp(() {
      final storage = FakeDynamoDBStorageService();
      server = AwsRestApiServer(serverName: 'TestServer', storage: storage);
      router = server.getRouter();
    });

    Future<Map<String, dynamic>> post(String body) async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'POST',
        'path': '/api/changes',
        'headers': <String, String>{'Content-Type': 'application/json'},
        'body': body,
      }, router);
      return response;
    }

    test(
      'includeChangeUpdates/includeStateUpdates returns summaries',
      () async {
        final payload = jsonEncode({
          'changes': [
            {
              'domainType': 'project',
              'domainId': '__test1',
              'entityType': 'document',
              'entityId': 'doc1',
              'operation': 'create',
              'seq': 1,
              'cid': 'test-cid-1',
              'stateChanged': false,
              'changeBy': 'tester',
              'changeAt': DateTime.now().toUtc().toIso8601String(),
              'storageId': 'test-storage',
              'dataJson': jsonEncode({'foo': 'bar'}),
            },
          ],
          'srcStorageType': 'local',
          'srcStorageId': 'test',
          'storageMode': 'save',
          'includeChangeUpdates': true,
          'includeStateUpdates': true,
        });

        final resp = await post(payload);
        expect(resp['statusCode'], anyOf([200, 201]));
        final body = jsonDecode(resp['body'] as String) as Map<String, dynamic>;
        expect(body['created'], isA<List>());
        expect(body['changeUpdates'], isA<List>());
        expect(body['stateUpdates'], isA<List>());
      },
    );

    test('sync mode with missing seq returns error', () async {
      // In sync mode, entries must include seq and storageId
      final change = {
        'cid': 'test-cid-1-HUon',
        'domainType': 'project',
        'domainId': '__test1',
        'entityType': 'document',
        'entityId': 'doc1',
        'operation': 'create',
        'storageId': 'test-storage',
        'stateChanged': true, // TODO: allow false for storing errors etc...
        'changeBy': 'tester',
        'changeAt': DateTime.now().toUtc().toIso8601String(),
        // missing seq in sync mode
        'dataJson': jsonEncode({'foo': 'bar'}),
      };
      final payloadJson = {
        'changes': [change],
        'srcStorageType': 'local',
        'srcStorageId': 'test',
        'storageMode': 'sync',
      };
      final payload = jsonEncode(payloadJson);

      final resp = await post(payload);
      final body = jsonDecode(resp['body'] as String) as Map<String, dynamic>;
      expect(
        resp['statusCode'],
        anyOf([400] /* [200, 201] */),
        reason:
            /* was 'Status code should be 200 or 201 even with errors in body, but got:\n$resp', */
            'Status code should be 400 even with errors in body, but got:\n$resp',
      );

      // final oldExpectedError =
      //     'CheckedFromJsonException\n'
      //     'Could not create `DynamoChangeLogEntry`.\n'
      //     'There is a problem with "seq".\n'
      //     'type \'Null\' is not a subtype of type \'num\' in type cast';

      expect(
        body['error'],
        equals('Changes [0] in sync mode must include a valid positive seq'),

        /* was:
        body['errors'],
        [
          {
            'cid': 'test-cid-1-HUon',
            'info': {
              'error': oldExpectedError,
              'errorStack': isA<String>(),
              'json': change,
            },
          },
        ],*/
        reason: 'Should return error for default negative seq, but got:\n$body',
      );
    });
  });
}
