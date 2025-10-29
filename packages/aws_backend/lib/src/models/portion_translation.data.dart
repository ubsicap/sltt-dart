import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'portion_translation.data.g.dart';

@JsonSerializable(includeIfNull: true, checked: true)
// @SyncableEntityStateData(entityType: kEntityTypePortion)
class PortionTranslationData extends BaseDataFields {
  final String name;
  final String visibility;

  PortionTranslationData({
    required this.name,
    required this.visibility,
    required super.parentId,
    required super.parentProp,
    required super.rank,
  });

  factory PortionTranslationData.fromJson(Map<String, dynamic> json) =>
      _$PortionTranslationDataFromJson(json);

  Map<String, dynamic> toJson() => _$PortionTranslationDataToJson(this);
}
