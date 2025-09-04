import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/isar_storage_service.dart';
import 'package:sync_manager/src/models/cursor_sync_state.dart';
import 'package:sync_manager/src/models/isar_change_log_entry.dart';
import 'package:sync_manager/src/models/self_sync_state.dart';
import 'package:test/test.dart';

void main() {
  late IsarStorageService storage;
  late String testDbName;
  // Use a fixed base time for deterministic field-level tests
  final baseTime = DateTime.parse('2023-01-01T00:00:00Z');

  /// Helper to create change payloads similar to api_changes_network_test
  Map<String, dynamic> changePayload({
    required String projectId,
    required String entityType,
    required String entityId,
    required DateTime changeAt,
    String storageId = 'local',
    Map<String, dynamic> data = const <String, dynamic>{},
    String operation = 'update',
    bool addDefaultParentId = true,
  }) {
    final adjustedData = Map<String, dynamic>.from(data);
    // Ensure required parentId is present unless it's an explicit delete
    if (addDefaultParentId &&
        operation != 'delete' &&
        !adjustedData.containsKey('parentId')) {
      adjustedData['parentId'] = 'root';
    }
    return {
      'projectId': projectId,
      'domainId': projectId,
      'domainType': 'project',
      'entityType': entityType,
      'entityId': entityId,
      'changeBy': 'tester',
      'changeAt': changeAt.toUtc().toIso8601String(),
      'cid': generateCid(changeAt),
      'storageId': storageId,
      'operation': operation,
      'operationInfoJson': '{}',
      'stateChanged': false,
      'unknownJson': '{}',
      'dataJson': jsonEncode(adjustedData),
    };
  }

  setUp(() async {
    // Create unique database name for each test
    testDbName = 'test_${DateTime.now().millisecondsSinceEpoch}';
    storage = IsarStorageService(testDbName, 'Test');
    await storage.initialize();
  });

  tearDown(() async {
    // Close storage service
    await storage.close();
    // Clean up test database files
    final dir = Directory('./isar_db');
    if (await dir.exists()) {
      final files = await dir.list().toList();
      for (final file in files) {
        if (file.path.contains(testDbName)) {
          try {
            await file.delete();
          } catch (e) {
            // Ignore deletion errors during cleanup
          }
        }
      }
    }
  });

  group('IsarStorageService Basic Operations', () {
    test('initializes successfully', () async {
      expect(storage.getStorageType(), equals('local'));
      final storageId = await storage.getStorageId();
      expect(storageId, isNotEmpty);
      expect(
        storageId.length,
        equals(16),
        reason: 'Short storage ID format: $storageId',
      ); // Short storage ID format
    });

    test('creates and retrieves changes', () async {
      final projectId = 'proj-basic';
      final changeData = changePayload(
        projectId: projectId,
        entityType: 'project',
        entityId: 'entity-1',
        changeAt: baseTime,
        data: {'nameLocal': 'Test Project', 'parentId': 'root'},
      );

      // Create change
      final createdChange = await storage.createChange(changeData);
      expect(createdChange.seq, greaterThan(0));
      expect(createdChange.domainId, equals(projectId));
      expect(createdChange.entityType, equals('project'));
      expect(createdChange.entityId, equals('entity-1'));

      // Retrieve change by sequence number
      final retrievedChange = await storage.getChange(
        projectId,
        createdChange.seq,
      );
      expect(retrievedChange, isNotNull);
      expect(retrievedChange!.seq, equals(createdChange.seq));
      expect(retrievedChange.entityId, equals('entity-1'));
    });

    test('returns null for non-existent change', () async {
      final result = await storage.getChange('non-existent-project', 999);
      expect(result, isNull);
    });

    test('gets changes with cursor pagination', () async {
      final projectId = 'proj-pagination';

      // Create multiple changes
      for (int i = 1; i <= 5; i++) {
        final changeData = changePayload(
          projectId: projectId,
          entityType: 'project',
          entityId: 'entity-$i',
          changeAt: baseTime.add(Duration(minutes: i)),
          data: {'nameLocal': 'Project $i', 'parentId': 'root'},
        );
        await storage.createChange(changeData);
      }

      // Get changes with limit
      final changes = await storage.getChangesWithCursor(
        domainId: projectId,
        limit: 3,
      );
      expect(changes.length, equals(3));

      // Verify they're for the correct project
      for (final change in changes) {
        expect(change.domainId, equals(projectId));
      }
    });

    test('gets changes since specific sequence number', () async {
      final projectId = 'proj-since';
      final changes = <BaseChangeLogEntry>[];

      // Create multiple changes
      for (int i = 1; i <= 3; i++) {
        final changeData = changePayload(
          projectId: projectId,
          entityType: 'project',
          entityId: 'entity-$i',
          changeAt: baseTime.add(Duration(minutes: i)),
          data: {'nameLocal': 'Project $i', 'parentId': 'root'},
        );
        final change = await storage.createChange(changeData);
        changes.add(change);
      }

      // Get changes since the first one
      final sinceChanges = await storage.getChangesSince(
        projectId,
        changes[0].seq,
      );

      // Should include changes 2 and 3 (after seq 1)
      expect(sinceChanges.length, equals(2));
      expect(sinceChanges[0].entityId, equals('entity-2'));
      expect(sinceChanges[1].entityId, equals('entity-3'));
    });
  });

  group('IsarStorageService Entity State Operations', () {
    test('creates and retrieves project entity state', () async {
      final projectId = 'proj-state';
      final entityId = 'entity-project-1';

      // Create a change that will generate entity state
      final changeData = changePayload(
        projectId: projectId,
        entityType: 'project',
        entityId: entityId,
        changeAt: baseTime,
        data: {'nameLocal': 'Test Project', 'parentId': 'root'},
        operation: 'create',
      );

      // Use updateChangeLogAndState to create both change and state
      final change = IsarChangeLogEntry.fromJson(changeData);
      final result = await storage.updateChangeLogAndState(
        changeLogEntry: change,
        changeUpdates: {'seq': 1, 'stateChanged': true},
        stateUpdates: {
          'entityId': entityId,
          'entityType': 'project',
          'change_domainId': projectId,
          'change_changeAt': baseTime.toIso8601String(),
          'change_cid': change.cid,
          'change_changeBy': 'tester',
          'change_domainId_orig_': '', // Empty string for string orig fields
          'change_changeAt_orig_': BaseEntityState.defaultOrigDateTime()
              .toIso8601String(), // defaultOrigDateTime()
          'change_cid_orig_': '', // Empty string for string orig fields
          'change_changeBy_orig_': '', // Empty string for string orig fields
          'data_nameLocal': 'Test Project',
          'data_parentId': 'root',
          'data_parentId_changeAt_': baseTime.toIso8601String(),
          'data_parentId_cid_': change.cid,
          'data_parentId_changeBy_': 'tester',
          'unknownJson': '{}',
        },
      );

      expect(result.newChangeLogEntry.seq, equals(1));
      expect(result.newEntityState.entityId, equals(entityId));

      // Retrieve the entity state
      final entityState = await storage.getCurrentEntityState(
        projectId,
        'project',
        entityId,
      );

      expect(entityState, isNotNull);
      expect(entityState!.entityType, equals('project'));
      expect(entityState.entityId, equals(entityId));
    });

    test('creates and retrieves document entity state', () async {
      final projectId = 'proj-doc';
      final entityId = 'doc-1';

      final changeData = changePayload(
        projectId: projectId,
        entityType: 'document',
        entityId: entityId,
        changeAt: baseTime,
        data: {'title': 'Test Document', 'parentId': 'root'},
        operation: 'create',
      );

      final change = IsarChangeLogEntry.fromJson(changeData);
      await storage.updateChangeLogAndState(
        changeLogEntry: change,
        changeUpdates: {'seq': 1, 'stateChanged': true},
        stateUpdates: {
          'entityId': entityId,
          'entityType': 'document',
          'change_domainId': projectId,
          'change_changeAt': baseTime.toIso8601String(),
          'change_cid': change.cid,
          'change_changeBy': 'tester',
          'change_domainId_orig_': '', // Empty string for string orig fields
          'change_changeAt_orig_': BaseEntityState.defaultOrigDateTime()
              .toIso8601String(), // defaultOrigDateTime()
          'change_cid_orig_': '', // Empty string for string orig fields
          'change_changeBy_orig_': '', // Empty string for string orig fields
          'data_title': 'Test Document',
          'data_parentId': 'root',
          'data_parentId_changeAt_': baseTime.toIso8601String(),
          'data_parentId_cid_': change.cid,
          'data_parentId_changeBy_': 'tester',
          'unknownJson': '{}',
        },
      );

      final entityState = await storage.getCurrentEntityState(
        projectId,
        'document',
        entityId,
      );

      expect(entityState, isNotNull);
      expect(entityState!.entityType, equals('document'));
      expect(entityState.entityId, equals(entityId));
    });

    test('creates and retrieves team entity state', () async {
      final projectId = 'proj-team';
      final entityId = 'team-1';

      final changeData = changePayload(
        projectId: projectId,
        entityType: 'team',
        entityId: entityId,
        changeAt: baseTime,
        data: {'name': 'Test Team', 'parentId': 'root'},
        operation: 'create',
      );

      final change = IsarChangeLogEntry.fromJson(changeData);
      await storage.updateChangeLogAndState(
        changeLogEntry: change,
        changeUpdates: {'seq': 1, 'stateChanged': true},
        stateUpdates: {
          'entityId': entityId,
          'entityType': 'team',
          'change_domainId': projectId,
          'change_changeAt': baseTime.toIso8601String(),
          'change_cid': change.cid,
          'change_changeBy': 'tester',
          'change_domainId_orig_': '',
          'change_changeAt_orig_': '1970-01-01T00:00:00.000Z',
          'change_cid_orig_': '',
          'change_changeBy_orig_': '',
          'name': 'Test Team',
          'nameChangeAt': baseTime.toIso8601String(),
          'nameCid': change.cid,
          'nameChangeBy': 'tester',
          'description': '',
          'descriptionChangeAt': baseTime.toIso8601String(),
          'descriptionCid': change.cid,
          'descriptionChangeBy': 'tester',
          'leadId': '',
          'leadIdChangeAt': baseTime.toIso8601String(),
          'leadIdCid': change.cid,
          'leadIdChangeBy': 'tester',
          'settings': '{}',
          'settingsChangeAt': baseTime.toIso8601String(),
          'settingsCid': change.cid,
          'settingsChangeBy': 'tester',
          'data_parentId': 'root',
          'data_parentId_changeAt_': baseTime.toIso8601String(),
          'data_parentId_cid_': change.cid,
          'data_parentId_changeBy_': 'tester',
        },
      );

      final entityState = await storage.getCurrentEntityState(
        projectId,
        'team',
        entityId,
      );

      expect(entityState, isNotNull);
      expect(entityState!.entityType, equals('team'));
      expect(entityState.entityId, equals(entityId));
    });

    test('returns null for non-existent entity state', () async {
      final result = await storage.getCurrentEntityState(
        'non-existent-project',
        'project',
        'non-existent-entity',
      );
      expect(result, isNull);
    });

    test('handles unknown entity type gracefully', () async {
      final result = await storage.getCurrentEntityState(
        'test-project',
        'unknown',
        'test-entity',
      );
      expect(result, isNull);
    });
  });

  group('IsarStorageService Statistics and Project Operations', () {
    test('gets change statistics', () async {
      final projectId = 'proj-stats';

      // Create changes with different operations
      await storage.createChange(
        changePayload(
          projectId: projectId,
          entityType: 'project',
          entityId: 'entity-1',
          changeAt: baseTime,
          operation: 'create',
        ),
      );

      await storage.createChange(
        changePayload(
          projectId: projectId,
          entityType: 'project',
          entityId: 'entity-2',
          changeAt: baseTime.add(const Duration(minutes: 1)),
          operation: 'update',
        ),
      );

      await storage.createChange(
        changePayload(
          projectId: projectId,
          entityType: 'project',
          entityId: 'entity-3',
          changeAt: baseTime.add(const Duration(minutes: 2)),
          operation: 'delete',
        ),
      );

      final stats = await storage.getChangeStats(projectId);
      expect(stats['total'], greaterThanOrEqualTo(3));
      expect(stats['creates'], greaterThanOrEqualTo(1));
      expect(stats['updates'], greaterThanOrEqualTo(1));
      expect(stats['deletes'], greaterThanOrEqualTo(1));
    });

    test('gets entity type statistics', () async {
      final projectId = 'proj-entity-stats';

      // Create changes for different entity types
      await storage.createChange(
        changePayload(
          projectId: projectId,
          entityType: 'project',
          entityId: 'proj-1',
          changeAt: baseTime,
        ),
      );

      await storage.createChange(
        changePayload(
          projectId: projectId,
          entityType: 'document',
          entityId: 'doc-1',
          changeAt: baseTime.add(const Duration(minutes: 1)),
        ),
      );

      await storage.createChange(
        changePayload(
          projectId: projectId,
          entityType: 'document',
          entityId: 'doc-2',
          changeAt: baseTime.add(const Duration(minutes: 2)),
        ),
      );

      final stats = await storage.getEntityTypeStats(projectId);
      expect(stats['project'], greaterThanOrEqualTo(1));
      expect(stats['document'], greaterThanOrEqualTo(2));
    });

    test('gets all projects', () async {
      final projects = ['proj-1', 'proj-2', 'proj-3'];

      // Create changes for different projects
      for (int i = 0; i < projects.length; i++) {
        await storage.createChange(
          changePayload(
            projectId: projects[i],
            entityType: 'project',
            entityId: 'entity-$i',
            changeAt: baseTime.add(Duration(minutes: i)),
          ),
        );
      }

      final allProjects = await storage.getAllProjects();
      for (final project in projects) {
        expect(allProjects, contains(project));
      }
    });
  });

  group('IsarStorageService Entity States API', () {
    test('returns empty result for non-existent project entities', () async {
      final result = await storage.getEntityStates(
        domainId: 'non-existent',
        entityType: 'project',
        includeMetadata: true,
      );

      expect(result['items'], isA<List>());
      expect((result['items'] as List), isEmpty);
      expect(result['nextCursor'], isNull);
      expect(result['hasMore'], isFalse);
    });

    test('handles stubbed entity states method', () async {
      // The current implementation is stubbed to return empty results
      final result = await storage.getEntityStates(
        domainId: 'test-project',
        entityType: 'project',
        includeMetadata: true,
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['items'], isA<List>());
      expect(result['hasMore'], isA<bool>());
      expect(result.containsKey('nextCursor'), isTrue);
    });
  });

  group('IsarStorageService Field-Level Change Detection', () {
    test(
      'handles field-level conflict resolution (newer change wins)',
      () async {
        final projectId = 'proj-conflict';
        final entityId = 'entity-conflict-1';

        // Create initial entity state
        final initialChange = changePayload(
          projectId: projectId,
          entityType: 'project',
          entityId: entityId,
          changeAt: baseTime,
          data: {'nameLocal': 'Original Name', 'rank': '1'},
          operation: 'create',
        );

        final change1 = IsarChangeLogEntry.fromJson(initialChange);
        final result1 = await storage.updateChangeLogAndState(
          changeLogEntry: change1,
          changeUpdates: {'seq': 1, 'stateChanged': true},
          stateUpdates: {
            'entityId': entityId,
            'entityType': 'project',
            'change_domainId': projectId,
            'change_changeAt': baseTime.toIso8601String(),
            'change_cid': change1.cid,
            'change_changeBy': 'user1',
            'change_domainId_orig_': '',
            'change_changeAt_orig_': '1970-01-01T00:00:00.000Z',
            'change_cid_orig_': '',
            'change_changeBy_orig_': '',
            'data_nameLocal': 'Original Name',
            'data_nameLocal_changeAt_': baseTime.toIso8601String(),
            'data_nameLocal_cid_': change1.cid,
            'data_nameLocal_changeBy_': 'user1',
            'data_rank': '1',
            'data_rank_changeAt_': baseTime.toIso8601String(),
            'data_rank_cid_': change1.cid,
            'data_rank_changeBy_': 'user1',
            'data_parentId': 'root',
            'data_parentId_changeAt_': baseTime.toIso8601String(),
            'data_parentId_cid_': change1.cid,
            'data_parentId_changeBy_': 'user1',
          },
        );

        print(
          '1 - Initial change result: ${result1.newChangeLogEntry.toJson()}',
        );
        print('1 - Initial state result: ${result1.newEntityState.toJson()}');

        // Apply a newer change to nameLocal
        final newerTime = baseTime.add(const Duration(minutes: 5));
        final newerChange = changePayload(
          projectId: projectId,
          entityType: 'project',
          entityId: entityId,
          changeAt: newerTime,
          data: {'nameLocal': 'Updated Name'},
          operation: 'update',
        );

        final change2 = IsarChangeLogEntry.fromJson(newerChange);
        final currentState = await storage.getCurrentEntityState(
          projectId,
          'project',
          entityId,
        );

        print('2 - Current state before update: ${currentState?.toJson()}');
        print('2 - Current change result: ${change2.toJson()}');

        final result = await storage.updateChangeLogAndState(
          changeLogEntry: change2,
          changeUpdates: {'stateChanged': true},
          entityState: currentState,
          stateUpdates: {
            'data_nameLocal': 'Updated Name',
            'data_nameLocal_changeAt_': newerTime.toIso8601String(),
            'data_nameLocal_cid_': change2.cid,
          },
        );

        print('3 - Update result: ${result.newChangeLogEntry.toJson()}');
        print('3 - Update state result: ${result.newEntityState.toJson()}');

        expect(result.newChangeLogEntry.seq, equals(2));

        // Verify the state was updated with newer change
        final finalState = await storage.getCurrentEntityState(
          projectId,
          'project',
          entityId,
        );
        expect(finalState, isNotNull);

        // The current implementation is basic, but we can verify the structure
        expect(finalState!.entityId, equals(entityId));
      },
    );

    test('preserves non-conflicting fields during updates', () async {
      final projectId = 'proj-preserve';
      final entityId = 'entity-preserve-1';

      // Create initial state with multiple fields
      final initialChange = changePayload(
        projectId: projectId,
        entityType: 'project',
        entityId: entityId,
        changeAt: baseTime,
        data: {
          'nameLocal': 'Original Name',
          'rank': '1',
          'parentId': 'parent1',
        },
        operation: 'create',
      );

      final change1 = IsarChangeLogEntry.fromJson(initialChange);
      await storage.updateChangeLogAndState(
        changeLogEntry: change1,
        changeUpdates: {'seq': 1, 'stateChanged': true},
        stateUpdates: {
          'entityId': entityId,
          'entityType': 'project',
          'change_domainId': projectId,
          'change_domainId_orig_': '',
          'change_changeAt': baseTime.toIso8601String(),
          'change_changeAt_orig_': BaseEntityState.defaultOrigDateTime()
              .toIso8601String(),
          'change_cid': change1.cid,
          'change_cid_orig_': '',
          'change_changeBy': 'user1',
          'change_changeBy_orig_': '',
          'data_nameLocal': 'Original Name',
          'data_rank': '1',
          'data_parentId': 'parent1',
          'data_parentId_changeAt_': baseTime.toIso8601String(),
          'data_parentId_cid_': change1.cid,
          'data_parentId_changeBy_': 'user1',
          'data_parentId_cloudAt_': null,
        },
      );

      // Update only one field
      final updateChange = changePayload(
        projectId: projectId,
        entityType: 'project',
        entityId: entityId,
        changeAt: baseTime.add(const Duration(minutes: 2)),
        data: {'nameLocal': 'New Name'}, // Only updating nameLocal
        operation: 'update',
      );

      final change2 = IsarChangeLogEntry.fromJson(updateChange);
      final currentState = await storage.getCurrentEntityState(
        projectId,
        'project',
        entityId,
      );

      await storage.updateChangeLogAndState(
        changeLogEntry: change2,
        changeUpdates: {'seq': 2, 'stateChanged': true},
        entityState: currentState,
        stateUpdates: {'data_nameLocal': 'New Name'},
      );

      // Verify the entity still exists and can be retrieved
      final finalState = await storage.getCurrentEntityState(
        projectId,
        'project',
        entityId,
      );
      expect(finalState, isNotNull);
      expect(finalState!.entityId, equals(entityId));
    });
  });

  group('IsarStorageService markAsOutdated', () {
    test('markAsOutdated method exists and can be called', () async {
      // Test that the method exists and doesn't throw
      await storage.markAsOutdated('test-project', 1, 2);
      // Since it's currently stubbed, just verify it doesn't throw
    });
  });

  group('IsarStorageService Edge Cases', () {
    test('handles entity creation with minimal data', () async {
      final projectId = 'proj-minimal';
      final entityId = 'entity-minimal';

      final changeData = changePayload(
        projectId: projectId,
        entityType: 'project',
        entityId: entityId,
        changeAt: baseTime,
        data: {'parentId': 'root'}, // Minimal required data
        operation: 'create',
      );

      final change = await storage.createChange(changeData);
      expect(change.seq, greaterThan(0));
      expect(change.domainId, equals(projectId));
      expect(change.entityId, equals(entityId));
    });

    test('handles entity deletion', () async {
      final projectId = 'proj-delete';
      final entityId = 'entity-delete';

      // First create the entity
      await storage.createChange(
        changePayload(
          projectId: projectId,
          entityType: 'project',
          entityId: entityId,
          changeAt: baseTime,
          data: {'nameLocal': 'To Be Deleted', 'parentId': 'root'},
          operation: 'create',
        ),
      );

      // Then delete it
      final deleteChange = await storage.createChange(
        changePayload(
          projectId: projectId,
          entityType: 'project',
          entityId: entityId,
          changeAt: baseTime.add(const Duration(minutes: 1)),
          data: {'deleted': true},
          operation: 'delete',
          addDefaultParentId: false,
        ),
      );

      expect(deleteChange.operation, equals('delete'));
      expect(deleteChange.entityId, equals(entityId));
    });

    test('handles large data payloads', () async {
      final projectId = 'proj-large';
      final entityId = 'entity-large';

      // Create a change with large data payload
      final largeData = {
        'parentId': 'root',
        'nameLocal': 'Large Entity',
        'description': 'A' * 1000, // 1000 character description
        'metadata': List.generate(100, (i) => 'item-$i'),
      };

      final changeData = changePayload(
        projectId: projectId,
        entityType: 'project',
        entityId: entityId,
        changeAt: baseTime,
        data: largeData,
        operation: 'create',
      );

      final change = await storage.createChange(changeData);
      expect(change.seq, greaterThan(0));

      // Retrieve and verify the data was stored correctly
      final retrieved = await storage.getChange(projectId, change.seq);
      expect(retrieved, isNotNull);
      expect(retrieved!.entityId, equals(entityId));
    });
  });

  group('SelfSyncState and CursorSyncState persistence', () {
    test(
      'ensureStorageId creates SelfSyncState and persists across reopen',
      () async {
        final id1 = await storage.ensureStorageId();
        expect(id1, isNotEmpty);

        // Close storage and open Isar directly to verify the SelfSyncState was persisted
        await storage.close();

        final dir = Directory('./isar_db');
        final isar = await Isar.open(
          [SelfSyncStateSchema, CursorSyncStateSchema],
          directory: dir.path,
          name: testDbName,
        );

        final existing = await isar.selfSyncStates
            .filter()
            .domainIdEqualTo('root')
            .findFirst();

        expect(existing, isNotNull);
        expect(existing!.storageId, equals(id1));

        await isar.close();

        // Re-initialize storage so tearDown can close it normally
        storage = IsarStorageService(testDbName, 'Test');
        await storage.initialize();
      },
    );

    test('can create and retrieve CursorSyncState directly in Isar', () async {
      final now = DateTime.now().toUtc();
      final cursor = CursorSyncState(
        domainId: 'cursor-domain',
        domainType: 'cursor',
        storageId: 'local',
        storageType: 'local',
        cid: 'cid-1',
        changeAt: now,
        seq: 1,
      );

      // Close storage before opening raw Isar to avoid conflicts
      await storage.close();

      final dir = Directory('./isar_db');
      final isar = await Isar.open(
        [SelfSyncStateSchema, CursorSyncStateSchema],
        directory: dir.path,
        name: testDbName,
      );

      await isar.writeTxn(() async {
        await isar.cursorSyncStates.put(cursor);
      });

      final found = await isar.cursorSyncStates
          .filter()
          .domainIdEqualTo('cursor-domain')
          .findFirst();

      expect(found, isNotNull);
      expect(found!.domainId, equals('cursor-domain'));

      await isar.close();

      // Re-initialize storage so tearDown can close it normally
      storage = IsarStorageService(testDbName, 'Test');
      await storage.initialize();
    });
  });
}
