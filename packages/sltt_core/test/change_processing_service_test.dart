import 'dart:convert';

import 'package:sltt_core/sltt_core.dart';
import 'package:sltt_core/src/services/change_processing_service.dart';
import 'package:test/test.dart';

import 'helpers/in_memory_storage.dart';
import 'test_models.dart';

void main() {
  group('ChangeProcessingService - basic tests', () {
    late InMemoryStorage storage;

    setUpAll(() {
      // Register change-log entry factory group for tests
      registerChangeLogEntryFactoryGroup(
        FactoryGroup<BaseChangeLogEntry>(
          (json) => TestChangeLogEntry.fromJson(json),
          (entry) => (entry as TestChangeLogEntry).toJson(),
          (original) {
            // Produce a safe shape for TestChangeLogEntry
            final now = HlcTimestampGenerator.generate();
            return {
              'entityId': original['entityId'] ?? 'e-test',
              'entityType': original['entityType'] ?? 'project',
              'domainId':
                  original['domainId'] ?? original['projectId'] ?? 'p-test',
              'domainType': original['domainType'] ?? 'project',
              'changeAt': original['changeAt'] ?? now.toIso8601String(),
              'cid': original['cid'] ?? generateCid(now),
              'changeBy': original['changeBy'] ?? 'test-user',
              'storageId': original['storageId'] ?? 'test-storage',
              'operation': original['operation'] ?? 'update',
              'operationInfoJson': original['operationInfoJson'] ?? '{}',
              'stateChanged': original['stateChanged'] ?? false,
              'unknownJson': original['unknownJson'] ?? '{}',
              'dataJson': original['dataJson'] ?? '{}',
            };
          },
        ),
      );
    });

    setUp(() {
      storage = InMemoryStorage(storageType: 'local');
    });

    tearDown(() async {
      await storage.close();
    });

    test('returns error for empty changes list', () async {
      final result = await ChangeProcessingService.processChanges(
        changesToCreate: [],
        storage: storage,
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );

      expect(result.isError, isTrue);
      expect(result.errorCode, equals(400));
      expect(result.errorMessage, equals('No changes provided'));
    });

    test('processes single change successfully', () async {
      await storage.initialize();
      final baseTime = DateTime.parse('2023-01-01T00:00:00Z');

      final changeData = {
        'projectId': 'test-project',
        'domainId': 'test-project',
        'domainType': 'project',
        'entityType': 'task',
        'entityId': 'task-1',
        'changeBy': 'tester',
        'changeAt': baseTime.toUtc().toIso8601String(),
        'cid': generateCid(baseTime),
        'storageId': 'local',
        'operation': 'create',
        'operationInfoJson': '{}',
        'stateChanged': true,
        'unknownJson': '{}',
        'dataJson': '{"nameLocal": "Test Task", "parentId": "root"}',
      };

      final result = await ChangeProcessingService.processChanges(
        changesToCreate: [changeData],
        storage: storage,
        srcStorageType: 'local',
        srcStorageId: 'local',
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );

      expect(result.isSuccess, isTrue);

      final summary = result.resultsSummary!;
      expect(summary['storageType'], isNotEmpty);
      expect(summary['storageId'], equals(await storage.getStorageId()));
      expect(summary['created'], isA<List>());
      expect((summary['created'] as List).length, equals(1));
    });

    test('includes changeUpdates when requested', () async {
      await storage.initialize();
      final baseTime = DateTime.parse('2023-01-01T00:00:00Z');

      final changeData = {
        'projectId': 'test-project',
        'domainId': 'test-project',
        'domainType': 'project',
        'entityType': 'task',
        'entityId': 'task-change-updates',
        'changeBy': 'tester',
        'changeAt': baseTime.toUtc().toIso8601String(),
        'cid': generateCid(baseTime),
        'storageId': 'local',
        'operation': 'create',
        'operationInfoJson': '{}',
        'stateChanged': true,
        'unknownJson': '{}',
        'dataJson': '{"nameLocal": "Test Task", "parentId": "root"}',
      };

      final result = await ChangeProcessingService.processChanges(
        changesToCreate: [changeData],
        storage: storage,
        srcStorageType: 'local',
        srcStorageId: 'local',
        includeChangeUpdates: true,
        includeStateUpdates: false,
      );

      expect(result.isSuccess, isTrue);

      final summary = result.resultsSummary!;
      print('Summary keys: ${summary.keys}');
      print('changeUpdates: ${summary['changeUpdates']}');
      print('stateUpdates: ${summary['stateUpdates']}');
      print('created: ${summary['created']}');
      print('updated: ${summary['updated']}');
      print('errors: ${summary['errors']}');
      print('unprocessed: ${summary['unprocessed']}');

      expect(summary['changeUpdates'], isA<List>());
      expect((summary['changeUpdates'] as List).isNotEmpty, isTrue);
      expect(
        (summary['changeUpdates'] as List).first,
        containsPair('cid', isNotNull),
      );
      expect(
        (summary['changeUpdates'] as List).first,
        containsPair('updates', isNotNull),
      );

      // When includeStateUpdates is false, stateUpdates should be empty
      expect(summary['stateUpdates'], isA<List>());
      expect((summary['stateUpdates'] as List).isEmpty, isTrue);
    });

    test('includes stateUpdates when requested', () async {
      await storage.initialize();
      final baseTime = DateTime.parse('2023-01-01T00:00:00Z');

      final changeData = {
        'projectId': 'test-project',
        'domainId': 'test-project',
        'domainType': 'project',
        'entityType': 'task',
        'entityId': 'task-state-updates',
        'changeBy': 'tester',
        'changeAt': baseTime.toUtc().toIso8601String(),
        'cid': generateCid(baseTime),
        'storageId': 'local',
        'operation': 'create',
        'operationInfoJson': '{}',
        'stateChanged': true,
        'unknownJson': '{}',
        'dataJson': '{"nameLocal": "Test Task", "parentId": "root"}',
      };

      final result = await ChangeProcessingService.processChanges(
        changesToCreate: [changeData],
        storage: storage,
        srcStorageType: 'local',
        srcStorageId: 'local',
        includeChangeUpdates: false,
        includeStateUpdates: true,
      );

      expect(result.isSuccess, isTrue);

      final summary = result.resultsSummary!;
      expect(summary['stateUpdates'], isA<List>());
      expect((summary['stateUpdates'] as List).isNotEmpty, isTrue);
      expect(
        (summary['stateUpdates'] as List).first,
        containsPair('cid', isNotNull),
      );
      expect(
        (summary['stateUpdates'] as List).first,
        containsPair('state', isNotNull),
      );

      // When includeChangeUpdates is false, changeUpdates should be empty
      expect(summary['changeUpdates'], isA<List>());
      expect((summary['changeUpdates'] as List).isEmpty, isTrue);
    });

    test('processes multiple changes correctly', () async {
      await storage.initialize();
      final baseTime = DateTime.parse('2023-01-01T00:00:00Z');

      final changesData = [
        {
          'projectId': 'test-project',
          'domainId': 'test-project',
          'domainType': 'project',
          'entityType': 'task',
          'entityId': 'task-multi-1',
          'changeBy': 'tester',
          'changeAt': baseTime.toUtc().toIso8601String(),
          'cid': generateCid(baseTime),
          'storageId': 'local',
          'operation': 'create',
          'operationInfoJson': '{}',
          'stateChanged': true,
          'unknownJson': '{}',
          'dataJson': '{"nameLocal": "Task 1", "parentId": "root"}',
        },
        {
          'projectId': 'test-project',
          'domainId': 'test-project',
          'domainType': 'project',
          'entityType': 'task',
          'entityId': 'task-multi-2',
          'changeBy': 'tester',
          'changeAt': baseTime
              .add(const Duration(minutes: 1))
              .toUtc()
              .toIso8601String(),
          'cid': generateCid(baseTime.add(const Duration(minutes: 1))),
          'storageId': 'local',
          'operation': 'create',
          'operationInfoJson': '{}',
          'stateChanged': true,
          'unknownJson': '{}',
          'dataJson': '{"nameLocal": "Task 2", "parentId": "root"}',
        },
      ];

      final result = await ChangeProcessingService.processChanges(
        changesToCreate: changesData,
        storage: storage,
        srcStorageType: 'local',
        srcStorageId: 'local',
        includeChangeUpdates: true,
        includeStateUpdates: true,
      );

      expect(result.isSuccess, isTrue);

      final summary = result.resultsSummary!;
      expect(summary['changeUpdates'], isA<List>());
      expect((summary['changeUpdates'] as List).length, equals(2));
      expect(summary['stateUpdates'], isA<List>());
      expect((summary['stateUpdates'] as List).length, equals(2));
      expect(summary['created'], isA<List>());
      expect((summary['created'] as List).length, equals(2));
    });
  });

  group('ChangeProcessingService - api_changes_network_tests', () {
    late InMemoryStorage svcStorage;

    setUp(() {
      svcStorage = InMemoryStorage(storageType: 'local');
    });

    tearDown(() async {
      await svcStorage.close();
    });

    Map<String, dynamic> changePayload({
      required String projectId,
      required String entityType,
      required String entityId,
      required DateTime changeAt,
      String storageId = 'local',
      Map<String, dynamic> data = const <String, dynamic>{},
      String operation = 'update',
      bool addDefaultParentId = true,
    }) {
      final adjustedData = Map<String, dynamic>.from(data);
      if (addDefaultParentId &&
          operation != 'delete' &&
          !adjustedData.containsKey('parentId')) {
        adjustedData['parentId'] = 'root';
      }
      final namespacedEntityId = '$projectId-$entityId';
      final namespacedCid = '$projectId-${generateCid(changeAt)}';
      return {
        'projectId': projectId,
        'domainId': projectId,
        'domainType': 'project',
        'entityType': entityType,
        'entityId': namespacedEntityId,
        'changeBy': 'tester',
        'changeAt': changeAt.toUtc().toIso8601String(),
        'cid': namespacedCid,
        'storageId': storageId,
        'operation': operation,
        'operationInfoJson': '{}',
        'stateChanged': false,
        'unknownJson': '{}',
        'dataJson': jsonEncode(adjustedData),
      };
    }

    test(
      'POST /api/changes with includeChangeUpdates/includeStateUpdates returns summaries',
      () async {
        await svcStorage.initialize();
        final now = DateTime.now().toUtc();
        final payload = [
          changePayload(
            projectId: 'proj-1',
            entityType: 'project',
            entityId: 'entity-1',
            changeAt: now,
            storageId: 'local',
            operation: 'update',
            data: {'nameLocal': 'Core API Net Test', 'parentId': 'root'},
          ),
        ];

        final result = await ChangeProcessingService.processChanges(
          changesToCreate: payload,
          storage: svcStorage,
          srcStorageType: 'local',
          srcStorageId: 'local',
          includeChangeUpdates: true,
          includeStateUpdates: true,
        );

        expect(result.isSuccess, isTrue);
        final summary = result.resultsSummary!;
        expect(summary['storageType'], isNotEmpty);
        expect(summary['storageId'], isNotEmpty);
        expect(summary['changeUpdates'], isA<List>());
        expect(summary['stateUpdates'], isA<List>());
        expect((summary['changeUpdates'] as List).first, contains('cid'));
        expect((summary['stateUpdates'] as List).first, contains('cid'));
      },
    );

    test(
      'handles field-level conflict resolution (newer change wins)',
      () async {
        await svcStorage.initialize();
        final baseTime = DateTime.parse('2023-01-01T00:00:00Z');

        final project = 'proj-fl';
        final entity = 'entity-fl-1';

        // seed initial change
        final seed = changePayload(
          projectId: project,
          entityType: 'task',
          entityId: entity,
          changeAt: baseTime,
          data: {'rank': '1', 'nameLocal': 'Test Task'},
        );

        final seedRes = await ChangeProcessingService.processChanges(
          changesToCreate: [seed],
          storage: svcStorage,
          srcStorageType: 'local',
          srcStorageId: 'local',
          includeChangeUpdates: false,
          includeStateUpdates: false,
        );
        expect(seedRes.isSuccess, isTrue);

        final newer = baseTime.add(const Duration(minutes: 5));
        final resp = await ChangeProcessingService.processChanges(
          changesToCreate: [
            changePayload(
              projectId: project,
              entityType: 'task',
              entityId: entity,
              changeAt: newer,
              data: {'rank': '2'},
              addDefaultParentId: false,
            ),
          ],
          storage: svcStorage,
          srcStorageType: 'local',
          srcStorageId: 'local',
          includeChangeUpdates: true,
          includeStateUpdates: true,
        );

        expect(resp.isSuccess, isTrue);
        final summary = resp.resultsSummary!;
        final cu =
            (summary['changeUpdates'] as List).first['updates']
                as Map<String, dynamic>;
        final su =
            (summary['stateUpdates'] as List).first['state']
                as Map<String, dynamic>;

        expect(cu['operation'], 'update');
        expect(
          cu['operationInfoJson'],
          equals(jsonEncode({'outdatedBys': [], 'noOpFields': []})),
        );
        expect(cu['stateChanged'], isTrue);
        expect(cu['dataJson'], jsonEncode({'rank': '2'}));
        expect(su['data_rank'], '2');
        expect(su['data_rank_changeAt_'], newer.toUtc().toIso8601String());
      },
    );

    test(
      'POST srcStorageType/srcStorageId combinations behave as expected',
      () async {
        await svcStorage.initialize();
        final baseTime = DateTime.parse('2023-01-01T00:00:00Z');

        final serverStorageId = await svcStorage.getStorageId();

        // local + matching serverStorageId
        final p2 = changePayload(
          projectId: 'test-src-local-match',
          entityType: 'project',
          entityId: 'entity-1',
          changeAt: baseTime,
        );
        final r2 = await ChangeProcessingService.processChanges(
          changesToCreate: [p2],
          storage: svcStorage,
          srcStorageType: 'local',
          srcStorageId: serverStorageId,
          includeChangeUpdates: true,
          includeStateUpdates: true,
        );
        expect(r2.isSuccess, isTrue);
        expect(r2.resultsSummary!['storageId'], equals(serverStorageId));

        // cloud src (srcStorageId provided as cloud identifier)
        final p3 = changePayload(
          projectId: 'test-src-cloud',
          entityType: 'project',
          entityId: 'entity-1',
          changeAt: baseTime,
        );
        final r3 = await ChangeProcessingService.processChanges(
          changesToCreate: [p3],
          storage: svcStorage,
          srcStorageType: 'cloud',
          srcStorageId: 'cloud',
          includeChangeUpdates: true,
          includeStateUpdates: true,
        );
        expect(r3.isSuccess, isTrue);
        expect(r3.resultsSummary!['storageId'], equals(serverStorageId));
      },
    );
  });
}
