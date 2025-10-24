import 'package:test/test.dart';

import 'test_models.dart';
import 'utils/test_datetime.dart';

void main() {
  group('TestChangeLogEntry DateTime', () {
    test('DateTime fields become UTC', () {
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
        cloudAt: changeAtLocal,
        storedAt: changeAtLocal,
      );
      expect(entry.changeAt.isUtc, isTrue);
      expect(entry.changeAt, equals(changeAtLocal.toUtc()));
      expect(entry.cloudAt?.isUtc, isTrue);
      expect(entry.cloudAt, equals(changeAtLocal.toUtc()));
      expect(entry.storedAt?.isUtc, isTrue);
      expect(entry.storedAt, equals(changeAtLocal.toUtc()));

      // serialize and test still utc
      final json = entry.toJson();
      expectAllDateTimeFieldsAreUtc(json);

      // round-trip and test again
      final roundTrip = TestChangeLogEntry.fromJson(json);
      expect(roundTrip.changeAt.isUtc, isTrue);
      expect(roundTrip.changeAt, equals(changeAtLocal.toUtc()));
      expect(roundTrip.cloudAt?.isUtc, isTrue);
      expect(roundTrip.cloudAt, equals(changeAtLocal.toUtc()));
      expect(roundTrip.storedAt?.isUtc, isTrue);
      expect(roundTrip.storedAt, equals(changeAtLocal.toUtc()));
    });
  });
}
