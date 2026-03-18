import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/src/models/note_comment_chat.entity_state.dynamo.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'helpers/test_utils.dart';

void main() {
  final baseUrl = Uri.parse(
    Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl,
  );
  const testDomainId = '__test_comment_chat_state_coverage';
  const testDomainType = 'project';

  const knownDateTimeFields = {
    'change_changeAt',
    'change_changeAt_orig_',
    'change_storedAt',
    'change_storedAt_orig_',
    'change_cloudAt',
    'data_text_changeAt_',
    'data_text_cloudAt_',
    'data_videoStoredFilename_changeAt_',
    'data_videoStoredFilename_cloudAt_',
    'data_videoDurationMs_changeAt_',
    'data_videoDurationMs_cloudAt_',
    'data_dateMs_changeAt_',
    'data_dateMs_cloudAt_',
    'data_visibleToUserIds_changeAt_',
    'data_visibleToUserIds_cloudAt_',
    'data_notifiedUserIds_changeAt_',
    'data_notifiedUserIds_cloudAt_',
    'data_rank_changeAt_',
    'data_rank_cloudAt_',
    'data_deleted_changeAt_',
    'data_deleted_cloudAt_',
    'data_parentId_changeAt_',
    'data_parentId_cloudAt_',
    'data_parentProp_changeAt_',
    'data_parentProp_cloudAt_',
  };

  const knownCommentChatDataEntityStateFields = {
    'entityId',
    'entityType',
    'domainType',
    'unknownJson',
    'schemaVersion',
    'stateDataHash',
    'stateDataHash_orig_',
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
    'data_text',
    'data_text_dataSchemaRev_',
    'data_text_changeAt_',
    'data_text_cid_',
    'data_text_changeBy_',
    'data_text_cloudAt_',
    'data_videoStoredFilename',
    'data_videoStoredFilename_dataSchemaRev_',
    'data_videoStoredFilename_changeAt_',
    'data_videoStoredFilename_cid_',
    'data_videoStoredFilename_changeBy_',
    'data_videoStoredFilename_cloudAt_',
    'data_videoDurationMs',
    'data_videoDurationMs_dataSchemaRev_',
    'data_videoDurationMs_changeAt_',
    'data_videoDurationMs_cid_',
    'data_videoDurationMs_changeBy_',
    'data_videoDurationMs_cloudAt_',
    'data_dateMs',
    'data_dateMs_dataSchemaRev_',
    'data_dateMs_changeAt_',
    'data_dateMs_cid_',
    'data_dateMs_changeBy_',
    'data_dateMs_cloudAt_',
    'data_visibleToUserIds',
    'data_visibleToUserIds_dataSchemaRev_',
    'data_visibleToUserIds_changeAt_',
    'data_visibleToUserIds_cid_',
    'data_visibleToUserIds_changeBy_',
    'data_visibleToUserIds_cloudAt_',
    'data_notifiedUserIds',
    'data_notifiedUserIds_dataSchemaRev_',
    'data_notifiedUserIds_changeAt_',
    'data_notifiedUserIds_cid_',
    'data_notifiedUserIds_changeBy_',
    'data_notifiedUserIds_cloudAt_',
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
    DynamoNoteCommentChatDataEntityState state, {
    required DateTime expectedChangeAt,
    required DateTime expectedCloudAt,
    required DateTime expectedStoredAt,
    required DateTime expectedDataTextChangeAt,
    required DateTime expectedDataTextCloudAt,
    required DateTime expectedDataVideoStoredFilenameChangeAt,
    required DateTime expectedDataVideoStoredFilenameCloudAt,
    required DateTime expectedDataVideoDurationMsChangeAt,
    required DateTime expectedDataVideoDurationMsCloudAt,
    required DateTime expectedDataDateMsChangeAt,
    required DateTime expectedDataDateMsCloudAt,
    required DateTime expectedDataVisibleToChangeAt,
    required DateTime expectedDataVisibleToCloudAt,
    required DateTime expectedDataNotifiedChangeAt,
    required DateTime expectedDataNotifiedCloudAt,
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
      state.data_text_changeAt_,
      equals(expectedDataTextChangeAt.toUtc()),
      reason: '${prefix}data_text_changeAt_ should be UTC',
    );
    expect(
      state.data_text_cloudAt_,
      equals(expectedDataTextCloudAt.toUtc()),
      reason: '${prefix}data_text_cloudAt_ should be UTC',
    );
    expect(
      state.data_videoStoredFilename_changeAt_,
      equals(expectedDataVideoStoredFilenameChangeAt.toUtc()),
      reason: '${prefix}data_videoStoredFilename_changeAt_ should be UTC',
    );
    expect(
      state.data_videoStoredFilename_cloudAt_,
      equals(expectedDataVideoStoredFilenameCloudAt.toUtc()),
      reason: '${prefix}data_videoStoredFilename_cloudAt_ should be UTC',
    );
    expect(
      state.data_videoDurationMs_changeAt_,
      equals(expectedDataVideoDurationMsChangeAt.toUtc()),
      reason: '${prefix}data_videoDurationMs_changeAt_ should be UTC',
    );
    expect(
      state.data_videoDurationMs_cloudAt_,
      equals(expectedDataVideoDurationMsCloudAt.toUtc()),
      reason: '${prefix}data_videoDurationMs_cloudAt_ should be UTC',
    );
    expect(
      state.data_dateMs_changeAt_,
      equals(expectedDataDateMsChangeAt.toUtc()),
      reason: '${prefix}data_dateMs_changeAt_ should be UTC',
    );
    expect(
      state.data_dateMs_cloudAt_,
      equals(expectedDataDateMsCloudAt.toUtc()),
      reason: '${prefix}data_dateMs_cloudAt_ should be UTC',
    );
    expect(
      state.data_visibleToUserIds_changeAt_,
      equals(expectedDataVisibleToChangeAt.toUtc()),
      reason: '${prefix}data_visibleToUserIds_changeAt_ should be UTC',
    );
    expect(
      state.data_visibleToUserIds_cloudAt_,
      equals(expectedDataVisibleToCloudAt.toUtc()),
      reason: '${prefix}data_visibleToUserIds_cloudAt_ should be UTC',
    );
    expect(
      state.data_notifiedUserIds_changeAt_,
      equals(expectedDataNotifiedChangeAt.toUtc()),
      reason: '${prefix}data_notifiedUserIds_changeAt_ should be UTC',
    );
    expect(
      state.data_notifiedUserIds_cloudAt_,
      equals(expectedDataNotifiedCloudAt.toUtc()),
      reason: '${prefix}data_notifiedUserIds_cloudAt_ should be UTC',
    );

    expect(
      state.change_changeAt,
      equals(expectedChangeAt.toUtc()),
      reason: '${prefix}change_changeAt should be UTC',
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

  group('storeState and getEntityState - DynamoNoteCommentChatDataEntityState', () {
    test(
      'stores and retrieves with all expected fields - DynamoNoteCommentChatDataEntityState',
      () async {
        await resetTestDomainData(baseUrl, testDomainId);

        final localChangeAt = DateTime.now();
        final localCloudAt = DateTime.now().subtract(const Duration(hours: 1));
        final localStoredAt = DateTime.now().subtract(
          const Duration(minutes: 30),
        );
        final localDataTextChangeAt = DateTime.now().subtract(
          const Duration(minutes: 15),
        );
        final localDataTextCloudAt = DateTime.now().subtract(
          const Duration(minutes: 18),
        );
        final localDataVideoStoredFilenameChangeAt = DateTime.now().subtract(
          const Duration(minutes: 16),
        );
        final localDataVideoStoredFilenameCloudAt = DateTime.now().subtract(
          const Duration(minutes: 19),
        );
        final localDataVideoDurationMsChangeAt =
            localDataVideoStoredFilenameChangeAt;
        final localDataVideoDurationMsCloudAt =
            localDataVideoStoredFilenameCloudAt;
        final localDataDateMsChangeAt = DateTime.now().subtract(
          const Duration(minutes: 14),
        );
        final localDataDateMsCloudAt = DateTime.now().subtract(
          const Duration(minutes: 17),
        );
        final localDataVisibleToChangeAt = DateTime.now().subtract(
          const Duration(minutes: 22),
        );
        final localDataVisibleToCloudAt = DateTime.now().subtract(
          const Duration(minutes: 27),
        );
        final localDataNotifiedChangeAt = DateTime.now().subtract(
          const Duration(minutes: 20),
        );
        final localDataNotifiedCloudAt = DateTime.now().subtract(
          const Duration(minutes: 25),
        );
        final localDataRankChangeAt = DateTime.now().subtract(
          const Duration(minutes: 12),
        );
        final localDataRankCloudAt = DateTime.now().subtract(
          const Duration(minutes: 13),
        );
        final localDataDeletedChangeAt = DateTime.now().subtract(
          const Duration(minutes: 11),
        );
        final localDataDeletedCloudAt = DateTime.now().subtract(
          const Duration(minutes: 9),
        );
        final localDataParentIdChangeAt = DateTime.now().subtract(
          const Duration(minutes: 10),
        );
        final localDataParentIdCloudAt = DateTime.now().subtract(
          const Duration(minutes: 8),
        );
        final localDataParentPropChangeAt = DateTime.now().subtract(
          const Duration(minutes: 5),
        );
        final localDataParentPropCloudAt = DateTime.now().subtract(
          const Duration(minutes: 7),
        );

        final cidOrig = generateCid(
          entityType: EntityType.comment,
          userId: 'test-user-1',
        );

        final entry = DynamoNoteCommentChatDataEntityState(
          entityId: 'test-comment-1',
          entityType: kEntityTypeComment,
          domainType: testDomainType,
          unknownJson: '{}',
          stateDataHash: null,
          stateDataHash_orig_: null,
          schemaVersion: 1,
          change_domainId: testDomainId,
          change_domainId_orig_: testDomainId,
          change_changeAt: localChangeAt,
          change_changeAt_orig_: localChangeAt,
          change_storedAt: localStoredAt,
          change_storedAt_orig_: localStoredAt,
          change_cid: generateCid(
            entityType: EntityType.comment,
            userId: 'test-user-7',
          ),
          change_cid_orig_: cidOrig,
          change_dataSchemaRev: 7,
          change_cloudAt: localCloudAt,
          change_changeBy: 'test-user-7',
          change_changeBy_orig_: 'test-user-1',
          data_text: 'Hello',
          data_text_dataSchemaRev_: 7,
          data_text_changeAt_: localDataTextChangeAt,
          data_text_cid_: generateCid(
            entityType: EntityType.comment,
            userId: 'test-user-7',
          ),
          data_text_changeBy_: 'test-user-7',
          data_text_cloudAt_: localDataTextCloudAt,
          data_videoStoredFilename: 'video-id-1',
          data_videoStoredFilename_dataSchemaRev_: 7,
          data_videoStoredFilename_changeAt_:
              localDataVideoStoredFilenameChangeAt,
          data_videoStoredFilename_cid_: generateCid(
            entityType: EntityType.comment,
            userId: 'test-user-7',
          ),
          data_videoStoredFilename_changeBy_: 'test-user-7',
          data_videoStoredFilename_cloudAt_:
              localDataVideoStoredFilenameCloudAt,
          data_videoDurationMs: 1500,
          data_videoDurationMs_dataSchemaRev_: 7,
          data_videoDurationMs_changeAt_: localDataVideoDurationMsChangeAt,
          data_videoDurationMs_cid_: generateCid(
            entityType: EntityType.comment,
            userId: 'test-user-7',
          ),
          data_videoDurationMs_changeBy_: 'test-user-7',
          data_videoDurationMs_cloudAt_: localDataVideoDurationMsCloudAt,
          data_dateMs: 1234,
          data_dateMs_dataSchemaRev_: 7,
          data_dateMs_changeAt_: localDataDateMsChangeAt,
          data_dateMs_cid_: generateCid(
            entityType: EntityType.comment,
            userId: 'test-user-7',
          ),
          data_dateMs_changeBy_: 'test-user-7',
          data_dateMs_cloudAt_: localDataDateMsCloudAt,
          data_visibleToUserIds: ['test-user-7'],
          data_visibleToUserIds_dataSchemaRev_: 7,
          data_visibleToUserIds_changeAt_: localDataVisibleToChangeAt,
          data_visibleToUserIds_cid_: generateCid(
            entityType: EntityType.comment,
            userId: 'test-user-7',
          ),
          data_visibleToUserIds_changeBy_: 'test-user-7',
          data_visibleToUserIds_cloudAt_: localDataVisibleToCloudAt,
          data_notifiedUserIds: ['test-user-9'],
          data_notifiedUserIds_dataSchemaRev_: 7,
          data_notifiedUserIds_changeAt_: localDataNotifiedChangeAt,
          data_notifiedUserIds_cid_: generateCid(
            entityType: EntityType.comment,
            userId: 'test-user-7',
          ),
          data_notifiedUserIds_changeBy_: 'test-user-7',
          data_notifiedUserIds_cloudAt_: localDataNotifiedCloudAt,
          data_rank: 'aaaaz',
          data_rank_dataSchemaRev_: 7,
          data_rank_changeAt_: localDataRankChangeAt,
          data_rank_cid_: generateCid(
            entityType: EntityType.comment,
            userId: 'test-user-7',
          ),
          data_rank_changeBy_: 'test-user-7',
          data_rank_cloudAt_: localDataRankCloudAt,
          data_deleted: false,
          data_deleted_dataSchemaRev_: 7,
          data_deleted_changeAt_: localDataDeletedChangeAt,
          data_deleted_cid_: generateCid(
            entityType: EntityType.comment,
            userId: 'test-user-7',
          ),
          data_deleted_changeBy_: 'test-user-7',
          data_deleted_cloudAt_: localDataDeletedCloudAt,
          data_parentId: 'note-1',
          data_parentId_dataSchemaRev_: 7,
          data_parentId_changeAt_: localDataParentIdChangeAt,
          data_parentId_cid_: generateCid(
            entityType: EntityType.comment,
            userId: 'test-user-7',
          ),
          data_parentId_changeBy_: 'test-user-7',
          data_parentId_cloudAt_: localDataParentIdCloudAt,
          data_parentProp: kEntityTypeCommentCollection,
          data_parentProp_dataSchemaRev_: 7,
          data_parentProp_changeAt_: localDataParentPropChangeAt,
          data_parentProp_cid_: generateCid(
            entityType: EntityType.comment,
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
        final storedState = DynamoNoteCommentChatDataEntityState.fromJson(
          storedStateJson,
        );

        expect(storedState, isA<DynamoNoteCommentChatDataEntityState>());
        expectAllDateTimeFieldsUtc(
          storedState,
          expectedDataTextChangeAt: localDataTextChangeAt,
          expectedDataTextCloudAt: localDataTextCloudAt,
          expectedDataVideoStoredFilenameChangeAt:
              localDataVideoStoredFilenameChangeAt,
          expectedDataVideoStoredFilenameCloudAt:
              localDataVideoStoredFilenameCloudAt,
          expectedDataVideoDurationMsChangeAt: localDataVideoDurationMsChangeAt,
          expectedDataVideoDurationMsCloudAt: localDataVideoDurationMsCloudAt,
          expectedDataDateMsChangeAt: localDataDateMsChangeAt,
          expectedDataDateMsCloudAt: localDataDateMsCloudAt,
          expectedDataVisibleToChangeAt: localDataVisibleToChangeAt,
          expectedDataVisibleToCloudAt: localDataVisibleToCloudAt,
          expectedDataNotifiedChangeAt: localDataNotifiedChangeAt,
          expectedDataNotifiedCloudAt: localDataNotifiedCloudAt,
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
              '${baseUrl.path}/api/state/projects/$testDomainId/comments/test-comment-1',
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
        final retrieved = DynamoNoteCommentChatDataEntityState.fromJson(
          retrievedStateJson,
        );

        expect(retrieved, isA<DynamoNoteCommentChatDataEntityState>());

        expectAllDateTimeFieldsUtc(
          retrieved,
          expectedDataTextChangeAt: localDataTextChangeAt,
          expectedDataTextCloudAt: localDataTextCloudAt,
          expectedDataVideoStoredFilenameChangeAt:
              localDataVideoStoredFilenameChangeAt,
          expectedDataVideoStoredFilenameCloudAt:
              localDataVideoStoredFilenameCloudAt,
          expectedDataVideoDurationMsChangeAt: localDataVideoDurationMsChangeAt,
          expectedDataVideoDurationMsCloudAt: localDataVideoDurationMsCloudAt,
          expectedDataDateMsChangeAt: localDataDateMsChangeAt,
          expectedDataDateMsCloudAt: localDataDateMsCloudAt,
          expectedDataVisibleToChangeAt: localDataVisibleToChangeAt,
          expectedDataVisibleToCloudAt: localDataVisibleToCloudAt,
          expectedDataNotifiedChangeAt: localDataNotifiedChangeAt,
          expectedDataNotifiedCloudAt: localDataNotifiedCloudAt,
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
        expect(retrieved.data_text, equals(entry.data_text));
        expect(
          retrieved.data_text_dataSchemaRev_,
          equals(entry.data_text_dataSchemaRev_),
        );
        expect(retrieved.data_text_cid_, equals(entry.data_text_cid_));
        expect(
          retrieved.data_text_changeBy_,
          equals(entry.data_text_changeBy_),
        );
        expect(
          retrieved.data_videoStoredFilename,
          equals(entry.data_videoStoredFilename),
        );
        expect(
          retrieved.data_videoStoredFilename_dataSchemaRev_,
          equals(entry.data_videoStoredFilename_dataSchemaRev_),
        );
        expect(
          retrieved.data_videoStoredFilename_cid_,
          equals(entry.data_videoStoredFilename_cid_),
        );
        expect(
          retrieved.data_videoStoredFilename_changeBy_,
          equals(entry.data_videoStoredFilename_changeBy_),
        );
        expect(
          retrieved.data_videoDurationMs,
          equals(entry.data_videoDurationMs),
        );
        expect(
          retrieved.data_videoDurationMs_dataSchemaRev_,
          equals(entry.data_videoDurationMs_dataSchemaRev_),
        );
        expect(
          retrieved.data_videoDurationMs_cid_,
          equals(entry.data_videoDurationMs_cid_),
        );
        expect(
          retrieved.data_videoDurationMs_changeBy_,
          equals(entry.data_videoDurationMs_changeBy_),
        );
        expect(retrieved.data_dateMs, equals(entry.data_dateMs));
        expect(
          retrieved.data_dateMs_dataSchemaRev_,
          equals(entry.data_dateMs_dataSchemaRev_),
        );
        expect(retrieved.data_dateMs_cid_, equals(entry.data_dateMs_cid_));
        expect(
          retrieved.data_dateMs_changeBy_,
          equals(entry.data_dateMs_changeBy_),
        );
        expect(
          retrieved.data_visibleToUserIds,
          equals(entry.data_visibleToUserIds),
        );
        expect(
          retrieved.data_visibleToUserIds_dataSchemaRev_,
          equals(entry.data_visibleToUserIds_dataSchemaRev_),
        );
        expect(
          retrieved.data_visibleToUserIds_cid_,
          equals(entry.data_visibleToUserIds_cid_),
        );
        expect(
          retrieved.data_visibleToUserIds_changeBy_,
          equals(entry.data_visibleToUserIds_changeBy_),
        );
        expect(
          retrieved.data_notifiedUserIds,
          equals(entry.data_notifiedUserIds),
        );
        expect(
          retrieved.data_notifiedUserIds_dataSchemaRev_,
          equals(entry.data_notifiedUserIds_dataSchemaRev_),
        );
        expect(
          retrieved.data_notifiedUserIds_cid_,
          equals(entry.data_notifiedUserIds_cid_),
        );
        expect(
          retrieved.data_notifiedUserIds_changeBy_,
          equals(entry.data_notifiedUserIds_changeBy_),
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

        for (final field in knownCommentChatDataEntityStateFields) {
          expect(
            jsonKeys.contains(field),
            isTrue,
            reason: 'Expected field $field to be in JSON',
          );
        }

        final unknownFields = jsonKeys.difference(
          knownCommentChatDataEntityStateFields,
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
