import 'package:sltt_core/sltt_core.dart';
import 'package:sltt_core/src/services/change_processing_service.dart';
import 'package:test/test.dart';

import 'helpers/in_memory_storage.dart';
import 'test_models.dart';

void main() {
  group('ChangeProcessingService', () {
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
      storage = InMemoryStorage();
    });

    tearDown(() async {
      await storage.close();
    });

    test('returns error for empty changes list', () async {
      final result = await ChangeProcessingService.processChanges(
        changesToCreate: [],
        storage: storage,
        srcStorageType: 'none',
        srcStorageId: '',
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
}
