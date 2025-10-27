import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/isar_project_state.dart';
import 'package:test/test.dart';

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
  });

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

  /// Helper to verify all DateTime fields are UTC
  void expectAllDateTimeFieldsUtc(
    IsarProjectState state, {
    required DateTime expectedDataNameLocalChangeAt,
    required DateTime expectedDataNameLocalCloudAt,
    required DateTime expectedChangeAt,
    required DateTime expectedCloudAt,
    required DateTime expectedStoredAt,
    required DateTime expectedDataRankChangeAt,
    required DateTime expectedDataRankCloudAt,
    required DateTime expectedDataDeletedChangeAt,
    required DateTime expectedDataDeletedCloudAt,
    required DateTime expectedDataParentIdChangeAt,
    required DateTime expectedDataParentIdCloudAt,
    required DateTime expectedDataParentPropChangeAt,
    required DateTime expectedDataParentPropCloudAt,
    String context = '',
  }) {
    final prefix = context.isEmpty ? '' : '$context: ';

    // Test Project specific DateTime fields are UTC
    expect(
      state.data_nameLocal_changeAt_,
      equals(expectedDataNameLocalChangeAt.toUtc()),
      reason: '${prefix}data_nameLocal_changeAt_ should be UTC',
    );
    expect(
      state.data_nameLocal_cloudAt_,
      equals(expectedDataNameLocalCloudAt.toUtc()),
      reason: '${prefix}data_nameLocal_cloudAt_ should be UTC',
    );

    // Test all remaining DateTime fields are UTC
    expect(
      state.change_changeAt,
      equals(expectedChangeAt.toUtc()),
      reason: '${prefix}change_changeAt should be UTC',
    );
    expect(
      state.change_cloudAt,
      equals(expectedCloudAt.toUtc()),
      reason: '${prefix}change_cloudAt should be UTC',
    );
    expect(
      state.change_storedAt,
      equals(expectedStoredAt.toUtc()),
      reason: '${prefix}change_storedAt should be UTC',
    );
    expect(
      state.data_rank_changeAt_,
      equals(expectedDataRankChangeAt.toUtc()),
      reason: '${prefix}data_rank_changeAt_ should be UTC',
    );
    expect(
      state.data_rank_cloudAt_,
      equals(expectedDataRankCloudAt.toUtc()),
      reason: '${prefix}data_rank_cloudAt_ should be UTC',
    );
    expect(
      state.data_deleted_changeAt_,
      equals(expectedDataDeletedChangeAt.toUtc()),
      reason: '${prefix}data_deleted_changeAt_ should be UTC',
    );
    expect(
      state.data_deleted_cloudAt_,
      equals(expectedDataDeletedCloudAt.toUtc()),
      reason: '${prefix}data_deleted_cloudAt_ should be UTC',
    );
    expect(
      state.data_parentId_changeAt_,
      equals(expectedDataParentIdChangeAt.toUtc()),
      reason: '${prefix}data_parentId_changeAt_ should be UTC',
    );
    expect(
      state.data_parentId_cloudAt_,
      equals(expectedDataParentIdCloudAt.toUtc()),
      reason: '${prefix}data_parentId_cloudAt_ should be UTC',
    );
    expect(
      state.data_parentProp_changeAt_,
      equals(expectedDataParentPropChangeAt.toUtc()),
      reason: '${prefix}data_parentProp_changeAt_ should be UTC',
    );
    expect(
      state.data_parentProp_cloudAt_,
      equals(expectedDataParentPropCloudAt.toUtc()),
      reason: '${prefix}data_parentProp_cloudAt_ should be UTC',
    );
  }

  group('IsarProjectState DateTime UTC Conversion', () {
    test('stores and retrieves with all DateTime fields converted to UTC', () async {
      // Create individual local (non-UTC) DateTimes for testing - each field gets unique value
      final localChangeAt = DateTime.now(); // Local time
      final localCloudAt = DateTime.now().subtract(const Duration(hours: 1));
      final localStoredAt = DateTime.now().subtract(
        const Duration(minutes: 30),
      );
      final localDataNameLocalChangeAt = DateTime.now().subtract(
        const Duration(minutes: 15),
      );
      final localDataNameLocalCloudAt = DateTime.now().subtract(
        const Duration(minutes: 18),
      );
      final localDataRankChangeAt = DateTime.now().subtract(
        const Duration(minutes: 22),
      );
      final localDataRankCloudAt = DateTime.now().subtract(
        const Duration(minutes: 27),
      );
      final localDataDeletedChangeAt = DateTime.now().subtract(
        const Duration(minutes: 20),
      );
      final localDataDeletedCloudAt = DateTime.now().subtract(
        const Duration(minutes: 25),
      );
      final localDataParentIdChangeAt = DateTime.now().subtract(
        const Duration(minutes: 10),
      );
      final localDataParentIdCloudAt = DateTime.now().subtract(
        const Duration(minutes: 12),
      );
      final localDataParentPropChangeAt = DateTime.now().subtract(
        const Duration(minutes: 5),
      );
      final localDataParentPropCloudAt = DateTime.now().subtract(
        const Duration(minutes: 7),
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
        data_nameLocal_changeAt_: localDataNameLocalChangeAt,
        data_nameLocal_cid_: cid,
        data_nameLocal_changeBy_: 'test-user',
        data_nameLocal_cloudAt_: localDataNameLocalCloudAt,
        // Common data fields
        data_rank: '100',
        data_rank_dataSchemaRev_: 1,
        data_rank_changeAt_: localDataRankChangeAt,
        data_rank_cid_: cid,
        data_rank_changeBy_: 'test-user',
        data_rank_cloudAt_: localDataRankCloudAt,
        data_deleted: false,
        data_deleted_dataSchemaRev_: 1,
        data_deleted_changeAt_: localDataDeletedChangeAt,
        data_deleted_cid_: cid,
        data_deleted_changeBy_: 'test-user',
        data_deleted_cloudAt_: localDataDeletedCloudAt,
        data_parentId: 'root',
        data_parentId_dataSchemaRev_: 1,
        data_parentId_changeAt_: localDataParentIdChangeAt,
        data_parentId_cid_: cid,
        data_parentId_changeBy_: 'test-user',
        data_parentId_cloudAt_: localDataParentIdCloudAt,
        data_parentProp: 'pList',
        data_parentProp_dataSchemaRev_: 1,
        data_parentProp_changeAt_: localDataParentPropChangeAt,
        data_parentProp_cid_: cid,
        data_parentProp_changeBy_: 'test-user',
        data_parentProp_cloudAt_: localDataParentPropCloudAt,
      );

      // Test that instance DateTime fields are UTC before storing
      expectAllDateTimeFieldsUtc(
        entry,
        expectedDataNameLocalChangeAt: localDataNameLocalChangeAt,
        expectedDataNameLocalCloudAt: localDataNameLocalCloudAt,
        expectedChangeAt: localChangeAt,
        expectedCloudAt: localCloudAt,
        expectedStoredAt: localStoredAt,
        expectedDataRankChangeAt: localDataRankChangeAt,
        expectedDataRankCloudAt: localDataRankCloudAt,
        expectedDataDeletedChangeAt: localDataDeletedChangeAt,
        expectedDataDeletedCloudAt: localDataDeletedCloudAt,
        expectedDataParentIdChangeAt: localDataParentIdChangeAt,
        expectedDataParentIdCloudAt: localDataParentIdCloudAt,
        expectedDataParentPropChangeAt: localDataParentPropChangeAt,
        expectedDataParentPropCloudAt: localDataParentPropCloudAt,
        context: 'Before storing',
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
      expectAllDateTimeFieldsUtc(
        retrieved!,
        expectedDataNameLocalChangeAt: localDataNameLocalChangeAt,
        expectedDataNameLocalCloudAt: localDataNameLocalCloudAt,
        expectedChangeAt: localChangeAt,
        expectedCloudAt: localCloudAt,
        expectedStoredAt: localStoredAt,
        expectedDataRankChangeAt: localDataRankChangeAt,
        expectedDataRankCloudAt: localDataRankCloudAt,
        expectedDataDeletedChangeAt: localDataDeletedChangeAt,
        expectedDataDeletedCloudAt: localDataDeletedCloudAt,
        expectedDataParentIdChangeAt: localDataParentIdChangeAt,
        expectedDataParentIdCloudAt: localDataParentIdCloudAt,
        expectedDataParentPropChangeAt: localDataParentPropChangeAt,
        expectedDataParentPropCloudAt: localDataParentPropCloudAt,
        context: 'After retrieval',
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
