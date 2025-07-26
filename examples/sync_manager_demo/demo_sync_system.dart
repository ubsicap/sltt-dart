import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:sltt_core/sltt_core.dart';

class SyncSystemDemo {
  final MultiServerLauncher _serverLauncher = MultiServerLauncher.instance;
  final SyncManager _syncManager = SyncManager.instance;
  final OutsyncsStorageService _outsyncsStorage = OutsyncsStorageService.instance;
  final Dio _dio = Dio();

  // API endpoints
  final String _cloudStorageUrl = 'http://localhost:$kCloudStoragePort';
  final String _outsyncsUrl = 'http://localhost:$kOutsyncsPort';
  final String _downsyncsUrl = 'http://localhost:$kDownsyncsPort';

  SyncSystemDemo() {
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<void> runDemo() async {
    print('🚀 Starting SLTT Dart Sync Demo\n');

    try {
      await _setupSystem();
      await _demonstrateBasicOperations();
      await _demonstrateSequenceMapping();
      await _demonstrateOutdatedChanges();
      await _demonstrateOutsyncFlow();
      await _demonstrateDownsyncFlow();
      await _demonstrateFullSyncFlow();
      await _showFinalStatus();

      print('\n🎉 Demo completed successfully!');
      print('Press Ctrl+C to stop all servers and exit.');

      // Keep servers running for manual testing
      while (true) {
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      print('\n❌ Demo failed: $e');
      rethrow;
    }
  }

  Future<void> _setupSystem() async {
    print('🔧 Setting up the sync system...');

    // Start all servers
    await _serverLauncher.startAllServers();

    // Wait a moment for servers to fully start
    await Future.delayed(const Duration(milliseconds: 500));

    // Initialize sync manager
    await _syncManager.initialize();

    // Verify all servers are running
    final status = _serverLauncher.getServerStatus();
    print('✅ Server status: $status');
    print('✅ Sync system ready!\n');
  }

  Future<void> _demonstrateBasicOperations() async {
    print('📝 Demonstrating basic operations on each server...');

    // Add some initial data to each server
    final servers = [
      {'name': 'Outsyncs', 'url': _outsyncsUrl, 'description': 'Local changes to be uploaded'},
      {'name': 'Downsyncs', 'url': _downsyncsUrl, 'description': 'Changes received from cloud'},
      {'name': 'Cloud Storage', 'url': _cloudStorageUrl, 'description': 'Cloud-based change storage'},
    ];

    for (int i = 0; i < servers.length; i++) {
      final server = servers[i];
      print('   Adding test data to ${server['name']} server...');

      await _dio.post('${server['url']}/api/changes', data: [
        {
          'entityType': 'Document',
          'operation': 'create',
          'entityId': 'demo-doc-${i + 1}',
          'data': {
            'title': 'Demo Document ${i + 1}',
            'content': 'This is a demo document stored in ${server['name']}',
            'description': server['description'],
          },
        }
      ]);

      print('   ✅ Added demo document to ${server['name']}');
    }

    await _showCurrentStatus();
    print('✅ Basic operations completed\n');
  }

  Future<void> _demonstrateOutsyncFlow() async {
    print('⬆️ Demonstrating outsync flow...');
    print('   This will sync changes from Outsyncs to Cloud Storage\n');

    // Add more changes to outsyncs to demonstrate the flow
    print('   Adding additional changes to Outsyncs...');
    final outsyncsChanges = [
      {
        'entityType': 'Document',
        'operation': 'create',
        'entityId': 'demo-doc-outsync-1',
        'data': {
          'title': 'Outsync Demo Document 1',
          'content': 'This document was created and needs to be synced to cloud',
          'lastModified': DateTime.now().toIso8601String(),
        },
      },
      {
        'entityType': 'User',
        'operation': 'create',
        'entityId': 'user-123',
        'data': {
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'role': 'editor',
        },
      },
    ];

    for (final change in outsyncsChanges) {
      await _dio.post('$_outsyncsUrl/api/changes', data: [change]);
      print('   ✅ Added change: ${change['operation']} ${change['entityType']}');
    }

    print('\n   Status before outsync:');
    await _showCurrentStatus();

    print('   Performing outsync...');
    final outsyncResult = await _syncManager.outsyncToCloud();

    if (outsyncResult.success) {
      print('   ✅ Outsync successful!');
      print('   📊 Synced ${outsyncResult.deletedLocalChanges.length} changes');
      print('   🗑️ Cleaned up ${outsyncResult.deletedLocalChanges.length} local changes');
    } else {
      print('   ❌ Outsync failed: ${outsyncResult.message}');
    }

    print('\n   Status after outsync:');
    await _showCurrentStatus();
    print('✅ Outsync flow demonstration completed\n');
  }

  Future<void> _demonstrateDownsyncFlow() async {
    print('⬇️ Demonstrating downsync flow...');
    print('   This will sync changes from Cloud Storage to Downsyncs\n');

    // Add some changes directly to cloud storage to simulate remote changes
    print('   Simulating remote changes in Cloud Storage...');
    final cloudChanges = [
      {
        'entityType': 'Document',
        'operation': 'create',
        'entityId': 'remote-doc-1',
        'data': {
          'title': 'Remote Document 1',
          'content': 'This document was created remotely and needs to be downloaded',
          'author': 'Remote User',
          'createdAt': DateTime.now().toIso8601String(),
        },
      },
      {
        'entityType': 'Project',
        'operation': 'create',
        'entityId': 'project-456',
        'data': {
          'name': 'Remote Project',
          'description': 'A project created in the cloud',
          'status': 'active',
        },
      },
    ];

    for (final change in cloudChanges) {
      await _dio.post('$_cloudStorageUrl/api/changes', data: [change]);
      print('   ✅ Added remote change: ${change['operation']} ${change['entityType']}');
    }

    print('\n   Status before downsync:');
    await _showCurrentStatus();

    print('   Performing downsync...');
    final downsyncResult = await _syncManager.downsyncFromCloud();

    if (downsyncResult.success) {
      print('   ✅ Downsync successful!');
      print('   📥 Downloaded ${downsyncResult.newChanges.length} new changes');
    } else {
      print('   ❌ Downsync failed: ${downsyncResult.message}');
    }

    print('\n   Status after downsync:');
    await _showCurrentStatus();
    print('✅ Downsync flow demonstration completed\n');
  }

  Future<void> _demonstrateFullSyncFlow() async {
    print('🔄 Demonstrating full sync flow...');
    print('   This will perform both outsync and downsync operations\n');

    // Add one more change to outsyncs
    await _dio.post('$_outsyncsUrl/api/changes', data: [
      {
        'entityType': 'Settings',
        'operation': 'create',
        'entityId': 'app-settings-final',
        'data': {
          'theme': 'dark',
          'language': 'en',
          'autoSync': true,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
      }
    ]);
    print('   ✅ Added final change to Outsyncs');

    print('\n   Status before full sync:');
    await _showCurrentStatus();

    print('   Performing full sync (outsync + downsync)...');
    final fullSyncResult = await _syncManager.performFullSync();

    if (fullSyncResult.success) {
      print('   ✅ Full sync successful!');
      print('   ⬆️ Outsync: ${fullSyncResult.outsyncResult.message}');
      print('   ⬆️ Sequence mappings: ${fullSyncResult.outsyncResult.seqMap}');
      print('   ⬆️ Deleted ${fullSyncResult.outsyncResult.deletedLocalChanges.length} local changes');
      print('   ⬇️ Downsync: ${fullSyncResult.downsyncResult.message}');
    } else {
      print('   ❌ Full sync failed');
      print('   ⬆️ Outsync: ${fullSyncResult.outsyncResult.message}');
      print('   ⬇️ Downsync: ${fullSyncResult.downsyncResult.message}');
    }

    print('\n   Status after full sync:');
    await _showCurrentStatus();
    print('✅ Full sync flow demonstration completed\n');
  }

  Future<void> _showCurrentStatus() async {
    try {
      final responses = await Future.wait([
        _dio.get('$_outsyncsUrl/api/stats'),
        _dio.get('$_downsyncsUrl/api/stats'),
        _dio.get('$_cloudStorageUrl/api/stats'),
      ]);

      final outsyncsStats = responses[0].data['changeStats'];
      final downsyncsStats = responses[1].data['changeStats'];
      final cloudStats = responses[2].data['changeStats'];

      print('   📊 Current Status:');
      print('      Outsyncs:      ${outsyncsStats['total']} changes');
      print('      Downsyncs:    ${downsyncsStats['total']} changes');
      print('      Cloud Storage: ${cloudStats['total']} changes');
    } catch (e) {
      print('   ⚠️ Could not retrieve stats: $e');
    }
  }

  Future<void> _showFinalStatus() async {
    print('📊 Final System Status:');

    // Show detailed stats for each server
    final servers = [
      {'name': 'Outsyncs', 'url': _outsyncsUrl},
      {'name': 'Downsyncs', 'url': _downsyncsUrl},
      {'name': 'Cloud Storage', 'url': _cloudStorageUrl},
    ];

    for (final server in servers) {
      try {
        final statsResponse = await _dio.get('${server['url']}/api/stats');
        final changeStats = statsResponse.data['changeStats'];
        final entityTypeStats = statsResponse.data['entityTypeStats'];

        print('\n   ${server['name']}:');
        print('      Total changes: ${changeStats['total']}');
        print('      Creates: ${changeStats['creates']}');
        print('      Updates: ${changeStats['updates']}');
        print('      Deletes: ${changeStats['deletes']}');
        print('      Entity types: $entityTypeStats');
      } catch (e) {
        print('\n   ${server['name']}: Could not retrieve stats');
      }
    }

    // Show sync manager status
    try {
      final syncStatus = await _syncManager.getSyncStatus();
      print('\n   Sync Manager Status:');
      print('      Last sync: ${syncStatus.lastSyncTime}');
    } catch (e) {
      print('\n   Sync Manager: Could not retrieve status');
    }

    print('\n✅ All servers are running and ready for manual testing:');
    print('   - Outsyncs Server:     $_outsyncsUrl');
    print('   - Downsyncs Server:   $_downsyncsUrl');
    print('   - Cloud Storage:      $_cloudStorageUrl');

    await _showApiDocumentation();
  }

  Future<void> _showApiDocumentation() async {
    try {
      // Get API documentation from one of the servers
      final response = await _dio.get('$_cloudStorageUrl/api/help');
      final docs = response.data as Map<String, dynamic>;

      print('\n📚 Available endpoints on each server:');

      for (final endpoint in docs['endpoints']) {
        final method = endpoint['method'].toString().padRight(6);
        final path = endpoint['path'].toString().padRight(25);
        print('   $method $path - ${endpoint['description']}');
      }

      print('');
      print('   Notes:');
      for (final note in docs['notes']) {
        print('   • $note');
      }
    } catch (e) {
      // Fallback to static documentation if API call fails
      print('\n📚 Available endpoints on each server:');
      print('   GET  /health                  - Health check');
      print('   GET  /api/help               - API documentation');
      print('   GET  /api/changes            - Get all changes');
      print('   GET  /api/changes/{seq}      - Get specific change');
      print('   POST /api/changes            - Create new changes (array)');
      print('   GET  /api/stats              - Get statistics');
      print('');
      print('   Note: PUT and DELETE endpoints have been removed.');
      print('   Change logs are now append-only for data integrity.');
    }
  }

  Future<void> _demonstrateSequenceMapping() async {
    print('\n--- Step 2A: Sequence Mapping ---');
    print('Demonstrating how cloud storage creates new sequences and provides seqMap...');

    // Create changes with explicit old sequences that should be ignored
    final changes = [
      {
        'seq': 9999, // This will be ignored
        'entityType': 'Document',
        'operation': 'create',
        'entityId': 'demo-seq-mapping-1',
        'data': {'title': 'Document with Old Seq 9999'},
      },
      {
        'seq': 8888, // This will also be ignored
        'entityType': 'Document',
        'operation': 'create',
        'entityId': 'demo-seq-mapping-2',
        'data': {'title': 'Document with Old Seq 8888'},
      }
    ];

    final response = await _dio.post('$_cloudStorageUrl/api/changes', data: changes);
    final responseData = response.data as Map<String, dynamic>;

    if (responseData['success']) {
      final seqMap = responseData['seqMap'] as Map<String, dynamic>;
      print('✓ Created ${responseData['created']} changes in cloud storage');
      print('✓ Sequence mappings:');
      seqMap.forEach((oldSeq, newSeq) {
        print('   Old seq $oldSeq → New seq $newSeq');
      });
    } else {
      print('✗ Failed to create changes: ${responseData['error']}');
    }
  }

  Future<void> _demonstrateOutdatedChanges() async {
    print('\n--- Step 2B: Outdated Changes ---');
    print('Demonstrating how outdated changes are excluded from sync...');

    // Create a change in outsyncs
    final change = {
      'entityType': 'Document',
      'operation': 'create',
      'entityId': 'demo-outdated-change',
      'data': {'title': 'This change will be marked outdated'},
    };

    final createResponse = await _dio.post('$_outsyncsUrl/api/changes', data: [change]);
    final createData = createResponse.data as Map<String, dynamic>;
    final seqMap = createData['seqMap'] as Map<String, dynamic>;
    final createdSeq = seqMap.values.first as int;

    print('✓ Created change with seq: $createdSeq');

    // Mark it as outdated using the storage service directly
    // (PUT endpoint has been removed - change logs are now append-only)
    await _outsyncsStorage.markAsOutdated(createdSeq, 99999);

    print('✓ Marked change as outdated (outdatedBy: 99999)');

    // Get cloud stats before sync attempt
    final statsBefore = await _dio.get('$_cloudStorageUrl/api/stats');
    final countBefore = statsBefore.data['changeStats']['total'] as int;

    // Attempt to sync - should skip outdated changes
    final outsyncResult = await _syncManager.outsyncToCloud();
    if (outsyncResult.seqMap.isEmpty) {
      print('✓ Outsync correctly skipped outdated changes');
    } else {
      print('✗ Outdated change was unexpectedly synced');
    }

    // Verify cloud count didn't change
    final statsAfter = await _dio.get('$_cloudStorageUrl/api/stats');
    final countAfter = statsAfter.data['changeStats']['total'] as int;

    if (countAfter == countBefore) {
      print('✓ Cloud storage count remained unchanged: $countAfter');
    } else {
      print('✗ Cloud storage count changed unexpectedly: $countBefore → $countAfter');
    }
  }

  Future<void> cleanup() async {
    print('\n🧹 Cleaning up...');
    try {
      await _syncManager.close();
      await _serverLauncher.stopAllServers();
      print('✅ Cleanup completed');
    } catch (e) {
      print('⚠️ Cleanup error: $e');
    }
  }
}

void main() async {
  final demo = SyncSystemDemo();

  // Set up signal handlers for graceful shutdown
  ProcessSignal.sigint.watch().listen((signal) async {
    print('\n\n🛑 Shutting down...');
    await demo.cleanup();
    exit(0);
  });

  try {
    await demo.runDemo();
  } catch (e) {
    print('Demo execution failed: $e');
    await demo.cleanup();
    exit(1);
  }
}
