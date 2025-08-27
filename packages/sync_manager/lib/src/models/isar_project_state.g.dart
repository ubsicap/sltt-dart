// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_project_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IsarProjectState _$IsarProjectStateFromJson(Map<String, dynamic> json) =>
    IsarProjectState(
      entityId: json['entityId'] as String,
      entityType: json['entityType'] as String? ?? 'project',
      data_nameLocal: json['data_nameLocal'] as String?,
      data_nameLocal_dataSchemaRev_:
          (json['data_nameLocal_dataSchemaRev_'] as num?)?.toInt(),
      data_nameLocal_changeAt_: json['data_nameLocal_changeAt_'] == null
          ? null
          : DateTime.parse(json['data_nameLocal_changeAt_'] as String),
      data_nameLocal_cid_: json['data_nameLocal_cid_'] as String?,
      data_nameLocal_changeBy_: json['data_nameLocal_changeBy_'] as String?,
      data_nameLocal_cloudAt_: json['data_nameLocal_cloudAt_'] == null
          ? null
          : DateTime.parse(json['data_nameLocal_cloudAt_'] as String),
      schemaVersion: (json['schemaVersion'] as num?)?.toInt(),
      change_domainId: json['change_domainId'] as String,
      change_domainId_orig_: json['change_domainId_orig_'] as String?,
      change_changeAt: DateTime.parse(json['change_changeAt'] as String),
      change_changeAt_orig_: json['change_changeAt_orig_'] == null
          ? null
          : DateTime.parse(json['change_changeAt_orig_'] as String),
      change_cid: json['change_cid'] as String,
      change_cid_orig_: json['change_cid_orig_'] as String?,
      change_dataSchemaRev: (json['change_dataSchemaRev'] as num?)?.toInt(),
      change_cloudAt: json['change_cloudAt'] == null
          ? null
          : DateTime.parse(json['change_cloudAt'] as String),
      change_changeBy: json['change_changeBy'] as String,
      data_rank_dataSchemaRev_:
          (json['data_rank_dataSchemaRev_'] as num?)?.toInt(),
      data_rank: json['data_rank'] as String?,
      data_rank_changeAt_: json['data_rank_changeAt_'] == null
          ? null
          : DateTime.parse(json['data_rank_changeAt_'] as String),
      data_rank_cid_: json['data_rank_cid_'] as String?,
      data_rank_changeBy_: json['data_rank_changeBy_'] as String?,
      data_rank_cloudAt_: json['data_rank_cloudAt_'] == null
          ? null
          : DateTime.parse(json['data_rank_cloudAt_'] as String),
      data_deleted: json['data_deleted'] as bool?,
      data_deleted_dataSchemaRev_:
          (json['data_deleted_dataSchemaRev_'] as num?)?.toInt(),
      data_deleted_changeAt_: json['data_deleted_changeAt_'] == null
          ? null
          : DateTime.parse(json['data_deleted_changeAt_'] as String),
      data_deleted_cid_: json['data_deleted_cid_'] as String?,
      data_deleted_changeBy_: json['data_deleted_changeBy_'] as String?,
      data_deleted_cloudAt_: json['data_deleted_cloudAt_'] == null
          ? null
          : DateTime.parse(json['data_deleted_cloudAt_'] as String),
      data_parentId: json['data_parentId'] as String,
      data_parentId_dataSchemaRev_:
          (json['data_parentId_dataSchemaRev_'] as num?)?.toInt(),
      data_parentId_changeAt_:
          DateTime.parse(json['data_parentId_changeAt_'] as String),
      data_parentId_cid_: json['data_parentId_cid_'] as String,
      data_parentId_changeBy_: json['data_parentId_changeBy_'] as String,
      data_parentId_cloudAt_: json['data_parentId_cloudAt_'] == null
          ? null
          : DateTime.parse(json['data_parentId_cloudAt_'] as String),
    )
      ..id = (json['id'] as num).toInt()
      ..unknownJson = json['unknownJson'] as String;

Map<String, dynamic> _$IsarProjectStateToJson(IsarProjectState instance) =>
    <String, dynamic>{
      'change_domainId_orig_': instance.change_domainId_orig_,
      'change_changeAt_orig_': instance.change_changeAt_orig_.toIso8601String(),
      'change_cid_orig_': instance.change_cid_orig_,
      'id': instance.id,
      'entityId': instance.entityId,
      'schemaVersion': instance.schemaVersion,
      'unknownJson': instance.unknownJson,
      'change_domainId': instance.change_domainId,
      'change_changeAt': instance.change_changeAt.toIso8601String(),
      'change_cid': instance.change_cid,
      'change_dataSchemaRev': instance.change_dataSchemaRev,
      'change_cloudAt': instance.change_cloudAt?.toIso8601String(),
      'change_changeBy': instance.change_changeBy,
      'data_rank': instance.data_rank,
      'data_rank_dataSchemaRev_': instance.data_rank_dataSchemaRev_,
      'data_rank_changeAt_': instance.data_rank_changeAt_?.toIso8601String(),
      'data_rank_cid_': instance.data_rank_cid_,
      'data_rank_changeBy_': instance.data_rank_changeBy_,
      'data_rank_cloudAt_': instance.data_rank_cloudAt_?.toIso8601String(),
      'data_deleted': instance.data_deleted,
      'data_deleted_dataSchemaRev_': instance.data_deleted_dataSchemaRev_,
      'data_deleted_changeAt_':
          instance.data_deleted_changeAt_?.toIso8601String(),
      'data_deleted_cid_': instance.data_deleted_cid_,
      'data_deleted_changeBy_': instance.data_deleted_changeBy_,
      'data_deleted_cloudAt_':
          instance.data_deleted_cloudAt_?.toIso8601String(),
      'data_parentId': instance.data_parentId,
      'data_parentId_dataSchemaRev_': instance.data_parentId_dataSchemaRev_,
      'data_parentId_changeAt_':
          instance.data_parentId_changeAt_.toIso8601String(),
      'data_parentId_cid_': instance.data_parentId_cid_,
      'data_parentId_changeBy_': instance.data_parentId_changeBy_,
      'data_parentId_cloudAt_':
          instance.data_parentId_cloudAt_?.toIso8601String(),
      'entityType': instance.entityType,
      'data_nameLocal': instance.data_nameLocal,
      'data_nameLocal_dataSchemaRev_': instance.data_nameLocal_dataSchemaRev_,
      'data_nameLocal_changeAt_':
          instance.data_nameLocal_changeAt_?.toIso8601String(),
      'data_nameLocal_cid_': instance.data_nameLocal_cid_,
      'data_nameLocal_changeBy_': instance.data_nameLocal_changeBy_,
      'data_nameLocal_cloudAt_':
          instance.data_nameLocal_cloudAt_?.toIso8601String(),
    };
