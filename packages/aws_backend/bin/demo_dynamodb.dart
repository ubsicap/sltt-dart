#!/usr/bin/env dart

import 'package:aws_backend/aws_backend.dart';

/// Demo script to test DynamoDB Local integration.
///
/// Prerequisites:
/// 1. Install DynamoDB Local: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html
/// 2. Start DynamoDB Local: java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb
/// 3. Run this script: dart run demo_dynamodb.dart
Future<void> main() async {
  print('🚀 Starting DynamoDB Integration Demo\n');

  // Create DynamoDB storage service using local DynamoDB
  final storage = DynamoDBStorageService(
    tableName: 'sltt-demo-changes',
    projectId: 'demo-project-123',
    region: 'us-east-1',
    useLocalDynamoDB: true,
    localEndpoint: 'http://localhost:8000',
  );

  try {
    // Initialize the storage service
    print('🔧 Initializing DynamoDB storage...');
    await storage.initialize();
    print('✅ DynamoDB storage initialized\n');

    // Test 1: Create some changes
    print('📝 Testing change creation...');
    final change1 = await storage.createChange({
      'entityType': 'Document',
      'operation': 'create',
      'entityId': 'doc-001',
      'data': {
        'title': 'My First Document',
        'content': 'This is the content of my first document.',
        'author': 'demo-user',
      },
    });
    print('   Created change: ${change1['seq']} - ${change1['entityType']}/${change1['entityId']}');

    final change2 = await storage.createChange({
      'entityType': 'Document',
      'operation': 'update',
      'entityId': 'doc-001',
      'data': {
        'title': 'My Updated Document',
        'content': 'This is the updated content.',
        'author': 'demo-user',
        'lastModified': DateTime.now().toIso8601String(),
      },
    });
    print('   Created change: ${change2['seq']} - ${change2['entityType']}/${change2['entityId']}');

    final change3 = await storage.createChange({
      'entityType': 'User',
      'operation': 'create',
      'entityId': 'user-001',
      'data': {
        'name': 'Demo User',
        'email': 'demo@example.com',
        'role': 'editor',
      },
    });
    print('   Created change: ${change3['seq']} - ${change3['entityType']}/${change3['entityId']}');
    print('✅ Change creation test passed\n');

    // Test 2: Get changes with cursor
    print('🔍 Testing change retrieval with cursor...');
    final allChanges = await storage.getChangesWithCursor();
    print('   Retrieved ${allChanges.length} changes total');

    final limitedChanges = await storage.getChangesWithCursor(limit: 2);
    print('   Retrieved ${limitedChanges.length} changes with limit=2');

    if (limitedChanges.isNotEmpty) {
      final cursor = limitedChanges.last['seq'] as int;
      final remainingChanges = await storage.getChangesWithCursor(cursor: cursor);
      print('   Retrieved ${remainingChanges.length} changes after cursor=$cursor');
    }
    print('✅ Cursor-based retrieval test passed\n');

    // Test 3: Get specific change
    print('🎯 Testing specific change retrieval...');
    final specificChange = await storage.getChange(change1['seq'] as int);
    if (specificChange != null) {
      print(
          '   Retrieved change ${specificChange['seq']}: ${specificChange['entityType']}/${specificChange['entityId']}',);
      print('   Data: ${specificChange['data']}');
    } else {
      print('   ❌ Failed to retrieve specific change');
    }
    print('✅ Specific change retrieval test passed\n');

    // Test 4: Get changes since sequence
    print('📈 Testing changes since sequence...');
    final changesSince = await storage.getChangesSince(change1['seq'] as int);
    print('   Retrieved ${changesSince.length} changes since seq ${change1['seq']}');
    for (final change in changesSince) {
      print('   - ${change['seq']}: ${change['entityType']}/${change['entityId']} (${change['operation']})');
    }
    print('✅ Changes since test passed\n');

    // Test 5: Get statistics
    print('📊 Testing statistics...');
    final changeStats = await storage.getChangeStats();
    print('   Change stats: $changeStats');

    final entityStats = await storage.getEntityTypeStats();
    print('   Entity type stats: $entityStats');
    print('✅ Statistics test passed\n');

    // Test 6: Get non-outdated changes
    print('🔄 Testing non-outdated changes...');
    final nonOutdatedChanges = await storage.getChangesNotOutdated();
    print('   Retrieved ${nonOutdatedChanges.length} non-outdated changes');
    print('✅ Non-outdated changes test passed\n');

    print('🎉 All DynamoDB integration tests passed!\n');

    // Optional: Start a simple REST API server
    print('🌐 Starting REST API server on port 9000...');
    print('   Try: curl http://localhost:9000/health');
    print('   Try: curl http://localhost:9000/api/changes');
    print('   Try: curl http://localhost:9000/api/stats');
    print('   Press Ctrl+C to stop\n');

    final server = AwsRestApiServer(
      serverName: 'DynamoDB-Demo',
      storage: storage,
    );

    await server.start(port: 9000);

    // Keep the server running
    await Future.delayed(const Duration(hours: 1));
  } catch (e, stackTrace) {
    print('❌ Error during demo: $e');
    print('Stack trace: $stackTrace');
  } finally {
    // Clean up
    await storage.close();
    print('🧹 Demo completed, storage closed');
  }
}
