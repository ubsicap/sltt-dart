import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  print('Testing against: $baseUrl');
  const testProjectId = '_test_cloud_api_project';

  test('create test project change', () async {
    final testProjectChange = [
      {
        'projectId': testProjectId,
        'entityType': 'project',
        'operation': 'create',
        'entityId': testProjectId,
        'data': {
          'name': '_test_cloud_api_integration_project',
          'description': 'Test project created by cloud API integration tests',
          'tags': ['test', 'integration', 'cloud-api'],
        },
      },
    ];

    final response = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(testProjectChange),
    );

    expect(response.statusCode, equals(200));

    final data = jsonDecode(response.body);
    expect(data['success'], isTrue);

    // The change might be created (if new) or detected as no-op (if already exists with same data)
    // Both scenarios are valid for this integration test
    final isNewCreation = data['created'] == 1;
    final isNoOpDetected = data['created'] == 0 && data['noOpCount'] == 1;

    expect(
      isNewCreation || isNoOpDetected,
      isTrue,
      reason:
          'Expected either new creation (created=1) or no-op detection (created=0, noOpCount=1), '
          'but got created=${data['created']}, noOpCount=${data['noOpCount']}',
    );

    print('✅ Project creation test passed!');
    print('   Success: ${data['success']}');
    if (isNewCreation) {
      print('   Result: Created new project (${data['created']} changes)');
      print('   Created sequences: ${data['createdSeqs']}');
    } else {
      print(
        '   Result: Detected as no-op change (project already exists with same data)',
      );
      print('   No-op changes: ${data['noOpCount']}');
    }
    print('   Timestamp: ${data['timestamp']}');
  }, tags: ['internet', 'integration', 'slow']);
}
