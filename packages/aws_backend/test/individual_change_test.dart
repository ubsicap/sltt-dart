import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  print('Testing against: $baseUrl');
  const testProjectId = '_test_cloud_api_project';

  group('Individual Change Retrieval Tests', () {
    test('get specific change by sequence number', () async {
      final encodedProjectId = Uri.encodeComponent(testProjectId);
      final response = await http.get(
        Uri.parse('$baseUrl/api/projects/$encodedProjectId/changes/1'),
      );

      expect(response.statusCode, equals(200));

      final change = jsonDecode(response.body);
      expect(change['seq'], equals(1));
      expect(change['entityType'], isA<String>());
      expect(change['operation'], isA<String>());
      expect(change['entityId'], isA<String>());
      expect(change['data'], isA<Map>());
      expect(change['changeAt'], isA<String>());

      print('✅ Individual change retrieval works!');
      print('   Seq: ${change['seq']}');
      print(
        '   Project ID: ${change['projectId']}',
      ); // This should show if our fix worked
      print('   Entity Type: ${change['entityType']}');
      print('   Operation: ${change['operation']}');
      print('   Entity ID: ${change['entityId']}');
      print('   Change At: ${change['changeAt']}');
      print('   Data: ${change['data']}');
    }, tags: ['internet', 'integration']);

    test('get non-existent change returns 404', () async {
      final encodedProjectId = Uri.encodeComponent(testProjectId);
      final response = await http.get(
        Uri.parse('$baseUrl/api/projects/$encodedProjectId/changes/999'),
      );

      expect(response.statusCode, equals(404));

      final error = jsonDecode(response.body);
      expect(error['error'], isA<String>());
      expect(error['error'], contains('not found'));

      print('✅ Non-existent change handling works!');
      print('   Status: ${response.statusCode}');
      print('   Error: ${error['error']}');
    }, tags: ['internet', 'integration']);

    test('invalid sequence number returns 400', () async {
      final encodedProjectId = Uri.encodeComponent(testProjectId);
      final response = await http.get(
        Uri.parse('$baseUrl/api/projects/$encodedProjectId/changes/invalid'),
      );

      expect(response.statusCode, equals(400));

      final error = jsonDecode(response.body);
      expect(error['error'], isA<String>());
      expect(error['error'], contains('seq'));

      print('✅ Invalid sequence number handling works!');
      print('   Status: ${response.statusCode}');
      print('   Error: ${error['error']}');
    }, tags: ['internet', 'integration']);

    test(
      'change retrieval for non-existent project returns 404',
      () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/projects/non-existent-project/changes/1'),
        );

        expect(response.statusCode, equals(404));

        final error = jsonDecode(response.body);
        expect(error['error'], isA<String>());

        print('✅ Non-existent project change retrieval handling works!');
        print('   Status: ${response.statusCode}');
        print('   Error: ${error['error']}');
      },
      tags: ['internet', 'integration'],
    );
  });
}
