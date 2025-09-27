// No top-level dart:io/convert/async imports required after switching to MultiServerLauncher

import 'package:sltt_core/sltt_core.dart';
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
      registerChangeLogEntryFactoryGroup(
        SerializableGroup<BaseChangeLogEntry>(
          fromJson: IsarChangeLogEntry.fromJson,
          fromJsonBase: IsarChangeLogEntry.fromJsonBase,
          toJson: (entry) => (entry as IsarChangeLogEntry).toJson(),
          toJsonBase: (entry) => (entry as IsarChangeLogEntry).toJsonBase(),
          toSafeJson: (original) {
            // Use the common safe JSON service
            return SafeJsonService.generateSafeChangeLogJson(original);
          },
          validate: (entry) async {
            // TODO: Validate the entry dataJson against the schema for the entity type
            // for now just validate BaseDataFields
            BaseDataFields.fromJson(entry.getData());
          },
        ),
      );

      // Start the in-process cloud server using MultiServerLauncher.
      final storageInfo = await MultiServerLauncher.instance.startServer(
        StorageType.cloud,
        kCloudStoragePort,
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
      final cloudStorage = CloudStorageService.instance;
      await cloudStorage.initialize();
      await cloudStorage.testResetDomainStorage(
        domainType: 'project',
        domainId: '__test_1',
      );
      await cloudStorage.testResetDomainStorage(
        domainType: 'project',
        domainId: '__test_2',
      );

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

      // Initialize the real LocalStorageService and seed it via
      // ChangeProcessingService (save mode). This ensures the Isar-backed
      // LocalStorageService contains the change entries.
      final local = LocalStorageService.instance;
      await local.initialize();
      final localStorageId = await local.getStorageId();
      await local.testResetDomainStorage(
        domainType: 'project',
        domainId: '__test_1',
      );
      await local.testResetDomainStorage(
        domainType: 'project',
        domainId: '__test_2',
      );

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

      // Ensure local storage is initialized and cleared for this test
      final local = LocalStorageService.instance;
      await local.initialize();
      await local.testResetDomainStorage(
        domainType: 'project',
        domainId: '__test_1',
      );
      await local.testResetDomainStorage(
        domainType: 'project',
        domainId: '__test_2',
      );
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
      final projects = await local.getAllDomainIds(domainType: 'project');
      expect(
        projects,
        contains('__test_2'),
        reason:
            'Local storage should contain the cloud test project __test_2 after downsync',
      );
    });
  });
}

/// Very small adapter implementing only the methods SyncManager calls on
/// LocalStorageService. This avoids pulling the full LocalStorageService
/// interface into the test.
// Test adapter removed: tests now use the real LocalStorageService.instance
