import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  print('Testing against: $baseUrl');
  const testProjectId = '_test_complex_data_project';

  group('Data Validation Tests', () {
    test('create change with empty data object', () async {
      final changeWithEmptyData = [
        {
          'projectId': testProjectId,
          'entityType': 'document',
          'operation': 'delete',
          'entityId': 'temp-document-001',
          'cid': BaseChangeLogEntry.generateCid(),
          'data': {},
        },
      ];

      final response = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(changeWithEmptyData),
      );

      expect(response.statusCode, equals(200));

      final data = jsonDecode(response.body);
      expect(data['success'], isTrue);
      expect(data['created'], equals(1));

      print('✅ Empty data object accepted!');
      print('   Success: ${data['success']}');
      print('   Created: ${data['created']}');
      print('   Sequences: ${data['createdSeqs']}');
    }, tags: ['internet', 'integration']);

    test(
      'create change with complex nested data',
      () async {
        final complexChange = [
          {
            'projectId': testProjectId,
            'entityType': 'note',
            'operation': 'create',
            'entityId': 'note-complex-001',
            'data': {
              'settings': {
                'ui': {
                  'theme': 'dark',
                  'fontSize': 14,
                  'features': ['spellcheck', 'autocomplete'],
                },
                'performance': {'cacheSize': 100, 'enablePrefetch': true},
              },
              'metadata': {
                'version': '1.0.0',
                'created': DateTime.now().toIso8601String(),
                'tags': ['test', 'complex', 'nested'],
              },
              'arrayData': [
                {'id': 1, 'name': 'Item 1'},
                {'id': 2, 'name': 'Item 2'},
              ],
              'nullValue': null,
              'booleanValue': true,
              'numberValue': 42.5,
            },
          },
        ];

        final response = await http.post(
          Uri.parse('$baseUrl/api/changes'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(complexChange),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data['success'], isTrue);
        expect(data['created'], equals(1));

        print('✅ Complex nested data accepted!');
        print('   Success: ${data['success']}');
        print('   Created: ${data['created']}');
        print('   Sequences: ${data['createdSeqs']}');
      },
      tags: ['internet', 'integration', 'slow'],
    );

    test(
      'create multiple changes with different data types',
      () async {
        // Use unique entity IDs to ensure these are new creations
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final multipleChanges = [
          {
            'projectId': testProjectId,
            'entityType': 'document',
            'operation': 'create',
            'entityId': 'doc-string-data-$timestamp',
            'cid': BaseChangeLogEntry.generateCid(),
            'data': {
              'title': 'String Document',
              'content': 'Simple string content',
            },
          },
          {
            'projectId': testProjectId,
            'entityType': 'member',
            'operation': 'create',
            'entityId': 'user-with-numbers-$timestamp',
            'cid': BaseChangeLogEntry.generateCid(),
            'data': {
              'name': 'Test User',
              'age': 25,
              'height': 5.9,
              'isActive': true,
            },
          },
          {
            'projectId': testProjectId,
            'entityType': 'gloss',
            'operation': 'create',
            'entityId': 'list-with-arrays-$timestamp',
            'cid': BaseChangeLogEntry.generateCid(),
            'data': {
              'items': ['item1', 'item2', 'item3'],
              'numbers': [1, 2, 3, 4, 5],
              'mixed': ['string', 42, true, null],
            },
          },
        ];

        final response = await http.post(
          Uri.parse('$baseUrl/api/changes'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(multipleChanges),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data['success'], isTrue);
        expect(data['created'], equals(3));
        expect(data['createdSeqs'].length, equals(3));

        print('✅ Multiple changes with different data types accepted!');
        print('   Success: ${data['success']}');
        print('   Created: ${data['created']}');
        print('   Sequences: ${data['createdSeqs']}');
      },
      tags: ['internet', 'integration', 'slow'],
    );

    test('verify data integrity after retrieval', () async {
      final encodedProjectId = Uri.encodeComponent(testProjectId);
      final response = await http.get(
        Uri.parse('$baseUrl/api/projects/$encodedProjectId/changes'),
      );

      expect(response.statusCode, equals(200));

      final data = jsonDecode(response.body);
      expect(data['changes'], isA<List>());
  expect(data['count'], equals(5)); // We created 5 changes

      print('✅ Data integrity verification!');
      print('   Total changes retrieved: ${data['count']}');

      // Check that different data types are preserved
      final changes = data['changes'] as List;
      for (int i = 0; i < changes.length; i++) {
        final change = changes[i];
        print(
          '   Change ${i + 1}: ${change['entityType']} - ${change['operation']}',
        );

        // Verify required fields
        expect(change['seq'], isA<int>());
        expect(change['entityType'], isA<String>());
        expect(change['operation'], isA<String>());
        expect(change['entityId'], isA<String>());
        expect(change['data'], isA<Map>());
        expect(change['changeAt'], isA<String>());

        // Check if complex data is preserved (for the complex config change)
        if (change['entityType'] == 'configuration') {
          final configData = change['data'] as Map;
          expect(configData['settings'], isA<Map>());
          expect(configData['metadata'], isA<Map>());
          expect(configData['arrayData'], isA<List>());
          print('     ✓ Complex nested data preserved');
        }
      }
    }, tags: ['internet', 'integration']);
  });
}
