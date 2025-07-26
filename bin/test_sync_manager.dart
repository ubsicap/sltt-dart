import 'dart:io';
import 'package:dio/dio.dart';
import '../lib/core/server/multi_server_launcher.dart';
import '../lib/core/server/server_ports.dart';
import '../lib/core/sync/sync_manager.dart';
import '../lib/core/storage/shared_storage_service.dart';

class SyncManagerTester {
  final Dio _dio = Dio();
  final MultiServerLauncher _serverLauncher = MultiServerLauncher.instance;
  final SyncManager _syncManager = SyncManager.instance;
  final OutsyncsStorageService _outsyncsStorage = OutsyncsStorageService.instance;

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
      await _testCloudStorageSequenceGeneration();
      await _testOutsyncFlow();
      await _testDownsyncFlow();
      await _testFullSyncFlow();
      await _testOutdatedChangesNotSynced();
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
        data: [testData], // Wrap in array
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
    final success = batchResult['success'] as bool;
    final createdCount = batchResult['created'] as int;
    final seqMap = batchResult['seqMap'] as Map<String, dynamic>?;

    if (!success || createdCount != 2) {
      throw Exception(
          'Expected 2 successful changes, got success=$success, created=$createdCount');
    }

    if (seqMap == null || seqMap.length != 2) {
      throw Exception('Expected seqMap with 2 entries, got ${seqMap?.length}');
    }

    print('   ✅ Batch changes endpoint created $createdCount changes');
    print('   ✅ seqMap contains ${seqMap.length} sequence mappings');
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
      await _dio
          .post('$_outsyncsUrl/api/changes', data: [change]); // Wrap in array
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

    // Verify that seqMap is populated but changes are not deleted yet
    if (outsyncResult.seqMap.isEmpty) {
      throw Exception('Expected seqMap to be populated after outsync');
    }

    if (outsyncResult.deletedLocalChanges.isNotEmpty) {
      throw Exception('Expected no local changes to be deleted yet, but found ${outsyncResult.deletedLocalChanges.length}');
    }

    // Verify changes were added to cloud storage but outsyncs still has them
    final outsyncsStatsAfter = await _dio.get('$_outsyncsUrl/api/stats');
    final cloudStatsAfter = await _dio.get('$_cloudStorageUrl/api/stats');

    final outsyncsCountAfter =
        outsyncsStatsAfter.data['changeStats']['total'] as int;
    final cloudCountAfter = cloudStatsAfter.data['changeStats']['total'] as int;

    print('   Outsyncs changes after: $outsyncsCountAfter');
    print('   Cloud changes after: $cloudCountAfter');

    if (cloudCountAfter <= cloudCountBefore) {
      throw Exception('Expected cloud changes to increase after outsync');
    }

    if (outsyncsCountAfter != outsyncsCountBefore) {
      throw Exception('Expected outsyncs changes to remain same until full sync completion, before: $outsyncsCountBefore, after: $outsyncsCountAfter');
    }

    print('   ✅ Successfully outsynced to cloud, seqMap contains ${outsyncResult.seqMap.length} mappings');
    print('   ✅ Local changes preserved until full sync completion');
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
    await _dio.post('$_outsyncsUrl/api/changes', data: [
      {
        'entityType': 'Document',
        'operation': 'create',
        'entityId': 'full-sync-test',
        'data': {'title': 'Full Sync Test Document'},
      }
    ]);

    // Get initial counts
    final outsyncsStatsBefore = await _dio.get('$_outsyncsUrl/api/stats');
    final outsyncsCountBefore =
        outsyncsStatsBefore.data['changeStats']['total'] as int;

    // Perform full sync
    final fullSyncResult = await _syncManager.performFullSync();

    if (!fullSyncResult.success) {
      throw Exception('Full sync failed');
    }

    // Verify that local changes were actually deleted after full sync
    final outsyncsStatsAfter = await _dio.get('$_outsyncsUrl/api/stats');
    final outsyncsCountAfter =
        outsyncsStatsAfter.data['changeStats']['total'] as int;

    if (fullSyncResult.outsyncResult.deletedLocalChanges.isEmpty) {
      throw Exception('Expected some local changes to be deleted after full sync');
    }

    if (outsyncsCountAfter >= outsyncsCountBefore) {
      throw Exception('Expected outsyncs count to decrease after full sync, before: $outsyncsCountBefore, after: $outsyncsCountAfter');
    }

    print('   ✅ Full sync completed successfully');
    print('   ✅ Outsync: ${fullSyncResult.outsyncResult.message}');
    print('   ✅ Downsync: ${fullSyncResult.downsyncResult.message}');
    print('   ✅ Deleted ${fullSyncResult.outsyncResult.deletedLocalChanges.length} local changes');
    print('   ✅ seqMap contains ${fullSyncResult.outsyncResult.seqMap.length} sequence mappings');
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

