// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_data_fields.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseDataFields _$BaseDataFieldsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BaseDataFields', json, ($checkedConvert) {
      final val = BaseDataFields(
        parentId: $checkedConvert('parentId', (v) => v as String),
        parentProp: $checkedConvert('parentProp', (v) => v as String),
        rank: $checkedConvert('rank', (v) => v as String?),
        deleted: $checkedConvert('deleted', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$BaseDataFieldsToJson(BaseDataFields instance) =>
    <String, dynamic>{
      'parentId': instance.parentId,
      'parentProp': instance.parentProp,
      'rank': instance.rank,
      'deleted': instance.deleted,
    };
