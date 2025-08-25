// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_serialization_service_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchemaVersion1 _$SchemaVersion1FromJson(Map<String, dynamic> json) =>
    SchemaVersion1(
      a: json['a'] as String,
      unknownJson: json['unknownJson'] as String? ?? '{}',
    );

Map<String, dynamic> _$SchemaVersion1ToJson(SchemaVersion1 instance) =>
    <String, dynamic>{
      'a': instance.a,
      'unknownJson': instance.unknownJson,
    };

SchemaVersion2 _$SchemaVersion2FromJson(Map<String, dynamic> json) =>
    SchemaVersion2(
      a: json['a'] as String,
      b: json['b'] as String,
      unknownJson: json['unknownJson'] as String? ?? '{}',
    );

Map<String, dynamic> _$SchemaVersion2ToJson(SchemaVersion2 instance) =>
    <String, dynamic>{
      'a': instance.a,
      'b': instance.b,
      'unknownJson': instance.unknownJson,
    };
