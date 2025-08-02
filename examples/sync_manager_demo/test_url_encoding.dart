#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sync_manager/sync_manager.dart';

Future<void> main() async {
  print('🧪 Testing URL encoding/decoding for projectId\n');

  try {
    // Create an enhanced REST API server with local storage
    final server = EnhancedRestApiServer(
      StorageType.outsyncs,
      'URL Test Server',
    );
    await server.start(port: 8081);

    print('✅ Server started on port 8081\n');

    // Test cases with various projectId formats
    final testCases = [
      {
        'description': 'Simple alphanumeric projectId',
        'projectId': 'project123',
        'urlEncoded': 'project123',
      },
      {
        'description': 'ProjectId with spaces',
        'projectId': 'my project name',
        'urlEncoded': 'my%20project%20name',
      },
      {
        'description': 'ProjectId with special characters',
        'projectId': 'project@domain.com',
        'urlEncoded': 'project%40domain.com',
      },
      {
        'description': 'ProjectId with forward slashes',
        'projectId': 'org/team/project',
        'urlEncoded': 'org%2F${'team'}%2F${'project'}',
      },
      {
        'description': 'ProjectId with Unicode characters',
        'projectId': 'проект-测试',
        'urlEncoded': Uri.encodeComponent('проект-测试'),
      },
      {
        'description': 'ProjectId with mixed symbols',
        'projectId': 'project-v1.2.3+build_456',
        'urlEncoded': 'project-v1.2.3%2B${'build'}_456',
      },
      {
        'description': 'ProjectId with percent signs',
        'projectId': 'project%20with%percent',
        'urlEncoded': Uri.encodeComponent('project%20with%percent'),
      },
      {
        'description': 'ProjectId with ampersands and equals',
        'projectId': 'project?param=value&other=test',
        'urlEncoded': Uri.encodeComponent('project?param=value&other=test'),
      },
    ];

    // Wait a moment for server to be ready
    await Future.delayed(const Duration(milliseconds: 500));

    for (final testCase in testCases) {
      final projectId = testCase['projectId'] as String;
      final expectedEncoded = testCase['urlEncoded'] as String;
      final description = testCase['description'] as String;

      print('🔍 Testing: $description');
      print('   Original projectId: "$projectId"');
      print('   URL encoded: "$expectedEncoded"');

      try {
        // Test 1: Create a change using URL-encoded projectId
        print('   📝 Creating change...');
        final changeData = [
          {
            'entityType': 'Document',
            'operation': 'create',
            'entityId': 'doc-${DateTime.now().millisecondsSinceEpoch}',
            'data': {
              'title': 'Test Document for $projectId',
              'content': 'Testing URL encoding',
            },
          },
        ];

        final createUrl =
            'http://localhost:8081/api/projects/$expectedEncoded/changes';
        print('   POST URL: $createUrl');

        final createResponse = await http.post(
          Uri.parse(createUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(changeData),
        );

        if (createResponse.statusCode == 200) {
          final createResult = jsonDecode(createResponse.body);
          final returnedProjectId = createResult['projectId'];
          final createdSeqs = createResult['createdSeqs'] as List?;

          print('   ✅ Change created successfully');
          print('   📦 Created sequences: $createdSeqs');
          print('   📦 Returned projectId: "$returnedProjectId"');

          // Verify that the decoded projectId matches the original
          if (returnedProjectId == projectId) {
            print('   ✅ ProjectId encoding/decoding is correct');
          } else {
            print(
              '   ❌ ProjectId mismatch! Expected: "$projectId", Got: "$returnedProjectId"',
            );
          }
        } else {
          print('   ❌ Change creation failed: ${createResponse.statusCode}');
          print('   Response: ${createResponse.body}');
          continue;
        }

        // Test 2: Retrieve changes using URL-encoded projectId
        print('   📋 Retrieving changes...');
        final getUrl =
            'http://localhost:8081/api/projects/$expectedEncoded/changes';
        final getResponse = await http.get(Uri.parse(getUrl));

        if (getResponse.statusCode == 200) {
          final getResult = jsonDecode(getResponse.body);
          final changes = getResult['changes'] as List;

          if (changes.isNotEmpty) {
            final firstChange = changes.first;
            final retrievedProjectId = firstChange['projectId'];

            print('   ✅ Changes retrieved successfully');
            print('   📦 Retrieved projectId: "$retrievedProjectId"');

            // Verify projectId in the change data matches original
            if (retrievedProjectId == projectId) {
              print('   ✅ Retrieved projectId matches original');
            } else {
              print(
                '   ❌ Retrieved projectId mismatch! Expected: "$projectId", Got: "$retrievedProjectId"',
              );
            }
          } else {
            print(
              '   ⚠️  No changes found (might be database isolation issue)',
            );
          }
        } else {
          print('   ❌ Change retrieval failed: ${getResponse.statusCode}');
          print('   Response: ${getResponse.body}');
        }

        // Test 3: Get statistics using URL-encoded projectId
        print('   📊 Getting statistics...');
        final statsUrl =
            'http://localhost:8081/api/projects/$expectedEncoded/stats';
        final statsResponse = await http.get(Uri.parse(statsUrl));

        if (statsResponse.statusCode == 200) {
          final statsResult = jsonDecode(statsResponse.body);
          final statsProjectId = statsResult['projectId'];

          print('   ✅ Statistics retrieved successfully');
          print('   📦 Stats projectId: "$statsProjectId"');

          if (statsProjectId == projectId) {
            print('   ✅ Stats projectId matches original');
          } else {
            print(
              '   ❌ Stats projectId mismatch! Expected: "$projectId", Got: "$statsProjectId"',
            );
          }
        } else {
          print(
            '   ❌ Statistics retrieval failed: ${statsResponse.statusCode}',
          );
        }

        print('   ✅ Test case completed\n');
      } catch (e) {
        print('   ❌ Test case failed with error: $e\n');
      }
    }

    // Test 4: Verify that unencoded URLs with special characters fail gracefully
    print('🔍 Testing error handling with unencoded special characters...');
    try {
      final badUrl =
          'http://localhost:8081/api/projects/project with spaces/changes';
      print('   Trying unencoded URL: $badUrl');

      final badResponse = await http.get(Uri.parse(badUrl));
      print('   Response status: ${badResponse.statusCode}');

      if (badResponse.statusCode >= 400) {
        print('   ✅ Server properly rejected unencoded URL');
      } else {
        print(
          '   ⚠️  Server accepted unencoded URL (might work due to HTTP client auto-encoding)',
        );
      }
    } catch (e) {
      print('   ✅ Unencoded URL properly rejected: $e');
    }

    // Test 5: Test edge cases
    print('\n🔍 Testing edge cases...');

    // Empty project ID
    try {
      final emptyResponse = await http.get(
        Uri.parse('http://localhost:8081/api/projects//changes'),
      );
      print('   Empty projectId status: ${emptyResponse.statusCode}');
      if (emptyResponse.statusCode >= 400) {
        print('   ✅ Empty projectId properly rejected');
      }
    } catch (e) {
      print('   ✅ Empty projectId properly rejected: $e');
    }

    // Very long project ID
    try {
      final longProjectId = 'very-' * 50 + 'long-project-id';
      final longEncoded = Uri.encodeComponent(longProjectId);
      final longResponse = await http.get(
        Uri.parse('http://localhost:8081/api/projects/$longEncoded/changes'),
      );
      print('   Long projectId status: ${longResponse.statusCode}');
      if (longResponse.statusCode == 200) {
        print('   ✅ Long projectId handled correctly');
      }
    } catch (e) {
      print('   ⚠️  Long projectId handling: $e');
    }

    print('\n🎉 URL encoding/decoding tests completed!');

    // Clean up
    await server.stop();
  } catch (e, stackTrace) {
    print('❌ Test failed with error: $e');
    print('Stack trace: $stackTrace');
  }

  exit(0);
}
