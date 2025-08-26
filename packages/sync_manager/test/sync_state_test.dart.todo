import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  group('SyncState Tests', () {
    late OutsyncsStorageService storage;

    setUpAll(() async {
      storage = OutsyncsStorageService.instance;
      await storage.initialize();
    });

    tearDownAll(() async {
      await storage.close();
    });

    test('can create and retrieve sync state', () async {
      const projectId = 'test-sync-project';
      const changeLogId = 'change-123';
      final lastChangeAt = DateTime.now();
      const lastSeq = 42;

      // Create sync state
      final syncState = await storage.upsertSyncState(
        projectId,
        changeLogId: changeLogId,
        lastChangeAt: lastChangeAt,
        lastSeq: lastSeq,
      );

      expect(syncState.projectId, equals(projectId));
      expect(syncState.changeLogId, equals(changeLogId));
      expect(syncState.lastChangeAt, equals(lastChangeAt));
      expect(syncState.lastSeq, equals(lastSeq));

      // Retrieve sync state
      final retrieved = await storage.getSyncState(projectId);
      expect(retrieved, isNotNull);
      expect(retrieved!.projectId, equals(projectId));
      expect(retrieved.changeLogId, equals(changeLogId));
      expect(retrieved.lastSeq, equals(lastSeq));
    });

    test('can update existing sync state', () async {
      const projectId = 'test-update-project';
      const initialSeq = 10;
      const updatedSeq = 20;
      const updatedChangeLogId = 'change-456';

      // Create initial sync state
      await storage.upsertSyncState(
        projectId,
        changeLogId: 'initial-change',
        lastSeq: initialSeq,
      );

      // Update sync state
      final updated = await storage.upsertSyncState(
        projectId,
        changeLogId: updatedChangeLogId,
        lastSeq: updatedSeq,
      );

      expect(updated.projectId, equals(projectId));
      expect(updated.changeLogId, equals(updatedChangeLogId));
      expect(updated.lastSeq, equals(updatedSeq));

      // Verify the update was persisted
      final retrieved = await storage.getSyncState(projectId);
      expect(retrieved!.changeLogId, equals(updatedChangeLogId));
      expect(retrieved.lastSeq, equals(updatedSeq));
    });

    test('can get all sync states', () async {
      // Create multiple sync states
      await storage.upsertSyncState('project-a', lastSeq: 1);
      await storage.upsertSyncState('project-b', lastSeq: 2);
      await storage.upsertSyncState('project-c', lastSeq: 3);

      final allSyncStates = await storage.getAllSyncStates();
      expect(allSyncStates.length, greaterThanOrEqualTo(3));

      final projectIds = allSyncStates.map((s) => s.projectId).toSet();
      expect(projectIds, contains('project-a'));
      expect(projectIds, contains('project-b'));
      expect(projectIds, contains('project-c'));
    });

    test('can delete sync state', () async {
      const projectId = 'test-delete-project';

      // Create sync state
      await storage.upsertSyncState(projectId, lastSeq: 99);

      // Verify it exists
      final existing = await storage.getSyncState(projectId);
      expect(existing, isNotNull);

      // Delete it
      final deleted = await storage.deleteSyncState(projectId);
      expect(deleted, isTrue);

      // Verify it's gone
      final notFound = await storage.getSyncState(projectId);
      expect(notFound, isNull);
    });

    test('delete non-existent sync state returns false', () async {
      final deleted = await storage.deleteSyncState('non-existent-project');
      expect(deleted, isFalse);
    });
  });
}
