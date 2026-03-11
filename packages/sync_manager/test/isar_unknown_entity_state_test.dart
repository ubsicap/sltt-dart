// Tests that mirror offline_unknown_entity_state_test.dart but for the
// IsarUnknownEntityState model used in sync_manager.
// ignore_for_file: non_constant_identifier_names

import 'package:sync_manager/src/models/unknown_entity_state.isar.dart';
import 'package:test/test.dart';

import '../../sltt_core/test/utils/test_datetime.dart';

void main() {
  group('IsarUnknownEntityState deserialization', () {
    test('totallyRandom entityType deserializes to IsarUnknownEntityState', () {
      final payload = _basePayload(entityType: 'totallyRandom');
      final state = IsarUnknownEntityState.fromJson(payload);

      expect(state, isA<IsarUnknownEntityState>());
      expect(state.entityType, equals('totallyRandom'));
      expect(state.entityId, equals('test-entity-1'));
      expect(state.change_domainId, equals('__test_unknown_entity_state'));
    });

    test('round-trip serialization preserves entityType', () {
      final payload = _basePayload(entityType: 'totallyRandom');
      final state = IsarUnknownEntityState.fromJson(payload);
      final serialized = state.toJson();

      expect(serialized['entityType'], equals('totallyRandom'));
      expect(serialized['entityId'], equals(payload['entityId']));
      expect(serialized['change_domainId'], equals(payload['change_domainId']));
    });

    test('round-trip serialization produces identical payloads', () {
      final payload = _basePayload(entityType: 'totallyRandom');
      final state = IsarUnknownEntityState.fromJson(payload);
      final serialized = state.toJson();

      final state2 = IsarUnknownEntityState.fromJson(serialized);
      expect(state2.entityType, equals(state.entityType));
      expect(state2.entityId, equals(state.entityId));
      expect(state2.change_domainId, equals(state.change_domainId));
      expect(state2.change_cid, equals(state.change_cid));
    });

    test('data_name is null when not provided', () {
      final payload = _basePayload(entityType: 'totallyRandom');
      final state = IsarUnknownEntityState.fromJson(payload);

      expect(state.data_name, isNull);
    });

    test('data_name is deserialized when provided', () {
      final payload = _basePayload(
        entityType: 'totallyRandom',
        extraData: {
          'data_name': 'My Unknown Entity',
          'data_name_changeAt_': DateTime.now().toUtc().toIso8601String(),
          'data_name_changeBy_': 'tester',
          'data_name_cid_': 'cid-name-1',
        },
      );
      final state = IsarUnknownEntityState.fromJson(payload);

      expect(state.data_name, equals('My Unknown Entity'));
      expect(state.data_name_changeBy_, equals('tester'));
    });

    test('another unknown entityType also deserializes correctly', () {
      final payload = _basePayload(entityType: 'futureEntityV99');
      final state = IsarUnknownEntityState.fromJson(payload);

      expect(state, isA<IsarUnknownEntityState>());
      expect(state.entityType, equals('futureEntityV99'));
    });

    test('all DateTime fields are UTC after deserialization', () {
      final payload = _basePayload(entityType: 'totallyRandom');
      final state = IsarUnknownEntityState.fromJson(payload);
      final json = state.toJson();

      expectAllDateTimeFieldsAreUtc(json);
    });
  });
}

Map<String, dynamic> _basePayload({
  required String entityType,
  Map<String, dynamic> extraData = const {},
}) {
  final now = DateTime.now().toUtc();
  return {
    'entityId': 'test-entity-1',
    'entityType': entityType,
    'domainType': 'project',
    'unknownJson': '{}',
    'change_domainId': '__test_unknown_entity_state',
    'change_domainId_orig_': '__test_unknown_entity_state',
    'change_changeAt': now.toIso8601String(),
    'change_changeAt_orig_': now.toIso8601String(),
    'change_storedAt': now.toIso8601String(),
    'change_storedAt_orig_': now.toIso8601String(),
    'change_cid': 'cid-1',
    'change_cid_orig_': 'cid-1',
    'change_changeBy': 'tester',
    'change_changeBy_orig_': 'tester',
    'data_parentId': 'parent-1',
    'data_parentId_changeAt_': now.toIso8601String(),
    'data_parentId_cid_': 'cid-1',
    'data_parentId_changeBy_': 'tester',
    'data_parentProp': 'prop',
    'data_parentProp_changeAt_': now.toIso8601String(),
    'data_parentProp_cid_': 'cid-1',
    'data_parentProp_changeBy_': 'tester',
    ...extraData,
  };
}
