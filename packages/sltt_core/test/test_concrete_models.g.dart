// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_concrete_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConcreteChangeLogEntry _$ConcreteChangeLogEntryFromJson(
        Map<String, dynamic> json) =>
    ConcreteChangeLogEntry(
      entityId: json['entityId'] as String,
      entityType: $enumDecode(_$EntityTypeEnumMap, json['entityType']),
      domainId: json['domainId'] as String,
      domainType: json['domainType'] as String,
      changeAt: DateTime.parse(json['changeAt'] as String),
      cid: json['cid'] as String,
      changeBy: json['changeBy'] as String,
      data: json['data'] as Map<String, dynamic>,
      operation: json['operation'] as String,
      operationInfo: json['operationInfo'] as Map<String, dynamic>,
      stateChanged: json['stateChanged'] as bool,
      unknown: json['unknown'] as Map<String, dynamic>,
      dataSchemaRev: (json['dataSchemaRev'] as num?)?.toInt(),
      cloudAt: json['cloudAt'] == null
          ? null
          : DateTime.parse(json['cloudAt'] as String),
      schemaVersion: (json['schemaVersion'] as num?)?.toInt(),
      seq: (json['seq'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ConcreteChangeLogEntryToJson(
        ConcreteChangeLogEntry instance) =>
    <String, dynamic>{
      'cid': instance.cid,
      'domainType': instance.domainType,
      'domainId': instance.domainId,
      'entityType': _$EntityTypeEnumMap[instance.entityType]!,
      'operation': instance.operation,
      'operationInfo': instance.operationInfo,
      'stateChanged': instance.stateChanged,
      'changeAt': instance.changeAt.toIso8601String(),
      'entityId': instance.entityId,
      'data': instance.data,
      'dataSchemaRev': instance.dataSchemaRev,
      'cloudAt': instance.cloudAt?.toIso8601String(),
      'changeBy': instance.changeBy,
      'schemaVersion': instance.schemaVersion,
      'unknown': instance.unknown,
      'seq': instance.seq,
    };

const _$EntityTypeEnumMap = {
  EntityType.project: 'project',
  EntityType.team: 'team',
  EntityType.plan: 'plan',
  EntityType.stage: 'stage',
  EntityType.task: 'task',
  EntityType.member: 'member',
  EntityType.message: 'message',
  EntityType.portion: 'portion',
  EntityType.passage: 'passage',
  EntityType.reference: 'reference',
  EntityType.document: 'document',
  EntityType.video: 'video',
  EntityType.patch: 'patch',
  EntityType.gloss: 'gloss',
  EntityType.note: 'note',
  EntityType.comment: 'comment',
};

ConcreteEntityState _$ConcreteEntityStateFromJson(Map<String, dynamic> json) =>
    ConcreteEntityState(
      entityId: json['entityId'] as String,
      entityType: $enumDecode(_$EntityTypeEnumMap, json['entityType']),
      change_domainId: json['change_domainId'] as String,
      change_domainId_orig_: json['change_domainId_orig_'] as String,
      change_changeAt: json['change_changeAt'] == null
          ? null
          : DateTime.parse(json['change_changeAt'] as String),
      change_changeAt_orig_: json['change_changeAt_orig_'] == null
          ? null
          : DateTime.parse(json['change_changeAt_orig_'] as String),
      change_cid: json['change_cid'] as String,
      change_cid_orig_: json['change_cid_orig_'] as String,
      change_dataSchemaRev: (json['change_dataSchemaRev'] as num?)?.toInt(),
      change_cloudAt: json['change_cloudAt'] == null
          ? null
          : DateTime.parse(json['change_cloudAt'] as String),
      change_cloudAt_orig_: json['change_cloudAt_orig_'] == null
          ? null
          : DateTime.parse(json['change_cloudAt_orig_'] as String),
      change_changeBy: json['change_changeBy'] as String,
      data_rank_dataSchemaRev:
          (json['data_rank_dataSchemaRev'] as num?)?.toInt(),
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
      data_deleted_dataSchemaRev:
          (json['data_deleted_dataSchemaRev'] as num?)?.toInt(),
      data_deleted_changeAt_: json['data_deleted_changeAt_'] == null
          ? null
          : DateTime.parse(json['data_deleted_changeAt_'] as String),
      data_deleted_cid_: json['data_deleted_cid_'] as String?,
      data_deleted_changeBy_: json['data_deleted_changeBy_'] as String?,
      data_deleted_cloudAt_: json['data_deleted_cloudAt_'] == null
          ? null
          : DateTime.parse(json['data_deleted_cloudAt_'] as String),
      data_parentId: json['data_parentId'] as String,
      data_parentId_dataSchemaRev:
          (json['data_parentId_dataSchemaRev'] as num?)?.toInt(),
      data_parentId_changeAt_:
          DateTime.parse(json['data_parentId_changeAt_'] as String),
      data_parentId_cid_: json['data_parentId_cid_'] as String,
      data_parentId_changeBy_: json['data_parentId_changeBy_'] as String,
      data_parentId_cloudAt_: json['data_parentId_cloudAt_'] == null
          ? null
          : DateTime.parse(json['data_parentId_cloudAt_'] as String),
    )
      ..schemaVersion = (json['schemaVersion'] as num?)?.toInt()
      ..unknown = json['unknown'] as Map<String, dynamic>
      ..change_changeBy_orig_ = json['change_changeBy_orig_'] as String
      ..changeAt = json['changeAt'] == null
          ? null
          : DateTime.parse(json['changeAt'] as String);

Map<String, dynamic> _$ConcreteEntityStateToJson(
        ConcreteEntityState instance) =>
    <String, dynamic>{
      'entityId': instance.entityId,
      'entityType': _$EntityTypeEnumMap[instance.entityType]!,
      'schemaVersion': instance.schemaVersion,
      'unknown': instance.unknown,
      'change_domainId': instance.change_domainId,
      'change_domainId_orig_': instance.change_domainId_orig_,
      'change_changeAt': instance.change_changeAt?.toIso8601String(),
      'change_changeAt_orig_':
          instance.change_changeAt_orig_?.toIso8601String(),
      'change_cid': instance.change_cid,
      'change_cid_orig_': instance.change_cid_orig_,
      'change_dataSchemaRev': instance.change_dataSchemaRev,
      'change_cloudAt': instance.change_cloudAt?.toIso8601String(),
      'change_cloudAt_orig_': instance.change_cloudAt_orig_?.toIso8601String(),
      'change_changeBy': instance.change_changeBy,
      'change_changeBy_orig_': instance.change_changeBy_orig_,
      'data_rank': instance.data_rank,
      'data_rank_dataSchemaRev': instance.data_rank_dataSchemaRev,
      'data_rank_changeAt_': instance.data_rank_changeAt_?.toIso8601String(),
      'data_rank_cid_': instance.data_rank_cid_,
      'data_rank_changeBy_': instance.data_rank_changeBy_,
      'data_rank_cloudAt_': instance.data_rank_cloudAt_?.toIso8601String(),
      'data_deleted': instance.data_deleted,
      'data_deleted_dataSchemaRev': instance.data_deleted_dataSchemaRev,
      'data_deleted_changeAt_':
          instance.data_deleted_changeAt_?.toIso8601String(),
      'data_deleted_cid_': instance.data_deleted_cid_,
      'data_deleted_changeBy_': instance.data_deleted_changeBy_,
      'data_deleted_cloudAt_':
          instance.data_deleted_cloudAt_?.toIso8601String(),
      'data_parentId': instance.data_parentId,
      'data_parentId_dataSchemaRev': instance.data_parentId_dataSchemaRev,
      'data_parentId_changeAt_':
          instance.data_parentId_changeAt_.toIso8601String(),
      'data_parentId_cid_': instance.data_parentId_cid_,
      'data_parentId_changeBy_': instance.data_parentId_changeBy_,
      'data_parentId_cloudAt_':
          instance.data_parentId_cloudAt_?.toIso8601String(),
      'changeAt': instance.changeAt?.toIso8601String(),
    };
