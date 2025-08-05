import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  print('Testing against: $baseUrl');
  const testProjectId = '_test_cloud_api_project';

  group('Pagination Tests', () {
    test(
      'changes endpoint supports cursor pagination',
      () async {
        final response = await http.get(
          Uri.parse(
            '$baseUrl/api/projects/$testProjectId/changes?cursor=0&limit=2',
          ),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data['changes'], isA<List>());
        expect(data['count'], isA<int>());
        expect(data['timestamp'], isA<String>());

        print('✅ Pagination test passed!');
        print('   Status: ${response.statusCode}');
        print('   Changes count: ${data['count']}');
        print('   Actual changes returned: ${data['changes'].length}');
        print('   Timestamp: ${data['timestamp']}');

        // If there are changes, check that limit is respected
        if (data['count'] > 0) {
          expect(data['changes'].length, lessThanOrEqualTo(2));
          print('   ✅ Limit parameter respected');
        }
      },
      tags: ['internet', 'integration'],
    );

    test('pagination with different limit values', () async {
      // Test with limit = 1
      final response1 = await http.get(
        Uri.parse('$baseUrl/api/projects/$testProjectId/changes?limit=1'),
      );

      expect(response1.statusCode, equals(200));
      final data1 = jsonDecode(response1.body);

      print('✅ Pagination with limit=1 works!');
      print('   Changes returned: ${data1['changes'].length}');
      print('   Total count: ${data1['count']}');

      if (data1['count'] > 0) {
        expect(data1['changes'].length, lessThanOrEqualTo(1));
      }

      // Test with no limit (default)
      final response2 = await http.get(
        Uri.parse('$baseUrl/api/projects/$testProjectId/changes'),
      );

      expect(response2.statusCode, equals(200));
      final data2 = jsonDecode(response2.body);

      print('✅ Pagination without limit works!');
      print('   Changes returned: ${data2['changes'].length}');
      print('   Total count: ${data2['count']}');
    }, tags: ['internet', 'integration']);

    test('invalid limit parameter handling', () async {
      // Test with invalid limit
      final response = await http.get(
        Uri.parse('$baseUrl/api/projects/$testProjectId/changes?limit=invalid'),
      );

      expect(response.statusCode, equals(400));

      final error = jsonDecode(response.body);
      expect(error['error'], isA<String>());
      expect(error['error'], contains('limit'));

      print('✅ Invalid limit error handling works!');
      print('   Status: ${response.statusCode}');
      print('   Error: ${error['error']}');
    }, tags: ['internet', 'integration']);

    test('excessive limit parameter handling', () async {
      // Test with limit > 1000
      final response = await http.get(
        Uri.parse('$baseUrl/api/projects/$testProjectId/changes?limit=1500'),
      );

      expect(response.statusCode, equals(400));

      final error = jsonDecode(response.body);
      expect(error['error'], isA<String>());
      expect(error['error'], contains('too large'));

      print('✅ Excessive limit error handling works!');
      print('   Status: ${response.statusCode}');
      print('   Error: ${error['error']}');
    }, tags: ['internet', 'integration']);
  });
}
