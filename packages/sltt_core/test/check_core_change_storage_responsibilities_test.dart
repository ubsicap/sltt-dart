import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import './helpers/in_memory_storage.dart';
import './test_models.dart';

void main() {
  group('checkCoreChangeStorageResponsibilities', () {
    test('cloud storage requires cloudAt/storedAt and storageId', () {
      final storage = InMemoryStorage(storageType: 'cloud');
      final change = TestChangeLogEntry(
        cid: 'c1',
        entityId: 'e1',
        entityType: 'document',
        domainId: '__test1',
        domainType: 'project',
        changeAt: DateTime.now().toUtc(),
        changeBy: 't',
        dataJson: '{}',
        operation: 'create',
        stateChanged: false,
        // missing storageId/cloudAt/storedAt
      );

      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: storage,
          change: change,
          entityState: null,
          skipChangeLogWrite: false,
          skipStateWrite: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('local storage rejects empty storageId', () {
      final storage = InMemoryStorage(storageType: 'local');
      final change = TestChangeLogEntry(
        cid: 'c2',
        entityId: 'e2',
        entityType: 'document',
        domainId: '__test2',
        domainType: 'project',
        changeAt: DateTime.now().toUtc(),
        changeBy: 't',
        dataJson: '{}',
        operation: 'create',
        stateChanged: false,
        storageId: '', // invalid empty storageId
      );

      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: storage,
          change: change,
          entityState: null,
          skipChangeLogWrite: false,
          skipStateWrite: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('local storage does accept storageId', () {
      final storage = InMemoryStorage(storageType: 'local');
      final change = TestChangeLogEntry(
        cid: 'c3',
        entityId: 'e3',
        entityType: 'document',
        domainId: '__test3',
        domainType: 'project',
        changeAt: DateTime.now().toUtc(),
        changeBy: 't',
        dataJson: '{}',
        operation: 'create',
        stateChanged: false,
        storageId: 'valid-for-test',
      );
      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: storage,
          change: change,
          entityState: null,
          skipChangeLogWrite: false,
          skipStateWrite: false,
        ),
        returnsNormally,
      );
    });
  });
}
