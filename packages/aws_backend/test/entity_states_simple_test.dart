import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = kCloudDevUrl;
  const testProjectId = '_test_entity_states_simple';

  group('Entity States Endpoint Simple Tests', () {
    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state returns proper structure',
      () async {
        print('🧪 Testing entity states endpoint structure...');

        // Test with document entity type
        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/document/state',
          ),
        );

        print('   Response status: ${response.statusCode}');
        print('   Response body: ${response.body}');

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());

        // Check that the response has the expected structure
        expect(
          data.containsKey('items'),
          isTrue,
          reason: 'Response should contain items field',
        );
        expect(
          data.containsKey('hasMore'),
          isTrue,
          reason: 'Response should contain hasMore field',
        );
        expect(
          data.containsKey('cursor'),
          isTrue,
          reason: 'Response should contain cursor field',
        );

        expect(data['items'], isA<List>(), reason: 'items should be a list');
        expect(
          data['hasMore'],
          isA<bool>(),
          reason: 'hasMore should be a boolean',
        );

        print('✅ Entity states endpoint structure test passed!');
        print('   Items count: ${(data['items'] as List).length}');
        print('   Has more: ${data['hasMore']}');
      },
    );

    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state with limit parameter',
      () async {
        print('🧪 Testing entity states endpoint with limit parameter...');

        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/document/state?limit=5',
          ),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        final items = data['items'] as List;

        // Should respect the limit (though may return fewer if not enough data)
        expect(items.length, lessThanOrEqualTo(5));

        print('✅ Limit parameter test passed!');
        print('   Items returned: ${items.length}');
      },
    );

    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state with metadata parameter',
      () async {
        print('🧪 Testing entity states endpoint with field_metadata=true...');

        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/document/state?field_metadata=true',
          ),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());

        print('✅ Metadata parameter test passed!');
        print('   Response structure valid for metadata request');
      },
    );

    test(
      'GET /api/projects/{projectId}/entities/invalid_type/state returns 400',
      () async {
        print('🧪 Testing entity states endpoint with invalid entity type...');

        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/invalid_type/state',
          ),
        );

        expect(response.statusCode, equals(400));

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        expect(data.containsKey('error'), isTrue);

        print('✅ Invalid entity type test passed!');
        print('   Error message: ${data['error']}');
      },
    );

    test(
      'GET /api/projects/{projectId}/entities with different entity types',
      () async {
        print('🧪 Testing different entity types...');

        final entityTypes = ['project', 'team', 'document', 'task'];

        for (final entityType in entityTypes) {
          final response = await http.get(
            Uri.parse(
              '$baseUrl/api/projects/$testProjectId/entities/$entityType/state',
            ),
          );

          expect(
            response.statusCode,
            equals(200),
            reason: 'Entity type $entityType should return 200',
          );

          final data = jsonDecode(response.body);
          expect(
            data['items'],
            isA<List>(),
            reason: 'Entity type $entityType should return items list',
          );

          print('   ✓ $entityType: ${(data['items'] as List).length} items');
        }

        print('✅ Multiple entity types test passed!');
      },
    );
  });
}
