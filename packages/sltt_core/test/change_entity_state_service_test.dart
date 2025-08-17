import 'package:sltt_core/src/models/entity_type.dart';
import 'package:sltt_core/src/services/change_entity_state_service.dart';
import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  group('ChangeEntityStateService', () {
    late DateTime baseTime;
    late TestEntityState entityState;

    setUp(() {
      baseTime = DateTime.parse('2023-01-01T00:00:00Z');
      entityState = TestEntityState.fromJson(<String, dynamic>{
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
        final changeLogEntry = TestChangeLogEntry(
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
        final changeLogEntry = TestChangeLogEntry(
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
        final changeLogEntry = TestChangeLogEntry(
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
        final changeLogEntry = TestChangeLogEntry(
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
        final changeLogEntry = TestChangeLogEntry(
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
        final changeLogEntry = TestChangeLogEntry(
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
        final changeLogEntry = TestChangeLogEntry(
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
        final changeLogEntry = TestChangeLogEntry(
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
              changeLogEntryFactory: TestChangeLogEntry.fromJson,
              entityStateFactory: TestEntityState.fromJson,
            );
        expect(result.newChangeLogEntry, isNotNull);
        expect(result.newEntityState, isNotNull);
        // The rank should be updated to '2' since the change is newer
        expect(result.newEntityState?.data_rank, equals('2'));
        // Validate new change log entry fields
        expect(result.newChangeLogEntry.operation, equals('update'));
        expect(
          result.newChangeLogEntry.operationInfo['outdatedBys'],
          equals([]),
        );
        expect(
          result.newChangeLogEntry.operationInfo['noOpFields'],
          equals([]),
        );
        expect(result.newChangeLogEntry.stateChanged, isTrue);
        expect(result.newChangeLogEntry.data, equals({'rank': '2'}));
        expect(
          result.newChangeLogEntry.cloudAt,
          equals(changeLogEntry.cloudAt),
        );
      });

      test(
        'should record noOpFields and only include changed fields in change data',
        () {
          // incoming has rank same as existing (no-op), parentId changed and nameLocal new
          final changeLogEntry = TestChangeLogEntry(
            entityId: 'entity1',
            entityType: EntityType.task,
            domainId: 'project1',
            domainType: 'project',
            changeAt: baseTime.add(const Duration(minutes: 1)),
            cid: 'cid6',
            changeBy: 'user2',
            data: {'rank': '1', 'parentId': 'parent2', 'nameLocal': 'New Name'},
            operation: 'update',
            operationInfo: {},
            stateChanged: true,
            unknown: {},
          );

          final result =
              getAtomicLastWriteWinsToChangeLogEntryAndUpdateEntityState(
                changeLogEntry,
                entityState,
                changeLogEntryFactory: TestChangeLogEntry.fromJson,
                entityStateFactory: TestEntityState.fromJson,
              );

          expect(result.newChangeLogEntry.operation, equals('update'));
          // rank should be reported as no-op
          expect(
            result.newChangeLogEntry.operationInfo['noOpFields'],
            contains('rank'),
          );
          expect(
            result.newChangeLogEntry.operationInfo['outdatedBys'],
            equals([]),
          );
          // data should only include the applied fields (parentId and nameLocal)
          expect(
            result.newChangeLogEntry.data,
            equals({'parentId': 'parent2', 'nameLocal': 'New Name'}),
          );
          expect(result.newEntityState?.data_parentId, equals('parent2'));
          expect(result.newEntityState?.data_nameLocal, equals('New Name'));
        },
      );

      test('should include only non-outdated, non-noop fields in output data', () {
        // Build an entity where rank is newer (so incoming rank is outdated), parentId is older (so it should update),
        // and nameLocal matches existing (no-op).
        final olderTime = baseTime.subtract(const Duration(minutes: 5));
        final newerFieldTime = baseTime.add(const Duration(minutes: 2));

        final entityStateMixed = TestEntityState.fromJson({
          'entityId': 'entity1',
          'entityType': 'task',
          'change_domainId': 'project1',
          'change_domainId_orig_': 'project1',
          'change_changeAt': baseTime.toIso8601String(),
          'change_changeAt_orig_': baseTime.toIso8601String(),
          'change_cid': 'latest-cid',
          'change_cid_orig_': 'latest-cid',
          'change_changeBy': 'user1',
          'change_changeBy_orig_': 'user1',
          // parentId was last updated well before incoming change
          'data_parentId': 'parent1',
          'data_parentId_dataSchemaRev': 1,
          'data_parentId_changeAt_': olderTime.toIso8601String(),
          'data_parentId_cid_': 'cid1',
          'data_parentId_changeBy_': 'user1',
          // rank was updated after incoming change -> incoming rank should be outdated
          'data_rank': '9',
          'data_rank_dataSchemaRev': 1,
          'data_rank_changeAt_': newerFieldTime.toIso8601String(),
          'data_rank_cid_': 'field-cid',
          'data_rank_changeBy_': 'user1',
          // nameLocal already matches incoming
          'data_nameLocal': 'Same Name',
          'data_nameLocal_dataSchemaRev': 1,
          'data_nameLocal_changeAt_': baseTime.toIso8601String(),
          'data_nameLocal_cid_': 'cid-name',
          'data_nameLocal_changeBy_': 'user1',
          'unknown': <String, dynamic>{},
        });

        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity1',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime, // between olderTime and newerFieldTime
          cid: 'cid7',
          changeBy: 'user2',
          data: {'rank': '1', 'parentId': 'parent2', 'nameLocal': 'Same Name'},
          operation: 'update',
          operationInfo: {},
          stateChanged: true,
          unknown: {},
        );

        final result =
            getAtomicLastWriteWinsToChangeLogEntryAndUpdateEntityState(
              changeLogEntry,
              entityStateMixed,
              changeLogEntryFactory: TestChangeLogEntry.fromJson,
              entityStateFactory: TestEntityState.fromJson,
            );

        // rank should be outdated, nameLocal no-op, parentId should be applied
        expect(
          result.newChangeLogEntry.operation,
          anyOf(equals('update'), equals('outdated')),
        );
        expect(
          result.newChangeLogEntry.operationInfo['outdatedBys'],
          contains('rank'),
        );
        expect(
          result.newChangeLogEntry.operationInfo['noOpFields'],
          contains('nameLocal'),
        );
        // Only parentId should be present in output data
        expect(result.newChangeLogEntry.data, equals({'parentId': 'parent2'}));
        // The entity state may or may not be updated depending on whether the
        // overall operation was considered 'outdated' (no state update) or 'update'.
        if (result.newEntityState != null) {
          expect(result.newEntityState?.data_parentId, equals('parent2'));
        } else {
          // If no new entity state, enforce that the operation was marked outdated
          expect(result.newChangeLogEntry.operation, equals('outdated'));
        }
      });

      test('should reject older changes', () {
        // Create a change log entry with older field changes
        final olderTime = baseTime.subtract(const Duration(minutes: 5));
        final changeLogEntry = TestChangeLogEntry(
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
              changeLogEntryFactory: TestChangeLogEntry.fromJson,
              entityStateFactory: TestEntityState.fromJson,
            );

        expect(result.newChangeLogEntry.operation, equals('outdated'));
        // The rank should remain unchanged since the change is older
        expect(result.newEntityState?.data_rank, isNull);
        // Validate new change log entry fields for outdated result
        expect(
          result.newChangeLogEntry.operationInfo['outdatedBys'],
          contains('rank'),
        );
        expect(
          result.newChangeLogEntry.operationInfo['noOpFields'],
          equals([]),
        );
        expect(result.newChangeLogEntry.stateChanged, isFalse);
        // For outdated operations the produced data payload should be empty (no applied updates)
        expect(result.newChangeLogEntry.data, equals({}));
        expect(
          result.newChangeLogEntry.cloudAt,
          equals(changeLogEntry.cloudAt),
        );
      });

      test('should handle new entity creation', () {
        final changeLogEntry = TestChangeLogEntry(
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
              changeLogEntryFactory: TestChangeLogEntry.fromJson,
              entityStateFactory: TestEntityState.fromJson,
            );

        expect(result.newChangeLogEntry.operation, equals('create'));
        expect(result.newEntityState, isNotNull);
        expect(result.newEntityState?.entityId, equals('entity2'));
        expect(result.newEntityState?.data_rank, equals('1'));
        expect(result.newEntityState?.data_parentId, equals('parent2'));
        // Validate new change log entry fields
        expect(
          result.newChangeLogEntry.operationInfo['outdatedBys'],
          equals([]),
        );
        expect(
          result.newChangeLogEntry.operationInfo['noOpFields'],
          equals([]),
        );
        expect(result.newChangeLogEntry.stateChanged, isTrue);
        expect(
          result.newChangeLogEntry.data,
          equals({'rank': '1', 'parentId': 'parent2'}),
        );
        expect(
          result.newChangeLogEntry.cloudAt,
          equals(changeLogEntry.cloudAt),
        );
      });

      test('should populate nameLocal from change data', () {
        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity3',
          entityType: EntityType.task,
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid5',
          changeBy: 'user1',
          data: {'nameLocal': 'Localized Name', 'parentId': 'parent3'},
          operation: 'create',
          operationInfo: {},
          stateChanged: true,
          unknown: {},
        );

        final result =
            getAtomicLastWriteWinsToChangeLogEntryAndUpdateEntityState(
              changeLogEntry,
              null,
              changeLogEntryFactory: TestChangeLogEntry.fromJson,
              entityStateFactory: TestEntityState.fromJson,
            );

        expect(result.newChangeLogEntry.operation, equals('create'));
        expect(result.newEntityState, isNotNull);
        expect(result.newEntityState?.data_parentId, equals('parent3'));
        expect(result.newEntityState?.data_nameLocal, equals('Localized Name'));
        // Validate change log entry
        expect(
          result.newChangeLogEntry.operationInfo['outdatedBys'],
          equals([]),
        );
        expect(
          result.newChangeLogEntry.operationInfo['noOpFields'],
          equals([]),
        );
        expect(result.newChangeLogEntry.stateChanged, isTrue);
        expect(
          result.newChangeLogEntry.data,
          equals({'nameLocal': 'Localized Name', 'parentId': 'parent3'}),
        );
        expect(
          result.newChangeLogEntry.cloudAt,
          equals(changeLogEntry.cloudAt),
        );
      });

      test('should handle entity deletion', () {
        final changeLogEntry = TestChangeLogEntry(
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
              changeLogEntryFactory: TestChangeLogEntry.fromJson,
              entityStateFactory: TestEntityState.fromJson,
            );

        expect(result.newChangeLogEntry.operation, equals('delete'));
        expect(result.newEntityState?.data_deleted, equals(true));
        // Validate change log entry for delete
        expect(
          result.newChangeLogEntry.operationInfo['outdatedBys'],
          equals([]),
        );
        expect(
          result.newChangeLogEntry.operationInfo['noOpFields'],
          equals([]),
        );
        expect(result.newChangeLogEntry.stateChanged, isTrue);
        expect(result.newChangeLogEntry.data, equals({'deleted': true}));
        expect(
          result.newChangeLogEntry.cloudAt,
          equals(changeLogEntry.cloudAt),
        );
      });

      test(
        'should use latest timestamp pathway when change is newer than latest',
        () {
          // Test the case where incoming change is newer than the latest timestamp
          final newerTime = baseTime.add(const Duration(minutes: 5));
          final changeLogEntry = TestChangeLogEntry(
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
                changeLogEntryFactory: TestChangeLogEntry.fromJson,
                entityStateFactory: TestEntityState.fromJson,
              );

          expect(result.newChangeLogEntry.operation, equals('update'));
          expect(result.newEntityState?.data_rank, equals('2'));
          // Latest metadata should be updated
          expect(result.newEntityState?.change_changeAt, equals(newerTime));
          expect(result.newEntityState?.change_cid, equals('new-cid'));
          // Validate change log entry
          expect(
            result.newChangeLogEntry.operationInfo['outdatedBys'],
            equals([]),
          );
          expect(
            result.newChangeLogEntry.operationInfo['noOpFields'],
            equals([]),
          );
          expect(result.newChangeLogEntry.stateChanged, isTrue);
          expect(result.newChangeLogEntry.data, equals({'rank': '2'}));
          expect(
            result.newChangeLogEntry.cloudAt,
            equals(changeLogEntry.cloudAt),
          );
        },
      );

      test(
        'should use field-level pathway when change is older than latest - outdated',
        () {
          // Test the case where incoming change is older than latest, forcing field-level check
          // AND the incoming change is also older than the field timestamp -> outdated
          final olderTime = baseTime.subtract(const Duration(minutes: 5));
          final newerFieldTime = baseTime.add(const Duration(minutes: 2));

          // Create entity state where latest is baseTime but rank field was updated more recently
          final entityStateWithNewerField = TestEntityState.fromJson({
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

          final changeLogEntry = TestChangeLogEntry(
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
                changeLogEntryFactory: TestChangeLogEntry.fromJson,
                entityStateFactory: TestEntityState.fromJson,
              );

          expect(result.newChangeLogEntry.operation, equals('outdated'));
          expect(result.newEntityState, isNull); // No state change for outdated
          // Validate change log entry fields for outdated
          expect(
            result.newChangeLogEntry.operationInfo['outdatedBys'],
            contains('rank'),
          );
          expect(
            result.newChangeLogEntry.operationInfo['noOpFields'],
            equals([]),
          );
          expect(result.newChangeLogEntry.stateChanged, isFalse);
          expect(result.newChangeLogEntry.data, equals({}));
          expect(
            result.newChangeLogEntry.cloudAt,
            equals(changeLogEntry.cloudAt),
          );
        },
      );

      test(
        'should use field-level pathway when change is older than latest - update',
        () {
          // Test the case where incoming change is older than latest, forcing field-level check
          // BUT the incoming change is newer than the field timestamp -> update
          final olderTime = baseTime.subtract(const Duration(minutes: 5));
          final newerFieldTime = baseTime.subtract(
            const Duration(minutes: 2),
          ); // Between olderTime and baseTime

          // Create entity state where latest is baseTime but rank field is older
          final entityStateWithOlderField = TestEntityState.fromJson({
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
            'data_rank_changeAt_': olderTime
                .toIso8601String(), // Field is older than incoming
            'data_rank_cid_': 'old-field-cid',
            'data_rank_changeBy_': 'user0',
            'unknown': <String, dynamic>{},
          });

          final changeLogEntry = TestChangeLogEntry(
            entityId: 'entity1',
            entityType: EntityType.task,
            domainId: 'project1',
            domainType: 'project',
            changeAt: newerFieldTime, // Older than latest, but newer than field
            cid: 'mid-cid',
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
                entityStateWithOlderField,
                changeLogEntryFactory: TestChangeLogEntry.fromJson,
                entityStateFactory: TestEntityState.fromJson,
              );

          expect(result.newChangeLogEntry.operation, equals('update'));
          expect(result.newEntityState?.data_rank, equals('2'));
          // Latest metadata should NOT be updated to reflect this change
          expect(result.newEntityState?.change_changeAt, equals(baseTime));
          expect(result.newEntityState?.change_cid, equals('latest-cid'));
          // Validate change log entry fields for field-level update
          expect(
            result.newChangeLogEntry.operationInfo['outdatedBys'],
            equals([]),
          );
          expect(
            result.newChangeLogEntry.operationInfo['noOpFields'],
            equals([]),
          );
          expect(result.newChangeLogEntry.stateChanged, isTrue);
          expect(result.newChangeLogEntry.data, equals({'rank': '2'}));
          expect(
            result.newChangeLogEntry.cloudAt,
            equals(changeLogEntry.cloudAt),
          );
        },
      );
    });
  });
}
