import 'dart:convert';

import 'package:sltt_core/sltt_core.dart';
// helper removed; tests now use LocalStorageService.instance for seeding

// Integration tests for SyncManager using a local cloud server launched by
// multi_server_launcher. These tests exercise two scenarios:
// 1) Local storage starts with changes to outsync (outsync -> cloud)
// 2) Cloud storage starts with changes to downsync (downsync -> local)

// logging available via public export
import 'package:sync_manager/src/test_helpers/isar_change_log_serializer.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  // Initialize project logger so SLTT_LOG_LEVEL is honored in tests.
  SlttLogger.init();
  group('SyncManager integration', () {
    // Helper to construct the expected flattened state map that the
    // ChangeProcessingService produces when upserting entity state. The
    // service expands the JSON fields in change.dataJson into flattened
    // keys like `data_<field>` and also emits derived metadata fields.
    Map<String, dynamic> expectedStateFromChange(
      IsarChangeLogEntry ch, {
      bool isCloudStorage = false,
    }) {
      final data = jsonDecode(ch.dataJson) as Map<String, dynamic>;
      final changeAt = const UtcDateTimeConverter().toJson(ch.changeAt);
      final map = <String, dynamic>{
        'entityId': ch.entityId,
        'domainType': ch.domainType,
        'entityType': ch.entityType,
        'change_domainId_orig_': ch.domainId,
        'change_cid_orig_': ch.cid,
        'change_changeBy_orig_': ch.changeBy,
        'change_changeAt_orig_': changeAt,
        'change_storedAt_orig_': isA<String>(),
        'change_domainId': ch.domainId,
        'change_changeAt': changeAt,
        'change_cid': ch.cid,
        'change_changeBy': ch.changeBy,
        if (isCloudStorage) 'change_cloudAt': isA<String>(),
        'change_storedAt': isA<String>(),
      };

      // For each data field include the flattened variants observed in the
      // processing service output. This mirrors the debug output seen in
      // test runs and keeps expectations deterministic.
      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;
        if (value == null) continue;
        map['data_$key'] = value;
        map['data_${key}_changeAt_'] = changeAt;
        map['data_${key}_cid_'] = ch.cid;
        map['data_${key}_changeBy_'] = ch.changeBy;
        if (isCloudStorage) {
          map['data_${key}_cloudAt_'] = isA<String>();
        }
      }

      return map;
    }

    late String cloudBaseUrl;
    late String srcStorageId;
    late String srcStorageType;

    setUpAll(() async {
      // register change log entry SerializableGroup
      registerIsarChangeLogSerializableGroup();
    });

    setUp(() async {
      final local = LocalStorageService.instance;
      // Ensure any previous instances are closed and on-disk files removed
      // to avoid cross-test interference and 'file in use' errors on Windows.
      try {
        await local.deleteDatabase();
      } catch (e) {
        SlttLogger.logger.warning(
          '[test] Warning: failed to delete local database: $e',
        );
        rethrow;
      }
      await local.initialize();

      final cloudStorage = CloudStorageService.instance;
      try {
        await cloudStorage.deleteDatabase();
      } catch (e) {
        SlttLogger.logger.warning(
          '[test] Warning: failed to delete cloud database: $e',
        );
        rethrow;
      }
      await cloudStorage.initialize();

      // Start the in-process cloud server using MultiServerLauncher.
      final storageInfo = await MultiServerLauncher.instance.startServer(
        StorageType.cloud,
        kCloudStoragePort,
        storage: cloudStorage,
      );
      srcStorageId = storageInfo.storageId;
      srcStorageType = storageInfo.storageType;

      final addresses = MultiServerLauncher.instance.getServerAddresses();
      final cloudAddress = addresses['cloud'];
      expect(
        cloudAddress,
        isNotNull,
        reason: 'Cloud server address should be available after startServer',
      );
      cloudBaseUrl = cloudAddress!;

      // Seed the cloud storage with a test project __test_2 so downsync has data
      final cloudSeedChange = IsarChangeLogEntry(
        changeAt: DateTime.now(),
        cid: generateCid(entityType: EntityType.project, userId: 'test'),
        domainType: 'project',
        domainId: '__test_2',
        entityType: 'project',
        operation: 'create',
        entityId: '__test_2',
        dataJson: stableStringify(
          BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
        ),
        changeBy: 'test',
        stateChanged: false,
        storageId: '',
        unknownJson: '{}',
        operationInfoJson: '{}',
      );

      final cloudSeedResult = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [cloudSeedChange.toJson()],
        srcStorageType: srcStorageType,
        srcStorageId: srcStorageId,
        storage: cloudStorage,
        includeChangeUpdates: true,
        includeStateUpdates: true,
      );
      expect(
        cloudSeedResult.isSuccess,
        isTrue,
        reason:
            'Seeding cloud storage with __test_2 should succeed: ${cloudSeedResult.errorMessage}',
      );

      // Verify storedAt was set on the persisted state. If the storage
      // implementation also sets a cloudAt timestamp we expect storedAt == cloudAt.
      final cloudSeedJson = cloudSeedResult.resultsSummary?.toJson();
      if (cloudSeedJson != null) {
        final stateUpdates = cloudSeedJson['stateUpdates'] as List?;
        if (stateUpdates != null && stateUpdates.isNotEmpty) {
          final state = stateUpdates.first['state'] as Map<String, dynamic>?;
          expect(state, isNotNull);
          expect(
            state!.containsKey('change_storedAt'),
            isTrue,
            reason:
                'cloud seed state must include change_storedAt: ${const JsonEncoder.withIndent(' ').convert(cloudSeedJson)}',
          );
          final storedAt = state['change_storedAt'] as String?;
          expect(storedAt, isNotNull);
          // If the changeUpdates reported a cloudAt, ensure storedAt equals it.
          final changeUpdates = cloudSeedJson['changeUpdates'] as List?;
          if (changeUpdates != null && changeUpdates.isNotEmpty) {
            final cloudAt =
                (changeUpdates.first['updates']
                        as Map<String, dynamic>?)?['cloudAt']
                    as String?;
            if (cloudAt != null) {
              expect(
                storedAt,
                equals(cloudAt),
                reason: 'cloud storedAt should equal cloudAt',
              );
            }
          }
        }
      }
    });

    tearDownAll(() async {
      await MultiServerLauncher.instance.stopServer(StorageType.cloud);
    });

    test('outsync: local changes are pushed to cloud', () async {
      final syncManager = SyncManager.instance;

      // Seed LocalStorageService via
      // ChangeProcessingService (save mode). This ensures the Isar-backed
      // LocalStorageService contains the change entries.
      final local = LocalStorageService.instance;
      final localStorageId = await local.getStorageId();

      final changeBy = 'test';
      final change = IsarChangeLogEntry(
        changeAt: DateTime.now(),
        cid: generateCid(entityType: EntityType.project, userId: changeBy),
        domainType: 'project',
        domainId: '__test_1',
        entityType: 'project',
        operation: 'create',
        entityId: '__test_1',
        dataJson: stableStringify(
          BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
        ),
        changeBy: changeBy,
        stateChanged: false,
        storageId: '',
        unknownJson: '{}',
        operationInfoJson: '{}',
      );

      final seedResult = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [change.toJson()],
        srcStorageType: srcStorageType,
        srcStorageId: srcStorageId,
        storage: local,
        includeChangeUpdates: true,
        includeStateUpdates: true,
      );
      expect(
        seedResult.isSuccess,
        isTrue,
        reason:
            'Seeding local storage should succeed: ${seedResult.errorMessage}',
      );
      final seedJson = seedResult.resultsSummary?.toJson();
      final seedStateUpdates = [
        {'cid': change.cid, 'state': expectedStateFromChange(change)},
      ];
      final seedChangeUpdates = [
        {
          'cid': change.cid,
          'updates': {
            'operation': change.operation,
            'operationInfoJson': '{"outdatedBys":[],"noOpFields":[]}',
            'stateChanged': true,
            'storageId': localStorageId,
            'cloudAt': null,
            'storedAt': isA<String>(),
            'dataJson': change.dataJson,
          },
        },
      ];
      final seedInfo = [
        {
          'cid': change.cid,
          'operation': change.operation,
          'info': {'outdatedBys': [], 'noOpFields': []},
        },
      ];
      expect(
        seedJson,
        equals({
          'storageType': 'local',
          'storageId': localStorageId,
          'stateUpdates': seedStateUpdates,
          'changeUpdates': seedChangeUpdates,
          'created': [change.cid],
          'updated': [],
          'deleted': [],
          'outdated': [],
          'noOps': [],
          'clouded': [],
          'dups': [],
          'unknowns': [],
          'info': seedInfo,
          'errors': [],
          'unprocessed': [],
        }),
        reason: 'Seeding local storage should process 1 change',
      );

      // Verify storedAt was set on the local persisted state.
      final seedSummaryJson = seedResult.resultsSummary?.toJson();
      if (seedSummaryJson != null) {
        final stateUpdates = seedSummaryJson['stateUpdates'] as List?;
        if (stateUpdates != null && stateUpdates.isNotEmpty) {
          final state = stateUpdates.first['state'] as Map<String, dynamic>?;
          expect(state, isNotNull);
          expect(
            state!.containsKey('change_storedAt'),
            isTrue,
            reason: 'local seed state must include change_storedAt',
          );
          final storedAt = state['change_storedAt'] as String?;
          expect(storedAt, isNotNull);
        }
      }

      await syncManager.initialize();
      syncManager.configureCloudUrl(cloudBaseUrl);

      final result = await syncManager.outsyncToCloud();

      expect(
        result.success,
        isTrue,
        reason:
            'Unexpected outsync failure: ${result.error} at ${result.errorStackTrace}',
      );
      expect(
        result.deletedLocalChanges,
        equals([change.cid]),
        reason:
            'Unexpected outsync failure: ${result.error} at ${result.errorStackTrace}',
      );
      expect(
        result.changeSummary?.processed,
        equals([change.cid]),
        reason:
            'Outsync summary should only include the local-origin change cid',
      );
      // Use SyncManager.getSyncStatus to confirm the project has no pending outsyncs
      final status = await syncManager.getSyncStatus('__test_1');
      expect(
        status.localChangeStats?.totals.toJson(),
        equals({
          'creates': 0,
          'updates': 0,
          'deletes': 0,
          'total': 0,
          'latestChangeAt': '1970-01-01T00:00:00Z',
          'latestSeq': -1,
        }),
        reason:
            'After successful outsync, project __test_1 should have 0 pending outsyncs',
      );
      expect(
        status.cloudChangeStats?.toJson(),
        equals(isNotNull),
        reason:
            'After successful outsync, project __test_1 should have change logs in the cloud',
      );
    });

    test('downsync: cloud changes are applied to local', () async {
      final syncManager = SyncManager.instance;
      await syncManager.initialize();
      syncManager.configureCloudUrl(cloudBaseUrl);

      // Trigger downsync; the cloud server should start with a __test_2 project
      final downsyncResult = await syncManager.downsyncFromCloud();

      expect(
        downsyncResult.success,
        isTrue,
        reason:
            'Unexpected downsync failure: ${downsyncResult.error} at ${downsyncResult.errorStackTrace}',
      );

      final downsyncedChanges = downsyncResult.projectCursorChanges.values
          .expand((changes) => changes)
          .toList();
      expect(
        downsyncedChanges,
        isNotEmpty,
        reason:
            'Downsync should emit at least one change for the seeded project',
      );
      expect(
        downsyncedChanges
            .map((change) => change['cloudAt'])
            .every((c) => c != null),
        isTrue,
        reason:
            'Downsynced change payloads must include cloudAt to mark cloud origin, but got: $downsyncedChanges',
      );

      final status = await syncManager.getSyncStatus('__test_2');
      // After downsync we expect local state stats to be available for the project
      final totalsObj = status.localStateStats?.totals;
      final totals = totalsObj?.toJson();
      final expectedLatest = const UtcDateTimeConverter().toJson(
        DateTime.parse(downsyncedChanges.first['changeAt'] as String),
      );
      expect(
        totals,
        equals({
          'creates': 1,
          'updates': 0,
          'deletes': 0,
          'total': 1,
          'latestChangeAt': expectedLatest,
          'latestSeq': totals?['latestSeq'],
        }),
        reason:
            'getSyncStatus should report local state stats for __test_2 after downsync',
      );

      // Verify local storage has received changes for __test_2 and report status via SyncManager
      final local = LocalStorageService.instance;
      final projects = await local.getAllDomainIds(domainType: 'project');
      expect(
        projects,
        contains('__test_2'),
        reason:
            'Local storage should contain the cloud test project __test_2 after downsync',
      );
    });

    test(
      'full sync: outsynced lww local changes and downsynced cloud changes',
      () async {
        final syncManager = SyncManager.instance;
        final local = LocalStorageService.instance;
        final cloud = CloudStorageService.instance;

        // seed cloud first then local so local lww change wins
        const projectId = '__test_full_cloud_local_lww';
        final cloudChange = IsarChangeLogEntry(
          changeAt: DateTime.now().subtract(const Duration(minutes: 1)),
          cid: generateCid(
            entityType: EntityType.project,
            userId: 'cloud-full',
          ),
          domainType: 'project',
          domainId: projectId,
          entityType: 'project',
          operation: 'create',
          entityId: projectId,
          dataJson: stableStringify({
            ...BaseDataFields(
              parentId: 'root',
              parentProp: 'projects',
            ).toJson(),
            'nameLocal': 'Edited by cloud-full',
          }),
          changeBy: 'cloud-full',
          stateChanged: false,
          storageId: '',
          unknownJson: '{}',
          operationInfoJson: '{}',
        );

        final cloudSeed = await ChangeProcessingService.storeChanges(
          storageMode: 'save',
          changes: [cloudChange.toJson()],
          srcStorageType: srcStorageType,
          srcStorageId: srcStorageId,
          storage: cloud,
          includeChangeUpdates: true,
          includeStateUpdates: true,
        );
        expect(
          cloudSeed.isSuccess,
          isTrue,
          reason:
              'Seeding cloud storage for full sync should succeed: ${cloudSeed.errorMessage}',
        );
        // Verify cloud persisted state included change_storedAt (and equals cloudAt if present).
        final cloudSeedJsonForAssert = cloudSeed.resultsSummary?.toJson();
        if (cloudSeedJsonForAssert != null) {
          final stateUpdates = cloudSeedJsonForAssert['stateUpdates'] as List?;
          if (stateUpdates != null && stateUpdates.isNotEmpty) {
            final state = stateUpdates.first['state'] as Map<String, dynamic>?;
            expect(state, isNotNull);
            expect(
              state!.containsKey('change_storedAt'),
              isTrue,
              reason: 'cloud seed state must include change_storedAt',
            );
            final storedAt = state['change_storedAt'] as String?;
            expect(storedAt, isNotNull);
            final changeUpdates =
                cloudSeedJsonForAssert['changeUpdates'] as List?;
            if (changeUpdates != null && changeUpdates.isNotEmpty) {
              final cloudAt =
                  (changeUpdates.first['updates']
                          as Map<String, dynamic>?)?['cloudAt']
                      as String?;
              if (cloudAt != null) {
                expect(
                  storedAt,
                  equals(cloudAt),
                  reason: 'cloud storedAt should equal cloudAt',
                );
              }
            }
          }
        }
        final cloudStateUpdates = [
          {
            'cid': cloudChange.cid,
            'state': expectedStateFromChange(cloudChange, isCloudStorage: true),
          },
        ];
        final cloudChangeUpdates = [
          {
            'cid': cloudChange.cid,
            'updates': {
              'operation': cloudChange.operation,
              'operationInfoJson': '{"outdatedBys":[],"noOpFields":[]}',
              'stateChanged': true,
              'storageId': await cloud.getStorageId(),
              'cloudAt': isA<String>(),
              'storedAt': isA<String>(),
              'dataJson': cloudChange.dataJson,
            },
          },
        ];
        final cloudInfo = [
          {
            'cid': cloudChange.cid,
            'operation': cloudChange.operation,
            'info': {'outdatedBys': [], 'noOpFields': []},
          },
        ];
        expect(
          cloudSeedJsonForAssert,
          equals({
            'storageType': 'cloud',
            'storageId': await cloud.getStorageId(),
            'stateUpdates': cloudStateUpdates,
            'changeUpdates': cloudChangeUpdates,
            'created': [cloudChange.cid],
            'updated': [],
            'deleted': [],
            'outdated': [],
            'noOps': [],
            'clouded': [],
            'dups': [],
            'unknowns': [],
            'info': cloudInfo,
            'errors': [],
            'unprocessed': [],
          }),
          reason: 'Seeding cloud storage should process 1 change',
        );
        final localChange = IsarChangeLogEntry(
          changeAt: DateTime.now(),
          cid: generateCid(
            entityType: EntityType.project,
            userId: 'local-full',
          ),
          domainType: 'project',
          domainId: projectId,
          entityType: 'project',
          operation: 'create',
          entityId: projectId,
          dataJson: stableStringify({
            ...BaseDataFields(
              parentId: 'root',
              parentProp: 'projects',
            ).toJson(),
            'nameLocal': 'Edited by local-full',
          }),
          changeBy: 'local-full',
          stateChanged: false,
          storageId: '',
          unknownJson: '{}',
          operationInfoJson: '{}',
        );
        final localSeed = await ChangeProcessingService.storeChanges(
          storageMode: 'save',
          changes: [localChange.toJson()],
          srcStorageType: srcStorageType,
          srcStorageId: srcStorageId,
          storage: local,
          includeChangeUpdates: true,
          includeStateUpdates: true,
        );
        expect(
          localSeed.isSuccess,
          isTrue,
          reason:
              'Seeding local storage for full sync should succeed: ${localSeed.errorMessage}',
        );
        // Verify local persisted state included change_storedAt.
        final localSeedJsonForAssert = localSeed.resultsSummary?.toJson();
        if (localSeedJsonForAssert != null) {
          final stateUpdates = localSeedJsonForAssert['stateUpdates'] as List?;
          if (stateUpdates != null && stateUpdates.isNotEmpty) {
            final state = stateUpdates.first['state'] as Map<String, dynamic>?;
            expect(state, isNotNull);
            expect(
              state!.containsKey('change_storedAt'),
              isTrue,
              reason: 'local seed state must include change_storedAt',
            );
            final storedAt = state['change_storedAt'] as String?;
            expect(storedAt, isNotNull);
          }
        }
        final localStateUpdates = [
          {
            'cid': localChange.cid,
            'state': expectedStateFromChange(localChange),
          },
        ];
        final localChangeUpdates = [
          {
            'cid': localChange.cid,
            'updates': {
              'operation': localChange.operation,
              'operationInfoJson': '{"outdatedBys":[],"noOpFields":[]}',
              'stateChanged': true,
              'storageId': await local.getStorageId(),
              'cloudAt': null,
              'storedAt': isA<String>(),
              'dataJson': localChange.dataJson,
            },
          },
        ];
        final localInfo = [
          {
            'cid': localChange.cid,
            'operation': localChange.operation,
            'info': {'outdatedBys': [], 'noOpFields': []},
          },
        ];
        expect(
          localSeedJsonForAssert,
          equals({
            'storageType': 'local',
            'storageId': await local.getStorageId(),
            'stateUpdates': localStateUpdates,
            'changeUpdates': localChangeUpdates,
            'created': [localChange.cid],
            'updated': [],
            'deleted': [],
            'outdated': [],
            'noOps': [],
            'clouded': [],
            'dups': [],
            'unknowns': [],
            'info': localInfo,
            'errors': [],
            'unprocessed': [],
          }),
          reason: 'Seeding local storage should process 1 change',
        );
        await syncManager.initialize();
        syncManager.configureCloudUrl(cloudBaseUrl);
        final fullSyncResult = await syncManager.performFullSync();
        expect(
          fullSyncResult.success,
          isTrue,
          reason:
              'Full sync should succeed: ${fullSyncResult.downsyncResult.error}',
        );
        expect(
          fullSyncResult.outsyncResult.deletedLocalChanges,
          contains(localChange.cid),
          reason: 'Full sync should remove outsynced local change from storage',
        );
        expect(
          fullSyncResult.downsyncResult.projectCursorChanges.values
              .expand((changes) => changes)
              .any((change) => change['entityId'] == projectId),
          isTrue,
          reason: 'Downsync should include the cloud project change',
        );
        // Verify outsynced project has no pending local-origin changes
        final localStatus = await syncManager.getSyncStatus(projectId);
        final pendingLocalChanges = await local.getChangesWithCursor(
          domainType: 'project',
          domainId: projectId,
        );
        expect(
          pendingLocalChanges,
          isEmpty,
          reason:
              'After full sync, project $projectId should have 0 pending local-origin changes',
        );
        expect(
          localStatus.localStateStats?.totals.toJson(),
          equals({
            'creates': 1,
            'updates': 1,
            'deletes': 0,
            'total': 2,
            'latestChangeAt': const UtcDateTimeConverter().toJson(
              localChange.changeAt,
            ),
            'latestSeq': 3,
          }),
          reason:
              'After full sync, project $projectId should have 1 local state entity',
        );
      },
      // skip: 'fixme',
    );

    test(
      'full sync: outsynced OUTDATED local changes and downsynced cloud changes',
      () async {
        final syncManager = SyncManager.instance;
        final local = LocalStorageService.instance;
        final cloud = CloudStorageService.instance;

        const projectId = '__test_full_cloud_local_outdated';

        // Seed a local change that should be outsynced
        final localChange = IsarChangeLogEntry(
          changeAt: DateTime.now(),
          cid: generateCid(
            entityType: EntityType.project,
            userId: 'local-full',
          ),
          domainType: 'project',
          domainId: projectId,
          entityType: 'project',
          operation: 'create',
          entityId: projectId,
          dataJson: stableStringify({
            ...BaseDataFields(
              parentId: 'root',
              parentProp: 'projects',
            ).toJson(),
            'nameLocal': 'Edited by local-full',
          }),
          changeBy: 'local-full',
          stateChanged: false,
          storageId: '',
          unknownJson: '{}',
          operationInfoJson: '{}',
        );

        final localSeed = await ChangeProcessingService.storeChanges(
          storageMode: 'save',
          changes: [localChange.toJson()],
          srcStorageType: srcStorageType,
          srcStorageId: srcStorageId,
          storage: local,
          includeChangeUpdates: true,
          includeStateUpdates: true,
        );
        expect(
          localSeed.isSuccess,
          isTrue,
          reason:
              'Seeding local storage for full sync should succeed: ${localSeed.errorMessage}',
        );

        expect(
          localSeed.resultsSummary?.toJson(),
          equals({
            'storageType': 'local',
            'storageId': await local.getStorageId(),
            'stateUpdates': isA<List<Map<String, dynamic>>>(),
            'changeUpdates': isA<List<Map<String, dynamic>>>(),
            'created': [localChange.cid],
            'updated': [],
            'deleted': [],
            'outdated': [],
            'noOps': [],
            'clouded': [],
            'dups': [],
            'unknowns': [],
            'info': isA<List<Map<String, dynamic>>>(),
            'errors': [],
            'unprocessed': [],
          }),
          reason: 'Seeding local storage should process 1 change',
        );

        // Seed a cloud change that should be downsynced
        final cloudChange = IsarChangeLogEntry(
          changeAt: DateTime.now(),
          cid: generateCid(
            entityType: EntityType.project,
            userId: 'cloud-full',
          ),
          domainType: 'project',
          domainId: projectId,
          entityType: 'project',
          operation: 'create',
          entityId: projectId,
          dataJson: stableStringify({
            ...BaseDataFields(
              parentId: 'root',
              parentProp: 'projects',
            ).toJson(),
            'nameLocal': 'Edited by cloud-full',
          }),
          changeBy: 'cloud-full',
          stateChanged: false,
          storageId: '',
          unknownJson: '{}',
          operationInfoJson: '{}',
        );

        final cloudSeed = await ChangeProcessingService.storeChanges(
          storageMode: 'save',
          changes: [cloudChange.toJson()],
          srcStorageType: srcStorageType,
          srcStorageId: srcStorageId,
          storage: cloud,
          includeChangeUpdates: true,
          includeStateUpdates: true,
        );
        expect(
          cloudSeed.isSuccess,
          isTrue,
          reason:
              'Seeding cloud storage for full sync should succeed: ${cloudSeed.errorMessage}',
        );
        // Verify cloud persisted state included change_storedAt (and equals cloudAt if present).
        final cloudSeedJson2 = cloudSeed.resultsSummary?.toJson();
        if (cloudSeedJson2 != null) {
          final stateUpdates = cloudSeedJson2['stateUpdates'] as List?;
          if (stateUpdates != null && stateUpdates.isNotEmpty) {
            final state = stateUpdates.first['state'] as Map<String, dynamic>?;
            expect(state, isNotNull);
            expect(
              state!.containsKey('change_storedAt'),
              isTrue,
              reason: 'cloud seed state must include change_storedAt',
            );
            final storedAt = state['change_storedAt'] as String?;
            expect(storedAt, isNotNull);
            final changeUpdates = cloudSeedJson2['changeUpdates'] as List?;
            if (changeUpdates != null && changeUpdates.isNotEmpty) {
              final cloudAt =
                  (changeUpdates.first['updates']
                          as Map<String, dynamic>?)?['cloudAt']
                      as String?;
              if (cloudAt != null) {
                expect(
                  storedAt,
                  equals(cloudAt),
                  reason: 'cloud storedAt should equal cloudAt',
                );
              }
            }
          }
        }

        final cloudStateUpdates2 = [
          {
            'cid': cloudChange.cid,
            'state': expectedStateFromChange(cloudChange, isCloudStorage: true),
          },
        ];
        final cloudChangeUpdates2 = [
          {
            'cid': cloudChange.cid,
            'updates': {
              'operation': cloudChange.operation,
              'operationInfoJson': '{"outdatedBys":[],"noOpFields":[]}',
              'stateChanged': true,
              'storageId': await cloud.getStorageId(),
              'cloudAt': isA<String>(),
              'storedAt': isA<String>(),
              'dataJson': cloudChange.dataJson,
            },
          },
        ];
        final cloudInfo2 = [
          {
            'cid': cloudChange.cid,
            'operation': cloudChange.operation,
            'info': {'outdatedBys': [], 'noOpFields': []},
          },
        ];
        expect(
          cloudSeedJson2,
          equals({
            'storageType': 'cloud',
            'storageId': await cloud.getStorageId(),
            'stateUpdates': cloudStateUpdates2,
            'changeUpdates': cloudChangeUpdates2,
            'created': [cloudChange.cid],
            'updated': [],
            'deleted': [],
            'outdated': [],
            'noOps': [],
            'clouded': [],
            'dups': [],
            'unknowns': [],
            'info': cloudInfo2,
            'errors': [],
            'unprocessed': [],
          }),
          reason: 'Seeding cloud storage should process 1 change',
        );

        await syncManager.initialize();
        syncManager.configureCloudUrl(cloudBaseUrl);

        final fullSyncResult = await syncManager.performFullSync(
          domainIds: [projectId],
        );

        expect(
          fullSyncResult.success,
          isTrue,
          reason:
              'Full sync should succeed: ${fullSyncResult.downsyncResult.error}',
        );
        expect(
          fullSyncResult.outsyncResult.deletedLocalChanges,
          contains(localChange.cid),
          reason: 'Full sync should remove outsynced local change from storage',
        );
        expect(
          fullSyncResult.downsyncResult.projectCursorChanges.values
              .expand((changes) => changes)
              .any((change) => change['entityId'] == projectId),
          isTrue,
          reason: 'Downsync should include the cloud project change',
        );

        // Verify outsynced project has no pending local-origin changes
        final localStatus = await syncManager.getSyncStatus(projectId);
        final pendingLocalChanges = await local.getChangesWithCursor(
          domainType: 'project',
          domainId: projectId,
        );

        expect(
          pendingLocalChanges,
          isEmpty,
          reason:
              'Full sync should remove local-origin change log entries for $projectId, but got: ${(pendingLocalChanges).map((c) => c.toJson())}',
        );

        // After full sync and deletion of local change-log entries, pending
        // change stats will be empty. Verify the historical state counters
        // (localStateStats) still reflect the operation that occurred.
        final stateTotals = localStatus.localStateStats?.totals;
        expect(
          stateTotals,
          isNotNull,
          reason: 'State stats should be available for $projectId',
        );
        final totalsMap = stateTotals?.toJson();
        expect(
          totalsMap,
          equals({
            'creates': 1,
            'updates': 1,
            'deletes': 0,
            'total': 2,
            'latestChangeAt': const UtcDateTimeConverter().toJson(
              cloudChange.changeAt,
            ),
            'latestSeq': totalsMap?['latestSeq'],
          }),
          reason:
              'After full sync, project $projectId should have 2 total local state changes',
        );

        // Verify downsynced project exists locally
        final downsyncedState = await local.getCurrentEntityState(
          domainType: 'project',
          domainId: projectId,
          entityType: 'project',
          entityId: projectId,
        );
        expect(
          downsyncedState,
          isNotNull,
          reason: 'Downsynced project should exist in local storage',
        );
      },
      timeout: const Timeout(Duration(minutes: 3)),
      // skip: 'fixme',
    );
  });
}

/// Very small adapter implementing only the methods SyncManager calls on
/// LocalStorageService. This avoids pulling the full LocalStorageService
/// interface into the test.
// Test adapter removed: tests now use the real LocalStorageService.instance
