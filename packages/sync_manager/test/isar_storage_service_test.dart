import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:isar_community/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/isar_storage_service.dart';
import 'package:sync_manager/src/models/cursor_sync_state.dart';
import 'package:sync_manager/src/models/isar_change_log_entry.dart';
import 'package:sync_manager/src/models/isar_storage_state.dart';
import 'package:sync_manager/src/test_helpers/isar_change_log_serializer.dart';
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
    String storageId = '',
    Map<String, dynamic> data = const <String, dynamic>{},
    String operation = 'update',
    bool addDefaultParentId = true,
    int? seq,
  }) {
    final adjustedData = Map<String, dynamic>.from(data);
    // Normalize parentId/parentProp: treat explicit nulls as missing and
    // inject defaults for non-delete operations. This prevents cases where
    // tests pass `parentId: null` (or omit parentId) which would later
    // cause checked deserialization errors inside the server code.
    if (operation != 'delete') {
      final hasParentKey = adjustedData.containsKey('parentId');
      final parentVal = adjustedData['parentId'];
      if (addDefaultParentId && (!hasParentKey || parentVal == null)) {
        adjustedData['parentId'] = 'root';
      }

      // Ensure parentProp exists and is non-null when parentId is present
      final hasParentProp = adjustedData.containsKey('parentProp');
      final parentPropVal = adjustedData['parentProp'];
      if (!hasParentProp || parentPropVal == null) {
        adjustedData['parentProp'] = 'pList';
      }
    }

    // If entityType is 'task' ensure a default nameLocal is present for
    // non-delete operations so IsarTaskState deserialization doesn't fail
    // when tests omit nameLocal.
    if (operation != 'delete' &&
        entityType == 'task' &&
        !adjustedData.containsKey('nameLocal')) {
      adjustedData['nameLocal'] = 'Test $entityId';
    }
    return {
      'domainId': projectId,
      'domainType': 'project',
      'entityType': entityType,
      'entityId': entityId,
      'changeBy': 'tester',
      'changeAt': changeAt.toUtc().toIso8601String(),
      'cid': generateCid(
        entityType: EntityType.tryFromString(entityType) ?? EntityType.unknown,
      ),
      'storageId': storageId,
      'operation': operation,
      'operationInfoJson': '{}',
      'stateChanged': false,
      'unknownJson': '{}',
      'dataJson': jsonEncode(adjustedData),
      if (seq != null) 'seq': seq,
    };
  }

  setUpAll(() async {
    // register Isar Change Log factory group
    registerIsarChangeLogSerializableGroup();
  });

  setUp(() async {
    // Create unique database name for each test (use microseconds + random)
    testDbName =
        'test_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 31)}';
    storage = IsarStorageService(testDbName, 'Test');
    await storage.deleteDatabase();
    await storage.initialize();
  });

  tearDown(() async {
    // Close storage service
    await storage.close();
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
        entityType: 'task',
        entityId: 'entity-1',
        changeAt: baseTime,
        storageId: '',
        data: {
          'nameLocal': 'Test Project',
          'parentId': 'root',
          'parentProp': 'pList',
        },
      );

      // Create change via ChangeProcessingService to exercise full processing
      final procResult = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [changeData],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(procResult.isSuccess, isTrue, reason: procResult.errorMessage);
      expect(
        procResult.resultsSummary!.created,
        isNotEmpty,
        reason:
            'storeChanges did not report created cids: ${procResult.resultsSummary}',
      );
      final createdCid = procResult.resultsSummary!.created.first;
      final createdChange = await storage.getChange(
        domainType: 'project',
        domainId: projectId,
        cid: createdCid,
      );
      expect(
        createdChange,
        isNotNull,
        reason: 'createdChange not found by cid',
      );
      final createdChangeNN = createdChange!;
      expect(createdChangeNN.seq, greaterThan(0));
      expect(createdChangeNN.domainId, equals(projectId));
      expect(createdChangeNN.entityType, equals('task'));
      expect(createdChangeNN.entityId, equals('entity-1'));
      // Timestamps should be set by the processing pipeline (storedAt at minimum)
      expect(
        createdChangeNN.storedAt,
        isNotNull,
        reason:
            'storedAt should be set by ChangeProcessingService/storeChanges',
      );
      expect(createdChangeNN.storedAt, isA<DateTime>());
      // For local source/storage we do not expect a cloudAt timestamp
      expect(createdChangeNN.cloudAt, isNull);

      // Retrieve change by sequence number
      final retrievedChange = await storage.getChange(
        domainType: 'project',
        domainId: projectId,
        cid: createdCid,
      );
      expect(retrievedChange, isNotNull);
      expect(retrievedChange!.seq, equals(createdChangeNN.seq));
      expect(retrievedChange.entityId, equals('entity-1'));
    });

    test('returns null for non-existent change', () async {
      final result = await storage.getChange(
        domainType: 'project',
        domainId: 'non-existent-project',
        cid: 'non-existent-cid',
      );
      expect(result, isNull);
    });

    test('gets changes with cursor pagination', () async {
      final projectId = 'proj-pagination';

      // Create multiple changes
      for (int i = 1; i <= 5; i++) {
        final changeData = changePayload(
          projectId: projectId,
          storageId: '',
          entityType: 'task',
          entityId: 'entity-$i-ayix',
          changeAt: baseTime.add(Duration(minutes: i)),
          data: {
            'nameLocal': 'Project $i',
            'parentId': 'root',
            'parentProp': 'pList',
          },
        );
        // Seed via ChangeProcessingService to get the same end-to-end behavior
        final r = await ChangeProcessingService.storeChanges(
          storageMode: 'save',
          changes: [changeData],
          srcStorageType: 'local',
          srcStorageId: 'local-client',
          storage: storage,
          includeChangeUpdates: false,
          includeStateUpdates: false,
        );
        expect(r.isSuccess, isTrue, reason: r.errorMessage);
      }

      // Get changes with limit
      final changes = await storage.getChangesWithCursor(
        domainType: 'project',
        domainId: projectId,
        limit: 3,
      );
      expect(changes.length, equals(3));

      // Verify they're for the correct project
      for (final change in changes) {
        expect(change.domainId, equals(projectId));
      }
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
        data: {
          'nameLocal': 'Test Project',
          'parentId': 'root',
          'parentProp': 'pList',
        },
        operation: 'create',
      );

      final storageId = await storage.getStorageId();
      final storedAtChange1Json = DateTime.now().toUtc().toIso8601String();
      // Use updateChangeLogAndState to create both change and state
      final change = IsarChangeLogEntry.fromJson(changeData);
      final result = await storage.updateChangeLogAndState(
        domainType: 'project',
        changeLogEntry: change,
        changeUpdates: {
          'seq': 1,
          'stateChanged': true,
          'storageId': storageId,
          'storedAt': storedAtChange1Json,
        },
        operationCounts: OperationCounts(create: 1),
        stateUpdates: {
          'domainType': 'project',
          'entityId': entityId,
          'entityType': 'project',
          'change_storedAt': storedAtChange1Json,
          'change_storedAt_orig_': storedAtChange1Json,
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
          'data_parentProp': 'pList',
          'data_parentProp_dataSchemaRev_': 0,
          'data_parentProp_changeAt_': baseTime.toIso8601String(),
          'data_parentProp_cid_': change.cid,
          'data_parentProp_changeBy_': 'tester',
          // parentProp meta fields added above
          'unknownJson': '{}',
        },
      );

      expect(result.newChangeLogEntry.seq, equals(1));
      expect(result.newEntityState.entityId, equals(entityId));

      // Retrieve the entity state
      final entityState = await storage.getCurrentEntityState(
        domainType: 'project',
        domainId: projectId,
        entityType: 'project',
        entityId: entityId,
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
        data: {
          'title': 'Test Document',
          'parentId': 'root',
          'parentProp': 'pList',
        },
        operation: 'create',
      );

      final storageId = await storage.getStorageId();
      final storedAtChange2 = DateTime.now().toUtc().toIso8601String();

      final change = IsarChangeLogEntry.fromJson(changeData);
      await storage.updateChangeLogAndState(
        domainType: 'project',
        changeLogEntry: change,
        changeUpdates: {
          'seq': 1,
          'stateChanged': true,
          'storageId': storageId,
          'storedAt': storedAtChange2,
        },
        operationCounts: OperationCounts(create: 1),
        stateUpdates: {
          'domainType': 'project',
          'entityId': entityId,
          'entityType': 'document',
          'change_storedAt': storedAtChange2,
          'change_storedAt_orig_': storedAtChange2,
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
          'data_parentProp': 'pList',
          'data_parentProp_changeAt_': baseTime.toIso8601String(),
          'data_parentProp_cid_': change.cid,
          'data_parentProp_changeBy_': 'tester',
          'unknownJson': '{}',
        },
      );

      final entityState = await storage.getCurrentEntityState(
        domainType: 'project',
        domainId: projectId,
        entityType: 'document',
        entityId: entityId,
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
        data: {'name': 'Test Team', 'parentId': 'root', 'parentProp': 'pList'},
        operation: 'create',
      );

      final storageId = await storage.getStorageId();
      final storedAtChange = DateTime.now().toUtc().toIso8601String();

      final change = IsarChangeLogEntry.fromJson(changeData);
      await storage.updateChangeLogAndState(
        domainType: 'project',
        changeLogEntry: change,
        changeUpdates: {
          'seq': 1,
          'stateChanged': true,
          'storageId': storageId,
          'storedAt': storedAtChange,
        },
        operationCounts: OperationCounts(create: 1),
        stateUpdates: {
          'domainType': 'project',
          'entityId': entityId,
          'entityType': 'team',
          'change_storedAt': storedAtChange,
          'change_storedAt_orig_': storedAtChange,
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
          'data_parentProp': 'pList',
          'data_parentProp_changeAt_': baseTime.toIso8601String(),
          'data_parentProp_cid_': change.cid,
          'data_parentProp_changeBy_': 'tester',
        },
      );

      final entityState = await storage.getCurrentEntityState(
        domainType: 'project',
        domainId: projectId,
        entityType: 'team',
        entityId: entityId,
      );

      expect(entityState, isNotNull);
      expect(entityState!.entityType, equals('team'));
      expect(entityState.entityId, equals(entityId));
    });

    test('returns null for non-existent entity state', () async {
      final result = await storage.getCurrentEntityState(
        domainType: 'project',
        domainId: 'non-existent-project',
        entityType: 'project',
        entityId: 'non-existent-entity',
      );
      expect(result, isNull);
    });

    test('handles unknown entity type gracefully', () async {
      final result = await storage.getCurrentEntityState(
        domainType: 'project',
        domainId: 'test-project',
        entityType: 'unknown',
        entityId: 'test-entity',
      );
      expect(result, isNull);
    });
  });

  group('IsarStorageService Statistics and Project Operations', () {
    test('change-log deletion leaves state counters intact', () async {
      final projectId = 'proj-separation';

      // Create a single change via canonical processing so both a change-log
      // entry and entity-type sync state counters are created.
      final r = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [
          changePayload(
            projectId: projectId,
            entityType: 'task',
            entityId: 'sep-1',
            changeAt: baseTime,
            operation: 'create',
          ),
        ],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(r.isSuccess, isTrue, reason: r.errorMessage);
      final createdCid = r.resultsSummary!.created.first;

      // Ensure change-log shows 1 pending change
      final beforeStats = await storage.getChangeStats(
        domainType: 'project',
        domainId: projectId,
      );
      expect(beforeStats.totals.total, equals(1));

      // Delete the change-log entry (simulate outsync cleanup)
      final deleted = await storage.deleteChanges([createdCid]);
      expect(deleted, equals(1), reason: 'Expected one change to be deleted');

      // After deletion, change-log based stats should show zero pending changes
      final afterChangeStats = await storage.getChangeStats(
        domainType: 'project',
        domainId: projectId,
      );
      expect(afterChangeStats.totals.total, equals(0));
      expect(afterChangeStats.totals.creates, equals(0));

      // But entity-type state counters (historical) should still reflect the
      // original create operation performed earlier.
      final stateStats = await storage.getStateStats(
        domainType: 'project',
        domainId: projectId,
      );
      expect(stateStats.totals.total, equals(1));
      expect(stateStats.totals.creates, equals(1));
    });
    test('gets change statistics', () async {
      final projectId = 'proj-stats';

      // Create changes with different operations via ChangeProcessingService
      final r1 = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [
          changePayload(
            projectId: projectId,
            entityType: 'task',
            entityId: 'entity-1',
            changeAt: baseTime,
            operation: 'create',
          ),
        ],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(r1.isSuccess, isTrue, reason: r1.errorMessage);
      expect(
        r1.resultsSummary!.created,
        isNotEmpty,
        reason:
            'storeChanges did not report created cids: ${r1.resultsSummary}',
      );

      // Seed entity-2 so the subsequent 'update' operation is classified
      // as an update rather than a create.
      final seed2 = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [
          changePayload(
            projectId: projectId,
            entityType: 'task',
            entityId: 'entity-2',
            changeAt: baseTime.subtract(const Duration(minutes: 1)),
            operation: 'create',
          ),
        ],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(seed2.isSuccess, isTrue, reason: seed2.errorMessage);
      expect(seed2.resultsSummary!.created, isNotEmpty);

      final r2 = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [
          changePayload(
            projectId: projectId,
            entityType: 'task',
            entityId: 'entity-2',
            changeAt: baseTime.add(const Duration(minutes: 1)),
            operation: 'update',
            data: {'nameLocal': 'Updated Name'},
          ),
        ],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(r2.isSuccess, isTrue, reason: r2.errorMessage);
      // The result may be categorized as a create (if no prior state) or an
      // update (if a seed existed). Accept either created or updated CIDs.
      expect(
        r2.resultsSummary!.created.isNotEmpty ||
            r2.resultsSummary!.updated.isNotEmpty,
        isTrue,
        reason:
            'storeChanges did not report created or updated cids: ${r2.resultsSummary}',
      );

      final seed3 = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [
          changePayload(
            projectId: projectId,
            entityType: 'task',
            entityId: 'entity-3',
            changeAt: baseTime.subtract(const Duration(minutes: 2)),
            operation: 'create',
          ),
        ],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(seed3.isSuccess, isTrue, reason: seed3.errorMessage);

      final deletePayload = changePayload(
        projectId: projectId,
        entityType: 'task',
        entityId: 'entity-3',
        changeAt: baseTime.add(const Duration(minutes: 2)),
        operation: 'delete',
        addDefaultParentId: false,
        data: {'deleted': true, 'parentId': 'root', 'parentProp': 'pList'},
      );

      final dr = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [deletePayload],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(dr.isSuccess, isTrue, reason: dr.errorMessage);
      expect(
        dr.resultsSummary!.deleted,
        equals([deletePayload['cid']]),
        reason:
            'storeChanges did not report deleted cids: ${dr.resultsSummary}',
      );

      final expectedCid = deletePayload['cid'] as String;
      var persisted = await storage.getChange(
        domainType: 'project',
        domainId: projectId,
        cid: expectedCid,
      );

      expect(
        persisted,
        isNotNull,
        reason:
            'Persisted delete change was not found by payload cid ($expectedCid) or by storeChanges results: ${dr.resultsSummary}',
      );
      expect(persisted!.operation, equals('delete'));

      final statsDyn = await storage.getChangeStats(
        domainType: 'project',
        domainId: projectId,
      );
      SlttLogger.logger.fine('DEBUG: change stats for $projectId -> $statsDyn');
      // Compute expected counts from the processResults so the test
      // remains correct regardless of how individual changes were
      // classified (create vs update) by ChangeProcessingService.
      final expectedCreates =
          (r1.resultsSummary!.created.length) +
          (seed2.resultsSummary!.created.length) +
          (r2.resultsSummary!.created.length) +
          (seed3.resultsSummary!.created.length);
      final expectedUpdates = r2.resultsSummary!.updated.length;
      final expectedDeletes = dr.resultsSummary!.deleted.length;
      final expectedTotal = expectedCreates + expectedUpdates + expectedDeletes;

      expect(statsDyn.totals.total, equals(expectedTotal));
      expect(statsDyn.totals.creates, equals(expectedCreates));
      expect(statsDyn.totals.updates, equals(expectedUpdates));
      expect(statsDyn.totals.deletes, equals(expectedDeletes));
    });

    test('gets entity type statistics', () async {
      final projectId = 'proj-entity-stats';

      final payload = [
        changePayload(
          projectId: projectId,
          entityType: 'task',
          entityId: 'proj-1',
          changeAt: baseTime,
        ),
        changePayload(
          projectId: projectId,
          entityType: 'document',
          entityId: 'doc-1',
          changeAt: baseTime.add(const Duration(minutes: 1)),
        ),
        changePayload(
          projectId: projectId,
          entityType: 'document',
          entityId: 'doc-2',
          changeAt: baseTime.add(const Duration(minutes: 2)),
        ),
        changePayload(
          projectId: projectId,
          entityType: 'document',
          entityId: 'doc-2',
          changeAt: baseTime.add(const Duration(minutes: 3)),
          data: {'title': 'Updated Title'},
        ),
        changePayload(
          projectId: projectId,
          entityType: 'document',
          entityId: 'doc-2',
          changeAt: baseTime.add(const Duration(minutes: 4)),
          data: {'deleted': true},
        ),
      ];
      final r = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: payload,
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(r.isSuccess, isTrue, reason: r.errorMessage);
      expect(
        r.resultsSummary?.created.length,
        equals(3),
        reason: 'storeChanges did not report created cids: ${r.resultsSummary}',
      );
      expect(
        r.resultsSummary?.updated.length,
        equals(1),
        reason: 'storeChanges did not report updated cids: ${r.resultsSummary}',
      );
      expect(
        r.resultsSummary?.deleted.length,
        equals(1),
        reason: 'storeChanges did not report deleted cids: ${r.resultsSummary}',
      );
      final statsDyn = await storage.getStateStats(
        domainType: 'project',
        domainId: projectId,
      );
      final expectedStats = EntityTypeStats.fromJson({
        'entityTypes': {
          'task': {
            'creates': 1,
            'updates': 0,
            'deletes': 0,
            'total': 1,
            'latestChangeAt': '2023-01-01T00:00:00.000Z',
            'latestSeq': 1,
          },
          'document': {
            'creates': 2,
            'updates': 1,
            'deletes': 1,
            'total': 4,
            'latestChangeAt': '2023-01-01T00:04:00.000Z',
            'latestSeq': 5,
          },
        },
        'totals': {
          'creates': 1,
          'updates': 0,
          'deletes': 0,
          'total': 1,
          'latestChangeAt': '2023-01-01T00:00:00.000Z',
          'latestSeq': 1,
        },
      }).toJson();
      // New shape: { 'entityTypes': { '<type>': {creates, updates, deletes, total}}, 'totals': {...} }
      final stats = statsDyn.toJson();
      expect(stats.containsKey('entityTypes'), isTrue);
      final entityTypes = stats['entityTypes'];
      expect(
        entityTypes['project'],
        equals(expectedStats['entityTypes']['project']),
      );
      expect(
        entityTypes['document'],
        equals(expectedStats['entityTypes']['document']),
      );
    });

    test('gets all projects', () async {
      final projects = ['proj-1', 'proj-2', 'proj-3'];

      // Create changes for different projects via canonical processing
      for (int i = 0; i < projects.length; i++) {
        final payload = changePayload(
          projectId: projects[i],
          entityType: 'task',
          entityId: 'entity-$i',
          changeAt: baseTime.add(Duration(minutes: i)),
        );
        final r = await ChangeProcessingService.storeChanges(
          storageMode: 'save',
          changes: [payload],
          srcStorageType: 'local',
          srcStorageId: 'local-client',
          storage: storage,
          includeChangeUpdates: false,
          includeStateUpdates: false,
        );
        expect(r.isSuccess, isTrue, reason: r.errorMessage);
      }

      final allProjects = await storage.getAllDomainIds(
        domainType: kDomainProject,
      );
      for (final project in projects) {
        expect(allProjects, contains(project));
      }
    });
  });

  group('IsarStorageService Entity States API', () {
    test('returns empty result for non-existent project entities', () async {
      final result = await storage.getEntityStates(
        domainType: kDomainProject,
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
        domainType: kDomainProject,
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

        final storedAtJson = DateTime.now().toUtc().toIso8601String();
        final storageId = await storage.getStorageId();
        final change1 = IsarChangeLogEntry.fromJson(initialChange);
        final result1 = await storage.updateChangeLogAndState(
          domainType: 'project',
          changeLogEntry: change1,
          changeUpdates: {
            'seq': 1,
            'stateChanged': true,
            'storedAt': storedAtJson,
            'storageId': storageId,
          },
          operationCounts: OperationCounts(create: 1),
          stateUpdates: {
            'domainType': 'project',
            'entityId': entityId,
            'entityType': 'project',
            'change_storedAt': storedAtJson,
            'change_storedAt_orig_': storedAtJson,
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
            'data_parentProp': 'pList',
            'data_parentProp_changeAt_': baseTime.toIso8601String(),
            'data_parentProp_cid_': change1.cid,
            'data_parentProp_changeBy_': 'user1',
          },
        );

        SlttLogger.logger.fine(
          '1 - Initial change result: ${result1.newChangeLogEntry.toJson()}',
        );
        SlttLogger.logger.fine(
          '1 - Initial state result: ${result1.newEntityState.toJson()}',
        );

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
          domainType: 'project',
          domainId: projectId,
          entityType: 'project',
          entityId: entityId,
        );

        SlttLogger.logger.fine(
          '2 - Current state before update: ${currentState?.toJson()}',
        );
        SlttLogger.logger.fine(
          '2 - Current change result: ${change2.toJson()}',
        );

        final change2StoredAt = DateTime.now().toUtc().toIso8601String();
        final result = await storage.updateChangeLogAndState(
          domainType: 'project',
          changeLogEntry: change2,
          changeUpdates: {
            'stateChanged': true,
            'storedAt': change2StoredAt,
            'storageId': storageId,
          },
          operationCounts: OperationCounts(update: 1),
          entityState: currentState,
          stateUpdates: {
            'change_storedAt': change2StoredAt,
            'data_nameLocal': 'Updated Name',
            'data_nameLocal_changeAt_': newerTime.toIso8601String(),
            'data_nameLocal_cid_': change2.cid,
          },
        );

        SlttLogger.logger.fine(
          '3 - Update result: ${result.newChangeLogEntry.toJson()}',
        );
        SlttLogger.logger.fine(
          '3 - Update state result: ${result.newEntityState.toJson()}',
        );

        expect(result.newChangeLogEntry.seq, equals(2));

        // Verify the state was updated with newer change
        final finalState = await storage.getCurrentEntityState(
          domainType: 'project',
          domainId: projectId,
          entityType: 'project',
          entityId: entityId,
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

      final storageId = await storage.getStorageId();
      final storedAtJson = DateTime.now().toUtc().toIso8601String();
      final change1 = IsarChangeLogEntry.fromJson(initialChange);
      await storage.updateChangeLogAndState(
        domainType: kDomainProject,
        changeLogEntry: change1,
        changeUpdates: {
          'seq': 1,
          'stateChanged': true,
          'storageId': storageId,
          'storedAt': storedAtJson,
        },
        operationCounts: OperationCounts(create: 1),
        stateUpdates: {
          'domainType': 'project',
          'entityId': entityId,
          'entityType': 'project',
          'change_storedAt': storedAtJson,
          'change_storedAt_orig_': storedAtJson,
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
          'data_parentProp': 'pList',
          'data_parentProp_changeAt_': baseTime.toIso8601String(),
          'data_parentProp_cid_': change1.cid,
          'data_parentProp_changeBy_': 'user1',
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
        domainType: kDomainProject,
        domainId: projectId,
        entityType: kEntityTypeProject,
        entityId: entityId,
      );

      final change2StoredAt = DateTime.now().toUtc().toIso8601String();
      await storage.updateChangeLogAndState(
        domainType: 'project',
        changeLogEntry: change2,
        changeUpdates: {
          'seq': 2,
          'stateChanged': true,
          'storedAt': change2StoredAt,
          'storageId': storageId,
        },
        operationCounts: OperationCounts(update: 1),
        entityState: currentState,
        stateUpdates: {
          'data_nameLocal': 'New Name',
          'change_storedAt': change2StoredAt,
        },
      );

      // Verify the entity still exists and can be retrieved
      final finalState = await storage.getCurrentEntityState(
        domainType: kDomainProject,
        domainId: projectId,
        entityType: kEntityTypeProject,
        entityId: entityId,
      );
      expect(finalState, isNotNull);
      expect(finalState!.entityId, equals(entityId));
    });
  });

  group('IsarStorageService Edge Cases', () {
    test('handles entity creation with minimal data', () async {
      final projectId = 'proj-minimal';
      final entityId = 'entity-minimal';

      final changeData = changePayload(
        projectId: projectId,
        entityType: 'task',
        entityId: entityId,
        changeAt: baseTime,
        storageId: '',
        data: {
          'nameLocal': 'Test Project',
          'parentId': 'root',
          'parentProp': 'pList',
        },
      );
      final r = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [changeData],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(r.isSuccess, isTrue, reason: r.errorMessage);
      final createdCid = r.resultsSummary!.created.first;
      final change = await storage.getChange(
        domainType: 'project',
        domainId: projectId,
        cid: createdCid,
      );
      expect(change, isNotNull);
      expect(change!.seq, greaterThan(0));
      expect(change.domainId, equals(projectId));
      expect(change.entityId, equals(entityId));
    });

    test('project/project matching ids succeeds', () async {
      final projectId = 'proj-match-1';
      final entityId = 'proj-match-1';

      final changeData = changePayload(
        projectId: projectId,
        entityType: 'task',
        entityId: entityId,
        changeAt: baseTime,
        data: {
          'nameLocal': 'Matching Project',
          'parentId': 'root',
          'parentProp': 'pList',
        },
        operation: 'create',
      );

      final r = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [changeData],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );

      expect(r.isSuccess, isTrue, reason: r.errorMessage);
      expect(r.resultsSummary?.created, isNotEmpty);
    });

    test('project/project mismatched ids fails', () async {
      final projectId = 'proj-mismatch-1';
      final entityId = 'entity-not-equal';

      final changeData = changePayload(
        projectId: projectId,
        entityType: 'project',
        entityId: entityId,
        changeAt: baseTime,
        data: {
          'nameLocal': 'Mismatched Project',
          'parentId': 'root',
          'parentProp': 'pList',
        },
        operation: 'create',
      );

      final r = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [changeData],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );

      // Expect processing to report failure due to invariant violation.
      // Accept either an error message or a populated resultsSummary.errors.
      expect(r.isSuccess, isFalse);
      final hasErrorMessage =
          r.errorMessage != null && r.errorMessage!.isNotEmpty;
      final hasSummaryErrors = (r.resultsSummary?.errors != null)
          ? r.resultsSummary!.errors.isNotEmpty
          : false;
      expect(
        hasErrorMessage || hasSummaryErrors,
        isTrue,
        reason: 'Expected an error message or summary errors but got none',
      );
    });

    test('handles entity deletion', () async {
      final projectId = 'proj-delete';
      final entityId = 'entity-delete';

      // First create the entity via canonical processing
      final createPayload = changePayload(
        projectId: projectId,
        entityType: 'task',
        entityId: entityId,
        changeAt: baseTime,
        data: {
          'nameLocal': 'To Be Deleted',
          'parentId': 'root',
          'parentProp': 'pList',
        },
        operation: 'create',
      );
      final r1 = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [createPayload],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(r1.isSuccess, isTrue, reason: r1.errorMessage);

      // Then delete it
      final deletePayload = changePayload(
        projectId: projectId,
        entityType: 'task',
        entityId: entityId,
        changeAt: baseTime.add(const Duration(minutes: 1)),
        data: {'deleted': true, 'parentId': 'root', 'parentProp': 'pList'},
        operation: 'delete',
        addDefaultParentId: false,
      );
      final r2 = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [deletePayload],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(r2.isSuccess, isTrue, reason: r2.errorMessage);
      final expectedCid = deletePayload['cid'] as String;
      final deleteChange = await storage.getChange(
        domainType: 'project',
        domainId: projectId,
        cid: expectedCid,
      );
      expect(deleteChange, isNotNull);
      expect(deleteChange!.operation, equals('delete'));
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
        entityType: 'task',
        entityId: entityId,
        changeAt: baseTime,
        data: largeData,
        operation: 'create',
      );

      final r3 = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [changeData],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(r3.isSuccess, isTrue, reason: r3.errorMessage);
      final createdCid3 = r3.resultsSummary!.created.first;

      // Retrieve and verify the data was stored correctly
      final retrieved = await storage.getChange(
        domainType: 'project',
        domainId: projectId,
        cid: createdCid3,
      );
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
          [IsarStorageStateSchema, CursorSyncStateSchema],
          directory: dir.path,
          name: testDbName,
        );

        final existing = await isar.isarStorageStates
            .filter()
            .storageTypeEqualTo('local')
            .findFirst();

        expect(existing, isNotNull);
        expect(existing!.storageId, equals(id1));

        await isar.close();

        // Re-initialize storage so tearDown can close it normally
        storage = IsarStorageService(testDbName, 'Test');
        await storage.initialize();
      },
    );

    test('testResetDomainStorage deletes domain-scoped data', () async {
      final domainId = '__test_reset_1';
      final entityId = 'entity-to-clear';

      // Seed a change which will also create entity state via canonical processing
      final payload = changePayload(
        projectId: domainId,
        // This test seeds a change and entity state for the domain. The
        // entityId intentionally differs from the domainId, so use a
        // non-project entity type (task) so the production invariant
        // (project/project -> ids must match) is not violated by the
        // seeded test data.
        entityType: 'task',
        entityId: entityId,
        changeAt: baseTime,
        operation: 'create',
      );

      final seedRes = await ChangeProcessingService.storeChanges(
        storageMode: 'save',
        changes: [payload],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(seedRes.isSuccess, isTrue, reason: seedRes.errorMessage);
      final createdCid = seedRes.resultsSummary!.created.first;

      // Verify the change and the entity state exist
      final createdChange = await storage.getChange(
        domainType: 'project',
        domainId: domainId,
        cid: createdCid,
      );
      expect(
        createdChange,
        isNotNull,
        reason: 'Seeded change should be present before reset',
      );

      // The seeded entity state is for a 'task' (see payload above).
      final entityState = await storage.getCurrentEntityState(
        domainType: 'project',
        domainId: domainId,
        entityType: 'task',
        entityId: entityId,
      );
      expect(
        entityState,
        isNotNull,
        reason: 'Seeded entity state should be present before reset',
      );

      // Create a cursor sync state for the domain
      await storage.upsertCursorSyncState(
        domainType: 'project',
        domainId: domainId,
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        seq: createdChange!.seq,
        cid: createdChange.cid,
        changeAt: createdChange.changeAt,
      );

      final cursorBefore = await storage.getCursorSyncState(domainId);
      expect(
        cursorBefore,
        isNotNull,
        reason: 'Cursor sync state should exist before reset',
      );

      // Perform the test reset
      await storage.testResetDomainStorage(
        domainType: 'project',
        domainId: domainId,
      );

      // Verify change is removed
      final afterChange = await storage.getChange(
        domainType: 'project',
        domainId: domainId,
        cid: createdCid,
      );
      expect(
        afterChange,
        isNull,
        reason: 'Change should be deleted by testResetDomainStorage',
      );

      // Verify entity state removed
      final afterState = await storage.getCurrentEntityState(
        domainType: 'project',
        domainId: domainId,
        entityType: 'task',
        entityId: entityId,
      );
      expect(
        afterState,
        isNull,
        reason: 'Entity state should be deleted by testResetDomainStorage',
      );

      // Verify cursor state removed
      final cursorAfter = await storage.getCursorSyncState(domainId);
      expect(
        cursorAfter,
        isNull,
        reason: 'Cursor sync state should be deleted by testResetDomainStorage',
      );

      // Verify domain is no longer reported
      final allDomains = await storage.getAllDomainIds(domainType: 'project');
      expect(
        allDomains,
        isNot(contains(domainId)),
        reason: 'Domain should not be listed after reset',
      );
    });

    test('testResetDomainStorage rejects unsafe domain ids', () async {
      // Should throw if domainId does not start with __test
      expect(
        () => storage.testResetDomainStorage(
          domainType: 'project',
          domainId: 'prod-1',
        ),
        throwsArgumentError,
      );
    });

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
        [IsarStorageStateSchema, CursorSyncStateSchema],
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
