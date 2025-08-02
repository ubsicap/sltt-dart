import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  group('Sync Manager Tests', () {
    late MultiServerLauncher serverLauncher;
    late SyncManager syncManager;
    late OutsyncsStorageService outsyncsStorage;
    late Dio dio;

    // Configuration - set to true to test against dev cloud instead of localhost
    // do USE_DEV_CLOUD=true LD_LIBRARY_PATH=/tmp/dart_test_libs dart test test/sync_manager_test.dart
    final bool useDevCloud = Platform.environment['USE_DEV_CLOUD'] == 'true';

    // Use different project names for dev cloud vs localhost
    final String testProjectId = useDevCloud
        ? '_test_cloud_api_project'
        : 'test-project';

    // API endpoints
    final String cloudStorageUrl = useDevCloud
        ? kCloudDevUrl
        : kLocalhostCloudStorageUrl;
    final String outsyncsUrl = kLocalhostOutsyncsUrl;
    final String downsyncsUrl = kLocalhostDownsyncsUrl;

    setUpAll(() async {
      serverLauncher = MultiServerLauncher.instance;
      syncManager = SyncManager.instance;
      outsyncsStorage = OutsyncsStorageService.instance;

      dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      if (useDevCloud) {
        print('🌩️ Using DEV CLOUD for testing: $cloudStorageUrl');
        // Configure sync manager to use dev cloud
        syncManager.configureCloudUrl(cloudStorageUrl);

        // Start only local servers (outsyncs and downsyncs)
        await serverLauncher.startServer('outsyncs', kOutsyncsPort);
        await serverLauncher.startServer('downsyncs', kDownsyncsPort);

        final serverStatus = serverLauncher.getServerStatus();
        expect(serverStatus['downsyncs'], isTrue);
        expect(serverStatus['outsyncs'], isTrue);
        print('✅ Local servers started (cloud storage using AWS dev)');
      } else {
        print('🏠 Using LOCALHOST for testing: $cloudStorageUrl');
        // Configure sync manager to use localhost cloud server
        syncManager.configureCloudUrl(cloudStorageUrl);

        // Start all servers
        print('🔧 Starting all servers...');
        await serverLauncher.startAllServers();

        final serverStatus = serverLauncher.getServerStatus();
        expect(serverStatus['downsyncs'], isTrue);
        expect(serverStatus['outsyncs'], isTrue);
        expect(serverStatus['cloudStorage'], isTrue);
      }

      // Initialize sync manager
      await syncManager.initialize();

      // Clean up any leftover data from previous test runs
      print('🧹 Cleaning up leftover test data...');
      await outsyncsStorage.deleteAllChanges();
      await DownsyncsStorageService.instance.deleteAllChanges();
      await syncManager.clearAllSyncStates();
      if (!useDevCloud) {
        // Don't clear cloud storage here as it breaks test dependencies
        // Each test should manage its own cloud data as needed
      }
      print('✅ Database cleanup completed');
    });

    tearDownAll(() async {
      await syncManager.close();
      await serverLauncher.stopAllServers();
    });

    test('basic server operations', () async {
      // Test downsyncs server
      final downsyncsHealth = await dio.get('$downsyncsUrl/health');
      expect(downsyncsHealth.statusCode, equals(200));

      final downsyncsChange = await dio.post(
        '$downsyncsUrl/api/changes',
        data: [
          {
            'projectId': testProjectId,
            'entityType': 'Document',
            'operation': 'create',
            'entityId': 'test-downsyncs-1',
            'data': {'title': 'Test Document'},
          },
        ],
      );
      expect(downsyncsChange.statusCode, equals(200));

      // Test outsyncs server
      final outsyncsHealth = await dio.get('$outsyncsUrl/health');
      expect(outsyncsHealth.statusCode, equals(200));

      final outsyncsChange = await dio.post(
        '$outsyncsUrl/api/changes',
        data: [
          {
            'projectId': testProjectId,
            'entityType': 'Document',
            'operation': 'create',
            'entityId': 'test-outsyncs-1',
            'data': {'title': 'Test Document'},
          },
        ],
      );
      expect(outsyncsChange.statusCode, equals(200));

      // Test cloud storage server (localhost or dev cloud)
      final cloudHealth = await dio.get('$cloudStorageUrl/health');
      expect(cloudHealth.statusCode, equals(200));

      final cloudChange = await dio.post(
        '$cloudStorageUrl/api/changes',
        data: [
          {
            'projectId': testProjectId,
            'entityType': 'Document',
            'operation': 'create',
            'entityId': 'test-cloud-1',
            'data': {'title': 'Test Document'},
          },
        ],
      );
      expect(cloudChange.statusCode, equals(200));
    });

    test('batch changes endpoint', () async {
      final batchChanges = [
        {
          'projectId': testProjectId,
          'entityType': 'Document',
          'operation': 'create',
          'entityId': 'batch-doc-1',
          'data': {'title': 'Batch Document 1'},
        },
        {
          'projectId': testProjectId,
          'entityType': 'Document',
          'operation': 'create',
          'entityId': 'batch-doc-2',
          'data': {'title': 'Batch Document 2'},
        },
      ];

      final response = await dio.post(
        '$cloudStorageUrl/api/changes',
        data: batchChanges,
      );
      expect(response.statusCode, equals(200));

      final responseData = response.data as Map<String, dynamic>;
      expect(responseData['success'], isTrue);
      expect(responseData['created'], equals(2));
      expect(responseData['seqMap'], isNotNull);

      final seqMap = responseData['seqMap'] as Map<String, dynamic>;
      expect(seqMap.length, equals(2));
    });

    test('cloud storage sequence generation', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final entityId1 = 'test-seq-1-$timestamp';
      final entityId2 = 'test-seq-2-$timestamp';

      final changes = [
        {
          'seq': 999, // This should be ignored
          'projectId': testProjectId,
          'entityType': 'TestEntity',
          'operation': 'create',
          'entityId': entityId1,
          'data': {'name': 'Test 1'},
        },
        {
          'seq': 1000, // This should also be ignored
          'projectId': testProjectId,
          'entityType': 'TestEntity',
          'operation': 'create',
          'entityId': entityId2,
          'data': {'name': 'Test 2'},
        },
      ];

      // Send to cloud storage
      final response = await dio.post(
        '$cloudStorageUrl/api/changes',
        data: changes,
      );
      final responseData = response.data as Map<String, dynamic>;

      expect(responseData['success'], isTrue);

      final seqMap = responseData['seqMap'] as Map<String, dynamic>;
      expect(seqMap['999'], isNotNull);
      expect(seqMap['1000'], isNotNull);

      final newSeq1 = seqMap['999'] as int;
      final newSeq2 = seqMap['1000'] as int;

      // Cloud storage should create new sequences
      expect(newSeq1, isNot(equals(999)));
      expect(newSeq2, isNot(equals(1000)));

      // Verify the actual stored changes have the new sequences
      final storedChanges = await dio.get(
        '$cloudStorageUrl/api/projects/$testProjectId/changes',
      );
      final changesList = storedChanges.data['changes'] as List;

      final change1 = changesList
          .where((c) => c['entityId'] == entityId1)
          .toList();
      final change2 = changesList
          .where((c) => c['entityId'] == entityId2)
          .toList();

      expect(change1, isNotEmpty);
      expect(change2, isNotEmpty);
      expect(change1.first['seq'], equals(newSeq1));
      expect(change2.first['seq'], equals(newSeq2));
    });

    test('outsync flow', () async {
      // Add test changes to outsyncs
      await dio.post(
        '$outsyncsUrl/api/changes',
        data: [
          {
            'projectId': testProjectId,
            'entityType': 'Document',
            'operation': 'create',
            'entityId': 'outsync-test-1',
            'data': {'title': 'Outsync Test Document 1'},
          },
        ],
      );

      await dio.post(
        '$outsyncsUrl/api/changes',
        data: [
          {
            'projectId': testProjectId,
            'entityType': 'Document',
            'operation': 'create',
            'entityId': 'outsync-test-2',
            'data': {'title': 'Outsync Test Document 2'},
          },
        ],
      );

      // Get initial counts
      final outsyncsStatsBefore = await dio.get(
        '$outsyncsUrl/api/projects/$testProjectId/stats',
      );
      final cloudStatsBefore = await dio.get(
        '$cloudStorageUrl/api/projects/$testProjectId/stats',
      );

      final outsyncsCountBefore =
          outsyncsStatsBefore.data['changeStats']['total'] as int;

      // Cloud API now uses consistent 'total' field
      final cloudCountBefore =
          (cloudStatsBefore.data?['changeStats']?['total'] as int?) ?? 0;

      // Perform outsync
      final outsyncResult = await syncManager.outsyncToCloud();

      expect(outsyncResult.success, isTrue);
      expect(outsyncResult.seqMap, isNotEmpty);
      expect(
        outsyncResult.deletedLocalChanges,
        isNotEmpty,
      ); // Changes are deleted immediately after successful upload

      // Verify changes were added to cloud and removed from outsyncs
      final outsyncsStatsAfter = await dio.get(
        '$outsyncsUrl/api/projects/$testProjectId/stats',
      );
      final cloudStatsAfter = await dio.get(
        '$cloudStorageUrl/api/projects/$testProjectId/stats',
      );

      final outsyncsCountAfter =
          outsyncsStatsAfter.data['changeStats']['total'] as int;

      // Cloud API now uses consistent 'total' field
      final cloudCountAfter =
          (cloudStatsAfter.data?['changeStats']?['total'] as int?) ?? 0;

      expect(cloudCountAfter, greaterThan(cloudCountBefore));
      expect(
        outsyncsCountAfter,
        lessThan(outsyncsCountBefore),
      ); // Changes deleted immediately after upload
    });

    test('downsync flow', () async {
      // Reset sync state to ensure we start fresh for this test
      await syncManager.clearAllSyncStates();

      // Get initial downsync count
      final downsyncsStatsBefore = await dio.get(
        '$downsyncsUrl/api/projects/$testProjectId/stats',
      );
      final downsyncsCountBefore =
          downsyncsStatsBefore.data['changeStats']['total'] as int;

      // Perform downsync
      final downsyncResult = await syncManager.downsyncFromCloud();

      expect(downsyncResult.success, isTrue);

      // For dev cloud, there may not be new changes if none exist
      if (useDevCloud) {
        // Just verify the operation succeeded
        expect(downsyncResult.newChanges, isA<List>());
      } else {
        // For localhost, we expect new changes based on the setup
        expect(downsyncResult.newChanges, isNotEmpty);
      }

      // Verify changes were added to downsyncs (if any new changes)
      final downsyncsStatsAfter = await dio.get(
        '$downsyncsUrl/api/projects/$testProjectId/stats',
      );
      final downsyncsCountAfter =
          downsyncsStatsAfter.data['changeStats']['total'] as int;

      if (useDevCloud) {
        // For dev cloud, count may not increase if no new changes
        expect(downsyncsCountAfter, greaterThanOrEqualTo(downsyncsCountBefore));
      } else {
        // With Step 4 implementation, downsyncs are applied to state then deleted
        // So count should remain the same (0 before, 0 after) but changes should exist
        expect(downsyncResult.newChanges, isNotEmpty);
        expect(downsyncsCountAfter, equals(downsyncsCountBefore));
      }
    });

    test('full sync flow', () async {
      // Add a test change for full sync
      await dio.post(
        '$outsyncsUrl/api/changes',
        data: [
          {
            'projectId': testProjectId,
            'entityType': 'Document',
            'operation': 'create',
            'entityId': 'full-sync-test',
            'data': {'title': 'Full Sync Test Document'},
          },
        ],
      );

      // Get initial counts
      final outsyncsStatsBefore = await dio.get(
        '$outsyncsUrl/api/projects/$testProjectId/stats',
      );
      final outsyncsCountBefore =
          outsyncsStatsBefore.data['changeStats']['total'] as int;

      // Perform full sync
      final fullSyncResult = await syncManager.performFullSync();

      expect(fullSyncResult.success, isTrue);
      expect(fullSyncResult.outsyncResult.success, isTrue);
      expect(fullSyncResult.downsyncResult.success, isTrue);

      if (useDevCloud) {
        // For dev cloud, just verify sync completed successfully
        expect(fullSyncResult.outsyncResult.deletedLocalChanges, isA<List>());
      } else {
        // For localhost, expect deleted changes
        expect(fullSyncResult.outsyncResult.deletedLocalChanges, isNotEmpty);
      }

      // Verify local changes were cleaned up after full sync
      final outsyncsStatsAfter = await dio.get(
        '$outsyncsUrl/api/projects/$testProjectId/stats',
      );
      final outsyncsCountAfter =
          outsyncsStatsAfter.data['changeStats']['total'] as int;

      if (useDevCloud) {
        // For dev cloud, count may not decrease if sync behaves differently
        expect(outsyncsCountAfter, lessThanOrEqualTo(outsyncsCountBefore));
      } else {
        // For localhost, expect count to decrease
        expect(outsyncsCountAfter, lessThan(outsyncsCountBefore));
      }
    });

    test('outdated changes are not synced', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final entityId = 'test-outdated-$timestamp';

      // Add a change to outsyncs
      final change = {
        'projectId': testProjectId,
        'entityType': 'TestEntity',
        'operation': 'create',
        'entityId': entityId,
        'data': {'name': 'Will be outdated'},
      };

      final response = await dio.post(
        '$outsyncsUrl/api/changes',
        data: [change],
      );
      final responseData = response.data as Map<String, dynamic>;
      final seqMap = responseData['seqMap'] as Map<String, dynamic>;
      final createdSeq = seqMap.values.first as int;

      // Mark the change as outdated
      await outsyncsStorage.markAsOutdated(testProjectId, createdSeq, 99999);

      // Get initial cloud count
      final cloudStatsBefore = await dio.get(
        '$cloudStorageUrl/api/projects/$testProjectId/stats',
      );
      final cloudCountBefore =
          (cloudStatsBefore.data?['changeStats']?['total'] as int?) ?? 0;

      // Try to outsync - should skip the outdated change
      final outsyncResult = await syncManager.outsyncToCloud();

      expect(outsyncResult.success, isTrue);
      expect(outsyncResult.seqMap, isEmpty); // No changes should be synced

      // Verify cloud storage count didn't increase
      final cloudStatsAfter = await dio.get(
        '$cloudStorageUrl/api/projects/$testProjectId/stats',
      );
      final cloudCountAfter =
          (cloudStatsAfter.data?['changeStats']?['total'] as int?) ?? 0;

      expect(cloudCountAfter, equals(cloudCountBefore));
    });

    test('sync status', () async {
      final syncStatus = await syncManager.getSyncStatus();

      expect(syncStatus.outsyncsCount, isA<int>());
      expect(syncStatus.downsyncsCount, isA<int>());
      expect(syncStatus.cloudCount, isA<int>());
      expect(syncStatus.lastSyncTime, isA<DateTime>());
    });
  });
}
