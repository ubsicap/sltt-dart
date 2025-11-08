// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passage_translation.data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PassageTranslationData _$PassageTranslationDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PassageTranslationData', json, ($checkedConvert) {
  final val = PassageTranslationData(
    name: $checkedConvert('name', (v) => v as String),
    visibility: $checkedConvert(
      'visibility',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    type: $checkedConvert('type', (v) => v as String),
    difficulty: $checkedConvert('difficulty', (v) => v as String),
    references: $checkedConvert(
      'references',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    tags: $checkedConvert(
      'tags',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    includeInStatistics: $checkedConvert(
      'includeInStatistics',
      (v) => v as bool? ?? true,
    ),
    parentId: $checkedConvert('parentId', (v) => v as String),
    parentProp: $checkedConvert('parentProp', (v) => v as String),
    rank: $checkedConvert('rank', (v) => v as String?),
  );
  $checkedConvert('deleted', (v) => val.deleted = v as bool?);
  return val;
});

Map<String, dynamic> _$PassageTranslationDataToJson(
  PassageTranslationData instance,
) => <String, dynamic>{
  'parentId': instance.parentId,
  'parentProp': instance.parentProp,
  'rank': ?instance.rank,
  'deleted': ?instance.deleted,
  'name': instance.name,
  'visibility': instance.visibility,
  'type': instance.type,
  'difficulty': instance.difficulty,
  'references': instance.references,
  'tags': instance.tags,
  'includeInStatistics': instance.includeInStatistics,
};
