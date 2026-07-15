import 'package:aws_backend/src/storage/key_codec.dart';
import 'package:aws_backend/src/storage/value_codec.dart';
import 'package:test/test.dart';

void main() {
  group('Value Codec', () {
    test('round-trips plain value', () {
      expect(decodeKeyValue(encodeKeyValue('hello')), equals('hello'));
    });

    test('round-trips all special characters', () {
      const value = 'a#b@c%d';
      expect(decodeKeyValue(encodeKeyValue(value)), equals(value));
    });

    test('does not misinterpret percent-encoded literal', () {
      const value = '%23';
      expect(decodeKeyValue(encodeKeyValue(value)), equals(value));
    });

    test('unicode is preserved', () {
      const value = 'smile😊日本#@%';
      expect(decodeKeyValue(encodeKeyValue(value)), equals(value));
    });

    test('needsEncoding detects special characters', () {
      expect(needsEncoding('clean'), isFalse);
      expect(needsEncoding('bad#'), isTrue);
      expect(needsEncoding('bad@'), isTrue);
      expect(needsEncoding('bad%'), isTrue);
    });
  });

  group('Key Codec', () {
    test('buildKey with labels only', () {
      final key = buildKey([KeyLabel(r'$sltt'), KeyLabel('change')]);
      expect(key, equals(r'$sltt#change'));
    });

    test('buildKey with fields encodes values', () {
      final key = buildKey([
        KeyLabel(r'$sltt'),
        KeyField('DOMAINTYPE', 'project#1'),
        KeyField('DOMAINID', 'abc@123'),
      ]);
      expect(key, equals(r'$sltt#@DOMAINTYPE#project%231#@DOMAINID#abc%40123'));
    });

    test('parseKey reads field segments correctly', () {
      final key = r'$sltt#@DOMAINTYPE#project%231#@DOMAINID#abc%40123';
      final segments = parseKey(key);
      expect(segments.length, equals(3));
      expect(segments[0], isA<KeyLabel>());
      expect((segments[1] as KeyField).name, equals('DOMAINTYPE'));
      expect((segments[1] as KeyField).value, equals('project#1'));
      expect((segments[2] as KeyField).name, equals('DOMAINID'));
      expect((segments[2] as KeyField).value, equals('abc@123'));
    });

    test('round-trip buildKey and parseKey preserves values', () {
      final segments = [
        KeyLabel(r'$sltt'),
        KeyLabel('change'),
        KeyField('DOMAINTYPE', 'project#1'),
        KeyField('DOMAINID', 'abc@123'),
      ];
      final key = buildKey(segments);
      final parsed = parseKey(key);
      expect(parsed.length, equals(segments.length));
      for (var i = 0; i < segments.length; i++) {
        final original = segments[i];
        final reconstructed = parsed[i];
        expect(reconstructed.runtimeType, equals(original.runtimeType));
        if (original is KeyField) {
          expect((reconstructed as KeyField).name, equals(original.name));
          expect(reconstructed.value, equals(original.value));
        } else {
          expect(
            (reconstructed as KeyLabel).value,
            equals((original as KeyLabel).value),
          );
        }
      }
    });

    test('assertSafeSortKeyValue throws for invalid sort-key values', () {
      expect(
        () => assertSafeSortKeyValue('bad#'),
        throwsA(isA<SortKeyEncodingViolation>()),
      );
      expect(
        () => assertSafeSortKeyValue('bad@'),
        throwsA(isA<SortKeyEncodingViolation>()),
      );
      expect(
        () => assertSafeSortKeyValue('bad%'),
        throwsA(isA<SortKeyEncodingViolation>()),
      );
    });
  });

  group('Key builders', () {
    test('change key family golden values', () {
      final pk = buildChangePrimaryKey(
        domainType: 'project',
        domainId: 'abc123',
        entityType: 'portion',
        entityId: 'entity1',
      );
      expect(
        pk,
        equals(
          r'$sltt#change#@DOMAINTYPE#project#@DOMAINID#abc123#@ENTITYTYPE#portion#@ENTITYID#entity1',
        ),
      );

      final prefix = buildChangePrimaryKeyPrefix(
        domainType: 'project',
        domainId: 'abc123',
      );
      expect(
        prefix,
        equals(r'$sltt#change#@DOMAINTYPE#project#@DOMAINID#abc123'),
      );

      final sk = buildChangeSortKey('1234567890');
      expect(sk, equals(r'$changes#change#@CID#1234567890'));

      final gsi1sk = buildChangeGsiSortKey(42);
      expect(gsi1sk, equals(r'seq#@VALUE#0000000000000000042'));
    });

    test('entity state gsi3 builder golden value', () {
      final pk = buildStateGsi3Partition(domainType: 'project');
      expect(pk, equals(r'$sltt#crossDomain#@DOMAINTYPE#project'));

      final sk = buildStateGsi3SortKey(
        entityType: 'project',
        entityId: 'projectId',
        domainId: 'projectId',
        changeAtOrig: '2023-01-01T00:00:00Z',
      );
      expect(
        sk,
        equals(
          r'states#@ENTITYTYPE#project#@ENTITYID#projectId#@DOMAINID#projectId#@CHANGEAT_ORIG#2023-01-01T00:00:00Z',
        ),
      );
    });
  });
}
