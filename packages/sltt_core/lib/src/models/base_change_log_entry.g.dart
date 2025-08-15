// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_change_log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseChangeLogEntry _$BaseChangeLogEntryFromJson(Map<String, dynamic> json) =>
    BaseChangeLogEntry(
      projectId: json['projectId'] as String,
      entityType: $enumDecode(_$EntityTypeEnumMap, json['entityType']),
      operation: json['operation'] as String,
      stateChanged: json['stateChanged'] as bool,
      operationInfo: json['operationInfo'] as Map<String, dynamic>,
      changeAt: DateTime.parse(json['changeAt'] as String),
      entityId: json['entityId'] as String,
      data: json['data'] as Map<String, dynamic>,
      dataSchemaRev: (json['dataSchemaRev'] as num?)?.toInt(),
      cloudAt: json['cloudAt'] == null
          ? null
          : DateTime.parse(json['cloudAt'] as String),
      changeBy: json['changeBy'] as String,
      cid: json['cid'] as String,
      version: (json['version'] as num?)?.toInt(),
      unknown: json['unknown'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$BaseChangeLogEntryToJson(BaseChangeLogEntry instance) =>
    <String, dynamic>{
      'cid': instance.cid,
      'projectId': instance.projectId,
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
      'version': instance.version,
      'unknown': instance.unknown,
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
