import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'test_data_fields.dart';
import 'test_models.dart';

void main() {
  group('ChangeLogEntryFactoryService.forChangeSave', () {
    test('creates TestChangeLogEntry with save mode defaults', () {
      final oneMsAgo = DateTime.now().subtract(const Duration(milliseconds: 1));

      final entry =
          ChangeLogEntryFactoryService.forChangeSave<
            TestChangeLogEntry,
            int,
            TestDataFields
          >(
            factory: TestChangeLogEntry.new,
            domainType: 'project',
            domainId: 'proj-123',
            entityType: 'task',
            entityId: 'task-1',
            changeBy: 'user-1',
            data: TestDataFields(
              nameLocal: 'My Task',
              parentId: 'root',
              parentProp: 'pList',
            ),
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
          ChangeLogEntryFactoryService.forChangeSave<
            TestChangeLogEntry,
            int,
            TestDataFields
          >(
            factory: TestChangeLogEntry.new,
            cid: customCid,
            domainType: 'project',
            domainId: 'proj-456',
            entityType: 'project',
            entityId: 'proj-sub-1',
            changeBy: 'user-2',
            changeAt: changeAt,
            data: TestDataFields(
              nameLocal: 'Sub Project',
              parentId: 'root',
              parentProp: 'pList',
            ),
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
          ChangeLogEntryFactoryService.forChangeSave<
            TestChangeLogEntry,
            int,
            TestDataFields
          >(
            factory: TestChangeLogEntry.new,
            domainType: 'project',
            domainId: 'proj-789',
            entityType: 'task',
            entityId: 'task-2',
            changeBy: 'user-3',
            changeAt: localTime,
            data: TestDataFields(
              nameLocal: 'Test',
              parentId: 'root',
              parentProp: 'pList',
            ),
          );

      // Verify time was normalized to UTC
      expect(entry.changeAt.isUtc, isTrue);
    });

    test('generates unique CIDs for different entity types', () {
      final now = DateTime.now();

      final taskEntry =
          ChangeLogEntryFactoryService.forChangeSave<
            TestChangeLogEntry,
            int,
            TestDataFields
          >(
            factory: TestChangeLogEntry.new,
            domainType: 'project',
            domainId: 'proj-1',
            entityType: 'task',
            entityId: 'task-1',
            changeBy: 'user-1',
            changeAt: now,
            data: TestDataFields(
              nameLocal: 'Task',
              parentId: 'parent1',
              parentProp: 'pList',
            ),
          );

      final projectEntry =
          ChangeLogEntryFactoryService.forChangeSave<
            TestChangeLogEntry,
            int,
            TestDataFields
          >(
            factory: TestChangeLogEntry.new,
            domainType: 'project',
            domainId: 'proj-2',
            entityType: 'project',
            entityId: 'proj-2',
            changeBy: 'user-1',
            changeAt: now,
            data: TestDataFields(
              nameLocal: 'Project',
              parentId: 'parent2',
              parentProp: 'pList',
            ),
          );

      // CIDs should be different
      expect(taskEntry.cid, isNot(equals(projectEntry.cid)));

      // CIDs should be properly formatted
      expect(taskEntry.cid, isNotEmpty);
      expect(projectEntry.cid, isNotEmpty);
    });

    test('handles empty data map', () {
      final entry =
          ChangeLogEntryFactoryService.forChangeSave<
            TestChangeLogEntry,
            int,
            BaseDataFields
          >(
            factory: TestChangeLogEntry.new,
            domainType: 'project',
            domainId: 'proj-empty',
            entityType: 'task',
            entityId: 'task-empty',
            changeBy: 'user-1',
            changeAt: DateTime.now(),
            data: BaseDataFields(parentId: 'parent1', parentProp: 'pList'),
          );

      expect(entry.dataJson, contains('parentId'));
      expect(entry.dataJson, contains('parentProp'));
      final data = entry.getData();
      expect(data['parentId'], equals('parent1'));
      expect(data['parentProp'], equals('pList'));
    });

    test('properly encodes complex data structures', () {
      final entry =
          ChangeLogEntryFactoryService.forChangeSave<
            TestChangeLogEntry,
            int,
            TestDataFields
          >(
            factory: TestChangeLogEntry.new,
            domainType: 'project',
            domainId: 'proj-complex',
            entityType: 'task',
            entityId: 'task-complex',
            changeBy: 'user-1',
            changeAt: DateTime.now(),
            data: TestDataFields(
              nameLocal: 'Complex Task',
              parentId: 'parent1',
              parentProp: 'pList',
              deleted: false,
            ),
          );

      final data = entry.getData();
      expect(data['nameLocal'], equals('Complex Task'));
      expect(data['parentId'], equals('parent1'));
      expect(data['parentProp'], equals('pList'));
      expect(data['deleted'], equals(false));
    });
  });
}
