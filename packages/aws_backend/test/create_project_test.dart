import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  const baseUrl = 'https://u1e8wbi87a.execute-api.us-east-1.amazonaws.com/dev';
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
    expect(data['created'], equals(1));
    expect(data['createdSeqs'], isA<List>());
    expect(data['createdSeqs'].length, equals(1));

    print('✅ Project creation test passed!');
    print('   Success: ${data['success']}');
    print('   Created: ${data['created']} changes');
    print('   Created sequences: ${data['createdSeqs']}');
    print('   Project ID: ${data['projectId'] ?? 'Not returned'}');
    print('   Timestamp: ${data['timestamp']}');
  }, tags: ['internet', 'integration', 'slow']);
}
