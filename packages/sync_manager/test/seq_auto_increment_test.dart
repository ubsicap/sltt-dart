import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  group('Seq auto-increment regression', () {
    setUpAll(() async {
      // Register change log entry serializer group (same as integration tests)
      registerChangeLogEntryFactoryGroup(
        SerializableGroup<BaseChangeLogEntry>(
          fromJson: IsarChangeLogEntry.fromJson,
          fromJsonBase: IsarChangeLogEntry.fromJsonBase,
          toJson: (entry) => (entry as IsarChangeLogEntry).toJson(),
          toJsonBase: (entry) => (entry as IsarChangeLogEntry).toJsonBase(),
          toSafeJson: (original) =>
              SafeJsonService.generateSafeChangeLogJson(original),
          validate: (entry) async {
            // Ensure dataJson isn't empty and parses to BaseDataFields
            BaseDataFields.fromJson(entry.getData());
          },
        ),
      );
      // Ensure storages are initialized and cleared
      final local = LocalStorageService.instance;
      await local.initialize();
      await local.testResetDomainStorage(
        domainType: 'project',
        domainId: '__test_reg1',
      );

      final cloud = CloudStorageService.instance;
      await cloud.initialize();
      await cloud.testResetDomainStorage(
        domainType: 'project',
        domainId: '__test_reg1',
      );
    });

    test('writing change with explicit seq does not preserve seq', () async {
      final cloud = CloudStorageService.instance;

      // Build a change with an explicit seq value (simulating a bad caller)
      final badChange = IsarChangeLogEntry(
        changeAt: DateTime.now().toUtc(),
        cid: 'explicit-seq-cid',
        domainType: 'project',
        domainId: '__test_reg1',
        entityType: 'project',
        operation: 'create',
        entityId: '__test_reg1',
        dataJson: stableStringify(
          BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
        ),
        changeBy: 'test',
        stateChanged: false,
        storageId: '',
        unknownJson: '{}',
        operationInfoJson: '{}',
      );

      // Manually set seq to a large sentinel to simulate a caller-provided seq
      badChange.seq = 9999999;

      final res = await ChangeProcessingService.processChanges(
        storageMode: 'save',
        changes: [badChange.toJson()],
        srcStorageType: 'cloud',
        srcStorageId: 'reg-seed',
        storage: cloud,
        includeChangeUpdates: true,
        includeStateUpdates: false,
      );

      expect(res.isSuccess, isTrue, reason: res.errorMessage);

      // Fetch entries for domain and ensure the stored seq is not the explicit one
      // debugDumpAllChanges prints entries; query Isar directly
      final entries = await cloud.getChangesNotOutdated('__test_reg1');
      expect(entries, isNotEmpty);
      final stored = entries.first as IsarChangeLogEntry;

      expect(
        stored.seq == 9999999,
        isFalse,
        reason: 'Stored seq should not match caller-provided seq',
      );

      // Now insert another change with the same explicit seq and ensure it didn't overwrite
      final badChange2 = IsarChangeLogEntry(
        changeAt: DateTime.now().toUtc(),
        cid: 'explicit-seq-cid-2',
        domainType: 'project',
        domainId: '__test_reg1',
        entityType: 'project',
        operation: 'create',
        entityId: '__test_reg1',
        dataJson: stableStringify(
          BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
        ),
        changeBy: 'test',
        stateChanged: false,
        storageId: '',
        unknownJson: '{}',
        operationInfoJson: '{}',
      );
      badChange2.seq = 9999999;

      final res2 = await ChangeProcessingService.processChanges(
        storageMode: 'save',
        changes: [badChange2.toJson()],
        srcStorageType: 'cloud',
        srcStorageId: 'reg-seed',
        storage: cloud,
        includeChangeUpdates: true,
        includeStateUpdates: false,
      );

      expect(res2.isSuccess, isTrue, reason: res2.errorMessage);

      final entries2 = await cloud.getChangesNotOutdated('__test_reg1');
      expect(
        entries2.length >= 2,
        isTrue,
        reason: 'Both changes should coexist and not overwrite',
      );
    });
  });
}
