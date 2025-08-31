import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  group('TestChangeLogEntry serialization', () {
    test('round-trips xJson fields', () {
      final entry = TestChangeLogEntry(
        cid: 'cid',
        entityId: 'eid',
        entityType: 'project',
        domainId: 'did',
        domainType: 'dType',
        changeAt: DateTime.now().toUtc(),
        storageId: 'local',
        changeBy: 'user',
        dataJson: '{}',
        operation: 'create',
        stateChanged: true,
      );
      entry.setDataMap({'foo': 42});
      entry.setOperationInfoMap({'bar': true});
      entry.setUnknownMap({'baz': 'qux'});
      final json = entry.toJson();
      final roundTrip = TestChangeLogEntry.fromJson(json);
      expect(roundTrip.getData(), entry.getData());
      expect(roundTrip.getOperationInfo(), entry.getOperationInfo());
      expect(roundTrip.getUnknown(), entry.getUnknown());
    });
  });

  group('TestEntityState serialization', () {
    test('round-trips unknownJson field', () {
      final state = TestEntityState(
        data_nameLocal: 'name',
        entityId: 'eid',
        entityType: 'project',
        schemaVersion: 1,
        change_domainId: 'did',
        change_domainId_orig_: 'did',
        change_changeAt: DateTime.now().toUtc(),
        change_changeAt_orig_: DateTime.now().toUtc(),
        change_cid: 'cid',
        change_cid_orig_: 'cid',
        change_dataSchemaRev: 1,
        change_cloudAt: DateTime.now().toUtc(),
        change_changeBy: 'user',
        change_changeBy_orig_: 'user',
        data_parentId: 'pid',
        data_parentId_dataSchemaRev_: 1,
        data_parentId_changeAt_: DateTime.now().toUtc(),
        data_parentId_cid_: 'cid',
        data_parentId_changeBy_: 'user',
        data_parentId_cloudAt_: DateTime.now().toUtc(),
        unknownJson: '',
      );
      state.setUnknown('baz', 'qux');
      final json = state.toJson();
      final roundTrip = TestEntityState.fromJson(json);
      expect(roundTrip.getUnknown(), state.getUnknown());
    });
  });
}
