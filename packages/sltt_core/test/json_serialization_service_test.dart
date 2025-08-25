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
    expect(json, containsPair('unknownJson', '{}'));
    expect(json.length, 3);
  });

  test('SchemaVersion2.fromJson() works for its own json', () {
    final json = {'a': 'foo', 'b': 'bar'};
    final obj = SchemaVersion2.fromJson(json);
    expect(obj.a, 'foo');
    expect(obj.b, 'bar');
    expect(obj.unknownJson, '{}');
    expect(obj.getUnknown(), isEmpty);
  });

  test('SchemaVersion1.fromJson() puts unknown fields in .unknown', () {
    final json = {'a': 'foo', 'b': 'bar'};
    final obj = SchemaVersion1.fromJson(json);
    expect(obj.a, 'foo');
    expect(obj.unknownJson, equals('{"b":"bar"}'));
    expect(obj.getUnknown(), equals({'b': 'bar'}));
  });

  test('SchemaVersion1.toJson() merges unknown fields', () {
    final obj = SchemaVersion1(a: 'foo', unknownJson: '{"b": "bar"}');
    final json = obj.toJson();
    expect(json, containsPair('a', 'foo'));
    expect(json, containsPair('b', 'bar'));
    expect(json, containsPair('unknownJson', '{"b": "bar"}'));
    expect(json.length, 3);
  });
}

@JsonSerializable()
class SchemaVersion1 with HasUnknownField {
  final String a;
  @override
  String unknownJson;

  Map<String, dynamic> get unknown => getUnknown();

  SchemaVersion1({required this.a, this.unknownJson = '{}'});

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

  SchemaVersion2({required this.a, required this.b, this.unknownJson = '{}'});

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
