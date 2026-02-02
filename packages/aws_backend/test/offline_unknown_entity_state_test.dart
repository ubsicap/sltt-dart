import 'package:aws_backend/src/models/dynamo_entity_state.dart';
import 'package:aws_backend/src/models/dynamo_entity_state_serialization_registry.dart'
    as registry;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    // Ensure Dynamo entity state factories are registered
    registry.ensureDynamoSerializersRegistered();
  });

  group('deserializeEntityStateSafely', () {
    test('totallyRandom uses default DynamoEntityState', () {
      final payload = _basePayload(entityType: 'totallyRandom');
      final state = deserializeEntityStateSafely(payload);
      expect(state, isA<DynamoEntityState>());
      final group = getSerializableGroup(EntityType.unknown);
      final serialized = group?.toJson(state);
      // test round-trip serialization
      expect(serialized, payload);
    });

    test('literal entityType "unknown" throws', () {
      final payload = _basePayload(entityType: 'unknown');
      expect(
        () => deserializeEntityStateSafely(payload),
        throwsA(isA<Exception>()),
      );
    });

    test('literal entityType "missing" throws', () {
      final payload = _basePayload(entityType: 'missing');
      expect(
        () => deserializeEntityStateSafely(payload),
        throwsA(isA<Exception>()),
      );
    });
  });
}

Map<String, dynamic> _basePayload({required String entityType}) => {
  'entityId': 'test-entity-1',
  'entityType': entityType,
  'domainType': 'project',
  'unknownJson': '{}',
  'change_domainId': 'proj-1',
  'change_domainId_orig_': 'proj-1',
  'change_changeAt': DateTime.now().toUtc().toIso8601String(),
  'change_changeAt_orig_': DateTime.now().toUtc().toIso8601String(),
  'change_cid': 'cid-1',
  'change_cid_orig_': 'cid-1',
  'change_changeBy': 'tester',
  'change_changeBy_orig_': 'tester',
  'data_parentId': 'parent-1',
  'data_parentId_changeAt_': DateTime.now().toUtc().toIso8601String(),
  'data_parentId_cid_': 'cid-1',
  'data_parentId_changeBy_': 'tester',
  'data_parentProp': 'prop',
  'data_parentProp_changeAt_': DateTime.now().toUtc().toIso8601String(),
  'data_parentProp_cid_': 'cid-1',
  'data_parentProp_changeBy_': 'tester',
  'change_storedAt': DateTime.now().toUtc().toIso8601String(),
  'change_storedAt_orig_': DateTime.now().toUtc().toIso8601String(),
};
