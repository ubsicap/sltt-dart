// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_data.entity_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskDataEntityState _$TaskDataEntityStateFromJson(Map<String, dynamic> json) =>
    TaskDataEntityState(
      entityId: json['entityId'] as String,
      domainType: json['domainType'] as String,
      change_domainId: json['change_domainId'] as String,
      change_changeAt: DateTime.parse(json['change_changeAt'] as String),
      change_cid: json['change_cid'] as String,
      change_changeBy: json['change_changeBy'] as String,
      data_parentId: json['data_parentId'] as String,
      data_parentId_changeAt_:
          DateTime.parse(json['data_parentId_changeAt_'] as String),
      data_parentId_cid_: json['data_parentId_cid_'] as String,
      data_parentId_changeBy_: json['data_parentId_changeBy_'] as String,
      data_parentProp: json['data_parentProp'] as String,
      data_parentProp_dataSchemaRev_:
          (json['data_parentProp_dataSchemaRev_'] as num?)?.toInt(),
      data_parentProp_changeAt_:
          DateTime.parse(json['data_parentProp_changeAt_'] as String),
      data_parentProp_cid_: json['data_parentProp_cid_'] as String,
      data_parentProp_changeBy_: json['data_parentProp_changeBy_'] as String,
      data_parentProp_cloudAt_: json['data_parentProp_cloudAt_'] == null
          ? null
          : DateTime.parse(json['data_parentProp_cloudAt_'] as String),
      unknownJson: json['unknownJson'] as String,
      change_dataSchemaRev: (json['change_dataSchemaRev'] as num?)?.toInt(),
      change_cloudAt: json['change_cloudAt'] == null
          ? null
          : DateTime.parse(json['change_cloudAt'] as String),
      data_rank: json['data_rank'] as String?,
      data_rank_dataSchemaRev_:
          (json['data_rank_dataSchemaRev_'] as num?)?.toInt(),
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
      data_nameLocal: json['data_nameLocal'] as String,
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
    );

Map<String, dynamic> _$TaskDataEntityStateToJson(
        TaskDataEntityState instance) =>
    <String, dynamic>{
      'domainType': instance.domainType,
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
      'data_parentId_changeAt_':
          instance.data_parentId_changeAt_.toIso8601String(),
      'data_parentId_cid_': instance.data_parentId_cid_,
      'data_parentId_changeBy_': instance.data_parentId_changeBy_,
      'data_parentProp': instance.data_parentProp,
      'data_parentProp_dataSchemaRev_': instance.data_parentProp_dataSchemaRev_,
      'data_parentProp_changeAt_':
          instance.data_parentProp_changeAt_.toIso8601String(),
      'data_parentProp_cid_': instance.data_parentProp_cid_,
      'data_parentProp_changeBy_': instance.data_parentProp_changeBy_,
      'data_parentProp_cloudAt_':
          instance.data_parentProp_cloudAt_?.toIso8601String(),
      'entityId': instance.entityId,
      'data_nameLocal': instance.data_nameLocal,
      'data_nameLocal_dataSchemaRev_': instance.data_nameLocal_dataSchemaRev_,
      'data_nameLocal_changeAt_':
          instance.data_nameLocal_changeAt_?.toIso8601String(),
      'data_nameLocal_cid_': instance.data_nameLocal_cid_,
      'data_nameLocal_changeBy_': instance.data_nameLocal_changeBy_,
      'data_nameLocal_cloudAt_':
          instance.data_nameLocal_cloudAt_?.toIso8601String(),
    };
