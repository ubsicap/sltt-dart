import 'package:json_annotation/json_annotation.dart';

part 'entity_type_summary.g.dart';

@JsonSerializable()
class EntityTypeSummary {
  final int creates;
  final int updates;
  final int deletes;
  final int total;

  /// ISO 8601 string for the latest change time for this entity type. Never null.
  final String latestChangeAt;

  /// Latest sequence number for this entity type. Use `-1` when no changes exist.
  final int latestSeq;

  EntityTypeSummary({
    required this.creates,
    required this.updates,
    required this.deletes,
    required this.total,
    required this.latestChangeAt,
    required this.latestSeq,
  });

  factory EntityTypeSummary.fromJson(Map<String, dynamic> json) =>
      _$EntityTypeSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$EntityTypeSummaryToJson(this);
}
