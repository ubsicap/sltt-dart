import 'package:sync_manager/src/isar_storage_service.dart';
import 'package:sync_manager/src/models/isar_task_state.dart';
import 'package:sync_manager/src/models/unknown_entity_state.isar.dart';
import 'package:test/test.dart';

void main() {
  late IsarStorageService storage;
  const dbName = 'isar_unknown_entity_migration_test';

  setUp(() async {
    storage = IsarStorageService(dbName, 'UnknownMigrationTest');
    await storage.deleteDatabase();
    await storage.initialize();
  });

  tearDown(() async {
    await storage.close();
  });

  group('Isar unknown entity migration', () {
    test(
      'migrates resolvable raw entityType rows to target collection',
      () async {
        final now = DateTime.now().toUtc();
        final row1 = _unknownTaskRow(
          entityId: 'task-migrate-1',
          domainId: '__test_migrate_domain',
          changeAt: now,
        );
        final row2 = _unknownTaskRow(
          entityId: 'task-migrate-2',
          domainId: '__test_migrate_domain',
          changeAt: now.add(const Duration(seconds: 1)),
        );

        late List<int> insertedIds;
        await storage.isar.writeTxn(() async {
          insertedIds = await storage.isar.isarUnknownEntityStates.putAll([
            row1,
            row2,
          ]);
        });

        final result = await storage.migrateUnknownEntityStates(
          maxRowsPerBatch: 1,
        );

        expect(result.rowsScanned, equals(2));
        expect(result.rowsMigrated, equals(2));
        expect(result.rowsDeleted, equals(2));
        expect(result.rowsSkipped, equals(0));
        expect(result.rowsFailed, equals(0));
        expect(result.migratedEntityTypes, contains('task'));

        final unknownRemaining = await storage.isar.isarUnknownEntityStates
            .count();
        expect(unknownRemaining, equals(0));
        for (final id in insertedIds) {
          final oldRow = await storage.isar.isarUnknownEntityStates.get(id);
          expect(oldRow, isNull);
        }

        final migratedOne = await storage.getEntityState(
          domainType: 'project',
          domainId: '__test_migrate_domain',
          entityType: 'task',
          entityId: 'task-migrate-1',
        );
        final migratedTwo = await storage.getEntityState(
          domainType: 'project',
          domainId: '__test_migrate_domain',
          entityType: 'task',
          entityId: 'task-migrate-2',
        );

        expect(migratedOne, isA<IsarTaskState>());
        expect(migratedTwo, isA<IsarTaskState>());
      },
    );

    test(
      'skips unresolved entity types and keeps rows in unknown table',
      () async {
        final now = DateTime.now().toUtc();
        final unknownTypeRow = _unknownTaskRow(
          entityId: 'entity-unresolved',
          domainId: '__test_unresolved_domain',
          changeAt: now,
          entityType: 'totallyRandomFutureType',
        );

        late int insertedId;
        await storage.isar.writeTxn(() async {
          insertedId = await storage.isar.isarUnknownEntityStates.put(
            unknownTypeRow,
          );
        });

        final result = await storage.migrateUnknownEntityStates();

        expect(result.rowsScanned, equals(1));
        expect(result.rowsMigrated, equals(0));
        expect(result.rowsDeleted, equals(0));
        expect(result.rowsSkipped, equals(1));
        expect(result.rowsFailed, equals(0));
        expect(result.skippedEntityTypes, contains('totallyRandomFutureType'));

        final unknownRemaining = await storage.isar.isarUnknownEntityStates
            .count();
        expect(unknownRemaining, equals(1));
        final unresolved = await storage.isar.isarUnknownEntityStates.get(
          insertedId,
        );
        expect(unresolved, isNotNull);
        expect(unresolved!.entityType, equals('totallyRandomFutureType'));
      },
    );

    test(
      'skips when entityType parses but storage group is not registered',
      () async {
        await storage.close();
        storage = IsarStorageService(dbName, 'UnknownMigrationNoTaskGroup');
        await storage.deleteDatabase();
        await storage.initialize(
          registerStorageGroups: (registry, isar) {
            registerIsarUnknownEntityStateStorageGroup(registry, isar);
          },
        );

        final now = DateTime.now().toUtc();
        final taskRow = _unknownTaskRow(
          entityId: 'task-without-group',
          domainId: '__test_missing_group_domain',
          changeAt: now,
        );

        late int insertedId;
        await storage.isar.writeTxn(() async {
          insertedId = await storage.isar.isarUnknownEntityStates.put(taskRow);
        });

        final result = await storage.migrateUnknownEntityStates();

        expect(result.rowsScanned, equals(1));
        expect(result.rowsMigrated, equals(0));
        expect(result.rowsDeleted, equals(0));
        expect(result.rowsSkipped, equals(1));
        expect(result.rowsFailed, equals(0));
        expect(result.skippedEntityTypes, contains('task'));

        final unknownRemaining = await storage.isar.isarUnknownEntityStates
            .count();
        expect(unknownRemaining, equals(1));
        final stillUnknown = await storage.isar.isarUnknownEntityStates.get(
          insertedId,
        );
        expect(stillUnknown, isNotNull);
      },
    );
  });
}

IsarUnknownEntityState _unknownTaskRow({
  required String entityId,
  required String domainId,
  required DateTime changeAt,
  String entityType = 'task',
}) {
  final payload = <String, dynamic>{
    'entityId': entityId,
    'entityType': entityType,
    'domainType': 'project',
    'unknownJson': '{}',
    'change_domainId': domainId,
    'change_domainId_orig_': domainId,
    'change_changeAt': changeAt.toIso8601String(),
    'change_changeAt_orig_': changeAt.toIso8601String(),
    'change_storedAt': changeAt.toIso8601String(),
    'change_storedAt_orig_': changeAt.toIso8601String(),
    'change_cid': 'cid-$entityId',
    'change_cid_orig_': 'cid-$entityId',
    'change_changeBy': 'tester',
    'change_changeBy_orig_': 'tester',
    'data_parentId': 'root',
    'data_parentId_dataSchemaRev_': 0,
    'data_parentId_changeAt_': changeAt.toIso8601String(),
    'data_parentId_cid_': 'cid-$entityId',
    'data_parentId_changeBy_': 'tester',
    'data_parentProp': 'pList',
    'data_parentProp_dataSchemaRev_': 0,
    'data_parentProp_changeAt_': changeAt.toIso8601String(),
    'data_parentProp_cid_': 'cid-$entityId',
    'data_parentProp_changeBy_': 'tester',
    'data_nameLocal': 'Task $entityId',
    'data_nameLocal_changeAt_': changeAt.toIso8601String(),
    'data_nameLocal_cid_': 'cid-$entityId',
    'data_nameLocal_changeBy_': 'tester',
  };

  return IsarUnknownEntityState.fromJson(payload);
}
