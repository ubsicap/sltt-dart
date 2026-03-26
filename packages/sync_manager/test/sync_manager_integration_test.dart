import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/user_preferences.data.dart';
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

  // Group 1: Tests with Isar-backed cloud storage (in-process)
  group('[isar] SyncManager integration (Isar cloud)', () {
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

    tearDown(() async {
      // Ensure background queue jobs are disposed between tests so they do not
      // continue hitting a torn-down local cloud server.
      await SyncManager.instance.close();
    });

    tearDownAll(() async {
      await SyncManager.instance.close();
      await MultiServerLauncher.instance.stopServer(StorageType.cloud);
    });

    test(
      '[isar] outsync [create]: save local changes > outsync to cloud',
      () async {
        await testOutsyncCreate(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: false,
        );
      },
    );

    test(
      '[isar] downsync [create]: save cloud changes > downsync to local',
      () async {
        await testDownsyncCreate(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: false,
        );
      },
    );

    test(
      '[isar] downsync [user preferences]: downsync user_preferences domain',
      () async {
        await testUserDomainDownsync(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: false,
        );
      },
    );

    test(
      '[isar] downsync [stateChanged=false warning]: sync no-op change warning pre-enqueues refetch regardless of storage id',
      () async {
        await testDownsyncStateChangedFalseWarningQueuesRefetch(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: false,
        );
      },
      timeout: Timeout.none,
    );

    test(
      '[isar] downsync [stateChanged=false warning same-storage]: sync no-op warning pre-enqueues refetch for same storage id',
      () async {
        await testDownsyncStateChangedFalseWarningSameStorageIdPreEnqueuesRefetch(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: false,
        );
      },
      timeout: Timeout.none,
    );

    test(
      '[isar] full sync [create]: save local changes > outsync to cloud > downsync same',
      () async {
        await testFullSyncCreate(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: false,
        );
      },
      timeout: Timeout.none,
    );

    test(
      '[isar] full sync [update]: cloud save > downsync > local save > outsync to cloud > downsynced cloud changes',
      () async {
        await testFullSyncUpdate(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: false,
        );
      },
      timeout: Timeout.none,
    );

    test(
      '[isar] full sync [outdated]: save cloud change > downsync > save local changes > save cloud change > upsync local changes - OUTDATED > downsynced cloud changes',
      () async {
        await testFullSyncOutdated(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: false,
        );
      },
      timeout: Timeout.none,
    );

    test(
      '[isar] full sync [partialUpdate]: cloud save > downsync > local save [rank, nameLocal] > cloud save [rank] > upsync - pUpdate nameLocal > downsynced cloud changes',
      () async {
        await testFullSyncPartialUpdate(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: false,
        );
      },
      timeout: Timeout.none,
    );
  });

  // Group 2: Tests with cloud storage (HTTP)
  group('[aws_backend] SyncManager integration', () {
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

      // Use cloud URL from environment or default to dev
      cloudBaseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
      srcStorageId = 'test-storage';
      srcStorageType = 'cloud';
    });

    tearDown(() async {
      // Dispose queue/retries after each aws integration test to keep logs and
      // teardown behavior deterministic.
      await SyncManager.instance.close();
    });

    test(
      '[aws_backend] outsync [create]: save local changes > outsync to cloud',
      () async {
        await testOutsyncCreate(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: true,
        );
      },
    );

    test(
      '[aws_backend] downsync [create]: save cloud changes > downsync to local',
      () async {
        await testDownsyncCreate(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: true,
        );
      },
    );

    test(
      '[aws_backend] downsync [user preferences]: downsync user_preferences domain',
      () async {
        await testUserDomainDownsync(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: true,
        );
      },
    );

    test(
      '[aws_backend] downsync [stateChanged=false warning]: sync no-op change warning pre-enqueues refetch regardless of storage id',
      () async {
        await testDownsyncStateChangedFalseWarningQueuesRefetch(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: true,
        );
      },
      timeout: Timeout.none,
    );

    test(
      '[aws_backend] downsync [stateChanged=false warning same-storage]: sync no-op warning pre-enqueues refetch for same storage id',
      () async {
        await testDownsyncStateChangedFalseWarningSameStorageIdPreEnqueuesRefetch(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: true,
        );
      },
      timeout: Timeout.none,
    );

    test(
      '[aws_backend] full sync [create]: save local changes > outsync to cloud > downsync same',
      () async {
        await testFullSyncCreate(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: true,
        );
      },
      timeout: Timeout.none,
    );

    test(
      '[aws_backend] full sync [update]: cloud save > downsync > local save > outsync to cloud > downsynced cloud changes',
      () async {
        await testFullSyncUpdate(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: true,
        );
      },
      timeout: Timeout.none,
    );

    test(
      '[aws_backend] full sync [outdated]: save cloud change > downsync > save local changes > save cloud change > upsync local changes - OUTDATED > downsynced cloud changes',
      () async {
        await testFullSyncOutdated(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: true,
        );
      },
      timeout: Timeout.none,
    );

    test(
      '[aws_backend] full sync [pUpdate]: cloud save > downsync > local save [rank, nameLocal] > cloud save [rank] > upsync - pUpdate nameLocal > downsynced cloud changes',
      () async {
        await testFullSyncPartialUpdate(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: srcStorageId,
          srcStorageType: srcStorageType,
          useCloudDb: true,
        );
      },
      timeout: Timeout.none,
    );
  });
}

