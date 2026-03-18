import 'package:aws_backend/src/models/marker.entity_state.dynamo.dart';
import 'package:test/test.dart';

void main() {
  group('offline - DynamoMarkerDataEntityState - field coverage', () {
    test('toJsonBase includes expected keys (nullable fields allowed)', () {
      final state = DynamoMarkerDataEntityState(
        entityId: 'm1',
        domainType: 'project',
        change_domainId: 'project1',
        change_domainId_orig_: 'project1',
        change_changeAt: DateTime.now().toUtc(),
        change_changeAt_orig_: DateTime.now().toUtc(),
        change_storedAt: DateTime.now().toUtc(),
        change_storedAt_orig_: DateTime.now().toUtc(),
        change_cid: 'cid',
        change_cid_orig_: 'cid',
        change_changeBy: 'user',
        change_changeBy_orig_: 'user',
        data_parentId: 'root',
        data_parentId_changeAt_: DateTime.now().toUtc(),
        data_parentId_cid_: 'cid',
        data_parentId_changeBy_: 'user',
        data_parentProp: 'markers',
        data_parentProp_changeAt_: DateTime.now().toUtc(),
        data_parentProp_cid_: 'cid',
        data_parentProp_changeBy_: 'user',
        unknownJson: '{}',
        stateDataHash: 'something',
        stateDataHash_orig_: 'something',
        data_colorValue: 0,
        data_colorValue_changeAt_: DateTime.now().toUtc(),
        data_colorValue_changeBy_: 'user',
        data_shape: '',
        data_shape_changeAt_: DateTime.now().toUtc(),
        data_shape_changeBy_: 'user',
        data_description: '',
        data_description_changeAt_: DateTime.now().toUtc(),
        data_description_changeBy_: 'user',
      );

      final base = state.toJsonBase();
      expect(base.containsKey('entityId'), isTrue);
      expect(base.containsKey('data_colorValue'), isTrue);
      expect(base.containsKey('data_shape'), isTrue);
      expect(base.containsKey('data_description'), isTrue);
      expect(base.containsKey('data_replacementId'), isTrue);
    });
  });
}
