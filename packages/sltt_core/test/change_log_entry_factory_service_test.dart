import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  group('ChangeLogEntryFactoryService.forChangeSave', () {
    test('creates TestChangeLogEntry with save mode defaults', () {
      final oneMsAgo = DateTime.now().subtract(const Duration(milliseconds: 1));

      final entry =
          ChangeLogEntryFactoryService.forChangeSave<TestChangeLogEntry, int>(
            factory: TestChangeLogEntry.new,
            domainType: 'project',
            domainId: 'proj-123',
            entityType: 'task',
            entityId: 'task-1',
            changeBy: 'user-1',
            data: {
              'nameLocal': 'My Task',
              'parentId': 'root',
              'parentProp': 'pList',
            },
          );

      // Verify all save mode defaults are set correctly
      expect(entry.domainType, equals('project'));
      expect(entry.domainId, equals('proj-123'));
      expect(entry.entityType, equals('task'));
      expect(entry.entityId, equals('task-1'));
      expect(entry.changeBy, equals('user-1'));
      expect(entry.changeAt.isAfter(oneMsAgo), isTrue);

      // Save mode defaults
      expect(entry.storageId, equals(''));
      expect(entry.operation, equals(kChangeOperationNotYetDefined));
      expect(entry.operationInfoJson, equals('{}'));
      expect(entry.stateChanged, equals(false));
      expect(entry.unknownJson, equals('{}'));
      expect(entry.seq, equals(0));
      expect(entry.storedAt, isNull);
      expect(entry.cloudAt, isNull);

      // Verify CID was generated
      expect(entry.cid, isNotEmpty);
      expect(entry.cid.length, greaterThan(10));

      // Verify data was encoded as JSON
      expect(entry.dataJson, isNotEmpty);
      final data = entry.getData();
      expect(data['nameLocal'], equals('My Task'));
      expect(data['parentId'], equals('root'));
      expect(data['parentProp'], equals('pList'));
    });

    test('allows overriding default values', () {
      final customCid = 'custom-cid-123';
      final String operation = 'create';
      final changeAt = DateTime.parse('2023-06-15T10:30:00Z');

      final entry =
          ChangeLogEntryFactoryService.forChangeSave<TestChangeLogEntry, int>(
            factory: TestChangeLogEntry.new,
            cid: customCid,
            domainType: 'project',
            domainId: 'proj-456',
            entityType: 'project',
            entityId: 'proj-sub-1',
            changeBy: 'user-2',
            changeAt: changeAt,
            data: {'nameLocal': 'Sub Project'},
            operation: operation,
            dataSchemaRev: 5,
          );

      // Verify overridden values
      expect(entry.cid, equals(customCid));
      expect(entry.operation, equals(operation));
      expect(entry.dataSchemaRev, equals(5));
    });

    test('normalizes changeAt to UTC', () {
      final localTime = DateTime.parse('2023-06-15T10:30:00'); // No timezone

      final entry =
          ChangeLogEntryFactoryService.forChangeSave<TestChangeLogEntry, int>(
            factory: TestChangeLogEntry.new,
            domainType: 'project',
            domainId: 'proj-789',
            entityType: 'task',
            entityId: 'task-2',
            changeBy: 'user-3',
            changeAt: localTime,
            data: {'nameLocal': 'Test'},
          );

      // Verify time was normalized to UTC
      expect(entry.changeAt.isUtc, isTrue);
    });

    test('generates unique CIDs for different entity types', () {
      final now = DateTime.now();

      final taskEntry =
          ChangeLogEntryFactoryService.forChangeSave<TestChangeLogEntry, int>(
            factory: TestChangeLogEntry.new,
            domainType: 'project',
            domainId: 'proj-1',
            entityType: 'task',
            entityId: 'task-1',
            changeBy: 'user-1',
            changeAt: now,
            data: {'nameLocal': 'Task'},
          );

      final projectEntry =
          ChangeLogEntryFactoryService.forChangeSave<TestChangeLogEntry, int>(
            factory: TestChangeLogEntry.new,
            domainType: 'project',
            domainId: 'proj-2',
            entityType: 'project',
            entityId: 'proj-2',
            changeBy: 'user-1',
            changeAt: now,
            data: {'nameLocal': 'Project'},
          );

      // CIDs should be different
      expect(taskEntry.cid, isNot(equals(projectEntry.cid)));

      // CIDs should be properly formatted
      expect(taskEntry.cid, isNotEmpty);
      expect(projectEntry.cid, isNotEmpty);
    });

    test('handles empty data map', () {
      final entry =
          ChangeLogEntryFactoryService.forChangeSave<TestChangeLogEntry, int>(
            factory: TestChangeLogEntry.new,
            domainType: 'project',
            domainId: 'proj-empty',
            entityType: 'task',
            entityId: 'task-empty',
            changeBy: 'user-1',
            changeAt: DateTime.now(),
            data: {},
          );

      expect(entry.dataJson, equals('{}'));
      expect(entry.getData(), isEmpty);
    });

    test('properly encodes complex data structures', () {
      final entry =
          ChangeLogEntryFactoryService.forChangeSave<TestChangeLogEntry, int>(
            factory: TestChangeLogEntry.new,
            domainType: 'project',
            domainId: 'proj-complex',
            entityType: 'task',
            entityId: 'task-complex',
            changeBy: 'user-1',
            changeAt: DateTime.now(),
            data: {
              'nameLocal': 'Complex Task',
              'metadata': {
                'tags': ['urgent', 'review'],
                'priority': 5,
              },
              'deleted': false,
            },
          );

      final data = entry.getData();
      expect(data['nameLocal'], equals('Complex Task'));
      expect(data['metadata'], isA<Map>());
      expect(data['metadata']['tags'], equals(['urgent', 'review']));
      expect(data['metadata']['priority'], equals(5));
      expect(data['deleted'], equals(false));
    });
  });
}
