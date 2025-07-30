import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  const baseUrl = 'https://u1e8wbi87a.execute-api.us-east-1.amazonaws.com/dev';

  test('api help endpoint returns documentation', () async {
    final response = await http.get(Uri.parse('$baseUrl/api/help'));

    expect(response.statusCode, equals(200));

    final data = jsonDecode(response.body);
    expect(data['server'], isNotNull);
    expect(data['endpoints'], isA<List>());
    expect(data['endpoints'].length, greaterThan(5));
    expect(data['timestamp'], isA<String>());

    // Check for key endpoints
    final endpointPaths = data['endpoints'].map((e) => e['path']).toList();
    expect(endpointPaths, contains('/health'));
    expect(endpointPaths, contains('/api/projects'));
    expect(endpointPaths, contains('/api/projects/{projectId}/changes'));

    print('✅ API Help endpoint test passed!');
    print('   Server: ${data['server']['name']}');
    print('   Storage Type: ${data['server']['storageType']}');
    print('   Available endpoints: ${endpointPaths.length}');

    // Print all available endpoints
    print('\n📋 Available endpoints:');
    for (final endpoint in data['endpoints']) {
      print(
        '   ${endpoint['method']} ${endpoint['path']} - ${endpoint['description']}',
      );
    }
  }, tags: ['internet', 'integration']);
}
