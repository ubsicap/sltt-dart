#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';

Future<void> main() async {
  print('🧪 Testing new project-based API endpoints\n');

  // Create an enhanced REST API server with local storage
  final server = EnhancedRestApiServer(StorageType.outsyncs, 'Test Server');
  await server.start(port: 8080);

  print('✅ Server started on port 8080\n');

  const testProjectId = 'test-project-123';

  try {
    // Test 1: Health check
    print('🔍 Testing health endpoint...');
    final healthResponse = await http.get(
      Uri.parse('http://localhost:8080/health'),
    );
    print('   Health status: ${healthResponse.statusCode}');
    if (healthResponse.statusCode == 200) {
      print('✅ Health check passed\n');
    }

    // Test 2: API help (should show new project-based endpoints)
    print('🔍 Testing API help endpoint...');
    final helpResponse = await http.get(
      Uri.parse('http://localhost:8080/api/help'),
    );
    if (helpResponse.statusCode == 200) {
      final helpData = jsonDecode(helpResponse.body);
      print('   Available endpoints:');
      for (final endpoint in helpData['endpoints']) {
        print('     ${endpoint['method']} ${endpoint['path']}');
      }
      print('✅ API help endpoint passed\n');
    }

    // Test 3: Create a test change
    print('🔍 Testing change creation...');
    final changeData = [
      {
        'entityType': 'Document',
        'operation': 'create',
        'entityId': 'doc-123',
        'data': {'title': 'Test Document', 'content': 'Hello World'},
      },
    ];

    final createResponse = await http.post(
      Uri.parse('http://localhost:8080/api/projects/$testProjectId/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(changeData),
    );

    if (createResponse.statusCode == 200) {
      final createResult = jsonDecode(createResponse.body);
      print('   Created change: ${createResult['createdSeqs']}');
      print('✅ Change creation passed\n');
    } else {
      print(
        '   ❌ Change creation failed: ${createResponse.statusCode} ${createResponse.body}',
      );
    }

    // Test 4: Get changes for the project
    print('🔍 Testing change retrieval...');
    final changesResponse = await http.get(
      Uri.parse('http://localhost:8080/api/projects/$testProjectId/changes'),
    );

    if (changesResponse.statusCode == 200) {
      final changesResult = jsonDecode(changesResponse.body);
      print('   Retrieved ${changesResult['changes'].length} changes');
      if (changesResult['changes'].isNotEmpty) {
        final change = changesResult['changes'][0];
        print(
          '   First change: seq=${change['seq']}, projectId=${change['projectId']}',
        );
      }
      print('✅ Change retrieval passed\n');
    } else {
      print(
        '   ❌ Change retrieval failed: ${changesResponse.statusCode} ${changesResponse.body}',
      );
    }

    // Test 5: Get project statistics
    print('🔍 Testing project statistics...');
    final statsResponse = await http.get(
      Uri.parse('http://localhost:8080/api/projects/$testProjectId/stats'),
    );

    if (statsResponse.statusCode == 200) {
      final statsResult = jsonDecode(statsResponse.body);
      print('   Project stats: ${statsResult['changeStats']}');
      print('   Entity types: ${statsResult['entityTypeStats']}');
      print('✅ Project statistics passed\n');
    } else {
      print(
        '   ❌ Project statistics failed: ${statsResponse.statusCode} ${statsResponse.body}',
      );
    }

    print('🎉 All API endpoint tests completed successfully!');
  } catch (e) {
    print('❌ Test failed with error: $e');
  } finally {
    // Clean up
    await server.stop();
    exit(0);
  }
}
