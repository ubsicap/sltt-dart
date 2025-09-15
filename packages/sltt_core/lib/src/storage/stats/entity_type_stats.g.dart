// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_type_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityTypeStats _$EntityTypeStatsFromJson(Map<String, dynamic> json) =>
    EntityTypeStats(
      entityTypes: (json['entityTypes'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, EntityTypeSummary.fromJson(e as Map<String, dynamic>)),
      ),
      totals:
          EntityTypeSummary.fromJson(json['totals'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EntityTypeStatsToJson(EntityTypeStats instance) =>
    <String, dynamic>{
      'entityTypes':
          instance.entityTypes.map((k, e) => MapEntry(k, e.toJson())),
      'totals': instance.totals.toJson(),
    };