// ============================================================================
// Individual Test Functions
// ============================================================================

/// Test outsync: save local changes > outsync to cloud
Future<void> testOutsyncCreate({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  bool useCloudDb = false,
}) async {
  final syncManager = SyncManager.instance;
  final local = LocalStorageService.instance;
  final localStorageId = await local.getStorageId();

  const projectId = '__test_outsync_create';

  // Reset project if using Cloud
  if (useCloudDb) {
    await resetDomainId(cloudBaseUrl, projectId);
  }

  final changeBy = 'test';
  final change =
      ChangeLogEntryFactoryService.forChangeSave<
        IsarChangeLogEntry,
        Id,
        BaseDataFields
      >(
        factory: IsarChangeLogEntry.new,
        domainType: 'project',
        domainId: projectId,
        entityType: 'project',
        entityId: projectId,
        changeBy: changeBy,
        changeAt: DateTime.now(),
        cid: generateCid(entityType: EntityType.project, userId: changeBy),
        data: BaseDataFields(parentId: 'root', parentProp: 'projects'),
        operation: 'create',
      );

  final changeOtherDomainId =
      ChangeLogEntryFactoryService.forChangeSave<
        IsarChangeLogEntry,
        Id,
        BaseDataFields
      >(
        factory: IsarChangeLogEntry.new,
        domainType: 'project',
        domainId: '${projectId}_other',
        entityType: 'project',
        entityId: '${projectId}_other',
        changeBy: changeBy,
        changeAt: DateTime.now(),
        cid: generateCid(entityType: EntityType.project, userId: changeBy),
        data: BaseDataFields(parentId: 'root', parentProp: 'projects'),
        operation: 'create',
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
        'stateDataHash': isA<String>(),
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

  final localSaveResultOther = await ChangeProcessingService.storeChanges(
    storageMode: 'save',
    changes: [changeOtherDomainId.toJson()],
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
    storage: local,
    includeChangeUpdates: true,
    includeStateUpdates: true,
  );

  final savedChangeUpdatesOther = [
    {
      'cid': changeOtherDomainId.cid,
      'updates': {
        'operation': changeOtherDomainId.operation,
        'operationInfoJson': '{"outdatedBys":[],"noOpFields":[]}',
        'stateChanged': true,
        'storageId': localStorageId,
        'cloudAt': null,
        'storedAt': isA<String>(),
        'dataJson': changeOtherDomainId.dataJson,
        'stateDataHash': isA<String>(),
      },
    },
  ];

  await verifyLocalChangeSaved(
    localSaveResult: localSaveResultOther,
    localChange: changeOtherDomainId,
    local: local,
    expectedChangeUpdates: savedChangeUpdatesOther,
    expectedStateUpdates: expectedStateFromChange(changeOtherDomainId),
  );

  await syncManager.initialize();
  syncManager.configureCloudUrl(cloudBaseUrl);

  final result = await syncManager.outsyncToCloud(domainIds: [projectId]);

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
    reason: 'Outsync summary should only include the local-origin change cid',
  );
  // Use SyncManager.getSyncStatus to confirm the project has no pending outsyncs
  final status = await syncManager.getSyncStatus(projectId);
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
        'After successful outsync, project $projectId should have 0 pending outsyncs',
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
      'latestChangeAt': change.changeAt.toUtc().toIso8601String(),
      'latestSeq': 1,
    }),
    reason:
        'After successful outsync, project $projectId should have change logs in the cloud',
  );

  final statusOther = await syncManager.getSyncStatus('${projectId}_other');
  expect(
    statusOther.cloudStateStats?.totals.toJson(),
    equals({
      'creates': 0,
      'updates': 0,
      'deletes': 0,
      'total': 0,
      'latestChangeAt': useCloudDb
          ? '1970-01-01T00:00:00.000Z'
          : '1970-01-01T00:00:00Z',
      'latestSeq': -1,
    }),
    reason:
        'Outsync of $projectId should not affect cloud state stats of ${projectId}_other',
  );
}

