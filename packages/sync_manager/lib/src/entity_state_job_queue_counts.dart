import 'package:json_annotation/json_annotation.dart';

part 'entity_state_job_queue_counts.g.dart';

@JsonSerializable()
class EntityStateJobQueueCounts {
  const EntityStateJobQueueCounts({
    required this.queuedSingle,
    required this.queuedCollection,
    required this.queuedTotal,
    required this.activeSingle,
    required this.activeCollection,
    required this.activeTotal,
    required this.enabled,
  });

  final int queuedSingle;
  final int queuedCollection;
  final int queuedTotal;
  final int activeSingle;
  final int activeCollection;
  final int activeTotal;
  final bool enabled;

  factory EntityStateJobQueueCounts.fromJson(Map<String, dynamic> json) =>
      _$EntityStateJobQueueCountsFromJson(json);

  Map<String, dynamic> toJson() => _$EntityStateJobQueueCountsToJson(this);
}
