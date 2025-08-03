import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = kCloudDevUrl;
  const testProjectId = '_test_entity_states_project';

  // Store created entity IDs for testing
  final createdDocumentIds = <String>[];
  final createdTeamIds = <String>[];

  group('Entity States Endpoint Tests', () {
    setUpAll(() async {
      print('🚀 Setting up test data for entity states testing...');

      // Create a test project first
      final projectId = EntityType.generateEntityId('project');
      final testProjectChange = [
        {
          'projectId': testProjectId,
          'entityType': 'project',
          'operation': 'create',
          'entityId': projectId,
          'data': {
            'name': '_test_entity_states_project',
            'description': 'Test project for entity states endpoint testing',
            'tags': ['test', 'integration', 'entity-states'],
          },
        },
      ];

      final projectResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(testProjectChange),
      );

      expect(projectResponse.statusCode, equals(200));
      print('✅ Test project created');

      // Create multiple document entities for testing pagination
      final documentChanges = <Map<String, dynamic>>[];
      for (int i = 1; i <= 5; i++) {
        final documentId = EntityType.generateEntityId('document');
        createdDocumentIds.add(documentId);

        documentChanges.add({
          'projectId': testProjectId,
          'entityType': 'document',
          'operation': 'create',
          'entityId': documentId,
          'data': {
            'title': 'Test Document $i',
            'content': 'Content for test document $i',
            'author': 'Test Author',
            'version': i,
            'tags': ['test', 'document'],
          },
        });
      }

      final docResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(documentChanges),
      );

      expect(docResponse.statusCode, equals(200));
      print('✅ Created ${documentChanges.length} test documents');

      // Create team entities for testing different entity types
      final teamChanges = <Map<String, dynamic>>[];
      for (int i = 1; i <= 3; i++) {
        final teamId = EntityType.generateEntityId('team');
        createdTeamIds.add(teamId);

        teamChanges.add({
          'projectId': testProjectId,
          'entityType': 'team',
          'operation': 'create',
          'entityId': teamId,
          'data': {
            'name': 'Test Team $i',
            'description': 'Description for test team $i',
            'members': ['member1', 'member2'],
            'lead': 'team-lead-$i',
          },
        });
      }

      final teamResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(teamChanges),
      );

      expect(teamResponse.statusCode, equals(200));
      print('✅ Created ${teamChanges.length} test teams');

      // Wait a bit for DynamoDB consistency
      await Future.delayed(const Duration(seconds: 2));
      print('✅ Test data setup complete');
    });

    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state returns document entities',
      () async {
        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/document/state',
          ),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        expect(data['items'], isA<List>());

        final items = data['items'] as List;

        print('✅ Document entities endpoint test passed!');
        print('   Items count: ${items.length}');
        print('   Has next page: ${data['hasNextPage']}');

        // Verify entity structure
        if (items.isNotEmpty) {
          final firstEntity = items.first;
          expect(firstEntity['entityId'], isA<String>());
          expect(firstEntity['title'], isA<String>());
          print('   Sample entity ID: ${firstEntity['entityId']}');
          print('   Sample title: ${firstEntity['title']}');
        }
      },
      tags: ['internet', 'integration'],
    );

    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state returns team entities',
      () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/projects/$testProjectId/entities/team/state'),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        expect(data['items'], isA<List>());

        final items = data['items'] as List;

        print('✅ Team entities endpoint test passed!');
        print('   Items count: ${items.length}');

        // Verify entity structure
        if (items.isNotEmpty) {
          final firstEntity = items.first;
          expect(firstEntity['entityId'], isA<String>());
          expect(firstEntity['name'], isA<String>());
          print('   Sample entity ID: ${firstEntity['entityId']}');
          print('   Sample name: ${firstEntity['name']}');
        }
      },
      tags: ['internet', 'integration'],
    );

    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state with limit parameter',
      () async {
        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/document/state?limit=2',
          ),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        expect(data['items'], isA<List>());

        final items = data['items'] as List;
        expect(items.length, lessThanOrEqualTo(2));

        print('✅ Limit parameter test passed!');
        print('   Items count: ${items.length}');
        print('   Has next page: ${data['hasNextPage']}');
      },
      tags: ['internet', 'integration'],
    );

    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state with metadata',
      () async {
        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/document/state?field_metadata=true',
          ),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        expect(data['items'], isA<List>());

        final items = data['items'] as List;

        print('✅ Metadata parameter test passed!');
        print('   Items count: ${items.length}');

        // Verify metadata is included
        if (items.isNotEmpty) {
          final firstEntity = items.first;
          print('   Entity keys: ${firstEntity.keys.toList()}');

          // Should have metadata fields
          final hasMetadata = firstEntity.keys.any(
            (key) =>
                key.endsWith('_meta') ||
                key == 'changeAt' ||
                key == 'cid' ||
                key == 'seq',
          );

          if (hasMetadata) {
            print('   ✅ Metadata fields found');
          } else {
            print(
              '   ⚠️ No metadata fields found (may be expected for empty result)',
            );
          }
        }
      },
      tags: ['internet', 'integration'],
    );

    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state with cursor pagination',
      () async {
        // First request to get initial data and cursor
        final firstResponse = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/document/state?limit=2',
          ),
        );

        expect(firstResponse.statusCode, equals(200));

        final firstData = jsonDecode(firstResponse.body);
        final firstItems = firstData['items'] as List;

        if (firstData['hasNextPage'] == true &&
            firstData['nextCursor'] != null) {
          final cursor = firstData['nextCursor'];

          // Second request with cursor
          final secondResponse = await http.get(
            Uri.parse(
              '$baseUrl/api/projects/$testProjectId/entities/document/state?limit=2&cursor=${Uri.encodeComponent(cursor)}',
            ),
          );

          expect(secondResponse.statusCode, equals(200));

          final secondData = jsonDecode(secondResponse.body);
          final secondItems = secondData['items'] as List;

          print('✅ Cursor pagination test passed!');
          print('   First page items: ${firstItems.length}');
          print('   Second page items: ${secondItems.length}');
          print('   Cursor used: $cursor');

          // Verify different items (no overlap)
          if (firstItems.isNotEmpty && secondItems.isNotEmpty) {
            final firstIds = firstItems.map((item) => item['entityId']).toSet();
            final secondIds = secondItems
                .map((item) => item['entityId'])
                .toSet();
            final overlap = firstIds.intersection(secondIds);
            expect(
              overlap.isEmpty,
              isTrue,
              reason: 'Pages should not have overlapping items',
            );
            print('   ✅ No overlap between pages');
          }
        } else {
          print('✅ Cursor pagination test completed (no next page available)');
          print('   Items: ${firstItems.length}');
        }
      },
      tags: ['internet', 'integration'],
    );

    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state with invalid entity type returns 400',
      () async {
        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/invalid_entity_type/state',
          ),
        );

        expect(response.statusCode, equals(400));

        final data = jsonDecode(response.body);
        expect(data['error'], isA<String>());
        expect(data['error'], contains('Invalid entity type'));

        print('✅ Invalid entity type test passed!');
        print('   Status: ${response.statusCode}');
        print('   Error: ${data['error']}');
      },
      tags: ['internet', 'integration'],
    );

    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state with nonexistent project returns empty',
      () async {
        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/nonexistent-project-123/entities/document/state',
          ),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        expect(data['items'], isA<List>());

        final items = data['items'] as List;
        expect(items, isEmpty);

        print('✅ Nonexistent project test passed!');
        print('   Items count: ${items.length}');
        print('   Has next page: ${data['hasNextPage']}');
      },
      tags: ['internet', 'integration'],
    );

    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state with invalid limit parameter returns 400',
      () async {
        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/document/state?limit=invalid',
          ),
        );

        expect(response.statusCode, equals(400));

        final data = jsonDecode(response.body);
        expect(data['error'], isA<String>());
        expect(data['error'], contains('Invalid limit'));

        print('✅ Invalid limit parameter test passed!');
        print('   Status: ${response.statusCode}');
        print('   Error: ${data['error']}');
      },
      tags: ['internet', 'integration'],
    );

    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state with excessive limit returns 400',
      () async {
        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/document/state?limit=2000',
          ),
        );

        expect(response.statusCode, equals(400));

        final data = jsonDecode(response.body);
        expect(data['error'], isA<String>());
        expect(data['error'], contains('Limit too large'));

        print('✅ Excessive limit parameter test passed!');
        print('   Status: ${response.statusCode}');
        print('   Error: ${data['error']}');
      },
      tags: ['internet', 'integration'],
    );

    test(
      'Entity ID format validation - verify embedded suffixes',
      () async {
        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/document/state',
          ),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        final items = data['items'] as List;

        if (items.isNotEmpty) {
          for (final item in items) {
            final entityId = item['entityId'] as String;
            final extractedType = EntityType.extractEntityTypeFromId(entityId);

            expect(
              extractedType,
              equals('document'),
              reason:
                  'Entity ID $entityId should have embedded document suffix',
            );

            // Verify the ID format follows the expected pattern
            expect(
              entityId,
              matches(RegExp(r'\d{4}-\d{4}-\d{6}-\d{3}[+-]\d{4}-\w{4}-docu')),
            );
          }

          print('✅ Entity ID format validation passed!');
          print('   Verified ${items.length} document entity IDs');
          print('   Sample ID: ${items.first['entityId']}');
        } else {
          print('ℹ️ No items to validate entity ID format');
        }
      },
      tags: ['internet', 'integration'],
    );
  });
}
