import 'package:sltt_core/src/utils/json_utils.dart';
import 'package:test/test.dart';

void main() {
  group('stableStringify', () {
    test('sorts map keys recursively', () {
      final map = {
        'b': 2,
        'a': 1,
        'c': {'z': 9, 'y': 8},
      };
      expect(stableStringify(map), '{"a":1,"b":2,"c":{"y":8,"z":9}}');
    });

    test('handles lists', () {
      final list = [3, 2, 1];
      expect(stableStringify(list), '[3,2,1]');
    });

    test('handles nested lists and maps', () {
      final data = {
        'x': [
          {'b': 2, 'a': 1},
          {'d': 4, 'c': 3},
        ],
      };
      expect(stableStringify(data), '{"x":[{"a":1,"b":2},{"c":3,"d":4}]}');
    });

    test('handles primitives', () {
      expect(stableStringify(42), '42');
      expect(stableStringify('foo'), 'foo');
      expect(stableStringify(true), 'true');
      expect(stableStringify(null), 'null');
    });

    test('does not double-encode JSON strings', () {
      final alreadyJson = '{"a":1}';
      // Should treat as a string, not as a map
      expect(stableStringify(alreadyJson), alreadyJson);
    });
  });
}
