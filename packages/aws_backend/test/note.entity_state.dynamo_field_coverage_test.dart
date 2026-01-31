import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/src/models/note.entity_state.dynamo.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'helpers/test_utils.dart';

void main() {
  final baseUrl = Uri.parse(
    Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl,
  );
  const testDomainId = '__test_note_state_coverage';
  const testDomainType = 'project';

  const knownDateTimeFields = {
    'change_changeAt',
    'change_changeAt_orig_',
    'change_storedAt',
    'change_storedAt_orig_',
    'change_cloudAt',
    'data_title_changeAt_',
    'data_title_cloudAt_',
    'data_videoCommentId_changeAt_',
    'data_videoCommentId_cloudAt_',
    'data_textComment_changeAt_',
    'data_textComment_cloudAt_',
    'data_markerColorValue_changeAt_',
    'data_markerColorValue_cloudAt_',
    'data_markerShape_changeAt_',
    'data_markerShape_cloudAt_',
    'data_markerDescription_changeAt_',
    'data_markerDescription_cloudAt_',
    'data_positionMs_changeAt_',
    'data_positionMs_cloudAt_',
    'data_resolution_changeAt_',
    'data_resolution_cloudAt_',
    'data_rank_changeAt_',
    'data_rank_cloudAt_',
    'data_deleted_changeAt_',
    'data_deleted_cloudAt_',
    'data_parentId_changeAt_',
    'data_parentId_cloudAt_',
    'data_parentProp_changeAt_',
    'data_parentProp_cloudAt_',
  };

  const knownNoteDataEntityStateFields = {
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
    'data_title',
    'data_title_dataSchemaRev_',
    'data_title_changeAt_',
    'data_title_cid_',
    'data_title_changeBy_',
    'data_title_cloudAt_',
    'data_videoCommentId',
    'data_videoCommentId_dataSchemaRev_',
    'data_videoCommentId_changeAt_',
    'data_videoCommentId_cid_',
    'data_videoCommentId_changeBy_',
    'data_videoCommentId_cloudAt_',
    'data_textComment',
    'data_textComment_dataSchemaRev_',
    'data_textComment_changeAt_',
    'data_textComment_cid_',
    'data_textComment_changeBy_',
    'data_textComment_cloudAt_',
    'data_markerColorValue',
    'data_markerColorValue_dataSchemaRev_',
    'data_markerColorValue_changeAt_',
    'data_markerColorValue_cid_',
    'data_markerColorValue_changeBy_',
    'data_markerColorValue_cloudAt_',
    'data_markerShape',
    'data_markerShape_dataSchemaRev_',
    'data_markerShape_changeAt_',
    'data_markerShape_cid_',
    'data_markerShape_changeBy_',
    'data_markerShape_cloudAt_',
    'data_markerDescription',
    'data_markerDescription_dataSchemaRev_',
    'data_markerDescription_changeAt_',
    'data_markerDescription_cid_',
    'data_markerDescription_changeBy_',
    'data_markerDescription_cloudAt_',
    'data_positionMs',
    'data_positionMs_dataSchemaRev_',
    'data_positionMs_changeAt_',
    'data_positionMs_cid_',
    'data_positionMs_changeBy_',
    'data_positionMs_cloudAt_',
    'data_resolution',
    'data_resolution_dataSchemaRev_',
    'data_resolution_changeAt_',
    'data_resolution_cid_',
    'data_resolution_changeBy_',
    'data_resolution_cloudAt_',
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

  void expectAllDateTimeFieldsUtc(
    DynamoNoteDataEntityState state, {
    required DateTime expectedDataTitleChangeAt,
    required DateTime expectedDataTitleCloudAt,
    required DateTime expectedDataVideoCommentIdChangeAt,
    required DateTime expectedDataVideoCommentIdCloudAt,
    required DateTime expectedDataTextCommentChangeAt,
    required DateTime expectedDataTextCommentCloudAt,
    required DateTime expectedDataMarkerColorValueChangeAt,
    required DateTime expectedDataMarkerColorValueCloudAt,
    required DateTime expectedDataMarkerShapeChangeAt,
    required DateTime expectedDataMarkerShapeCloudAt,
    required DateTime expectedDataMarkerDescriptionChangeAt,
    required DateTime expectedDataMarkerDescriptionCloudAt,
    required DateTime expectedDataPositionMsChangeAt,
    required DateTime expectedDataPositionMsCloudAt,
    required DateTime expectedDataResolutionChangeAt,
    required DateTime expectedDataResolutionCloudAt,
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
      state.data_title_changeAt_,
      equals(expectedDataTitleChangeAt.toUtc()),
      reason: '${prefix}data_title_changeAt_ should be UTC',
    );
    expect(
      state.data_title_cloudAt_,
      equals(expectedDataTitleCloudAt.toUtc()),
      reason: '${prefix}data_title_cloudAt_ should be UTC',
    );
    expect(
      state.data_videoCommentId_changeAt_,
      equals(expectedDataVideoCommentIdChangeAt.toUtc()),
      reason: '${prefix}data_videoCommentId_changeAt_ should be UTC',
    );
    expect(
      state.data_videoCommentId_cloudAt_,
      equals(expectedDataVideoCommentIdCloudAt.toUtc()),
      reason: '${prefix}data_videoCommentId_cloudAt_ should be UTC',
    );
    expect(
      state.data_textComment_changeAt_,
      equals(expectedDataTextCommentChangeAt.toUtc()),
      reason: '${prefix}data_textComment_changeAt_ should be UTC',
    );
    expect(
      state.data_textComment_cloudAt_,
      equals(expectedDataTextCommentCloudAt.toUtc()),
      reason: '${prefix}data_textComment_cloudAt_ should be UTC',
    );
    expect(
      state.data_markerColorValue_changeAt_,
      equals(expectedDataMarkerColorValueChangeAt.toUtc()),
      reason: '${prefix}data_markerColorValue_changeAt_ should be UTC',
    );
    expect(
      state.data_markerColorValue_cloudAt_,
      equals(expectedDataMarkerColorValueCloudAt.toUtc()),
      reason: '${prefix}data_markerColorValue_cloudAt_ should be UTC',
    );
    expect(
      state.data_markerShape_changeAt_,
      equals(expectedDataMarkerShapeChangeAt.toUtc()),
      reason: '${prefix}data_markerShape_changeAt_ should be UTC',
    );
    expect(
      state.data_markerShape_cloudAt_,
      equals(expectedDataMarkerShapeCloudAt.toUtc()),
      reason: '${prefix}data_markerShape_cloudAt_ should be UTC',
    );
    expect(
      state.data_markerDescription_changeAt_,
      equals(expectedDataMarkerDescriptionChangeAt.toUtc()),
      reason: '${prefix}data_markerDescription_changeAt_ should be UTC',
    );
    expect(
      state.data_markerDescription_cloudAt_,
      equals(expectedDataMarkerDescriptionCloudAt.toUtc()),
      reason: '${prefix}data_markerDescription_cloudAt_ should be UTC',
    );
    expect(
      state.data_positionMs_changeAt_,
      equals(expectedDataPositionMsChangeAt.toUtc()),
      reason: '${prefix}data_positionMs_changeAt_ should be UTC',
    );
    expect(
      state.data_positionMs_cloudAt_,
      equals(expectedDataPositionMsCloudAt.toUtc()),
      reason: '${prefix}data_positionMs_cloudAt_ should be UTC',
    );
    expect(
      state.data_resolution_changeAt_,
      equals(expectedDataResolutionChangeAt.toUtc()),
      reason: '${prefix}data_resolution_changeAt_ should be UTC',
    );
    expect(
      state.data_resolution_cloudAt_,
      equals(expectedDataResolutionCloudAt.toUtc()),
      reason: '${prefix}data_resolution_cloudAt_ should be UTC',
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

  group('storeState and getEntityState - DynamoNoteDataEntityState', () {
    test(
      'stores and retrieves with all expected fields - DynamoNoteDataEntityState',
      () async {
        await resetTestProject(baseUrl, testDomainId);

        final localChangeAt = DateTime.now();
        final localCloudAt = DateTime.now().subtract(const Duration(hours: 1));
        final localStoredAt = DateTime.now().subtract(
          const Duration(minutes: 30),
        );
        final localDataTitleChangeAt = DateTime.now().subtract(
          const Duration(minutes: 15),
        );
        final localDataTitleCloudAt = DateTime.now().subtract(
          const Duration(minutes: 18),
        );
        final localDataVideoCommentIdChangeAt = DateTime.now().subtract(
          const Duration(minutes: 12),
        );
        final localDataVideoCommentIdCloudAt = DateTime.now().subtract(
          const Duration(minutes: 17),
        );
        final localDataTextCommentChangeAt = DateTime.now().subtract(
          const Duration(minutes: 14),
        );
        final localDataTextCommentCloudAt = DateTime.now().subtract(
          const Duration(minutes: 13),
        );
        final localDataMarkerColorValueChangeAt = DateTime.now().subtract(
          const Duration(minutes: 16),
        );
        final localDataMarkerColorValueCloudAt = DateTime.now().subtract(
          const Duration(minutes: 19),
        );
        final localDataMarkerShapeChangeAt = DateTime.now().subtract(
          const Duration(minutes: 11),
        );
        final localDataMarkerShapeCloudAt = DateTime.now().subtract(
          const Duration(minutes: 10),
        );
        final localDataMarkerDescriptionChangeAt = DateTime.now().subtract(
          const Duration(minutes: 9),
        );
        final localDataMarkerDescriptionCloudAt = DateTime.now().subtract(
          const Duration(minutes: 8),
        );
        final localDataPositionMsChangeAt = DateTime.now().subtract(
          const Duration(minutes: 7),
        );
        final localDataPositionMsCloudAt = DateTime.now().subtract(
          const Duration(minutes: 6),
        );
        final localDataResolutionChangeAt = DateTime.now().subtract(
          const Duration(minutes: 5),
        );
        final localDataResolutionCloudAt = DateTime.now().subtract(
          const Duration(minutes: 4),
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

        final cidOrig = generateCid(
          entityType: EntityType.note,
          userId: 'test-user-1',
        );

        final entry = DynamoNoteDataEntityState(
          entityId: 'test-note-1',
          entityType: kEntityTypeNote,
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
            entityType: EntityType.note,
            userId: 'test-user-7',
          ),
          change_cid_orig_: cidOrig,
          change_dataSchemaRev: 7,
          change_cloudAt: localCloudAt,
          change_changeBy: 'test-user-7',
          change_changeBy_orig_: 'test-user-1',
          data_title: 'Note Title',
          data_title_dataSchemaRev_: 7,
          data_title_changeAt_: localDataTitleChangeAt,
          data_title_cid_: generateCid(
            entityType: EntityType.note,
            userId: 'test-user-7',
          ),
          data_title_changeBy_: 'test-user-7',
          data_title_cloudAt_: localDataTitleCloudAt,
          data_videoCommentId: 'video-comment-1',
          data_videoCommentId_dataSchemaRev_: 7,
          data_videoCommentId_changeAt_: localDataVideoCommentIdChangeAt,
          data_videoCommentId_cid_: generateCid(
            entityType: EntityType.note,
            userId: 'test-user-7',
          ),
          data_videoCommentId_changeBy_: 'test-user-7',
          data_videoCommentId_cloudAt_: localDataVideoCommentIdCloudAt,
          data_textComment: 'Note text comment',
          data_textComment_dataSchemaRev_: 7,
          data_textComment_changeAt_: localDataTextCommentChangeAt,
          data_textComment_cid_: generateCid(
            entityType: EntityType.note,
            userId: 'test-user-7',
          ),
          data_textComment_changeBy_: 'test-user-7',
          data_textComment_cloudAt_: localDataTextCommentCloudAt,
          data_markerColorValue: 0xFF00FF00,
          data_markerColorValue_dataSchemaRev_: 7,
          data_markerColorValue_changeAt_: localDataMarkerColorValueChangeAt,
          data_markerColorValue_cid_: generateCid(
            entityType: EntityType.note,
            userId: 'test-user-7',
          ),
          data_markerColorValue_changeBy_: 'test-user-7',
          data_markerColorValue_cloudAt_: localDataMarkerColorValueCloudAt,
          data_markerShape: 'circle',
          data_markerShape_dataSchemaRev_: 7,
          data_markerShape_changeAt_: localDataMarkerShapeChangeAt,
          data_markerShape_cid_: generateCid(
            entityType: EntityType.note,
            userId: 'test-user-7',
          ),
          data_markerShape_changeBy_: 'test-user-7',
          data_markerShape_cloudAt_: localDataMarkerShapeCloudAt,
          data_markerDescription: 'Marker description',
          data_markerDescription_dataSchemaRev_: 7,
          data_markerDescription_changeAt_: localDataMarkerDescriptionChangeAt,
          data_markerDescription_cid_: generateCid(
            entityType: EntityType.note,
            userId: 'test-user-7',
          ),
          data_markerDescription_changeBy_: 'test-user-7',
          data_markerDescription_cloudAt_: localDataMarkerDescriptionCloudAt,
          data_positionMs: 1234,
          data_positionMs_dataSchemaRev_: 7,
          data_positionMs_changeAt_: localDataPositionMsChangeAt,
          data_positionMs_cid_: generateCid(
            entityType: EntityType.note,
            userId: 'test-user-7',
          ),
          data_positionMs_changeBy_: 'test-user-7',
          data_positionMs_cloudAt_: localDataPositionMsCloudAt,
          data_resolution: 'unresolved',
          data_resolution_dataSchemaRev_: 7,
          data_resolution_changeAt_: localDataResolutionChangeAt,
          data_resolution_cid_: generateCid(
            entityType: EntityType.note,
            userId: 'test-user-7',
          ),
          data_resolution_changeBy_: 'test-user-7',
          data_resolution_cloudAt_: localDataResolutionCloudAt,
          data_rank: 'aaaaz',
          data_rank_dataSchemaRev_: 7,
          data_rank_changeAt_: localDataRankChangeAt,
          data_rank_cid_: generateCid(
            entityType: EntityType.note,
            userId: 'test-user-7',
          ),
          data_rank_changeBy_: 'test-user-7',
          data_rank_cloudAt_: localDataRankCloudAt,
          data_deleted: false,
          data_deleted_dataSchemaRev_: 7,
          data_deleted_changeAt_: localDataDeletedChangeAt,
          data_deleted_cid_: generateCid(
            entityType: EntityType.note,
            userId: 'test-user-7',
          ),
          data_deleted_changeBy_: 'test-user-7',
          data_deleted_cloudAt_: localDataDeletedCloudAt,
          data_parentId: 'root',
          data_parentId_dataSchemaRev_: 7,
          data_parentId_changeAt_: localDataParentIdChangeAt,
          data_parentId_cid_: generateCid(
            entityType: EntityType.note,
            userId: 'test-user-7',
          ),
          data_parentId_changeBy_: 'test-user-7',
          data_parentId_cloudAt_: localDataParentIdCloudAt,
          data_parentProp: 'notes',
          data_parentProp_dataSchemaRev_: 7,
          data_parentProp_changeAt_: localDataParentPropChangeAt,
          data_parentProp_cid_: generateCid(
            entityType: EntityType.note,
            userId: 'test-user-7',
          ),
          data_parentProp_changeBy_: 'test-user-7',
          data_parentProp_cloudAt_: localDataParentPropCloudAt,
        );

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
        final storedState = DynamoNoteDataEntityState.fromJson(storedStateJson);

        expect(storedState, isA<DynamoNoteDataEntityState>());
        expectAllDateTimeFieldsUtc(
          storedState,
          expectedDataTitleChangeAt: localDataTitleChangeAt,
          expectedDataTitleCloudAt: localDataTitleCloudAt,
          expectedDataVideoCommentIdChangeAt: localDataVideoCommentIdChangeAt,
          expectedDataVideoCommentIdCloudAt: localDataVideoCommentIdCloudAt,
          expectedDataTextCommentChangeAt: localDataTextCommentChangeAt,
          expectedDataTextCommentCloudAt: localDataTextCommentCloudAt,
          expectedDataMarkerColorValueChangeAt:
              localDataMarkerColorValueChangeAt,
          expectedDataMarkerColorValueCloudAt: localDataMarkerColorValueCloudAt,
          expectedDataMarkerShapeChangeAt: localDataMarkerShapeChangeAt,
          expectedDataMarkerShapeCloudAt: localDataMarkerShapeCloudAt,
          expectedDataMarkerDescriptionChangeAt:
              localDataMarkerDescriptionChangeAt,
          expectedDataMarkerDescriptionCloudAt:
              localDataMarkerDescriptionCloudAt,
          expectedDataPositionMsChangeAt: localDataPositionMsChangeAt,
          expectedDataPositionMsCloudAt: localDataPositionMsCloudAt,
          expectedDataResolutionChangeAt: localDataResolutionChangeAt,
          expectedDataResolutionCloudAt: localDataResolutionCloudAt,
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

        final getUrl = baseUrl.replace(
          path:
              '${baseUrl.path}/api/state/projects/$testDomainId/notes/test-note-1',
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
        final retrieved = DynamoNoteDataEntityState.fromJson(
          retrievedStateJson,
        );

        expect(retrieved, isA<DynamoNoteDataEntityState>());

        expectAllDateTimeFieldsUtc(
          retrieved,
          expectedDataTitleChangeAt: localDataTitleChangeAt,
          expectedDataTitleCloudAt: localDataTitleCloudAt,
          expectedDataVideoCommentIdChangeAt: localDataVideoCommentIdChangeAt,
          expectedDataVideoCommentIdCloudAt: localDataVideoCommentIdCloudAt,
          expectedDataTextCommentChangeAt: localDataTextCommentChangeAt,
          expectedDataTextCommentCloudAt: localDataTextCommentCloudAt,
          expectedDataMarkerColorValueChangeAt:
              localDataMarkerColorValueChangeAt,
          expectedDataMarkerColorValueCloudAt: localDataMarkerColorValueCloudAt,
          expectedDataMarkerShapeChangeAt: localDataMarkerShapeChangeAt,
          expectedDataMarkerShapeCloudAt: localDataMarkerShapeCloudAt,
          expectedDataMarkerDescriptionChangeAt:
              localDataMarkerDescriptionChangeAt,
          expectedDataMarkerDescriptionCloudAt:
              localDataMarkerDescriptionCloudAt,
          expectedDataPositionMsChangeAt: localDataPositionMsChangeAt,
          expectedDataPositionMsCloudAt: localDataPositionMsCloudAt,
          expectedDataResolutionChangeAt: localDataResolutionChangeAt,
          expectedDataResolutionCloudAt: localDataResolutionCloudAt,
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
        expect(retrieved.data_title, equals(entry.data_title));
        expect(
          retrieved.data_title_dataSchemaRev_,
          equals(entry.data_title_dataSchemaRev_),
        );
        expect(retrieved.data_title_cid_, equals(entry.data_title_cid_));
        expect(
          retrieved.data_title_changeBy_,
          equals(entry.data_title_changeBy_),
        );
        expect(
          retrieved.data_videoCommentId,
          equals(entry.data_videoCommentId),
        );
        expect(
          retrieved.data_videoCommentId_dataSchemaRev_,
          equals(entry.data_videoCommentId_dataSchemaRev_),
        );
        expect(
          retrieved.data_videoCommentId_cid_,
          equals(entry.data_videoCommentId_cid_),
        );
        expect(
          retrieved.data_videoCommentId_changeBy_,
          equals(entry.data_videoCommentId_changeBy_),
        );
        expect(retrieved.data_textComment, equals(entry.data_textComment));
        expect(
          retrieved.data_textComment_dataSchemaRev_,
          equals(entry.data_textComment_dataSchemaRev_),
        );
        expect(
          retrieved.data_textComment_cid_,
          equals(entry.data_textComment_cid_),
        );
        expect(
          retrieved.data_textComment_changeBy_,
          equals(entry.data_textComment_changeBy_),
        );
        expect(
          retrieved.data_markerColorValue,
          equals(entry.data_markerColorValue),
        );
        expect(
          retrieved.data_markerColorValue_dataSchemaRev_,
          equals(entry.data_markerColorValue_dataSchemaRev_),
        );
        expect(
          retrieved.data_markerColorValue_cid_,
          equals(entry.data_markerColorValue_cid_),
        );
        expect(
          retrieved.data_markerColorValue_changeBy_,
          equals(entry.data_markerColorValue_changeBy_),
        );
        expect(retrieved.data_markerShape, equals(entry.data_markerShape));
        expect(
          retrieved.data_markerShape_dataSchemaRev_,
          equals(entry.data_markerShape_dataSchemaRev_),
        );
        expect(
          retrieved.data_markerShape_cid_,
          equals(entry.data_markerShape_cid_),
        );
        expect(
          retrieved.data_markerShape_changeBy_,
          equals(entry.data_markerShape_changeBy_),
        );
        expect(
          retrieved.data_markerDescription,
          equals(entry.data_markerDescription),
        );
        expect(
          retrieved.data_markerDescription_dataSchemaRev_,
          equals(entry.data_markerDescription_dataSchemaRev_),
        );
        expect(
          retrieved.data_markerDescription_cid_,
          equals(entry.data_markerDescription_cid_),
        );
        expect(
          retrieved.data_markerDescription_changeBy_,
          equals(entry.data_markerDescription_changeBy_),
        );
        expect(retrieved.data_positionMs, equals(entry.data_positionMs));
        expect(
          retrieved.data_positionMs_dataSchemaRev_,
          equals(entry.data_positionMs_dataSchemaRev_),
        );
        expect(
          retrieved.data_positionMs_cid_,
          equals(entry.data_positionMs_cid_),
        );
        expect(
          retrieved.data_positionMs_changeBy_,
          equals(entry.data_positionMs_changeBy_),
        );
        expect(retrieved.data_resolution, equals(entry.data_resolution));
        expect(
          retrieved.data_resolution_dataSchemaRev_,
          equals(entry.data_resolution_dataSchemaRev_),
        );
        expect(
          retrieved.data_resolution_cid_,
          equals(entry.data_resolution_cid_),
        );
        expect(
          retrieved.data_resolution_changeBy_,
          equals(entry.data_resolution_changeBy_),
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

        final json = retrieved.toJson();
        final jsonKeys = json.keys.toSet();

        for (final field in knownNoteDataEntityStateFields) {
          expect(
            jsonKeys.contains(field),
            isTrue,
            reason: 'Expected field $field to be in JSON',
          );
        }

        final unknownFields = jsonKeys.difference(
          knownNoteDataEntityStateFields,
        );
        expect(
          unknownFields,
          isEmpty,
          reason: 'Unexpected fields in JSON: $unknownFields',
        );

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
