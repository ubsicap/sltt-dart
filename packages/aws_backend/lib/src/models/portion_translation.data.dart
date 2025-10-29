import 'package:json_annotation/json_annotation.dart';

part 'portion_translation.data.g.dart';

@JsonSerializable(includeIfNull: true)
// @SyncableEntityStateData(entityType: kEntityTypePortion)
class PortionTranslationData {
  final String name;
  final String visibility;
  // TODO: extend from CoreData with parentId and parentProp
  final String parentProp;
  final String parentId;
  final String? rank;

  PortionTranslationData({
    required this.name,
    required this.visibility,
    required this.parentId,
    required this.parentProp,
    required this.rank,
  });

  factory PortionTranslationData.fromJson(Map<String, dynamic> json) =>
      _$PortionTranslationDataFromJson(json);

  Map<String, dynamic> toJson() => _$PortionTranslationDataToJson(this);
}
