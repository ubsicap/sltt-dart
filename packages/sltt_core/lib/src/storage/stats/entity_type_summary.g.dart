// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_type_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityTypeSummary _$EntityTypeSummaryFromJson(Map<String, dynamic> json) =>
    EntityTypeSummary(
      creates: (json['creates'] as num).toInt(),
      updates: (json['updates'] as num).toInt(),
      deletes: (json['deletes'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      latestChangeAt: json['latestChangeAt'] as String,
      latestSeq: (json['latestSeq'] as num).toInt(),
    );

Map<String, dynamic> _$EntityTypeSummaryToJson(EntityTypeSummary instance) =>
    <String, dynamic>{
      'creates': instance.creates,
      'updates': instance.updates,
      'deletes': instance.deletes,
      'total': instance.total,
      'latestChangeAt': instance.latestChangeAt,
      'latestSeq': instance.latestSeq,
    };
