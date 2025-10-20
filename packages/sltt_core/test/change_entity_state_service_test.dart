import 'dart:convert';

import 'package:sltt_core/src/logging.dart';
import 'package:sltt_core/src/models/constants/change_operations.dart';
import 'package:sltt_core/src/services/change_entity_state_service.dart';
import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  // Initialize project logger with default level (WARNING). Tests can call
  // SlttLogger.setLevel(Level.FINE) to enable verbose logs for debugging.
  SlttLogger.init();
  group('Serialization/Deserialization', () {
    test('TestChangeLogEntry serializes and deserializes correctly', () {
      final entry = TestChangeLogEntry(
        entityId: 'e1',
        entityType: 'task',
        domainId: 'd1',
        domainType: 'project',
        changeAt: DateTime.parse('2023-01-01T00:00:00Z'),
        cid: 'c1',
        storageId: 'local',
        changeBy: 'user1',
        dataJson: '{"foo":"bar"}',
        operation: 'update',
        operationInfoJson: '{"op":1}',
        stateChanged: true,
        unknownJson: '{"extra":42}',
        dataSchemaRev: 1,
        cloudAt: DateTime.parse('2023-01-01T01:00:00Z'),
        schemaVersion: 2,
        seq: 99,
      );
      final json = entry.toJson();
      final fromJson = TestChangeLogEntry.fromJson(json);
      expect(fromJson.entityId, entry.entityId);
      expect(fromJson.dataJson, entry.dataJson);
      expect(fromJson.unknownJson, entry.unknownJson);
      expect(fromJson.seq, entry.seq);
    });

    test('TestEntityState serializes and deserializes correctly', () {
      final state = TestEntityState(
        data_nameLocal: 'TaskName',
        entityId: 'e2',
        entityType: 'task',
        domainType: 'project',
        schemaVersion: 1,
        change_domainId: 'd2',
        change_domainId_orig_: 'd2',
        change_changeAt: DateTime.parse('2023-01-02T00:00:00Z'),
        change_changeAt_orig_: DateTime.parse('2023-01-02T00:00:00Z'),
        change_cid: 'c2',
        change_cid_orig_: 'c2',
        change_dataSchemaRev: 2,
        change_cloudAt: DateTime.parse('2023-01-02T01:00:00Z'),
        change_changeBy: 'user2',
        change_changeBy_orig_: 'user2',
        data_rank: 'r1',
        data_rank_dataSchemaRev_: 3,
        data_rank_changeAt_: DateTime.parse('2023-01-02T02:00:00Z'),
        data_rank_cid_: 'c2',
        data_rank_changeBy_: 'user2',
        data_rank_cloudAt_: DateTime.parse('2023-01-02T03:00:00Z'),
        data_deleted: false,
        data_deleted_dataSchemaRev_: 4,
        data_deleted_changeAt_: DateTime.parse('2023-01-02T04:00:00Z'),
        data_deleted_cid_: 'c2',
        data_deleted_changeBy_: 'user2',
        data_deleted_cloudAt_: DateTime.parse('2023-01-02T05:00:00Z'),
        data_parentId: 'p1',
        data_parentId_dataSchemaRev_: 5,
        data_parentId_changeAt_: DateTime.parse('2023-01-02T06:00:00Z'),
        data_parentId_cid_: 'c2',
        data_parentId_changeBy_: 'user2',
        data_parentId_cloudAt_: DateTime.parse('2023-01-02T07:00:00Z'),
        data_parentProp: 'pList',
        data_parentProp_dataSchemaRev_: 0,
        data_parentProp_changeAt_: DateTime.parse('2023-01-02T07:00:00Z'),
        data_parentProp_cid_: 'cid-parentprop-new',
        data_parentProp_changeBy_: 'creator',
        data_parentProp_cloudAt_: DateTime.parse('2023-01-02T08:00:00Z'),
        change_storedAt: DateTime.parse('2023-01-02T08:00:00Z'),
        change_storedAt_orig_: DateTime.parse('2023-01-02T08:00:00Z'),
        unknownJson: '',
      );
      final json = state.toJson();
      final fromJson = TestEntityState.fromJson(json);
      expect(fromJson.entityId, state.entityId);
      expect(fromJson.data_nameLocal, state.data_nameLocal);
      expect(fromJson.data_rank, state.data_rank);
      expect(fromJson.data_parentId, state.data_parentId);
      expect(fromJson.data_deleted, state.data_deleted);
    });
  });
  group('ChangeEntityStateService', () {
    late DateTime baseTime;
    late TestEntityState entityState;

    setUp(() {
      baseTime = DateTime.parse('2023-01-01T00:00:00Z');
      final storedAt = DateTime.now().toUtc().toIso8601String();
      final esJson = <String, dynamic>{
        'entityId': 'entity1',
        'entityType': 'task',
        'domainType': 'project',
        'change_storedAt': storedAt,
        'change_storedAt_orig_': storedAt,
        'change_domainId': 'project1',
        'change_domainId_orig_': 'project1',
        'change_changeAt': baseTime.toIso8601String(),
        'change_changeAt_orig_': baseTime.toIso8601String(),
        'change_cid': 'cid1',
        'change_cid_orig_': 'cid1',
        'change_changeBy': 'user1',
        'change_changeBy_orig_': 'user1',
        'data_parentId': 'parent1',
        'data_parentProp': 'pList',
        'data_parentId_dataSchemaRev_': 1,
        'data_parentId_changeAt_': baseTime.toIso8601String(),
        'data_parentId_cid_': 'cid1',
        'data_parentId_changeBy_': 'user1',
        'data_parentProp_dataSchemaRev_': 1,
        'data_parentProp_changeAt_': baseTime.toIso8601String(),
        'data_parentProp_cid_': 'cid1',
        'data_parentProp_changeBy_': 'user1',
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
    group('getAdditionalWarnings', () {
      late DateTime baseTime;
      late TestEntityState entityState;

      setUp(() {
        baseTime = DateTime.parse('2023-01-01T00:00:00Z');
        final storedAt = DateTime.now().toUtc().toIso8601String();
        entityState = TestEntityState.fromJson({
          'entityId': 'e1',
          'entityType': 'task',
          'domainType': 'project',
          'change_storedAt': storedAt,
          'change_storedAt_orig_': storedAt,
          'data_parentId': 'parent1',
          'data_parentProp': 'pList',
          'data_parentId_changeAt_': baseTime.toIso8601String(),
          'data_parentId_cid_': 'cid1',
          'data_parentId_changeBy_': 'u1',
          'data_parentProp_changeAt_': baseTime.toIso8601String(),
          'data_parentProp_cid_': 'cid1',
          'data_parentProp_changeBy_': 'u1',
          'data_nameLocal': 'Task 1',
          'data_nameLocal_changeAt_': baseTime.toIso8601String(),
          'data_nameLocal_cid_': 'cid1',
          'data_nameLocal_changeBy_': 'u1',
          'change_domainId': 'project1',
          'change_domainId_orig_': 'project1',
          'change_changeAt': baseTime.toIso8601String(),
          'change_changeAt_orig_': baseTime.toIso8601String(),
          'change_cid': 'cid1',
          'change_cid_orig_': 'cid1',
          'change_changeBy': 'u1',
          'data_rank_dataSchemaRev_': 1,
          'change_changeBy_orig_': 'u1',
          'unknownJson': '{}',
        });
      });

      test('reports operation mismatch when incoming operation differs', () {
        final entry = TestChangeLogEntry(
          entityId: 'e1',
          entityType: 'task',
          domainId: 'd1',
          domainType: 'project',
          changeAt: baseTime,
          cid: 'c1',
          storageId: 'local',
          changeBy: 'user1',
          dataJson: jsonEncode({'data_nameLocal': 'Task 1'}),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );

        final warnings = getAdditionalWarnings(
          operation: 'create',
          changeLogEntry: entry,
          entityState: entityState,
          stateUpdates: <String, dynamic>{},
          storageMode: 'sync',
        );

        expect(warnings.containsKey('operation'), isTrue);
        expect(warnings['operation'], equals('update'));
      });

      test(
        'captures non-default _orig_ values for new entities and copies field value',
        () {
          final entry = TestChangeLogEntry(
            entityId: 'e2',
            entityType: 'task',
            domainId: 'd2',
            domainType: 'project',
            changeAt: baseTime,
            cid: 'c2',
            storageId: 'local',
            changeBy: 'user2',
            dataJson: jsonEncode({'data_nameLocal': 'Task 2'}),
            operation: 'create',
            operationInfoJson: jsonEncode({}),
            stateChanged: true,
            unknownJson: jsonEncode({}),
          );

          final stateUpdates = <String, dynamic>{
            'change_domainId_orig_': 'orig-domain',
            'change_domainId': 'domain2',
          };

          final warnings = getAdditionalWarnings(
            operation: 'create',
            changeLogEntry: entry,
            entityState: null,
            stateUpdates: stateUpdates,
            storageMode: 'sync',
          );

          expect(warnings.containsKey('change_domainId_orig_'), isTrue);
          expect(warnings['change_domainId_orig_'], equals('orig-domain'));
          // the _orig_ entry should be replaced with the actual field value
          expect(stateUpdates['change_domainId_orig_'], equals('domain2'));
        },
      );

      test(
        'moves _orig_ fields to warnings when an existing entityState is present',
        () {
          final stateUpdates = <String, dynamic>{
            'data_rank_orig_': 'old-rank',
            'data_rank': '9',
          };

          final warnings = getAdditionalWarnings(
            operation: 'update',
            changeLogEntry: TestChangeLogEntry(
              entityId: 'e1',
              entityType: 'task',
              domainId: 'd1',
              domainType: 'project',
              changeAt: baseTime,
              cid: 'c1',
              storageId: 'local',
              changeBy: 'user1',
              dataJson: jsonEncode({
                'data_nameLocal': 'Task 1',
                'data_rank': '9',
              }),
              operation: 'update',
              operationInfoJson: jsonEncode({}),
              stateChanged: true,
              unknownJson: jsonEncode({}),
            ),
            entityState: entityState,
            stateUpdates: stateUpdates,
            storageMode: 'sync',
          );

          expect(warnings.containsKey('data_rank_orig_'), isTrue);
          expect(warnings['data_rank_orig_'], equals('old-rank'));
          expect(stateUpdates.containsKey('data_rank_orig_'), isFalse);
        },
      );

      test('should report empty change log entry operation for sync mode', () {
        final entry = TestChangeLogEntry(
          entityId: 'e1',
          entityType: 'task',
          domainId: 'd1',
          domainType: 'project',
          changeAt: baseTime,
          cid: 'c1',
          storageId: 'local',
          changeBy: 'user1',
          dataJson: jsonEncode({'data_nameLocal': 'Task 1'}),
          operation: '',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );

        final warnings = getAdditionalWarnings(
          operation: 'update',
          changeLogEntry: entry,
          entityState: entityState,
          stateUpdates: <String, dynamic>{},
          storageMode: 'sync',
        );

        expect(warnings.containsKey('operation'), isTrue);
        expect(warnings['operation'], equals(''));
      });

      test(
        'should not report empty change log entry operation for save mode',
        () {
          final entry = TestChangeLogEntry(
            entityId: 'e1',
            entityType: 'task',
            domainId: 'd1',
            domainType: 'project',
            changeAt: baseTime,
            cid: 'c1',
            storageId: 'local',
            changeBy: 'user1',
            dataJson: jsonEncode({'data_nameLocal': 'Task 1'}),
            operation: '',
            operationInfoJson: jsonEncode({}),
            stateChanged: true,
            unknownJson: jsonEncode({}),
          );

          final warnings = getAdditionalWarnings(
            operation: 'update',
            changeLogEntry: entry,
            entityState: entityState,
            stateUpdates: <String, dynamic>{},
            storageMode: 'save',
          );

          expect(warnings.containsKey('operation'), isFalse);
        },
      );
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
          storageId: 'localId',
          changeBy: 'user1',
          dataJson: jsonEncode({'rank': '1'}),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );

        final result = getMaybeIsDuplicateCidResult(
          changeLogEntry: changeLogEntry,
          entityState: entityState,
          storageType: 'local',
        );

        expect(result.isDuplicate, isTrue);
      });

      test(
        'should return duplicate with cloudAt stateUpdates for local storageType',
        () {
          final changeLogEntry = TestChangeLogEntry(
            entityId: 'entity1',
            entityType: 'task',
            domainId: 'project1',
            domainType: 'project',
            changeAt: baseTime,
            cid: 'cid1', // Same as entity state
            storageId: 'localId',
            changeBy: 'user1',
            dataJson: jsonEncode({'rank': '1'}),
            operation: 'update',
            operationInfoJson: jsonEncode({}),
            stateChanged: true,
            unknownJson: jsonEncode({}),
            cloudAt: baseTime.add(const Duration(minutes: 10)),
          );

          final result = getMaybeIsDuplicateCidResult(
            changeLogEntry: changeLogEntry,
            entityState: entityState,
            storageType: 'local',
          );

          expect(result.isDuplicate, isTrue);
          expect(result.stateUpdates, isNotNull);
          // Expect cloudAt to match and storedAt to be present (parseable)
          expect(
            result.stateUpdates,
            containsPair(
              'change_cloudAt',
              changeLogEntry.cloudAt!.toUtc().toIso8601String(),
            ),
          );
          expect(result.stateUpdates.containsKey('change_storedAt'), isTrue);
          final storedAtVal = result.stateUpdates['change_storedAt'];
          expect(storedAtVal, isA<String>());
          expect(DateTime.tryParse(storedAtVal), isNotNull);
        },
      );

      test(
        'should not return cloudAt stateUpdates for duplicate with cloudAt for cloud storageType',
        () {
          final changeLogEntry = TestChangeLogEntry(
            entityId: 'entity1',
            entityType: 'task',
            domainId: 'project1',
            domainType: 'project',
            changeAt: baseTime,
            cid: 'cid1', // Same as entity state
            storageId: 'localId',
            changeBy: 'user1',
            dataJson: jsonEncode({'rank': '1'}),
            operation: 'update',
            operationInfoJson: jsonEncode({}),
            stateChanged: true,
            unknownJson: jsonEncode({}),
            cloudAt: baseTime.add(const Duration(minutes: 10)),
          );

          final result = getMaybeIsDuplicateCidResult(
            changeLogEntry: changeLogEntry,
            entityState: entityState,
            storageType: 'cloud',
          );

          expect(result.isDuplicate, isTrue);
          expect(result.stateUpdates, isEmpty);
        },
      );

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
          changeLogEntry: changeLogEntry,
          entityState: entityState,
          storageType: 'local',
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

      test('should calculate pUpdate for partial updates', () {
        final tweenTime = baseTime.add(const Duration(minutes: 30));

        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity1',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: tweenTime,
          cid: 'cid2',
          storageId: 'local',
          changeBy: 'user1',
          dataJson: jsonEncode({
            'rank': '2', // Changed older date
            'nameLocal': 'Test Task (should be outdated)',
          }),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );

        final operation = calculateOperation(
          changeLogEntry,
          entityState,
          {'rank': '2'},
          [],
          ['nameLocal'],
        );

        expect(operation, equals('pUpdate'));
      });
    });

    group('getUpdatesForChangeLogEntryAndEntityState', () {
      // NOTE: removed helper functions that masked dynamic timestamp fields.
      // Tests should explicitly assert presence/format of dynamic timestamps
      // (like 'storedAt' and 'change_storedAt') where relevant, and perform
      // map equality by creating a copy and removing those keys inline.

      // Helper to assert a storedAt-like field exists, is a UTC ISO string,
      // and is equal or after baseTime. Returns the string value (does NOT
      // remove it from the map) so tests can include it in expected maps.
      String assertAndGetStoredAt(Map<String, dynamic> m, String key) {
        expect(m.containsKey(key), isTrue, reason: '$key should be present');
        final val = m[key];
        expect(val, isA<String>());
        final parsed = DateTime.parse(val as String).toUtc();
        expect(
          parsed.isAtSameMomentAs(baseTime.toUtc()) ||
              parsed.isAfter(baseTime.toUtc()),
          isTrue,
          reason: '$key should be equal or after baseTime',
        );
        return val;
      }

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
          storageId: '',
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
          storageMode: 'save',
          storageType: 'local',
          targetStorageId: 'localId',
        );

        final storedAtVal = assertAndGetStoredAt(
          updates.stateUpdates,
          'change_storedAt',
        );

        // Entity state should update via stateUpdates
        expect(
          updates.stateUpdates,
          equals({
            'domainType': 'project',
            'change_domainId': 'project1',
            'change_changeAt': newerTime.toIso8601String(),
            'change_cid': 'cid2',
            'change_changeBy': 'user2',
            'change_storedAt': storedAtVal,
            'data_rank': '2',
            'data_rank_changeAt_': newerTime.toIso8601String(),
            'data_rank_cid_': 'cid2',
            'data_rank_changeBy_': 'user2',
          }),
        );
        // Latest metadata should be updated since change is newer
        expect(
          updates.stateUpdates['change_changeAt'],
          equals(newerTime.toIso8601String()),
        );
        // Validate change-log entry updates: assert storedAt and include it in expected
        final storedAtVal1 = assertAndGetStoredAt(
          updates.changeUpdates,
          'storedAt',
        );
        expect(
          updates.changeUpdates,
          equals({
            'operation': 'update',
            'operationInfoJson': jsonEncode({
              'outdatedBys': [],
              'noOpFields': [],
            }),
            'stateChanged': true,
            'storageId': 'localId',
            'dataJson': jsonEncode({'rank': '2'}),
            'cloudAt': changeLogEntry.cloudAt?.toUtc().toIso8601String(),
            'storedAt': storedAtVal1,
          }),
        );
      });

      test('preserves incoming data when targetStorageId differs (cloud)', () {
        // incoming change originated from 'local' but is being sent to 'cloud'
        final newerTime = baseTime.add(const Duration(minutes: 5));
        final cloudAt = DateTime.now();
        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity1',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: newerTime,
          cid: 'cid-local-1',
          storageId: 'localId-1', // original
          changeBy: 'user2',
          dataJson: jsonEncode({'rank': entityState.data_rank}),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
          cloudAt: cloudAt,
        );
        final updates = getUpdatesForChangeLogEntryAndEntityState(
          changeLogEntry,
          entityState,
          storageMode: 'sync',
          storageType: 'local',
          targetStorageId: 'localId-2',
        );

        // Operation should be computed as noOp and report noOpFields; data subset is omitted
        final storedAtVal2 = assertAndGetStoredAt(
          updates.changeUpdates,
          'storedAt',
        );
        expect(
          updates.changeUpdates,
          equals({
            'operation': 'noOp',
            'operationInfoJson': jsonEncode({
              'outdatedBys': [],
              'noOpFields': ['rank'],
            }),
            'stateChanged': false,
            'cloudAt': changeLogEntry.cloudAt!.toUtc().toIso8601String(),
            'dataJson': jsonEncode({'rank': entityState.data_rank}),
            'storedAt': storedAtVal2,
          }),
        );
      });

      test(
        'should record noOpFields and only include changed fields in change data',
        () {
          // incoming has rank same as existing (no-op), parentId changed and nameLocal new
          final changeLogEntry = TestChangeLogEntry(
            storageId: '',
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
              'parentProp': 'pList',
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
            storageMode: 'save',
            storageType: 'local',
            targetStorageId: 'localId',
          );

          final storedAtVal3 = assertAndGetStoredAt(
            updates.changeUpdates,
            'storedAt',
          );
          expect(
            updates.changeUpdates,
            equals({
              'operation': 'update',
              'operationInfoJson': jsonEncode({
                'outdatedBys': [],
                'noOpFields': ['rank', 'parentProp'],
              }),
              'stateChanged': true,
              'storageId': 'localId',
              'dataJson': jsonEncode({
                'parentId': 'parent2',
                'nameLocal': 'New Name',
              }),
              'cloudAt': changeLogEntry.cloudAt?.toUtc().toIso8601String(),
              'storedAt': storedAtVal3,
            }),
          );

          // assert change_storedAt is present and valid (value included in expected map)
          assertAndGetStoredAt(updates.stateUpdates, 'change_storedAt');
          expect(
            updates.stateUpdates,
            equals({
              'domainType': 'project',
              'change_domainId': 'project1',
              'change_changeAt': '2023-01-01T00:01:00.000Z',
              'change_cid': 'cid6',
              'change_changeBy': 'user2',
              'change_storedAt': storedAtVal3,
              'data_parentId': 'parent2',
              'data_nameLocal': 'New Name',
              'data_parentId_changeAt_': '2023-01-01T00:01:00.000Z',
              'data_nameLocal_changeAt_': '2023-01-01T00:01:00.000Z',
              'data_parentId_cid_': 'cid6',
              'data_nameLocal_cid_': 'cid6',
              'data_parentId_changeBy_': 'user2',
              'data_nameLocal_changeBy_': 'user2',
            }),
          );
        },
      );

      test(
        'should include only non-outdated, non-noop fields in output data - partial update (pUpdate)',
        () {
          // Build an entity where rank is newer (so incoming rank is outdated), parentId is older (so it should update),
          // and nameLocal matches existing (no-op).
          final olderTime = baseTime.subtract(const Duration(minutes: 5));
          final newerFieldTime = baseTime.add(const Duration(minutes: 2));

          final storedAtJson = DateTime.now().toUtc().toIso8601String();

          final entityStateMixed = TestEntityState.fromJson({
            'entityId': 'entity1',
            'entityType': 'task',
            'domainType': 'project',
            'change_storedAt': storedAtJson,
            'change_storedAt_orig_': storedAtJson,
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
            // parentProp matches incoming (no-op)
            'data_parentProp': 'pList',
            'data_parentProp_dataSchemaRev_': 1,
            'data_parentProp_changeAt_': baseTime.toIso8601String(),
            'data_parentProp_cid_': 'cid-name',
            'data_parentProp_changeBy_': 'user1',
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
            storageId: '',
            changeBy: 'user2',
            dataJson: jsonEncode({
              'rank': '1',
              'parentId': 'parent2',
              'parentProp': 'pList',
              'nameLocal': 'Same Name',
            }),
            operation: kChangeOperationNotYetDefined,
            operationInfoJson: jsonEncode({}),
            stateChanged: true,
            unknownJson: jsonEncode({}),
          );

          final updates = getUpdatesForChangeLogEntryAndEntityState(
            changeLogEntry,
            entityStateMixed,
            storageMode: 'save',
            storageType: 'local',
            targetStorageId: 'localId',
          );

          // rank should be outdated, nameLocal no-op, parentId should be applied
          final storedAtVal4 = assertAndGetStoredAt(
            updates.changeUpdates,
            'storedAt',
          );
          expect(
            updates.changeUpdates,
            equals({
              'operation': 'pUpdate',
              'operationInfoJson': jsonEncode({
                'outdatedBys': ['rank'],
                'noOpFields': ['parentProp', 'nameLocal'],
              }),
              'stateChanged': true,
              'storageId': 'localId',
              'cloudAt': null,
              'dataJson': jsonEncode({'parentId': 'parent2'}),
              'storedAt': storedAtVal4,
            }),
          );
        },
      );

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
          storageId: '',
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
          storageMode: 'save',
          storageType: 'local',
          targetStorageId: 'localId',
        );

        final storedAtVal5 = assertAndGetStoredAt(
          updates.changeUpdates,
          'storedAt',
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
            'storageId': 'localId',
            'dataJson': jsonEncode({}),
            'cloudAt': changeLogEntry.cloudAt?.toUtc().toIso8601String(),
            'storedAt': storedAtVal5,
          }),
        );
      });

      test('should handle new entity creation', () {
        final changeLogEntry = TestChangeLogEntry(
          storageId: '',
          entityId: 'entity2',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid3',
          changeBy: 'user1',
          dataJson: jsonEncode({
            'rank': '1',
            'parentId': 'parent2',
            'parentProp': 'pList',
          }),
          operation: 'create',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );

        final updates = getUpdatesForChangeLogEntryAndEntityState(
          changeLogEntry,
          null, // No existing entity state
          storageMode: 'save',
          storageType: 'local',
          targetStorageId: 'localId',
        );

        final storedAtVal6 = assertAndGetStoredAt(
          updates.changeUpdates,
          'storedAt',
        );
        expect(
          updates.changeUpdates,
          equals({
            'operation': 'create',
            'operationInfoJson': jsonEncode({
              'outdatedBys': [],
              'noOpFields': [],
            }),
            'stateChanged': true,
            'storageId': 'localId',
            'cloudAt': null,
            'dataJson': jsonEncode({
              'rank': '1',
              'parentId': 'parent2',
              'parentProp': 'pList',
            }),
            'storedAt': storedAtVal6,
          }),
        );
        // stateUpdates should initialize entity fields appropriately
        // If present, change_storedAt must be equal or after baseTime
        if (updates.stateUpdates.containsKey('change_storedAt')) {
          final csVal = updates.stateUpdates['change_storedAt'];
          expect(csVal, isA<String>());
          final csParsed = DateTime.parse(csVal as String).toUtc();
          expect(
            csParsed.isAtSameMomentAs(baseTime.toUtc()) ||
                csParsed.isAfter(baseTime.toUtc()),
            isTrue,
            reason: 'change_storedAt should be equal or after baseTime',
          );
          updates.stateUpdates.remove('change_storedAt');
        }
        // Also capture dynamic change_storedAt_orig_ if present
        String? storedAtOrig;
        if (updates.stateUpdates.containsKey('change_storedAt_orig_')) {
          storedAtOrig =
              updates.stateUpdates['change_storedAt_orig_'] as String?;
          expect(
            DateTime.tryParse(storedAtOrig ?? ''),
            isNotNull,
            reason: 'change_storedAt_orig_ should be a valid ISO timestamp',
          );
        }

        expect(
          updates.stateUpdates,
          equals({
            'entityId': 'entity2',
            'domainType': 'project',
            'entityType': 'task',
            'change_domainId_orig_': 'project1',
            'change_cid_orig_': 'cid3',
            'change_changeBy_orig_': 'user1',
            'change_changeAt_orig_': '2023-01-01T00:01:00.000Z',
            if (storedAtOrig != null) 'change_storedAt_orig_': storedAtOrig,
            'change_domainId': 'project1',
            'change_changeAt': '2023-01-01T00:01:00.000Z',
            'change_cid': 'cid3',
            'change_changeBy': 'user1',
            'data_rank': '1',
            'data_parentId': 'parent2',
            'data_rank_changeAt_': '2023-01-01T00:01:00.000Z',
            'data_parentId_changeAt_': '2023-01-01T00:01:00.000Z',
            'data_rank_cid_': 'cid3',
            'data_parentId_cid_': 'cid3',
            'data_rank_changeBy_': 'user1',
            'data_parentId_changeBy_': 'user1',
            'data_parentProp': 'pList',
            'data_parentProp_changeAt_': '2023-01-01T00:01:00.000Z',
            'data_parentProp_cid_': 'cid3',
            'data_parentProp_changeBy_': 'user1',
          }),
        );
      });

      test('should populate nameLocal from change data', () {
        final changeLogEntry = TestChangeLogEntry(
          storageId: '',
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
            'parentProp': 'pList',
          }),
          operation: 'create',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );

        final updates = getUpdatesForChangeLogEntryAndEntityState(
          changeLogEntry,
          null,
          storageMode: 'save',
          storageType: 'local',
          targetStorageId: 'localId',
        );

        expect(updates.stateUpdates['data_parentId'], equals('parent3'));
        expect(
          updates.stateUpdates['data_nameLocal'],
          equals('Localized Name'),
        );
        // Validate change log entry
        final storedAtVal7 = assertAndGetStoredAt(
          updates.changeUpdates,
          'storedAt',
        );
        expect(
          updates.changeUpdates,
          equals({
            'operation': 'create',
            'operationInfoJson': jsonEncode({
              'outdatedBys': [],
              'noOpFields': [],
            }),
            'stateChanged': true,
            'storageId': 'localId',
            'dataJson': jsonEncode({
              'nameLocal': 'Localized Name',
              'parentId': 'parent3',
              'parentProp': 'pList',
            }),
            'cloudAt': null,
            'storedAt': storedAtVal7,
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
          storageId: '',
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
          storageMode: 'save',
          storageType: 'local',
          targetStorageId: 'localId',
        );

        final storedAtVal8 = assertAndGetStoredAt(
          updates.changeUpdates,
          'storedAt',
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
            'storageId': 'localId',
            'dataJson': jsonEncode({'deleted': true}),
            'cloudAt': changeLogEntry.cloudAt?.toUtc().toIso8601String(),
            'storedAt': storedAtVal8,
          }),
        );
      });

      test(
        'changeUpdates cloudAt is assigned when null in cloud storageType',
        () {
          // create a change with a null cloudAt
          final changeLogEntry = TestChangeLogEntry(
            entityId: 'entityX',
            entityType: 'task',
            domainId: 'project1',
            domainType: 'project',
            changeAt: baseTime.add(const Duration(minutes: 1)),
            cid: 'cid-cloud-sync',
            storageId: 'localId-1',
            changeBy: 'user1',
            dataJson: jsonEncode({'rank': '1'}),
            operation: 'update',
            operationInfoJson: jsonEncode({}),
            stateChanged: true,
            unknownJson: jsonEncode({}),
            cloudAt: null,
          );

          final updates = getUpdatesForChangeLogEntryAndEntityState(
            changeLogEntry,
            null,
            storageMode: 'sync',
            storageType: 'cloud',
            targetStorageId: 'cloudId-1',
          );

          final cloudVal = updates.changeUpdates['cloudAt'];
          // Must be present
          expect(cloudVal, isNotNull);
          // And must be serialized as a String (not a DateTime object)
          expect(cloudVal, isA<String>());
          // And parsable back to the original instant
          final parsed = DateTime.parse(cloudVal as String);
          expect(
            parsed.isUtc,
            isTrue,
            reason: 'Should be in UTC, but was not: $parsed',
          );
          // preserve original storageId in this pathway
          expect(updates.changeUpdates['storageId'], isNull);
        },
      );

      test(
        'changeUpdates cloudAt is a serialized ISO string when non-null',
        () {
          // create a change with an explicit cloudAt DateTime
          final cloudTime = DateTime.parse('2023-01-01T02:00:00Z');
          final changeLogEntry = TestChangeLogEntry(
            entityId: 'entityY',
            entityType: 'task',
            domainId: 'project1',
            domainType: 'project',
            changeAt: baseTime.add(const Duration(minutes: 1)),
            cid: 'cid-cloud-sync2',
            storageId: 'localId-1',
            changeBy: 'user1',
            dataJson: jsonEncode({'rank': '1'}),
            operation: 'update',
            operationInfoJson: jsonEncode({}),
            stateChanged: true,
            unknownJson: jsonEncode({}),
            cloudAt: cloudTime,
          );

          final updates = getUpdatesForChangeLogEntryAndEntityState(
            changeLogEntry,
            null,
            storageMode: 'sync',
            storageType: 'cloud',
            targetStorageId: 'cloudId-1',
          );

          final cloudVal = updates.changeUpdates['cloudAt'];
          // Must be present
          expect(cloudVal, isNotNull);
          // And must be serialized as a String (not a DateTime object)
          expect(cloudVal, isA<String>());
          // And parsable back to the original instant
          final parsed = DateTime.parse(cloudVal as String).toUtc();
          expect(parsed, equals(cloudTime.toUtc()));
        },
      );

      test(
        'should use latest timestamp pathway when change is newer than latest',
        () {
          // Test the case where incoming change is newer than the latest timestamp
          final newerTime = baseTime.add(const Duration(minutes: 5));
          final changeLogEntry = TestChangeLogEntry(
            storageId: '',
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
            storageMode: 'save',
            storageType: 'local',
            targetStorageId: 'localId',
          );

          final storedAtVal12 = assertAndGetStoredAt(
            updates.changeUpdates,
            'storedAt',
          );
          expect(
            updates.changeUpdates,
            equals({
              'operation': 'update',
              'operationInfoJson': jsonEncode({
                'outdatedBys': [],
                'noOpFields': [],
              }),
              'stateChanged': true,
              'storageId': 'localId',
              'dataJson': jsonEncode({'rank': '2'}),
              'storedAt': storedAtVal12,
              'cloudAt': null,
            }),
          );
          expect(
            (() {
              final s = Map<String, dynamic>.from(updates.stateUpdates);
              s.remove('change_storedAt');
              return s;
            })(),
            equals({
              'domainType': 'project',
              'change_domainId': 'project1',
              'change_changeAt': '2023-01-01T00:05:00.000Z',
              'change_cid': 'new-cid',
              'change_changeBy': 'user2',
              'data_rank': '2',
              'data_rank_changeAt_': '2023-01-01T00:05:00.000Z',
              'data_rank_cid_': 'new-cid',
              'data_rank_changeBy_': 'user2',
            }),
          );
        },
      );

      test(
        'should create change log entry for some non-state-changing errors in cloud storage',
        () {
          // TODO: generate a change producing an error that should be stored in cloudStorage
          // Do we also want to do this for any local storage errors?
        },
        skip: 'Not implemented yet',
      );

      // this is interesting because it creates a change entry log even though
      // the state hasn't changed
      // should we do this for errors in the cloud sync pathway too?
      test(
        'should use field-level pathway when change is older than latest - outdated',
        () {
          // Test the case where incoming change is older than latest, forcing field-level check
          // AND the incoming change is also older than the field timestamp -> outdated
          final olderTime = baseTime.subtract(const Duration(minutes: 5));
          final newerFieldTime = baseTime.add(const Duration(minutes: 2));

          final storedAtJson = DateTime.now().toUtc().toIso8601String();
          // Create entity state where latest is baseTime but rank field was updated more recently
          final entityStateWithNewerField = TestEntityState.fromJson({
            'entityId': 'entity1',
            'entityType': 'task',
            'domainType': 'project',
            'change_storedAt': storedAtJson,
            'change_storedAt_orig_': storedAtJson,
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
            'data_parentProp': 'pList',
            'data_parentProp_dataSchemaRev_': 1,
            'data_parentProp_changeAt_': baseTime.toIso8601String(),
            'data_parentProp_cid_': 'cid1',
            'data_parentProp_changeBy_': 'user1',
            'data_parentProp_cloudAt_': null,
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
            storageMode: 'save',
            storageType: 'local',
            targetStorageId: 'localId',
          );

          final storedAtVal13 = assertAndGetStoredAt(
            updates.changeUpdates,
            'storedAt',
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
              'storageId': 'localId',
              'dataJson': jsonEncode({}),
              'cloudAt': changeLogEntry.cloudAt?.toUtc().toIso8601String(),
              'storedAt': storedAtVal13,
            }),
          );
          expect(updates.stateUpdates, equals({}));
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

          final storedAtJson = DateTime.now().toUtc().toIso8601String();

          // Create entity state where latest is baseTime but rank field is older
          final entityStateWithOlderField = TestEntityState.fromJson({
            'entityId': 'entity1',
            'entityType': 'task',
            'domainType': 'project',
            'change_storedAt': storedAtJson,
            'change_storedAt_orig_': storedAtJson,
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
            'data_parentProp': 'pList',
            'data_parentProp_dataSchemaRev_': 1,
            'data_parentProp_changeAt_': baseTime.toIso8601String(),
            'data_parentProp_cid_': 'cid1',
            'data_parentProp_changeBy_': 'user1',
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
            storageMode: 'save',
            storageType: 'local',
            targetStorageId: 'localId',
          );

          final storedAtVal14 = assertAndGetStoredAt(
            updates.changeUpdates,
            'storedAt',
          );
          expect(
            updates.changeUpdates,
            equals({
              'operation': 'update',
              'operationInfoJson': jsonEncode({
                'outdatedBys': [],
                'noOpFields': [],
              }),
              'stateChanged': true,
              'storageId': 'localId',
              'dataJson': jsonEncode({'rank': '2'}),
              'cloudAt': changeLogEntry.cloudAt?.toUtc().toIso8601String(),
              'storedAt': storedAtVal14,
            }),
          );
          // Latest metadata should NOT be updated to reflect this change
          expect(updates.stateUpdates.containsKey('change_changeAt'), isFalse);
          expect(updates.stateUpdates.containsKey('change_cid'), isFalse);
          // change_storedAt and change_cloudAt are present when field updates are applied
          final stateStoredAtVal = assertAndGetStoredAt(
            updates.stateUpdates,
            'change_storedAt',
          );
          expect(
            updates.stateUpdates,
            equals({
              'change_storedAt': stateStoredAtVal,
              'data_rank': '2',
              'data_rank_changeAt_': newerFieldTime.toIso8601String(),
              'data_rank_cid_': 'mid-cid',
              'data_rank_changeBy_': 'user2',
            }),
          );
        },
      );

      test('should add storedAt for local storage changes', () {
        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity1',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid-store-1',
          storageId: '',
          changeBy: 'user1',
          dataJson: jsonEncode({'rank': '1'}),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
        );

        final updates = getUpdatesForChangeLogEntryAndEntityState(
          changeLogEntry,
          entityState,
          storageMode: 'save',
          storageType: 'local',
          targetStorageId: 'localId-1',
        );

        expect(
          updates.changeUpdates.containsKey('storedAt'),
          isTrue,
          reason:
              'storedAt should be added for local storage changes, but was missing',
        );
        final storedAtVal = assertAndGetStoredAt(
          updates.changeUpdates,
          'storedAt',
        );
        final parsed = DateTime.parse(storedAtVal);
        expect(
          parsed.isAfter(baseTime),
          isTrue,
          reason: 'storedAt should be after baseTime, but was not: $parsed',
        );
      });

      test('should add storedAt for cloud storage changes (match cloudAt)', () {
        final cloudAt = DateTime.parse('2023-01-01T02:00:00Z');
        final changeLogEntry = TestChangeLogEntry(
          entityId: 'entity1',
          entityType: 'task',
          domainId: 'project1',
          domainType: 'project',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          cid: 'cid-cloud-store-1',
          storageId: 'localId-1',
          changeBy: 'user1',
          dataJson: jsonEncode({'rank': '1'}),
          operation: 'update',
          operationInfoJson: jsonEncode({}),
          stateChanged: true,
          unknownJson: jsonEncode({}),
          cloudAt: cloudAt,
        );

        final updates = getUpdatesForChangeLogEntryAndEntityState(
          changeLogEntry,
          entityState,
          storageMode: 'sync',
          storageType: 'cloud',
          targetStorageId: 'cloudId-1',
        );

        expect(
          updates.changeUpdates.containsKey('storedAt'),
          isTrue,
          reason:
              'storedAt should be added for cloud storage changes, but was missing',
        );
        final storedAtVal = assertAndGetStoredAt(
          updates.changeUpdates,
          'storedAt',
        );
        final parsed = DateTime.parse(storedAtVal).toUtc();
        // storedAt should match cloudAt in this pathway
        expect(
          parsed,
          equals(cloudAt.toUtc()),
          reason:
              'storedAt should match cloudAt, but did not. storedAt=$parsed, cloudAt=$cloudAt',
        );
      });
    });

    group('getDataAndStateUpdatesOrOutdatedBys', () {
      test(
        'should detect field-drift and produce stateUpdates compatible with TestEntityState deserialization',
        () {
          final data = {
            'nameLocal': 'Test Task Name',
            'parentId': 'parent-drift-test',
            'parentProp': 'pList',
            'nameOptionalField': 'optional value',
          };
          // Create a change log entry for a new entity with all required fields
          final changeLogEntry = TestChangeLogEntry(
            entityId: 'entity-drift-test',
            entityType: 'task',
            domainId: 'project1',
            domainType: 'project',
            changeAt: baseTime.add(const Duration(minutes: 1)),
            cid: 'cid-drift-test',
            storageId: '',
            changeBy: 'user1',
            dataJson: jsonEncode(data),
            operation: 'create',
            operationInfoJson: jsonEncode({}),
            stateChanged: true,
            unknownJson: jsonEncode({}),
            dataSchemaRev: 0,
          );

          final updates = getDataAndStateUpdatesOrOutdatedBys(
            changeLogEntry: changeLogEntry,
            entityState: null, // No existing entity state
            fieldChanges: data,
            noOpFields: [],
            storageMode: 'save',
            storageType: 'cloud',
            cs: computeCloudAndStoredAt(changeLogEntry, 'cloud'),
          );

          // Debug: Print stateUpdates to understand what fields are being generated
          SlttLogger.logger.info(
            'DEBUG: stateUpdates keys: ${updates['stateUpdates'].keys.toList()..sort()}',
          );

          // Step 2: Deserialize stateUpdates back to TestEntityState
          final testEntityState = TestEntityState.fromJson(
            updates['stateUpdates'],
          );

          // Step 2 verification: Check if there are unknown fields
          if (testEntityState.unknownJson != '{}') {
            SlttLogger.logger.info(
              'DEBUG: Unknown fields detected: ${testEntityState.unknownJson}',
            );
            SlttLogger.logger.info(
              'DEBUG: Action needed: Either add missing fields to BaseEntityState or update TestEntityState',
            );
            fail(
              'FIELD DRIFT DETECTED: TestEntityState has unknown fields:\n${const JsonEncoder.withIndent(' ').convert(testEntityState.getUnknown())}',
            );
          }

          expect(
            testEntityState.unknownJson,
            equals('{}'),
            reason: 'TestEntityState should deserialize without unknown fields',
          );

          // Step 3: Round-trip serialize the entity state
          final serializedJson = testEntityState.toJson();

          // Step 3 verification: The serialized version should contain the same fields and values
          // as the original stateUpdates (excluding dynamic timestamps that we handle separately)
          final originalStateUpdates = Map<String, dynamic>.from(
            updates['stateUpdates'],
          );

          // remove unknownJson for comparison
          serializedJson.remove('unknownJson');

          // remove optional fields for field-drift detection
          final strippedStateUpdates = Map<String, dynamic>.from(
            originalStateUpdates,
          )..removeWhere((key, value) => value == null);

          expect(
            serializedJson,
            equals(strippedStateUpdates),
            reason:
                'Round-trip serialization should produce consistent results',
          );

          // Verify specific field was properly handled
          expect(
            testEntityState.data_nameLocal,
            equals('Test Task Name'),
            reason: 'nameLocal field should be correctly deserialized',
          );
          expect(
            serializedJson['data_nameLocal'],
            equals('Test Task Name'),
            reason: 'nameLocal field should be correctly serialized',
          );

          // now see if TestEntityState has any additional (optional) fields
          final jsonWithNullValues = testEntityState.toJsonBase()
            ..removeWhere((key, value) => value != null);
          // compare with null values from stateUpdates
          final stateUpdatesWithNullValues = <String, dynamic>{
            ...updates['stateUpdates'],
          }..removeWhere((key, value) => value != null);
          expect(
            jsonWithNullValues.keys.toList()..sort(),
            equals(stateUpdatesWithNullValues.keys.toList()..sort()),
            reason:
                'TestEntityState should include all optional fields with null values',
          );
        },
      );
    });
  });
}
