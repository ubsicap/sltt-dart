// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passage_translation.entity_state.dynamo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamoPassageDataEntityState _$DynamoPassageDataEntityStateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DynamoPassageDataEntityState', json, ($checkedConvert) {
  final val = DynamoPassageDataEntityState(
    schemaVersion: $checkedConvert(
      'schemaVersion',
      (v) => (v as num?)?.toInt(),
    ),
    entityType: $checkedConvert(
      'entityType',
      (v) => v as String? ?? kEntityTypePassage,
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
    data_name: $checkedConvert('data_name', (v) => v as String),
    data_name_dataSchemaRev_: $checkedConvert(
      'data_name_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_name_changeAt_: $checkedConvert(
      'data_name_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_name_cid_: $checkedConvert('data_name_cid_', (v) => v as String?),
    data_name_changeBy_: $checkedConvert(
      'data_name_changeBy_',
      (v) => v as String,
    ),
    data_name_cloudAt_: $checkedConvert(
      'data_name_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_visibility: $checkedConvert('data_visibility', (v) => v as String),
    data_visibility_dataSchemaRev_: $checkedConvert(
      'data_visibility_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_visibility_changeAt_: $checkedConvert(
      'data_visibility_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_visibility_cid_: $checkedConvert(
      'data_visibility_cid_',
      (v) => v as String,
    ),
    data_visibility_changeBy_: $checkedConvert(
      'data_visibility_changeBy_',
      (v) => v as String,
    ),
    data_visibility_cloudAt_: $checkedConvert(
      'data_visibility_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_type: $checkedConvert('data_type', (v) => v as String),
    data_type_dataSchemaRev_: $checkedConvert(
      'data_type_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_type_changeAt_: $checkedConvert(
      'data_type_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_type_cid_: $checkedConvert('data_type_cid_', (v) => v as String),
    data_type_changeBy_: $checkedConvert(
      'data_type_changeBy_',
      (v) => v as String,
    ),
    data_type_cloudAt_: $checkedConvert(
      'data_type_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_difficulty: $checkedConvert('data_difficulty', (v) => v as String),
    data_difficulty_dataSchemaRev_: $checkedConvert(
      'data_difficulty_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_difficulty_changeAt_: $checkedConvert(
      'data_difficulty_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_difficulty_cid_: $checkedConvert(
      'data_difficulty_cid_',
      (v) => v as String,
    ),
    data_difficulty_changeBy_: $checkedConvert(
      'data_difficulty_changeBy_',
      (v) => v as String,
    ),
    data_difficulty_cloudAt_: $checkedConvert(
      'data_difficulty_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_references: $checkedConvert(
      'data_references',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    data_references_dataSchemaRev_: $checkedConvert(
      'data_references_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_references_changeAt_: $checkedConvert(
      'data_references_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_references_cid_: $checkedConvert(
      'data_references_cid_',
      (v) => v as String,
    ),
    data_references_changeBy_: $checkedConvert(
      'data_references_changeBy_',
      (v) => v as String,
    ),
    data_references_cloudAt_: $checkedConvert(
      'data_references_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_tags: $checkedConvert(
      'data_tags',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    data_tags_dataSchemaRev_: $checkedConvert(
      'data_tags_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_tags_changeAt_: $checkedConvert(
      'data_tags_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_tags_cid_: $checkedConvert('data_tags_cid_', (v) => v as String),
    data_tags_changeBy_: $checkedConvert(
      'data_tags_changeBy_',
      (v) => v as String,
    ),
    data_tags_cloudAt_: $checkedConvert(
      'data_tags_cloudAt_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    data_includeInStatistics: $checkedConvert(
      'data_includeInStatistics',
      (v) => v as bool,
    ),
    data_includeInStatistics_dataSchemaRev_: $checkedConvert(
      'data_includeInStatistics_dataSchemaRev_',
      (v) => (v as num?)?.toInt(),
    ),
    data_includeInStatistics_changeAt_: $checkedConvert(
      'data_includeInStatistics_changeAt_',
      (v) => DateTime.parse(v as String),
    ),
    data_includeInStatistics_cid_: $checkedConvert(
      'data_includeInStatistics_cid_',
      (v) => v as String,
    ),
    data_includeInStatistics_changeBy_: $checkedConvert(
      'data_includeInStatistics_changeBy_',
      (v) => v as String,
    ),
    data_includeInStatistics_cloudAt_: $checkedConvert(
      'data_includeInStatistics_cloudAt_',
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

Map<String, dynamic> _$DynamoPassageDataEntityStateToJson(
  DynamoPassageDataEntityState instance,
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
  'data_name': instance.data_name,
  'data_name_dataSchemaRev_': instance.data_name_dataSchemaRev_,
  'data_name_changeAt_': instance.data_name_changeAt_.toIso8601String(),
  'data_name_cid_': instance.data_name_cid_,
  'data_name_changeBy_': instance.data_name_changeBy_,
  'data_name_cloudAt_': instance.data_name_cloudAt_?.toIso8601String(),
  'data_visibility': instance.data_visibility,
  'data_visibility_dataSchemaRev_': instance.data_visibility_dataSchemaRev_,
  'data_visibility_changeAt_': instance.data_visibility_changeAt_
      .toIso8601String(),
  'data_visibility_cid_': instance.data_visibility_cid_,
  'data_visibility_changeBy_': instance.data_visibility_changeBy_,
  'data_visibility_cloudAt_': instance.data_visibility_cloudAt_
      ?.toIso8601String(),
  'data_type': instance.data_type,
  'data_type_dataSchemaRev_': instance.data_type_dataSchemaRev_,
  'data_type_changeAt_': instance.data_type_changeAt_.toIso8601String(),
  'data_type_cid_': instance.data_type_cid_,
  'data_type_changeBy_': instance.data_type_changeBy_,
  'data_type_cloudAt_': instance.data_type_cloudAt_?.toIso8601String(),
  'data_difficulty': instance.data_difficulty,
  'data_difficulty_dataSchemaRev_': instance.data_difficulty_dataSchemaRev_,
  'data_difficulty_changeAt_': instance.data_difficulty_changeAt_
      .toIso8601String(),
  'data_difficulty_cid_': instance.data_difficulty_cid_,
  'data_difficulty_changeBy_': instance.data_difficulty_changeBy_,
  'data_difficulty_cloudAt_': instance.data_difficulty_cloudAt_
      ?.toIso8601String(),
  'data_references': instance.data_references,
  'data_references_dataSchemaRev_': instance.data_references_dataSchemaRev_,
  'data_references_changeAt_': instance.data_references_changeAt_
      .toIso8601String(),
  'data_references_cid_': instance.data_references_cid_,
  'data_references_changeBy_': instance.data_references_changeBy_,
  'data_references_cloudAt_': instance.data_references_cloudAt_
      ?.toIso8601String(),
  'data_tags': instance.data_tags,
  'data_tags_dataSchemaRev_': instance.data_tags_dataSchemaRev_,
  'data_tags_changeAt_': instance.data_tags_changeAt_.toIso8601String(),
  'data_tags_cid_': instance.data_tags_cid_,
  'data_tags_changeBy_': instance.data_tags_changeBy_,
  'data_tags_cloudAt_': instance.data_tags_cloudAt_?.toIso8601String(),
  'data_includeInStatistics': instance.data_includeInStatistics,
  'data_includeInStatistics_dataSchemaRev_':
      instance.data_includeInStatistics_dataSchemaRev_,
  'data_includeInStatistics_changeAt_': instance
      .data_includeInStatistics_changeAt_
      .toIso8601String(),
  'data_includeInStatistics_cid_': instance.data_includeInStatistics_cid_,
  'data_includeInStatistics_changeBy_':
      instance.data_includeInStatistics_changeBy_,
  'data_includeInStatistics_cloudAt_': instance
      .data_includeInStatistics_cloudAt_
      ?.toIso8601String(),
};
