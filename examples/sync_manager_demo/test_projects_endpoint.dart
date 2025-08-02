#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sync_manager/sync_manager.dart';

Future<void> main() async {
  print('🧪 Testing /api/projects endpoint\n');

  // Create an enhanced REST API server with local storage
  final server = EnhancedRestApiServer(StorageType.outsyncs, 'Test Server');
  await server.start(port: 8081);

  print('✅ Server started on port 8081\n');

  try {
    // Test 1: Create some test project changes
    print('🔍 Creating test project changes...');

    final projectChanges = [
      {
        'projectId': 'project-alpha',
        'entityType': 'project',
        'operation': 'create',
        'entityId': 'project-alpha',
        'data': {'name': 'Alpha Project', 'description': 'First test project'},
      },
      {
        'projectId': 'project-beta',
        'entityType': 'project',
        'operation': 'create',
        'entityId': 'project-beta',
        'data': {'name': 'Beta Project', 'description': 'Second test project'},
      },
    ];

    for (final change in projectChanges) {
      final response = await http.post(
        Uri.parse('http://localhost:8081/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([change]),
      );

      if (response.statusCode == 200) {
        print('   ✅ Created project: ${change['projectId']}');
      } else {
        print(
          '   ❌ Failed to create project: ${change['projectId']} - ${response.statusCode}',
        );
        print('      Response: ${response.body}');
      }
    }

    // Test 2: Get all projects
    print('\n🔍 Testing /api/projects endpoint...');
    final projectsResponse = await http.get(
      Uri.parse('http://localhost:8081/api/projects'),
    );

    if (projectsResponse.statusCode == 200) {
      final projectsData = jsonDecode(projectsResponse.body);
      print('   ✅ Projects endpoint responded successfully');
      print('   📋 Found ${projectsData['count']} projects:');

      for (final projectId in projectsData['projects']) {
        print('     - $projectId');
      }
    } else {
      print('   ❌ Projects endpoint failed: ${projectsResponse.statusCode}');
      print('      Response: ${projectsResponse.body}');
    }
  } catch (e, stackTrace) {
    print('❌ Test failed with error: $e');
    print('Stack trace: $stackTrace');
  } finally {
    print('\n🛑 Shutting down server...');
    await server.stop();
    print('✅ Server stopped');
  }
}
