import 'dart:convert';

import 'package:sltt_core/src/services/change_entity_state_service.dart';
import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  group('ChangeEntityStateService', () {
    late DateTime baseTime;
    late TestEntityState entityState;

    setUp(() {
      baseTime = DateTime.parse('2023-01-01T00:00:00Z');
      final esJson = <String, dynamic>{
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
        'data_parentId_dataSchemaRev_': 1,
        'data_parentId_changeAt_': baseTime.toIso8601String(),
        'data_parentId_cid_': 'cid1',
        'data_parentId_changeBy_': 'user1',
        // Add some rank data for testing
        'data_nameLocal': 'Test Task',
        'data_nameLocal_dataSchemaRev_': 1,
        'data_nameLocal_changeAt_': baseTime.toIso8601String(),
        'data_nameLocal_cid_': 'cid1',
        'data_nameLocal_changeBy_': 'user1',
        'data_rank': '1',
        'data_rank_dataSchemaRev_': 1,
        'data_rank_changeAt_': baseTime.toIso8601String(),
        'data_rank_cid_': 'cid1',
        'data_rank_changeBy_': 'user1',
        'unknownJson': '{}',
      };
      entityState = TestEntityState.fromJson(esJson);
    });

    group('getMaybeIsDuplicateCidResult', () {
      test('should return true for duplicate CID', () {
        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity1',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime,
          cid: 'cid1', // Same as entity state
          storageId: 'local',
          changeBy: 'user1',
          dataJson: jsonEncode({'rank': '1'}),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
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
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime,
          cid: 'cid2', // Different from entity state
          storageId: 'local',
          changeBy: 'user1',
          dataJson: jsonEncode({'rank': '2'}),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
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
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid2',
          storageId: 'local',
          changeBy: 'user1',
          dataJson: jsonEncode({'rank': '1'}),
          operation: 'create',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );

        final operation = calculateOperation(changeLogEntry, null, {}, [], []);

        expect(operation, equals('create'));
      });

      test('should calculate update operation for existing entity', () {
        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity1',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid2',
          storageId: 'local',
          changeBy: 'user1',
          dataJson: jsonEncode({'rank': '2'}),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
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
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid2',
          storageId: 'local',
          changeBy: 'user1',
          dataJson: jsonEncode({'deleted': true}),
          operation: 'delete',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
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
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid2',
          storageId: 'local',
          changeBy: 'user1',
          dataJson: jsonEncode({'rank': '1'}), // Same as current
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: false,
          unknownJson: jsonEncode({}),
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
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.subtract(const Duration(minutes: 1)), // Older
          cid: 'cid2',
          storageId: 'local',
          changeBy: 'user1',
          dataJson: jsonEncode({'rank': '2'}),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
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

    group('getUpdatesForChangeLogEntryAndEntityState', () {
      test('should handle field-level conflict resolution', () {
        // Create a change log entry with newer field changes
        final newerTime = baseTime.add(const Duration(minutes: 5));
        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity1',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: newerTime,
          cid: 'cid2',
          storageId: 'local',
          changeBy: 'user2',
          dataJson: jsonEncode({'rank': '2'}),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );
        final updates = getUpdatesForChangeLogEntryAndEntityState(
          changeLogEntry,
          entityState,
          targetStorageId: 'local',
        );

        // Entity state should update via stateUpdates
        expect(updates.stateUpdates['data_rank'], equals('2'));
        // Latest metadata should be updated since change is newer
        expect(
          updates.stateUpdates['change_changeAt'],
          equals(newerTime.toIso8601String()),
        );
        // Validate change-log entry updates
        expect(
          updates.changeUpdates,
          equals({
            'operation': 'update',
            'operationInfoJson': jsonEncode({
              'outdatedBys': [],
              'noOpFields': [],
            }),
            'stateChanged': true,
            'data': {'rank': '2'},
            'cloudAt': changeLogEntry.cloudAt,
          }),
        );
      });

      test('preserves incoming data when targetStorageId differs (cloud)', () {
        // incoming change originated from 'local' but is being sent to 'cloud'
        final newerTime = baseTime.add(const Duration(minutes: 5));
        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity1',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: newerTime,
          cid: 'cid-local-1',
          storageId: 'local',
          changeBy: 'user2',
          dataJson: jsonEncode({'rank': entityState.data_rank}),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );
        final updates = getUpdatesForChangeLogEntryAndEntityState(
          changeLogEntry,
          entityState,
          targetStorageId: 'cloud',
        );

        // Operation should be computed as noOp and report noOpFields; data subset is omitted
        expect(
          updates.changeUpdates,
          equals({
            'operation': 'noOp',
            'operationInfoJson': jsonEncode({
              'outdatedBys': [],
              'noOpFields': ['rank'],
            }),
            'stateChanged': false,
            'cloudAt': changeLogEntry.cloudAt,
          }),
        );
      });

      test(
        'should record noOpFields and only include changed fields in change data',
        () {
          // incoming has rank same as existing (no-op), parentId changed and nameLocal new
          final changeLogEntry = TestChangeLogEntry(
            entityId: 'entity1',
            entityType: 'task',
            domainId: 'project1',
            domainType: 'project',
            changeAt: baseTime.add(const Duration(minutes: 1)),
            cid: 'cid6',
            changeBy: 'user2',
            dataJson: jsonEncode({
              'rank': '1',
              'parentId': 'parent2',
              'nameLocal': 'New Name',
            }),
            operation: 'update',
            operationInfoJson: jsonEncode({}),
            stateChanged: true,
            unknownJson: jsonEncode({}),
          );

          final updates = getUpdatesForChangeLogEntryAndEntityState(
            changeLogEntry,
            entityState,
            targetStorageId: 'local',
          );

          expect(
            updates.changeUpdates,
            equals({
              'operation': 'update',
              'operationInfoJson': jsonEncode({
                'outdatedBys': [],
                'noOpFields': ['rank'],
              }),
              'stateChanged': true,
              'data': {'parentId': 'parent2', 'nameLocal': 'New Name'},
              'cloudAt': changeLogEntry.cloudAt,
            }),
          );

          expect(
            updates.stateUpdates,
            equals({
              'change_domainType': 'project',
              'change_domainId': 'project1',
              'change_changeAt': '2023-01-01T00:01:00.000Z',
              'change_cid': 'cid6',
              'change_changeBy': 'user2',
              'change_cloudAt': null,
              'data_parentId': 'parent2',
              'data_nameLocal': 'New Name',
              'data_parentId_changeAt_': '2023-01-01T00:01:00.000Z',
              'data_nameLocal_changeAt_': '2023-01-01T00:01:00.000Z',
              'data_parentId_cid_': 'cid6',
              'data_nameLocal_cid_': 'cid6',
              'data_parentId_changeBy_': 'user2',
              'data_nameLocal_changeBy_': 'user2',
              'data_parentId_cloudAt_': null,
              'data_nameLocal_cloudAt_': null,
            }),
          );
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
          'data_parentId_dataSchemaRev_': 1,
          'data_parentId_changeAt_': olderTime.toIso8601String(),
          'data_parentId_cid_': 'cid1',
          'data_parentId_changeBy_': 'user1',
          // rank was updated after incoming change -> incoming rank should be outdated
          'data_rank': '9',
          'data_rank_dataSchemaRev_': 1,
          'data_rank_changeAt_': newerFieldTime.toIso8601String(),
          'data_rank_cid_': 'field-cid',
          'data_rank_changeBy_': 'user1',
          // nameLocal already matches incoming
          'data_nameLocal': 'Same Name',
          'data_nameLocal_dataSchemaRev': 1,
          'data_nameLocal_changeAt_': baseTime.toIso8601String(),
          'data_nameLocal_cid_': 'cid-name',
          'data_nameLocal_changeBy_': 'user1',
          'unknownJson': '{}',
        });

        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity1',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime, // between olderTime and newerFieldTime
          cid: 'cid7',
          storageId: 'local',
          changeBy: 'user2',
          dataJson: jsonEncode({
            'rank': '1',
            'parentId': 'parent2',
            'nameLocal': 'Same Name',
          }),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );

        final updates = getUpdatesForChangeLogEntryAndEntityState(
          changeLogEntry,
          entityStateMixed,
          targetStorageId: 'local',
        );

        // rank should be outdated, nameLocal no-op, parentId should be applied
        expect(
          updates.changeUpdates,
          equals({
            'operation': 'outdated',
            'operationInfoJson': jsonEncode({
              'outdatedBys': ['rank'],
              'noOpFields': ['nameLocal'],
            }),
            'stateChanged': false,
            'cloudAt': null,
            'data': {'parentId': 'parent2'},
          }),
        );
      });

      test('should reject older changes', () {
        // Create a change log entry with older field changes
        final olderTime = baseTime.subtract(const Duration(minutes: 5));
        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity1',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: olderTime,
          cid: 'cid2',
          storageId: 'local',
          changeBy: 'user2',
          dataJson: jsonEncode({'rank': '3'}),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );

        final updates = getUpdatesForChangeLogEntryAndEntityState(
          changeLogEntry,
          entityState,
          targetStorageId: 'local',
        );

        expect(
          updates.changeUpdates,
          equals({
            'operation': 'outdated',
            'operationInfoJson': jsonEncode({
              'outdatedBys': ['rank'],
              'noOpFields': [],
            }),
            'stateChanged': false,
            'data': {},
            'cloudAt': changeLogEntry.cloudAt,
          }),
        );
      });

      test('should handle new entity creation', () {
        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity2',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid3',
          changeBy: 'user1',
          dataJson: jsonEncode({'rank': '1', 'parentId': 'parent2'}),
          operation: 'create',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );

        final updates = getUpdatesForChangeLogEntryAndEntityState(
          changeLogEntry,
          null, // No existing entity state
          targetStorageId: 'local',
        );

        expect(
          updates.changeUpdates,
          equals({
            'operation': 'create',
            'operationInfoJson': jsonEncode({
              'outdatedBys': [],
              'noOpFields': [],
              'change_changeAt_orig_': '1970-01-01 00:00:00.000Z',
            }),
            'stateChanged': true,
            'cloudAt': null,
            'data': {'rank': '1', 'parentId': 'parent2'},
          }),
        );
        // stateUpdates should initialize entity fields appropriately
        expect(
          updates.stateUpdates,
          equals({
            'entityId': 'entity2',
            'entityType': 'task',
            'change_dataSchemaRev': null,
            'change_domainId_orig_': '',
            'change_cid_orig_': '',
            'change_changeBy_orig_': '',
            'change_changeAt_orig_': '2023-01-01T00:01:00.000Z',
            'change_domainType': 'project',
            'change_domainId': 'project1',
            'change_changeAt': '2023-01-01T00:01:00.000Z',
            'change_cid': 'cid3',
            'change_changeBy': 'user1',
            'change_cloudAt': null,
            'data_rank': '1',
            'data_parentId': 'parent2',
            'data_rank_changeAt_': '2023-01-01T00:01:00.000Z',
            'data_parentId_changeAt_': '2023-01-01T00:01:00.000Z',
            'data_rank_cid_': 'cid3',
            'data_parentId_cid_': 'cid3',
            'data_rank_changeBy_': 'user1',
            'data_parentId_changeBy_': 'user1',
            'data_rank_cloudAt_': null,
            'data_parentId_cloudAt_': null,
          }),
        );
      });

      test('should populate nameLocal from change data', () {
        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity3',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid5',
          changeBy: 'user1',
          dataJson: jsonEncode({
            'nameLocal': 'Localized Name',
            'parentId': 'parent3',
          }),
          operation: 'create',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );

        final updates = getUpdatesForChangeLogEntryAndEntityState(
          changeLogEntry,
          null,
          targetStorageId: 'local',
        );

        expect(updates.stateUpdates['data_parentId'], equals('parent3'));
        expect(
          updates.stateUpdates['data_nameLocal'],
          equals('Localized Name'),
        );
        // Validate change log entry
        expect(
          updates.changeUpdates,
          equals({
            'operation': 'create',
            'operationInfoJson': jsonEncode({
              'outdatedBys': [],
              'noOpFields': [],
              'change_changeAt_orig_': '1970-01-01 00:00:00.000Z',
            }),
            'stateChanged': true,
            'data': {'nameLocal': 'Localized Name', 'parentId': 'parent3'},
            'cloudAt': null,
          }),
        );
      });

      test('should handle entity deletion', () {
        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity1',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid4',
          storageId: 'local',
          changeBy: 'user1',
          dataJson: jsonEncode({'deleted': true}),
          operation: 'delete',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );

        final updates = getUpdatesForChangeLogEntryAndEntityState(
          changeLogEntry,
          entityState,
          targetStorageId: 'local',
        );

        expect(
          updates.changeUpdates,
          equals({
            'operation': 'delete',
            'operationInfoJson': jsonEncode({
              'outdatedBys': [],
              'noOpFields': [],
            }),
            'stateChanged': true,
            'data': {'deleted': true},
            'cloudAt': changeLogEntry.cloudAt,
          }),
        );
      });

      test(
        'should use latest timestamp pathway when change is newer than latest',
        () {
          // Test the case where incoming change is newer than the latest timestamp
          final newerTime = baseTime.add(const Duration(minutes: 5));
          final changeLogEntry = TestChangeLogEntry(
            entityId: 'entity1',
            entityType: 'task',
            domainId: 'project1',
            domainType: 'project',
            changeAt: newerTime, // Newer than latest in entity state
            cid: 'new-cid',
            changeBy: 'user2',
            dataJson: jsonEncode({'rank': '2'}),
            operation: 'update',
            operationInfoJson: jsonEncode({}),
            stateChanged: true,
            unknownJson: jsonEncode({}),
          );

          final updates = getUpdatesForChangeLogEntryAndEntityState(
            changeLogEntry,
            entityState, // Uses baseTime as latest change
            targetStorageId: 'local',
          );

          expect(updates.changeUpdates['operation'], equals('update'));
          expect(updates.stateUpdates['data_rank'], equals('2'));
          // Latest metadata should be updated
          expect(
            updates.stateUpdates['change_changeAt'],
            equals(newerTime.toIso8601String()),
          );
          expect(updates.stateUpdates['change_cid'], equals('new-cid'));
          // Validate change log entry
          expect(
            updates.changeUpdates['operationInfo']['outdatedBys'],
            equals([]),
          );
          expect(
            updates.changeUpdates['operationInfo']['noOpFields'],
            equals([]),
          );
          expect(updates.changeUpdates['stateChanged'], isTrue);
          expect(updates.changeUpdates['data'], equals({'rank': '2'}));
          expect(
            updates.changeUpdates['cloudAt'],
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
            'data_nameLocal': 'Test Task',
            'data_nameLocal_dataSchemaRev_': 1,
            'data_nameLocal_changeAt_': baseTime.toIso8601String(),
            'data_nameLocal_cid_': 'cid1',
            'data_nameLocal_changeBy_': 'user1',
            'data_parentId': 'parent1',
            'data_parentId_dataSchemaRev_': 1,
            'data_parentId_changeAt_': baseTime.toIso8601String(),
            'data_parentId_cid_': 'cid1',
            'data_parentId_changeBy_': 'user1',
            'data_rank': '1',
            'data_rank_dataSchemaRev': 1,
            'data_rank_dataSchemaRev_': 1,
            'data_rank_changeAt_': newerFieldTime
                .toIso8601String(), // Field is newer than incoming
            'data_rank_cid_': 'field-cid',
            'data_rank_changeBy_': 'user1',
            'unknownJson': '{}',
          });

          final changeLogEntry = TestChangeLogEntry(
            entityId: 'entity1',
            entityType: 'task',
            domainId: 'project1',
            domainType: 'project',
            changeAt:
                olderTime, // Older than latest, will be rejected at field level too
            cid: 'old-cid',
            changeBy: 'user0',
            dataJson: jsonEncode({'rank': '0'}),
            operation: 'update',
            operationInfoJson: jsonEncode({}),
            stateChanged: true,
            unknownJson: jsonEncode({}),
          );

          final updates = getUpdatesForChangeLogEntryAndEntityState(
            changeLogEntry,
            entityStateWithNewerField,
            targetStorageId: 'local',
          );

          expect(updates.changeUpdates['operation'], equals('outdated'));
          // Validate change log entry fields for outdated
          expect(
            updates.changeUpdates['operationInfo']['outdatedBys'],
            contains('rank'),
          );
          expect(
            updates.changeUpdates['operationInfo']['noOpFields'],
            equals([]),
          );
          expect(updates.changeUpdates['stateChanged'], isFalse);
          expect(updates.changeUpdates['data'], equals({}));
          expect(
            updates.changeUpdates['cloudAt'],
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
            'data_nameLocal': 'Test Task',
            'data_nameLocal_dataSchemaRev_': 1,
            'data_nameLocal_changeAt_': baseTime.toIso8601String(),
            'data_nameLocal_cid_': 'cid1',
            'data_nameLocal_changeBy_': 'user1',
            'data_parentId': 'parent1',
            'data_parentId_dataSchemaRev_': 1,
            'data_parentId_changeAt_': baseTime.toIso8601String(),
            'data_parentId_cid_': 'cid1',
            'data_parentId_changeBy_': 'user1',
            'data_rank': '1',
            'data_rank_dataSchemaRev_': 1,
            'data_rank_changeAt_': olderTime
                .toIso8601String(), // Field is older than incoming
            'data_rank_cid_': 'old-field-cid',
            'data_rank_changeBy_': 'user0',
            'unknownJson': '{}',
          });

          final changeLogEntry = TestChangeLogEntry(
            entityId: 'entity1',
            entityType: 'task',
            domainId: 'project1',
            domainType: 'project',
            changeAt: newerFieldTime, // Older than latest, but newer than field
            cid: 'mid-cid',
            changeBy: 'user2',
            dataJson: jsonEncode({'rank': '2'}),
            operation: 'update',
            operationInfoJson: jsonEncode({}),
            stateChanged: true,
            unknownJson: jsonEncode({}),
          );

          final updates = getUpdatesForChangeLogEntryAndEntityState(
            changeLogEntry,
            entityStateWithOlderField,
            targetStorageId: 'local',
          );

          expect(updates.changeUpdates['operation'], equals('update'));
          expect(updates.stateUpdates['data_rank'], equals('2'));
          // Latest metadata should NOT be updated to reflect this change
          expect(updates.stateUpdates.containsKey('change_changeAt'), isFalse);
          expect(updates.stateUpdates.containsKey('change_cid'), isFalse);
          // Validate change log entry fields for field-level update
          expect(
            updates.changeUpdates['operationInfo']['outdatedBys'],
            equals([]),
          );
          expect(
            updates.changeUpdates['operationInfo']['noOpFields'],
            equals([]),
          );
          expect(updates.changeUpdates['stateChanged'], isTrue);
          expect(updates.changeUpdates['data'], equals({'rank': '2'}));
          expect(
            updates.changeUpdates['cloudAt'],
            equals(changeLogEntry.cloudAt),
          );
        },
      );
    });
  });
}
