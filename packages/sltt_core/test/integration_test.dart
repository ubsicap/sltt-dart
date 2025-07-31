import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  group('Integration Tests', () {
    late OutsyncsStorageService outsyncsStorage;
    late DownsyncsStorageService downsyncsStorage;
    late CloudStorageService cloudStorage;

    setUpAll(() async {
      outsyncsStorage = OutsyncsStorageService.instance;
      downsyncsStorage = DownsyncsStorageService.instance;
      cloudStorage = CloudStorageService.instance;

      await outsyncsStorage.initialize();
      await downsyncsStorage.initialize();
      await cloudStorage.initialize();
    });

    tearDownAll(() async {
      await outsyncsStorage.close();
      await downsyncsStorage.close();
      await cloudStorage.close();
    });

    test('storage services initialization', () async {
      // Storage services should be initialized from setUpAll
      expect(outsyncsStorage, isNotNull);
      expect(downsyncsStorage, isNotNull);
      expect(cloudStorage, isNotNull);
    });

    test('multi-project support', () async {
      final testChange1 = {
        'projectId': 'project-test-1',
        'entityType': 'document',
        'operation': 'create',
        'entityId': 'doc-123',
        'data': {'title': 'Test Document 1', 'content': 'Content 1'},
      };

      final testChange2 = {
        'projectId': 'project-test-2',
        'entityType': 'document',
        'operation': 'create',
        'entityId': 'doc-456',
        'data': {'title': 'Test Document 2', 'content': 'Content 2'},
      };

      final result1 = await outsyncsStorage.createChange(testChange1);
      final result2 = await outsyncsStorage.createChange(testChange2);

      expect(result1.seq, isNotNull);
      expect(result2.seq, isNotNull);
      expect(result1.projectId, equals('project-test-1'));
      expect(result2.projectId, equals('project-test-2'));
    });

    test('project discovery', () async {
      final projects = await outsyncsStorage.getAllProjects();

      expect(projects, contains('project-test-1'));
      expect(projects, contains('project-test-2'));
    });

    test('change retrieval by project', () async {
      final project1Changes = await outsyncsStorage.getChangesWithCursor(
        projectId: 'project-test-1',
      );
      final project2Changes = await outsyncsStorage.getChangesWithCursor(
        projectId: 'project-test-2',
      );

      expect(project1Changes, isNotEmpty);
      expect(project2Changes, isNotEmpty);

      // Verify each change has correct projectId
      for (final change in project1Changes) {
        expect(change.projectId, equals('project-test-1'));
      }

      for (final change in project2Changes) {
        expect(change.projectId, equals('project-test-2'));
      }
    });

    test('project statistics', () async {
      final stats1 = await outsyncsStorage.getChangeStats('project-test-1');
      final stats2 = await outsyncsStorage.getChangeStats('project-test-2');

      expect(stats1['total'], greaterThan(0));
      expect(stats2['total'], greaterThan(0));
    });
  });
}
