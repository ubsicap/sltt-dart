import 'package:json_annotation/json_annotation.dart';

part 'entity_state_pagination_service_config.g.dart';

@JsonSerializable()
class EntityStatePaginationServiceConfig {
  const EntityStatePaginationServiceConfig({
    this.maxConcurrentRequests = 4,
    this.singleRequestDebounce = const Duration(milliseconds: 300),
    this.workspacePrefix = '',
    this.persistJobs = true,
    this.persistenceDbDirectory = './isar_db',
    this.persistenceDbNamePrefix = 'entity_state_pagination_jobs',
    this.persistenceInspector = true,
    this.startProcessingOnInitialize = false,
  });

  final int maxConcurrentRequests;

  @JsonKey(fromJson: _durationFromMilliseconds, toJson: _durationToMilliseconds)
  final Duration singleRequestDebounce;

  final String workspacePrefix;
  final bool persistJobs;
  final String persistenceDbDirectory;
  final String persistenceDbNamePrefix;
  final bool persistenceInspector;
  final bool startProcessingOnInitialize;

  factory EntityStatePaginationServiceConfig.fromJson(
    Map<String, dynamic> json,
  ) => _$EntityStatePaginationServiceConfigFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EntityStatePaginationServiceConfigToJson(this);
}

Duration _durationFromMilliseconds(int milliseconds) =>
    Duration(milliseconds: milliseconds);

int _durationToMilliseconds(Duration duration) => duration.inMilliseconds;
