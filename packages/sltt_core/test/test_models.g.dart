// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestChangeLogEntry _$TestChangeLogEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'TestChangeLogEntry',
      json,
      ($checkedConvert) {
        final val = TestChangeLogEntry(
          entityId: $checkedConvert('entityId', (v) => v as String),
          entityType: $checkedConvert('entityType', (v) => v as String),
          domainId: $checkedConvert('domainId', (v) => v as String),
          domainType: $checkedConvert('domainType', (v) => v as String),
          changeAt: $checkedConvert('changeAt',
              (v) => const UtcDateTimeConverter().fromJson(v as String)),
          cid: $checkedConvert('cid', (v) => v as String),
          storageId:
              $checkedConvert('storageId', (v) => v as String? ?? 'local'),
          changeBy: $checkedConvert('changeBy', (v) => v as String),
          dataJson: $checkedConvert('dataJson', (v) => v as String),
          operation: $checkedConvert('operation', (v) => v as String),
          operationInfoJson:
              $checkedConvert('operationInfoJson', (v) => v as String? ?? '{}'),
          stateChanged: $checkedConvert('stateChanged', (v) => v as bool),
          unknownJson:
              $checkedConvert('unknownJson', (v) => v as String? ?? '{}'),
          dataSchemaRev:
              $checkedConvert('dataSchemaRev', (v) => (v as num?)?.toInt()),
          cloudAt: $checkedConvert(
              'cloudAt',
              (v) => _$JsonConverterFromJson<String, DateTime>(
                  v, const UtcDateTimeConverter().fromJson)),
          schemaVersion:
              $checkedConvert('schemaVersion', (v) => (v as num?)?.toInt()),
          seq: $checkedConvert('seq', (v) => (v as num?)?.toInt() ?? 0),
        );
        return val;
      },
    );

Map<String, dynamic> _$TestChangeLogEntryToJson(TestChangeLogEntry instance) =>
    <String, dynamic>{
      'cid': instance.cid,
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
          instance.cloudAt, const UtcDateTimeConverter().toJson),
      'changeBy': instance.changeBy,
      'schemaVersion': instance.schemaVersion,
      'unknownJson': instance.unknownJson,
      'seq': instance.seq,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

TestEntityState _$TestEntityStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'TestEntityState',
      json,
      ($checkedConvert) {
        final val = TestEntityState(
          data_nameLocal: $checkedConvert('data_nameLocal', (v) => v as String),
          entityId: $checkedConvert('entityId', (v) => v as String),
          entityType: $checkedConvert('entityType', (v) => v as String),
          schemaVersion:
              $checkedConvert('schemaVersion', (v) => (v as num?)?.toInt()),
          change_domainId:
              $checkedConvert('change_domainId', (v) => v as String),
          change_domainId_orig_:
              $checkedConvert('change_domainId_orig_', (v) => v as String?),
          change_changeAt: $checkedConvert(
              'change_changeAt', (v) => DateTime.parse(v as String)),
          change_changeAt_orig_: $checkedConvert('change_changeAt_orig_',
              (v) => v == null ? null : DateTime.parse(v as String)),
          change_cid: $checkedConvert('change_cid', (v) => v as String),
          change_cid_orig_:
              $checkedConvert('change_cid_orig_', (v) => v as String?),
          change_dataSchemaRev: $checkedConvert(
              'change_dataSchemaRev', (v) => (v as num?)?.toInt()),
          change_cloudAt: $checkedConvert('change_cloudAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
          change_cloudAt_orig_: $checkedConvert('change_cloudAt_orig_',
              (v) => v == null ? null : DateTime.parse(v as String)),
          change_changeBy:
              $checkedConvert('change_changeBy', (v) => v as String),
          data_rank_dataSchemaRev_: $checkedConvert(
              'data_rank_dataSchemaRev_', (v) => (v as num?)?.toInt()),
          data_rank: $checkedConvert('data_rank', (v) => v as String?),
          data_rank_changeAt_: $checkedConvert('data_rank_changeAt_',
              (v) => v == null ? null : DateTime.parse(v as String)),
          data_rank_cid_:
              $checkedConvert('data_rank_cid_', (v) => v as String?),
          data_rank_changeBy_:
              $checkedConvert('data_rank_changeBy_', (v) => v as String?),
          data_rank_cloudAt_: $checkedConvert('data_rank_cloudAt_',
              (v) => v == null ? null : DateTime.parse(v as String)),
          data_deleted: $checkedConvert('data_deleted', (v) => v as bool?),
          data_deleted_dataSchemaRev_: $checkedConvert(
              'data_deleted_dataSchemaRev_', (v) => (v as num?)?.toInt()),
          data_deleted_changeAt_: $checkedConvert('data_deleted_changeAt_',
              (v) => v == null ? null : DateTime.parse(v as String)),
          data_deleted_cid_:
              $checkedConvert('data_deleted_cid_', (v) => v as String?),
          data_deleted_changeBy_:
              $checkedConvert('data_deleted_changeBy_', (v) => v as String?),
          data_deleted_cloudAt_: $checkedConvert('data_deleted_cloudAt_',
              (v) => v == null ? null : DateTime.parse(v as String)),
          data_parentId: $checkedConvert('data_parentId', (v) => v as String),
          data_parentId_dataSchemaRev_: $checkedConvert(
              'data_parentId_dataSchemaRev_', (v) => (v as num?)?.toInt()),
          data_parentId_changeAt_: $checkedConvert(
              'data_parentId_changeAt_', (v) => DateTime.parse(v as String)),
          data_parentId_cid_:
              $checkedConvert('data_parentId_cid_', (v) => v as String),
          data_parentId_changeBy_:
              $checkedConvert('data_parentId_changeBy_', (v) => v as String),
          data_parentId_cloudAt_: $checkedConvert('data_parentId_cloudAt_',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        $checkedConvert('unknownJson', (v) => val.unknownJson = v as String);
        $checkedConvert('change_changeBy_orig_',
            (v) => val.change_changeBy_orig_ = v as String);
        return val;
      },
    );

Map<String, dynamic> _$TestEntityStateToJson(TestEntityState instance) =>
    <String, dynamic>{
      'data_nameLocal': instance.data_nameLocal,
      'entityId': instance.entityId,
      'entityType': instance.entityType,
      'schemaVersion': instance.schemaVersion,
      'unknownJson': instance.unknownJson,
      'change_domainId': instance.change_domainId,
      'change_domainId_orig_': instance.change_domainId_orig_,
      'change_changeAt': instance.change_changeAt.toIso8601String(),
      'change_changeAt_orig_': instance.change_changeAt_orig_.toIso8601String(),
      'change_cid': instance.change_cid,
      'change_cid_orig_': instance.change_cid_orig_,
      'change_dataSchemaRev': instance.change_dataSchemaRev,
      'change_cloudAt': instance.change_cloudAt?.toIso8601String(),
      'change_cloudAt_orig_': instance.change_cloudAt_orig_?.toIso8601String(),
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
    };
