import 'dart:io';
import 'package:dio/dio.dart';
import '../lib/core/server/multi_server_launcher.dart';
import '../lib/core/server/server_ports.dart';
import '../lib/core/storage/shared_storage_service.dart';

/// Simple test to verify optional operation field and outdated filtering
void main() async {
  print('🧪 Testing optional operation field and outdated filtering...\n');

  final dio = Dio();
  dio.options.headers['Content-Type'] = 'application/json';

  final serverLauncher = MultiServerLauncher.instance;
  final outsyncsStorage = OutsyncsStorageService.instance;

  try {
    // Start servers
    print('Starting servers...');
    await serverLauncher.startAllServers();
    await Future.delayed(const Duration(milliseconds: 500));

    final outsyncsUrl = 'http://localhost:$kOutsyncsPort';

    // Test 1: Create change without operation field (should default to 'create')
    print('Test 1: Creating change without operation field...');
    final changeWithoutOp = {
      'entityType': 'TestEntity',
      'entityId': 'test-no-op',
      'data': {'name': 'Test without operation'},
    };

    final response1 = await dio.post('$outsyncsUrl/api/changes', data: [changeWithoutOp]);
    if (response1.statusCode != 200) {
      throw Exception('Failed to create change without operation field');
    }

    final data1 = response1.data as Map<String, dynamic>;
    if (data1['success'] != true || data1['created'] != 1) {
      throw Exception('Expected successful creation, got: $data1');
    }

    print('✅ Successfully created change without operation field');

    // Test 2: Create change with operation field
    print('Test 2: Creating change with operation field...');
    final changeWithOp = {
      'entityType': 'TestEntity',
      'operation': 'update',
      'entityId': 'test-with-op',
      'data': {'name': 'Test with operation'},
    };

    final response2 = await dio.post('$outsyncsUrl/api/changes', data: [changeWithOp]);
    if (response2.statusCode != 200) {
      throw Exception('Failed to create change with operation field');
    }

    final data2 = response2.data as Map<String, dynamic>;
    if (data2['success'] != true || data2['created'] != 1) {
      throw Exception('Expected successful creation, got: $data2');
    }

    print('✅ Successfully created change with operation field');

    // Test 3: Verify outdated filtering
    print('Test 3: Testing outdated changes filtering...');

    // Get the sequence of the first change
    final seqMap1 = data1['seqMap'] as Map<String, dynamic>;
    final seq1 = seqMap1.values.first as int;

    // Mark it as outdated
    await outsyncsStorage.markAsOutdated(seq1, 99999);
    print('Marked change seq $seq1 as outdated');

    // Get changes for sync - should exclude the outdated one
    final changesForSync = await outsyncsStorage.getChangesForSync();
    print('Found ${changesForSync.length} changes for sync');

    // Verify the outdated change is excluded
    final outdatedChangeInSync = changesForSync.any((c) => c['seq'] == seq1);
    if (outdatedChangeInSync) {
      throw Exception('Outdated change was included in sync results');
    }

    print('✅ Outdated changes correctly filtered from sync');

    // Test 4: Verify the non-outdated change is still included
    final seqMap2 = data2['seqMap'] as Map<String, dynamic>;
    final seq2 = seqMap2.values.first as int;

    final nonOutdatedChangeInSync = changesForSync.any((c) => c['seq'] == seq2);
    if (!nonOutdatedChangeInSync) {
      throw Exception('Non-outdated change was incorrectly excluded from sync results');
    }

    print('✅ Non-outdated changes correctly included in sync');

    print('\n🎉 All tests passed! Optional operation field and outdated filtering work correctly.');
  } catch (e) {
    print('\n❌ Test failed: $e');
    exit(1);
  } finally {
    // Cleanup
    try {
      await serverLauncher.stopAllServers();
    } catch (e) {
      print('Warning: Cleanup error: $e');
    }
  }
}
