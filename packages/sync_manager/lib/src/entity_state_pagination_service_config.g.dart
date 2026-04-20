// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_state_pagination_service_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityStatePaginationServiceConfig _$EntityStatePaginationServiceConfigFromJson(
  Map<String, dynamic> json,
) => EntityStatePaginationServiceConfig(
  maxConcurrentRequests: (json['maxConcurrentRequests'] as num?)?.toInt() ?? 4,
  singleRequestDebounce: json['singleRequestDebounce'] == null
      ? const Duration(milliseconds: 300)
      : _durationFromMilliseconds(
          (json['singleRequestDebounce'] as num).toInt(),
        ),
  workspacePrefix: json['workspacePrefix'] as String? ?? '',
  persistJobs: json['persistJobs'] as bool? ?? true,
  persistenceDbDirectory:
      json['persistenceDbDirectory'] as String? ?? './isar_db',
  persistenceDbNamePrefix:
      json['persistenceDbNamePrefix'] as String? ??
      'entity_state_pagination_jobs',
  persistenceInspector: json['persistenceInspector'] as bool? ?? true,
  startProcessingOnInitialize:
      json['startProcessingOnInitialize'] as bool? ?? false,
);

Map<String, dynamic> _$EntityStatePaginationServiceConfigToJson(
  EntityStatePaginationServiceConfig instance,
) => <String, dynamic>{
  'maxConcurrentRequests': instance.maxConcurrentRequests,
  'singleRequestDebounce': _durationToMilliseconds(
    instance.singleRequestDebounce,
  ),
  'workspacePrefix': instance.workspacePrefix,
  'persistJobs': instance.persistJobs,
  'persistenceDbDirectory': instance.persistenceDbDirectory,
  'persistenceDbNamePrefix': instance.persistenceDbNamePrefix,
  'persistenceInspector': instance.persistenceInspector,
  'startProcessingOnInitialize': instance.startProcessingOnInitialize,
};
