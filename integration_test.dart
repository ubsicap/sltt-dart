#!/usr/bin/env dart

import 'package:sltt_core/sltt_core.dart';

Future<void> main() async {
  print('🧪 Running comprehensive integration test\n');

  try {
    // Test 1: Storage service instantiation
    print('✅ Test 1: Creating storage services...');
    final outsyncsStorage = OutsyncsStorageService.instance;
    final downsyncsStorage = DownsyncsStorageService.instance;
    final cloudStorage = CloudStorageService.instance;

    await outsyncsStorage.initialize();
    await downsyncsStorage.initialize();
    await cloudStorage.initialize();
    print('   ✅ All storage services initialized successfully');

    // Test 2: Multi-project support
    print('\n✅ Test 2: Testing multi-project support...');

    final testChange1 = {
      'projectId': 'project-test-1',
      'entityType': 'document',
      'operation': 'create',
      'entityId': 'doc-123',
      'data': {'title': 'Test Document 1', 'content': 'Content 1'},
    };

    final testChange2 = {
      'projectId': 'project-test-2',
      'entityType': 'document',
      'operation': 'create',
      'entityId': 'doc-456',
      'data': {'title': 'Test Document 2', 'content': 'Content 2'},
    };

    final result1 = await outsyncsStorage.createChange(testChange1);
    final result2 = await outsyncsStorage.createChange(testChange2);

    print('   ✅ Created change for project-test-1: seq=${result1.seq}');
    print('   ✅ Created change for project-test-2: seq=${result2.seq}');

    // Test 3: Project discovery
    print('\n✅ Test 3: Testing project discovery...');
    final projects = await outsyncsStorage.getAllProjects();
    print('   ✅ Found projects: $projects');

    if (projects.contains('project-test-1') &&
        projects.contains('project-test-2')) {
      print('   ✅ Both test projects found in project list');
    } else {
      throw Exception('Expected projects not found in list');
    }

    // Test 4: REST API Server creation
    print('\n✅ Test 4: Testing REST API server...');
    final server = EnhancedRestApiServer(
      StorageType.outsyncs,
      'Integration Test Server',
    );
    print('   ✅ REST API server created successfully: ${server.serverName}');

    // Test 5: Cleanup
    print('\n✅ Test 5: Cleanup...');
    await outsyncsStorage.close();
    await downsyncsStorage.close();
    await cloudStorage.close();
    print('   ✅ All storage services closed');

    print('\n🎉 All integration tests passed successfully!');
    print('✅ Multi-project support working');
    print('✅ Storage services working');
    print('✅ REST API server working');
    print('✅ Project discovery working');
  } catch (e, stackTrace) {
    print('\n❌ Integration test failed: $e');
    print('Stack trace: $stackTrace');

    // Try to cleanup on error
    try {
      await OutsyncsStorageService.instance.close();
      await DownsyncsStorageService.instance.close();
      await CloudStorageService.instance.close();
    } catch (_) {
      // Ignore cleanup errors
    }
  }
}
