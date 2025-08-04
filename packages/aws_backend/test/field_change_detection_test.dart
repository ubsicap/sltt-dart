import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = kCloudDevUrl;
  const testProjectId = '_test_field_change_detection_new';

  group('Field-Level Change Detection', () {
    test('detects no-op changes and returns proper result structure', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final entityId = 'doc-field-test-$timestamp';

      // 0. Create the test project first
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
      expect(projectResponse.statusCode, 200, reason: projectResponse.body);

      // 1. Create initial document
      final createCid = BaseChangeLogEntry.generateCid();
      final createResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([
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
        ]),
      );

      expect(createResponse.statusCode, 200, reason: createResponse.body);
      final createResult = jsonDecode(createResponse.body);
      expect(createResult['success'], isTrue);
      expect(createResult['created'], 1);
      expect(createResult['changeDetails'], isNotNull);

      // Verify create operation details
      final createDetails =
          createResult['changeDetails'][createCid] as Map<String, dynamic>;
      expect(createDetails['updatedFields'], hasLength(3));
      expect(createDetails['noOpFields'], isEmpty);
      expect(createDetails['totalFields'], 3);

      // Wait a moment to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 100));

      // 2. Send exact same data (no-op update)
      final noOpCid = BaseChangeLogEntry.generateCid();
      final noOpResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([
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
        ]),
      );

      expect(noOpResponse.statusCode, 200, reason: noOpResponse.body);
      final noOpResult = jsonDecode(noOpResponse.body);
      print('No-op result: ${jsonEncode(noOpResult)}');

      expect(noOpResult['success'], isTrue);
      expect(noOpResult['created'], 0);
      if (noOpResult.containsKey('noOpCount')) {
        expect(noOpResult['noOpCount'], 1);
      }
      if (noOpResult.containsKey('noOpChanges')) {
        expect(noOpResult['noOpChanges'], contains(noOpCid));
      }
      expect(noOpResult['changeDetails'], isNotNull);

      // Verify no-op change details
      final noOpDetails =
          noOpResult['changeDetails'][noOpCid] as Map<String, dynamic>;
      expect(noOpDetails['updatedFields'], isEmpty);
      expect(noOpDetails['noOpFields'], hasLength(3));
      expect(noOpDetails['totalFields'], 3);
      expect(
        noOpDetails['noOpFields'],
        containsAll(['title', 'content', 'priority']),
      );

      print('✅ No-op detection test passed!');
    });

    test('handles complex data types in field detection', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final entityId = 'complex-field-test-$timestamp';

      // 1. Create document with complex data
      final createCid = BaseChangeLogEntry.generateCid();
      final createResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([
          {
            'projectId': testProjectId,
            'entityType': 'document',
            'operation': 'create',
            'entityId': entityId,
            'cid': createCid,
            'data': {
              'title': 'Complex Document',
              'tags': ['tag1', 'tag2', 'tag3'],
              'metadata': {
                'author': 'John Doe',
                'version': 1,
                'settings': {'theme': 'dark', 'lang': 'en'},
              },
              'stats': [
                {'views': 100, 'likes': 5},
                {'views': 150, 'likes': 8},
              ],
            },
          },
        ]),
      );

      expect(createResponse.statusCode, 200, reason: createResponse.body);

      // Wait a moment for different timestamps
      await Future.delayed(const Duration(milliseconds: 100));

      // 2. Update with same complex data (should be no-op)
      final noOpCid = BaseChangeLogEntry.generateCid();
      final noOpResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([
          {
            'projectId': testProjectId,
            'entityType': 'document',
            'operation': 'update',
            'entityId': entityId,
            'cid': noOpCid,
            'data': {
              'tags': ['tag1', 'tag2', 'tag3'], // Same array
              'metadata': {
                'author': 'John Doe',
                'version': 1,
                'settings': {
                  'theme': 'dark',
                  'lang': 'en',
                }, // Same nested object
              },
            },
          },
        ]),
      );

      expect(noOpResponse.statusCode, 200, reason: noOpResponse.body);
      final noOpResult = jsonDecode(noOpResponse.body);

      expect(noOpResult['success'], isTrue);
      expect(noOpResult['created'], 0); // No changes created
      expect(noOpResult['noOpCount'], 1); // One no-op change detected

      final noOpDetails =
          noOpResult['changeDetails'][noOpCid] as Map<String, dynamic>;
      expect(noOpDetails['updatedFields'], isEmpty);
      expect(noOpDetails['noOpFields'], containsAll(['tags', 'metadata']));

      // 3. Update with slightly different complex data
      final updateCid = BaseChangeLogEntry.generateCid();
      final updateResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([
          {
            'projectId': testProjectId,
            'entityType': 'document',
            'operation': 'update',
            'entityId': entityId,
            'cid': updateCid,
            'data': {
              'tags': [
                'tag1',
                'tag2',
                'tag4',
              ], // Different array (tag3 -> tag4)
              'metadata': {
                'author': 'John Doe', // Same
                'version': 2, // Different
                'settings': {'theme': 'dark', 'lang': 'en'}, // Same nested
              },
            },
          },
        ]),
      );

      expect(updateResponse.statusCode, 200, reason: updateResponse.body);
      final updateResult = jsonDecode(updateResponse.body);

      expect(updateResult['success'], isTrue);
      expect(updateResult['created'], 1); // One change created

      final updateDetails =
          updateResult['changeDetails'][updateCid] as Map<String, dynamic>;
      expect(
        updateDetails['updatedFields'],
        containsAll(['tags', 'metadata']),
      ); // Both changed
      expect(updateDetails['noOpFields'], isEmpty);
    });

    test('handles null values and missing fields correctly', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final entityId = 'null-field-test-$timestamp';

      // 1. Create document with null and missing fields
      final createCid = BaseChangeLogEntry.generateCid();
      final createResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([
          {
            'projectId': testProjectId,
            'entityType': 'document',
            'operation': 'create',
            'entityId': entityId,
            'cid': createCid,
            'data': {
              'title': 'Null Test Document',
              'description': null,
              'tags': [],
            },
          },
        ]),
      );

      expect(createResponse.statusCode, 200, reason: createResponse.body);

      // Wait a moment
      await Future.delayed(const Duration(milliseconds: 100));

      // 2. Update with same null values (should be no-op)
      final noOpCid = BaseChangeLogEntry.generateCid();
      final noOpResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([
          {
            'projectId': testProjectId,
            'entityType': 'document',
            'operation': 'update',
            'entityId': entityId,
            'cid': noOpCid,
            'data': {
              'description': null, // Same null value
              'tags': [], // Same empty array
            },
          },
        ]),
      );

      expect(noOpResponse.statusCode, 200, reason: noOpResponse.body);
      final noOpResult = jsonDecode(noOpResponse.body);

      expect(noOpResult['success'], isTrue);
      expect(noOpResult['created'], 0);
      expect(noOpResult['noOpCount'], 1);

      final noOpDetails =
          noOpResult['changeDetails'][noOpCid] as Map<String, dynamic>;
      expect(noOpDetails['noOpFields'], containsAll(['description', 'tags']));

      // 3. Update null to actual value
      final updateCid = BaseChangeLogEntry.generateCid();
      final updateResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([
          {
            'projectId': testProjectId,
            'entityType': 'document',
            'operation': 'update',
            'entityId': entityId,
            'cid': updateCid,
            'data': {
              'description': 'Now has a description', // null -> string
              'tags': ['new-tag'], // empty -> non-empty array
            },
          },
        ]),
      );

      expect(updateResponse.statusCode, 200, reason: updateResponse.body);
      final updateResult = jsonDecode(updateResponse.body);

      expect(updateResult['success'], isTrue);
      expect(updateResult['created'], 1);

      final updateDetails =
          updateResult['changeDetails'][updateCid] as Map<String, dynamic>;
      expect(
        updateDetails['updatedFields'],
        containsAll(['description', 'tags']),
      );
      expect(updateDetails['noOpFields'], isEmpty);
    });

    test('batch operations handle mixed no-op and real changes', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final doc1Id = 'batch-doc1-$timestamp';
      final doc2Id = 'batch-doc2-$timestamp';

      // 1. Create two documents
      final createCid1 = BaseChangeLogEntry.generateCid();
      final createCid2 = BaseChangeLogEntry.generateCid();
      final createResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([
          {
            'projectId': testProjectId,
            'entityType': 'document',
            'operation': 'create',
            'entityId': doc1Id,
            'cid': createCid1,
            'data': {'title': 'Doc 1', 'status': 'draft'},
          },
          {
            'projectId': testProjectId,
            'entityType': 'document',
            'operation': 'create',
            'entityId': doc2Id,
            'cid': createCid2,
            'data': {'title': 'Doc 2', 'status': 'published'},
          },
        ]),
      );

      expect(createResponse.statusCode, 200);

      // Wait a moment
      await Future.delayed(const Duration(milliseconds: 100));

      // 2. Batch update: one no-op, one real change
      final batchCid1 = BaseChangeLogEntry.generateCid();
      final batchCid2 = BaseChangeLogEntry.generateCid();
      final batchResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([
          {
            'projectId': testProjectId,
            'entityType': 'document',
            'operation': 'update',
            'entityId': doc1Id,
            'cid': batchCid1,
            'data': {
              'title': 'Doc 1',
              'status': 'draft',
            }, // No-op (same values)
          },
          {
            'projectId': testProjectId,
            'entityType': 'document',
            'operation': 'update',
            'entityId': doc2Id,
            'cid': batchCid2,
            'data': {
              'title': 'Doc 2 Updated',
              'status': 'published',
            }, // Real change
          },
        ]),
      );

      expect(batchResponse.statusCode, 200, reason: batchResponse.body);
      final batchResult = jsonDecode(batchResponse.body);
      print('Batch result: ${jsonEncode(batchResult)}');

      expect(batchResult['success'], isTrue);
      expect(batchResult['created'], 1); // Only one real change
      expect(batchResult['noOpCount'], 1); // One no-op
      expect(batchResult['noOpChanges'], contains(batchCid1));
      expect(batchResult['changeDetails'], isNotNull);

      // Verify individual change details
      final doc1Details =
          batchResult['changeDetails'][batchCid1] as Map<String, dynamic>;
      expect(doc1Details['updatedFields'], isEmpty);
      expect(doc1Details['noOpFields'], hasLength(2));

      final doc2Details =
          batchResult['changeDetails'][batchCid2] as Map<String, dynamic>;
      expect(doc2Details['updatedFields'], contains('title'));
      expect(doc2Details['noOpFields'], contains('status'));
    });
  });
}
