// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marker.data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarkerData _$MarkerDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MarkerData', json, ($checkedConvert) {
      final val = MarkerData(
        colorValue: $checkedConvert('colorValue', (v) => (v as num).toInt()),
        shape: $checkedConvert('shape', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        parentId: $checkedConvert('parentId', (v) => v as String),
        parentProp: $checkedConvert('parentProp', (v) => v as String),
        rank: $checkedConvert('rank', (v) => v as String?),
        deleted: $checkedConvert('deleted', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$MarkerDataToJson(MarkerData instance) =>
    <String, dynamic>{
      'parentId': instance.parentId,
      'parentProp': instance.parentProp,
      'rank': ?instance.rank,
      'deleted': ?instance.deleted,
      'colorValue': instance.colorValue,
      'shape': instance.shape,
      'description': instance.description,
    };
