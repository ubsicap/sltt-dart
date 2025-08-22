// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientChangeLogEntry _$ClientChangeLogEntryFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'ClientChangeLogEntry',
      json,
      ($checkedConvert) {
        final val = ClientChangeLogEntry(
          domainId: $checkedConvert('domainId', (v) => v as String),
          entityType: $checkedConvert(
              'entityType', (v) => $enumDecode(_$EntityTypeEnumMap, v)),
          operation: $checkedConvert('operation', (v) => v as String),
          changeAt:
              $checkedConvert('changeAt', (v) => DateTime.parse(v as String)),
          entityId: $checkedConvert('entityId', (v) => v as String),
          data: $checkedConvert(
              'data', (v) => v == null ? const {} : _jsonToMap(v)),
          cloudAt: $checkedConvert(
              'cloudAt', (v) => v == null ? null : DateTime.parse(v as String)),
          changeBy: $checkedConvert('changeBy', (v) => v as String),
          cid: $checkedConvert('cid', (v) => v as String),
          storageId: $checkedConvert('storageId', (v) => v as String),
          domainType: $checkedConvert('domainType', (v) => v as String),
          stateChanged: $checkedConvert('stateChanged', (v) => v as bool),
          operationInfo: $checkedConvert(
              'operationInfo', (v) => v == null ? const {} : _jsonToMap(v)),
          unknown: $checkedConvert(
              'unknown', (v) => v == null ? const {} : _jsonToMap(v)),
          dataSchemaRev:
              $checkedConvert('dataSchemaRev', (v) => (v as num?)?.toInt()),
          schemaVersion:
              $checkedConvert('schemaVersion', (v) => (v as num?)?.toInt()),
        );
        $checkedConvert('seq', (v) => val.seq = (v as num).toInt());
        return val;
      },
    );

Map<String, dynamic> _$ClientChangeLogEntryToJson(
        ClientChangeLogEntry instance) =>
    <String, dynamic>{
      'seq': instance.seq,
      'cid': instance.cid,
      'storageId': instance.storageId,
      'domainType': instance.domainType,
      'domainId': instance.domainId,
      'entityType': _$EntityTypeEnumMap[instance.entityType]!,
      'entityId': instance.entityId,
      'changeAt': instance.changeAt.toIso8601String(),
      'changeBy': instance.changeBy,
      'operation': instance.operation,
      'data': _mapToJson(instance.data),
      'operationInfo': _mapToJson(instance.operationInfo),
      'stateChanged': instance.stateChanged,
      'cloudAt': instance.cloudAt?.toIso8601String(),
      'dataSchemaRev': instance.dataSchemaRev,
      'schemaVersion': instance.schemaVersion,
      'unknown': _mapToJson(instance.unknown),
    };

const _$EntityTypeEnumMap = {
  EntityType.unknown: 'unknown',
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
