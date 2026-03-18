import 'package:aws_backend/src/models/note_comment_chat.entity_state.dynamo.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
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
  }) {
    expect(state.change_changeAt, equals(expectedChangeAt.toUtc()));
    expect(state.change_changeAt_orig_, equals(expectedChangeAt.toUtc()));
    expect(state.change_cloudAt, equals(expectedCloudAt.toUtc()));
    expect(state.change_storedAt, equals(expectedStoredAt.toUtc()));
    expect(state.change_storedAt_orig_, equals(expectedStoredAt.toUtc()));
    expect(state.data_text_changeAt_, equals(expectedDataTextChangeAt.toUtc()));
    expect(state.data_text_cloudAt_, equals(expectedDataTextCloudAt.toUtc()));
    expect(
      state.data_videoStoredFilename_changeAt_,
      equals(expectedDataVideoStoredFilenameChangeAt.toUtc()),
    );
    expect(
      state.data_videoStoredFilename_cloudAt_,
      equals(expectedDataVideoStoredFilenameCloudAt.toUtc()),
    );
    expect(
      state.data_videoDurationMs_changeAt_,
      equals(expectedDataVideoDurationMsChangeAt.toUtc()),
    );
    expect(
      state.data_videoDurationMs_cloudAt_,
      equals(expectedDataVideoDurationMsCloudAt.toUtc()),
    );
    expect(
      state.data_dateMs_changeAt_,
      equals(expectedDataDateMsChangeAt.toUtc()),
    );
    expect(
      state.data_dateMs_cloudAt_,
      equals(expectedDataDateMsCloudAt.toUtc()),
    );
    expect(
      state.data_visibleToUserIds_changeAt_,
      equals(expectedDataVisibleToChangeAt.toUtc()),
    );
    expect(
      state.data_visibleToUserIds_cloudAt_,
      equals(expectedDataVisibleToCloudAt.toUtc()),
    );
    expect(
      state.data_notifiedUserIds_changeAt_,
      equals(expectedDataNotifiedChangeAt.toUtc()),
    );
    expect(
      state.data_notifiedUserIds_cloudAt_,
      equals(expectedDataNotifiedCloudAt.toUtc()),
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

  group('offline - DynamoNoteCommentChatDataEntityState field coverage', () {
    test('verifies all expected fields with UTC DateTime conversion', () {
      final localChangeAt = DateTime.now();
      final localCloudAt = DateTime.now().subtract(const Duration(hours: 1));
      final localStoredAt = DateTime.now().subtract(
        const Duration(minutes: 30),
      );
      final localDataChangeAt = DateTime.now().subtract(
        const Duration(hours: 2),
      );

      final state = DynamoNoteCommentChatDataEntityState(
        entityId: 'comment-1',
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
        data_text: 'Hello',
        data_text_dataSchemaRev_: 1,
        data_text_changeAt_: localDataChangeAt,
        data_text_cid_: 'cid-text',
        data_text_changeBy_: 'user1',
        data_text_cloudAt_: localCloudAt,
        data_videoStoredFilename: 'video-id-1',
        data_videoStoredFilename_dataSchemaRev_: 1,
        data_videoStoredFilename_changeAt_: localDataChangeAt,
        data_videoStoredFilename_cid_: 'cid-video',
        data_videoStoredFilename_changeBy_: 'user1',
        data_videoStoredFilename_cloudAt_: localCloudAt,
        data_videoDurationMs: 1500,
        data_videoDurationMs_dataSchemaRev_: 1,
        data_videoDurationMs_changeAt_: localDataChangeAt,
        data_videoDurationMs_cid_: 'cid-video',
        data_videoDurationMs_changeBy_: 'user1',
        data_videoDurationMs_cloudAt_: localCloudAt,
        data_dateMs: 1234,
        data_dateMs_dataSchemaRev_: 1,
        data_dateMs_changeAt_: localDataChangeAt,
        data_dateMs_cid_: 'cid-date',
        data_dateMs_changeBy_: 'user1',
        data_dateMs_cloudAt_: localCloudAt,
        data_visibleToUserIds: ['user2'],
        data_visibleToUserIds_dataSchemaRev_: 1,
        data_visibleToUserIds_changeAt_: localDataChangeAt,
        data_visibleToUserIds_cid_: 'cid-visible',
        data_visibleToUserIds_changeBy_: 'user1',
        data_visibleToUserIds_cloudAt_: localCloudAt,
        data_notifiedUserIds: ['user3'],
        data_notifiedUserIds_dataSchemaRev_: 1,
        data_notifiedUserIds_changeAt_: localDataChangeAt,
        data_notifiedUserIds_cid_: 'cid-notified',
        data_notifiedUserIds_changeBy_: 'user1',
        data_notifiedUserIds_cloudAt_: localCloudAt,
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
        data_parentProp: kEntityTypeCommentCollection,
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
        expectedDataTextChangeAt: localDataChangeAt,
        expectedDataTextCloudAt: localCloudAt,
        expectedDataVideoStoredFilenameChangeAt: localDataChangeAt,
        expectedDataVideoStoredFilenameCloudAt: localCloudAt,
        expectedDataVideoDurationMsChangeAt: localDataChangeAt,
        expectedDataVideoDurationMsCloudAt: localCloudAt,
        expectedDataDateMsChangeAt: localDataChangeAt,
        expectedDataDateMsCloudAt: localCloudAt,
        expectedDataVisibleToChangeAt: localDataChangeAt,
        expectedDataVisibleToCloudAt: localCloudAt,
        expectedDataNotifiedChangeAt: localDataChangeAt,
        expectedDataNotifiedCloudAt: localCloudAt,
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
      expect(jsonKeys, equals(knownCommentChatDataEntityStateFields));

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
  });
}
