// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamo_change_log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamoChangeLogEntry _$DynamoChangeLogEntryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DynamoChangeLogEntry', json, ($checkedConvert) {
  final val = DynamoChangeLogEntry(
    cid: $checkedConvert('cid', (v) => v as String),
    seq: $checkedConvert('seq', (v) => (v as num).toInt()),
    storageId: $checkedConvert('storageId', (v) => v as String),
    domainType: $checkedConvert('domainType', (v) => v as String),
    domainId: $checkedConvert('domainId', (v) => v as String),
    entityType: $checkedConvert('entityType', (v) => v as String),
    operation: $checkedConvert('operation', (v) => v as String),
    stateChanged: $checkedConvert('stateChanged', (v) => v as bool),
    changeAt: $checkedConvert(
      'changeAt',
      (v) => const UtcDateTimeConverter().fromJson(v as String),
    ),
    entityId: $checkedConvert('entityId', (v) => v as String),
    dataJson: $checkedConvert('dataJson', (v) => v as String),
    operationInfoJson: $checkedConvert(
      'operationInfoJson',
      (v) => v as String? ?? '{}',
    ),
    dataSchemaRev: $checkedConvert(
      'dataSchemaRev',
      (v) => (v as num?)?.toInt(),
    ),
    cloudAt: $checkedConvert(
      'cloudAt',
      (v) => _$JsonConverterFromJson<String, DateTime>(
        v,
        const UtcDateTimeConverter().fromJson,
      ),
    ),
    storedAt: $checkedConvert(
      'storedAt',
      (v) => _$JsonConverterFromJson<String, DateTime>(
        v,
        const UtcDateTimeConverter().fromJson,
      ),
    ),
    changeBy: $checkedConvert('changeBy', (v) => v as String),
    schemaVersion: $checkedConvert(
      'schemaVersion',
      (v) => (v as num?)?.toInt(),
    ),
    unknownJson: $checkedConvert('unknownJson', (v) => v as String? ?? '{}'),
  );
  return val;
});

Map<String, dynamic> _$DynamoChangeLogEntryToJson(
  DynamoChangeLogEntry instance,
) => <String, dynamic>{
  'storageId': instance.storageId,
  'domainType': instance.domainType,
  'domainId': instance.domainId,
  'entityType': instance.entityType,
  'operation': instance.operation,
  'operationInfoJson': instance.operationInfoJson,
  'stateChanged': instance.stateChanged,
  'changeAt': const UtcDateTimeConverter().toJson(instance.changeAt),
  'entityId': instance.entityId,
  'dataJson': instance.dataJson,
  'dataSchemaRev': instance.dataSchemaRev,
  'cloudAt': _$JsonConverterToJson<String, DateTime>(
    instance.cloudAt,
    const UtcDateTimeConverter().toJson,
  ),
  'storedAt': _$JsonConverterToJson<String, DateTime>(
    instance.storedAt,
    const UtcDateTimeConverter().toJson,
  ),
  'changeBy': instance.changeBy,
  'schemaVersion': instance.schemaVersion,
  'unknownJson': instance.unknownJson,
  'seq': instance.seq,
  'cid': instance.cid,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
