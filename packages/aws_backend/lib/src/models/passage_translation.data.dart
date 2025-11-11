// using portion translation data mapper as an exemplar, do the same for
// passage_translation.dart as it does for portion_translation.dart,
// making the fields isar-storage compatible

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'passage_translation.data.g.dart';

@JsonSerializable(includeIfNull: false, checked: true)
// @SyncableEntityStateData(entityType: kEntityTypePassage)
class PassageTranslationData extends BaseDataFields {
  final String name;
  final List<String> visibility;
  final String type;
  final String difficulty;
  final List<String> references;
  final List<String> tags;
  final bool includeInStatistics;

  PassageTranslationData({
    required this.name,
    required this.visibility,
    required this.type,
    required this.difficulty,
    required this.references,
    required this.tags,
    this.includeInStatistics = true,
    required super.parentId,
    required super.parentProp,
    required super.rank,
  });

  factory PassageTranslationData.fromJson(Map<String, dynamic> json) =>
      _$PassageTranslationDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PassageTranslationDataToJson(this);
}
