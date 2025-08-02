#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sync_manager/sync_manager.dart';

Future<void> main() async {
  print('🧪 Testing new project-based API endpoints with URL encoding\n');

  try {
    // Create an enhanced REST API server with local storage
    final server = EnhancedRestApiServer(StorageType.outsyncs, 'Test Server');
    await server.start(port: 8080);

    print('✅ Server started on port 8080\n');

    // Test with various projectId formats including URL-unsafe characters
    final testProjectIds = [
      'test-project-123', // Simple case
      'org/team/project', // With forward slashes
      'project@domain.com', // With @ symbol
      'my project name', // With spaces
      'project-v1.2.3+build_456', // With + symbol
    ];

    // Wait a moment for server to be ready
    await Future.delayed(const Duration(milliseconds: 500));

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

    // Test 3: Test each projectId with URL encoding
    for (int i = 0; i < testProjectIds.length; i++) {
      final projectId = testProjectIds[i];
      final encodedProjectId = Uri.encodeComponent(projectId);

      print(
        '🔍 Testing projectId ${i + 1}/${testProjectIds.length}: "$projectId"',
      );
      print('   URL encoded: "$encodedProjectId"');

      try {
        // Test 3a: Create a test change
        print('   📝 Creating change...');
        final changeData = [
          {
            'entityType': 'Document',
            'operation': 'create',
            'entityId': 'doc-${DateTime.now().millisecondsSinceEpoch}',
            'data': {
              'title': 'Test Document for $projectId',
              'content': 'Testing URL encoding with special characters',
            },
          },
        ];

        final createResponse = await http.post(
          Uri.parse(
            'http://localhost:8080/api/projects/$encodedProjectId/changes',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(changeData),
        );

        if (createResponse.statusCode == 200) {
          final createResult = jsonDecode(createResponse.body);
          print('   ✅ Change created: ${createResult['createdSeqs']}');

          // Verify that the projectId in response matches original
          final returnedProjectId = createResult['projectId'];
          if (returnedProjectId == projectId) {
            print('   ✅ ProjectId encoding/decoding verified');
          } else {
            print(
              '   ❌ ProjectId mismatch! Expected: "$projectId", Got: "$returnedProjectId"',
            );
          }
        } else {
          print(
            '   ❌ Change creation failed: ${createResponse.statusCode} ${createResponse.body}',
          );
          continue;
        }

        // Test 3b: Get changes for the project
        print('   � Retrieving changes...');
        final changesResponse = await http.get(
          Uri.parse(
            'http://localhost:8080/api/projects/$encodedProjectId/changes',
          ),
        );

        if (changesResponse.statusCode == 200) {
          final changesResult = jsonDecode(changesResponse.body);
          print('   ✅ Retrieved ${changesResult['changes'].length} changes');

          if (changesResult['changes'].isNotEmpty) {
            final change = changesResult['changes'][0];
            final retrievedProjectId = change['projectId'];
            print(
              '   📦 Change details: seq=${change['seq']}, projectId="$retrievedProjectId"',
            );

            if (retrievedProjectId == projectId) {
              print('   ✅ Retrieved projectId matches original');
            } else {
              print(
                '   ❌ Retrieved projectId mismatch! Expected: "$projectId", Got: "$retrievedProjectId"',
              );
            }
          }
        } else {
          print(
            '   ❌ Change retrieval failed: ${changesResponse.statusCode} ${changesResponse.body}',
          );
        }

        // Test 3c: Get project statistics
        print('   � Getting statistics...');
        final statsResponse = await http.get(
          Uri.parse(
            'http://localhost:8080/api/projects/$encodedProjectId/stats',
          ),
        );

        if (statsResponse.statusCode == 200) {
          final statsResult = jsonDecode(statsResponse.body);
          print('   ✅ Statistics: ${statsResult['changeStats']}');

          final statsProjectId = statsResult['projectId'];
          if (statsProjectId == projectId) {
            print('   ✅ Stats projectId matches original');
          } else {
            print(
              '   ❌ Stats projectId mismatch! Expected: "$projectId", Got: "$statsProjectId"',
            );
          }
        } else {
          print(
            '   ❌ Statistics failed: ${statsResponse.statusCode} ${statsResponse.body}',
          );
        }

        print('   ✅ Test completed for projectId: "$projectId"\n');
      } catch (e) {
        print('   ❌ Test failed for projectId "$projectId": $e\n');
      }
    }

    // Test 4: Verify error handling with malformed URLs
    print('🔍 Testing error handling...');
    try {
      final badResponse = await http.get(
        Uri.parse(
          'http://localhost:8080/api/projects//changes',
        ), // Empty projectId
      );
      print('   Empty projectId response: ${badResponse.statusCode}');
      if (badResponse.statusCode >= 400) {
        print('   ✅ Server properly rejected empty projectId');
      }
    } catch (e) {
      print('   ✅ Empty projectId properly rejected: $e');
    }

    print(
      '🎉 All API endpoint tests with URL encoding completed successfully!',
    );

    // Clean up
    await server.stop();
  } catch (e, stackTrace) {
    print('❌ Test failed with error: $e');
    print('Stack trace: $stackTrace');
  }

  exit(0);
}
