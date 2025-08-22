import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/src/services/json_serialization_service.dart';
import 'package:test/test.dart';

part 'json_serialization_service_test.g.dart';

void main() {
  test('SchemaVersion2 toJson() works as expected', () {
    final obj = SchemaVersion2(a: 'foo', b: 'bar');
    final json = obj.toJson();
    expect(json, containsPair('a', 'foo'));
    expect(json, containsPair('b', 'bar'));
    expect(json.length, 2);
  });

  test('SchemaVersion2.fromJson() works for its own json', () {
    final json = {'a': 'foo', 'b': 'bar'};
    final obj = SchemaVersion2.fromJson(json);
    expect(obj.a, 'foo');
    expect(obj.b, 'bar');
    expect(obj.unknown, isEmpty);
  });

  test('SchemaVersion1.fromJson() puts unknown fields in .unknown', () {
    final json = {'a': 'foo', 'b': 'bar'};
    final obj = SchemaVersion1.fromJson(json);
    expect(obj.a, 'foo');
    expect(obj.unknown, containsPair('b', 'bar'));
    expect(obj.unknown.length, 1);
  });

  test('SchemaVersion1.toJson() merges unknown fields', () {
    final obj = SchemaVersion1(a: 'foo', unknown: {'b': 'bar'});
    final json = obj.toJson();
    expect(json, containsPair('a', 'foo'));
    expect(json, containsPair('b', 'bar'));
    expect(json.length, 2);
  });
}

@JsonSerializable()
class SchemaVersion1 with HasUnknownField {
  final String a;
  @override
  String unknownJson;

  // Provide the JSON-string backed fields required by HasUnknownField.
  @override
  String dataJson = '{}';

  @override
  String operationInfoJson = '{}';

  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic> get unknown => getUnknown();

  SchemaVersion1({required this.a, Map<String, dynamic> unknown = const {}})
    : unknownJson = jsonEncode(unknown);

  factory SchemaVersion1.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData<SchemaVersion1>(
        _$SchemaVersion1FromJson,
        json,
        _$SchemaVersion1ToJson,
      );

  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData<SchemaVersion1>(
        this,
        _$SchemaVersion1ToJson,
      );
}

@JsonSerializable()
class SchemaVersion2 with HasUnknownField {
  final String a;
  final String b;
  @override
  String unknownJson;

  // Provide the JSON-string backed fields required by HasUnknownField.
  @override
  String dataJson = '{}';

  @override
  String operationInfoJson = '{}';

  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic> get unknown => getUnknown();

  SchemaVersion2({
    required this.a,
    required this.b,
    Map<String, dynamic> unknown = const {},
  }) : unknownJson = jsonEncode(unknown);

  factory SchemaVersion2.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData<SchemaVersion2>(
        _$SchemaVersion2FromJson,
        json,
        _$SchemaVersion2ToJson,
      );

  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData<SchemaVersion2>(
        this,
        _$SchemaVersion2ToJson,
      );
}
