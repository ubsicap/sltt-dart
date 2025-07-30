import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  const baseUrl = 'https://u1e8wbi87a.execute-api.us-east-1.amazonaws.com/dev';
  const testProjectId = '_test_cloud_api_project';

  test('project statistics endpoint', () async {
    final encodedProjectId = Uri.encodeComponent(testProjectId);
    final response = await http.get(
      Uri.parse('$baseUrl/api/projects/$encodedProjectId/stats'),
    );

    expect(response.statusCode, equals(200));

    final data = jsonDecode(response.body);
    expect(data['projectId'], equals(testProjectId));
    expect(data['changeStats'], isA<Map>());
    expect(data['entityTypeStats'], isA<Map>());
    expect(data['timestamp'], isA<String>());

    print('✅ Project statistics test passed!');
    print('   Project ID: ${data['projectId']}');
    print('   Change Stats: ${data['changeStats']}');
    print('   Entity Type Stats: ${data['entityTypeStats']}');
    print('   Timestamp: ${data['timestamp']}');

    // Print detailed stats if available
    if (data['changeStats'] is Map && data['changeStats'].isNotEmpty) {
      print('\n📊 Change Statistics:');
      final changeStats = data['changeStats'] as Map;
      changeStats.forEach((key, value) {
        print('   - $key: $value');
      });
    }

    if (data['entityTypeStats'] is Map && data['entityTypeStats'].isNotEmpty) {
      print('\n📊 Entity Type Statistics:');
      final entityStats = data['entityTypeStats'] as Map;
      entityStats.forEach((key, value) {
        print('   - $key: $value');
      });
    }
  }, tags: ['internet', 'integration']);
}
