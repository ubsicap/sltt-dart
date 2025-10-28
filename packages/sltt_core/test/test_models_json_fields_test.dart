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
      final DateTime cloudAt = DateTime.now().toUtc();
      final changeAt = DateTime.now().toUtc();
      final storedAt = DateTime.now().toUtc();
      final state = TestEntityState(
        data_nameLocal: 'name',
        data_nameLocal_changeAt_: changeAt,
        entityId: 'eid',
        entityType: 'project',
        domainType: 'dType',
        schemaVersion: 1,
        change_storedAt: storedAt,
        change_storedAt_orig_: storedAt,
        change_domainId: 'did',
        change_domainId_orig_: 'did',
        change_changeAt: changeAt,
        change_changeAt_orig_: changeAt,
        change_cid: 'cid',
        change_cid_orig_: 'cid',
        change_dataSchemaRev: 1,
        change_cloudAt: cloudAt,
        change_changeBy: 'user',
        change_changeBy_orig_: 'user',
        data_parentId: 'pid',
        data_parentId_dataSchemaRev_: 1,
        data_parentId_changeAt_: changeAt,
        data_parentId_cid_: 'cid',
        data_parentId_changeBy_: 'user',
        data_parentId_cloudAt_: cloudAt,
        // Add some parentProp data for testing
        data_parentProp: 'pList',
        data_parentProp_dataSchemaRev_: 1,
        data_parentProp_changeAt_: changeAt,
        data_parentProp_cid_: 'cid',
        data_parentProp_changeBy_: 'user',
        unknownJson: '',
      );
      state.setUnknown('baz', 'qux');
      final json = state.toJson();
      final roundTrip = TestEntityState.fromJson(json);
      expect(roundTrip.getUnknown(), state.getUnknown());
    });
  });
}
