import 'package:json_annotation/json_annotation.dart';
import 'entity_type_summary.dart';

part 'entity_type_stats.g.dart';

@JsonSerializable()
class EntityTypeStats {
  final Map<String, EntityTypeSummary> entityTypes;
  final EntityTypeSummary totals;

  EntityTypeStats({required this.entityTypes, required this.totals});

  factory EntityTypeStats.fromJson(Map<String, dynamic> json) =>
      _$EntityTypeStatsFromJson(json);

  Map<String, dynamic> toJson() => _$EntityTypeStatsToJson(this);
}
