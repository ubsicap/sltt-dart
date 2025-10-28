import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  SlttLogger.logger.info('Testing against: $baseUrl');
  const testProjectId = '_test_entity_states_simple';

  group('Entity States Endpoint Simple Tests', () {
    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state returns proper structure',
      () async {
        SlttLogger.logger.info(
          '🧪 Testing entity states endpoint structure...',
        );

        // Test with document entity type
        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/document/state',
          ),
        );

        SlttLogger.logger.fine('   Response status: ${response.statusCode}');
        SlttLogger.logger.fine('   Response body: ${response.body}');

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

        SlttLogger.logger.info(
          '✅ Entity states endpoint structure test passed!',
        );
        SlttLogger.logger.info(
          '   Items count: ${(data['items'] as List).length}',
        );
        SlttLogger.logger.info('   Has more: ${data['hasMore']}');
      },
    );

    test(
      'GET /api/projects/{projectId}/entities/{entityType}/state with limit parameter',
      () async {
        SlttLogger.logger.info(
          '🧪 Testing entity states endpoint with limit parameter...',
        );

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

        SlttLogger.logger.info('✅ Limit parameter test passed!');
        SlttLogger.logger.info('   Items returned: ${items.length}');
      },
    );

    test(
      'GET /api/projects/{projectId}/entities/invalid_type/state returns 400',
      () async {
        SlttLogger.logger.info(
          '🧪 Testing entity states endpoint with invalid entity type...',
        );

        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/entities/invalid_type/state',
          ),
        );

        expect(response.statusCode, equals(400));

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        expect(data.containsKey('error'), isTrue);

        SlttLogger.logger.info('✅ Invalid entity type test passed!');
        SlttLogger.logger.info('   Error message: ${data['error']}');
      },
    );

    test(
      'GET /api/projects/{projectId}/entities with different entity types',
      () async {
        SlttLogger.logger.info('🧪 Testing different entity types...');

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

          SlttLogger.logger.info(
            '   ✓ $entityType: ${(data['items'] as List).length} items',
          );
        }

        SlttLogger.logger.info('✅ Multiple entity types test passed!');
      },
    );
  });
}
