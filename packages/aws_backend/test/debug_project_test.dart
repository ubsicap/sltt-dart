import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  print('Testing against: $baseUrl');

  test('debug document without project', () async {
    // Try creating a document without creating project first
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final documentData = [
      {
        'projectId': '_debug_no_project_$timestamp',
        'entityType': 'document',
        'operation': 'create',
        'entityId': 'doc-test-$timestamp',
        'data': {'title': 'Test Document', 'content': 'Test content'},
      },
    ];

    print('Testing document without project: ${jsonEncode(documentData)}');

    final response = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(documentData),
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  });

  test('debug document with valid project', () async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final projectId = '_debug_with_project_$timestamp';

    // 1. Create project first
    final projectData = [
      {
        'projectId': projectId,
        'entityType': 'project',
        'operation': 'create',
        'entityId': projectId,
        'data': {'name': 'Test Project'},
      },
    ];

    print('Creating project: ${jsonEncode(projectData)}');
    final projectResponse = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(projectData),
    );

    print('Project creation status: ${projectResponse.statusCode}');
    print('Project creation body: ${projectResponse.body}');

    // 2. Now create document
    final documentData = [
      {
        'projectId': projectId,
        'entityType': 'document',
        'operation': 'create',
        'entityId': 'doc-test-$timestamp',
        'data': {'title': 'Test Document', 'content': 'Test content'},
      },
    ];

    print('Creating document: ${jsonEncode(documentData)}');
    final documentResponse = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(documentData),
    );

    print('Document creation status: ${documentResponse.statusCode}');
    print('Document creation body: ${documentResponse.body}');
  });
}
