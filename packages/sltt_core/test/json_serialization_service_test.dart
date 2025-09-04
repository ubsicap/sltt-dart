import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/src/services/json_serialization_service.dart';
import 'package:test/test.dart';

part 'json_serialization_service_test.g.dart';

// Small helper class that simulates a model with an annotated field.
class _Annotated {
  @UtcDateTimeConverter()
  final DateTime ts;
  _Annotated({required this.ts});

  factory _Annotated.fromJson(Map<String, dynamic> j) =>
      _Annotated(ts: const UtcDateTimeConverter().fromJson(j['ts'] as String));

  Map<String, dynamic> toJson() => {
    'ts': const UtcDateTimeConverter().toJson(ts),
  };
}

void main() {
  group('UtcDateTimeConverter', () {
    test('round-trips and normalizes to UTC', () {
      const conv = UtcDateTimeConverter();
      // input with +02:00 offset
      final input = '2023-01-01T12:34:56+02:00';
      final dt = conv.fromJson(input);
      // normalized to UTC
      expect(dt.isUtc, isTrue);
      expect(
        dt.toIso8601String(),
        equals(DateTime.parse(input).toUtc().toIso8601String()),
      );

      final out = conv.toJson(dt);
      expect(out, equals(dt.toUtc().toIso8601String()));

      // Also ensure Z-formatted (already-UTC) timestamps round-trip as-is
      final inputZ = '2023-01-01T10:00:00.000Z';
      final dtZ = conv.fromJson(inputZ);
      expect(dtZ.isUtc, isTrue);
      expect(conv.toJson(dtZ), equals(inputZ));
    });

    test(
      'Annotated field serializes/deserializes using UtcDateTimeConverter',
      () {
        final src = DateTime.parse('2023-01-01T12:34:56+02:00');
        final obj = _Annotated(ts: src);
        final json = obj.toJson();
        expect(json['ts'], isA<String>());
        final got = _Annotated.fromJson(json);
        expect(got.ts, equals(src.toUtc()));
      },
    );
  });

  group('SchemaVersion', () {
    test('SchemaVersion2 toJson() works as expected', () {
      final obj = SchemaVersion2(a: 'foo', b: 'bar', unknownJson: '{}');
      final json = obj.toJson();
      expect(json, {'a': 'foo', 'b': 'bar', 'unknownJson': '{}'});
    });

    test('SchemaVersion2 toJson() with removed optional fields', () {
      final obj = SchemaVersion2(a: 'foo', unknownJson: '{}');
      final json = obj.toJson();
      expect(json, {'a': 'foo', 'unknownJson': '{}'});
    });

    test('SchemaVersion2.fromJson() works for its own json', () {
      final json = {'a': 'foo', 'b': 'bar', 'unknownJson': '{}'};
      final obj = SchemaVersion2.fromJson(json);
      expect(obj.a, 'foo');
      expect(obj.b, 'bar');
      expect(obj.unknownJson, '{}');
      expect(obj.getUnknown(), isEmpty);
    });

    test('SchemaVersion2.fromJson() upgrades SchemaVersion1 unknownJson', () {
      final json = {'a': 'foo', 'unknownJson': '{"b": "bar"}'};
      final obj = SchemaVersion2.fromJson(json);
      expect(obj.a, 'foo');
      expect(obj.b, 'bar');
      expect(obj.unknownJson, '{}');
      expect(obj.getUnknown(), isEmpty);
    });

    test('SchemaVersion1.fromJson() puts unknown fields in .unknown', () {
      final json = {'a': 'foo', 'b': 'bar', 'unknownJson': '{}'};
      final obj = SchemaVersion1.fromJson(json);
      expect(obj.a, 'foo');
      expect(obj.unknownJson, equals('{"b":"bar"}'));
      expect(obj.getUnknown(), equals({'b': 'bar'}));
    });

    test(
      'SchemaVersion1.toJson() adds unknown to keys and resets unknownJson',
      () {
        final obj = SchemaVersion1(a: 'foo', unknownJson: '{"b": "bar"}');
        final json = obj.toJson();
        expect(json, {'a': 'foo', 'b': 'bar', 'unknownJson': '{}'});
      },
    );

    test('SchemaVersion1.toJson() merges unknownJson with unknown field', () {
      final json = {'a': 'foo', 'unknownJson': '{"b": "bar"}', 'c': 'cVal'};
      final obj = SchemaVersion1.fromJson(json);
      expect(obj.a, 'foo');
      expect(obj.unknownJson, equals('{"b":"bar","c":"cVal"}'));
      expect(obj.getUnknown(), {'b': 'bar', 'c': 'cVal'});
    });

    test('SchemaVersion1.toJson() roundTrip - resetting unknownJson', () {
      final json = {'a': 'foo', 'b': 'bar', 'c': 'cVal', 'unknownJson': '{}'};
      final obj = SchemaVersion1.fromJson(json);
      expect(obj.a, 'foo');
      expect(obj.unknownJson, equals('{"b":"bar","c":"cVal"}'));
      expect(obj.getUnknown(), {'b': 'bar', 'c': 'cVal'});
      final out = obj.toJson();
      expect(out, json);
    });
  });
}

@JsonSerializable(includeIfNull: true, checked: true)
class SchemaVersion1 with HasUnknownField {
  final String a;
  @override
  String unknownJson;

  Map<String, dynamic> get unknown => getUnknown();

  // alternative:   SchemaVersion1({required this.a, this.unknownJson = '{}'});
  SchemaVersion1({required this.a, required this.unknownJson});

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

@JsonSerializable(includeIfNull: true, checked: true)
class SchemaVersion2 with HasUnknownField {
  final String a;
  final String? b;
  @override
  String unknownJson;

  SchemaVersion2({required this.a, this.b, required this.unknownJson});

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
