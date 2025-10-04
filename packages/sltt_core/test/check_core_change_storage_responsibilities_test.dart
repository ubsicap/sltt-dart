import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import './helpers/in_memory_storage.dart';
import './test_models.dart';

// Helper to create a minimal TestEntityState for a change entry.
TestEntityState _mkEntityStateForChange(
  TestChangeLogEntry change, {
  DateTime? storedAtOverride,
  DateTime? cloudAtOverride,
}) {
  final now = DateTime.now().toUtc();
  final changeStoredAt = storedAtOverride ?? change.storedAt ?? now;
  return TestEntityState(
    data_nameLocal: 'test',
    entityId: change.entityId,
    entityType: change.entityType,
    domainType: change.domainType,
    unknownJson: '{}',
    change_domainId: change.domainId,
    change_domainId_orig_: '',
    change_changeAt: change.changeAt,
    change_storedAt: changeStoredAt,
    change_changeAt_orig_: DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
    change_cid: change.cid,
    change_cid_orig_: '',
    change_changeBy: change.changeBy,
    change_changeBy_orig_: '',
    data_parentId: 'root',
    data_parentId_changeAt_: change.changeAt,
    data_parentId_cid_: change.cid,
    data_parentId_changeBy_: change.changeBy,
    data_parentProp: 'pList',
    data_parentProp_changeAt_: change.changeAt,
    data_parentProp_cid_: change.cid,
    data_parentProp_changeBy_: change.changeBy,
    // include cloudAt fields when provided
    change_cloudAt: cloudAtOverride ?? change.cloudAt,
    data_parentId_cloudAt_: cloudAtOverride ?? change.cloudAt,
    data_parentProp_cloudAt_: cloudAtOverride ?? change.cloudAt,
  );
}

