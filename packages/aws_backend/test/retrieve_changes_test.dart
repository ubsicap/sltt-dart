import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  SlttLogger.logger.info('Testing against: $baseUrl');
  const testProjectId = '_test_cloud_api_project';

  test('retrieve changes for test project', () async {
    final encodedProjectId = Uri.encodeComponent(testProjectId);
    final response = await http.get(
      Uri.parse('$baseUrl/api/projects/$encodedProjectId/changes'),
    );

    expect(response.statusCode, equals(200));

    final data = jsonDecode(response.body);
    expect(data['changes'], isA<List>());
    expect(data['count'], isA<int>());
    expect(data['timestamp'], isA<String>());

    SlttLogger.logger.info('✅ Changes retrieval test passed!');
    SlttLogger.logger.info('   Found ${data['count']} changes');
    SlttLogger.logger.info('   Timestamp: ${data['timestamp']}');

    // Validate change structure
    if (data['changes'].isNotEmpty) {
      SlttLogger.logger.fine('\n📋 Change details:');
      for (int i = 0; i < data['changes'].length; i++) {
        final change = data['changes'][i];
        print('   Change ${i + 1}:');
        SlttLogger.logger.fine('   - Seq: ${change['seq']}');
        SlttLogger.logger.fine('     - Project ID: ${change['projectId']}');
        SlttLogger.logger.fine('     - Entity Type: ${change['entityType']}');
        SlttLogger.logger.fine('     - Operation: ${change['operation']}');
        SlttLogger.logger.fine('     - Entity ID: ${change['entityId']}');
        SlttLogger.logger.fine('     - Change At: ${change['changeAt']}');

        // Validate required fields
        expect(change['projectId'], equals(testProjectId));
        expect(change['entityType'], isA<String>());
        expect(change['operation'], isA<String>());
        expect(change['entityId'], isA<String>());
        expect(change['data'], isA<Map>());
        expect(change['seq'], isA<int>());
        expect(change['changeAt'], isA<String>());

        // Print the data content if it's a project
        if (change['entityType'] == 'project') {
          SlttLogger.logger.fine('     - Data: ${change['data']}');
        }
      }
    } else {
      SlttLogger.logger.info(
        '\n📋 No changes found for project $testProjectId',
      );
    }
  }, tags: ['internet', 'integration']);
}
