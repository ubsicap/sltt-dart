// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_state_job_queue_counts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityStateJobQueueCounts _$EntityStateJobQueueCountsFromJson(
  Map<String, dynamic> json,
) => EntityStateJobQueueCounts(
  queuedSingle: (json['queuedSingle'] as num).toInt(),
  queuedCollection: (json['queuedCollection'] as num).toInt(),
  queuedTotal: (json['queuedTotal'] as num).toInt(),
  activeSingle: (json['activeSingle'] as num).toInt(),
  activeCollection: (json['activeCollection'] as num).toInt(),
  activeTotal: (json['activeTotal'] as num).toInt(),
  enabled: json['enabled'] as bool,
);

Map<String, dynamic> _$EntityStateJobQueueCountsToJson(
  EntityStateJobQueueCounts instance,
) => <String, dynamic>{
  'queuedSingle': instance.queuedSingle,
  'queuedCollection': instance.queuedCollection,
  'queuedTotal': instance.queuedTotal,
  'activeSingle': instance.activeSingle,
  'activeCollection': instance.activeCollection,
  'activeTotal': instance.activeTotal,
  'enabled': instance.enabled,
};
