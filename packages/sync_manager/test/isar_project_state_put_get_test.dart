import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/isar_project_state.dart';
import 'package:test/test.dart';

const knownDateTimeFields = {
  'change_changeAt',
  'change_changeAt_orig_',
  'change_storedAt',
  'change_storedAt_orig_',
  'change_cloudAt',
  'data_nameLocal_changeAt_',
  'data_nameLocal_cloudAt_',
  'data_rank_changeAt_',
  'data_rank_cloudAt_',
  'data_deleted_changeAt_',
  'data_deleted_cloudAt_',
  'data_parentId_changeAt_',
  'data_parentId_cloudAt_',
  'data_parentProp_changeAt_',
  'data_parentProp_cloudAt_',
};

const knownProjectStateFields = {
  'id',
  'entityId',
  'entityType',
  'domainType',
  'unknownJson',
  'schemaVersion',
  'change_domainId',
  'change_domainId_orig_',
  'change_changeAt',
  'change_changeAt_orig_',
  'change_storedAt',
  'change_storedAt_orig_',
  'change_cid',
  'change_cid_orig_',
  'change_dataSchemaRev',
  'change_cloudAt',
  'change_changeBy',
  'change_changeBy_orig_',
  'data_nameLocal',
  'data_nameLocal_dataSchemaRev_',
  'data_nameLocal_changeAt_',
  'data_nameLocal_cid_',
  'data_nameLocal_changeBy_',
  'data_nameLocal_cloudAt_',
  'data_rank',
  'data_rank_dataSchemaRev_',
  'data_rank_changeAt_',
  'data_rank_cid_',
  'data_rank_changeBy_',
  'data_rank_cloudAt_',
  'data_deleted',
  'data_deleted_dataSchemaRev_',
  'data_deleted_changeAt_',
  'data_deleted_cid_',
  'data_deleted_changeBy_',
  'data_deleted_cloudAt_',
  'data_parentId',
  'data_parentId_dataSchemaRev_',
  'data_parentId_changeAt_',
  'data_parentId_cid_',
  'data_parentId_changeBy_',
  'data_parentId_cloudAt_',
  'data_parentProp',
  'data_parentProp_dataSchemaRev_',
  'data_parentProp_changeAt_',
  'data_parentProp_cid_',
  'data_parentProp_changeBy_',
  'data_parentProp_cloudAt_',
};

