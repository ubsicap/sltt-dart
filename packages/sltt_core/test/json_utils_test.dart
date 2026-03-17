import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

/// Helper: independently compute the expected hash value for a given map.
String _expectedHash(Map<String, dynamic> fields) {
  final stable = stableStringify(fields);
  final digest = md5.convert(utf8.encode(stable));
  return base64.encode(digest.bytes);
}

void main() {
  group('computeStateDataHash', () {
    test('hashes a single data_ field', () {
      final hash = computeStateDataHash({'data_rank': '1'});
      expect(hash, equals(_expectedHash({'data_rank': '1'})));
      expect(hash, isNotEmpty);
    });

    test('hashes multiple data_ fields in a stable (sorted) order', () {
      final hashAB = computeStateDataHash({'data_a': 'x', 'data_b': 'y'});
      final hashBA = computeStateDataHash({'data_b': 'y', 'data_a': 'x'});
      // Order of insertion must not affect the hash
      expect(hashAB, equals(hashBA));
      expect(hashAB, equals(_expectedHash({'data_a': 'x', 'data_b': 'y'})));
    });

    test('different values produce different hashes', () {
      final hash1 = computeStateDataHash({'data_rank': '1'});
      final hash2 = computeStateDataHash({'data_rank': '2'});
      expect(hash1, isNot(equals(hash2)));
    });

    test('filters out non-data_ keys', () {
      final hashWithExtra = computeStateDataHash({
        'data_rank': '1',
        'change_cid': 'cid1',
        'entityId': 'e1',
        'unknownJson': '{}',
      });
      final hashDataOnly = computeStateDataHash({'data_rank': '1'});
      expect(hashWithExtra, equals(hashDataOnly));
    });

    test('filters out null data_ values', () {
      final hashWithNull = computeStateDataHash({
        'data_rank': '1',
        'data_deleted': null,
      });
      final hashWithoutNull = computeStateDataHash({'data_rank': '1'});
      expect(hashWithNull, equals(hashWithoutNull));
    });

    test('includes metadata data_ keys (ending with _)', () {
      final hashWithMeta = computeStateDataHash({
        'data_rank': '1',
        'data_rank_changeAt_': '2023-01-01T00:00:00Z',
        'data_rank_cid_': 'cid1',
      });
      final hashWithoutMeta = computeStateDataHash({'data_rank': '1'});
      // Metadata keys are included in the hash
      expect(hashWithMeta, isNot(equals(hashWithoutMeta)));
      expect(
        hashWithMeta,
        equals(
          _expectedHash({
            'data_rank': '1',
            'data_rank_changeAt_': '2023-01-01T00:00:00Z',
            'data_rank_cid_': 'cid1',
          }),
        ),
      );
    });

    test('throws when no non-null data_ fields are present', () {
      expect(
        () => computeStateDataHash({}),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('No non-null data_ fields'),
          ),
        ),
      );
    });

    test('throws when all data_ fields are null', () {
      expect(
        () => computeStateDataHash({'data_rank': null, 'data_deleted': null}),
        throwsA(isA<Exception>()),
      );
    });

    test('throws when only non-data_ fields are present', () {
      expect(
        () => computeStateDataHash({'change_cid': 'cid1', 'entityId': 'e1'}),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'produces a base64-encoded MD5 string (22 chars, no padding issues)',
      () {
        final hash = computeStateDataHash({'data_rank': '1'});
        // MD5 is 16 bytes → base64 is ceil(16*4/3) = 24 chars (with padding)
        expect(hash.length, equals(24));
        // Must be valid base64
        expect(() => base64.decode(hash), returnsNormally);
      },
    );

    test('identical maps produce identical hashes (determinism)', () {
      final map = {
        'data_nameLocal': 'Hello',
        'data_rank': '3',
        'data_parentId': 'parent1',
      };
      final hash1 = computeStateDataHash(map);
      final hash2 = computeStateDataHash(map);
      expect(hash1, equals(hash2));
    });

    test('adding a new data_ field changes the hash', () {
      final hashA = computeStateDataHash({'data_rank': '1'});
      final hashB = computeStateDataHash({
        'data_rank': '1',
        'data_parentId': 'p1',
      });
      expect(hashA, isNot(equals(hashB)));
    });

    test('handles numeric and bool data_ values', () {
      final hash = computeStateDataHash({
        'data_count': 42,
        'data_active': true,
      });
      expect(
        hash,
        equals(_expectedHash({'data_count': 42, 'data_active': true})),
      );
    });
  });

  group('stableStringify', () {
    test('sorts map keys recursively', () {
      final result = stableStringify({'b': 2, 'a': 1});
      final decoded = jsonDecode(result) as Map;
      expect(decoded.keys.toList(), equals(['a', 'b']));
    });

    test('sorts nested map keys', () {
      final result = stableStringify({
        'outer': {'z': 26, 'a': 1},
      });
      final decoded = jsonDecode(result) as Map;
      final inner = decoded['outer'] as Map;
      expect(inner.keys.toList(), equals(['a', 'z']));
    });

    test('returns string values as-is (no double-encoding)', () {
      final result = stableStringify('hello');
      expect(result, equals('hello'));
    });

    test('handles lists of maps by sorting each map\'s keys', () {
      final result = stableStringify([
        {'b': 2, 'a': 1},
      ]);
      final decoded = jsonDecode(result) as List;
      final first = decoded[0] as Map;
      expect(first.keys.toList(), equals(['a', 'b']));
    });
  });
}