/// Test downsync: save cloud changes > downsync to local
Future<void> testDownsyncCreate({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  bool useCloudDb = false,
}) async {
  final projectId = '__test_downsync_create';

  // Reset project if using Cloud
  if (useCloudDb) {
    await resetDomainId(cloudBaseUrl, projectId);
  }

  final cloudChange = await saveCloudChangeViaHttp(
    cloudBaseUrl: cloudBaseUrl,
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
    fromJson: ProjectDataFields.fromJson,
  );
  final syncManager = SyncManager.instance;
  await syncManager.initialize();
  syncManager.configureCloudUrl(cloudBaseUrl);

  // Trigger downsync; the cloud server should start with a __test_downsync_create project
  final downsyncResult = await syncManager.downsyncFromCloud(
    domainIds: [projectId],
  );

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
    reason: 'Downsync should emit at least one change for the seeded project',
  );
  expect(
    downsyncedChanges
        .map((change) => change['cloudAt'])
        .every((c) => c != null),
    isTrue,
    reason:
        'Downsynced change payloads must include cloudAt to mark cloud origin, but got: $downsyncedChanges',
  );

  final status = await syncManager.getSyncStatus('__test_downsync_create');
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
        'getSyncStatus should report local state stats for __test_downsync_create after downsync',
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

  // Verify local storage has received changes for __test_downsync_create and report status via SyncManager
  final local = LocalStorageService.instance;
  final projects = await local.getAllDomainIds(domainType: 'project');
  expect(
    projects,
    contains(projectId),
    reason:
        'Local storage should contain the cloud test project $projectId after downsync',
  );

  await getCurrentEntityStateAndCheckCloudAt(local, projectId);
}

/// Test downsync flow for user_preferences domain
Future<void> testUserDomainDownsync({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  bool useCloudDb = false,
}) async {
  final userId = '__test_user_preferences';

  // Reset test domain when using Cloud
  if (useCloudDb) {
    await resetDomainId(
      cloudBaseUrl,
      userId,
      domainCollection: kCollectionUser,
    );
  }

  final cloudChange = await saveCloudChangeViaHttp(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
    domainId: userId,
    entityId: kEntityIdDefaultUserPreferences,
    changeAt: DateTime.now(),
    dataJson: stableStringify(
      UserPreferencesData(
        parentId: 'root',
        parentProp: 'user_preferences',
        uiLocale: 'en-US',
      ).toJson(),
    ),
    userId: '__test_x',
    operation: 'create',
    domainType: DomainType.user,
    entityType: EntityType.userPreferences,
    fromJson: UserPreferencesData.fromJson,
  );

  final syncManager = SyncManager.instance;
  await syncManager.initialize();
  syncManager.configureCloudUrl(cloudBaseUrl);

  final downsyncResult = await syncManager.downsyncFromCloud(
    domainIds: [userId],
    domainType: DomainType.user.value,
  );

  expect(
    downsyncResult.success,
    isTrue,
    reason: 'User domain downsync should succeed: ${downsyncResult.error}',
  );

  final local = LocalStorageService.instance;
  final domains = await local.getAllDomainIds(
    domainType: DomainType.user.value,
  );
  expect(domains, contains(userId));

  final state = await local.getEntityState(
    entityType: kEntityTypeUserPreferences,
    entityId: kEntityIdDefaultUserPreferences,
    domainType: DomainType.user.value,
    domainId: userId,
  );
  expect(
    state,
    isNotNull,
    reason: 'User preferences state should exist locally',
  );

  // confirm cloud state totals
  final status = await syncManager.getSyncStatus(
    userId,
    domainType: DomainType.user.value,
  );
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
        'After user domain downsync, user $userId should have 1 total cloud change',
  );
}

