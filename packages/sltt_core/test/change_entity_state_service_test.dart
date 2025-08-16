import 'package:sltt_core/src/models/entity_type.dart';
import 'package:sltt_core/src/services/change_entity_state_service.dart';
import 'package:test/test.dart';

import 'test_concrete_models.dart';

void main() {
  group('ChangeEntityStateService', () {
    late DateTime baseTime;
    late ConcreteEntityState entityState;

    setUp(() {
      baseTime = DateTime.parse('2023-01-01T00:00:00Z');
      entityState = ConcreteEntityState.fromJson(<String, dynamic>{
        'entityId': 'entity1',
        'entityType': 'task',
        'change_domainId': 'project1',
        'change_domainId_orig_': 'project1',
        'change_changeAt': baseTime.toIso8601String(),
        'change_changeAt_orig_': baseTime.toIso8601String(),
        'change_cid': 'cid1',
        'change_cid_orig_': 'cid1',
        'change_changeBy': 'user1',
        'change_changeBy_orig_': 'user1',
        'data_parentId': 'parent1',
        'data_parentId_dataSchemaRev': 1,
        'data_parentId_changeAt_': baseTime.toIso8601String(),
        'data_parentId_cid_': 'cid1',
        'data_parentId_changeBy_': 'user1',
        // Add some rank data for testing
        'data_rank': '1',
        'data_rank_dataSchemaRev': 1,
        'data_rank_changeAt_': baseTime.toIso8601String(),
        'data_rank_cid_': 'cid1',
        'data_rank_changeBy_': 'user1',
        'unknown': <String, dynamic>{},
      });
    });

    group('getMaybeIsDuplicateCidResult', () {
      test('should return true for duplicate CID', () {
        final changeLogEntry = ConcreteChangeLogEntry(
          entityId: 'entity1',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime,
          cid: 'cid1', // Same as entity state
          changeBy: 'user1',
          data: {'rank': '1'},
          operation: 'update',
          operationInfo: {},
          stateChanged: true,
          unknown: {},
        );

        final result = getMaybeIsDuplicateCidResult(
          changeLogEntry,
          entityState,
        );

        expect(result.isDuplicate, isTrue);
      });

      test('should return false for different CID', () {
        final changeLogEntry = ConcreteChangeLogEntry(
          entityId: 'entity1',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime,
          cid: 'cid2', // Different from entity state
          changeBy: 'user1',
          data: {'rank': '2'},
          operation: 'update',
          operationInfo: {},
          stateChanged: true,
          unknown: {},
        );

        final result = getMaybeIsDuplicateCidResult(
          changeLogEntry,
          entityState,
        );

        expect(result.isDuplicate, isFalse);
      });
    });

    group('calculateOperation', () {
      test('should calculate create operation for new entity', () {
        final changeLogEntry = ConcreteChangeLogEntry(
          entityId: 'entity2',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid2',
          changeBy: 'user1',
          data: {'rank': '1'},
          operation: 'create',
          operationInfo: {},
          stateChanged: true,
          unknown: {},
        );

        final operation = calculateOperation(changeLogEntry, null, {}, [], []);

        expect(operation, equals('create'));
      });

      test('should calculate update operation for existing entity', () {
        final changeLogEntry = ConcreteChangeLogEntry(
          entityId: 'entity1',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid2',
          changeBy: 'user1',
          data: {'rank': '2'},
          operation: 'update',
          operationInfo: {},
          stateChanged: true,
          unknown: {},
        );

        final operation = calculateOperation(
          changeLogEntry,
          entityState,
          {},
          [],
          [],
        );

        expect(operation, equals('update'));
      });

      test('should calculate delete operation', () {
        final changeLogEntry = ConcreteChangeLogEntry(
          entityId: 'entity1',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid2',
          changeBy: 'user1',
          data: {'deleted': true},
          operation: 'delete',
          operationInfo: {},
          stateChanged: true,
          unknown: {},
        );

        final operation = calculateOperation(
          changeLogEntry,
          entityState,
          {},
          [],
          [],
        );

        expect(operation, equals('delete'));
      });

      test('should calculate noOp for no changes', () {
        final changeLogEntry = ConcreteChangeLogEntry(
          entityId: 'entity1',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid2',
          changeBy: 'user1',
          data: {'rank': '1'}, // Same as current
          operation: 'update',
          operationInfo: {},
          stateChanged: false,
          unknown: {},
        );

        final operation = calculateOperation(
          changeLogEntry,
          entityState,
          {},
          [],
          [],
        );

        expect(operation, equals('noOp'));
      });

      test('should calculate outdated for older changes', () {
        final changeLogEntry = ConcreteChangeLogEntry(
          entityId: 'entity1',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.subtract(const Duration(minutes: 1)), // Older
          cid: 'cid2',
          changeBy: 'user1',
          data: {'rank': '2'},
          operation: 'update',
          operationInfo: {},
          stateChanged: true,
          unknown: {},
        );

        final operation = calculateOperation(
          changeLogEntry,
          entityState,
          {},
          [],
          [],
        );

        expect(operation, equals('outdated'));
      });
    });

    group('getAtomicLastWriteWinsToChangeLogEntryAndUpdateEntityState', () {
      test('should handle field-level conflict resolution', () {
        // Create a change log entry with newer field changes
        final newerTime = baseTime.add(const Duration(minutes: 5));
        final changeLogEntry = ConcreteChangeLogEntry(
          entityId: 'entity1',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt: newerTime,
          cid: 'cid2',
          changeBy: 'user2',
          data: {'rank': '2'},
          operation: 'update',
          operationInfo: {},
          stateChanged: true,
          unknown: {},
        );

        final result =
            getAtomicLastWriteWinsToChangeLogEntryAndUpdateEntityState(
              changeLogEntry,
              entityState,
              changeLogEntryFactory: ConcreteChangeLogEntry.fromJson,
              entityStateFactory: ConcreteEntityState.fromJson,
            );

        expect(result.newChangeLogEntry, isNotNull);
        expect(result.newEntityState, isNotNull);
        // The rank should be updated to '2' since the change is newer
        expect(result.newEntityState?.data_rank, equals('2'));
      });

      test('should reject older changes', () {
        // Create a change log entry with older field changes
        final olderTime = baseTime.subtract(const Duration(minutes: 5));
        final changeLogEntry = ConcreteChangeLogEntry(
          entityId: 'entity1',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt: olderTime,
          cid: 'cid2',
          changeBy: 'user2',
          data: {'rank': '3'},
          operation: 'update',
          operationInfo: {},
          stateChanged: true,
          unknown: {},
        );

        final result =
            getAtomicLastWriteWinsToChangeLogEntryAndUpdateEntityState(
              changeLogEntry,
              entityState,
              changeLogEntryFactory: ConcreteChangeLogEntry.fromJson,
              entityStateFactory: ConcreteEntityState.fromJson,
            );

        expect(result.newChangeLogEntry.operation, equals('outdated'));
        // The rank should remain unchanged since the change is older
        expect(result.newEntityState?.data_rank, isNull);
      });

      test('should handle new entity creation', () {
        final changeLogEntry = ConcreteChangeLogEntry(
          entityId: 'entity2',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid3',
          changeBy: 'user1',
          data: {'rank': '1', 'parentId': 'parent2'},
          operation: 'create',
          operationInfo: {},
          stateChanged: true,
          unknown: {},
        );

        final result =
            getAtomicLastWriteWinsToChangeLogEntryAndUpdateEntityState(
              changeLogEntry,
              null, // No existing entity state
              changeLogEntryFactory: ConcreteChangeLogEntry.fromJson,
              entityStateFactory: ConcreteEntityState.fromJson,
            );

        expect(result.newChangeLogEntry.operation, equals('create'));
        expect(result.newEntityState, isNotNull);
        expect(result.newEntityState?.entityId, equals('entity2'));
        expect(result.newEntityState?.data_rank, equals('1'));
        expect(result.newEntityState?.data_parentId, equals('parent2'));
      });

      test('should handle entity deletion', () {
        final changeLogEntry = ConcreteChangeLogEntry(
          entityId: 'entity1',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid4',
          changeBy: 'user1',
          data: {'deleted': true},
          operation: 'delete',
          operationInfo: {},
          stateChanged: true,
          unknown: {},
        );

        final result =
            getAtomicLastWriteWinsToChangeLogEntryAndUpdateEntityState(
              changeLogEntry,
              entityState,
              changeLogEntryFactory: ConcreteChangeLogEntry.fromJson,
              entityStateFactory: ConcreteEntityState.fromJson,
            );

        expect(result.newChangeLogEntry.operation, equals('delete'));
        expect(result.newEntityState?.data_deleted, equals(true));
      });

      test(
        'should use latest timestamp pathway when change is newer than latest',
        () {
          // Test the case where incoming change is newer than the latest timestamp
          final newerTime = baseTime.add(const Duration(minutes: 5));
          final changeLogEntry = ConcreteChangeLogEntry(
            entityId: 'entity1',
            entityType: EntityType.task,
            domainId: 'project1',
            domainType: 'project',
            changeAt: newerTime, // Newer than latest in entity state
            cid: 'new-cid',
            changeBy: 'user2',
            data: {'rank': '2'},
            operation: 'update',
            operationInfo: {},
            stateChanged: true,
            unknown: {},
          );

          final result =
              getAtomicLastWriteWinsToChangeLogEntryAndUpdateEntityState(
                changeLogEntry,
                entityState, // Uses baseTime as latest change
                changeLogEntryFactory: ConcreteChangeLogEntry.fromJson,
                entityStateFactory: ConcreteEntityState.fromJson,
              );

          expect(result.newChangeLogEntry.operation, equals('update'));
          expect(result.newEntityState?.data_rank, equals('2'));
          // Latest metadata should be updated
          expect(result.newEntityState?.change_changeAt, equals(newerTime));
          expect(result.newEntityState?.change_cid, equals('new-cid'));
        },
      );

      test('should use field-level pathway when change is older than latest', () {
        // Test the case where incoming change is older than latest, forcing field-level check
        final olderTime = baseTime.subtract(const Duration(minutes: 5));
        final newerFieldTime = baseTime.add(const Duration(minutes: 2));

        // Create entity state where latest is baseTime but rank field was updated more recently
        final entityStateWithNewerField = ConcreteEntityState.fromJson({
          'entityId': 'entity1',
          'entityType': 'task',
          'change_domainId': 'project1',
          'change_domainId_orig_': 'project1',
          'change_changeAt': baseTime
              .toIso8601String(), // Latest overall change
          'change_changeAt_orig_': baseTime.toIso8601String(),
          'change_cid': 'latest-cid',
          'change_cid_orig_': 'latest-cid',
          'change_changeBy': 'user1',
          'change_changeBy_orig_': 'user1',
          'data_parentId': 'parent1',
          'data_parentId_dataSchemaRev': 1,
          'data_parentId_changeAt_': baseTime.toIso8601String(),
          'data_parentId_cid_': 'cid1',
          'data_parentId_changeBy_': 'user1',
          'data_rank': '1',
          'data_rank_dataSchemaRev': 1,
          'data_rank_changeAt_': newerFieldTime
              .toIso8601String(), // Field is newer than incoming
          'data_rank_cid_': 'field-cid',
          'data_rank_changeBy_': 'user1',
          'unknown': <String, dynamic>{},
        });

        final changeLogEntry = ConcreteChangeLogEntry(
          entityId: 'entity1',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt:
              olderTime, // Older than latest, will be rejected at field level too
          cid: 'old-cid',
          changeBy: 'user0',
          data: {'rank': '0'},
          operation: 'update',
          operationInfo: {},
          stateChanged: true,
          unknown: {},
        );

        final result =
            getAtomicLastWriteWinsToChangeLogEntryAndUpdateEntityState(
              changeLogEntry,
              entityStateWithNewerField,
              changeLogEntryFactory: ConcreteChangeLogEntry.fromJson,
              entityStateFactory: ConcreteEntityState.fromJson,
            );

        expect(result.newChangeLogEntry.operation, equals('outdated'));
        expect(result.newEntityState, isNull); // No state change for outdated
      });
    });
  });
}
