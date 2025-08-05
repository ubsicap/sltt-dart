import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  print('Testing against: $baseUrl');
  const testProjectId = '_test_field_debug';

  test('debug field change detection', () async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 1. First create a project entity to ensure the project exists
    final projectCid = BaseChangeLogEntry.generateCid();
    final projectResponse = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode([
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
      ]),
    );

    print('Project creation response: ${projectResponse.statusCode}');
    print('Project creation body: ${projectResponse.body}');
    expect(projectResponse.statusCode, 200, reason: projectResponse.body);

    // 2. Now create a document
    final docCid = BaseChangeLogEntry.generateCid();
    final docResponse = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode([
        {
          'projectId': testProjectId,
          'entityType': 'document',
          'operation': 'create',
          'entityId': 'doc-$timestamp',
          'cid': docCid,
          'data': {'title': 'Test Document', 'content': 'Test content'},
        },
      ]),
    );

    print('Document creation response: ${docResponse.statusCode}');
    print('Document creation body: ${docResponse.body}');
    expect(docResponse.statusCode, 200, reason: docResponse.body);

    final docResult = jsonDecode(docResponse.body);
    expect(docResult['success'], isTrue);
    expect(docResult['changeDetails'], isNotNull);

    print('✅ Debug test passed!');
  });
}
