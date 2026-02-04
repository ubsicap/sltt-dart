// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.entity_state.dynamo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamoNoteDataEntityState _$DynamoNoteDataEntityStateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DynamoNoteDataEntityState', json, ($checkedConvert) {
  final val = DynamoNoteDataEntityState(
    schemaVersion: $checkedConvert(
      'schemaVersion',
      (v) => (v as num?)?.toInt(),
    ),
    entityType: $checkedConvert(
      'entityType',
      (v) => v as String? ?? kEntityTypeNote,
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
    data_title: $checkedConvert('data_title', (v) => v as String),
    data_title_dataSchemaRev_: $checkedConvert(
      'data_title_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_title_changeAt_: $checkedConvert(
      'data_title_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_title_cid_: $checkedConvert('data_title_cid_', (v) => v as String?),
    data_title_changeBy_: $checkedConvert(
      'data_title_changeBy_',
      (v) => v as String,
    ),
    data_title_cloudAt_: $checkedConvert(
      'data_title_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_videoCommentId: $checkedConvert(
      'data_videoCommentId',
      (v) => v as String?,
    ),
    data_videoCommentId_dataSchemaRev_: $checkedConvert(
      'data_videoCommentId_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_videoCommentId_changeAt_: $checkedConvert(
      'data_videoCommentId_changeAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_videoCommentId_cid_: $checkedConvert(
      'data_videoCommentId_cid_',
      (v) => v as String?,
    ),
    data_videoCommentId_changeBy_: $checkedConvert(
      'data_videoCommentId_changeBy_',
      (v) => v as String?,
    ),
    data_videoCommentId_cloudAt_: $checkedConvert(
      'data_videoCommentId_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_textComment: $checkedConvert('data_textComment', (v) => v as String?),
    data_textComment_dataSchemaRev_: $checkedConvert(
      'data_textComment_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_textComment_changeAt_: $checkedConvert(
      'data_textComment_changeAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_textComment_cid_: $checkedConvert(
      'data_textComment_cid_',
      (v) => v as String?,
    ),
    data_textComment_changeBy_: $checkedConvert(
      'data_textComment_changeBy_',
      (v) => v as String?,
    ),
    data_textComment_cloudAt_: $checkedConvert(
      'data_textComment_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_markerId: $checkedConvert('data_markerId', (v) => v as String),
    data_markerId_dataSchemaRev_: $checkedConvert(
      'data_markerId_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_markerId_changeAt_: $checkedConvert(
      'data_markerId_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_markerId_cid_: $checkedConvert(
      'data_markerId_cid_',
      (v) => v as String?,
    ),
    data_markerId_changeBy_: $checkedConvert(
      'data_markerId_changeBy_',
      (v) => v as String,
    ),
    data_markerId_cloudAt_: $checkedConvert(
      'data_markerId_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_positionMs: $checkedConvert(
      'data_positionMs',
      (v) => (v as num).toInt(),
    ),
    data_positionMs_dataSchemaRev_: $checkedConvert(
      'data_positionMs_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_positionMs_changeAt_: $checkedConvert(
      'data_positionMs_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_positionMs_cid_: $checkedConvert(
      'data_positionMs_cid_',
      (v) => v as String?,
    ),
    data_positionMs_changeBy_: $checkedConvert(
      'data_positionMs_changeBy_',
      (v) => v as String,
    ),
    data_positionMs_cloudAt_: $checkedConvert(
      'data_positionMs_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_resolution: $checkedConvert('data_resolution', (v) => v as String),
    data_resolution_dataSchemaRev_: $checkedConvert(
      'data_resolution_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_resolution_changeAt_: $checkedConvert(
      'data_resolution_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_resolution_cid_: $checkedConvert(
      'data_resolution_cid_',
      (v) => v as String?,
    ),
    data_resolution_changeBy_: $checkedConvert(
      'data_resolution_changeBy_',
      (v) => v as String,
    ),
    data_resolution_cloudAt_: $checkedConvert(
      'data_resolution_cloudAt_',
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

Map<String, dynamic> _$DynamoNoteDataEntityStateToJson(
  DynamoNoteDataEntityState instance,
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
  'data_title': instance.data_title,
  'data_title_dataSchemaRev_': instance.data_title_dataSchemaRev_,
  'data_title_changeAt_': instance.data_title_changeAt_.toIso8601String(),
  'data_title_cid_': instance.data_title_cid_,
  'data_title_changeBy_': instance.data_title_changeBy_,
  'data_title_cloudAt_': instance.data_title_cloudAt_?.toIso8601String(),
  'data_videoCommentId': instance.data_videoCommentId,
  'data_videoCommentId_dataSchemaRev_':
      instance.data_videoCommentId_dataSchemaRev_,
  'data_videoCommentId_changeAt_': instance.data_videoCommentId_changeAt_
      ?.toIso8601String(),
  'data_videoCommentId_cid_': instance.data_videoCommentId_cid_,
  'data_videoCommentId_changeBy_': instance.data_videoCommentId_changeBy_,
  'data_videoCommentId_cloudAt_': instance.data_videoCommentId_cloudAt_
      ?.toIso8601String(),
  'data_textComment': instance.data_textComment,
  'data_textComment_dataSchemaRev_': instance.data_textComment_dataSchemaRev_,
  'data_textComment_changeAt_': instance.data_textComment_changeAt_
      ?.toIso8601String(),
  'data_textComment_cid_': instance.data_textComment_cid_,
  'data_textComment_changeBy_': instance.data_textComment_changeBy_,
  'data_textComment_cloudAt_': instance.data_textComment_cloudAt_
      ?.toIso8601String(),
  'data_markerId': instance.data_markerId,
  'data_markerId_dataSchemaRev_': instance.data_markerId_dataSchemaRev_,
  'data_markerId_changeAt_': instance.data_markerId_changeAt_.toIso8601String(),
  'data_markerId_cid_': instance.data_markerId_cid_,
  'data_markerId_changeBy_': instance.data_markerId_changeBy_,
  'data_markerId_cloudAt_': instance.data_markerId_cloudAt_?.toIso8601String(),
  'data_positionMs': instance.data_positionMs,
  'data_positionMs_dataSchemaRev_': instance.data_positionMs_dataSchemaRev_,
  'data_positionMs_changeAt_': instance.data_positionMs_changeAt_
      .toIso8601String(),
  'data_positionMs_cid_': instance.data_positionMs_cid_,
  'data_positionMs_changeBy_': instance.data_positionMs_changeBy_,
  'data_positionMs_cloudAt_': instance.data_positionMs_cloudAt_
      ?.toIso8601String(),
  'data_resolution': instance.data_resolution,
  'data_resolution_dataSchemaRev_': instance.data_resolution_dataSchemaRev_,
  'data_resolution_changeAt_': instance.data_resolution_changeAt_
      .toIso8601String(),
  'data_resolution_cid_': instance.data_resolution_cid_,
  'data_resolution_changeBy_': instance.data_resolution_changeBy_,
  'data_resolution_cloudAt_': instance.data_resolution_cloudAt_
      ?.toIso8601String(),
};
