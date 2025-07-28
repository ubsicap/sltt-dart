#!/usr/bin/env dart

import 'package:aws_backend/aws_backend.dart';

Future<void> main() async {
  print('🧪 Testing AWS DynamoDB multi-project support\n');

  // Create DynamoDB storage service without fixed project ID
  final storage = DynamoDBStorageService(
    tableName: 'sltt-test-changes',
    useLocalDynamoDB: true, // Use local DynamoDB for testing
  );

  // Create AWS REST API server
  final server = AwsRestApiServer(
    serverName: 'AWS Test Server',
    storage: storage,
  );

  try {
    await server.start(port: 8082);
    print('✅ AWS server started on port 8082\n');

    // Test creating changes for multiple projects
    final testChanges = [
      {
        'projectId': 'project-gamma',
        'entityType': 'project',
        'operation': 'create',
        'entityId': 'project-gamma',
        'data': {'name': 'Gamma Project', 'description': 'AWS test project'},
      },
      {
        'projectId': 'project-delta',
        'entityType': 'document',
        'operation': 'create',
        'entityId': 'doc-456',
        'data': {'title': 'Delta Document', 'content': 'Test content'},
      },
    ];

    print('🔍 Testing multi-project change creation...');
    for (final change in testChanges) {
      final result = await storage.createChange(change);
      print(
        '   ✅ Created change for ${change['projectId']}: seq=${result['seq']}',
      );
    }

    print('\n🔍 Testing getAllProjects...');
    final projects = await storage.getAllProjects();
    print('   ✅ Found projects: $projects');

    print('\n✅ All tests passed!');
  } catch (e, stackTrace) {
    print('❌ Test failed: $e');
    print('Stack trace: $stackTrace');
  } finally {
    await server.stop();
    print('\n🛑 Server stopped');
  }
}
