import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/src/models/passage_translation.entity_state.dynamo.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'helpers/test_utils.dart';

void main() {
  final baseUrl = Uri.parse(
    Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl,
  );
  const testDomainId = '__test_passage_state_coverage';
  const testDomainType = 'project';

  const knownDateTimeFields = {
    'change_changeAt',
    'change_changeAt_orig_',
    'change_storedAt',
    'change_storedAt_orig_',
    'change_cloudAt',
    'data_name_changeAt_',
    'data_name_cloudAt_',
    'data_visibility_changeAt_',
    'data_visibility_cloudAt_',
    'data_type_changeAt_',
    'data_type_cloudAt_',
    'data_difficulty_changeAt_',
    'data_difficulty_cloudAt_',
    'data_references_changeAt_',
    'data_references_cloudAt_',
    'data_tags_changeAt_',
    'data_tags_cloudAt_',
    'data_includeInStatistics_changeAt_',
    'data_includeInStatistics_cloudAt_',
    'data_rank_changeAt_',
    'data_rank_cloudAt_',
    'data_deleted_changeAt_',
    'data_deleted_cloudAt_',
    'data_parentId_changeAt_',
    'data_parentId_cloudAt_',
    'data_parentProp_changeAt_',
    'data_parentProp_cloudAt_',
  };

  const knownPassageDataEntityStateFields = {
    'entityId',
    'entityType',
    'domainType',
    'unknownJson',
    'schemaVersion',
    'change_domainId',
    'change_domainId_orig_',
    'change_changeAt',
    'change_changeAt_orig_',
    'change_storedAt',
    'change_storedAt_orig_',
    'change_cid',
    'change_cid_orig_',
    'change_dataSchemaRev',
    'change_cloudAt',
    'change_changeBy',
    'change_changeBy_orig_',
    'data_name',
    'data_name_dataSchemaRev_',
    'data_name_changeAt_',
    'data_name_cid_',
    'data_name_changeBy_',
    'data_name_cloudAt_',
    'data_visibility',
    'data_visibility_dataSchemaRev_',
    'data_visibility_changeAt_',
    'data_visibility_cid_',
    'data_visibility_changeBy_',
    'data_visibility_cloudAt_',
    'data_type',
    'data_type_dataSchemaRev_',
    'data_type_changeAt_',
    'data_type_cid_',
    'data_type_changeBy_',
    'data_type_cloudAt_',
    'data_difficulty',
    'data_difficulty_dataSchemaRev_',
    'data_difficulty_changeAt_',
    'data_difficulty_cid_',
    'data_difficulty_changeBy_',
    'data_difficulty_cloudAt_',
    'data_references',
    'data_references_dataSchemaRev_',
    'data_references_changeAt_',
    'data_references_cid_',
    'data_references_changeBy_',
    'data_references_cloudAt_',
    'data_tags',
    'data_tags_dataSchemaRev_',
    'data_tags_changeAt_',
    'data_tags_cid_',
    'data_tags_changeBy_',
    'data_tags_cloudAt_',
    'data_includeInStatistics',
    'data_includeInStatistics_dataSchemaRev_',
    'data_includeInStatistics_changeAt_',
    'data_includeInStatistics_cid_',
    'data_includeInStatistics_changeBy_',
    'data_includeInStatistics_cloudAt_',
    'data_rank',
    'data_rank_dataSchemaRev_',
    'data_rank_changeAt_',
    'data_rank_cid_',
    'data_rank_changeBy_',
    'data_rank_cloudAt_',
    'data_deleted',
    'data_deleted_dataSchemaRev_',
    'data_deleted_changeAt_',
    'data_deleted_cid_',
    'data_deleted_changeBy_',
    'data_deleted_cloudAt_',
    'data_parentId',
    'data_parentId_dataSchemaRev_',
    'data_parentId_changeAt_',
    'data_parentId_cid_',
    'data_parentId_changeBy_',
    'data_parentId_cloudAt_',
    'data_parentProp',
    'data_parentProp_dataSchemaRev_',
    'data_parentProp_changeAt_',
    'data_parentProp_cid_',
    'data_parentProp_changeBy_',
    'data_parentProp_cloudAt_',
  };

  /// Helper to verify all DateTime fields are UTC
  void expectAllDateTimeFieldsUtc(
    DynamoPassageDataEntityState state, {
    required DateTime expectedDataNameChangeAt,
    required DateTime expectedDataNameCloudAt,
    required DateTime expectedDataVisibilityChangeAt,
    required DateTime expectedDataVisibilityCloudAt,
    required DateTime expectedDataTypeChangeAt,
    required DateTime expectedDataTypeCloudAt,
    required DateTime expectedDataDifficultyChangeAt,
    required DateTime expectedDataDifficultyCloudAt,
    required DateTime expectedDataReferencesChangeAt,
    required DateTime expectedDataReferencesCloudAt,
    required DateTime expectedDataTagsChangeAt,
    required DateTime expectedDataTagsCloudAt,
    required DateTime expectedDataIncludeInStatisticsChangeAt,
    required DateTime expectedDataIncludeInStatisticsCloudAt,
    required DateTime expectedChangeAt,
    required DateTime expectedCloudAt,
    required DateTime expectedStoredAt,
    required DateTime expectedDataRankChangeAt,
    required DateTime expectedDataRankCloudAt,
    required DateTime expectedDataDeletedChangeAt,
    required DateTime expectedDataDeletedCloudAt,
    required DateTime expectedDataParentIdChangeAt,
    required DateTime expectedDataParentIdCloudAt,
    required DateTime expectedDataParentPropChangeAt,
    required DateTime expectedDataParentPropCloudAt,
    String context = '',
  }) {
    final prefix = context.isEmpty ? '' : '$context: ';
    expect(
      state.data_name_changeAt_,
      equals(expectedDataNameChangeAt.toUtc()),
      reason: '${prefix}data_name_changeAt_ should be UTC',
    );
    expect(
      state.data_name_cloudAt_,
      equals(expectedDataNameCloudAt.toUtc()),
      reason: '${prefix}data_name_cloudAt_ should be UTC',
    );
    expect(
      state.data_visibility_changeAt_,
      equals(expectedDataVisibilityChangeAt.toUtc()),
      reason: '${prefix}data_visibility_changeAt_ should be UTC',
    );
    expect(
      state.data_visibility_cloudAt_,
      equals(expectedDataVisibilityCloudAt.toUtc()),
      reason: '${prefix}data_visibility_cloudAt_ should be UTC',
    );
    expect(
      state.data_type_changeAt_,
      equals(expectedDataTypeChangeAt.toUtc()),
      reason: '${prefix}data_type_changeAt_ should be UTC',
    );
    expect(
      state.data_type_cloudAt_,
      equals(expectedDataTypeCloudAt.toUtc()),
      reason: '${prefix}data_type_cloudAt_ should be UTC',
    );
    expect(
      state.data_difficulty_changeAt_,
      equals(expectedDataDifficultyChangeAt.toUtc()),
      reason: '${prefix}data_difficulty_changeAt_ should be UTC',
    );
    expect(
      state.data_difficulty_cloudAt_,
      equals(expectedDataDifficultyCloudAt.toUtc()),
      reason: '${prefix}data_difficulty_cloudAt_ should be UTC',
    );
    expect(
      state.data_references_changeAt_,
      equals(expectedDataReferencesChangeAt.toUtc()),
      reason: '${prefix}data_references_changeAt_ should be UTC',
    );
    expect(
      state.data_references_cloudAt_,
      equals(expectedDataReferencesCloudAt.toUtc()),
      reason: '${prefix}data_references_cloudAt_ should be UTC',
    );
    expect(
      state.data_tags_changeAt_,
      equals(expectedDataTagsChangeAt.toUtc()),
      reason: '${prefix}data_tags_changeAt_ should be UTC',
    );
    expect(
      state.data_tags_cloudAt_,
      equals(expectedDataTagsCloudAt.toUtc()),
      reason: '${prefix}data_tags_cloudAt_ should be UTC',
    );
    expect(
      state.data_includeInStatistics_changeAt_,
      equals(expectedDataIncludeInStatisticsChangeAt.toUtc()),
      reason: '${prefix}data_includeInStatistics_changeAt_ should be UTC',
    );
    expect(
      state.data_includeInStatistics_cloudAt_,
      equals(expectedDataIncludeInStatisticsCloudAt.toUtc()),
      reason: '${prefix}data_includeInStatistics_cloudAt_ should be UTC',
    );
    expect(
      state.change_changeAt,
      equals(expectedChangeAt.toUtc()),
      reason: '${prefix}change_changeAt should be UTC',
    );
    expect(
      state.change_changeAt_orig_,
      equals(expectedChangeAt.toUtc()),
      reason: '${prefix}change_changeAt_orig_ should be UTC',
    );
    expect(
      state.change_cloudAt,
      equals(expectedCloudAt.toUtc()),
      reason: '${prefix}change_cloudAt should be UTC',
    );
    expect(
      state.change_storedAt,
      equals(expectedStoredAt.toUtc()),
      reason: '${prefix}change_storedAt should be UTC',
    );
    expect(
      state.change_storedAt_orig_,
      equals(expectedStoredAt.toUtc()),
      reason: '${prefix}change_storedAt_orig_ should be UTC',
    );
    expect(
      state.data_rank_changeAt_,
      equals(expectedDataRankChangeAt.toUtc()),
      reason: '${prefix}data_rank_changeAt_ should be UTC',
    );
    expect(
      state.data_rank_cloudAt_,
      equals(expectedDataRankCloudAt.toUtc()),
      reason: '${prefix}data_rank_cloudAt_ should be UTC',
    );
    expect(
      state.data_deleted_changeAt_,
      equals(expectedDataDeletedChangeAt.toUtc()),
      reason: '${prefix}data_deleted_changeAt_ should be UTC',
    );
    expect(
      state.data_deleted_cloudAt_,
      equals(expectedDataDeletedCloudAt.toUtc()),
      reason: '${prefix}data_deleted_cloudAt_ should be UTC',
    );
    expect(
      state.data_parentId_changeAt_,
      equals(expectedDataParentIdChangeAt.toUtc()),
      reason: '${prefix}data_parentId_changeAt_ should be UTC',
    );
    expect(
      state.data_parentId_cloudAt_,
      equals(expectedDataParentIdCloudAt.toUtc()),
      reason: '${prefix}data_parentId_cloudAt_ should be UTC',
    );
    expect(
      state.data_parentProp_changeAt_,
      equals(expectedDataParentPropChangeAt.toUtc()),
      reason: '${prefix}data_parentProp_changeAt_ should be UTC',
    );
    expect(
      state.data_parentProp_cloudAt_,
      equals(expectedDataParentPropCloudAt.toUtc()),
      reason: '${prefix}data_parentProp_cloudAt_ should be UTC',
    );
  }

  group('storeState and getEntityState - DynamoPassageDataEntityState', () {
    test(
      'stores and retrieves with all expected fields - DynamoPassageDataEntityState',
      () async {
        await resetTestProject(baseUrl, testDomainId);
        final localChangeAt = DateTime.now();
        final localCloudAt = DateTime.now().subtract(const Duration(hours: 1));
        final localStoredAt = DateTime.now().subtract(
          const Duration(minutes: 30),
        );
        final localDataNameChangeAt = DateTime.now().subtract(
          const Duration(minutes: 15),
        );
        final localDataNameCloudAt = DateTime.now().subtract(
          const Duration(minutes: 18),
        );
        final localDataVisibilityChangeAt = DateTime.now().subtract(
          const Duration(minutes: 13),
        );
        final localDataVisibilityCloudAt = DateTime.now().subtract(
          const Duration(minutes: 16),
        );
        final localDataTypeChangeAt = DateTime.now().subtract(
          const Duration(minutes: 12),
        );
        final localDataTypeCloudAt = DateTime.now().subtract(
          const Duration(minutes: 14),
        );
        final localDataDifficultyChangeAt = DateTime.now().subtract(
          const Duration(minutes: 11),
        );
        final localDataDifficultyCloudAt = DateTime.now().subtract(
          const Duration(minutes: 17),
        );
        final localDataReferencesChangeAt = DateTime.now().subtract(
          const Duration(minutes: 10),
        );
        final localDataReferencesCloudAt = DateTime.now().subtract(
          const Duration(minutes: 19),
        );
        final localDataTagsChangeAt = DateTime.now().subtract(
          const Duration(minutes: 9),
        );
        final localDataTagsCloudAt = DateTime.now().subtract(
          const Duration(minutes: 20),
        );
        final localDataIncludeInStatisticsChangeAt = DateTime.now().subtract(
          const Duration(minutes: 8),
        );
        final localDataIncludeInStatisticsCloudAt = DateTime.now().subtract(
          const Duration(minutes: 21),
        );
        final localDataRankChangeAt = DateTime.now().subtract(
          const Duration(minutes: 22),
        );
        final localDataRankCloudAt = DateTime.now().subtract(
          const Duration(minutes: 27),
        );
        final localDataDeletedChangeAt = DateTime.now().subtract(
          const Duration(minutes: 20),
        );
        final localDataDeletedCloudAt = DateTime.now().subtract(
          const Duration(minutes: 25),
        );
        final localDataParentIdChangeAt = DateTime.now().subtract(
          const Duration(minutes: 10),
        );
        final localDataParentIdCloudAt = DateTime.now().subtract(
          const Duration(minutes: 12),
        );
        final localDataParentPropChangeAt = DateTime.now().subtract(
          const Duration(minutes: 5),
        );
        final localDataParentPropCloudAt = DateTime.now().subtract(
          const Duration(minutes: 7),
        );

        expect(
          localChangeAt.isUtc,
          isFalse,
          reason: 'Test DateTime should be local',
        );
        expect(
          localCloudAt.isUtc,
          isFalse,
          reason: 'Test DateTime should be local',
        );
        expect(
          localStoredAt.isUtc,
          isFalse,
          reason: 'Test DateTime should be local',
        );

        final cidOrig = generateCid(
          entityType: EntityType.passage,
          userId: 'test-user-1',
        );

        final entry = DynamoPassageDataEntityState(
          entityId: 'test-passage-1',
          entityType: kEntityTypePassage,
          domainType: testDomainType,
          unknownJson: '{}',
          schemaVersion: 1,
          change_domainId: testDomainId,
          change_domainId_orig_: testDomainId,
          change_changeAt: localChangeAt,
          change_changeAt_orig_: localChangeAt,
          change_storedAt: localStoredAt,
          change_storedAt_orig_: localStoredAt,
          change_cid: generateCid(
            entityType: EntityType.passage,
            userId: 'test-user-7',
          ),
          change_cid_orig_: cidOrig,
          change_dataSchemaRev: 7,
          change_cloudAt: localCloudAt,
          change_changeBy: 'test-user-7',
          change_changeBy_orig_: 'test-user-1',
          data_name: 'Σ Passage 1',
          data_name_dataSchemaRev_: 7,
          data_name_changeAt_: localDataNameChangeAt,
          data_name_cid_: generateCid(
            entityType: EntityType.passage,
            userId: 'test-user-7',
          ),
          data_name_changeBy_: 'test-user-7',
          data_name_cloudAt_: localDataNameCloudAt,
          data_visibility: ['test-user-7'],
          data_visibility_dataSchemaRev_: 7,
          data_visibility_changeAt_: localDataVisibilityChangeAt,
          data_visibility_cid_: generateCid(
            entityType: EntityType.passage,
            userId: 'test-user-7',
          ),
          data_visibility_changeBy_: 'test-user-7',
          data_visibility_cloudAt_: localDataVisibilityCloudAt,
          data_type: 'typeA',
          data_type_dataSchemaRev_: 8,
          data_type_changeAt_: localDataTypeChangeAt,
          data_type_cid_: generateCid(
            entityType: EntityType.passage,
            userId: 'test-user-8',
          ),
          data_type_changeBy_: 'test-user-8',
          data_type_cloudAt_: localDataTypeCloudAt,
          data_difficulty: 'easy',
          data_difficulty_dataSchemaRev_: 9,
          data_difficulty_changeAt_: localDataDifficultyChangeAt,
          data_difficulty_cid_: generateCid(
            entityType: EntityType.passage,
            userId: 'test-user-9',
          ),
          data_difficulty_changeBy_: 'test-user-9',
          data_difficulty_cloudAt_: localDataDifficultyCloudAt,
          data_references: ['ref1', 'ref2'],
          data_references_dataSchemaRev_: 10,
          data_references_changeAt_: localDataReferencesChangeAt,
          data_references_cid_: generateCid(
            entityType: EntityType.passage,
            userId: 'test-user-10',
          ),
          data_references_changeBy_: 'test-user-10',
          data_references_cloudAt_: localDataReferencesCloudAt,
          data_tags: ['tag1', 'tag2'],
          data_tags_dataSchemaRev_: 11,
          data_tags_changeAt_: localDataTagsChangeAt,
          data_tags_cid_: generateCid(
            entityType: EntityType.passage,
            userId: 'test-user-11',
          ),
          data_tags_changeBy_: 'test-user-11',
          data_tags_cloudAt_: localDataTagsCloudAt,
          data_includeInStatistics: true,
          data_includeInStatistics_dataSchemaRev_: 12,
          data_includeInStatistics_changeAt_:
              localDataIncludeInStatisticsChangeAt,
          data_includeInStatistics_cid_: generateCid(
            entityType: EntityType.passage,
            userId: 'test-user-12',
          ),
          data_includeInStatistics_changeBy_: 'test-user-12',
          data_includeInStatistics_cloudAt_:
              localDataIncludeInStatisticsCloudAt,
          data_rank: 'aaaaz',
          data_rank_dataSchemaRev_: 7,
          data_rank_changeAt_: localDataRankChangeAt,
          data_rank_cid_: generateCid(
            entityType: EntityType.passage,
            userId: 'test-user-7',
          ),
          data_rank_changeBy_: 'test-user-7',
          data_rank_cloudAt_: localDataRankCloudAt,
          data_deleted: false,
          data_deleted_dataSchemaRev_: 7,
          data_deleted_changeAt_: localDataDeletedChangeAt,
          data_deleted_cid_: generateCid(
            entityType: EntityType.passage,
            userId: 'test-user-7',
          ),
          data_deleted_changeBy_: 'test-user-7',
          data_deleted_cloudAt_: localDataDeletedCloudAt,
          data_parentId: 'root',
          data_parentId_dataSchemaRev_: 7,
          data_parentId_changeAt_: localDataParentIdChangeAt,
          data_parentId_cid_: generateCid(
            entityType: EntityType.passage,
            userId: 'test-user-7',
          ),
          data_parentId_changeBy_: 'test-user-7',
          data_parentId_cloudAt_: localDataParentIdCloudAt,
          data_parentProp: 'passages',
          data_parentProp_dataSchemaRev_: 7,
          data_parentProp_changeAt_: localDataParentPropChangeAt,
          data_parentProp_cid_: generateCid(
            entityType: EntityType.passage,
            userId: 'test-user-7',
          ),
          data_parentProp_changeBy_: 'test-user-7',
          data_parentProp_cloudAt_: localDataParentPropCloudAt,
        );

        // Store the state using HTTP API
        final storeUrl = baseUrl.replace(
          path: '${baseUrl.path}/api/storage/__test/state',
        );
        final storeResponse = await http.post(
          storeUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(entry.toJson()),
        );

        expect(
          storeResponse.statusCode,
          equals(200),
          reason: 'Failed to store state: ${storeResponse.body}',
        );

        final storeResponseJson =
            jsonDecode(storeResponse.body) as Map<String, dynamic>;
        final storedStateJson =
            storeResponseJson['entityState'] as Map<String, dynamic>;
        final storedState = DynamoPassageDataEntityState.fromJson(
          storedStateJson,
        );

        // Verify the stored state is returned and has UTC DateTimes
        expect(storedState, isA<DynamoPassageDataEntityState>());
        expectAllDateTimeFieldsUtc(
          storedState,
          expectedDataNameChangeAt: localDataNameChangeAt,
          expectedDataNameCloudAt: localDataNameCloudAt,
          expectedDataVisibilityChangeAt: localDataVisibilityChangeAt,
          expectedDataVisibilityCloudAt: localDataVisibilityCloudAt,
          expectedDataTypeChangeAt: localDataTypeChangeAt,
          expectedDataTypeCloudAt: localDataTypeCloudAt,
          expectedDataDifficultyChangeAt: localDataDifficultyChangeAt,
          expectedDataDifficultyCloudAt: localDataDifficultyCloudAt,
          expectedDataReferencesChangeAt: localDataReferencesChangeAt,
          expectedDataReferencesCloudAt: localDataReferencesCloudAt,
          expectedDataTagsChangeAt: localDataTagsChangeAt,
          expectedDataTagsCloudAt: localDataTagsCloudAt,
          expectedDataIncludeInStatisticsChangeAt:
              localDataIncludeInStatisticsChangeAt,
          expectedDataIncludeInStatisticsCloudAt:
              localDataIncludeInStatisticsCloudAt,
          expectedChangeAt: localChangeAt,
          expectedCloudAt: localCloudAt,
          expectedStoredAt: localStoredAt,
          expectedDataRankChangeAt: localDataRankChangeAt,
          expectedDataRankCloudAt: localDataRankCloudAt,
          expectedDataDeletedChangeAt: localDataDeletedChangeAt,
          expectedDataDeletedCloudAt: localDataDeletedCloudAt,
          expectedDataParentIdChangeAt: localDataParentIdChangeAt,
          expectedDataParentIdCloudAt: localDataParentIdCloudAt,
          expectedDataParentPropChangeAt: localDataParentPropChangeAt,
          expectedDataParentPropCloudAt: localDataParentPropCloudAt,
          context: 'After storeState',
        );

        // Retrieve the state using GET API
        final getUrl = baseUrl.replace(
          path:
              '${baseUrl.path}/api/state/projects/$testDomainId/passages/test-passage-1',
        );
        final getResponse = await http.get(getUrl);

        expect(
          getResponse.statusCode,
          equals(200),
          reason: 'Failed to get state: ${getResponse.body}',
        );

        final getResponseJson =
            jsonDecode(getResponse.body) as Map<String, dynamic>;
        final retrievedStateJson =
            getResponseJson['state'] as Map<String, dynamic>;
        final retrieved = DynamoPassageDataEntityState.fromJson(
          retrievedStateJson,
        );

        // Verify we got the state back
        expect(retrieved, isA<DynamoPassageDataEntityState>());

        // Verify all DateTime fields are still UTC after retrieval
        expectAllDateTimeFieldsUtc(
          retrieved,
          expectedDataNameChangeAt: localDataNameChangeAt,
          expectedDataNameCloudAt: localDataNameCloudAt,
          expectedDataVisibilityChangeAt: localDataVisibilityChangeAt,
          expectedDataVisibilityCloudAt: localDataVisibilityCloudAt,
          expectedDataTypeChangeAt: localDataTypeChangeAt,
          expectedDataTypeCloudAt: localDataTypeCloudAt,
          expectedDataDifficultyChangeAt: localDataDifficultyChangeAt,
          expectedDataDifficultyCloudAt: localDataDifficultyCloudAt,
          expectedDataReferencesChangeAt: localDataReferencesChangeAt,
          expectedDataReferencesCloudAt: localDataReferencesCloudAt,
          expectedDataTagsChangeAt: localDataTagsChangeAt,
          expectedDataTagsCloudAt: localDataTagsCloudAt,
          expectedDataIncludeInStatisticsChangeAt:
              localDataIncludeInStatisticsChangeAt,
          expectedDataIncludeInStatisticsCloudAt:
              localDataIncludeInStatisticsCloudAt,
          expectedChangeAt: localChangeAt,
          expectedCloudAt: localCloudAt,
          expectedStoredAt: localStoredAt,
          expectedDataRankChangeAt: localDataRankChangeAt,
          expectedDataRankCloudAt: localDataRankCloudAt,
          expectedDataDeletedChangeAt: localDataDeletedChangeAt,
          expectedDataDeletedCloudAt: localDataDeletedCloudAt,
          expectedDataParentIdChangeAt: localDataParentIdChangeAt,
          expectedDataParentIdCloudAt: localDataParentIdCloudAt,
          expectedDataParentPropChangeAt: localDataParentPropChangeAt,
          expectedDataParentPropCloudAt: localDataParentPropCloudAt,
          context: 'After getEntityState',
        );

        // Verify all fields match
        expect(retrieved.entityId, equals(entry.entityId));
        expect(retrieved.entityType, equals(entry.entityType));
        expect(retrieved.domainType, equals(entry.domainType));
        expect(retrieved.change_domainId, equals(entry.change_domainId));
        expect(retrieved.change_cid, equals(entry.change_cid));
        expect(retrieved.change_cid_orig_, equals(entry.change_cid_orig_));
        expect(
          retrieved.change_dataSchemaRev,
          equals(entry.change_dataSchemaRev),
        );
        expect(retrieved.change_changeBy, equals(entry.change_changeBy));
        expect(
          retrieved.change_changeBy_orig_,
          equals(entry.change_changeBy_orig_),
        );
        expect(retrieved.data_name, equals(entry.data_name));
        expect(
          retrieved.data_name_dataSchemaRev_,
          equals(entry.data_name_dataSchemaRev_),
        );
        expect(retrieved.data_name_cid_, equals(entry.data_name_cid_));
        expect(
          retrieved.data_name_changeBy_,
          equals(entry.data_name_changeBy_),
        );
        expect(retrieved.data_visibility, equals(entry.data_visibility));
        expect(
          retrieved.data_visibility_dataSchemaRev_,
          equals(entry.data_visibility_dataSchemaRev_),
        );
        expect(
          retrieved.data_visibility_cid_,
          equals(entry.data_visibility_cid_),
        );
        expect(
          retrieved.data_visibility_changeBy_,
          equals(entry.data_visibility_changeBy_),
        );
        expect(retrieved.data_type, equals(entry.data_type));
        expect(
          retrieved.data_type_dataSchemaRev_,
          equals(entry.data_type_dataSchemaRev_),
        );
        expect(retrieved.data_type_cid_, equals(entry.data_type_cid_));
        expect(
          retrieved.data_type_changeBy_,
          equals(entry.data_type_changeBy_),
        );
        expect(retrieved.data_difficulty, equals(entry.data_difficulty));
        expect(
          retrieved.data_difficulty_dataSchemaRev_,
          equals(entry.data_difficulty_dataSchemaRev_),
        );
        expect(
          retrieved.data_difficulty_cid_,
          equals(entry.data_difficulty_cid_),
        );
        expect(
          retrieved.data_difficulty_changeBy_,
          equals(entry.data_difficulty_changeBy_),
        );
        expect(retrieved.data_references, equals(entry.data_references));
        expect(
          retrieved.data_references_dataSchemaRev_,
          equals(entry.data_references_dataSchemaRev_),
        );
        expect(
          retrieved.data_references_cid_,
          equals(entry.data_references_cid_),
        );
        expect(
          retrieved.data_references_changeBy_,
          equals(entry.data_references_changeBy_),
        );
        expect(retrieved.data_tags, equals(entry.data_tags));
        expect(
          retrieved.data_tags_dataSchemaRev_,
          equals(entry.data_tags_dataSchemaRev_),
        );
        expect(retrieved.data_tags_cid_, equals(entry.data_tags_cid_));
        expect(
          retrieved.data_tags_changeBy_,
          equals(entry.data_tags_changeBy_),
        );
        expect(
          retrieved.data_includeInStatistics,
          equals(entry.data_includeInStatistics),
        );
        expect(
          retrieved.data_includeInStatistics_dataSchemaRev_,
          equals(entry.data_includeInStatistics_dataSchemaRev_),
        );
        expect(
          retrieved.data_includeInStatistics_cid_,
          equals(entry.data_includeInStatistics_cid_),
        );
        expect(
          retrieved.data_includeInStatistics_changeBy_,
          equals(entry.data_includeInStatistics_changeBy_),
        );
        expect(retrieved.data_rank, equals(entry.data_rank));
        expect(
          retrieved.data_rank_dataSchemaRev_,
          equals(entry.data_rank_dataSchemaRev_),
        );
        expect(retrieved.data_rank_cid_, equals(entry.data_rank_cid_));
        expect(
          retrieved.data_rank_changeBy_,
          equals(entry.data_rank_changeBy_),
        );
        expect(retrieved.data_deleted, equals(entry.data_deleted));
        expect(
          retrieved.data_deleted_dataSchemaRev_,
          equals(entry.data_deleted_dataSchemaRev_),
        );
        expect(retrieved.data_deleted_cid_, equals(entry.data_deleted_cid_));
        expect(
          retrieved.data_deleted_changeBy_,
          equals(entry.data_deleted_changeBy_),
        );
        expect(retrieved.data_parentId, equals(entry.data_parentId));
        expect(
          retrieved.data_parentId_dataSchemaRev_,
          equals(entry.data_parentId_dataSchemaRev_),
        );
        expect(retrieved.data_parentId_cid_, equals(entry.data_parentId_cid_));
        expect(
          retrieved.data_parentId_changeBy_,
          equals(entry.data_parentId_changeBy_),
        );
        expect(retrieved.data_parentProp, equals(entry.data_parentProp));
        expect(
          retrieved.data_parentProp_dataSchemaRev_,
          equals(entry.data_parentProp_dataSchemaRev_),
        );
        expect(
          retrieved.data_parentProp_cid_,
          equals(entry.data_parentProp_cid_),
        );
        expect(
          retrieved.data_parentProp_changeBy_,
          equals(entry.data_parentProp_changeBy_),
        );

        // Verify toJson includes all expected fields
        final json = retrieved.toJson();
        final jsonKeys = json.keys.toSet();

        // Check all known fields are present in JSON
        for (final field in knownPassageDataEntityStateFields) {
          expect(
            jsonKeys.contains(field),
            isTrue,
            reason: 'Expected field $field to be in JSON',
          );
        }

        // Check for any unexpected fields (field drift detection)
        final unknownFields = jsonKeys.difference(
          knownPassageDataEntityStateFields,
        );
        expect(
          unknownFields,
          isEmpty,
          reason: 'Unexpected fields in JSON: $unknownFields',
        );

        // Verify DateTime fields are properly serialized in JSON
        for (final dateTimeField in knownDateTimeFields) {
          expect(
            json[dateTimeField],
            isA<String>(),
            reason:
                'DateTime field $dateTimeField should be serialized as string',
          );
        }
      },
    );
  });
}
