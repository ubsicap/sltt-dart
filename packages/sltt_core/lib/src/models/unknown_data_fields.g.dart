// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unknown_data_fields.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnknownDataFields _$UnknownDataFieldsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UnknownDataFields', json, ($checkedConvert) {
      final val = UnknownDataFields(
        parentId: $checkedConvert('parentId', (v) => v as String),
        parentProp: $checkedConvert('parentProp', (v) => v as String),
        rank: $checkedConvert('rank', (v) => v as String?),
        deleted: $checkedConvert('deleted', (v) => v as bool?),
        name: $checkedConvert('name', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$UnknownDataFieldsToJson(UnknownDataFields instance) =>
    <String, dynamic>{
      'parentId': instance.parentId,
      'parentProp': instance.parentProp,
      'rank': instance.rank,
      'deleted': instance.deleted,
      'name': instance.name,
    };
