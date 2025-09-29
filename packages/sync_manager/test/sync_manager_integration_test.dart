import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/test_helpers/isar_change_log_serializer.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

// helper removed; tests now use LocalStorageService.instance for seeding

// Integration tests for SyncManager using a local cloud server launched by
// multi_server_launcher. These tests exercise two scenarios:
// 1) Local storage starts with changes to outsync (outsync -> cloud)
// 2) Cloud storage starts with changes to downsync (downsync -> local)

void main() {
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
        print('[test] Warning: failed to delete local database: $e');
      }
      await local.initialize();

      final cloudStorage = CloudStorageService.instance;
      try {
        await cloudStorage.deleteDatabase();
      } catch (e) {
        print('[test] Warning: failed to delete cloud database: $e');
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

      final cloudSeedResult = await ChangeProcessingService.processChanges(
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

      final seedResult = await ChangeProcessingService.processChanges(
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
      expect(
        seedResult.resultsSummary?.toJson(),
        equals({
          'storageType': 'local',
          'storageId': localStorageId,
          'stateUpdates': isA<List<Map<String, dynamic>>>(),
          'changeUpdates': isA<List<Map<String, dynamic>>>(),
          'created': [change.cid],
          'updated': [],
          'deleted': [],
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
          'latestChangeAt': isA<String>(),
          'latestSeq': isA<int>(),
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
      expect(
        status.localStateStats?.totals.toJson(),
        equals({
          'creates': 1,
          'updates': 0,
          'deletes': 0,
          'total': 1,
          'latestChangeAt': isA<String>(),
          'latestSeq': isA<int>(),
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
      'full sync: outsynced OUTDATED local changes and downsynced cloud changes',
      () async {
        final syncManager = SyncManager.instance;
        final local = LocalStorageService.instance;
        final cloud = CloudStorageService.instance;

        const cloudProjectId = '__test_full_cloud';

        // Seed a local change that should be outsynced
        final localChange = IsarChangeLogEntry(
          changeAt: DateTime.now(),
          cid: generateCid(
            entityType: EntityType.project,
            userId: 'local-full',
          ),
          domainType: 'project',
          domainId: cloudProjectId,
          entityType: 'project',
          operation: 'create',
          entityId: cloudProjectId,
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

        final localSeed = await ChangeProcessingService.processChanges(
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
          domainId: cloudProjectId,
          entityType: 'project',
          operation: 'create',
          entityId: cloudProjectId,
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

        final cloudSeed = await ChangeProcessingService.processChanges(
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

        expect(
          cloudSeed.resultsSummary?.toJson(),
          equals({
            'storageType': 'cloud',
            'storageId': await cloud.getStorageId(),
            'stateUpdates': isA<List<Map<String, dynamic>>>(),
            'changeUpdates': isA<List<Map<String, dynamic>>>(),
            'created': [cloudChange.cid],
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
          reason: 'Seeding cloud storage should process 1 change',
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
              .any((change) => change['entityId'] == cloudProjectId),
          isTrue,
          reason: 'Downsync should include the cloud project change',
        );

        // Verify outsynced project has no pending local-origin changes
        final localStatus = await syncManager.getSyncStatus(cloudProjectId);
        final pendingLocalChanges = await local.getChangesWithCursor(
          domainType: 'project',
          domainId: cloudProjectId,
        );

        expect(
          pendingLocalChanges,
          isEmpty,
          reason:
              'Full sync should remove local-origin change log entries for $cloudProjectId, but got: ${(pendingLocalChanges).map((c) => c.toJson())}',
        );

        final totals = localStatus.localChangeStats?.totals;
        expect(
          totals,
          isNotNull,
          reason: 'Change stats should be available for $cloudProjectId',
        );
        expect(totals?.toJson(), {
          'creates': 1,
          'updates': 0,
          'deletes': 0,
          'total': 1,
          'latestChangeAt': isA<String>(),
          'latestSeq': isA<int>(),
        });

        // Verify downsynced project exists locally
        final downsyncedState = await local.getCurrentEntityState(
          domainType: 'project',
          domainId: cloudProjectId,
          entityType: 'project',
          entityId: cloudProjectId,
        );
        expect(
          downsyncedState,
          isNotNull,
          reason: 'Downsynced project should exist in local storage',
        );
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}

/// Very small adapter implementing only the methods SyncManager calls on
/// LocalStorageService. This avoids pulling the full LocalStorageService
/// interface into the test.
// Test adapter removed: tests now use the real LocalStorageService.instance
