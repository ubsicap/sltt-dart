import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  group('TestChangeLogEntry DateTime', () {
    test('changeAt is UTC', () {
      final changeAtLocal = DateTime.now();
      final entry = TestChangeLogEntry(
        cid: 'cid',
        entityId: 'eid',
        entityType: 'project',
        domainId: 'did',
        domainType: 'dType',
        changeAt: changeAtLocal,
        storageId: 'local',
        changeBy: 'user',
        dataJson: '{}',
        operation: 'create',
        stateChanged: true,
      );
      expect(entry.changeAt.isUtc, isTrue);
      expect(entry.changeAt, equals(changeAtLocal.toUtc()));
    });
  });
}