void main() {
  group('checkCoreChangeStorageResponsibilities', () {
    test('rejects empty storageId for both local and cloud storage', () {
      final localStorage = InMemoryStorage(storageType: 'local');
      final cloudStorage = InMemoryStorage(storageType: 'cloud');

      final changeWithEmptyStorageId = TestChangeLogEntry(
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
        storageId: '', // empty storageId should be rejected
        storedAt: DateTime.now().toUtc(),
      );

      // Both local and cloud storage should reject empty storageId
      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: localStorage,
          changeToPut: changeWithEmptyStorageId,
          entityStateToPut: _mkEntityStateForChange(changeWithEmptyStorageId),
          skipChangeLogWrite: false,
          skipStateWrite: true,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: cloudStorage,
          changeToPut: changeWithEmptyStorageId,
          entityStateToPut: _mkEntityStateForChange(changeWithEmptyStorageId),
          skipChangeLogWrite: false,
          skipStateWrite: true,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('requires storedAt for both local and cloud storage', () {
      final localStorage = InMemoryStorage(storageType: 'local');
      final cloudStorage = InMemoryStorage(storageType: 'cloud');

      final changeWithoutStoredAt = TestChangeLogEntry(
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
        storageId: 'valid-storage-id',
        // missing storedAt
      );

      // Both storage types require storedAt
      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: localStorage,
          changeToPut: changeWithoutStoredAt,
          entityStateToPut: _mkEntityStateForChange(changeWithoutStoredAt),
          skipChangeLogWrite: false,
          skipStateWrite: true,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: cloudStorage,
          changeToPut: changeWithoutStoredAt,
          entityStateToPut: _mkEntityStateForChange(changeWithoutStoredAt),
          skipChangeLogWrite: false,
          skipStateWrite: true,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('cloud storage additionally requires cloudAt', () {
      final cloudStorage = InMemoryStorage(storageType: 'cloud');

      final changeWithoutCloudAt = TestChangeLogEntry(
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
        storageId: 'valid-storage-id',
        storedAt: DateTime.now().toUtc(),
        // missing cloudAt for cloud storage
      );

      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: cloudStorage,
          changeToPut: changeWithoutCloudAt,
          entityStateToPut: _mkEntityStateForChange(changeWithoutCloudAt),
          skipChangeLogWrite: false,
          skipStateWrite: true,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('requires entityState when writing state', () {
      final localStorage = InMemoryStorage(storageType: 'local');

      final fixedStoredAt = DateTime.parse('2025-10-04T22:10:00.000Z');

      final validChange = TestChangeLogEntry(
        cid: 'c4',
        entityId: 'e4',
        entityType: 'document',
        domainId: '__test4',
        domainType: 'project',
        changeAt: DateTime.now().toUtc(),
        changeBy: 't',
        dataJson: '{}',
        operation: 'create',
        stateChanged: false,
        storageId: 'valid-storage-id',
        storedAt: fixedStoredAt,
      );

      // Should throw when a minimal/mismatched entityState is provided but
      // skipStateWrite is false and the content does not satisfy requirements.
      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: localStorage,
          changeToPut: validChange,
          entityStateToPut: _mkEntityStateForChange(
            validChange,
            storedAtOverride: DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
          ),
          skipChangeLogWrite: false,
          skipStateWrite: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validates entityState change_storedAt matches change.storedAt', () {
      final localStorage = InMemoryStorage(storageType: 'local');
      final now = DateTime.now().toUtc();
      final differentTime = now.add(const Duration(minutes: 1));

      final change = TestChangeLogEntry(
        cid: 'c5',
        entityId: 'e5',
        entityType: 'document',
        domainId: '__test5',
        domainType: 'project',
        changeAt: now,
        changeBy: 't',
        dataJson: '{}',
        operation: 'create',
        stateChanged: false,
        storageId: 'valid-storage-id',
        storedAt: now,
      );

      final entityStateWithMismatchedStoredAt = TestEntityState(
        data_nameLocal: 'test',
        entityId: 'e5',
        entityType: 'document',
        domainType: 'project',
        unknownJson: '{}',
        change_domainId: '__test5',
        change_domainId_orig_: '',
        change_changeAt: now,
        change_storedAt: differentTime, // mismatched
        change_changeAt_orig_: DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
        change_cid: 'c5',
        change_cid_orig_: '',
        change_changeBy: 't',
        change_changeBy_orig_: '',
        data_parentId: 'root',
        data_parentId_changeAt_: now,
        data_parentId_cid_: 'c5',
        data_parentId_changeBy_: 't',
        data_parentProp: 'pList',
        data_parentProp_changeAt_: now,
        data_parentProp_cid_: 'c5',
        data_parentProp_changeBy_: 't',
      );

      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: localStorage,
          changeToPut: change,
          entityStateToPut: entityStateWithMismatchedStoredAt,
          skipChangeLogWrite: false,
          skipStateWrite: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validates cloud storage has matching cloudAt in entityState', () {
      final cloudStorage = InMemoryStorage(storageType: 'cloud');
      final now = DateTime.now().toUtc();

      final change = TestChangeLogEntry(
        cid: 'c6',
        entityId: 'e6',
        entityType: 'document',
        domainId: '__test6',
        domainType: 'project',
        changeAt: now,
        changeBy: 't',
        dataJson: '{}',
        operation: 'create',
        stateChanged: false,
        storageId: 'valid-storage-id',
        storedAt: now,
        cloudAt: now,
      );

      final entityStateWithoutMatchingCloudAt = TestEntityState(
        data_nameLocal: 'test',
        entityId: 'e6',
        entityType: 'document',
        domainType: 'project',
        unknownJson: '{}',
        change_domainId: '__test6',
        change_domainId_orig_: '',
        change_changeAt: now,
        change_storedAt: now,
        change_changeAt_orig_: DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
        change_cid: 'c6',
        change_cid_orig_: '',
        change_changeBy: 't',
        change_changeBy_orig_: '',
        // Missing change_cloudAt and no field-level cloudAt that matches
        data_parentId: 'root',
        data_parentId_changeAt_: now,
        data_parentId_cid_: 'c6',
        data_parentId_changeBy_: 't',
        data_parentProp: 'pList',
        data_parentProp_changeAt_: now,
        data_parentProp_cid_: 'c6',
        data_parentProp_changeBy_: 't',
      );

      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: cloudStorage,
          changeToPut: change,
          entityStateToPut: entityStateWithoutMatchingCloudAt,
          skipChangeLogWrite: false,
          skipStateWrite: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('passes validation with correct local storage setup', () {
      final localStorage = InMemoryStorage(storageType: 'local');
      final now = DateTime.now().toUtc();

      final change = TestChangeLogEntry(
        cid: 'c7',
        entityId: 'e7',
        entityType: 'document',
        domainId: '__test7',
        domainType: 'project',
        changeAt: now,
        changeBy: 't',
        dataJson: '{}',
        operation: 'create',
        stateChanged: false,
        storageId: 'valid-storage-id',
        storedAt: now,
      );

      final validEntityState = TestEntityState(
        data_nameLocal: 'test',
        entityId: 'e7',
        entityType: 'document',
        domainType: 'project',
        unknownJson: '{}',
        change_domainId: '__test7',
        change_domainId_orig_: '',
        change_changeAt: now,
        change_storedAt: now, // matches change.storedAt
        change_changeAt_orig_: DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
        change_cid: 'c7',
        change_cid_orig_: '',
        change_changeBy: 't',
        change_changeBy_orig_: '',
        data_parentId: 'root',
        data_parentId_changeAt_: now,
        data_parentId_cid_: 'c7',
        data_parentId_changeBy_: 't',
        data_parentProp: 'pList',
        data_parentProp_changeAt_: now,
        data_parentProp_cid_: 'c7',
        data_parentProp_changeBy_: 't',
      );

      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: localStorage,
          changeToPut: change,
          entityStateToPut: validEntityState,
          skipChangeLogWrite: false,
          skipStateWrite: false,
        ),
        returnsNormally,
      );
    });

    test('passes validation with correct cloud storage setup', () {
      final cloudStorage = InMemoryStorage(storageType: 'cloud');
      final now = DateTime.now().toUtc();

      final change = TestChangeLogEntry(
        cid: 'c8',
        entityId: 'e8',
        entityType: 'document',
        domainId: '__test8',
        domainType: 'project',
        changeAt: now,
        changeBy: 't',
        dataJson: '{}',
        operation: 'create',
        stateChanged: false,
        storageId: 'valid-storage-id',
        storedAt: now,
        cloudAt: now,
      );

      final validEntityState = TestEntityState(
        data_nameLocal: 'test',
        entityId: 'e8',
        entityType: 'document',
        domainType: 'project',
        unknownJson: '{}',
        change_domainId: '__test8',
        change_domainId_orig_: '',
        change_changeAt: now,
        change_storedAt: now, // matches change.storedAt
        change_cloudAt: now, // matches change.cloudAt
        change_changeAt_orig_: DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
        change_cid: 'c8',
        change_cid_orig_: '',
        change_changeBy: 't',
        change_changeBy_orig_: '',
        data_parentId: 'root',
        data_parentId_changeAt_: now,
        data_parentId_cid_: 'c8',
        data_parentId_changeBy_: 't',
        data_parentId_cloudAt_: now, // field-level cloudAt also matches
        data_parentProp: 'pList',
        data_parentProp_changeAt_: now,
        data_parentProp_cid_: 'c8',
        data_parentProp_changeBy_: 't',
        data_parentProp_cloudAt_: now, // field-level cloudAt also matches
      );

      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: cloudStorage,
          changeToPut: change,
          entityStateToPut: validEntityState,
          skipChangeLogWrite: false,
          skipStateWrite: false,
        ),
        returnsNormally,
      );
    });

    test('skips validation when both writes are skipped', () {
      final cloudStorage = InMemoryStorage(storageType: 'cloud');

      // Even with invalid data, should not throw when both writes are skipped
      final invalidChange = TestChangeLogEntry(
        cid: 'c9',
        entityId: 'e9',
        entityType: 'document',
        domainId: '__test9',
        domainType: 'project',
        changeAt: DateTime.now().toUtc(),
        changeBy: 't',
        dataJson: '{}',
        operation: 'create',
        stateChanged: false,
        storageId: '', // empty storageId would normally fail
        // missing storedAt and cloudAt would normally fail
      );

      expect(
        () => ChangeProcessingService.checkCoreChangeStorageResponsibilities(
          storage: cloudStorage,
          changeToPut: invalidChange,
          entityStateToPut: _mkEntityStateForChange(invalidChange),
          skipChangeLogWrite: true,
          skipStateWrite: true,
        ),
        returnsNormally,
      );
    });
  });
}
