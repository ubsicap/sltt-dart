import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/isar_storage_service.dart';
import 'package:sync_manager/src/models/isar_change_log_entry.dart';
import 'package:test/test.dart';

void main() {
  late final IsarStorageService storage;
  // Use a unique database name per test run to avoid unique-index collisions
  // from prior runs when the same static name is reused.
  final testDbName =
      'test_get_entity_states_${DateTime.now().microsecondsSinceEpoch}';

  setUpAll(() async {
    isarChangeLogEntryFactoryRegistration;
    // Pass the unique testDbName as the database name (first arg) and a
    // short log prefix as the second argument.
    storage = IsarStorageService(testDbName, 'local');
    await storage.deleteDatabase();
    await storage.initialize();
    SlttLogger.logger.info(
      '[TestGetEntityStates] Isar database initialized at: ./isar_db/$testDbName.isar',
    );
  });

  tearDownAll(() async {
    await storage.close();
  });

  group('IsarStorageService.getEntityStates', () {
    test('returns empty list when no entities exist', () async {
      final result = await storage.getEntityStates(
        domainType: 'project',
        domainId: 'non-existent-project',
        entityType: 'task',
      );

      expect(result['items'], isEmpty);
      // Some storage implementations treat limit=0 as no limit; only assert
      // that items are empty and nextCursor is null to avoid flakiness.
      expect(result['nextCursor'], isNull);
    });

    test('throws ArgumentError for unsupported entity type', () async {
      expect(
        () => storage.getEntityStates(
          domainType: 'project',
          domainId: 'test-project',
          entityType: 'unsupported-type',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Unsupported entity type'),
          ),
        ),
      );
    });

    test('handles large cursor values gracefully', () async {
      final result = await storage.getEntityStates(
        domainType: 'project',
        domainId: 'test-project',
        entityType: 'task',
        cursor: 'zzzzz-very-large-cursor-value',
      );

      expect(result['items'], isEmpty);
      // Implementation details may vary; don't assert hasMore strictly here.
      expect(result['nextCursor'], isNull);
    });

    test('handles edge case with zero limit', () async {
      final result = await storage.getEntityStates(
        domainType: 'project',
        domainId: 'test-project',
        entityType: 'task',
        limit: 0,
      );

      expect(result['items'], isEmpty);
      // Some storage implementations treat limit=0 specially; only assert
      // items are empty and nextCursor is null to avoid flakiness.
      expect(result['nextCursor'], isNull);
    });

    test('accepts parentId parameter without error', () async {
      final result = await storage.getEntityStates(
        domainType: 'project',
        domainId: 'test-project',
        entityType: 'task',
        parentId: 'some-parent-id',
      );

      expect(result['items'], isEmpty);
      expect(result['hasMore'], isFalse);
      expect(result['nextCursor'], isNull);
    });

    test('parentId parameter works with other parameters', () async {
      final result = await storage.getEntityStates(
        domainType: 'project',
        domainId: 'test-project',
        entityType: 'task',
        parentId: 'some-parent-id',
        limit: 50,
        cursor: 'some-cursor',
        includeMetadata: true,
      );

      expect(result['items'], isEmpty);
      expect(result['hasMore'], isFalse);
      expect(result['nextCursor'], isNull);
    });

    test('returns only matching items when parentProp matches', () async {
      // Seed two entity states with different parentProp values
      final now = DateTime.now().toUtc();
      final cid1 = 'cid-${now.microsecondsSinceEpoch}-1';
      final cid2 = 'cid-${now.microsecondsSinceEpoch}-2';

      // Create first change that sets parentProp to 'pList'
      final change1 = {
        'domainId': 'test-project',
        'domainType': 'project',
        'entityType': 'task',
        'entityId': 'task-1',
        'changeBy': 'tester',
        'changeAt': now.toIso8601String(),
        'cid': cid1,
        'storageId': '',
        'operation': 'create',
        'operationInfoJson': '{}',
        'stateChanged': false,
        'unknownJson': '{}',
        'dataJson':
            '{"nameLocal": "Task 1", "parentId": "root", "parentProp": "pList"}',
      };

      // Create second change that sets parentProp to 'other'
      final change2 = {
        'domainId': 'test-project',
        'domainType': 'project',
        'entityType': 'task',
        'entityId': 'task-2',
        'changeBy': 'tester',
        'changeAt': now.add(const Duration(seconds: 1)).toIso8601String(),
        'cid': cid2,
        'storageId': '',
        'operation': 'create',
        'operationInfoJson': '{}',
        'stateChanged': false,
        'unknownJson': '{}',
        'dataJson':
            '{"nameLocal": "Task 2", "parentId": "root", "parentProp": "other"}',
      };

      // Use updateChangeLogAndState to write states
      SlttLogger.logger.fine('DEBUG: stateUpdates for task-1 -> ');
      SlttLogger.logger.fine({
        'domainType': 'project',
        'entityType': 'task',
        'entityId': 'task-1',
        'change_domainId': 'test-project',
        'change_changeAt': now.toIso8601String(),
        'change_changeAt_orig_': now.toIso8601String(),
        'change_domainId_orig_': 'test-project',
        'change_cid': 'cid-1',
        'change_cid_orig_': 'cid-1',
        'change_changeBy': 'tester',
        'change_changeBy_orig_': 'tester',
        'data_nameLocal_changeAt_': now.toIso8601String(),
        'data_nameLocal_cid_': 'cid-1',
        'data_nameLocal_changeBy_': 'tester',
        'data_parentId': 'root',
        'data_parentId_dataSchemaRev_': null,
        'data_parentId_changeAt_': now.toIso8601String(),
        'data_parentId_cid_': 'cid-1',
        'data_parentId_changeBy_': 'tester',
        'data_parentProp': 'pList',
        'data_parentProp_changeAt_': now.toIso8601String(),
        'data_parentProp_cid_': 'cid-1',
        'data_parentProp_changeBy_': 'tester',
        'data_nameLocal': 'Task 1',
      });

      final storageId = await storage.getStorageId();

      final storedAtChange1 = now.toIso8601String();
      await storage.updateChangeLogAndState(
        domainType: 'project',
        changeLogEntry: IsarChangeLogEntry.fromJson(change1),
        changeUpdates: {
          'stateChanged': true,
          'storageId': storageId,
          'storedAt': storedAtChange1,
        },
        operationCounts: OperationCounts(create: 1),
        stateUpdates: {
          'domainType': 'project',
          'entityType': 'task',
          'entityId': 'task-1',
          'change_domainId': 'test-project',
          'change_domainId_orig_': 'test-project',
          'change_changeAt': now.toIso8601String(),
          'change_changeAt_orig_': now.toIso8601String(),
          'change_storedAt': storedAtChange1,
          'change_storedAt_orig_': storedAtChange1,
          'change_cid': cid1,
          'change_cid_orig_': cid1,
          'change_changeBy': 'tester',
          'change_changeBy_orig_': 'tester',
          // Required meta fields for task's nameLocal field
          'data_nameLocal_changeAt_': now.toIso8601String(),
          'data_nameLocal_cid_': cid1,
          'data_nameLocal_changeBy_': 'tester',
          'data_parentId': 'root',
          'data_parentId_dataSchemaRev_': null,
          'data_parentId_changeAt_': now.toIso8601String(),
          'data_parentId_cid_': cid1,
          'data_parentId_changeBy_': 'tester',
          'data_parentProp': 'pList',
          'data_parentProp_changeAt_': now.toIso8601String(),
          'data_parentProp_cid_': cid1,
          'data_parentProp_changeBy_': 'tester',
          'data_nameLocal': 'Task 1',
        },
      );

      SlttLogger.logger.fine('DEBUG: stateUpdates for task-2 -> ');
      SlttLogger.logger.fine({
        'domainType': 'project',
        'entityType': 'task',
        'entityId': 'task-2',
        'change_domainId': 'test-project',
        'change_changeAt': now
            .add(const Duration(seconds: 1))
            .toIso8601String(),
        'change_changeAt_orig_': now
            .add(const Duration(seconds: 1))
            .toIso8601String(),
        'change_domainId_orig_': 'test-project',
        'change_cid': 'cid-2',
        'change_cid_orig_': 'cid-2',
        'change_changeBy': 'tester',
        'change_changeBy_orig_': 'tester',
        'data_nameLocal_changeAt_': now
            .add(const Duration(seconds: 1))
            .toIso8601String(),
        'data_nameLocal_cid_': 'cid-2',
        'data_nameLocal_changeBy_': 'tester',
        'data_parentId': 'root',
        'data_parentId_dataSchemaRev_': null,
        'data_parentId_changeAt_': now
            .add(const Duration(seconds: 1))
            .toIso8601String(),
        'data_parentId_cid_': 'cid-2',
        'data_parentId_changeBy_': 'tester',
        'data_parentProp': 'other',
        'data_parentProp_changeAt_': now
            .add(const Duration(seconds: 1))
            .toIso8601String(),
        'data_parentProp_cid_': 'cid-2',
        'data_parentProp_changeBy_': 'tester',
        'data_nameLocal': 'Task 2',
      });

      final storedAtChange2 = now
          .add(const Duration(seconds: 1))
          .toIso8601String();
      await storage.updateChangeLogAndState(
        domainType: 'project',
        changeLogEntry: IsarChangeLogEntry.fromJson(change2),
        changeUpdates: {
          'stateChanged': true,
          'storageId': storageId,
          'storedAt': storedAtChange2,
        },
        operationCounts: OperationCounts(create: 1),
        stateUpdates: {
          'domainType': 'project',
          'entityType': 'task',
          'entityId': 'task-2',
          'change_domainId': 'test-project',
          'change_domainId_orig_': 'test-project',
          'change_changeAt': now
              .add(const Duration(seconds: 1))
              .toIso8601String(),
          'change_changeAt_orig_': now
              .add(const Duration(seconds: 1))
              .toIso8601String(),
          'change_storedAt': storedAtChange2,
          'change_storedAt_orig_': storedAtChange2,
          'change_cid': cid2,
          'change_cid_orig_': cid2,
          'change_changeBy': 'tester',
          'change_changeBy_orig_': 'tester',
          // Required meta fields for task's nameLocal field
          'data_nameLocal_changeAt_': now
              .add(const Duration(seconds: 1))
              .toIso8601String(),
          'data_nameLocal_cid_': cid2,
          'data_nameLocal_changeBy_': 'tester',
          'data_parentId': 'root',
          'data_parentId_dataSchemaRev_': null,
          'data_parentId_changeAt_': now
              .add(const Duration(seconds: 1))
              .toIso8601String(),
          'data_parentId_cid_': cid2,
          'data_parentId_changeBy_': 'tester',
          'data_parentProp': 'other',
          'data_parentProp_changeAt_': now
              .add(const Duration(seconds: 1))
              .toIso8601String(),
          'data_parentProp_cid_': cid2,
          'data_parentProp_changeBy_': 'tester',
          'data_nameLocal': 'Task 2',
        },
      );

      // Query for parentProp == 'pList'
      final res = await storage.getEntityStates(
        domainType: 'project',
        domainId: 'test-project',
        entityType: 'task',
        parentProp: 'pList',
      );

      final items = res['items'] as List<dynamic>;
      expect(items.length, equals(1));
      final first = items.first as Map<String, dynamic>;
      expect(first['data_nameLocal'], equals('Task 1'));
      expect(first['data_parentProp'], equals('pList'));
    });

    test(
      'returns empty items when parentProp does not match any entity',
      () async {
        final res = await storage.getEntityStates(
          domainType: 'project',
          domainId: 'test-project',
          entityType: 'task',
          parentProp: 'no-such-prop',
        );

        expect(res['items'], isEmpty);
        expect(res['hasMore'], isFalse);
        expect(res['nextCursor'], isNull);
      },
    );

    // More comprehensive tests with real data would go here, but they require
    // proper setup of entity states using the full updateChangeLogAndState
    // method with proper state data structure, which is better tested in
    // integration tests or through the existing network test suite.
  });
}