void main() {
  late Isar isar;
  const testDbName = 'isar_project_state_put_get_test';
  const testDbPath = './isar_db';

  setUp(() async {
    // Delete database if it exists
    final dir = Directory(testDbPath);
    if (dir.existsSync()) {
      final dbFile = File('$testDbPath/$testDbName.isar');
      if (dbFile.existsSync()) {
        dbFile.deleteSync();
      }
      final lockFile = File('$testDbPath/$testDbName.isar.lock');
      if (lockFile.existsSync()) {
        lockFile.deleteSync();
      }
    }

    // Create Isar instance with IsarProjectState schema
    isar = await Isar.open(
      [IsarProjectStateSchema],
      directory: testDbPath,
      name: testDbName,
    );
  });

  tearDown(() async {
    await isar.close();

    // Clean up database files
    final dbFile = File('$testDbPath/$testDbName.isar');
    if (dbFile.existsSync()) {
      dbFile.deleteSync();
    }
    final lockFile = File('$testDbPath/$testDbName.isar.lock');
    if (lockFile.existsSync()) {
      lockFile.deleteSync();
    }
  });

  group('IsarProjectState DateTime UTC Conversion', () {
    test('stores and retrieves with all DateTime fields converted to UTC', () async {
      // Create local (non-UTC) DateTimes for testing
      final localChangeAt = DateTime.now(); // Local time
      final localCloudAt = DateTime.now().subtract(const Duration(hours: 1));
      final localStoredAt = DateTime.now().subtract(
        const Duration(minutes: 30),
      );
      final localNameLocalChangeAt = DateTime.now().subtract(
        const Duration(minutes: 15),
      );
      final localParentIdChangeAt = DateTime.now().subtract(
        const Duration(minutes: 10),
      );
      final localParentPropChangeAt = DateTime.now().subtract(
        const Duration(minutes: 5),
      );

      expect(
        localChangeAt.isUtc,
        isFalse,
        reason: 'Test DateTime should be local',
      );
      expect(
        localCloudAt.isUtc,
        isFalse,
        reason: 'Test DateTime should be local',
      );
      expect(
        localStoredAt.isUtc,
        isFalse,
        reason: 'Test DateTime should be local',
      );

      final cid = generateCid(entityType: EntityType.project);

      // Create IsarProjectState with all optional fields filled
      final entry = IsarProjectState(
        entityId: 'test-project-1',
        entityType: 'project',
        domainType: 'project',
        unknownJson: '{}',
        schemaVersion: 1,
        change_domainId: 'test-domain-1',
        change_domainId_orig_: 'test-domain-1',
        change_changeAt: localChangeAt,
        change_changeAt_orig_: localChangeAt,
        change_storedAt: localStoredAt,
        change_storedAt_orig_: localStoredAt,
        change_cid: cid,
        change_cid_orig_: cid,
        change_dataSchemaRev: 1,
        change_cloudAt: localCloudAt,
        change_changeBy: 'test-user',
        change_changeBy_orig_: 'test-user',
        // Project-specific fields
        data_nameLocal: 'Test Project',
        data_nameLocal_dataSchemaRev_: 1,
        data_nameLocal_changeAt_: localNameLocalChangeAt,
        data_nameLocal_cid_: cid,
        data_nameLocal_changeBy_: 'test-user',
        data_nameLocal_cloudAt_: localCloudAt,
        // Common data fields
        data_rank: '100',
        data_rank_dataSchemaRev_: 1,
        data_rank_changeAt_: localChangeAt,
        data_rank_cid_: cid,
        data_rank_changeBy_: 'test-user',
        data_rank_cloudAt_: localCloudAt,
        data_deleted: false,
        data_deleted_dataSchemaRev_: 1,
        data_deleted_changeAt_: localChangeAt,
        data_deleted_cid_: cid,
        data_deleted_changeBy_: 'test-user',
        data_deleted_cloudAt_: localCloudAt,
        data_parentId: 'root',
        data_parentId_dataSchemaRev_: 1,
        data_parentId_changeAt_: localParentIdChangeAt,
        data_parentId_cid_: cid,
        data_parentId_changeBy_: 'test-user',
        data_parentId_cloudAt_: localCloudAt,
        data_parentProp: 'pList',
        data_parentProp_dataSchemaRev_: 1,
        data_parentProp_changeAt_: localParentPropChangeAt,
        data_parentProp_cid_: cid,
        data_parentProp_changeBy_: 'test-user',
        data_parentProp_cloudAt_: localCloudAt,
      );

      // Test that instance DateTime fields are UTC before storing
      expect(
        entry.change_changeAt,
        equals(localChangeAt.toUtc()),
        reason: 'change_changeAt should be UTC',
      );
      expect(
        entry.change_cloudAt,
        equals(localCloudAt.toUtc()),
        reason: 'change_cloudAt should be UTC',
      );
      expect(
        entry.change_storedAt,
        equals(localStoredAt.toUtc()),
        reason: 'change_storedAt should be UTC',
      );
      expect(
        entry.data_nameLocal_changeAt_,
        equals(localNameLocalChangeAt.toUtc()),
        reason: 'data_nameLocal_changeAt_ should be UTC',
      );
      expect(
        entry.data_parentId_changeAt_,
        equals(localParentIdChangeAt.toUtc()),
        reason: 'data_parentId_changeAt_ should be UTC',
      );
      expect(
        entry.data_parentProp_changeAt_,
        equals(localParentPropChangeAt.toUtc()),
        reason: 'data_parentProp_changeAt_ should be UTC',
      );

      // Store to database
      await isar.writeTxn(() async {
        await isar.isarProjectStates.put(entry);
      });

      // Retrieve from database
      final retrieved = await isar.isarProjectStates
          .filter()
          .entityIdEqualTo(entry.entityId)
          .findFirst();

      expect(
        retrieved,
        isNotNull,
        reason: 'Entry should be retrieved from database',
      );

      // Test all retrieved DateTime fields are UTC
      expect(
        retrieved!.change_changeAt,
        equals(localChangeAt.toUtc()),
        reason: 'Retrieved change_changeAt should be UTC',
      );
      expect(
        retrieved.change_cloudAt,
        equals(localCloudAt.toUtc()),
        reason: 'Retrieved change_cloudAt should be UTC',
      );
      expect(
        retrieved.change_storedAt,
        equals(localStoredAt.toUtc()),
        reason: 'Retrieved change_storedAt should be UTC',
      );
      expect(
        retrieved.data_nameLocal_changeAt_,
        equals(localNameLocalChangeAt.toUtc()),
        reason: 'Retrieved data_nameLocal_changeAt_ should be UTC',
      );
      expect(
        retrieved.data_parentId_changeAt_,
        equals(localParentIdChangeAt.toUtc()),
        reason: 'Retrieved data_parentId_changeAt_ should be UTC',
      );
      expect(
        retrieved.data_parentProp_changeAt_,
        equals(localParentPropChangeAt.toUtc()),
        reason: 'Retrieved data_parentProp_changeAt_ should be UTC',
      );

      // Test that re-serialized toJson() has all UTC DateTime strings
      final jsonAfterRetrieve = retrieved.toJson();

      // Expected value checks
      expect(retrieved.entityId, equals(entry.entityId));
      expect(retrieved.entityType, equals(entry.entityType));
      expect(retrieved.domainType, equals(entry.domainType));
      expect(retrieved.change_domainId, equals(entry.change_domainId));
      expect(retrieved.change_cid, equals(entry.change_cid));
      expect(retrieved.change_changeBy, equals(entry.change_changeBy));
      expect(retrieved.data_nameLocal, equals(entry.data_nameLocal));
      expect(retrieved.data_rank, equals(entry.data_rank));
      expect(retrieved.data_deleted, equals(entry.data_deleted));
      expect(retrieved.data_parentId, equals(entry.data_parentId));
      expect(retrieved.data_parentProp, equals(entry.data_parentProp));
      expect(retrieved.unknownJson, equals(entry.unknownJson));
      expect(retrieved.schemaVersion, equals(entry.schemaVersion));

      final processedDateTimeFields = <String>{};
      final processedAllFields = <String>{};

      // Use toJsonBase() to check for any missing fields
      final jsonBase = entry.toJsonBase();
      for (final entry in jsonBase.entries) {
        expect(
          entry.value,
          isNotNull,
          reason:
              'Field ${entry.key} should not be null. If it is a DateTime, please test that has been converted to utc below',
        );
        expect(
          entry.key,
          isIn(knownProjectStateFields),
          reason:
              'Field ${entry.key} is not a known ProjectState field. Update the expected value checks and knownProjectStateFields accordingly.',
        );
        expect(
          entry.value,
          equals(jsonAfterRetrieve[entry.key]),
          reason:
              'Field ${entry.key} does not match after retrieval from database.',
        );
        processedAllFields.add(entry.key);
        if (entry.value is! String) continue;
        // Parse to see if it's a datetime field, if so make sure it's a known datetime field
        final maybeDateTime = DateTime.tryParse(entry.value);
        if (maybeDateTime != null) {
          processedDateTimeFields.add(entry.key);
          expect(entry.key, isIn(knownDateTimeFields));
          expect(
            maybeDateTime.isUtc,
            isTrue,
            reason:
                'Field ${entry.key} should be UTC DateTime string, got ${entry.value}',
          );
        }
      }
      // make sure all known datetime fields were processed
      expect(
        processedDateTimeFields,
        equals(knownDateTimeFields),
        reason: 'Not all known DateTime fields were processed.',
      );
      // make sure all known fields were processed
      expect(
        processedAllFields,
        equals(knownProjectStateFields),
        reason: 'Not all known ProjectState fields were processed.',
      );
    });
  });
}
