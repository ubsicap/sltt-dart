import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/src/models/note_comment_emoji_reacted.entity_state.dynamo.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'helpers/test_utils.dart';

void main() {
  final baseUrl = Uri.parse(
    Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl,
  );
  const testDomainId = '__test_comment_reaction_state_coverage';
  const testDomainType = 'project';

  const knownDateTimeFields = {
    'change_changeAt',
    'change_changeAt_orig_',
    'change_storedAt',
    'change_storedAt_orig_',
    'change_cloudAt',
    'data_emoji_changeAt_',
    'data_emoji_cloudAt_',
    'data_commentId_changeAt_',
    'data_commentId_cloudAt_',
    'data_noteId_changeAt_',
    'data_noteId_cloudAt_',
    'data_rank_changeAt_',
    'data_rank_cloudAt_',
    'data_deleted_changeAt_',
    'data_deleted_cloudAt_',
    'data_parentId_changeAt_',
    'data_parentId_cloudAt_',
    'data_parentProp_changeAt_',
    'data_parentProp_cloudAt_',
  };

  const knownCommentReactionDataEntityStateFields = {
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
    'data_emoji',
    'data_emoji_dataSchemaRev_',
    'data_emoji_changeAt_',
    'data_emoji_cid_',
    'data_emoji_changeBy_',
    'data_emoji_cloudAt_',
    'data_commentId',
    'data_commentId_dataSchemaRev_',
    'data_commentId_changeAt_',
    'data_commentId_cid_',
    'data_commentId_changeBy_',
    'data_commentId_cloudAt_',
    'data_noteId',
    'data_noteId_dataSchemaRev_',
    'data_noteId_changeAt_',
    'data_noteId_cid_',
    'data_noteId_changeBy_',
    'data_noteId_cloudAt_',
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
    DynamoNoteCommentEmojiReactedDataEntityState state, {
    required DateTime expectedChangeAt,
    required DateTime expectedCloudAt,
    required DateTime expectedStoredAt,
    required DateTime expectedDataEmojiChangeAt,
    required DateTime expectedDataEmojiCloudAt,
    required DateTime expectedDataCommentIdChangeAt,
    required DateTime expectedDataCommentIdCloudAt,
    required DateTime expectedDataNoteIdChangeAt,
    required DateTime expectedDataNoteIdCloudAt,
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
      state.data_emoji_changeAt_,
      equals(expectedDataEmojiChangeAt.toUtc()),
      reason: '${prefix}data_emoji_changeAt_ should be UTC',
    );
    expect(
      state.data_emoji_cloudAt_,
      equals(expectedDataEmojiCloudAt.toUtc()),
      reason: '${prefix}data_emoji_cloudAt_ should be UTC',
    );
    expect(
      state.data_commentId_changeAt_,
      equals(expectedDataCommentIdChangeAt.toUtc()),
      reason: '${prefix}data_commentId_changeAt_ should be UTC',
    );
    expect(
      state.data_commentId_cloudAt_,
      equals(expectedDataCommentIdCloudAt.toUtc()),
      reason: '${prefix}data_commentId_cloudAt_ should be UTC',
    );
    expect(
      state.data_noteId_changeAt_,
      equals(expectedDataNoteIdChangeAt.toUtc()),
      reason: '${prefix}data_noteId_changeAt_ should be UTC',
    );
    expect(
      state.data_noteId_cloudAt_,
      equals(expectedDataNoteIdCloudAt.toUtc()),
      reason: '${prefix}data_noteId_cloudAt_ should be UTC',
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

  group(
    'storeState and getEntityState - DynamoNoteCommentEmojiReactedDataEntityState',
    () {
      test(
        'stores and retrieves with all expected fields - DynamoNoteCommentEmojiReactedDataEntityState',
        () async {
          await resetTestProject(baseUrl, testDomainId);

          final localChangeAt = DateTime.now();
          final localCloudAt = DateTime.now().subtract(
            const Duration(hours: 1),
          );
          final localStoredAt = DateTime.now().subtract(
            const Duration(minutes: 30),
          );
          final localDataEmojiChangeAt = DateTime.now().subtract(
            const Duration(minutes: 15),
          );
          final localDataEmojiCloudAt = DateTime.now().subtract(
            const Duration(minutes: 18),
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
            entityType: EntityType.commentReaction,
            userId: 'test-user-1',
          );

          final entry = DynamoNoteCommentEmojiReactedDataEntityState(
            entityId: 'test-reaction-1',
            entityType: kEntityTypeCommentReaction,
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
              entityType: EntityType.commentReaction,
              userId: 'test-user-7',
            ),
            change_cid_orig_: cidOrig,
            change_dataSchemaRev: 7,
            change_cloudAt: localCloudAt,
            change_changeBy: 'test-user-7',
            change_changeBy_orig_: 'test-user-1',
            data_emoji: '👍',
            data_emoji_dataSchemaRev_: 7,
            data_emoji_changeAt_: localDataEmojiChangeAt,
            data_emoji_cid_: generateCid(
              entityType: EntityType.commentReaction,
              userId: 'test-user-7',
            ),
            data_emoji_changeBy_: 'test-user-7',
            data_emoji_cloudAt_: localDataEmojiCloudAt,
            data_commentId: 'comment-1',
            data_commentId_dataSchemaRev_: 7,
            data_commentId_changeAt_: localDataEmojiChangeAt,
            data_commentId_cid_: generateCid(
              entityType: EntityType.commentReaction,
              userId: 'test-user-7',
            ),
            data_commentId_changeBy_: 'test-user-7',
            data_commentId_cloudAt_: localDataEmojiCloudAt,
            data_noteId: 'note-1',
            data_noteId_dataSchemaRev_: 7,
            data_noteId_changeAt_: localDataEmojiChangeAt,
            data_noteId_cid_: generateCid(
              entityType: EntityType.commentReaction,
              userId: 'test-user-7',
            ),
            data_noteId_changeBy_: 'test-user-7',
            data_noteId_cloudAt_: localDataEmojiCloudAt,
            data_rank: 'aaaaz',
            data_rank_dataSchemaRev_: 7,
            data_rank_changeAt_: localDataRankChangeAt,
            data_rank_cid_: generateCid(
              entityType: EntityType.commentReaction,
              userId: 'test-user-7',
            ),
            data_rank_changeBy_: 'test-user-7',
            data_rank_cloudAt_: localDataRankCloudAt,
            data_deleted: false,
            data_deleted_dataSchemaRev_: 7,
            data_deleted_changeAt_: localDataDeletedChangeAt,
            data_deleted_cid_: generateCid(
              entityType: EntityType.commentReaction,
              userId: 'test-user-7',
            ),
            data_deleted_changeBy_: 'test-user-7',
            data_deleted_cloudAt_: localDataDeletedCloudAt,
            data_parentId: 'note-1',
            data_parentId_dataSchemaRev_: 7,
            data_parentId_changeAt_: localDataParentIdChangeAt,
            data_parentId_cid_: generateCid(
              entityType: EntityType.commentReaction,
              userId: 'test-user-7',
            ),
            data_parentId_changeBy_: 'test-user-7',
            data_parentId_cloudAt_: localDataParentIdCloudAt,
            data_parentProp: kEntityTypeCommentReactionCollection,
            data_parentProp_dataSchemaRev_: 7,
            data_parentProp_changeAt_: localDataParentPropChangeAt,
            data_parentProp_cid_: generateCid(
              entityType: EntityType.commentReaction,
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
          final storedState =
              DynamoNoteCommentEmojiReactedDataEntityState.fromJson(
                storedStateJson,
              );

          expect(
            storedState,
            isA<DynamoNoteCommentEmojiReactedDataEntityState>(),
          );
          expectAllDateTimeFieldsUtc(
            storedState,
            expectedDataEmojiChangeAt: localDataEmojiChangeAt,
            expectedDataEmojiCloudAt: localDataEmojiCloudAt,
            expectedDataCommentIdChangeAt: localDataEmojiChangeAt,
            expectedDataCommentIdCloudAt: localDataEmojiCloudAt,
            expectedDataNoteIdChangeAt: localDataEmojiChangeAt,
            expectedDataNoteIdCloudAt: localDataEmojiCloudAt,
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
                '${baseUrl.path}/api/state/projects/$testDomainId/comment_reactions/test-reaction-1',
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
          final retrieved =
              DynamoNoteCommentEmojiReactedDataEntityState.fromJson(
                retrievedStateJson,
              );

          expect(
            retrieved,
            isA<DynamoNoteCommentEmojiReactedDataEntityState>(),
          );

          expectAllDateTimeFieldsUtc(
            retrieved,
            expectedDataEmojiChangeAt: localDataEmojiChangeAt,
            expectedDataEmojiCloudAt: localDataEmojiCloudAt,
            expectedDataCommentIdChangeAt: localDataEmojiChangeAt,
            expectedDataCommentIdCloudAt: localDataEmojiCloudAt,
            expectedDataNoteIdChangeAt: localDataEmojiChangeAt,
            expectedDataNoteIdCloudAt: localDataEmojiCloudAt,
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
          expect(retrieved.data_emoji, equals(entry.data_emoji));
          expect(retrieved.data_commentId, equals(entry.data_commentId));
          expect(retrieved.data_noteId, equals(entry.data_noteId));
          expect(
            retrieved.data_emoji_dataSchemaRev_,
            equals(entry.data_emoji_dataSchemaRev_),
          );
          expect(retrieved.data_emoji_cid_, equals(entry.data_emoji_cid_));
          expect(
            retrieved.data_emoji_changeBy_,
            equals(entry.data_emoji_changeBy_),
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
          expect(
            retrieved.data_parentId_cid_,
            equals(entry.data_parentId_cid_),
          );
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

          for (final field in knownCommentReactionDataEntityStateFields) {
            expect(
              jsonKeys.contains(field),
              isTrue,
              reason: 'Expected field $field to be in JSON',
            );
          }

          final unknownFields = jsonKeys.difference(
            knownCommentReactionDataEntityStateFields,
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
    },
  );
}
