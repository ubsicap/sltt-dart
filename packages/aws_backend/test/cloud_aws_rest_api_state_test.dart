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
    test('POST api/changes > GET /api/state/users/<user_id>/users', () async {
      final userId = '__test_user_state__';
      await resetTestDomainData(baseUrl, userId);

      final userData = BaseDataFields(
        parentId: 'parentId',
        parentProp: 'parentProp',
      );

      final responseSeed = await saveDomainChange(
        baseUrl,
        domainType: DomainType.user,
        userId,
        entityData: userData,
        entityType: EntityType.userPreferences,
      );

      if (responseSeed.statusCode != 200 && responseSeed.statusCode != 201) {
        fail(
          'Failed to save domain change, status code: ${responseSeed.statusCode}, body: ${responseSeed.body}',
        );
      }

      final resp = await http.get(
        Uri.parse('$baseUrl/api/state/users/$userId/user_preferences'),
        headers: {'Accept': 'application/json'},
      );
      expect(resp.statusCode, anyOf([200, 404]));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        expect(body['items'], isA<List>());
        final items = body['items'] as List;

        // Should return exactly 1 user entity
        expect(items.length, equals(1));
        expect(body.containsKey('hasMore'), isTrue);
        expect(body['hasMore'], isFalse);
      }
    });

    test(
      'POST api/changes/projects > GET /api/state/projects/<project_id>/projects',
      () async {
        final projectId = '__test_post_changes_get_state__';
        await resetTestDomainData(baseUrl, projectId);

        final entityData = BaseDataFields(
          parentId: 'parentId',
          parentProp: 'parentProp',
        );

        await saveDomainChange(baseUrl, projectId, entityData: entityData);

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

    test('GET /api/state with parentId parameter', () async {
      final projectId = '__test_state_parentId__';
      await resetTestDomainData(baseUrl, projectId);

      // Create a portion entity with a specific parentId
      final portionData = PortionTranslationData(
        name: 'Portion 1',
        visibility: ['user-1'],
        parentId: 'root',
        parentProp: 'portions',
        rank: 'rank1',
      );
      await saveChanges<PortionTranslationData>(
        baseUrl,
        domainType: 'project',
        domainId: projectId,
        changesToSave: [
          SaveChangeRequest<PortionTranslationData>(
            entityType: 'portion',
            entityId: 'portion_1',
            data: portionData,
            changeBy: 'user1',
          ),
        ],
      );

      // create another portion with different parentId, use portion_1,
      // even though portions don't own other portions, this is just for testing
      final otherPortionData = PortionTranslationData(
        name: 'Portion 2',
        visibility: ['user-1'],
        parentId: 'portion_1',
        parentProp: 'portions',
        rank: 'rank2',
      );
      await saveChanges<PortionTranslationData>(
        baseUrl,
        domainType: 'project',
        domainId: projectId,
        changesToSave: [
          SaveChangeRequest<PortionTranslationData>(
            entityType: 'portion',
            entityId: 'portion_2',
            data: otherPortionData,
            changeBy: 'user2',
          ),
        ],
      );

      final resp = await http.get(
        Uri.parse(
          '$baseUrl/api/state/projects/$projectId/portions?parentId=${portionData.parentId}',
        ),
        headers: {'Accept': 'application/json'},
      );
      expect(resp.statusCode, anyOf([200, 404]));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        expect(body['items'], isA<List>());
        final items = body['items'] as List;

        // Should return exactly 1 portion entity
        expect(items.length, equals(1));
        expect(body.containsKey('hasMore'), isTrue);
        expect(body['hasMore'], isFalse);
      }

      // now test with parentId=portion_1
      final resp2 = await http.get(
        Uri.parse(
          '$baseUrl/api/state/projects/$projectId/portions?parentId=${otherPortionData.parentId}',
        ),
        headers: {'Accept': 'application/json'},
      );
      expect(resp2.statusCode, anyOf([200, 404]));
      if (resp2.statusCode == 200) {
        final body = jsonDecode(resp2.body) as Map<String, dynamic>;
        expect(body['items'], isA<List>());
        final items = body['items'] as List;

        // Should return exactly 1 portion entity
        expect(items.length, equals(1));
        expect(body.containsKey('hasMore'), isTrue);
        expect(body['hasMore'], isFalse);
      }
    });

    test(
      'GET /api/state with limit parameter',
      () async {
        final projectId = '__test_state_limit__';
        await resetTestDomainData(baseUrl, projectId);

        // Create 5 different portion entities within the same project
        for (int i = 1; i <= 5; i++) {
          final portionData = PortionTranslationData(
            name: 'Portion $i',
            visibility: ['user-1'],
            parentId: 'root',
            parentProp: 'portions',
            rank: 'rank$i',
          );
          await saveChanges<PortionTranslationData>(
            baseUrl,
            domainType: 'project',
            domainId: projectId,
            changesToSave: [
              SaveChangeRequest<PortionTranslationData>(
                entityType: 'portion',
                entityId: 'portion_$i',
                data: portionData,
                changeBy: 'user$i',
              ),
            ],
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
        await resetTestDomainData(baseUrl, projectId);

        // Create 6 different portion entities within the same project for pagination
        for (int i = 1; i <= 6; i++) {
          final portionData = PortionTranslationData(
            name: 'Portion $i',
            visibility: ['user-1'],
            parentId: 'root',
            parentProp: 'portions',
            rank: 'rank$i',
          );
          await saveChanges<PortionTranslationData>(
            baseUrl,
            domainType: 'project',
            domainId: projectId,
            changesToSave: [
              SaveChangeRequest<PortionTranslationData>(
                entityType: 'portion',
                entityId: 'portion_$i',
                data: portionData,
                changeBy: 'user$i',
              ),
            ],
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

    test(
      'GET /api/state with storedAfter parameter',
      () async {
        final projectId = '__test_state_stored_after__';
        await resetTestDomainData(baseUrl, projectId);

        // Create first batch of 3 portions
        for (int i = 1; i <= 3; i++) {
          final portionData = PortionTranslationData(
            name: 'Portion $i',
            visibility: ['user-1'],
            parentId: 'root',
            parentProp: 'portions',
            rank: 'rank$i',
          );
          await saveChanges<PortionTranslationData>(
            baseUrl,
            domainType: 'project',
            domainId: projectId,
            changesToSave: [
              SaveChangeRequest<PortionTranslationData>(
                entityType: 'portion',
                entityId: 'portion_$i',
                data: portionData,
                changeBy: 'user$i',
              ),
            ],
          );
        }

        // Use server-side storedAt values as the cutoff baseline to avoid
        // client/server clock skew in cloud integration tests.
        final firstBatchResp = await http.get(
          Uri.parse('$baseUrl/api/state/projects/$projectId/portions'),
          headers: {'Accept': 'application/json'},
        );
        expect(firstBatchResp.statusCode, equals(200));
        final firstBatchBody =
            jsonDecode(firstBatchResp.body) as Map<String, dynamic>;
        final firstBatchItems = firstBatchBody['items'] as List;
        expect(
          firstBatchItems.length,
          equals(3),
          reason: 'First batch should have exactly 3 portions',
        );
        final firstBatchStoredAt =
            firstBatchItems
                .map(
                  (item) => DateTime.parse(
                    (item as Map<String, dynamic>)['change_storedAt'] as String,
                  ),
                )
                .toList()
              ..sort();
        final betweenBatches = firstBatchStoredAt.last.toUtc();

        // Create second batch of 3 portions
        for (int i = 4; i <= 6; i++) {
          final portionData = PortionTranslationData(
            name: 'Portion $i',
            visibility: ['user-1'],
            parentId: 'root',
            parentProp: 'portions',
            rank: 'rank$i',
          );
          await saveChanges<PortionTranslationData>(
            baseUrl,
            domainType: 'project',
            domainId: projectId,
            changesToSave: [
              SaveChangeRequest<PortionTranslationData>(
                entityType: 'portion',
                entityId: 'portion_$i',
                data: portionData,
                changeBy: 'user$i',
              ),
            ],
          );
        }

        // Test 1: Get all states without storedAfter filter
        final allStatesResp = await http.get(
          Uri.parse('$baseUrl/api/state/projects/$projectId/portions'),
          headers: {'Accept': 'application/json'},
        );
        expect(allStatesResp.statusCode, equals(200));

        final allStatesBody =
            jsonDecode(allStatesResp.body) as Map<String, dynamic>;
        final allItems = allStatesBody['items'] as List;
        expect(
          allItems.length,
          equals(6),
          reason: 'Should have all 6 portions',
        );

        // Test 2: Get only states stored after the between-batches timestamp
        final storedAfterParam = Uri.encodeComponent(
          betweenBatches.toIso8601String(),
        );
        final filteredResp = await http.get(
          Uri.parse(
            '$baseUrl/api/state/projects/$projectId/portions?storedAfter=$storedAfterParam',
          ),
          headers: {'Accept': 'application/json'},
        );
        expect(filteredResp.statusCode, equals(200));

        final filteredBody =
            jsonDecode(filteredResp.body) as Map<String, dynamic>;
        final filteredItems = filteredBody['items'] as List;

        // Verify that the data itself is correct (timestamps are properly separated)
        // Count items that were stored after the cutoff
        int itemsAfterCutoff = 0;
        for (final item in filteredItems) {
          final itemMap = item as Map<String, dynamic>;
          final storedAt = itemMap['change_storedAt'] as String;
          if (storedAt.compareTo(betweenBatches.toIso8601String()) > 0) {
            itemsAfterCutoff++;
          }
        }

        // The FilterExpression should filter server-side, but verify the data is correct
        expect(
          itemsAfterCutoff,
          equals(3),
          reason:
              'Should have exactly 3 items stored after the cutoff (data verification): betweenBatches: ${betweenBatches.toIso8601String()}, item storedAts: ${filteredItems.map((i) => (i as Map<String, dynamic>)['change_storedAt']).join(', ')}',
        );

        // Should only return the second batch (portions 4-6) when FilterExpression works
        expect(
          filteredItems.length,
          equals(3),
          reason:
              'Should only return portions stored after the cutoff timestamp: $storedAfterParam, betweenBatches: ${betweenBatches.toIso8601String()}, item storedAts: ${filteredItems.map((i) => (i as Map<String, dynamic>)['change_storedAt']).join(', ')}',
        );

        // Verify the returned items are from the second batch
        final returnedEntityIds = filteredItems
            .map((item) => (item as Map<String, dynamic>)['entityId'] as String)
            .toSet();

        expect(returnedEntityIds.contains('portion_4'), isTrue);
        expect(returnedEntityIds.contains('portion_5'), isTrue);
        expect(returnedEntityIds.contains('portion_6'), isTrue);
        expect(returnedEntityIds.contains('portion_1'), isFalse);
        expect(returnedEntityIds.contains('portion_2'), isFalse);
        expect(returnedEntityIds.contains('portion_3'), isFalse);

        // Test 3: Verify storedAfter works with a very old timestamp (should return all)
        final veryOldTimestamp = betweenBatches.subtract(
          const Duration(days: 1),
        );
        final veryOldParam = Uri.encodeComponent(
          veryOldTimestamp.toIso8601String(),
        );
        final oldFilterResp = await http.get(
          Uri.parse(
            '$baseUrl/api/state/projects/$projectId/portions?storedAfter=$veryOldParam',
          ),
          headers: {'Accept': 'application/json'},
        );
        expect(oldFilterResp.statusCode, equals(200));

        final oldFilterBody =
            jsonDecode(oldFilterResp.body) as Map<String, dynamic>;
        final oldFilterItems = oldFilterBody['items'] as List;
        expect(
          oldFilterItems.length,
          equals(6),
          reason: 'Old timestamp should return all items',
        );

        // Test 4: Verify storedAfter works with a very recent timestamp (should return none or very few)
        final allStoredAt =
            allItems
                .map(
                  (item) => DateTime.parse(
                    (item as Map<String, dynamic>)['change_storedAt'] as String,
                  ),
                )
                .toList()
              ..sort();
        final futureTimestamp = allStoredAt.last.toUtc().add(
          const Duration(seconds: 10),
        );
        final futureParam = Uri.encodeComponent(
          futureTimestamp.toIso8601String(),
        );
        final futureFilterResp = await http.get(
          Uri.parse(
            '$baseUrl/api/state/projects/$projectId/portions?storedAfter=$futureParam',
          ),
          headers: {'Accept': 'application/json'},
        );
        expect(futureFilterResp.statusCode, equals(200));

        final futureFilterBody =
            jsonDecode(futureFilterResp.body) as Map<String, dynamic>;
        final futureFilterItems = futureFilterBody['items'] as List;
        expect(
          futureFilterItems.length,
          equals(0),
          reason: 'Future timestamp should return no items',
        );

        // Test 5: Verify storedAfter works with pagination
        final paginatedResp = await http.get(
          Uri.parse(
            '$baseUrl/api/state/projects/$projectId/portions?storedAfter=$storedAfterParam&limit=2',
          ),
          headers: {'Accept': 'application/json'},
        );
        expect(paginatedResp.statusCode, equals(200));

        final paginatedBody =
            jsonDecode(paginatedResp.body) as Map<String, dynamic>;
        final paginatedItems = paginatedBody['items'] as List;
        expect(
          paginatedItems.length,
          lessThanOrEqualTo(2),
          reason: 'Should respect limit parameter',
        );
        expect(
          paginatedBody['hasMore'],
          isTrue,
          reason: 'Should indicate more pages available',
        );
        expect(paginatedBody.containsKey('cursor'), isTrue);
      },
      tags: ['internet', 'integration'],
      timeout: Timeout.none,
    );
  });
}
