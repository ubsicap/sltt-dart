import 'dart:io';
import 'package:dio/dio.dart';
import '../lib/core/server/multi_server_launcher.dart';
import '../lib/core/server/server_ports.dart';
import '../lib/core/sync/sync_manager.dart';

class SyncManagerTester {
  final Dio _dio = Dio();
  final MultiServerLauncher _serverLauncher = MultiServerLauncher.instance;
  final SyncManager _syncManager = SyncManager.instance;

  // API endpoints
  final String _cloudStorageUrl = 'http://localhost:$kCloudStoragePort';
  final String _outsyncsUrl = 'http://localhost:$kOutsyncsPort';
  final String _downsyncsUrl = 'http://localhost:$kDownsyncsPort';

  SyncManagerTester() {
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<void> runTests() async {
    print('🚀 Starting Sync Manager Tests\n');

    try {
      // Start all servers
      await _startServers();

      // Initialize sync manager
      await _syncManager.initialize();

      // Run test scenarios
      await _testBasicOperations();
      await _testSyncEndpoint();
      await _testOutsyncFlow();
      await _testDownsyncFlow();
      await _testFullSyncFlow();
      await _testSyncStatus();

      print('\n✅ All sync manager tests completed successfully!');
    } catch (e) {
      print('\n❌ Test failed: $e');
      if (e is DioException) {
        print('DioException: ${e.message}');
        print('Response data: ${e.response?.data}');
      }
      rethrow;
    } finally {
      // Clean up
      await _cleanup();
    }
  }

  Future<void> _startServers() async {
    print('🔧 Starting all servers...');
    await _serverLauncher.startAllServers();

    // Wait a moment for servers to fully start
    await Future.delayed(const Duration(milliseconds: 500));

    // Verify all servers are running
    final status = _serverLauncher.getServerStatus();
    print('Server status: $status');

    if (!status['downsyncs']! ||
        !status['outsyncs']! ||
        !status['cloudStorage']!) {
      throw Exception('Not all servers started successfully');
    }
    print('✅ All servers started successfully\n');
  }

  Future<void> _testBasicOperations() async {
    print('📝 Testing basic operations on all servers...');

    final testData = {
      'entityType': 'Document',
      'operation': 'create',
      'entityId': 'test-uuid-123',
      'data': {
        'title': 'Test Document',
        'content': 'This is a test document',
      },
    };

    // Test each server
    final servers = [
      {'name': 'downsyncs', 'url': _downsyncsUrl},
      {'name': 'outsyncs', 'url': _outsyncsUrl},
      {'name': 'cloud storage', 'url': _cloudStorageUrl},
    ];

    for (final server in servers) {
      print('   Testing ${server['name']} server...');

      // Health check
      final healthResponse = await _dio.get('${server['url']}/health');
      if (healthResponse.statusCode != 200) {
        throw Exception('Health check failed for ${server['name']}');
      }

      // Create change
      final createResponse = await _dio.post(
        '${server['url']}/api/changes',
        data: testData,
      );
      if (createResponse.statusCode != 200) {
        throw Exception('Create change failed for ${server['name']}');
      }

      print('   ✅ ${server['name']} server working correctly');
    }

    print('✅ Basic operations test passed\n');
  }

  Future<void> _testSyncEndpoint() async {
    print('🔄 Testing batch changes endpoint...');

    // Test batch changes endpoint on cloud storage
    final syncData = [
      {
        'entityType': 'Document',
        'operation': 'update',
        'entityId': 'sync-test-1',
        'data': {'title': 'Sync Test Document 1'},
      },
      {
        'entityType': 'Document',
        'operation': 'create',
        'entityId': 'sync-test-2',
        'data': {'title': 'Sync Test Document 2'},
      },
    ];

    // Send batch changes request
    final batchResponse = await _dio.post(
      '$_cloudStorageUrl/api/changes',
      data: syncData,
    );

    if (batchResponse.statusCode != 200) {
      throw Exception('Batch changes endpoint failed');
    }

    final batchResult = batchResponse.data as Map<String, dynamic>;
    final storedChanges = batchResult['changes'] as List;

    if (storedChanges.length != 2) {
      throw Exception('Expected 2 stored changes, got ${storedChanges.length}');
    }

    print('   ✅ Batch changes endpoint stored ${storedChanges.length} changes');
    print('✅ Batch changes endpoint test passed\n');
  }

  Future<void> _testOutsyncFlow() async {
    print('⬆️ Testing outsync flow...');

    // Add some changes to outsyncs storage
    final testChanges = [
      {
        'entityType': 'Document',
        'operation': 'create',
        'entityId': 'outsync-test-1',
        'data': {'title': 'Outsync Test Document 1'},
      },
      {
        'entityType': 'Document',
        'operation': 'update',
        'entityId': 'outsync-test-2',
        'data': {'title': 'Outsync Test Document 2'},
      },
    ];

    // Add changes to outsyncs server
    for (final change in testChanges) {
      await _dio.post('$_outsyncsUrl/api/changes', data: change);
    }

    // Get initial counts
    final outsyncsStatsBefore = await _dio.get('$_outsyncsUrl/api/stats');
    final cloudStatsBefore = await _dio.get('$_cloudStorageUrl/api/stats');

    final outsyncsCountBefore =
        outsyncsStatsBefore.data['changeStats']['total'] as int;
    final cloudCountBefore =
        cloudStatsBefore.data['changeStats']['total'] as int;

    print('   Outsyncs changes before: $outsyncsCountBefore');
    print('   Cloud changes before: $cloudCountBefore');

    // Perform outsync
    final outsyncResult = await _syncManager.outsyncToCloud();

    if (!outsyncResult.success) {
      throw Exception('Outsync failed: ${outsyncResult.message}');
    }

    // Verify results
    final outsyncsStatsAfter = await _dio.get('$_outsyncsUrl/api/stats');
    final cloudStatsAfter = await _dio.get('$_cloudStorageUrl/api/stats');

    final outsyncsCountAfter =
        outsyncsStatsAfter.data['changeStats']['total'] as int;
    final cloudCountAfter = cloudStatsAfter.data['changeStats']['total'] as int;

    print('   Outsyncs changes after: $outsyncsCountAfter');
    print('   Cloud changes after: $cloudCountAfter');

    if (outsyncResult.syncedChanges.length < testChanges.length) {
      throw Exception(
          'Expected at least ${testChanges.length} synced changes, got ${outsyncResult.syncedChanges.length}');
    }

    print(
        '   ✅ Successfully outsynced ${outsyncResult.syncedChanges.length} changes');
    print(
        '   ✅ Deleted ${outsyncResult.deletedLocalChanges.length} local changes');
    print('✅ Outsync flow test passed\n');
  }

  Future<void> _testDownsyncFlow() async {
    print('⬇️ Testing downsync flow...');

    // Get initial downsync count
    final downsyncsStatsBefore = await _dio.get('$_downsyncsUrl/api/stats');
    final downsyncsCountBefore =
        downsyncsStatsBefore.data['changeStats']['total'] as int;

    print('   Downsyncs changes before: $downsyncsCountBefore');

    // Perform downsync
    final downsyncResult = await _syncManager.downsyncFromCloud();

    if (!downsyncResult.success) {
      throw Exception('Downsync failed: ${downsyncResult.message}');
    }

    // Verify results
    final downsyncsStatsAfter = await _dio.get('$_downsyncsUrl/api/stats');
    final downsyncsCountAfter =
        downsyncsStatsAfter.data['changeStats']['total'] as int;

    print('   Downsyncs changes after: $downsyncsCountAfter');
    print(
        '   ✅ Successfully downsynced ${downsyncResult.newChanges.length} changes');
    print('✅ Downsync flow test passed\n');
  }

  Future<void> _testFullSyncFlow() async {
    print('🔄 Testing full sync flow...');

    // Add a change to outsyncs
    await _dio.post('$_outsyncsUrl/api/changes', data: {
      'entityType': 'Document',
      'operation': 'create',
      'entityId': 'full-sync-test',
      'data': {'title': 'Full Sync Test Document'},
    });

    // Perform full sync
    final fullSyncResult = await _syncManager.performFullSync();

    if (!fullSyncResult.success) {
      throw Exception('Full sync failed');
    }

    print('   ✅ Full sync completed successfully');
    print('   ✅ Outsync: ${fullSyncResult.outsyncResult.message}');
    print('   ✅ Downsync: ${fullSyncResult.downsyncResult.message}');
    print('✅ Full sync flow test passed\n');
  }

  Future<void> _testSyncStatus() async {
    print('📊 Testing sync status...');

    final syncStatus = await _syncManager.getSyncStatus();

    print('   Outsyncs count: ${syncStatus.outsyncsCount}');
    print('   Downsyncs count: ${syncStatus.downsyncsCount}');
    print('   Cloud count: ${syncStatus.cloudCount}');
    print('   Last sync time: ${syncStatus.lastSyncTime}');

    print('✅ Sync status test passed\n');
  }

  Future<void> _cleanup() async {
    print('🧹 Cleaning up...');

    try {
      await _syncManager.close();
      await _serverLauncher.stopAllServers();
    } catch (e) {
      print('Warning: Cleanup error: $e');
    }

    print('✅ Cleanup completed\n');
  }
}

void main() async {
  final tester = SyncManagerTester();

  try {
    await tester.runTests();
  } catch (e) {
    print('Test execution failed: $e');
    exit(1);
  }
}
