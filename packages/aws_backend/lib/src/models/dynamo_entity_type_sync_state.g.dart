// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamo_entity_type_sync_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamoEntityTypeSyncState _$DynamoEntityTypeSyncStateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DynamoEntityTypeSyncState', json, ($checkedConvert) {
  final val = DynamoEntityTypeSyncState(
    entityType: $checkedConvert('entityType', (v) => v as String),
    domainId: $checkedConvert('domainId', (v) => v as String),
    domainType: $checkedConvert('domainType', (v) => v as String),
    storageId: $checkedConvert('storageId', (v) => v as String),
    storageType: $checkedConvert('storageType', (v) => v as String),
    cid: $checkedConvert('cid', (v) => v as String),
    changeAt: $checkedConvert('changeAt', (v) => DateTime.parse(v as String)),
    seq: $checkedConvert('seq', (v) => (v as num).toInt()),
    created: $checkedConvert('created', (v) => (v as num?)?.toInt() ?? 0),
    updated: $checkedConvert('updated', (v) => (v as num?)?.toInt() ?? 0),
    deleted: $checkedConvert('deleted', (v) => (v as num?)?.toInt() ?? 0),
    storedAt: $checkedConvert('storedAt', (v) => DateTime.parse(v as String)),
    storedAt_orig_: $checkedConvert(
      'storedAt_orig_',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$DynamoEntityTypeSyncStateToJson(
  DynamoEntityTypeSyncState instance,
) => <String, dynamic>{
  'domainId': instance.domainId,
  'domainType': instance.domainType,
  'storageId': instance.storageId,
  'storageType': instance.storageType,
  'cid': instance.cid,
  'changeAt': instance.changeAt.toIso8601String(),
  'seq': instance.seq,
  'storedAt': instance.storedAt.toIso8601String(),
  'storedAt_orig_': instance.storedAt_orig_?.toIso8601String(),
  'entityType': instance.entityType,
  'created': instance.created,
  'updated': instance.updated,
  'deleted': instance.deleted,
};
