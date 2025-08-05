import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  print('Testing against: $baseUrl');
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

      // The change might be created (if new) or detected as no-op (if already exists with same data)
      // Both scenarios are valid and show that validation passed
      final isNewCreation = data['created'] == 1;
      final isNoOpDetected = data['created'] == 0 && data['noOpCount'] == 1;

      expect(
        isNewCreation || isNoOpDetected,
        isTrue,
        reason:
            'Expected either new creation (created=1) or no-op detection (created=0, noOpCount=1), '
            'but got created=${data['created']}, noOpCount=${data['noOpCount']}',
      );

      print('✅ Valid project entity test passed!');
      print('   Status: ${response.statusCode}');
      if (isNewCreation) {
        print('   Result: Created new project (${data['created']} changes)');
      } else {
        print(
          '   Result: Detected as no-op change (project already exists with same data)',
        );
      }
    });
  });
}
