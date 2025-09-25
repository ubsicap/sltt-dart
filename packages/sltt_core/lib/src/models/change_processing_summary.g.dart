// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_processing_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeProcessingSummary _$ChangeProcessingSummaryFromJson(
  Map<String, dynamic> json,
) => ChangeProcessingSummary(
  storageType: json['storageType'] as String,
  storageId: json['storageId'] as String,
  stateUpdates: (json['stateUpdates'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  changeUpdates: (json['changeUpdates'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  created: (json['created'] as List<dynamic>).map((e) => e as String).toList(),
  updated: (json['updated'] as List<dynamic>).map((e) => e as String).toList(),
  deleted: (json['deleted'] as List<dynamic>).map((e) => e as String).toList(),
  noOps: (json['noOps'] as List<dynamic>).map((e) => e as String).toList(),
  clouded: (json['clouded'] as List<dynamic>).map((e) => e as String).toList(),
  dups: (json['dups'] as List<dynamic>).map((e) => e as String).toList(),
  unknowns: (json['unknowns'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  info: (json['info'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  errors: (json['errors'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  unprocessed: (json['unprocessed'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ChangeProcessingSummaryToJson(
  ChangeProcessingSummary instance,
) => <String, dynamic>{
  'storageType': instance.storageType,
  'storageId': instance.storageId,
  'stateUpdates': instance.stateUpdates,
  'changeUpdates': instance.changeUpdates,
  'created': instance.created,
  'updated': instance.updated,
  'deleted': instance.deleted,
  'noOps': instance.noOps,
  'clouded': instance.clouded,
  'dups': instance.dups,
  'unknowns': instance.unknowns,
  'info': instance.info,
  'errors': instance.errors,
  'unprocessed': instance.unprocessed,
};
