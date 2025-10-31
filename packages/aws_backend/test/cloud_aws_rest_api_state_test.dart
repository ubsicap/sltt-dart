import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:aws_backend/src/models/portion_translation.data.dart';
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

  group('AWS REST /api/state integration', () {
    test(
      'POST api/changes > GET /api/state/projects/<project_id>/projects',
      () async {
        final projectId = '__test_post_changes_get_state__';
        await resetTestProject(baseUrl, projectId);

        final projectData = BaseDataFields(
          parentId: 'parentId',
          parentProp: 'parentProp',
        );

        await saveProjectChange(baseUrl, projectId, projectData: projectData);

        final resp = await http.get(
          Uri.parse('$baseUrl/api/state/projects/$projectId/projects'),
          headers: {'Accept': 'application/json'},
        );
        expect(resp.statusCode, anyOf([200, 404]));

        if (resp.statusCode == 200) {
          final body = jsonDecode(resp.body) as Map<String, dynamic>;
          expect(body['items'], isA<List>());
          final items = body['items'] as List;

          // Should return exactly 1 project entity
          expect(items.length, equals(1));
          expect(body.containsKey('hasMore'), isTrue);
          expect(body['hasMore'], isFalse);
        }
      },
      tags: ['internet', 'integration'],
    );

    test(
      'GET /api/state with limit parameter',
      () async {
        final projectId = '__test_state_limit__';
        await resetTestProject(baseUrl, projectId);

        // Create 5 different portion entities within the same project
        for (int i = 1; i <= 5; i++) {
          final portionData = PortionTranslationData(
            name: 'Portion $i',
            visibility: 'public',
            parentId: 'root',
            parentProp: 'portions',
            rank: 'rank$i',
          );
          await saveChange<PortionTranslationData>(
            baseUrl,
            domainType: 'project',
            domainId: projectId,
            entityType: 'portion',
            entityId: 'portion_$i',
            data: portionData,
            changeBy: 'user$i',
          );
        }

        // Get states with limit=3
        final resp = await http.get(
          Uri.parse('$baseUrl/api/state/projects/$projectId/portions?limit=3'),
          headers: {'Accept': 'application/json'},
        );
        expect(resp.statusCode, equals(200));

        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        expect(body['items'], isA<List>());
        final items = body['items'] as List;

        // Should return exactly 3 items (due to limit)
        expect(items.length, equals(3));

        // Response should contain pagination metadata
        expect(body.containsKey('hasMore'), isTrue);
        expect(body['hasMore'], isTrue);
        expect(body.containsKey('cursor'), isTrue);
        expect(body['cursor'], isNotNull);

        // Verify each state has expected structure
        for (int i = 0; i < 3; i++) {
          final stateJson = items[i] as Map<String, dynamic>;

          // State items have flattened structure with entity-specific fields
          expect(stateJson.containsKey('entityId'), isTrue);
          expect(stateJson.containsKey('entityType'), isTrue);
          expect(stateJson['entityType'], equals('portion'));
          expect(stateJson.containsKey('domainType'), isTrue);

          // Portion-specific data fields (flattened)
          expect(stateJson.containsKey('data_name'), isTrue);
          expect(stateJson.containsKey('data_visibility'), isTrue);
          expect(stateJson.containsKey('data_parentId'), isTrue);
          expect(stateJson.containsKey('data_parentProp'), isTrue);

          // Verify no DynamoDB storage keys are present
          expect(stateJson.containsKey('pk'), isFalse);
          expect(stateJson.containsKey('sk'), isFalse);
          expect(stateJson.containsKey('gsi1pk'), isFalse);
          expect(stateJson.containsKey('gsi1sk'), isFalse);
        }
      },
      tags: ['internet', 'integration'],
      timeout: Timeout.none,
    );

    test(
      'GET /api/state with cursor parameter',
      () async {
        final projectId = '__test_state_cursor__';
        await resetTestProject(baseUrl, projectId);

        // Create 6 different portion entities within the same project for pagination
        for (int i = 1; i <= 6; i++) {
          final portionData = PortionTranslationData(
            name: 'Portion $i',
            visibility: 'public',
            parentId: 'root',
            parentProp: 'portions',
            rank: 'rank$i',
          );
          await saveChange<PortionTranslationData>(
            baseUrl,
            domainType: 'project',
            domainId: projectId,
            entityType: 'portion',
            entityId: 'portion_$i',
            data: portionData,
            changeBy: 'user$i',
          );
        }

        // Get first page with limit=2
        final firstResp = await http.get(
          Uri.parse('$baseUrl/api/state/projects/$projectId/portions?limit=2'),
          headers: {'Accept': 'application/json'},
        );
        expect(firstResp.statusCode, equals(200));

        final firstBody = jsonDecode(firstResp.body) as Map<String, dynamic>;
        expect(firstBody['items'], isA<List>());
        final firstItems = firstBody['items'] as List;
        expect(firstItems.length, equals(2));
        expect(firstBody['hasMore'], isTrue);
        expect(firstBody['cursor'], isNotNull);

        // Verify first page items have correct structure
        for (int i = 0; i < 2; i++) {
          final stateJson = firstItems[i] as Map<String, dynamic>;
          expect(stateJson.containsKey('entityId'), isTrue);
          expect(stateJson.containsKey('entityType'), isTrue);
          expect(stateJson['entityType'], equals('portion'));

          // Portion-specific data fields
          expect(stateJson.containsKey('data_name'), isTrue);
          expect(stateJson.containsKey('data_visibility'), isTrue);

          // Verify no DynamoDB storage keys are present
          expect(stateJson.containsKey('pk'), isFalse);
          expect(stateJson.containsKey('sk'), isFalse);
          expect(stateJson.containsKey('gsi1pk'), isFalse);
          expect(stateJson.containsKey('gsi1sk'), isFalse);
        }

        final cursor = firstBody['cursor'];

        // URL encode the cursor to handle special characters like $ and #
        final encodedCursor = Uri.encodeComponent(cursor as String);

        // Get second page using cursor
        final secondResp = await http.get(
          Uri.parse(
            '$baseUrl/api/state/projects/$projectId/portions?cursor=$encodedCursor&limit=2',
          ),
          headers: {'Accept': 'application/json'},
        );
        expect(secondResp.statusCode, equals(200));

        final secondBody = jsonDecode(secondResp.body) as Map<String, dynamic>;
        expect(secondBody['items'], isA<List>());
        final secondItems = secondBody['items'] as List;

        expect(secondItems.length, greaterThan(0));

        // Verify second page items have correct structure
        for (int i = 0; i < secondItems.length; i++) {
          final stateJson = secondItems[i] as Map<String, dynamic>;
          expect(stateJson.containsKey('entityId'), isTrue);
          expect(stateJson.containsKey('entityType'), isTrue);
          expect(stateJson['entityType'], equals('portion'));

          // Portion-specific data fields
          expect(stateJson.containsKey('data_name'), isTrue);
          expect(stateJson.containsKey('data_visibility'), isTrue);

          // Verify no DynamoDB storage keys are present
          expect(stateJson.containsKey('pk'), isFalse);
          expect(stateJson.containsKey('sk'), isFalse);
          expect(stateJson.containsKey('gsi1pk'), isFalse);
          expect(stateJson.containsKey('gsi1sk'), isFalse);
        }

        // Verify no overlap between pages by comparing entityIds
        final firstEntityIds = firstItems
            .map((item) => (item as Map<String, dynamic>)['entityId'] as String)
            .toSet();
        final secondEntityIds = secondItems
            .map((item) => (item as Map<String, dynamic>)['entityId'] as String)
            .toSet();

        expect(
          firstEntityIds.intersection(secondEntityIds).isEmpty,
          isTrue,
          reason: 'Pages should not have overlapping entity states',
        );
      },
      tags: ['internet', 'integration'],
      timeout: Timeout.none,
    );
  });
}
