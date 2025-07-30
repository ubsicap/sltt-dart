import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  const baseUrl = 'https://u1e8wbi87a.execute-api.us-east-1.amazonaws.com/dev';

  test('projects endpoint returns list of projects', () async {
    final response = await http.get(Uri.parse('$baseUrl/api/projects'));

    expect(response.statusCode, equals(200));

    final data = jsonDecode(response.body);
    expect(data['projects'], isA<List>());
    expect(data['count'], isA<int>());
    expect(data['timestamp'], isA<String>());

    print('✅ Projects endpoint test passed!');
    print('   Found ${data['count']} projects');
    print('   Timestamp: ${data['timestamp']}');

    if (data['projects'].isNotEmpty) {
      print('\n📋 Available projects:');
      for (final project in data['projects']) {
        print('   - $project');
      }
    } else {
      print('\n📋 No projects found in the database');
    }
  }, tags: ['internet', 'integration']);
}
