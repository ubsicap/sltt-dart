// ignore_for_file: avoid_print
import 'package:isar_community/isar.dart';
import 'package:sync_manager/src/models/passage_translation.entity_state.isar.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  group('Isar schema change preserves seq auto-increment', () {
    const testDbName = 'isar_schema_change_seq_test';
    const testDbPath = './isar_db';

    Future<void> deleteDb() async {
      // IsarStorageService helper provides cross-platform delete
      final ok = await IsarStorageService.deleteDatabaseFiles(testDbName);
      expect(ok, isTrue, reason: 'Failed to delete DB files before test');
    }

    IsarChangeLogEntry makeEntry(int i) => IsarChangeLogEntry(
      cid: 'cid-$i',
      domainId: 'proj',
      entityType: 'task',
      operation: 'create',
      changeAt: DateTime.now().toUtc(),
      entityId: 'e-$i',
      dataJson: '{"nameLocal":"X$i","parentId":"root","parentProp":"pList"}',
      changeBy: 'user',
      storageId: '',
      domainType: 'project',
      stateChanged: false,
    );

    test('seq advances across schema change', () async {
      await deleteDb();
      // 1) Open with only IsarChangeLogEntry schema and add N entries
      var isar = await Isar.open(
        [IsarChangeLogEntrySchema],
        name: testDbName,
        directory: testDbPath,
      );
      try {
        await isar.writeTxn(() async {
          for (int i = 0; i < 5; i++) {
            await isar.isarChangeLogEntrys.put(makeEntry(i));
          }
        });
        final maxSeq1 = await isar.isarChangeLogEntrys
            .where()
            .seqProperty()
            .max();
        expect(maxSeq1, isNonZero, reason: 'Should have inserted entries');

        // now delete entries and add another
        await isar.writeTxn(() async {
          await isar.isarChangeLogEntrys.clear();
          final count = await isar.isarChangeLogEntrys.count();
          expect(count, equals(0), reason: 'Entries should be deleted');
          // Add one entry after deletion
          await isar.isarChangeLogEntrys.put(makeEntry(99));
        });

        // expect seq to have advanced, not reset
        final maxSeqAfterDelete = await isar.isarChangeLogEntrys
            .where()
            .seqProperty()
            .max();
        expect(maxSeqAfterDelete!, greaterThan(5));
        // delete all again before closing
        await isar.writeTxn(() async {
          await isar.isarChangeLogEntrys.clear();
        });

        expect(
          await isar.isarChangeLogEntrys.count(),
          equals(0),
          reason: 'Entries should be deleted again',
        );
      } finally {
        await isar.close();
      }

      isar = await Isar.open(
        [IsarChangeLogEntrySchema, IsarPassageDataEntityStateSchema],
        name: testDbName,
        directory: testDbPath,
      );
      try {
        // Insert one more change log entry and ensure seq continues
        IsarChangeLogEntry? inserted;
        await isar.writeTxn(() async {
          inserted = makeEntry(999);
          await isar.isarChangeLogEntrys.put(inserted!);
        });
        final fetched = await isar.isarChangeLogEntrys
            .where()
            .filter()
            .cidEqualTo('cid-999')
            .findFirst();
        expect(
          fetched,
          isNotNull,
          reason: 'Inserted entry should be retrievable',
        );

        final maxSeq2 = await isar.isarChangeLogEntrys
            .where()
            .seqProperty()
            .max();
        final minSeq2 = await isar.isarChangeLogEntrys
            .where()
            .seqProperty()
            .min();
        expect(maxSeq2, isNotNull);
        expect(minSeq2, isNotNull);
        // Ensure seq did not reset to 1 after schema change
        expect(
          maxSeq2,
          greaterThan(5),
          reason: 'Seq should advance beyond initial inserts',
        );
      } finally {
        await isar.close();
        await deleteDb();
      }
    });
  });
}
