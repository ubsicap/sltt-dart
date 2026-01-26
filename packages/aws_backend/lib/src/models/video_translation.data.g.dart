// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_translation.data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoTranslationData _$VideoTranslationDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('VideoTranslationData', json, ($checkedConvert) {
  final val = VideoTranslationData(
    name: $checkedConvert('name', (v) => v as String),
    visibility: $checkedConvert(
      'visibility',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    storedFilename: $checkedConvert('storedFilename', (v) => v as String),
    durationMs: $checkedConvert('durationMs', (v) => (v as num).toInt()),
    parentId: $checkedConvert('parentId', (v) => v as String),
    parentProp: $checkedConvert('parentProp', (v) => v as String),
    rank: $checkedConvert('rank', (v) => v as String?),
  );
  $checkedConvert('deleted', (v) => val.deleted = v as bool?);
  return val;
});

Map<String, dynamic> _$VideoTranslationDataToJson(
  VideoTranslationData instance,
) => <String, dynamic>{
  'parentId': instance.parentId,
  'parentProp': instance.parentProp,
  'rank': ?instance.rank,
  'deleted': ?instance.deleted,
  'name': instance.name,
  'visibility': instance.visibility,
  'storedFilename': instance.storedFilename,
  'durationMs': instance.durationMs,
};
