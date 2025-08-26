import 'package:test/test.dart';
import 'package:sltt_core/src/models/entity_type.dart';

void main() {
  test('every EntityType has a 4-char suffix mapping', () {
    final missing = EntityType.values
        .where((e) => !EntityType.suffixMapping.containsKey(e.value))
        .map((e) => e.value)
        .toList();
    expect(missing, isEmpty, reason: 'Missing suffixMapping for: $missing');
  });

  test('all suffix mappings are exactly 4 characters', () {
    for (final entry in EntityType.suffixMapping.entries) {
      expect(
        entry.value.length,
        equals(4),
        reason: 'Suffix for ${entry.key} should be 4 chars',
      );
    }
  });

  test('generateEntityId and extractEntityTypeFromId roundtrip', () {
    final ts = DateTime.utc(2020, 1, 1);
    for (final e in EntityType.values) {
      final id = EntityType.generateEntityId(e.value, ts);
      final extracted = EntityType.extractEntityTypeFromId(id);
      expect(
        extracted,
        equals(e.value),
        reason: 'Roundtrip failed for ${e.value} (id=$id)',
      );
    }
  });
}
