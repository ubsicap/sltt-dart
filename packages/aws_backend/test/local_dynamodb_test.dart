import 'package:aws_backend/aws_backend.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  group('AWS Backend Tests - LocalDynamoDB', () {
    test('DynamoDB storage service can be instantiated', () {
      final storage = DynamoDBStorageService(
        tableName: 'test-table',
        useLocalDynamoDB: true,
      );

      expect(storage, isNotNull);
      expect(storage.tableName, equals('test-table'));
    });

    test('AWS REST API server can be instantiated', () {
      final storage = DynamoDBStorageService(
        tableName: 'test-table',
        useLocalDynamoDB: true,
      );

      final server = AwsRestApiServer(
        serverName: 'Test AWS Server',
        storage: storage,
      );

      expect(server, isNotNull);
      expect(server.serverName, equals('Test AWS Server'));
    });

    test('multi-project support structure validation', () {
      final testChanges = [
        {
          'projectId': 'project-gamma',
          'entityType': 'project',
          'operation': 'create',
          'entityId': 'project-gamma',
          'cid': BaseChangeLogEntry.generateCid(),
          'data': {'name': 'Gamma Project', 'description': 'AWS test project'},
        },
        {
          'projectId': 'project-delta',
          'entityType': 'document',
          'operation': 'create',
          'entityId': 'doc-456',
          'cid': BaseChangeLogEntry.generateCid(),
          'data': {'title': 'Delta Document', 'content': 'Test content'},
        },
      ];

      // This tests the structure, not the actual DynamoDB operations
      for (final change in testChanges) {
        expect(change['projectId'], isA<String>());
        expect(change['entityType'], isA<String>());
        expect(change['operation'], isA<String>());
        expect(change['entityId'], isA<String>());
        expect(change['data'], isA<Map>());
      }
    });
  });
}
