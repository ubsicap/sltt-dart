import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = kCloudDevUrl;
  const testProjectId = '_test_cloud_api_project';

  test('get specific change by sequence number', () async {
    // First get all changes to find a valid sequence number
    final encodedProjectId = Uri.encodeComponent(testProjectId);
    final changesResponse = await http.get(
      Uri.parse('$baseUrl/api/projects/$encodedProjectId/changes'),
    );

    expect(changesResponse.statusCode, equals(200));

    final changesData = jsonDecode(changesResponse.body);

    if (changesData['changes'].isEmpty) {
      print('⚠️  No changes found - skipping specific change test');
      return;
    }

    // Test getting the first change by sequence number
    final firstChange = changesData['changes'][0];
    final seq = firstChange['seq'];

    final specificChangeResponse = await http.get(
      Uri.parse('$baseUrl/api/projects/$encodedProjectId/changes/$seq'),
    );

    expect(specificChangeResponse.statusCode, equals(200));

    final specificChange = jsonDecode(specificChangeResponse.body);

    print('✅ Specific change retrieval test passed!');
    print('   Requested seq: $seq');
    print('   Retrieved seq: ${specificChange['seq']}');
    print('   Entity Type: ${specificChange['entityType']}');
    print('   Operation: ${specificChange['operation']}');
    print('   Entity ID: ${specificChange['entityId']}');

    // Validate the specific change matches what we expect
    expect(specificChange['seq'], equals(seq));
    expect(specificChange['projectId'], equals(testProjectId));
    expect(specificChange['entityType'], isA<String>());
    expect(specificChange['operation'], isA<String>());
    expect(specificChange['entityId'], isA<String>());
    expect(specificChange['data'], isA<Map>());
    expect(specificChange['changeAt'], isA<String>());
  }, tags: ['internet', 'integration']);
}
