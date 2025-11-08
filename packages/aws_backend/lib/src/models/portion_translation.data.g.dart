// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portion_translation.data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortionTranslationData _$PortionTranslationDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PortionTranslationData', json, ($checkedConvert) {
  final val = PortionTranslationData(
    name: $checkedConvert('name', (v) => v as String),
    visibility: $checkedConvert(
      'visibility',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    parentId: $checkedConvert('parentId', (v) => v as String),
    parentProp: $checkedConvert('parentProp', (v) => v as String),
    rank: $checkedConvert('rank', (v) => v as String?),
  );
  $checkedConvert('deleted', (v) => val.deleted = v as bool?);
  return val;
});

Map<String, dynamic> _$PortionTranslationDataToJson(
  PortionTranslationData instance,
) => <String, dynamic>{
  'parentId': instance.parentId,
  'parentProp': instance.parentProp,
  'rank': ?instance.rank,
  'deleted': ?instance.deleted,
  'name': instance.name,
  'visibility': instance.visibility,
};
