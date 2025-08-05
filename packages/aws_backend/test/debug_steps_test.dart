import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  print('Testing against: $baseUrl');
  const testProjectId = '_test_field_debug2';

  test('debug individual steps', () async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final entityId = 'doc-field-test-$timestamp';

    // Step 1: Create project
    print('Step 1: Creating project...');
    final projectCid = BaseChangeLogEntry.generateCid();
    final projectData = [
      {
        'projectId': testProjectId,
        'entityType': 'project',
        'operation': 'create',
        'entityId': testProjectId,
        'cid': projectCid,
        'data': {
          'name': 'Field Detection Test Project',
          'description': 'Test project for field-level change detection',
        },
      },
    ];

    print('Project data: ${jsonEncode(projectData)}');

    final projectResponse = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(projectData),
    );

    print('Project response status: ${projectResponse.statusCode}');
    print('Project response body: ${projectResponse.body}');
    expect(projectResponse.statusCode, 200, reason: projectResponse.body);

    // Step 2: Create document
    print('\\nStep 2: Creating document...');
    final createCid = BaseChangeLogEntry.generateCid();
    final documentData = [
      {
        'projectId': testProjectId,
        'entityType': 'document',
        'operation': 'create',
        'entityId': entityId,
        'cid': createCid,
        'data': {
          'title': 'Original Title',
          'content': 'Original content',
          'priority': 'high',
        },
      },
    ];

    print('Document data: ${jsonEncode(documentData)}');

    final createResponse = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(documentData),
    );

    print('Document response status: ${createResponse.statusCode}');
    print('Document response body: ${createResponse.body}');

    if (createResponse.statusCode != 200) {
      print('ERROR: Document creation failed!');
      fail(
        'Document creation failed with ${createResponse.statusCode}: ${createResponse.body}',
      );
    }

    print('✅ Both steps succeeded!');
  });
}
