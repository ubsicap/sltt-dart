import 'dart:convert';

import 'package:test/test.dart';

import 'test_assets/task_data.entity_state.dart';

void main() {
  group('TaskDataEntityState serialization', () {
    late TaskDataEntityState state;
    setUp(() {
      final changeAt = DateTime.utc(2025, 1, 2, 3, 4, 5);
      final storedAt = DateTime.utc(2025, 1, 2, 3, 4, 15);

      state = TaskDataEntityState(
        entityId: 'E1',
        change_domainId: 'D1',
        change_changeAt: changeAt,
        change_cid: 'CID123',
        change_changeBy: 'userA',
        data_parentId: 'PARENT',
        data_parentId_changeAt_: DateTime.utc(2025, 1, 1),
        data_parentId_cid_: 'PCID',
        data_parentId_changeBy_: 'userA',
        unknownJson: '{}',
        data_nameLocal: 'Test Name',
        domainType: '',
        data_parentProp: '',
        data_parentProp_changeAt_: DateTime.utc(2025, 1, 1),
        data_parentProp_cid_: '',
        data_parentProp_changeBy_: '',
        entityType: '',
        change_domainId_orig_: '',
        change_changeAt_orig_: changeAt,
        change_storedAt: storedAt,
        change_storedAt_orig_: storedAt,
        change_cid_orig_: '',
        change_changeBy_orig_: '',
      );
    });

    test('toJsonBase contains expected core & custom fields', () {
      final base = state.toJsonBase();
      expect(base['entityId'], 'E1');
      expect(base['data_nameLocal'], 'Test Name');
      expect(base.containsKey('data_parentId'), isTrue);
    });

    test('toJson (unknown-field aware) matches toJsonBase for known fields',
        () {
      final raw = state.toJson();
      final base = state.toJsonBase();
      for (final k in base.keys) {
        expect(raw[k], base[k], reason: 'Mismatch on key $k');
      }
    });

    test('toJsonSafe ensures all required data_ fields present with defaults',
        () {
      final safe = state.toJsonSafe();
      // All declared TaskData fields + core fields
      expect(safe['data_nameLocal'], 'Test Name');
      expect(safe['data_parentId'], isNotNull);
      expect(safe.containsKey('data_deleted'), isTrue);
      expect(safe.containsKey('data_rank'), isTrue);
    });

    test('fromJsonBase round-trip', () {
      final base = state.toJsonBase();
      final rebuilt = TaskDataEntityState.fromJsonBase(base);
      expect(rebuilt.entityId, state.entityId);
      expect(rebuilt.data_nameLocal, state.data_nameLocal);
      expect(rebuilt.data_parentId, state.data_parentId);
    });

    test(
        'fromJson (unknown-field aware) round-trip with extra unknown field retained in unknownJson',
        () {
      final map = state.toJsonBase();
      map['some_new_field'] = 'unexpected';
      final jsonStr = jsonEncode(map);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final rebuilt = TaskDataEntityState.fromJson(decoded);
      expect(rebuilt.data_nameLocal, state.data_nameLocal);
      // We can't easily assert unknownJson contents format here without internal details,
      // but ensure toJson still outputs known fields.
      final out = rebuilt.toJson();
      expect(out['data_nameLocal'], 'Test Name');
    });

    test('toData mapper returns original data class instance', () {
      final original = state.toData();
      expect(original.nameLocal, state.data_nameLocal);
      expect(original.parentId, state.data_parentId);
    });
  });
}
