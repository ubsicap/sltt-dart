import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  print('Testing against: $baseUrl');
  const testProjectId = '_test_cloud_api_project';

  test('project statistics endpoint', () async {
    final encodedProjectId = Uri.encodeComponent(testProjectId);
    final response = await http.get(
      Uri.parse('$baseUrl/api/projects/$encodedProjectId/stats'),
    );

    print('✅ Statistics endpoint test:');
    print('   Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('   Response Keys: ${data.keys.toList()}');
      print('   Project ID: ${data['projectId']}');
      print('   Change Stats: ${data['changeStats']}');
      print('   Entity Type Stats: ${data['entityTypeStats']}');
      print('   Timestamp: ${data['timestamp']}');

      // Basic validations
      expect(data['projectId'], equals(testProjectId));
      expect(data['changeStats'], isA<Map>());
      expect(data['entityTypeStats'], isA<Map>());
      expect(data['timestamp'], isA<String>());
    } else {
      print('   Error: ${response.body}');
      fail('Statistics endpoint failed with status ${response.statusCode}');
    }
  }, tags: ['internet', 'integration']);
}
