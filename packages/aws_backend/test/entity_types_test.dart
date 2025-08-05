import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  print('Testing against: $baseUrl');
  const testProjectId = '_test_entity_types_project';

  group('Entity Types Endpoint Tests', () {
    setUpAll(() async {
      // Create a test project first
      final testProjectChange = [
        {
          'projectId': testProjectId,
          'entityType': 'project',
          'operation': 'create',
          'entityId':
              testProjectId, // Project entities must have entityId == projectId
          'data': {
            'name': '_test_entity_types_project',
            'description': 'Test project for entity types endpoint testing',
            'tags': ['test', 'integration', 'entity-types'],
          },
        },
      ];

      final response = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(testProjectChange),
      );

      expect(response.statusCode, equals(200));
      print('✅ Test project created for entity types testing');
    });

    test(
      'GET /api/projects/{projectId}/entities returns supported entity types',
      () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/projects/$testProjectId/entities'),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        expect(data['entityTypes'], isA<List>());

        final entityTypes = List<String>.from(data['entityTypes']);

        // Should contain all standard entity types
        final expectedTypes = [
          'project',
          'team',
          'plan',
          'stage',
          'task',
          'member',
          'message',
          'portion',
          'passage',
          'reference',
          'document',
          'video',
          'patch',
          'gloss',
          'note',
          'comment',
        ];

        for (final expectedType in expectedTypes) {
          expect(entityTypes, contains(expectedType));
        }

        print('✅ Entity types endpoint test passed!');
        print('   Entity types count: ${entityTypes.length}');
        print('   Entity types: ${entityTypes.join(', ')}');
      },
      tags: ['internet', 'integration'],
    );

    test(
      'GET /api/projects/{projectId}/entities with URL-encoded project ID',
      () async {
        final encodedProjectId = Uri.encodeComponent(testProjectId);
        final response = await http.get(
          Uri.parse('$baseUrl/api/projects/$encodedProjectId/entities'),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        expect(data['entityTypes'], isA<List>());

        final entityTypes = List<String>.from(data['entityTypes']);
        expect(entityTypes.length, greaterThan(0));

        print('✅ URL-encoded project ID test passed!');
        print('   Entity types count: ${entityTypes.length}');
      },
      tags: ['internet', 'integration'],
    );

    test(
      'GET /api/projects/nonexistent/entities returns entity types (no 404)',
      () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/projects/nonexistent-project-123/entities'),
        );

        // Should still return supported entity types even for non-existent projects
        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        expect(data['entityTypes'], isA<List>());

        final entityTypes = List<String>.from(data['entityTypes']);
        expect(entityTypes.length, greaterThan(0));

        print('✅ Non-existent project test passed!');
        print('   Entity types count: ${entityTypes.length}');
      },
      tags: ['internet', 'integration'],
    );

    test(
      'GET /api/projects/{projectId}/entities with special characters in project ID',
      () async {
        final specialProjectId = 'test@project+with/special chars';
        final encodedProjectId = Uri.encodeComponent(specialProjectId);

        final response = await http.get(
          Uri.parse('$baseUrl/api/projects/$encodedProjectId/entities'),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        expect(data['entityTypes'], isA<List>());

        print('✅ Special characters in project ID test passed!');
      },
      tags: ['internet', 'integration'],
    );
  });
}
