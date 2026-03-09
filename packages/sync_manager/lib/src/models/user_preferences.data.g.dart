// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferencesData _$UserPreferencesDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UserPreferencesData', json, ($checkedConvert) {
      final val = UserPreferencesData(
        parentId: $checkedConvert('parentId', (v) => v as String),
        parentProp: $checkedConvert('parentProp', (v) => v as String),
        rank: $checkedConvert('rank', (v) => v as String?),
        deleted: $checkedConvert('deleted', (v) => v as bool?),
        uiLocale: $checkedConvert('uiLocale', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$UserPreferencesDataToJson(
  UserPreferencesData instance,
) => <String, dynamic>{
  'parentId': instance.parentId,
  'parentProp': instance.parentProp,
  'rank': ?instance.rank,
  'deleted': ?instance.deleted,
  'uiLocale': instance.uiLocale,
};
