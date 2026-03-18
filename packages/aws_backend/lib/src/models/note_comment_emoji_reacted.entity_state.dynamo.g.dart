// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_comment_emoji_reacted.entity_state.dynamo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamoNoteCommentEmojiReactedDataEntityState
_$DynamoNoteCommentEmojiReactedDataEntityStateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DynamoNoteCommentEmojiReactedDataEntityState', json, (
  $checkedConvert,
) {
  final val = DynamoNoteCommentEmojiReactedDataEntityState(
    schemaVersion: $checkedConvert(
      'schemaVersion',
      (v) => (v as num?)?.toInt(),
    ),
    entityType: $checkedConvert(
      'entityType',
      (v) => v as String? ?? kEntityTypeCommentReaction,
    ),
    entityId: $checkedConvert('entityId', (v) => v as String),
    domainType: $checkedConvert('domainType', (v) => v as String),
    change_domainId: $checkedConvert('change_domainId', (v) => v as String),
    change_domainId_orig_: $checkedConvert(
      'change_domainId_orig_',
      (v) => v as String,
    ),
    change_changeAt: $checkedConvert(
      'change_changeAt',
      (v) => DateTime.parse(v as String),
    ),
    change_changeAt_orig_: $checkedConvert(
      'change_changeAt_orig_',
      (v) => DateTime.parse(v as String),
    ),
    change_storedAt: $checkedConvert(
      'change_storedAt',
      (v) => DateTime.parse(v as String),
    ),
    change_storedAt_orig_: $checkedConvert(
      'change_storedAt_orig_',
      (v) => DateTime.parse(v as String),
    ),
    change_cid: $checkedConvert('change_cid', (v) => v as String),
    change_cid_orig_: $checkedConvert('change_cid_orig_', (v) => v as String),
    change_changeBy: $checkedConvert('change_changeBy', (v) => v as String),
    change_changeBy_orig_: $checkedConvert(
      'change_changeBy_orig_',
      (v) => v as String,
    ),
    data_parentId: $checkedConvert('data_parentId', (v) => v as String),
    data_parentId_changeAt_: $checkedConvert(
      'data_parentId_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_parentId_cid_: $checkedConvert(
      'data_parentId_cid_',
      (v) => v as String,
    ),
    data_parentId_changeBy_: $checkedConvert(
      'data_parentId_changeBy_',
      (v) => v as String,
    ),
    data_parentId_cloudAt_: $checkedConvert(
      'data_parentId_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_parentId_dataSchemaRev_: $checkedConvert(
      'data_parentId_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_parentProp: $checkedConvert('data_parentProp', (v) => v as String),
    data_parentProp_changeAt_: $checkedConvert(
      'data_parentProp_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_parentProp_cid_: $checkedConvert(
      'data_parentProp_cid_',
      (v) => v as String,
    ),
    data_parentProp_changeBy_: $checkedConvert(
      'data_parentProp_changeBy_',
      (v) => v as String,
    ),
    unknownJson: $checkedConvert('unknownJson', (v) => v as String),
    stateDataHash: $checkedConvert('stateDataHash', (v) => v as String?),
    stateDataHash_orig_: $checkedConvert(
      'stateDataHash_orig_',
      (v) => v as String?,
    ),
    data_emoji: $checkedConvert('data_emoji', (v) => v as String),
    data_emoji_dataSchemaRev_: $checkedConvert(
      'data_emoji_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_emoji_changeAt_: $checkedConvert(
      'data_emoji_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_emoji_cid_: $checkedConvert('data_emoji_cid_', (v) => v as String?),
    data_emoji_changeBy_: $checkedConvert(
      'data_emoji_changeBy_',
      (v) => v as String,
    ),
    data_emoji_cloudAt_: $checkedConvert(
      'data_emoji_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_commentId: $checkedConvert('data_commentId', (v) => v as String),
    data_commentId_dataSchemaRev_: $checkedConvert(
      'data_commentId_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_commentId_changeAt_: $checkedConvert(
      'data_commentId_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_commentId_cid_: $checkedConvert(
      'data_commentId_cid_',
      (v) => v as String?,
    ),
    data_commentId_changeBy_: $checkedConvert(
      'data_commentId_changeBy_',
      (v) => v as String,
    ),
    data_commentId_cloudAt_: $checkedConvert(
      'data_commentId_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_noteId: $checkedConvert('data_noteId', (v) => v as String),
    data_noteId_dataSchemaRev_: $checkedConvert(
      'data_noteId_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_noteId_changeAt_: $checkedConvert(
      'data_noteId_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_noteId_cid_: $checkedConvert('data_noteId_cid_', (v) => v as String?),
    data_noteId_changeBy_: $checkedConvert(
      'data_noteId_changeBy_',
      (v) => v as String,
    ),
    data_noteId_cloudAt_: $checkedConvert(
      'data_noteId_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    change_cloudAt: $checkedConvert(
      'change_cloudAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    change_dataSchemaRev: $checkedConvert(
      'change_dataSchemaRev',
      (v) => (v as num?)?.toInt(),
    ),
    data_deleted: $checkedConvert('data_deleted', (v) => v as bool?),
    data_deleted_changeAt_: $checkedConvert(
      'data_deleted_changeAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_deleted_changeBy_: $checkedConvert(
      'data_deleted_changeBy_',
      (v) => v as String?,
    ),
    data_deleted_cid_: $checkedConvert(
      'data_deleted_cid_',
      (v) => v as String?,
    ),
    data_deleted_cloudAt_: $checkedConvert(
      'data_deleted_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_deleted_dataSchemaRev_: $checkedConvert(
      'data_deleted_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_parentProp_cloudAt_: $checkedConvert(
      'data_parentProp_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_parentProp_dataSchemaRev_: $checkedConvert(
      'data_parentProp_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_rank: $checkedConvert('data_rank', (v) => v as String?),
    data_rank_changeAt_: $checkedConvert(
      'data_rank_changeAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_rank_changeBy_: $checkedConvert(
      'data_rank_changeBy_',
      (v) => v as String?,
    ),
    data_rank_cid_: $checkedConvert('data_rank_cid_', (v) => v as String?),
    data_rank_cloudAt_: $checkedConvert(
      'data_rank_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_rank_dataSchemaRev_: $checkedConvert(
      'data_rank_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$DynamoNoteCommentEmojiReactedDataEntityStateToJson(
  DynamoNoteCommentEmojiReactedDataEntityState instance,
) => <String, dynamic>{
  'entityType': instance.entityType,
  'domainType': instance.domainType,
  'unknownJson': instance.unknownJson,
  'schemaVersion': instance.schemaVersion,
  'stateDataHash': instance.stateDataHash,
  'stateDataHash_orig_': instance.stateDataHash_orig_,
  'change_domainId': instance.change_domainId,
  'change_domainId_orig_': instance.change_domainId_orig_,
  'change_changeAt': instance.change_changeAt.toIso8601String(),
  'change_changeAt_orig_': instance.change_changeAt_orig_.toIso8601String(),
  'change_storedAt': instance.change_storedAt.toIso8601String(),
  'change_storedAt_orig_': instance.change_storedAt_orig_.toIso8601String(),
  'change_cid': instance.change_cid,
  'change_cid_orig_': instance.change_cid_orig_,
  'change_dataSchemaRev': instance.change_dataSchemaRev,
  'change_cloudAt': instance.change_cloudAt?.toIso8601String(),
  'change_changeBy': instance.change_changeBy,
  'change_changeBy_orig_': instance.change_changeBy_orig_,
  'data_rank': instance.data_rank,
  'data_rank_dataSchemaRev_': instance.data_rank_dataSchemaRev_,
  'data_rank_changeAt_': instance.data_rank_changeAt_?.toIso8601String(),
  'data_rank_cid_': instance.data_rank_cid_,
  'data_rank_changeBy_': instance.data_rank_changeBy_,
  'data_rank_cloudAt_': instance.data_rank_cloudAt_?.toIso8601String(),
  'data_deleted': instance.data_deleted,
  'data_deleted_dataSchemaRev_': instance.data_deleted_dataSchemaRev_,
  'data_deleted_changeAt_': instance.data_deleted_changeAt_?.toIso8601String(),
  'data_deleted_cid_': instance.data_deleted_cid_,
  'data_deleted_changeBy_': instance.data_deleted_changeBy_,
  'data_deleted_cloudAt_': instance.data_deleted_cloudAt_?.toIso8601String(),
  'data_parentId': instance.data_parentId,
  'data_parentId_dataSchemaRev_': instance.data_parentId_dataSchemaRev_,
  'data_parentId_changeAt_': instance.data_parentId_changeAt_.toIso8601String(),
  'data_parentId_cid_': instance.data_parentId_cid_,
  'data_parentId_changeBy_': instance.data_parentId_changeBy_,
  'data_parentId_cloudAt_': instance.data_parentId_cloudAt_?.toIso8601String(),
  'data_parentProp': instance.data_parentProp,
  'data_parentProp_dataSchemaRev_': instance.data_parentProp_dataSchemaRev_,
  'data_parentProp_changeAt_': instance.data_parentProp_changeAt_
      .toIso8601String(),
  'data_parentProp_cid_': instance.data_parentProp_cid_,
  'data_parentProp_changeBy_': instance.data_parentProp_changeBy_,
  'data_parentProp_cloudAt_': instance.data_parentProp_cloudAt_
      ?.toIso8601String(),
  'entityId': instance.entityId,
  'data_emoji': instance.data_emoji,
  'data_emoji_dataSchemaRev_': instance.data_emoji_dataSchemaRev_,
  'data_emoji_changeAt_': instance.data_emoji_changeAt_.toIso8601String(),
  'data_emoji_cid_': instance.data_emoji_cid_,
  'data_emoji_changeBy_': instance.data_emoji_changeBy_,
  'data_emoji_cloudAt_': instance.data_emoji_cloudAt_?.toIso8601String(),
  'data_commentId': instance.data_commentId,
  'data_commentId_dataSchemaRev_': instance.data_commentId_dataSchemaRev_,
  'data_commentId_changeAt_': instance.data_commentId_changeAt_
      .toIso8601String(),
  'data_commentId_cid_': instance.data_commentId_cid_,
  'data_commentId_changeBy_': instance.data_commentId_changeBy_,
  'data_commentId_cloudAt_': instance.data_commentId_cloudAt_
      ?.toIso8601String(),
  'data_noteId': instance.data_noteId,
  'data_noteId_dataSchemaRev_': instance.data_noteId_dataSchemaRev_,
  'data_noteId_changeAt_': instance.data_noteId_changeAt_.toIso8601String(),
  'data_noteId_cid_': instance.data_noteId_cid_,
  'data_noteId_changeBy_': instance.data_noteId_changeBy_,
  'data_noteId_cloudAt_': instance.data_noteId_cloudAt_?.toIso8601String(),
};
