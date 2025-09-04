import 'dart:convert';

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
        SerializableGroup<BaseChangeLogEntry>(
          (json) => TestChangeLogEntry.fromJson(json),
          (json) => TestChangeLogEntry.fromJsonBase(json),
          (entry) => (entry as TestChangeLogEntry).toJson(),
          (entry) => (entry as TestChangeLogEntry).toJsonBase(),
          (original) {
            // Produce a safe shape for TestChangeLogEntry
            final now = HlcTimestampGenerator.generate();
            return {
              'entityId': original['entityId'] ?? 'e-test',
              'entityType': original['entityType'] ?? 'project',
              'domainId': original['domainId'] ?? 'p-test',
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

    group('- basic tests', () {
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
          storageMode: 'save',
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
          'domainId': 'test-project',
          'domainType': 'project',
          'entityType': 'task',
          'entityId': 'task-1',
          'changeBy': 'tester',
          'changeAt': baseTime.toUtc().toIso8601String(),
          'cid': generateCid(baseTime),
          'storageId': '', // Empty for save mode
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
          storageMode: 'save',
          includeChangeUpdates: false,
          includeStateUpdates: false,
        );

        expect(
          result.isSuccess,
          isTrue,
          reason:
              'processChanges failed: ${result.errorMessage ?? "Unknown error"}',
        );

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
          'domainId': 'test-project',
          'domainType': 'project',
          'entityType': 'task',
          'entityId': 'task-change-updates',
          'changeBy': 'tester',
          'changeAt': baseTime.toUtc().toIso8601String(),
          'cid': generateCid(baseTime),
          'storageId': '', // Empty for save mode
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
          storageMode: 'save',
          includeChangeUpdates: true,
          includeStateUpdates: false,
        );

        expect(
          result.isSuccess,
          isTrue,
          reason:
              'processChanges failed: ${result.errorMessage ?? "Unknown error"}',
        );

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
          'domainId': 'test-project',
          'domainType': 'project',
          'entityType': 'task',
          'entityId': 'task-state-updates',
          'changeBy': 'tester',
          'changeAt': baseTime.toUtc().toIso8601String(),
          'cid': generateCid(baseTime),
          'storageId': '', // Empty for save mode
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
          storageMode: 'save',
          includeChangeUpdates: false,
          includeStateUpdates: true,
        );

        expect(
          result.isSuccess,
          isTrue,
          reason:
              'processChanges failed: ${result.errorMessage ?? "Unknown error"}',
        );

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
            'domainId': 'test-project',
            'domainType': 'project',
            'entityType': 'task',
            'entityId': 'task-multi-1',
            'changeBy': 'tester',
            'changeAt': baseTime.toUtc().toIso8601String(),
            'cid': generateCid(baseTime),
            'storageId': '', // Empty for save mode
            'operation': 'create',
            'operationInfoJson': '{}',
            'stateChanged': true,
            'unknownJson': '{}',
            'dataJson': '{"nameLocal": "Task 1", "parentId": "root"}',
          },
          {
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
            'storageId': '', // Empty for save mode
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
          storageMode: 'save',
          includeChangeUpdates: true,
          includeStateUpdates: true,
        );

        expect(
          result.isSuccess,
          isTrue,
          reason:
              'processChanges failed: ${result.errorMessage ?? "Unknown error"}',
        );

        final summary = result.resultsSummary!;
        expect(summary['changeUpdates'], isA<List>());
        expect((summary['changeUpdates'] as List).length, equals(2));
        expect(summary['stateUpdates'], isA<List>());
        expect((summary['stateUpdates'] as List).length, equals(2));
        expect(summary['created'], isA<List>());
        expect((summary['created'] as List).length, equals(2));
      });
    });

    group('- api_changes_network_tests', () {
      late InMemoryStorage svcStorage;

      setUp(() {
        svcStorage = InMemoryStorage(storageType: 'local');
      });

      tearDown(() async {
        await svcStorage.close();
      });

      Map<String, dynamic> changePayload({
        required String domainId,
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
        final namespacedEntityId = '$domainId-$entityId';
        final namespacedCid = '$domainId-${generateCid(changeAt)}';
        return {
          'domainId': domainId,
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
              domainId: 'proj-1',
              entityType: 'project',
              entityId: 'entity-1',
              changeAt: now,
              storageId: '', // Empty for save mode
              operation: 'update',
              data: {'nameLocal': 'Core API Net Test', 'parentId': 'root'},
            ),
          ];

          final result = await ChangeProcessingService.processChanges(
            changesToCreate: payload,
            storage: svcStorage,
            srcStorageType: 'local',
            srcStorageId: 'local',
            storageMode: 'save',
            includeChangeUpdates: true,
            includeStateUpdates: true,
          );

          expect(
            result.isSuccess,
            isTrue,
            reason:
                'processChanges failed: ${result.errorMessage ?? "Unknown error"}',
          );
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
            domainId: project,
            entityType: 'task',
            entityId: entity,
            changeAt: baseTime,
            storageId: '', // Empty for save mode
            data: {'rank': '1', 'nameLocal': 'Test Task'},
          );

          final seedRes = await ChangeProcessingService.processChanges(
            changesToCreate: [seed],
            storage: svcStorage,
            srcStorageType: 'local',
            srcStorageId: 'local',
            storageMode: 'save',
            includeChangeUpdates: false,
            includeStateUpdates: false,
          );
          expect(
            seedRes.isSuccess,
            isTrue,
            reason:
                'Seed processChanges failed: ${seedRes.errorMessage ?? "Unknown error"}',
          );

          final newer = baseTime.add(const Duration(minutes: 5));
          final resp = await ChangeProcessingService.processChanges(
            changesToCreate: [
              changePayload(
                domainId: project,
                entityType: 'task',
                entityId: entity,
                changeAt: newer,
                storageId: '', // Empty for save mode
                data: {'rank': '2'},
                addDefaultParentId: false,
              ),
            ],
            storage: svcStorage,
            srcStorageType: 'local',
            srcStorageId: 'local',
            storageMode: 'save',
            includeChangeUpdates: true,
            includeStateUpdates: true,
          );

          expect(
            resp.isSuccess,
            isTrue,
            reason:
                'processChanges failed: ${resp.errorMessage ?? "Unknown error"}',
          );
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
            domainId: 'test-src-local-match',
            entityType: 'project',
            entityId: 'entity-1',
            changeAt: baseTime,
            storageId: '', // Empty for save mode
          );
          final r2 = await ChangeProcessingService.processChanges(
            changesToCreate: [p2],
            storage: svcStorage,
            srcStorageType: 'local',
            srcStorageId: serverStorageId,
            storageMode: 'save',
            includeChangeUpdates: true,
            includeStateUpdates: true,
          );
          expect(
            r2.isSuccess,
            isTrue,
            reason:
                'r2 processChanges failed: ${r2.errorMessage ?? "Unknown error"}',
          );
          expect(r2.resultsSummary!['storageId'], equals(serverStorageId));

          // cloud src (srcStorageId provided as cloud identifier)
          final p3 = changePayload(
            domainId: 'test-src-cloud',
            entityType: 'project',
            entityId: 'entity-1',
            changeAt: baseTime,
          );
          final r3 = await ChangeProcessingService.processChanges(
            changesToCreate: [p3],
            storage: svcStorage,
            srcStorageType: 'cloud',
            srcStorageId: 'cloud',
            storageMode: 'sync',
            includeChangeUpdates: true,
            includeStateUpdates: true,
          );
          expect(
            r3.isSuccess,
            isTrue,
            reason:
                'r3 processChanges failed: ${r3.errorMessage ?? "Unknown error"}',
          );
          expect(r3.resultsSummary!['storageId'], equals(serverStorageId));
        },
      );
    });

    group('- Storage Type Behaviors', () {
      late InMemoryStorage cloudStorage;
      late InMemoryStorage localStorage;

      setUp(() async {
        cloudStorage = InMemoryStorage(storageType: 'cloud');
        localStorage = InMemoryStorage(storageType: 'local');
        await cloudStorage.initialize();
        await localStorage.initialize();
      });

      tearDown(() async {
        await cloudStorage.close();
        await localStorage.close();
      });

      group('Cloud Storage Tests', () {
        test('save mode - should store change log entry and state', () async {
          // use the static API directly; ChangeProcessingService is static-only

          final changeData = {
            'domainId': 'test-project',
            'domainType': 'project',
            'entityType': 'project',
            'entityId': 'entity-1',
            'changeBy': 'user1',
            'changeAt': DateTime.now().toUtc().toIso8601String(),
            'cid': generateCid(DateTime.now().toUtc()),
            'storageId': '', // Empty for save mode
            'operation': 'create',
            'operationInfoJson': '{}',
            'stateChanged': true,
            'unknownJson': '{}',
            'dataJson': '{"nameLocal": "Test Project", "parentId": "root"}',
          };

          final result = await ChangeProcessingService.processChanges(
            changesToCreate: [changeData],
            storage: cloudStorage,
            storageMode: 'save',
            srcStorageType: 'local',
            srcStorageId: 'test-src',
            includeChangeUpdates: false,
            includeStateUpdates: false,
          );

          expect(
            result.isSuccess,
            isTrue,
            reason: 'Save mode should succeed: ${result.errorMessage}',
          );

          // Verify change log entry was stored
          final changes = await cloudStorage.getChangesWithCursor(
            domainId: 'test-project',
          );
          expect(
            changes.length,
            equals(1),
            reason: 'Cloud storage should store change log entry in save mode',
          );

          // Verify state was updated
          final state = await cloudStorage.getCurrentEntityState(
            'test-project',
            'project',
            'entity-1',
          );
          expect(
            state,
            isNotNull,
            reason: 'Cloud storage should store state in save mode',
          );
        });

        test('sync mode - should store change log entry and state', () async {
          // use the static API directly; ChangeProcessingService is static-only

          final changeData = {
            'domainId': 'test-project',
            'domainType': 'project',
            'entityType': 'project',
            'entityId': 'entity-2',
            'changeBy': 'user1',
            'changeAt': DateTime.now().toUtc().toIso8601String(),
            'cid': generateCid(DateTime.now().toUtc()),
            'storageId': 'remote-storage-id', // Non-empty for sync mode
            'operation': 'create',
            'operationInfoJson': '{}',
            'stateChanged': true,
            'unknownJson': '{}',
            'dataJson': '{"nameLocal": "Sync Project", "parentId": "root"}',
          };

          final result = await ChangeProcessingService.processChanges(
            changesToCreate: [changeData],
            storage: cloudStorage,
            storageMode: 'sync',
            srcStorageType: 'local',
            srcStorageId: 'test-src',
            includeChangeUpdates: false,
            includeStateUpdates: false,
          );

          expect(
            result.isSuccess,
            isTrue,
            reason: 'Sync mode should succeed: ${result.errorMessage}',
          );

          // Verify change log entry was stored
          final changes = await cloudStorage.getChangesWithCursor(
            domainId: 'test-project',
          );
          expect(
            changes.length,
            equals(1),
            reason: 'Cloud storage should store change log entry in sync mode',
          );

          // Verify state was updated
          final state = await cloudStorage.getCurrentEntityState(
            'test-project',
            'project',
            'entity-2',
          );
          expect(
            state,
            isNotNull,
            reason: 'Cloud storage should store state in sync mode',
          );
        });

        test('sync mode - should handle state updates correctly', () async {
          // use the static API directly; ChangeProcessingService is static-only

          // First, create an entity
          final createData = {
            'domainId': 'test-project',
            'domainType': 'project',
            'entityType': 'project',
            'entityId': 'entity-3',
            'changeBy': 'user1',
            'changeAt': DateTime.now().toUtc().toIso8601String(),
            'cid': generateCid(DateTime.now().toUtc()),
            'storageId': '',
            'operation': 'create',
            'operationInfoJson': '{}',
            'stateChanged': true,
            'unknownJson': '{}',
            'dataJson': '{"nameLocal": "Original Name", "parentId": "root"}',
          };

          await ChangeProcessingService.processChanges(
            changesToCreate: [createData],
            storage: cloudStorage,
            storageMode: 'save',
            srcStorageType: 'local',
            srcStorageId: 'test-src',
            includeChangeUpdates: false,
            includeStateUpdates: false,
          );

          // Then, sync an update
          final updateData = {
            'domainId': 'test-project',
            'domainType': 'project',
            'entityType': 'project',
            'entityId': 'entity-3',
            'changeBy': 'user2',
            'changeAt': DateTime.now()
                .add(const Duration(minutes: 1))
                .toUtc()
                .toIso8601String(),
            'cid': generateCid(
              DateTime.now().add(const Duration(minutes: 1)).toUtc(),
            ),
            'storageId': 'remote-storage-id',
            'operation': 'update',
            'operationInfoJson': '{}',
            'stateChanged': true,
            'unknownJson': '{}',
            'dataJson': '{"nameLocal": "Updated Name", "parentId": "root"}',
          };

          final result = await ChangeProcessingService.processChanges(
            changesToCreate: [updateData],
            storage: cloudStorage,
            storageMode: 'sync',
            srcStorageType: 'local',
            srcStorageId: 'test-src',
            includeChangeUpdates: false,
            includeStateUpdates: false,
          );

          expect(
            result.isSuccess,
            isTrue,
            reason: 'Sync update should succeed: ${result.errorMessage}',
          );

          // Verify both change log entries exist
          final changes = await cloudStorage.getChangesWithCursor(
            domainId: 'test-project',
          );
          expect(
            changes.length,
            equals(2),
            reason: 'Cloud storage should have both change log entries',
          );

          // Verify final state reflects the update
          final state = await cloudStorage.getCurrentEntityState(
            'test-project',
            'project',
            'entity-3',
          );
          expect(state, isNotNull);
          expect(
            state!.toJson()['data_nameLocal'],
            equals('Updated Name'),
            reason:
                'Cloud storage state should reflect the update in sync mode',
          );
        });

        test('save mode - should reject changes with unknownJson - 1', () async {
          // Test that cloud storage in save mode rejects changes with unknownJson

          final changeData = {
            'domainId': 'test-project',
            'domainType': 'project',
            'entityType': 'project',
            'entityId': 'entity-unknown',
            'changeBy': 'user1',
            'changeAt': DateTime.now().toUtc().toIso8601String(),
            'cid': generateCid(DateTime.now().toUtc()),
            'storageId': '', // Empty for save mode
            'operation': 'create',
            'operationInfoJson': '{}',
            'stateChanged': true,
            'unknownField':
                'should be rejected', // This should become unknownJson during deserialization
            'dataJson': '{"nameLocal": "Test Project", "parentId": "root"}',
          };

          final storageType = cloudStorage.getStorageType();
          final result = await ChangeProcessingService.processChanges(
            changesToCreate: [changeData],
            storage: cloudStorage,
            storageMode: 'save',
            srcStorageType: 'local',
            srcStorageId: 'test-src',
            includeChangeUpdates: false,
            includeStateUpdates: false,
          );

          print(
            'Test result: isError=${result.isError}, errorMessage=${result.errorMessage}',
          );
          print('Storage type: ${cloudStorage.getStorageType()}');
          print('Results summary: ${result.resultsSummary}');

          // The validation should either return an error result or add errors to the summary
          expect(result.isError, isTrue);
          expect(result.errorCode, equals(400));
          expect(
            result.errorMessage,
            contains('contains unknown fields in ($storageType) storage with save mode'),
          );
          expect(result.errorMessage, contains('unknownField'));
        });

        test('save mode - should reject changes with unknownJson - 2', () async {
          // Test that cloud storage in save mode rejects changes with unknownJson

          final changeData = {
            'domainId': 'test-project',
            'domainType': 'project',
            'entityType': 'project',
            'entityId': 'entity-unknown',
            'changeBy': 'user1',
            'changeAt': DateTime.now().toUtc().toIso8601String(),
            'cid': generateCid(DateTime.now().toUtc()),
            'storageId': '', // Empty for save mode
            'operation': 'create',
            'operationInfoJson': '{}',
            'stateChanged': true,
            'unknownJson': '{"unknownField": "should be rejected"}',
            'dataJson': '{"nameLocal": "Test Project", "parentId": "root"}',
          };

          final storageType = cloudStorage.getStorageType();
          final result = await ChangeProcessingService.processChanges(
            changesToCreate: [changeData],
            storage: cloudStorage,
            storageMode: 'save',
            srcStorageType: 'local',
            srcStorageId: 'test-src',
            includeChangeUpdates: false,
            includeStateUpdates: false,
          );

          print(
            'Test result: isError=${result.isError}, errorMessage=${result.errorMessage}',
          );
          print('Storage type: ${cloudStorage.getStorageType()}');
          print('Results summary: ${result.resultsSummary}');

          // The validation should either return an error result or add errors to the summary
          expect(result.isError, isTrue);
          expect(result.errorCode, equals(400));
          expect(
            result.errorMessage,
            contains('contains unknown fields in ($storageType) storage'),
          );
          expect(result.errorMessage, contains('unknownField'));
        });
      });

      group('Local Storage Tests', () {
        test('save mode - should store change log entry and state', () async {
          // use the static API directly; ChangeProcessingService is static-only

          final changeData = {
            'domainId': 'test-project',
            'domainType': 'project',
            'entityType': 'project',
            'entityId': 'entity-4',
            'changeBy': 'user1',
            'changeAt': DateTime.now().toUtc().toIso8601String(),
            'cid': generateCid(DateTime.now().toUtc()),
            'storageId': '', // Empty for save mode
            'operation': 'create',
            'operationInfoJson': '{}',
            'stateChanged': true,
            'unknownJson': '{}',
            'dataJson': '{"nameLocal": "Local Project", "parentId": "root"}',
          };

          final result = await ChangeProcessingService.processChanges(
            changesToCreate: [changeData],
            storage: localStorage,
            storageMode: 'save',
            srcStorageType: 'local',
            srcStorageId: 'test-src',
            includeChangeUpdates: false,
            includeStateUpdates: false,
          );

          expect(
            result.isSuccess,
            isTrue,
            reason: 'Save mode should succeed: ${result.errorMessage}',
          );

          // Verify change log entry was stored
          final changes = await localStorage.getChangesWithCursor(
            domainId: 'test-project',
          );
          expect(
            changes.length,
            equals(1),
            reason: 'Local storage should store change log entry in save mode',
          );

          // Verify state was updated
          final state = await localStorage.getCurrentEntityState(
            'test-project',
            'project',
            'entity-4',
          );
          expect(
            state,
            isNotNull,
            reason: 'Local storage should store state in save mode',
          );
        });

        test(
          'sync mode - should store change log entry and state (current implementation)',
          () async {
            // use the static API directly; ChangeProcessingService is static-only

            final changeData = {
              'domainId': 'test-project',
              'domainType': 'project',
              'entityType': 'project',
              'entityId': 'entity-5',
              'changeBy': 'user1',
              'changeAt': DateTime.now().toUtc().toIso8601String(),
              'cid': generateCid(DateTime.now().toUtc()),
              'storageId': 'remote-storage-id', // Non-empty for sync mode
              'operation': 'create',
              'operationInfoJson': '{}',
              'stateChanged': true,
              'unknownJson': '{}',
              'dataJson':
                  '{"nameLocal": "Sync Local Project", "parentId": "root"}',
            };

            final result = await ChangeProcessingService.processChanges(
              changesToCreate: [changeData],
              storage: localStorage,
              storageMode: 'sync',
              srcStorageType: 'cloud',
              srcStorageId: 'test-src',
              includeChangeUpdates: false,
              includeStateUpdates: false,
            );

            expect(
              result.isSuccess,
              isTrue,
              reason: 'Sync mode should succeed: ${result.errorMessage}',
            );

            // NOTE: Current implementation stores change log entry in local storage for sync mode
            // TODO: According to requirements, local storage in sync mode should typically
            // only update state (unless hosting team storage)
            final changes = await localStorage.getChangesWithCursor(
              domainId: 'test-project',
            );
            expect(
              changes.length,
              equals(1),
              reason:
                  'Current implementation: Local storage stores change log entry in sync mode',
            );

            // Verify state was updated
            final state = await localStorage.getCurrentEntityState(
              'test-project',
              'project',
              'entity-5',
            );
            expect(
              state,
              isNotNull,
              reason: 'Local storage should always store state in sync mode',
            );
          },
        );

        test('save mode - should reject changes with unknownJson - 1', () async {
          // Test that local storage in save mode rejects changes with unknownJson

          final changeData = {
            'domainId': 'test-project',
            'domainType': 'project',
            'entityType': 'project',
            'entityId': 'entity-unknown',
            'changeBy': 'user1',
            'changeAt': DateTime.now().toUtc().toIso8601String(),
            'cid': generateCid(DateTime.now().toUtc()),
            'storageId': '', // Empty for save mode
            'operation': 'create',
            'operationInfoJson': '{}',
            'stateChanged': true,
            'unknownField':
                'should be rejected', // This should become unknownJson during deserialization
            'dataJson': '{"nameLocal": "Test Project", "parentId": "root"}',
          };
          final storageType = localStorage.getStorageType();
          final result = await ChangeProcessingService.processChanges(
            changesToCreate: [changeData],
            storage: localStorage,
            storageMode: 'save',
            srcStorageType: 'local',
            srcStorageId: 'test-src',
            includeChangeUpdates: false,
            includeStateUpdates: false,
          );

          print(
            'Test result: isError=${result.isError}, errorMessage=${result.errorMessage}',
          );
          print('Storage type: $storageType');
          print('Results summary: ${result.resultsSummary}');

          // The validation should either return an error result or add errors to the summary
          expect(result.isError, isTrue);
          expect(result.errorCode, equals(400));
          expect(
            result.errorMessage,
            contains('contains unknown fields in ($storageType) storage'),
          );
          expect(result.errorMessage, contains('unknownField'));
        });

        test('save mode - should reject changes with unknownJson - 2', () async {
          // Test that local storage in save mode rejects changes with unknownJson

          final changeData = {
            'domainId': 'test-project',
            'domainType': 'project',
            'entityType': 'project',
            'entityId': 'entity-unknown',
            'changeBy': 'user1',
            'changeAt': DateTime.now().toUtc().toIso8601String(),
            'cid': generateCid(DateTime.now().toUtc()),
            'storageId': '', // Empty for save mode
            'operation': 'create',
            'operationInfoJson': '{}',
            'stateChanged': true,
            'unknownJson': '{"unknownField": "should be rejected"}',
            'dataJson': '{"nameLocal": "Test Project", "parentId": "root"}',
          };

          final storageType = localStorage.getStorageType();
          final result = await ChangeProcessingService.processChanges(
            changesToCreate: [changeData],
            storage: localStorage,
            storageMode: 'save',
            srcStorageType: 'local',
            srcStorageId: 'test-src',
            includeChangeUpdates: false,
            includeStateUpdates: false,
          );

          print(
            'Test result: isError=${result.isError}, errorMessage=${result.errorMessage}',
          );
          print('Storage type: $storageType');
          print('Results summary: ${result.resultsSummary}');

          // The validation should either return an error result or add errors to the summary
          expect(result.isError, isTrue);
          expect(result.errorCode, equals(400));
          expect(
            result.errorMessage,
            contains('contains unknown fields in ($storageType) storage'),
          );
          expect(result.errorMessage, contains('unknownField'));
        });
      });

      test(
        'sync mode - should handle state-only updates correctly (future implementation)',
        () async {
          // This test documents the expected future behavior where local storage
          // in sync mode typically only updates state, not change log

          // First, create an entity in save mode (should store change log)
          final createData = {
            'domainId': 'test-project',
            'domainType': 'project',
            'entityType': 'project',
            'entityId': 'entity-6',
            'changeBy': 'user1',
            'changeAt': DateTime.now().toUtc().toIso8601String(),
            'cid': generateCid(DateTime.now().toUtc()),
            'storageId': '',
            'operation': 'create',
            'operationInfoJson': '{}',
            'stateChanged': true,
            'unknownJson': '{}',
            'dataJson': '{"nameLocal": "Original Local", "parentId": "root"}',
          };

          await ChangeProcessingService.processChanges(
            changesToCreate: [createData],
            storage: localStorage,
            storageMode: 'save',
            srcStorageType: 'local',
            srcStorageId: 'test-src',
            includeChangeUpdates: false,
            includeStateUpdates: false,
          );

          // Then, sync an update from cloud (should update state, current impl also stores change log)
          final updateData = {
            'domainId': 'test-project',
            'domainType': 'project',
            'entityType': 'project',
            'entityId': 'entity-6',
            'changeBy': 'user2',
            'changeAt': DateTime.now()
                .add(const Duration(minutes: 1))
                .toUtc()
                .toIso8601String(),
            'cid': generateCid(
              DateTime.now().add(const Duration(minutes: 1)).toUtc(),
            ),
            'storageId': 'cloud-storage-id',
            'operation': 'update',
            'operationInfoJson': '{}',
            'stateChanged': true,
            'unknownJson': '{}',
            'dataJson':
                '{"nameLocal": "Updated from Cloud", "parentId": "root"}',
          };

          final result = await ChangeProcessingService.processChanges(
            changesToCreate: [updateData],
            storage: localStorage,
            storageMode: 'sync',
            srcStorageType: 'cloud',
            srcStorageId: 'test-src',
            includeChangeUpdates: false,
            includeStateUpdates: false,
          );

          expect(
            result.isSuccess,
            isTrue,
            reason: 'Sync update should succeed: ${result.errorMessage}',
          );

          // Current implementation: Both change log entries are stored
          final changes = await localStorage.getChangesWithCursor(
            domainId: 'test-project',
          );
          expect(
            changes.length,
            equals(2),
            reason:
                'Current implementation: Local storage stores all change log entries',
          );

          // State should always be updated regardless of mode
          final state = await localStorage.getCurrentEntityState(
            'test-project',
            'project',
            'entity-6',
          );
          expect(state, isNotNull);
          expect(
            state!.toJson()['data_nameLocal'],
            equals('Updated from Cloud'),
            reason: 'Local storage state should always be updated in sync mode',
          );
        },
      );

      group('Cross-Storage Type Comparisons', () {
        test(
          'save mode - both storage types should behave identically',
          () async {
            // use the static API directly; ChangeProcessingService is static-only

            final baseTime = DateTime.now().toUtc();

            // Process same change in both storage types
            final changeData = {
              'domainId': 'test-project',
              'domainType': 'project',
              'entityType': 'project',
              'entityId': 'entity-cross',
              'changeBy': 'user1',
              'changeAt': baseTime.toIso8601String(),
              'cid': generateCid(baseTime),
              'storageId': '', // Empty for save mode
              'operation': 'create',
              'operationInfoJson': '{}',
              'stateChanged': true,
              'unknownJson': '{}',
              'dataJson':
                  '{"nameLocal": "Cross Storage Test", "parentId": "root"}',
            };

            final cloudResult = await ChangeProcessingService.processChanges(
              changesToCreate: [changeData],
              storage: cloudStorage,
              storageMode: 'save',
              srcStorageType: 'local',
              srcStorageId: 'test-src',
              includeChangeUpdates: false,
              includeStateUpdates: false,
            );

            final localResult = await ChangeProcessingService.processChanges(
              changesToCreate: [changeData],
              storage: localStorage,
              storageMode: 'save',
              srcStorageType: 'local',
              srcStorageId: 'test-src',
              includeChangeUpdates: false,
              includeStateUpdates: false,
            );

            expect(cloudResult.isSuccess, isTrue);
            expect(localResult.isSuccess, isTrue);

            // Both should store change log entries in save mode
            final cloudChanges = await cloudStorage.getChangesWithCursor(
              domainId: 'test-project',
            );
            final localChanges = await localStorage.getChangesWithCursor(
              domainId: 'test-project',
            );

            expect(
              cloudChanges.length,
              equals(1),
              reason: 'Cloud storage should store change log in save mode',
            );
            expect(
              localChanges.length,
              equals(1),
              reason: 'Local storage should store change log in save mode',
            );

            // Both should store state
            final cloudState = await cloudStorage.getCurrentEntityState(
              'test-project',
              'project',
              'entity-cross',
            );
            final localState = await localStorage.getCurrentEntityState(
              'test-project',
              'project',
              'entity-cross',
            );

            expect(cloudState, isNotNull);
            expect(localState, isNotNull);
            expect(
              cloudState!.toJson()['data_nameLocal'],
              equals('Cross Storage Test'),
            );
            expect(
              localState!.toJson()['data_nameLocal'],
              equals('Cross Storage Test'),
            );
          },
        );

        test(
          'sync mode - storage types should behave according to requirements',
          () async {
            // use the static API directly; ChangeProcessingService is static-only

            final baseTime = DateTime.now().toUtc();

            // Process same sync change in both storage types
            final changeData = {
              'domainId': 'test-project',
              'domainType': 'project',
              'entityType': 'project',
              'entityId': 'entity-sync-cross',
              'changeBy': 'user1',
              'changeAt': baseTime.toIso8601String(),
              'cid': generateCid(baseTime),
              'storageId': 'remote-storage-id', // Non-empty for sync mode
              'operation': 'create',
              'operationInfoJson': '{}',
              'stateChanged': true,
              'unknownJson': '{}',
              'dataJson':
                  '{"nameLocal": "Sync Cross Test", "parentId": "root"}',
            };

            final cloudResult = await ChangeProcessingService.processChanges(
              changesToCreate: [changeData],
              storage: cloudStorage,
              storageMode: 'sync',
              srcStorageType: 'local',
              srcStorageId: 'test-src',
              includeChangeUpdates: false,
              includeStateUpdates: false,
            );

            final localResult = await ChangeProcessingService.processChanges(
              changesToCreate: [changeData],
              storage: localStorage,
              storageMode: 'sync',
              srcStorageType: 'cloud',
              srcStorageId: 'test-src',
              includeChangeUpdates: false,
              includeStateUpdates: false,
            );

            expect(cloudResult.isSuccess, isTrue);
            expect(localResult.isSuccess, isTrue);

            // Cloud storage should store change log entries in sync mode
            final cloudChanges = await cloudStorage.getChangesWithCursor(
              domainId: 'test-project',
            );
            expect(
              cloudChanges.length,
              equals(1),
              reason: 'Cloud storage should store change log in sync mode',
            );

            // Current implementation: Local storage also stores change log in sync mode
            // TODO: Future implementation should typically only update state for local storage
            final localChanges = await localStorage.getChangesWithCursor(
              domainId: 'test-project',
            );
            expect(
              localChanges.length,
              equals(1),
              reason:
                  'Current implementation: Local storage stores change log in sync mode',
            );

            // Both should always store/update state
            final cloudState = await cloudStorage.getCurrentEntityState(
              'test-project',
              'project',
              'entity-sync-cross',
            );
            final localState = await localStorage.getCurrentEntityState(
              'test-project',
              'project',
              'entity-sync-cross',
            );

            expect(
              cloudState,
              isNotNull,
              reason: 'Cloud storage should store state in sync mode',
            );
            expect(
              localState,
              isNotNull,
              reason: 'Local storage should store state in sync mode',
            );
          },
        );
      });
    });
  });
}
