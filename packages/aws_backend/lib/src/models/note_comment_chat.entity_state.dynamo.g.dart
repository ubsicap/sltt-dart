// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_comment_chat.entity_state.dynamo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamoNoteCommentChatDataEntityState
_$DynamoNoteCommentChatDataEntityStateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DynamoNoteCommentChatDataEntityState', json, (
  $checkedConvert,
) {
  final val = DynamoNoteCommentChatDataEntityState(
    schemaVersion: $checkedConvert(
      'schemaVersion',
      (v) => (v as num?)?.toInt(),
    ),
    entityType: $checkedConvert(
      'entityType',
      (v) => v as String? ?? kEntityTypeComment,
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
    data_text: $checkedConvert('data_text', (v) => v as String),
    data_text_dataSchemaRev_: $checkedConvert(
      'data_text_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_text_changeAt_: $checkedConvert(
      'data_text_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_text_cid_: $checkedConvert('data_text_cid_', (v) => v as String?),
    data_text_changeBy_: $checkedConvert(
      'data_text_changeBy_',
      (v) => v as String,
    ),
    data_text_cloudAt_: $checkedConvert(
      'data_text_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_videoStoredFilename: $checkedConvert(
      'data_videoStoredFilename',
      (v) => v as String?,
    ),
    data_videoStoredFilename_dataSchemaRev_: $checkedConvert(
      'data_videoStoredFilename_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_videoStoredFilename_changeAt_: $checkedConvert(
      'data_videoStoredFilename_changeAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_videoStoredFilename_cid_: $checkedConvert(
      'data_videoStoredFilename_cid_',
      (v) => v as String?,
    ),
    data_videoStoredFilename_changeBy_: $checkedConvert(
      'data_videoStoredFilename_changeBy_',
      (v) => v as String?,
    ),
    data_videoStoredFilename_cloudAt_: $checkedConvert(
      'data_videoStoredFilename_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_videoDurationMs: $checkedConvert(
      'data_videoDurationMs',
      (v) => (v as num?)?.toInt(),
    ),
    data_videoDurationMs_dataSchemaRev_: $checkedConvert(
      'data_videoDurationMs_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_videoDurationMs_changeAt_: $checkedConvert(
      'data_videoDurationMs_changeAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_videoDurationMs_cid_: $checkedConvert(
      'data_videoDurationMs_cid_',
      (v) => v as String?,
    ),
    data_videoDurationMs_changeBy_: $checkedConvert(
      'data_videoDurationMs_changeBy_',
      (v) => v as String?,
    ),
    data_videoDurationMs_cloudAt_: $checkedConvert(
      'data_videoDurationMs_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_dateMs: $checkedConvert('data_dateMs', (v) => (v as num).toInt()),
    data_dateMs_dataSchemaRev_: $checkedConvert(
      'data_dateMs_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_dateMs_changeAt_: $checkedConvert(
      'data_dateMs_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_dateMs_cid_: $checkedConvert('data_dateMs_cid_', (v) => v as String?),
    data_dateMs_changeBy_: $checkedConvert(
      'data_dateMs_changeBy_',
      (v) => v as String,
    ),
    data_dateMs_cloudAt_: $checkedConvert(
      'data_dateMs_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_visibleToUserIds: $checkedConvert(
      'data_visibleToUserIds',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    data_visibleToUserIds_dataSchemaRev_: $checkedConvert(
      'data_visibleToUserIds_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_visibleToUserIds_changeAt_: $checkedConvert(
      'data_visibleToUserIds_changeAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_visibleToUserIds_cid_: $checkedConvert(
      'data_visibleToUserIds_cid_',
      (v) => v as String?,
    ),
    data_visibleToUserIds_changeBy_: $checkedConvert(
      'data_visibleToUserIds_changeBy_',
      (v) => v as String?,
    ),
    data_visibleToUserIds_cloudAt_: $checkedConvert(
      'data_visibleToUserIds_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_notifiedUserIds: $checkedConvert(
      'data_notifiedUserIds',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    data_notifiedUserIds_dataSchemaRev_: $checkedConvert(
      'data_notifiedUserIds_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_notifiedUserIds_changeAt_: $checkedConvert(
      'data_notifiedUserIds_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_notifiedUserIds_cid_: $checkedConvert(
      'data_notifiedUserIds_cid_',
      (v) => v as String,
    ),
    data_notifiedUserIds_changeBy_: $checkedConvert(
      'data_notifiedUserIds_changeBy_',
      (v) => v as String,
    ),
    data_notifiedUserIds_cloudAt_: $checkedConvert(
      'data_notifiedUserIds_cloudAt_',
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

Map<String, dynamic> _$DynamoNoteCommentChatDataEntityStateToJson(
  DynamoNoteCommentChatDataEntityState instance,
) => <String, dynamic>{
  'entityType': instance.entityType,
  'domainType': instance.domainType,
  'unknownJson': instance.unknownJson,
  'schemaVersion': instance.schemaVersion,
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
  'data_text': instance.data_text,
  'data_text_dataSchemaRev_': instance.data_text_dataSchemaRev_,
  'data_text_changeAt_': instance.data_text_changeAt_.toIso8601String(),
  'data_text_cid_': instance.data_text_cid_,
  'data_text_changeBy_': instance.data_text_changeBy_,
  'data_text_cloudAt_': instance.data_text_cloudAt_?.toIso8601String(),
  'data_videoStoredFilename': instance.data_videoStoredFilename,
  'data_videoStoredFilename_dataSchemaRev_':
      instance.data_videoStoredFilename_dataSchemaRev_,
  'data_videoStoredFilename_changeAt_': instance
      .data_videoStoredFilename_changeAt_
      ?.toIso8601String(),
  'data_videoStoredFilename_cid_': instance.data_videoStoredFilename_cid_,
  'data_videoStoredFilename_changeBy_':
      instance.data_videoStoredFilename_changeBy_,
  'data_videoStoredFilename_cloudAt_': instance
      .data_videoStoredFilename_cloudAt_
      ?.toIso8601String(),
  'data_videoDurationMs': instance.data_videoDurationMs,
  'data_videoDurationMs_dataSchemaRev_':
      instance.data_videoDurationMs_dataSchemaRev_,
  'data_videoDurationMs_changeAt_': instance.data_videoDurationMs_changeAt_
      ?.toIso8601String(),
  'data_videoDurationMs_cid_': instance.data_videoDurationMs_cid_,
  'data_videoDurationMs_changeBy_': instance.data_videoDurationMs_changeBy_,
  'data_videoDurationMs_cloudAt_': instance.data_videoDurationMs_cloudAt_
      ?.toIso8601String(),
  'data_dateMs': instance.data_dateMs,
  'data_dateMs_dataSchemaRev_': instance.data_dateMs_dataSchemaRev_,
  'data_dateMs_changeAt_': instance.data_dateMs_changeAt_.toIso8601String(),
  'data_dateMs_cid_': instance.data_dateMs_cid_,
  'data_dateMs_changeBy_': instance.data_dateMs_changeBy_,
  'data_dateMs_cloudAt_': instance.data_dateMs_cloudAt_?.toIso8601String(),
  'data_visibleToUserIds': instance.data_visibleToUserIds,
  'data_visibleToUserIds_dataSchemaRev_':
      instance.data_visibleToUserIds_dataSchemaRev_,
  'data_visibleToUserIds_changeAt_': instance.data_visibleToUserIds_changeAt_
      ?.toIso8601String(),
  'data_visibleToUserIds_cid_': instance.data_visibleToUserIds_cid_,
  'data_visibleToUserIds_changeBy_': instance.data_visibleToUserIds_changeBy_,
  'data_visibleToUserIds_cloudAt_': instance.data_visibleToUserIds_cloudAt_
      ?.toIso8601String(),
  'data_notifiedUserIds': instance.data_notifiedUserIds,
  'data_notifiedUserIds_dataSchemaRev_':
      instance.data_notifiedUserIds_dataSchemaRev_,
  'data_notifiedUserIds_changeAt_': instance.data_notifiedUserIds_changeAt_
      .toIso8601String(),
  'data_notifiedUserIds_cid_': instance.data_notifiedUserIds_cid_,
  'data_notifiedUserIds_changeBy_': instance.data_notifiedUserIds_changeBy_,
  'data_notifiedUserIds_cloudAt_': instance.data_notifiedUserIds_cloudAt_
      ?.toIso8601String(),
};
