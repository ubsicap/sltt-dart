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
    });

    tearDownAll(() async {
      await MultiServerLauncher.instance.stopServer(StorageType.cloud);
    });

    test('outsync [create]: save local changes > outsync to cloud', () async {
      final syncManager = SyncManager.instance;
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

      final localSaveResult = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [change.toJson()],
        srcStorageType: srcStorageType,
        srcStorageId: srcStorageId,
        storage: local,
        includeChangeUpdates: true,
        includeStateUpdates: true,
      );
      final savedChangeUpdates = [
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
      await verifyLocalChangeSaved(
        localSaveResult: localSaveResult,
        localChange: change,
        local: local,
        expectedChangeUpdates: savedChangeUpdates,
        expectedStateUpdates: expectedStateFromChange(change),
      );

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
      // confirm cloud state totals
      final cloudTotals = status.cloudStateStats?.totals;
      expect(
        cloudTotals?.toJson(),
        equals({
          'creates': 1,
          'updates': 0,
          'deletes': 0,
          'total': 1,
          'latestChangeAt': const UtcDateTimeConverter().toJson(
            change.changeAt,
          ),
          'latestSeq': 1,
        }),
        reason:
            'After successful outsync, project __test_1 should have change logs in the cloud',
      );
    });

    test('downsync [create]: save cloud changes > downsync to local', () async {
      final cloud = CloudStorageService.instance;
      final cloudStorageId = await cloud.getStorageId();
      final projectId = '__test_2';
      final cloudChange = await saveCloudChange(
        srcStorageType: srcStorageType,
        srcStorageId: srcStorageId,
        domainId: projectId,
        entityId: projectId,
        changeAt: DateTime.now(),
        dataJson: stableStringify(
          BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
        ),
        userId: 'test',
        operation: 'create',
        fnGetExpectedChangeUpdates: (cloudSaveChange) => [
          expectedChangeUpdatesFromCreateChange(
            createChange: cloudSaveChange,
            storageId: cloudStorageId,
          ),
        ],
        fnGetExpectedStateUpdates: (change) =>
            expectedStateFromChange(change, isCloudStorage: true),
      );
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

      // confirm cloud state totals
      final cloudTotals = status.cloudStateStats?.totals;
      expect(
        cloudTotals?.toJson(),
        equals({
          'creates': 1,
          'updates': 0,
          'deletes': 0,
          'total': 1,
          'latestChangeAt': const UtcDateTimeConverter().toJson(
            cloudChange.changeAt,
          ),
          'latestSeq': 1,
        }),
        reason:
            'After full sync, project $projectId should have 1 total cloud changes',
      );

      // Verify local storage has received changes for __test_2 and report status via SyncManager
      final local = LocalStorageService.instance;
      final projects = await local.getAllDomainIds(domainType: 'project');
      expect(
        projects,
        contains(projectId),
        reason:
            'Local storage should contain the cloud test project $projectId after downsync',
      );

      await getCurrentEntityStateAndCheckCloudAt(local, projectId);
    });

    test(
      'full sync [create]: save local changes > outsync to cloud > downsync same',
      () async {
        final syncManager = SyncManager.instance;
        final local = LocalStorageService.instance;

        final expectedNameLocalUpdate = 'Edited by local-full';

        const projectId = '__test_full_cloud_local_create_update';
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
            'nameLocal': expectedNameLocalUpdate,
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
              'Saving local storage for full sync should succeed: ${localSeed.errorMessage}',
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
        final status = await syncManager.getSyncStatus(projectId);
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
          status.localStateStats?.totals.toJson(),
          equals({
            'creates': 1,
            'updates': 0,
            'deletes': 0,
            'total': 1,
            'latestChangeAt': const UtcDateTimeConverter().toJson(
              localChange.changeAt,
            ),
            'latestSeq': 1,
          }),
          reason:
              'After full sync, project $projectId should have 1 local state entity',
        );
        // confirm cloud state totals
        final cloudTotals = status.cloudStateStats?.totals;
        expect(
          cloudTotals?.toJson(),
          equals({
            'creates': 1,
            'updates': 0,
            'deletes': 0,
            'total': 1,
            'latestChangeAt': const UtcDateTimeConverter().toJson(
              localChange.changeAt,
            ),
            'latestSeq': 1,
          }),
          reason:
              'After full sync, project $projectId should have 1 total cloud changes',
        );

        IsarProjectState localState =
            await getCurrentEntityStateAndCheckCloudAt(local, projectId);

        // verify expected nameLocal state
        expect(
          localState.data_nameLocal,
          equals(expectedNameLocalUpdate),
          reason:
              'After full sync, local state for project $projectId should reflect last write wins local edit',
        );
      },
      // skip: 'fixme',
      timeout: Timeout.none,
    );

    test(
      'full sync [update]: cloud save > downsync > local save > outsync to cloud > downsynced cloud changes',
      () async {
        final syncManager = SyncManager.instance;
        final local = LocalStorageService.instance;
        final cloud = CloudStorageService.instance;
        final cloudStorageId = await cloud.getStorageId();

        // seed cloud first then local so local lww change wins
        const projectId = '__test_full_cloud_local_lww';
        final cloudChangeAt = DateTime.now().subtract(
          const Duration(minutes: 1),
        );
        const expectedNameLocalUpdate = 'Edited by local-full';
        await saveCloudChange(
          srcStorageType: srcStorageType,
          srcStorageId: srcStorageId,
          domainId: projectId,
          entityId: projectId,
          changeAt: cloudChangeAt,
          dataJson: stableStringify({
            ...BaseDataFields(
              parentId: 'root',
              parentProp: 'projects',
            ).toJson(),
            'nameLocal': 'Edited by cloud-full',
          }),
          userId: 'cloud-full',
          operation: 'create',
          fnGetExpectedChangeUpdates: (cloudSaveChange) => [
            expectedChangeUpdatesFromCreateChange(
              createChange: cloudSaveChange,
              storageId: cloudStorageId,
            ),
          ],
          fnGetExpectedStateUpdates: (change) =>
              expectedStateFromChange(change, isCloudStorage: true),
        );
        await syncManager.initialize();
        syncManager.configureCloudUrl(cloudBaseUrl);
        await syncManager.downsyncFromCloud(domainIds: [projectId]);
        final localChangeAt = DateTime.now().toUtc();
        final localChange = IsarChangeLogEntry(
          changeAt: localChangeAt,
          cid: generateCid(
            entityType: EntityType.project,
            userId: 'local-full',
          ),
          domainType: 'project',
          domainId: projectId,
          entityType: 'project',
          operation: 'update',
          entityId: projectId,
          dataJson: stableStringify({
            ...BaseDataFields(
              parentId: 'root',
              parentProp: 'projects',
            ).toJson(),
            'nameLocal': expectedNameLocalUpdate,
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
        await verifyLocalChangeSaved(
          localSaveResult: localSeed,
          localChange: localChange,
          local: local,
          expectedChangeUpdates: [
            {
              'cid': localChange.cid,
              'updates': {
                'operation': localChange.operation,
                'operationInfoJson':
                    '{"outdatedBys":[],"noOpFields":["parentId","parentProp"]}',
                'stateChanged': true,
                'storageId': await local.getStorageId(),
                'cloudAt': null,
                'storedAt': isA<String>(),
                'dataJson': '{"nameLocal":"$expectedNameLocalUpdate"}',
              },
            },
          ],
          expectedStateUpdates: {
            'domainType': 'project',
            'change_domainId': '__test_full_cloud_local_lww',
            'change_changeAt': localChange.changeAt.toIso8601String(),
            'change_cid': localChange.cid,
            'change_changeBy': 'local-full',
            'change_storedAt': isNotNull,
            'data_nameLocal': expectedNameLocalUpdate,
            'data_nameLocal_changeAt_': localChange.changeAt.toIso8601String(),
            'data_nameLocal_cid_': localChange.cid,
            'data_nameLocal_changeBy_': 'local-full',
          },
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
        final status = await syncManager.getSyncStatus(projectId);
        final pendingLocalChanges = await local.getChangesWithCursor(
          domainType: 'project',
          domainId: projectId,
        );
        expect(
          status.localStateStats?.totals.toJson(),
          equals({
            'creates': 1, // from cloud
            'updates': 1, // from local
            'deletes': 0,
            'total': 2,
            'latestChangeAt': const UtcDateTimeConverter().toJson(
              localChange.changeAt,
            ),
            'latestSeq': 2,
          }),
          reason:
              'After full sync, project $projectId should have 1 local state entity',
        );
        // confirm cloud state totals
        final cloudTotals = status.cloudStateStats?.totals;
        expect(
          cloudTotals?.toJson(),
          equals({
            'creates': 1,
            'updates': 1,
            'deletes': 0,
            'total': 2,
            'latestChangeAt': const UtcDateTimeConverter().toJson(
              localChange.changeAt,
            ),
            'latestSeq': 2,
          }),
          reason:
              'After full sync, project $projectId should have 2 total cloud changes',
        );

        expect(
          pendingLocalChanges.map((c) => c.toJson()),
          isEmpty,
          reason:
              'After full sync, project $projectId should have 0 pending local-origin changes',
        );
        // expect cloudAt to be updated on the local state
        final localState = await getCurrentEntityStateAndCheckCloudAt(
          local,
          projectId,
        );
        expect(
          localState.change_cloudAt,
          isNotNull,
          reason:
              'After full sync, local state for project $projectId should have change_cloudAt set',
        );

        // verify expected nameLocal state
        expect(
          localState.data_nameLocal,
          equals(expectedNameLocalUpdate),
          reason:
              'After full sync, local state for project $projectId should reflect last write wins local edit',
        );
      },
      // skip: 'fixme',
      timeout: Timeout.none,
    );

    test(
      'full sync [outdated]: save cloud change > downsync > save local changes > save cloud change > upsync local changes - OUTDATED > downsynced cloud changes',
      () async {
        final syncManager = SyncManager.instance;
        final local = LocalStorageService.instance;
        final cloud = CloudStorageService.instance;
        final cloudStorageId = await cloud.getStorageId();
        final expectedOutdatedNameLocalUpdate =
            'Expected outdated edit by local-full';
        final expectedNameLocalAfterDownsync =
            'Expected winning edit by cloud-full';

        const projectId = '__test_full_cloud_local_outdated';

        // Save a cloud change that should be downsynced
        await saveCloudChange(
          srcStorageType: srcStorageType,
          srcStorageId: srcStorageId,
          domainId: projectId,
          entityId: projectId,
          changeAt: DateTime.now(),
          dataJson: stableStringify({
            ...BaseDataFields(
              parentId: 'root',
              parentProp: 'projects',
            ).toJson(),
            'nameLocal': 'Created by cloud-full',
          }),
          userId: 'cloud-full',
          operation: kChangeOperationCreate,
          fnGetExpectedChangeUpdates: (cloudSaveChange) => [
            expectedChangeUpdatesFromCreateChange(
              createChange: cloudSaveChange,
              storageId: cloudStorageId,
            ),
          ],
          fnGetExpectedStateUpdates: (change) =>
              expectedStateFromChange(change, isCloudStorage: true),
        );

        await syncManager.initialize();
        syncManager.configureCloudUrl(cloudBaseUrl);
        await syncManager.downsyncFromCloud(domainIds: [projectId]);

        // Save a local change that should be outsynced
        final localChange = IsarChangeLogEntry(
          changeAt: DateTime.now().toUtc(),
          cid: generateCid(
            entityType: EntityType.project,
            userId: 'local-full',
          ),
          domainType: 'project',
          domainId: projectId,
          entityType: 'project',
          operation: kChangeOperationUpdate,
          entityId: projectId,
          dataJson: stableStringify({
            ...BaseDataFields(
              parentId: 'root',
              parentProp: 'projects',
            ).toJson(),
            'nameLocal': expectedOutdatedNameLocalUpdate,
          }),
          changeBy: 'local-full',
          stateChanged: false,
          storageId: '',
          unknownJson: '{}',
          operationInfoJson: '{}',
        );

        final localSave = await ChangeProcessingService.storeChanges(
          storageMode: 'save',
          changes: [localChange.toJson()],
          srcStorageType: srcStorageType,
          srcStorageId: srcStorageId,
          storage: local,
          includeChangeUpdates: true,
          includeStateUpdates: true,
        );
        await verifyLocalChangeSaved(
          localSaveResult: localSave,
          localChange: localChange,
          local: local,
          expectedChangeUpdates: [
            {
              'cid': localChange.cid,
              'updates': {
                'operation': kChangeOperationUpdate,
                'operationInfoJson':
                    '{"outdatedBys":[],"noOpFields":["parentId","parentProp"]}',
                'stateChanged': true,
                'storageId': await local.getStorageId(),
                'cloudAt': null,
                'storedAt': isA<String>(),
                'dataJson': '{"nameLocal":"$expectedOutdatedNameLocalUpdate"}',
              },
            },
          ],
          expectedStateUpdates: {
            'domainType': 'project',
            'change_domainId': projectId,
            'change_changeAt': localChange.changeAt.toIso8601String(),
            'change_cid': localChange.cid,
            'change_changeBy': localChange.changeBy,
            'change_storedAt': isNotNull,
            'data_nameLocal': expectedOutdatedNameLocalUpdate,
            'data_nameLocal_changeAt_': localChange.changeAt.toIso8601String(),
            'data_nameLocal_cid_': localChange.cid,
            'data_nameLocal_changeBy_': localChange.changeBy,
          },
        );

        // Save a cloud change that trumps local change
        final cloudChange2 = await saveCloudChange(
          srcStorageType: srcStorageType,
          srcStorageId: srcStorageId,
          domainId: projectId,
          entityId: projectId,
          changeAt: DateTime.now().toUtc(),
          dataJson: stableStringify({
            ...BaseDataFields(
              parentId: 'root',
              parentProp: 'projects',
            ).toJson(),
            'nameLocal': expectedNameLocalAfterDownsync,
          }),
          userId: 'cloud-full',
          operation: 'update',
          fnGetExpectedChangeUpdates: (cloudSaveChange) => [
            {
              'cid': cloudSaveChange.cid,
              'updates': {
                'operation': cloudSaveChange.operation,
                'operationInfoJson':
                    '{"outdatedBys":[],"noOpFields":["parentId","parentProp"]}',
                'stateChanged': true,
                'storageId': cloudStorageId,
                'cloudAt': isA<String>(),
                'storedAt': isA<String>(),
                'dataJson': '{"nameLocal":"$expectedNameLocalAfterDownsync"}',
              },
            },
          ],
          fnGetExpectedStateUpdates: (change) => {
            'domainType': 'project',
            'change_domainId': projectId,
            'change_changeAt': change.changeAt.toIso8601String(),
            'change_cid': change.cid,
            'change_changeBy': change.changeBy,
            'change_storedAt': isNotNull,
            'change_cloudAt': isNotNull,
            'data_nameLocal': expectedNameLocalAfterDownsync,
            'data_nameLocal_changeAt_': change.changeAt.toIso8601String(),
            'data_nameLocal_cid_': change.cid,
            'data_nameLocal_changeBy_': change.changeBy,
            'data_nameLocal_cloudAt_': isNotNull,
          },
        );

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
        final syncStatus = await syncManager.getSyncStatus(projectId);
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
        final stateTotals = syncStatus.localStateStats?.totals;
        expect(
          stateTotals,
          isNotNull,
          reason: 'State stats should be available for $projectId',
        );
        final totalsMap = stateTotals?.toJson();
        expect(
          totalsMap,
          equals({
            'creates': 1, // cloud
            'updates': 2, // local (outdated) + cloud winner
            'deletes': 0,
            'total': 3,
            'latestChangeAt': const UtcDateTimeConverter().toJson(
              cloudChange2.changeAt,
            ),
            'latestSeq': 2,
          }),
          reason:
              'After full sync, project $projectId should have 3 total local state changes',
        );

        // confirm cloud state totals
        final cloudTotals = syncStatus.cloudStateStats?.totals;
        expect(
          cloudTotals?.toJson(),
          equals({
            'creates': 1, // cloud
            'updates': 1, // cloud winner
            'deletes': 0,
            'total': 2,
            'latestChangeAt': const UtcDateTimeConverter().toJson(
              cloudChange2.changeAt,
            ),
            'latestSeq': 2,
          }),
          reason:
              'After full sync, project $projectId should have 2 total cloud changes',
        );

        // confirm cloud change totals
        final cloudChangeTotals = syncStatus.cloudChangeStats;
        expect(
          cloudChangeTotals?.toJson(),
          equals({
            'creates': 1, // cloud
            'updates': 1, // cloud winner
            'deletes': 0,
            'total': 3,
            'latestChangeAt': const UtcDateTimeConverter().toJson(
              cloudChange2.changeAt,
            ),
            'latestSeq': 3,
          }),
          reason:
              'After full sync, project $projectId should have 3 total cloud changes',
        );

        final downsyncedState = await getCurrentEntityStateAndCheckCloudAt(
          local,
          projectId,
        );
        expect(
          downsyncedState.data_nameLocal,
          equals(expectedNameLocalAfterDownsync),
          reason:
              'After full sync, local state for project $projectId should reflect cloud change as LWW',
        );
      },
      timeout: Timeout.none,
      // skip: 'fixme',
    );

    test(
      'full sync [pUpdate]: cloud save > downsync > local save [rank, nameLocal] > cloud save [rank] > upsync - pUpdate nameLocal > downsynced cloud changes',
      () async {
        final syncManager = SyncManager.instance;
        final local = LocalStorageService.instance;
        final cloud = CloudStorageService.instance;
        final cloudStorageId = await cloud.getStorageId();

        const projectId = '__test_full_cloud_local_pUpdate';
        final cloudChangeAt1 = DateTime.parse('2024-01-01T12:00:00Z');
        final cloudChange1Rank = '1';
        final cloudChange1NameLocal = 'Edited by cloud-full';
        final localChangeAt = cloudChangeAt1.add(const Duration(minutes: 1));
        final localChangeRank = 'local edit should lose to cloud 2 rank';
        final localChangeNameLocal = 'local edit should win';
        final cloudChangeAt2 = localChangeAt.add(const Duration(minutes: 1));
        final cloudChange2Rank = '2';

        // Save first cloud change that contains 'nameLocal' field that local can overwrite
        // next cloud change will update 'rank', which will be later than local rank change
        final cloudChange1 = await saveCloudChange(
          srcStorageType: srcStorageType,
          srcStorageId: srcStorageId,
          domainId: projectId,
          entityId: projectId,
          changeAt: cloudChangeAt1,
          dataJson: stableStringify({
            ...BaseDataFields(
              parentId: 'root',
              parentProp: 'projects',
            ).toJson(),
            'rank': cloudChange1Rank,
            'nameLocal': cloudChange1NameLocal,
          }),
          userId: 'cloud-full',
          operation: 'create',
          fnGetExpectedChangeUpdates: (cloudSaveChange) => [
            expectedChangeUpdatesFromCreateChange(
              createChange: cloudSaveChange,
              storageId: cloudStorageId,
            ),
          ],
          fnGetExpectedStateUpdates: (change) =>
              expectedStateFromChange(change, isCloudStorage: true),
        );

        await syncManager.initialize();
        syncManager.configureCloudUrl(cloudBaseUrl);
        await syncManager.downsyncFromCloud(domainIds: [projectId]);

        // Save a local change that should be outsynced
        final localChange = IsarChangeLogEntry(
          changeAt: localChangeAt,
          cid: generateCid(
            entityType: EntityType.project,
            userId: 'local-full',
          ),
          domainType: 'project',
          domainId: projectId,
          entityType: 'project',
          operation: 'update',
          entityId: projectId,
          dataJson: stableStringify({
            ...BaseDataFields(
              parentId: 'root',
              parentProp: 'projects',
              rank: localChangeRank, // should lose
            ).toJson(),
            'nameLocal': localChangeNameLocal, // should win
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
        await verifyLocalChangeSaved(
          localSaveResult: localSeed,
          localChange: localChange,
          local: local,
          expectedChangeUpdates: [
            {
              'cid': localChange.cid,
              'updates': {
                'operation': localChange.operation,
                'operationInfoJson':
                    '{"outdatedBys":[],"noOpFields":["parentId","parentProp"]}',
                'stateChanged': true,
                'storageId': await local.getStorageId(),
                'cloudAt': null,
                'storedAt': isA<String>(),
                'dataJson':
                    '{"nameLocal":"$localChangeNameLocal","rank":"$localChangeRank"}',
              },
            },
          ],
          expectedStateUpdates: {
            'domainType': 'project',
            'change_domainId': projectId,
            'change_changeAt': localChange.changeAt.toIso8601String(),
            'change_cid': localChange.cid,
            'change_changeBy': localChange.changeBy,
            'change_storedAt': isNotNull,
            'data_nameLocal': localChangeNameLocal,
            'data_nameLocal_changeAt_': localChange.changeAt.toIso8601String(),
            'data_nameLocal_cid_': localChange.cid,
            'data_nameLocal_changeBy_': localChange.changeBy,
            'data_rank': localChangeRank,
            'data_rank_changeAt_': localChange.changeAt.toIso8601String(),
            'data_rank_cid_': localChange.cid,
            'data_rank_changeBy_': localChange.changeBy,
          },
        );

        // Save second cloud change that contains 'rank' field that should overwrite local change
        final cloudChange2 = await saveCloudChange(
          srcStorageType: srcStorageType,
          srcStorageId: srcStorageId,
          domainId: projectId,
          entityId: projectId,
          changeAt: cloudChangeAt2,
          dataJson: stableStringify({
            ...BaseDataFields(
              parentId: 'root',
              parentProp: 'projects',
              rank: cloudChange2Rank, // should win
            ).toJson(),
          }),
          userId: 'cloud-full',
          operation: 'update',
          fnGetExpectedChangeUpdates: (cloudSaveChange) => [
            {
              'cid': cloudSaveChange.cid,
              'updates': {
                'operation': cloudSaveChange.operation,
                'operationInfoJson':
                    '{"outdatedBys":[],"noOpFields":["parentId","parentProp"]}',
                'stateChanged': true,
                'storageId': cloudStorageId,
                'cloudAt': isA<String>(),
                'storedAt': isA<String>(),
                'dataJson': '{"rank":"$cloudChange2Rank"}',
              },
            },
          ],
          fnGetExpectedStateUpdates: (change) => {
            'domainType': 'project',
            'change_domainId': projectId,
            'change_changeAt': change.changeAt.toIso8601String(),
            'change_cid': change.cid,
            'change_changeBy': change.changeBy,
            'change_storedAt': isNotNull,
            'change_cloudAt': isNotNull,
            'data_rank': cloudChange2Rank,
            'data_rank_changeAt_': change.changeAt.toIso8601String(),
            'data_rank_cid_': change.cid,
            'data_rank_cloudAt_': isNotNull,
            'data_rank_changeBy_': change.changeBy,
          },
        );

        final fullSyncResult = await syncManager.performFullSync(
          domainIds: [projectId],
        );

        expect(
          fullSyncResult.success,
          isTrue,
          reason:
              'Full sync should succeed: \noutsync: ${fullSyncResult.outsyncResult.error}\ndownsync: ${fullSyncResult.downsyncResult.error ?? ''}',
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
            'updates':
                2, // local change [rank, nameLocal] and cloudChange2 [rank]
            'deletes': 0,
            'total': 3,
            'latestChangeAt': const UtcDateTimeConverter().toJson(
              cloudChange2.changeAt,
            ),
            'latestSeq': totalsMap?['latestSeq'],
          }),
          reason:
              'After full sync, project $projectId should have 3 total local state changes',
        );

        // Verify downsynced project exists locally
        final downsyncedState = await getCurrentEntityStateAndCheckCloudAt(
          local,
          projectId,
        );

        // verify expected nameLocal and rank state
        expect(
          downsyncedState.data_nameLocal,
          equals(localChangeNameLocal),
          reason:
              'After full sync, local state for project $projectId should reflect last write wins local nameLocal edit',
        );
        expect(
          downsyncedState.data_nameLocal_changeAt_,
          equals(const UtcDateTimeConverter().toJson(localChange.changeAt)),
          reason:
              'After full sync, local state for project $projectId should reflect last write wins local nameLocal edit',
        );
        expect(
          downsyncedState.data_rank,
          equals(cloudChange2Rank),
          reason:
              'After full sync, local state for project $projectId should reflect last write wins cloud rank edit',
        );
        expect(
          downsyncedState.data_rank_changeAt_,
          equals(const UtcDateTimeConverter().toJson(cloudChange2.changeAt)),
          reason:
              'After full sync, local state for project $projectId should reflect last write wins cloud rank edit',
        );
      },
      timeout: const Timeout(Duration(minutes: 3)),
      // skip: 'fixme',
    );
  });
}

Future<IsarProjectState> getCurrentEntityStateAndCheckCloudAt(
  LocalStorageService local,
  String projectId,
) async {
  final localState =
      await local.getCurrentEntityState(
            entityType: 'project',
            entityId: projectId,
            domainType: 'project',
            domainId: projectId,
          )
          as IsarProjectState;

  expect(
    localState,
    isNotNull,
    reason: 'Local state for project $projectId should exist after full sync',
  );
  expect(
    localState.change_cloudAt,
    isNotNull,
    reason:
        'After full sync, local state for project $projectId should have change_cloudAt set',
  );
  return localState;
}

Future<void> verifyLocalChangeSaved({
  required ChangeProcessingResult localSaveResult,
  required IsarChangeLogEntry localChange,
  required LocalStorageService local,
  required List<Map<String, dynamic>> expectedChangeUpdates,
  required Map<String, dynamic> expectedStateUpdates,
}) async {
  expect(
    localSaveResult.isSuccess,
    isTrue,
    reason:
        'Saving local storage for full sync should succeed: ${localSaveResult.errorMessage}',
  );
  // Verify local persisted state included change_storedAt.
  final localSaveJsonForAssert = localSaveResult.resultsSummary?.toJson();
  if (localSaveJsonForAssert != null) {
    final stateUpdates = localSaveJsonForAssert['stateUpdates'] as List?;
    if (stateUpdates != null && stateUpdates.isNotEmpty) {
      final state = stateUpdates.first['state'] as Map<String, dynamic>?;
      expect(state, isNotNull);
      expect(
        state!.containsKey('change_storedAt'),
        isTrue,
        reason: 'local save state must include change_storedAt',
      );
      final storedAt = state['change_storedAt'] as String?;
      expect(storedAt, isNotNull);
    }
  }
  final localStateUpdates = [
    {'cid': localChange.cid, 'state': expectedStateUpdates},
  ];
  final localInfo = [
    {
      'cid': localChange.cid,
      'operation': localChange.operation,
      'info': jsonDecode(
        expectedChangeUpdates.first['updates']!['operationInfoJson'],
      ),
    },
  ];
  expect(
    localSaveJsonForAssert,
    equals({
      'storageType': 'local',
      'storageId': await local.getStorageId(),
      'stateUpdates': localStateUpdates,
      'changeUpdates': expectedChangeUpdates,
      'created': [
        localChange.operation == 'create' ? localChange.cid : null,
      ].whereType<String>().toList(),
      'updated': [
        localChange.operation == 'update' ? localChange.cid : null,
      ].whereType<String>().toList(),
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
    reason: 'Saving local storage should process 1 change',
  );
}

/// Very small adapter implementing only the methods SyncManager calls on
/// LocalStorageService. This avoids pulling the full LocalStorageService
/// interface into the test.
// Test adapter removed: tests now use the real LocalStorageService.instance

Map<String, dynamic> expectedChangeUpdatesFromCreateChange({
  required IsarChangeLogEntry createChange,
  required String storageId,
}) {
  if (createChange.operation != kChangeOperationCreate) {
    throw ArgumentError.value(
      createChange.operation,
      'createChange.operation',
      'Expected create operation in ${createChange.toJson()}',
    );
  }
  return {
    'cid': createChange.cid,
    'updates': {
      'operation': createChange.operation,
      'operationInfoJson': '{"outdatedBys":[],"noOpFields":[]}',
      'stateChanged': true,
      'storageId': storageId,
      'cloudAt': isA<String>(),
      'storedAt': isA<String>(),
      'dataJson': createChange.dataJson,
    },
  };
}

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

Future<IsarChangeLogEntry> saveCloudChange({
  required String srcStorageType,
  required String srcStorageId,
  required String domainId,
  required String entityId,
  required DateTime changeAt,
  required String dataJson,
  required String userId,
  required String operation,
  required List<Map<String, dynamic>> Function(IsarChangeLogEntry)
  fnGetExpectedChangeUpdates,
  required Map<String, dynamic> Function(IsarChangeLogEntry)
  fnGetExpectedStateUpdates,
}) async {
  final cloudStorage = CloudStorageService.instance;
  final cloudSaveChange = IsarChangeLogEntry(
    changeAt: changeAt,
    cid: generateCid(entityType: EntityType.project, userId: userId),
    domainType: 'project',
    domainId: domainId,
    entityType: 'project',
    operation: operation,
    entityId: entityId,
    dataJson: dataJson,
    changeBy: userId,
    stateChanged: false,
    storageId: '',
    unknownJson: '{}',
    operationInfoJson: '{}',
  );

  final cloudSaveResult = await ChangeProcessingService.storeChanges(
    storageMode: 'save',
    changes: [cloudSaveChange.toJson()],
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
    storage: cloudStorage,
    includeChangeUpdates: true,
    includeStateUpdates: true,
  );
  expect(
    cloudSaveResult.isSuccess,
    isTrue,
    reason:
        'Saving cloud storage with __test_2 should succeed: ${cloudSaveResult.errorMessage}',
  );

  final cloudStateUpdates = [
    {
      'cid': cloudSaveChange.cid,
      'state': fnGetExpectedStateUpdates(cloudSaveChange),
    },
  ];
  final cloudChangeUpdates = fnGetExpectedChangeUpdates(cloudSaveChange);
  final cloudInfo = [
    {
      'cid': cloudSaveChange.cid,
      'operation': cloudSaveChange.operation,
      'info': jsonDecode(
        cloudChangeUpdates.first['updates']!['operationInfoJson'],
      ),
    },
  ];
  expect(
    cloudSaveResult.resultsSummary?.toJson(),
    equals({
      'storageType': 'cloud',
      'storageId': await cloudStorage.getStorageId(),
      'stateUpdates': cloudStateUpdates,
      'changeUpdates': cloudChangeUpdates,
      'created': [
        cloudSaveChange.operation == kChangeOperationCreate
            ? cloudSaveChange.cid
            : null,
      ].whereType<String>().toList(),
      'updated': [
        cloudSaveChange.operation == kChangeOperationUpdate
            ? cloudSaveChange.cid
            : null,
      ].whereType<String>().toList(),
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
    reason: 'Saving cloud storage should process 1 change',
  );

  // Verify storedAt was set on the persisted state. If the storage
  // implementation also sets a cloudAt timestamp we expect storedAt == cloudAt.
  final cloudSeedJson = cloudSaveResult.resultsSummary?.toJson();
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
  return cloudSaveChange;
}
