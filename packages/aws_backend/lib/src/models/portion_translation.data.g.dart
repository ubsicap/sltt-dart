// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portion_translation.data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortionTranslationData _$PortionTranslationDataFromJson(
  Map<String, dynamic> json,
) => PortionTranslationData(
  name: json['name'] as String,
  visibility: json['visibility'] as String,
  parentId: json['parentId'] as String,
  parentProp: json['parentProp'] as String,
  rank: json['rank'] as String?,
);

Map<String, dynamic> _$PortionTranslationDataToJson(
  PortionTranslationData instance,
) => <String, dynamic>{
  'name': instance.name,
  'visibility': instance.visibility,
  'parentProp': instance.parentProp,
  'parentId': instance.parentId,
  'rank': instance.rank,
};
