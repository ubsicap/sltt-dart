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
    // Pattern: YYYY-mmdd-HHMMss-sss[_-]HH{user code: [A-Za-z]{2}}-{4chars}
    final re = RegExp(
      r'^\d{4}-\d{4}-\d{6}-\d{3}[_\\-]\d{2}UK-[A-Za-z0-9]{4}-prtn-cid$',
    );
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

  test('EntityIdParts validate', () {
    final entityId = '2026-0108-161325-580_06UK-XQZK-vidZ';
    final entityIdParts = EntityIdParts(entityId: entityId);
    expect(entityIdParts.YYYY, equals('2026'));
    expect(entityIdParts.mmdd, equals('0108'));
    expect(entityIdParts.HHMMss, equals('161325'));
    expect(entityIdParts.zzz, equals('580'));
    expect(entityIdParts.tzOffset, equals('_06'));
    expect(entityIdParts.usrHash, equals('UK'));
    expect(entityIdParts.randomPart, equals('XQZK'));
    expect(entityIdParts.entitySuffix, equals('vidZ'));
    expect(entityIdParts.entityType, equals(EntityType.video.value));
    expect(() => entityIdParts.validate(), returnsNormally);
  });
}
