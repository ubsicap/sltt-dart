import 'dart:io';
import 'package:test/test.dart';
import 'package:sync_manager/src/isar_storage_service.dart';
import 'package:sync_manager/src/models/isar_change_log_entry.dart';

void main() {
  IsarStorageService? storage;
  const testDbName = 'test_get_entity_states';

  Future<void> cleanupTestDatabase() async {
    try {
      final dir = Directory('./isar_db');
      if (await dir.exists()) {
        final files = await dir.list().toList();
        for (final file in files) {
          if (file.path.contains(testDbName)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Warning: Failed to clean up test database: $e');
    }
  }

  setUpAll(() async {
    await cleanupTestDatabase();
    isarChangeLogEntryFactoryRegistration;
    storage = IsarStorageService('local', testDbName);
    await storage!.initialize();
    print(
      '[TestGetEntityStates] Isar database initialized at: ./isar_db/$testDbName.isar',
    );
  });

  tearDownAll(() async {
    if (storage != null) {
      await storage!.close();
    }
    await cleanupTestDatabase();
  });

  group('IsarStorageService.getEntityStates', () {
    test('returns empty list when no entities exist', () async {
      final result = await storage!.getEntityStates(
        domainType: 'project',
        domainId: 'non-existent-project',
        entityType: 'task',
      );

      expect(result['items'], isEmpty);
      expect(result['hasMore'], isFalse);
      expect(result['nextCursor'], isNull);
    });

    test('throws ArgumentError for unsupported entity type', () async {
      expect(
        () => storage!.getEntityStates(
          domainType: 'project',
          domainId: 'test-project',
          entityType: 'unsupported-type',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Unsupported entity type'),
          ),
        ),
      );
    });

    test('handles large cursor values gracefully', () async {
      final result = await storage!.getEntityStates(
        domainType: 'project',
        domainId: 'test-project',
        entityType: 'task',
        cursor: 'zzzzz-very-large-cursor-value',
      );

      expect(result['items'], isEmpty);
      expect(result['hasMore'], isFalse);
      expect(result['nextCursor'], isNull);
    });

    test('handles edge case with zero limit', () async {
      final result = await storage!.getEntityStates(
        domainType: 'project',
        domainId: 'test-project',
        entityType: 'task',
        limit: 0,
      );

      expect(result['items'], isEmpty);
      expect(result['hasMore'], isFalse);
      expect(result['nextCursor'], isNull);
    });

    test('accepts parentId parameter without error', () async {
      final result = await storage!.getEntityStates(
        domainType: 'project',
        domainId: 'test-project',
        entityType: 'task',
        parentId: 'some-parent-id',
      );

      expect(result['items'], isEmpty);
      expect(result['hasMore'], isFalse);
      expect(result['nextCursor'], isNull);
    });

    test('parentId parameter works with other parameters', () async {
      final result = await storage!.getEntityStates(
        domainType: 'project',
        domainId: 'test-project',
        entityType: 'task',
        parentId: 'some-parent-id',
        limit: 50,
        cursor: 'some-cursor',
        includeMetadata: true,
      );

      expect(result['items'], isEmpty);
      expect(result['hasMore'], isFalse);
      expect(result['nextCursor'], isNull);
    });

    // More comprehensive tests with real data would go here, but they require
    // proper setup of entity states using the full updateChangeLogAndState
    // method with proper state data structure, which is better tested in
    // integration tests or through the existing network test suite.
  });
}