  Future<void> _testCloudStorageSequenceGeneration() async {
    print('🔢 Testing cloud storage sequence generation...');

    // Use unique entity IDs to avoid conflicts with previous tests
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final entityId1 = 'test-seq-1-$timestamp';
    final entityId2 = 'test-seq-2-$timestamp';

    // Create changes with explicit old sequences
    final changes = [
      {
        'seq': 999, // This should be ignored
        'entityType': 'TestEntity',
        'operation': 'create',
        'entityId': entityId1,
        'data': {'name': 'Test 1'},
      },
      {
        'seq': 1000, // This should also be ignored
        'entityType': 'TestEntity',
        'operation': 'create',
        'entityId': entityId2,
        'data': {'name': 'Test 2'},
      }
    ];

    // Send to cloud storage
    final response = await _dio.post('$_cloudStorageUrl/api/changes', data: changes);
    final responseData = response.data as Map<String, dynamic>;

    if (!responseData['success']) {
      throw Exception('Failed to create changes in cloud storage');
    }

    final seqMap = responseData['seqMap'] as Map<String, dynamic>;

    // Verify seqMap maps old to new sequences
    if (seqMap['999'] == null || seqMap['1000'] == null) {
      throw Exception('seqMap should contain mappings for old sequences');
    }

    final newSeq1 = seqMap['999'] as int;
    final newSeq2 = seqMap['1000'] as int;

    if (newSeq1 == 999 || newSeq2 == 1000) {
      throw Exception('Cloud storage used old sequences instead of creating new ones');
    }

    // Verify the actual stored changes have the new sequences
    final storedChanges = await _dio.get('$_cloudStorageUrl/api/changes');
    final changesList = storedChanges.data['changes'] as List;

    // Find our changes by entity ID
    final change1 = changesList.where((c) => c['entityId'] == entityId1).toList();
    final change2 = changesList.where((c) => c['entityId'] == entityId2).toList();

    if (change1.isEmpty || change2.isEmpty) {
      throw Exception('Could not find test changes in storage. Found ${changesList.length} total changes.');
    }

    if (change1.first['seq'] != newSeq1 || change2.first['seq'] != newSeq2) {
      throw Exception(
        'Stored changes have incorrect sequences. '
        'Expected change1 seq: $newSeq1, got: ${change1.first['seq']}. '
        'Expected change2 seq: $newSeq2, got: ${change2.first['seq']}'
      );
    }

    print('   ✅ Cloud storage correctly creates new sequences and provides seqMap');
    print('   ✅ Old seq 999 → new seq $newSeq1');
    print('   ✅ Old seq 1000 → new seq $newSeq2');
    print('✅ Cloud storage sequence generation test passed\n');
  }

  Future<void> _testOutdatedChangesNotSynced() async {
    print('⚠️ Testing outdated changes are not synced...');

    // Use unique entity ID to avoid conflicts
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final entityId = 'test-outdated-$timestamp';

    // Add a change to outsyncs
    final change = {
      'entityType': 'TestEntity',
      'operation': 'create',
      'entityId': entityId,
      'data': {'name': 'Will be outdated'},
    };

    final response = await _dio.post('$_outsyncsUrl/api/changes', data: [change]);
    final responseData = response.data as Map<String, dynamic>;
    final seqMap = responseData['seqMap'] as Map<String, dynamic>;
    final createdSeq = seqMap.values.first as int;

    print('   Created change with seq: $createdSeq');

    // Mark the change as outdated using the storage service directly
    // (since PUT endpoint has been removed from the API)
    await _outsyncsStorage.markAsOutdated(createdSeq, 99999);

    print('   Marked change as outdated');

    // Get initial cloud count
    final cloudStatsBefore = await _dio.get('$_cloudStorageUrl/api/stats');
    final cloudCountBefore = cloudStatsBefore.data['changeStats']['total'] as int;

    // Try to outsync - should skip the outdated change
    final outsyncResult = await _syncManager.outsyncToCloud();

    if (!outsyncResult.success) {
      throw Exception('Outsync failed: ${outsyncResult.message}');
    }

    // Verify no changes were synced
    if (outsyncResult.seqMap.isNotEmpty) {
      throw Exception('Expected no changes to be synced, but got ${outsyncResult.seqMap.length}');
    }

    // Verify cloud storage count didn't increase
    final cloudStatsAfter = await _dio.get('$_cloudStorageUrl/api/stats');
    final cloudCountAfter = cloudStatsAfter.data['changeStats']['total'] as int;

    if (cloudCountAfter != cloudCountBefore) {
      throw Exception('Expected cloud count to remain same, before: $cloudCountBefore, after: $cloudCountAfter');
    }

    print('   ✅ Outdated changes correctly filtered out from sync');
    print('   ✅ Cloud storage count remained: $cloudCountAfter');
    print('✅ Outdated changes test passed\n');
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
