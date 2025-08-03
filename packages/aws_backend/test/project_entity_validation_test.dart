import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = kCloudDevUrl;
  const testProjectId = '_test_project_validation';

  group('Project Entity Validation Tests', () {
    test(
      'project entity with mismatched entityId should be rejected',
      () async {
        // Try to create a project entity where entityId != projectId
        final invalidProjectChange = [
          {
            'projectId': testProjectId,
            'entityType': 'project',
            'operation': 'create',
            'entityId': EntityType.generateEntityId(
              'project',
            ), // This should fail!
            'data': {
              'name': 'Test Project',
              'description': 'This should fail validation',
            },
          },
        ];

        final response = await http.post(
          Uri.parse('$baseUrl/api/changes'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(invalidProjectChange),
        );

        // Should return 400 Bad Request due to validation error
        expect(response.statusCode, equals(400));

        final data = jsonDecode(response.body);
        expect(data['error'], isA<String>());
        expect(
          data['error'],
          contains('Project entities must have entityId equal to projectId'),
        );

        print('✅ Project entity validation test passed!');
        print('   Status: ${response.statusCode}');
        print('   Error: ${data['error']}');
      },
    );

    test('project entity with matching entityId should be accepted', () async {
      // Create a valid project entity where entityId == projectId
      final validProjectChange = [
        {
          'projectId': testProjectId,
          'entityType': 'project',
          'operation': 'create',
          'entityId': testProjectId, // This should succeed!
          'data': {
            'name': 'Test Project',
            'description': 'This should pass validation',
          },
        },
      ];

      final response = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(validProjectChange),
      );

      // Should return 200 OK
      expect(response.statusCode, equals(200));

      final data = jsonDecode(response.body);
      expect(data['success'], equals(true));
      expect(data['created'], equals(1));

      print('✅ Valid project entity test passed!');
      print('   Status: ${response.statusCode}');
      print('   Created: ${data['created']} changes');
    });
  });
}
