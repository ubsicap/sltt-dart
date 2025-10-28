// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_data_fields.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectDataFields _$ProjectDataFieldsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProjectDataFields', json, ($checkedConvert) {
      final val = ProjectDataFields(
        parentId: $checkedConvert('parentId', (v) => v as String),
        parentProp: $checkedConvert('parentProp', (v) => v as String),
        rank: $checkedConvert('rank', (v) => v as String?),
        deleted: $checkedConvert('deleted', (v) => v as bool?),
        nameLocal: $checkedConvert('nameLocal', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ProjectDataFieldsToJson(ProjectDataFields instance) =>
    <String, dynamic>{
      'parentId': instance.parentId,
      'parentProp': instance.parentProp,
      'rank': instance.rank,
      'deleted': instance.deleted,
      'nameLocal': instance.nameLocal,
    };
