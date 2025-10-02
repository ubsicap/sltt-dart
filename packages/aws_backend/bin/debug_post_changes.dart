import 'dart:convert';

import 'package:aws_backend/aws_backend.dart';

import '../test/helpers/fake_storage.dart';

Future<void> main() async {
  final storage = FakeDynamoDBStorageService();
  final server = AwsRestApiServer(serverName: 'DebugServer', storage: storage);
  final router = server.getRouter();

  final payload1 = jsonEncode({
    'changes': [
      {
        'domainType': 'project',
        'domainId': '__test1',
        'entityType': 'document',
        'entityId': 'doc1',
        'operation': 'create',
        'stateChanged': false,
        'seq': 1,
        'cid': 'test-cid-1',
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

  final resp1 = await server.handleApiGatewayEvent({
    'httpMethod': 'POST',
    'path': '/api/changes',
    'headers': <String, String>{'Content-Type': 'application/json'},
    'body': payload1,
  }, router);

  print('=== SAVE mode response ===');
  print('statusCode: ${resp1['statusCode']}');
  print('body:');
  print(resp1['body']);

  final payload2 = jsonEncode({
    'changes': [
      {
        'domainId': '__test1',
        'entityType': 'document',
        'entityId': 'doc1',
        'operation': 'create',
      },
    ],
    'srcStorageType': 'local',
    'srcStorageId': 'test',
    'storageMode': 'sync',
  });

  final resp2 = await server.handleApiGatewayEvent({
    'httpMethod': 'POST',
    'path': '/api/changes',
    'headers': <String, String>{'Content-Type': 'application/json'},
    'body': payload2,
  }, router);

  print('=== SYNC mode response ===');
  print('statusCode: ${resp2['statusCode']}');
  print('body:');
  print(resp2['body']);
}
