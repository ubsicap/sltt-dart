import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = kCloudDevUrl;

  test('debug CID differences', () async {
    const testProjectId = '_test_cid_debug';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final entityId = 'doc-field-test-$timestamp';

    // 1. Create project (this works)
    final projectCid = BaseChangeLogEntry.generateCid();
    print('Project CID: $projectCid');

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

    final projectResponse = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(projectData),
    );

    print('Project status: ${projectResponse.statusCode}');
    if (projectResponse.statusCode != 200) {
      print('Project ERROR: ${projectResponse.body}');
      return;
    }

    // 2. Create document (this works)
    final createCid = BaseChangeLogEntry.generateCid();
    print('Create CID: $createCid');

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

    final documentResponse = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(documentData),
    );

    print('Document status: ${documentResponse.statusCode}');
    if (documentResponse.statusCode != 200) {
      print('Document ERROR: ${documentResponse.body}');
      return;
    }

    // 3. Wait and try update without CID first (this might work)
    await Future.delayed(const Duration(milliseconds: 100));

    final noCidData = [
      {
        'projectId': testProjectId,
        'entityType': 'document',
        'operation': 'update',
        'entityId': entityId,
        // NO CID - let it auto-generate
        'data': {
          'title': 'Original Title',
          'content': 'Original content',
          'priority': 'high',
        },
      },
    ];

    print('Testing without CID...');
    final noCidResponse = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(noCidData),
    );

    print('No CID status: ${noCidResponse.statusCode}');
    print('No CID body: ${noCidResponse.body}');

    // 4. Now try with CID (this fails)
    final noOpCid = BaseChangeLogEntry.generateCid();
    print('No-op CID: $noOpCid');

    final withCidData = [
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

    print('Testing with CID...');
    final withCidResponse = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(withCidData),
    );

    print('With CID status: ${withCidResponse.statusCode}');
    print('With CID body: ${withCidResponse.body}');

    // 5. Let's also test a simple different value update
    final differentCid = BaseChangeLogEntry.generateCid();
    print('Different CID: $differentCid');

    final differentData = [
      {
        'projectId': testProjectId,
        'entityType': 'document',
        'operation': 'update',
        'entityId': entityId,
        'cid': differentCid,
        'data': {
          'title': 'Different Title', // Changed value
          'content': 'Original content',
          'priority': 'high',
        },
      },
    ];

    print('Testing different value...');
    final differentResponse = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(differentData),
    );

    print('Different value status: ${differentResponse.statusCode}');
    print('Different value body: ${differentResponse.body}');
  });
}
