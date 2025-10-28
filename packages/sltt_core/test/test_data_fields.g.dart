// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_data_fields.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestDataFields _$TestDataFieldsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TestDataFields', json, ($checkedConvert) {
      final val = TestDataFields(
        nameLocal: $checkedConvert('nameLocal', (v) => v as String),
        parentId: $checkedConvert('parentId', (v) => v as String),
        parentProp: $checkedConvert('parentProp', (v) => v as String),
        rank: $checkedConvert('rank', (v) => v as String?),
        deleted: $checkedConvert('deleted', (v) => v as bool?),
        nameOptionalField: $checkedConvert(
          'nameOptionalField',
          (v) => v as String?,
        ),
      );
      return val;
    });

Map<String, dynamic> _$TestDataFieldsToJson(TestDataFields instance) =>
    <String, dynamic>{
      'parentId': instance.parentId,
      'parentProp': instance.parentProp,
      'rank': instance.rank,
      'deleted': instance.deleted,
      'nameLocal': instance.nameLocal,
      'nameOptionalField': instance.nameOptionalField,
    };
