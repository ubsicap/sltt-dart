import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = kCloudDevUrl;
  const testProjectId = '_test_cloud_api_project';

  test('debug changes retrieval', () async {
    final encodedProjectId = Uri.encodeComponent(testProjectId);
    final response = await http.get(
      Uri.parse('$baseUrl/api/projects/$encodedProjectId/changes'),
    );

    expect(response.statusCode, equals(200));

    final data = jsonDecode(response.body);

    print('✅ Debug changes retrieval:');
    print('   Status Code: ${response.statusCode}');
    print('   Response Count: ${data['count']}');
    print('   Response Keys: ${data.keys.toList()}');

    if (data['changes'].isNotEmpty) {
      final change = data['changes'][0];
      print('\n📋 First change full structure:');
      print('   Raw change: $change');
      print('   Change keys: ${change.keys.toList()}');

      // Check each field individually
      print('\n🔍 Field analysis:');
      print(
        '   - seq type: ${change['seq'].runtimeType} value: ${change['seq']}',
      );
      print(
        '   - projectId type: ${change['projectId'].runtimeType} value: ${change['projectId']}',
      );
      print(
        '   - entityType type: ${change['entityType'].runtimeType} value: ${change['entityType']}',
      );
      print(
        '   - operation type: ${change['operation'].runtimeType} value: ${change['operation']}',
      );
      print(
        '   - entityId type: ${change['entityId'].runtimeType} value: ${change['entityId']}',
      );
      print(
        '   - changeAt type: ${change['changeAt'].runtimeType} value: ${change['changeAt']}',
      );
      print(
        '   - data type: ${change['data'].runtimeType} value: ${change['data']}',
      );
    }

    // Test passes regardless to see debug info
    expect(data['changes'], isA<List>());
  }, tags: ['internet', 'integration']);
}
