// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_serialization_service_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchemaVersion1 _$SchemaVersion1FromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SchemaVersion1',
      json,
      ($checkedConvert) {
        final val = SchemaVersion1(
          a: $checkedConvert('a', (v) => v as String),
          unknownJson: $checkedConvert('unknownJson', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$SchemaVersion1ToJson(SchemaVersion1 instance) =>
    <String, dynamic>{
      'a': instance.a,
      'unknownJson': instance.unknownJson,
    };

SchemaVersion2 _$SchemaVersion2FromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SchemaVersion2',
      json,
      ($checkedConvert) {
        final val = SchemaVersion2(
          a: $checkedConvert('a', (v) => v as String),
          b: $checkedConvert('b', (v) => v as String?),
          unknownJson: $checkedConvert('unknownJson', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$SchemaVersion2ToJson(SchemaVersion2 instance) =>
    <String, dynamic>{
      'a': instance.a,
      'b': instance.b,
      'unknownJson': instance.unknownJson,
    };
