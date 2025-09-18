import 'dart:math';

import 'package:sltt_core/src/models/entity_type.dart';
import 'package:test/test.dart';

void main() {
  test('every EntityType has a 4-char suffix mapping', () {
    final missing = EntityType.values
        .where(
          (e) =>
              !EntityType.suffixMapping.containsKey(e.value) &&
              e.value != 'unknown',
        )
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

  test('generateCid produces a stable-looking formatted id', () {
    final cid = generateCid(entityType: EntityType.portion);
    // Pattern: YYYY-mmdd-HHMMss-sss[_-]HHmm-{4chars}
    final re = RegExp(r'^\d{4}-\d{4}-\d{6}-\d{3}[_\\-]\d{4}-[A-Za-z0-9]{4}-cid$');
    expect(
      re.hasMatch(cid),
      isTrue,
      reason: 'CID ($cid) did not match expected pattern',
    );
  });

  test('generateEntityId and extractEntityTypeFromId roundtrip', () {
    for (final e in EntityType.values.where((e) => e != EntityType.unknown)) {
      final id = EntityType.generateEntityId(entityType: e);
      final extracted = EntityType.extractEntityTypeFromId(id);
      expect(
        extracted,
        equals(e.value),
        reason: 'Roundtrip failed for ${e.value} (id=$id)',
      );
    }
  });
}
