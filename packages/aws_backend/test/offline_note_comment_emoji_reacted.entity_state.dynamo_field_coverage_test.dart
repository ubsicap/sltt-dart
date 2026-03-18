import 'package:aws_backend/src/models/note_comment_emoji_reacted.entity_state.dynamo.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
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
  }) {
    expect(state.change_changeAt, equals(expectedChangeAt.toUtc()));
    expect(state.change_changeAt_orig_, equals(expectedChangeAt.toUtc()));
    expect(state.change_cloudAt, equals(expectedCloudAt.toUtc()));
    expect(state.change_storedAt, equals(expectedStoredAt.toUtc()));
    expect(state.change_storedAt_orig_, equals(expectedStoredAt.toUtc()));
    expect(
      state.data_emoji_changeAt_,
      equals(expectedDataEmojiChangeAt.toUtc()),
    );
    expect(state.data_emoji_cloudAt_, equals(expectedDataEmojiCloudAt.toUtc()));
    expect(
      state.data_commentId_changeAt_,
      equals(expectedDataCommentIdChangeAt.toUtc()),
    );
    expect(
      state.data_commentId_cloudAt_,
      equals(expectedDataCommentIdCloudAt.toUtc()),
    );
    expect(
      state.data_noteId_changeAt_,
      equals(expectedDataNoteIdChangeAt.toUtc()),
    );
    expect(
      state.data_noteId_cloudAt_,
      equals(expectedDataNoteIdCloudAt.toUtc()),
    );
    expect(state.data_rank_changeAt_, equals(expectedDataRankChangeAt.toUtc()));
    expect(state.data_rank_cloudAt_, equals(expectedDataRankCloudAt.toUtc()));
    expect(
      state.data_deleted_changeAt_,
      equals(expectedDataDeletedChangeAt.toUtc()),
    );
    expect(
      state.data_deleted_cloudAt_,
      equals(expectedDataDeletedCloudAt.toUtc()),
    );
    expect(
      state.data_parentId_changeAt_,
      equals(expectedDataParentIdChangeAt.toUtc()),
    );
    expect(
      state.data_parentId_cloudAt_,
      equals(expectedDataParentIdCloudAt.toUtc()),
    );
    expect(
      state.data_parentProp_changeAt_,
      equals(expectedDataParentPropChangeAt.toUtc()),
    );
    expect(
      state.data_parentProp_cloudAt_,
      equals(expectedDataParentPropCloudAt.toUtc()),
    );
  }

  group(
    'offline - DynamoNoteCommentEmojiReactedDataEntityState field coverage',
    () {
      test('verifies all expected fields with UTC DateTime conversion', () {
        final localChangeAt = DateTime.now();
        final localCloudAt = DateTime.now().subtract(const Duration(hours: 1));
        final localStoredAt = DateTime.now().subtract(
          const Duration(minutes: 30),
        );
        final localDataChangeAt = DateTime.now().subtract(
          const Duration(hours: 2),
        );

        final state = DynamoNoteCommentEmojiReactedDataEntityState(
          entityId: 'reaction-1',
          domainType: 'project',
          unknownJson: '{}',
          stateDataHash: 'something',
          stateDataHash_orig_: 'something',
          schemaVersion: 1,
          change_domainId: 'project-1',
          change_domainId_orig_: 'project-1',
          change_changeAt: localChangeAt,
          change_changeAt_orig_: localChangeAt,
          change_storedAt: localStoredAt,
          change_storedAt_orig_: localStoredAt,
          change_cid: 'cid-1',
          change_cid_orig_: 'cid-1',
          change_dataSchemaRev: 1,
          change_cloudAt: localCloudAt,
          change_changeBy: 'user1',
          change_changeBy_orig_: 'user1',
          data_emoji: '👍',
          data_emoji_dataSchemaRev_: 1,
          data_emoji_changeAt_: localDataChangeAt,
          data_emoji_cid_: 'cid-emoji',
          data_emoji_changeBy_: 'user1',
          data_emoji_cloudAt_: localCloudAt,
          data_commentId: 'comment-1',
          data_commentId_dataSchemaRev_: 1,
          data_commentId_changeAt_: localDataChangeAt,
          data_commentId_cid_: 'cid-comment-id',
          data_commentId_changeBy_: 'user1',
          data_commentId_cloudAt_: localCloudAt,
          data_noteId: 'note-1',
          data_noteId_dataSchemaRev_: 1,
          data_noteId_changeAt_: localDataChangeAt,
          data_noteId_cid_: 'cid-note-id',
          data_noteId_changeBy_: 'user1',
          data_noteId_cloudAt_: localCloudAt,
          data_rank: 'aaaaz',
          data_rank_dataSchemaRev_: 1,
          data_rank_changeAt_: localDataChangeAt,
          data_rank_cid_: 'cid-rank',
          data_rank_changeBy_: 'user1',
          data_rank_cloudAt_: localCloudAt,
          data_deleted: false,
          data_deleted_dataSchemaRev_: 1,
          data_deleted_changeAt_: localDataChangeAt,
          data_deleted_cid_: 'cid-deleted',
          data_deleted_changeBy_: 'user1',
          data_deleted_cloudAt_: localCloudAt,
          data_parentId: 'note-1',
          data_parentId_dataSchemaRev_: 1,
          data_parentId_changeAt_: localDataChangeAt,
          data_parentId_cid_: 'cid-parent',
          data_parentId_changeBy_: 'user1',
          data_parentId_cloudAt_: localCloudAt,
          data_parentProp: kEntityTypeCommentReactionCollection,
          data_parentProp_dataSchemaRev_: 1,
          data_parentProp_changeAt_: localDataChangeAt,
          data_parentProp_cid_: 'cid-parent-prop',
          data_parentProp_changeBy_: 'user1',
          data_parentProp_cloudAt_: localCloudAt,
        );

        expectAllDateTimeFieldsUtc(
          state,
          expectedChangeAt: localChangeAt,
          expectedCloudAt: localCloudAt,
          expectedStoredAt: localStoredAt,
          expectedDataEmojiChangeAt: localDataChangeAt,
          expectedDataEmojiCloudAt: localCloudAt,
          expectedDataCommentIdChangeAt: localDataChangeAt,
          expectedDataCommentIdCloudAt: localCloudAt,
          expectedDataNoteIdChangeAt: localDataChangeAt,
          expectedDataNoteIdCloudAt: localCloudAt,
          expectedDataRankChangeAt: localDataChangeAt,
          expectedDataRankCloudAt: localCloudAt,
          expectedDataDeletedChangeAt: localDataChangeAt,
          expectedDataDeletedCloudAt: localCloudAt,
          expectedDataParentIdChangeAt: localDataChangeAt,
          expectedDataParentIdCloudAt: localCloudAt,
          expectedDataParentPropChangeAt: localDataChangeAt,
          expectedDataParentPropCloudAt: localCloudAt,
        );

        final jsonKeys = state.toJsonBase().keys.toSet();
        expect(jsonKeys, equals(knownCommentReactionDataEntityStateFields));

        final dateTimeFields = state
            .toJsonBase()
            .entries
            .where((e) => knownDateTimeFields.contains(e.key))
            .map((e) => e.value)
            .whereType<String>()
            .toList();
        for (final value in dateTimeFields) {
          expect(DateTime.parse(value).isUtc, isTrue);
        }
      });
    },
  );
}