Future<void> testDownsyncStateChangedFalseWarningQueuesRefetch({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  bool useCloudDb = false,
}) async {
  final projectId = '__test_downsync_statechanged_false_warning';

  if (useCloudDb) {
    await resetDomainId(cloudBaseUrl, projectId);
  }

  await saveCloudChangeViaHttp(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
    domainId: projectId,
    entityId: projectId,
    changeAt: DateTime.now().toUtc().subtract(const Duration(minutes: 2)),
    dataJson: stableStringify(
      BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
    ),
    userId: 'test-seed',
    operation: 'create',
    fromJson: ProjectDataFields.fromJson,
  );

  final syncNoOpChange = IsarChangeLogEntry(
    seq: 2,
    cid: generateCid(entityType: EntityType.project, userId: 'sync-noop'),
    storageId: 'sender-storage',
    domainType: 'project',
    domainId: projectId,
    entityType: 'project',
    entityId: projectId,
    operation: 'update',
    operationInfoJson: jsonEncode({}),
    stateChanged: true,
    stateDataHash: 'incoming-mismatched-state-data-hash',
    changeAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
    dataJson: stableStringify(
      BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
    ),
    changeBy: 'sync-noop',
    unknownJson: jsonEncode({}),
  );

  final syncReq = CreateChangesRequest(
    changes: [syncNoOpChange],
    srcStorageType: 'local',
    srcStorageId: 'sender-storage',
    storageMode: 'sync',
    includeChangeUpdates: true,
    includeStateUpdates: true,
  );

  final syncResp = await http.post(
    Uri.parse('$cloudBaseUrl/api/changes'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(syncReq.toJson()),
  );
  expect(
    syncResp.statusCode,
    anyOf([200, 201]),
    reason:
        'sync-mode cloud save should succeed, got ${syncResp.statusCode}: ${syncResp.body}',
  );

  final syncRespJson = jsonDecode(syncResp.body) as Map<String, dynamic>;
  expect(
    syncRespJson['errors'],
    isEmpty,
    reason: 'sync-mode cloud save should have no errors: ${syncResp.body}',
  );

  final syncManager = SyncManager.instance;
  await syncManager.initialize();
  syncManager.configureCloudUrl(cloudBaseUrl);

  final queue = syncManager.entityStatePaginationService;
  queue.stopProcessing();
  final beforeQueuedSingleCount = queue.queuedSingleJobCount;

  final downsyncResult = await syncManager.downsyncFromCloud(
    domainIds: [projectId],
  );

  expect(
    downsyncResult.success,
    isTrue,
    reason:
        'stateChanged=false warning downsync should succeed: ${downsyncResult.error}',
  );

  final downloadedChanges = downsyncResult.projectCursorChanges.values
      .expand((changes) => changes)
      .toList();
  final downloadedSyncNoOp = downloadedChanges.firstWhere(
    (c) => c['cid'] == syncNoOpChange.cid,
    orElse: () => <String, dynamic>{},
  );

  expect(
    downloadedSyncNoOp,
    isNotEmpty,
    reason:
        'expected to download sync no-op change ${syncNoOpChange.cid}, got: $downloadedChanges',
  );
  expect(downloadedSyncNoOp['stateChanged'], isFalse);

  final operationInfo =
      jsonDecode(downloadedSyncNoOp['operationInfoJson'] as String)
          as Map<String, dynamic>;
  final warnings =
      operationInfo['warnings'] as Map<String, dynamic>? ?? <String, dynamic>{};
  expect(
    warnings['stateDataHash'],
    equals('incoming-mismatched-state-data-hash'),
  );

  await Future<void>.delayed(const Duration(milliseconds: 450));

  expect(
    queue.queuedSingleJobCount,
    greaterThan(beforeQueuedSingleCount),
    reason:
        'warning-based stateChanged=false reconciliation should pre-enqueue refetch even when sender storageId differs from current storageId',
  );

  queue.resumeProcessing();
}

Future<void>
testDownsyncStateChangedFalseWarningSameStorageIdPreEnqueuesRefetch({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  bool useCloudDb = false,
}) async {
  final projectId = '__test_downsync_statechanged_false_warning_same_storage';

  if (useCloudDb) {
    await resetDomainId(cloudBaseUrl, projectId);
  }

  await saveCloudChangeViaHttp(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
    domainId: projectId,
    entityId: projectId,
    changeAt: DateTime.now().toUtc().subtract(const Duration(minutes: 2)),
    dataJson: stableStringify(
      BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
    ),
    userId: 'test-seed',
    operation: 'create',
    fromJson: ProjectDataFields.fromJson,
  );

  final localStorageId = await LocalStorageService.instance.getStorageId();

  final syncNoOpChange = IsarChangeLogEntry(
    seq: 2,
    cid: generateCid(
      entityType: EntityType.project,
      userId: 'sync-noop-same-storage',
    ),
    storageId: localStorageId,
    domainType: 'project',
    domainId: projectId,
    entityType: 'project',
    entityId: projectId,
    operation: 'update',
    operationInfoJson: jsonEncode({}),
    stateChanged: true,
    stateDataHash: 'incoming-mismatched-state-data-hash',
    changeAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
    dataJson: stableStringify(
      BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
    ),
    changeBy: 'sync-noop-same-storage',
    unknownJson: jsonEncode({}),
  );

  final syncReq = CreateChangesRequest(
    changes: [syncNoOpChange],
    srcStorageType: 'local',
    srcStorageId: localStorageId,
    storageMode: 'sync',
    includeChangeUpdates: true,
    includeStateUpdates: true,
  );

  final syncResp = await http.post(
    Uri.parse('$cloudBaseUrl/api/changes'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(syncReq.toJson()),
  );
  expect(
    syncResp.statusCode,
    anyOf([200, 201]),
    reason:
        'sync-mode cloud save should succeed, got ${syncResp.statusCode}: ${syncResp.body}',
  );

  final syncRespJson = jsonDecode(syncResp.body) as Map<String, dynamic>;
  expect(
    syncRespJson['errors'],
    isEmpty,
    reason: 'sync-mode cloud save should have no errors: ${syncResp.body}',
  );

  final syncManager = SyncManager.instance;
  await syncManager.initialize();
  syncManager.configureCloudUrl(cloudBaseUrl);

  final queue = syncManager.entityStatePaginationService;
  queue.stopProcessing();
  final beforeQueuedSingleCount = queue.queuedSingleJobCount;

  final downsyncResult = await syncManager.downsyncFromCloud(
    domainIds: [projectId],
  );

  expect(
    downsyncResult.success,
    isTrue,
    reason:
        'stateChanged=false warning downsync should succeed: ${downsyncResult.error}',
  );

  final downloadedChanges = downsyncResult.projectCursorChanges.values
      .expand((changes) => changes)
      .toList();
  final downloadedSyncNoOp = downloadedChanges.firstWhere(
    (c) => c['cid'] == syncNoOpChange.cid,
    orElse: () => <String, dynamic>{},
  );

  expect(
    downloadedSyncNoOp,
    isNotEmpty,
    reason:
        'expected to download sync no-op change ${syncNoOpChange.cid}, got: $downloadedChanges',
  );
  expect(downloadedSyncNoOp['stateChanged'], isFalse);

  final operationInfo =
      jsonDecode(downloadedSyncNoOp['operationInfoJson'] as String)
          as Map<String, dynamic>;
  final warnings =
      operationInfo['warnings'] as Map<String, dynamic>? ?? <String, dynamic>{};
  expect(
    warnings['stateDataHash'],
    equals('incoming-mismatched-state-data-hash'),
  );

  await Future<void>.delayed(const Duration(milliseconds: 450));

  expect(
    queue.queuedSingleJobCount,
    greaterThan(beforeQueuedSingleCount),
    reason: 'same-storage warning reconciliation should pre-enqueue refetch',
  );

  queue.resumeProcessing();
}

/// Test full sync [create]: save local changes > outsync to cloud > downsync same
Future<void> testFullSyncCreate({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  bool useCloudDb = false,
}) async {
  final syncManager = SyncManager.instance;
  final local = LocalStorageService.instance;

  final expectedNameLocalUpdate = 'Edited by local-full';

  const projectId = '__test_full_sync_create';

  // Reset project if using Cloud
  if (useCloudDb) {
    await resetDomainId(cloudBaseUrl, projectId);
  }

  final localChange =
      ChangeLogEntryFactoryService.forChangeSave<
        IsarChangeLogEntry,
        Id,
        ProjectDataFields
      >(
        factory: IsarChangeLogEntry.new,
        domainType: 'project',
        domainId: projectId,
        entityType: 'project',
        entityId: projectId,
        changeBy: 'local-full',
        changeAt: DateTime.now(),
        data: ProjectDataFields(
          parentId: 'root',
          parentProp: 'projects',
          nameLocal: expectedNameLocalUpdate,
        ),
        operation: 'create',
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
    reason: 'Full sync should succeed: ${fullSyncResult.downsyncResult.error}',
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

  final localCursorState = status.localCursorState;
  expect(
    localCursorState,
    isNotNull,
    reason: 'Local cursor state should be available for $projectId',
  );

  expect(
    localCursorState?.seq,
    equals(1),
    reason:
        'After full sync, sync cursor state seq should update to the latest cloud change',
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

  IsarProjectState localState = await getCurrentEntityStateAndCheckCloudAt(
    local,
    projectId,
  );

  // verify expected nameLocal state
  expect(
    localState.data_nameLocal,
    equals(expectedNameLocalUpdate),
    reason:
        'After full sync, local state for project $projectId should reflect last write wins local edit',
  );
}

/// Test full sync [update]: cloud save > downsync > local save > outsync to cloud > downsynced cloud changes
Future<void> testFullSyncUpdate({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  bool useCloudDb = false,
}) async {
  final syncManager = SyncManager.instance;
  final local = LocalStorageService.instance;

  // seed cloud first then local so local lww change wins
  const projectId = '__test_full_cloud_local_lww';
  final cloudChangeAt = DateTime.now().subtract(const Duration(minutes: 1));
  const expectedNameLocalUpdate = 'Edited by local-full';

  // Reset project if using Cloud
  if (useCloudDb) {
    await resetDomainId(cloudBaseUrl, projectId);
  }

  await saveCloudChangeViaHttp(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
    domainId: projectId,
    entityId: projectId,
    changeAt: cloudChangeAt,
    dataJson: stableStringify({
      ...BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
      'nameLocal': 'Edited by cloud-full',
    }),
    userId: 'cloud-full',
    operation: 'create',
    fromJson: ProjectDataFields.fromJson,
  );
  await syncManager.initialize();
  syncManager.configureCloudUrl(cloudBaseUrl);
  await syncManager.downsyncFromCloud(domainIds: [projectId]);
  final localChangeAt = DateTime.now().toUtc();
  final localChange =
      ChangeLogEntryFactoryService.forChangeSave<
        IsarChangeLogEntry,
        Id,
        ProjectDataFields
      >(
        factory: IsarChangeLogEntry.new,
        domainType: 'project',
        domainId: projectId,
        entityType: 'project',
        entityId: projectId,
        changeBy: 'local-full',
        changeAt: localChangeAt,
        data: ProjectDataFields(
          parentId: 'root',
          parentProp: 'projects',
          nameLocal: expectedNameLocalUpdate,
        ),
        operation: 'update',
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
          'stateDataHash': isA<String>(),
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
      'stateDataHash': isA<String>(),
    },
  );
  final fullSyncResult = await syncManager.performFullSync(
    domainIds: [projectId],
  );
  expect(
    fullSyncResult.success,
    isTrue,
    reason: 'Full sync should succeed: ${fullSyncResult.downsyncResult.error}',
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

  // make sure sync cursor seq matches the latest change
  final localCursorState = status.localCursorState;
  expect(
    localCursorState,
    isNotNull,
    reason: 'Local cursor state should be available for $projectId',
  );

  expect(
    localCursorState?.seq,
    equals(2),
    reason:
        'After full sync, sync cursor state seq should update for the latest cloud change',
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
}

/// Test full sync with outdated local change
Future<void> testFullSyncOutdated({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  bool useCloudDb = false,
}) async {
  final syncManager = SyncManager.instance;
  final local = LocalStorageService.instance;
  final expectedOutdatedNameLocalUpdate =
      'Expected outdated edit by local-full';
  final expectedNameLocalAfterDownsync = 'Expected winning edit by cloud-full';

  const projectId = '__test_full_cloud_local_outdated';

  // Reset project if using Cloud
  if (useCloudDb) {
    await resetDomainId(cloudBaseUrl, projectId);
  }

  // Save a cloud change that should be downsynced
  await saveCloudChangeViaHttp(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
    domainId: projectId,
    entityId: projectId,
    changeAt: DateTime.now(),
    dataJson: stableStringify({
      ...BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
      'nameLocal': 'Created by cloud-full',
    }),
    userId: 'cloud-full',
    operation: kChangeOperationCreate,
    fromJson: ProjectDataFields.fromJson,
  );

  await syncManager.initialize();
  syncManager.configureCloudUrl(cloudBaseUrl);
  await syncManager.downsyncFromCloud(domainIds: [projectId]);

  // Save a local change that should be outsynced
  final localChange =
      ChangeLogEntryFactoryService.forChangeSave<
        IsarChangeLogEntry,
        Id,
        ProjectDataFields
      >(
        factory: IsarChangeLogEntry.new,
        domainType: 'project',
        domainId: projectId,
        entityType: 'project',
        operation: kChangeOperationUpdate,
        entityId: projectId,
        changeBy: 'local-full',
        changeAt: DateTime.now().toUtc(),
        data: ProjectDataFields(
          parentId: 'root',
          parentProp: 'projects',
          nameLocal: expectedOutdatedNameLocalUpdate,
        ),
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
          'stateDataHash': isA<String>(),
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
      'stateDataHash': isA<String>(),
    },
  );

  // Save a cloud change that trumps local change
  final cloudChange2 = await saveCloudChangeViaHttp(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
    domainId: projectId,
    entityId: projectId,
    changeAt: DateTime.now().add(const Duration(seconds: 1)).toUtc(),
    dataJson: stableStringify({
      ...BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
      'nameLocal': expectedNameLocalAfterDownsync,
    }),
    userId: 'cloud-full',
    operation: 'update',
    fromJson: ProjectDataFields.fromJson,
  );

  // first downsync from cloud to get the trump change
  final downsyncResult = await syncManager.downsyncFromCloud(
    domainIds: [projectId],
  );

  expect(
    downsyncResult.projectCursorChanges.values
        .expand((changes) => changes)
        .any((change) => change['entityId'] == projectId),
    isTrue,
    reason: 'Downsync should include the cloud project change',
  );

  // make sure local state reflects the trump change even though we still have an outgoing change
  final localStateAfterDownsync = await getCurrentEntityStateAndCheckCloudAt(
    local,
    projectId,
  );
  expect(
    localStateAfterDownsync.data_nameLocal,
    equals(expectedNameLocalAfterDownsync),
    reason:
        'After downsync, local state for project $projectId should reflect cloud change as LWW data_nameLocal_changeAt_ (cloud): ${cloudChange2.changeAt} vs. local: ${localStateAfterDownsync.data_nameLocal_changeAt_}',
  );

  // make sure outsync is still pending after downsync
  final pendingLocalChanges1 = (await local.getChangesWithCursor(
    domainType: 'project',
    domainId: projectId,
  )).map((c) => c as IsarChangeLogEntry).toList();
  expect(
    pendingLocalChanges1,
    hasLength(1),
    reason:
        'Downsync should leave local-origin change log entries for $projectId, but got: ${(pendingLocalChanges1).map((c) => c.toJson())}',
  );

  // now perform full sync to outsync local outdated change and downsync outdated cursor
  final fullSyncResult = await syncManager.performFullSync(
    domainIds: [projectId],
  );

  expect(
    fullSyncResult.success,
    isTrue,
    reason: 'Full sync should succeed: ${fullSyncResult.downsyncResult.error}',
  );
  expect(
    fullSyncResult.outsyncResult.deletedLocalChanges,
    contains(localChange.cid),
    reason: 'Full sync should remove outsynced local change from storage',
  );
  final fullSyncDownsyncedChanges = fullSyncResult
      .downsyncResult
      .projectCursorChanges
      .values
      .expand((changes) => changes)
      .toList();
  expect(
    fullSyncDownsyncedChanges,
    isNotEmpty,
    reason:
        'Downsync should include the local outdated change as a synced cursor update',
  );
  final outdatedDownsyncedChange = fullSyncDownsyncedChanges.firstWhere(
    (change) =>
        change['cid'] == localChange.cid &&
        change['operation'] == 'outdated' &&
        change['stateChanged'] == false,
    orElse: () => <String, dynamic>{},
  );
  expect(
    outdatedDownsyncedChange,
    isNotEmpty,
    reason:
        'Downsync should include an outdated/stateChanged=false cursor change for local cid ${localChange.cid}',
  );

  // Verify outsynced project has no pending local-origin changes
  final pendingLocalChanges2 = await local.getChangesWithCursor(
    domainType: 'project',
    domainId: projectId,
  );

  expect(
    pendingLocalChanges2,
    isEmpty,
    reason:
        'Full sync should remove local-origin change log entries for $projectId, but got: ${(pendingLocalChanges2).map((c) => c.toJson())}',
  );

  // After full sync and deletion of local change-log entries, pending
  // change stats will be empty. Verify the historical state counters
  // (localStateStats) still reflect the operation that occurred.
  final syncStatus = await syncManager.getSyncStatus(projectId);
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

  // make sure sync cursor seq matches the outdated change
  final localCursorState = syncStatus.localCursorState;
  expect(
    localCursorState,
    isNotNull,
    reason: 'Local cursor state should be available for $projectId',
  );

  expect(
    localCursorState?.seq,
    equals(3),
    reason:
        'After full sync, sync cursor state seq should update for the outdated cloud change',
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
}

/// Test full sync with partial update
Future<void> testFullSyncPartialUpdate({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  bool useCloudDb = false,
}) async {
  final syncManager = SyncManager.instance;
  final local = LocalStorageService.instance;

  const projectId = '__test_full_cloud_local_pUpdate';
  final cloudChangeAt1 = DateTime.parse('2024-01-01T12:00:00Z');
  final cloudChange1Rank = '1';
  final cloudChange1NameLocal = 'Edited by cloud-full';
  final localChangeAt = cloudChangeAt1.add(const Duration(minutes: 1));
  final localChangeRank = 'local edit should lose to cloud 2 rank';
  final localChangeNameLocal = 'local edit should win';
  final cloudChangeAt2 = localChangeAt.add(const Duration(minutes: 1));
  final cloudChange2Rank = '2';

  // Reset project if using Cloud
  if (useCloudDb) {
    await resetDomainId(cloudBaseUrl, projectId);
  }

  // Save first cloud change that contains 'nameLocal' field that local can overwrite
  // next cloud change will update 'rank', which will be later than local rank change
  await saveCloudChangeViaHttp(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
    domainId: projectId,
    entityId: projectId,
    changeAt: cloudChangeAt1,
    dataJson: stableStringify({
      ...BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
      'rank': cloudChange1Rank,
      'nameLocal': cloudChange1NameLocal,
    }),
    userId: 'cloud-full',
    operation: 'create',
    fromJson: ProjectDataFields.fromJson,
  );

  await syncManager.initialize();
  syncManager.configureCloudUrl(cloudBaseUrl);
  await syncManager.downsyncFromCloud(domainIds: [projectId]);

  // Save a local change that should be outsynced
  final localChange =
      ChangeLogEntryFactoryService.forChangeSave<
        IsarChangeLogEntry,
        Id,
        ProjectDataFields
      >(
        factory: IsarChangeLogEntry.new,
        domainType: 'project',
        domainId: projectId,
        entityType: 'project',
        operation: 'update',
        entityId: projectId,
        changeBy: 'local-full',
        changeAt: localChangeAt,
        data: ProjectDataFields(
          parentId: 'root',
          parentProp: 'projects',
          rank: localChangeRank, // should lose
          nameLocal: localChangeNameLocal, // should win
        ),
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
          'stateDataHash': isA<String>(),
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
      'stateDataHash': isA<String>(),
    },
  );

  // Save second cloud change that contains 'rank' field that should overwrite local change
  final cloudChange2 = await saveCloudChangeViaHttp(
    cloudBaseUrl: cloudBaseUrl,
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
    fromJson: ProjectDataFields.fromJson,
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
  final localStateTotals = localStatus.localStateStats?.totals;
  expect(
    localStateTotals,
    isNotNull,
    reason: 'State stats should be available for $projectId',
  );
  final localStateTotalsMap = localStateTotals?.toJson();
  expect(
    localStateTotalsMap,
    equals({
      'creates': 1,
      'updates': 2, // local change [rank, nameLocal] and cloudChange2 [rank]
      'deletes': 0,
      'total': 3,
      'latestChangeAt': const UtcDateTimeConverter().toJson(
        cloudChange2.changeAt,
      ),
      'latestSeq': localStateTotalsMap?['latestSeq'],
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
        'After full sync, local data_nameLocal state for project $projectId should reflect last write wins local edit',
  );
  expect(
    downsyncedState.data_nameLocal_changeAt_,
    equals(localChange.changeAt.toUtc()),
    reason:
        'After full sync, local data_nameLocal change at state for project $projectId should reflect last write wins edit',
  );
  expect(
    downsyncedState.data_rank,
    equals(cloudChange2Rank),
    reason:
        'After full sync, local rank state for project $projectId should reflect last write wins cloud edit',
  );
  expect(
    downsyncedState.data_rank_changeAt_,
    equals(cloudChange2.changeAt.toUtc()),
    reason:
        'After full sync, local data_rank change at state for project $projectId should reflect last write wins cloud edit',
  );
}

/// Helper function to reset/delete a test project domain (for Cloud tests).
///
/// This calls the `/api/storage/__test/reset/{domainCollection}/{domainId}` endpoint
/// to delete all data for a test domain. The endpoint only allows deletion of
/// domains with IDs starting with `__test`.
Future<void> resetDomainId(
  String baseUrl,
  String domainId, {
  String domainCollection = kCollectionProject,
}) async {
  final result = await http.delete(
    Uri.parse('$baseUrl/api/storage/__test/reset/$domainCollection/$domainId'),
  );
  expect(
    result.statusCode,
    equals(200),
    reason:
        'Resetting test domain $domainId should return HTTP 200, but got ${result.statusCode}: ${result.body}',
  );
}

Future<IsarProjectState> getCurrentEntityStateAndCheckCloudAt(
  LocalStorageService local,
  String projectId,
) async {
  final localState =
      await local.getEntityState(
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
        localChange.operation == kChangeOperationCreate
            ? localChange.cid
            : null,
      ].whereType<String>().toList(),
      'updated': [
        [
              kChangeOperationUpdate,
              kChangeOperationPartialUpdate,
            ].contains(localChange.operation)
            ? localChange.cid
            : null,
      ].whereType<String>().toList(),
      'pUpdated': [
        localChange.operation == kChangeOperationPartialUpdate
            ? localChange.cid
            : null,
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
    'stateDataHash_orig_': isA<String>(),
    'stateDataHash': isA<String>(),
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

/// Save a cloud change via HTTP POST to /api/changes endpoint.
/// This allows tests to work with both local in-process servers and remote AWS endpoints.
Future<IsarChangeLogEntry>
saveCloudChangeViaHttp<TData extends BaseDataFields>({
  required String cloudBaseUrl,
  required String srcStorageType,
  required String srcStorageId,
  required String domainId,
  required String entityId,
  required DateTime changeAt,
  required String dataJson,
  required String userId,
  required String operation,
  required TData Function(Map<String, dynamic>) fromJson,
  DomainType domainType = DomainType.project,
  EntityType entityType = EntityType.project,
}) async {
  final cloudSaveChange =
      ChangeLogEntryFactoryService.forChangeSave<IsarChangeLogEntry, Id, TData>(
        factory: IsarChangeLogEntry.new,
        domainType: domainType.value,
        domainId: domainId,
        entityType: entityType.value,
        entityId: entityId,
        changeBy: userId,
        changeAt: changeAt,
        cid: generateCid(entityType: entityType, userId: userId),
        data: fromJson(jsonDecode(dataJson)),
        operation: operation,
      );

  final request = CreateChangesRequest(
    changes: [cloudSaveChange],
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
    storageMode: 'save',
  );

  final response = await http.post(
    Uri.parse('$cloudBaseUrl/api/changes'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(request.toJson()),
  );

  expect(
    response.statusCode,
    anyOf([200, 201]),
    reason:
        'Saving cloud change via HTTP should succeed, got ${response.statusCode}: ${response.body}',
  );

  final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
  expect(
    responseBody['errors'],
    isEmpty,
    reason: 'Cloud change save should have no errors: ${response.body}',
  );

  return cloudSaveChange;
}
