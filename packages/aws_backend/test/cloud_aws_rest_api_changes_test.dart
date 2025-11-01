import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'helpers/test_utils.dart';

void main() {
  final baseUrl = Uri.parse(
    Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl,
  );

  setUpAll(() {
    // register DynamoChangeLogEntry factory for api models usage
    dynamoChangeLogEntryFactoryRegistration;
  });

  group('cloud - POST /api/changes', () {
    test('POST invalid JSON returns 400', () async {
      final resp = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        body: 'not-a-json',
        headers: {'Content-Type': 'application/json'},
      );
      expect(
        resp.statusCode,
        anyOf([400, 422]),
        reason: 'Should return 400 or 422 for invalid JSON, got ${resp.body}',
      );
    }, tags: ['internet', 'integration']);

    test(
      'POST minimal valid payload returns 200 or 201',
      () async {
        final projectData = BaseDataFields(
          parentId: 'parentId',
          parentProp: 'parentProp',
        );
        final projectId = '__test_project_post_minimal_valid_payload__';

        await resetTestProject(baseUrl, projectId);

        final resp = await saveProjectChange(
          baseUrl,
          projectId,
          projectData: projectData,
        );

        expect(resp.statusCode, anyOf([200, 201]), reason: 'Got ${resp.body}');
      },
      tags: ['internet', 'integration'],
      timeout: Timeout.none,
    );

    test(
      'POST and GET multiple changes',
      () async {
        final projectId = '__test_multiple_changes__';
        await resetTestProject(baseUrl, projectId);

        // Create multiple changes for the same project by varying rank and changeBy
        final numChanges = 3;
        for (int i = 1; i <= numChanges; i++) {
          final projectData = BaseDataFields(
            parentId: 'root',
            parentProp: 'projects',
            rank: 'rank$i',
          );
          final resp = await saveProjectChange(
            baseUrl,
            projectId,
            projectData: projectData,
            changeBy: 'user$i',
          );
          expect(resp.statusCode, anyOf([200, 201]));
        }

        // Get all changes for the project
        final getResp = await http.get(
          Uri.parse('$baseUrl/api/changes/projects/$projectId'),
          headers: {'Accept': 'application/json'},
        );
        expect(getResp.statusCode, equals(200));

        final body = jsonDecode(getResp.body) as Map<String, dynamic>;
        expect(body['changes'], isA<List>());
        final items = body['changes'] as List;

        // Should have at least numChanges changes for this project
        expect(items.length, greaterThanOrEqualTo(numChanges));

        // Verify each change matches expected rank and changeBy
        for (int i = 0; i < numChanges; i++) {
          final itemJson = items[i] as Map<String, dynamic>;
          final change = DynamoChangeLogEntry.fromJson(itemJson);

          final dataJson = jsonDecode(change.dataJson) as Map<String, dynamic>;
          final expectedSeq = i + 1;

          // First validate sequence number
          expect(
            change.seq,
            equals(expectedSeq),
            reason: 'Change at index $i should have seq $expectedSeq',
          );

          expect(
            change.changeBy,
            equals('user${i + 1}'),
            reason: 'Change at index $i should be by user${i + 1}',
          );
          expect(
            change.unknownJson,
            equals('{}'),
            reason: 'Change at index $i should have empty unknownJson',
          );

          // First change should have all fields (initial creation)
          if (i == 0) {
            final expectedDataKeys = {'parentId', 'parentProp', 'rank'};
            final actualDataKeys = dataJson.keys.toSet();
            expect(
              actualDataKeys,
              equals(expectedDataKeys),
              reason: 'First change should have parentId, parentProp, and rank',
            );
            expect(dataJson['parentId'], equals('root'));
            expect(dataJson['parentProp'], equals('projects'));
            expect(dataJson['rank'], equals('rank1'));
          } else {
            // Subsequent changes should only have the field that changed (rank)
            final expectedDataKeys = {'rank'};
            final actualDataKeys = dataJson.keys.toSet();
            expect(
              actualDataKeys,
              equals(expectedDataKeys),
              reason:
                  'Change at index $i should only contain rank (the changed field)',
            );
            expect(dataJson['rank'], equals('rank${i + 1}'));
          }
        }
      },
      tags: ['internet', 'integration'],
      timeout: Timeout.none,
    );

    test(
      'GET changes with limit parameter',
      () async {
        final projectId = '__test_changes_limit__';
        await resetTestProject(baseUrl, projectId);

        // Create 5 changes for the same project by varying rank and changeBy
        for (int i = 1; i <= 5; i++) {
          final projectData = BaseDataFields(
            parentId: 'root',
            parentProp: 'projects',
            rank: 'rank$i',
          );
          await saveProjectChange(
            baseUrl,
            projectId,
            projectData: projectData,
            changeBy: 'user$i',
          );
        }

        // Get changes with limit=3
        final getResp = await http.get(
          Uri.parse('$baseUrl/api/changes/projects/$projectId?limit=3'),
          headers: {'Accept': 'application/json'},
        );
        expect(getResp.statusCode, equals(200));

        final body = jsonDecode(getResp.body) as Map<String, dynamic>;
        expect(body['changes'], isA<List>());
        final items = body['changes'] as List;

        // Should return exactly 3 items (due to limit)
        expect(items.length, equals(3));

        // Response should contain pagination metadata
        expect(body.containsKey('hasMore'), isTrue);
        expect(body['hasMore'], isTrue);
        expect(body['cursor'], isNotNull);

        // Verify first 3 items match expected rank and changeBy
        for (int i = 0; i < 3; i++) {
          final itemJson = items[i] as Map<String, dynamic>;
          final change = DynamoChangeLogEntry.fromJson(itemJson);

          final dataJson = jsonDecode(change.dataJson) as Map<String, dynamic>;
          final expectedSeq = i + 1;

          // First validate sequence number
          expect(
            change.seq,
            equals(expectedSeq),
            reason: 'Item at index $i should have seq $expectedSeq',
          );

          expect(
            change.changeBy,
            equals('user${i + 1}'),
            reason: 'Item at index $i should be by user${i + 1}',
          );
          expect(
            change.unknownJson,
            equals('{}'),
            reason: 'Item at index $i should have empty unknownJson',
          );

          // First change should have all fields (initial creation)
          if (i == 0) {
            final expectedDataKeys = {'parentId', 'parentProp', 'rank'};
            final actualDataKeys = dataJson.keys.toSet();
            expect(
              actualDataKeys,
              equals(expectedDataKeys),
              reason: 'First change should have parentId, parentProp, and rank',
            );
            expect(dataJson['parentId'], equals('root'));
            expect(dataJson['parentProp'], equals('projects'));
            expect(dataJson['rank'], equals('rank1'));
          } else {
            // Subsequent changes should only have the field that changed (rank)
            final expectedDataKeys = {'rank'};
            final actualDataKeys = dataJson.keys.toSet();
            expect(
              actualDataKeys,
              equals(expectedDataKeys),
              reason:
                  'Item at index $i should only contain rank (the changed field)',
            );
            expect(dataJson['rank'], equals('rank${i + 1}'));
          }
        }
      },
      tags: ['internet', 'integration'],
      timeout: Timeout.none,
    );

    test(
      'GET changes with cursor parameter',
      () async {
        final projectId = '__test_changes_cursor__';
        await resetTestProject(baseUrl, projectId);

        // Create 6 changes for the same project to ensure we have enough for pagination
        for (int i = 1; i <= 6; i++) {
          final projectData = BaseDataFields(
            parentId: 'root',
            parentProp: 'projects',
            rank: 'rank$i',
          );
          await saveProjectChange(
            baseUrl,
            projectId,
            projectData: projectData,
            changeBy: 'user$i',
          );
        }

        // Get first page with limit=2
        final firstResp = await http.get(
          Uri.parse('$baseUrl/api/changes/projects/$projectId?limit=2'),
          headers: {'Accept': 'application/json'},
        );
        expect(firstResp.statusCode, equals(200));

        final firstBody = jsonDecode(firstResp.body) as Map<String, dynamic>;
        expect(firstBody['changes'], isA<List>());
        final firstItems = firstBody['changes'] as List;
        expect(firstItems.length, equals(2));
        expect(firstBody['hasMore'], isTrue);
        expect(firstBody['cursor'], isNotNull);

        // Verify first page items (should be items 1 and 2)
        for (int i = 0; i < 2; i++) {
          final itemJson = firstItems[i] as Map<String, dynamic>;
          final change = DynamoChangeLogEntry.fromJson(itemJson);

          final dataJson = jsonDecode(change.dataJson) as Map<String, dynamic>;
          final expectedSeq = i + 1;

          // First validate sequence number
          expect(
            change.seq,
            equals(expectedSeq),
            reason: 'First page item at index $i should have seq $expectedSeq',
          );

          expect(
            change.changeBy,
            equals('user${i + 1}'),
            reason: 'First page item at index $i should be by user${i + 1}',
          );
          expect(
            change.unknownJson,
            equals('{}'),
            reason: 'First page item at index $i should have empty unknownJson',
          );

          // First change should have all fields (initial creation)
          if (i == 0) {
            final expectedDataKeys = {'parentId', 'parentProp', 'rank'};
            final actualDataKeys = dataJson.keys.toSet();
            expect(
              actualDataKeys,
              equals(expectedDataKeys),
              reason: 'First change should have parentId, parentProp, and rank',
            );
            expect(dataJson['parentId'], equals('root'));
            expect(dataJson['parentProp'], equals('projects'));
            expect(dataJson['rank'], equals('rank1'));
          } else {
            // Subsequent changes should only have the field that changed (rank)
            final expectedDataKeys = {'rank'};
            final actualDataKeys = dataJson.keys.toSet();
            expect(
              actualDataKeys,
              equals(expectedDataKeys),
              reason: 'First page item at index $i should only contain rank',
            );
            expect(dataJson['rank'], equals('rank${i + 1}'));
          }
        }

        final cursor = firstBody['cursor'];

        // Get second page using cursor
        final secondResp = await http.get(
          Uri.parse(
            '$baseUrl/api/changes/projects/$projectId?cursor=$cursor&limit=2',
          ),
          headers: {'Accept': 'application/json'},
        );
        expect(secondResp.statusCode, equals(200));

        final secondBody = jsonDecode(secondResp.body) as Map<String, dynamic>;
        expect(secondBody['changes'], isA<List>());
        final secondItems = secondBody['changes'] as List;
        expect(secondItems.length, greaterThan(0));

        // Verify second page items (should start from item 3)
        for (int i = 0; i < secondItems.length; i++) {
          final itemJson = secondItems[i] as Map<String, dynamic>;
          final change = DynamoChangeLogEntry.fromJson(itemJson);

          final dataJson = jsonDecode(change.dataJson) as Map<String, dynamic>;
          final expectedUserNum = i + 3; // Third user onwards
          final expectedSeq = i + 3; // Third sequence number onwards

          // First validate sequence number
          expect(
            change.seq,
            equals(expectedSeq),
            reason: 'Second page item at index $i should have seq $expectedSeq',
          );

          expect(
            change.changeBy,
            equals('user$expectedUserNum'),
            reason:
                'Second page item at index $i should be by user$expectedUserNum',
          );
          expect(
            change.unknownJson,
            equals('{}'),
            reason:
                'Second page item at index $i should have empty unknownJson',
          );

          // All items on second page should only have rank (no initial creation)
          final expectedDataKeys = {'rank'};
          final actualDataKeys = dataJson.keys.toSet();
          expect(
            actualDataKeys,
            equals(expectedDataKeys),
            reason:
                'Second page item at index $i should only contain rank (the changed field)',
          );
          expect(dataJson['rank'], equals('rank$expectedUserNum'));
        }

        // Verify no overlap between pages
        final firstIds = firstItems
            .map((item) => (item as Map<String, dynamic>)['cid'] as String)
            .toSet();
        final secondIds = secondItems
            .map((item) => (item as Map<String, dynamic>)['cid'] as String)
            .toSet();
        expect(
          firstIds.intersection(secondIds).isEmpty,
          isTrue,
          reason: 'Pages should not have overlapping changes',
        );
      },
      tags: ['internet', 'integration'],
      timeout: Timeout.none,
    );

    test(
      'POST with client-provided seq value ignores it and assigns new seq',
      () async {
        final projectId = '__test_seq_always_bump__';
        await resetTestProject(baseUrl, projectId);

        // Create first change normally to establish seq=1
        final resp1 = await saveProjectChange(
          baseUrl,
          projectId,
          projectData: BaseDataFields(
            parentId: 'root',
            parentProp: 'projects',
            rank: 'rank1',
          ),
          changeBy: 'user1',
        );
        expect(resp1.statusCode, anyOf([200, 201]));

        // Create second change with explicit seq=999 in sync mode
        // The server should ignore this and assign seq=2 from its own counter
        final change2 = DynamoChangeLogEntry(
          storageId: 'test-storage-id',
          domainType: 'project',
          domainId: projectId,
          entityType: 'project',
          entityId: projectId,
          operation: 'update',
          stateChanged: true,
          changeBy: 'user2',
          changeAt: DateTime.now().toUtc(),
          cid: generateCid(entityType: EntityType.project, userId: 'user2'),
          dataJson: jsonEncode({'rank': 'rank2'}),
          seq: 999, // This should be ignored by the server
        );

        final request2 = CreateChangesRequest(
          changes: [change2],
          srcStorageType: 'cloud',
          srcStorageId: 'test',
          storageMode: 'sync', // Use sync mode (not save mode)
        );

        final resp2 = await http.post(
          Uri.parse('$baseUrl/api/changes'),
          body: jsonEncode(request2.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
        expect(
          resp2.statusCode,
          anyOf([200, 201]),
          reason: 'Got ${resp2.body}',
        );

        // Get all changes for the project
        final getResp = await http.get(
          Uri.parse('$baseUrl/api/changes/projects/$projectId'),
          headers: {'Accept': 'application/json'},
        );
        expect(getResp.statusCode, equals(200));

        final body = jsonDecode(getResp.body) as Map<String, dynamic>;
        expect(body['changes'], isA<List>());
        final items = body['changes'] as List;

        // Should have exactly 2 changes
        expect(items.length, equals(2));

        // Verify first change has seq=1
        final change1Json = items[0] as Map<String, dynamic>;
        final change1 = DynamoChangeLogEntry.fromJson(change1Json);
        expect(
          change1.seq,
          equals(1),
          reason:
              'First change should have seq=1 (assigned by server), got ${change1.seq}',
        );
        expect(change1.changeBy, equals('user1'));

        // Verify second change has seq=2 (not 999)
        final change2Json = items[1] as Map<String, dynamic>;
        final change2Result = DynamoChangeLogEntry.fromJson(change2Json);
        expect(
          change2Result.seq,
          equals(2),
          reason:
              'Second change should have seq=2 (assigned by server from its own counter, ignoring client-provided seq=999), got ${change2Result.seq}',
        );
        expect(change2Result.changeBy, equals('user2'));
      },
      tags: ['internet', 'integration'],
      timeout: Timeout.none,
    );
  });
}
