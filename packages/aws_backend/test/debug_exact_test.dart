import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  print('Testing against: $baseUrl');

  test('debug exact field change test data', () async {
    const testProjectId = '_test_field_change_detection_exact';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final entityId = 'doc-field-test-$timestamp';

    // Use EXACT same structure as field change detection test

    // 1. Create project
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

    print('Project status: ${projectResponse.statusCode}');
    print('Project body: ${projectResponse.body}');

    if (projectResponse.statusCode != 200) {
      print('ERROR: Project creation failed!');
      return;
    }

    // 2. Create document with EXACT same structure
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
    final documentResponse = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(documentData),
    );

    print('Document status: ${documentResponse.statusCode}');
    print('Document body: ${documentResponse.body}');

    if (documentResponse.statusCode != 200) {
      print('ERROR: Document creation failed!');
      return;
    }

    // 3. Try no-op update with EXACT same structure
    await Future.delayed(const Duration(milliseconds: 100));

    final noOpCid = BaseChangeLogEntry.generateCid();
    final noOpData = [
      {
        'projectId': testProjectId,
        'entityType': 'document',
        'operation': 'update',
        'entityId': entityId,
        'cid': noOpCid,
        'data': {
          'title': 'Original Title',
          'content': 'Original content',
          'priority': 'high',
        },
      },
    ];

    print('No-op data: ${jsonEncode(noOpData)}');
    final noOpResponse = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(noOpData),
    );

    print('No-op status: ${noOpResponse.statusCode}');
    print('No-op body: ${noOpResponse.body}');

    if (noOpResponse.statusCode == 200) {
      print('✅ All exact replica tests passed!');
    } else {
      print('❌ No-op update failed!');
    }
  });
}
