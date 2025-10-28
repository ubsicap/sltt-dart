import 'package:isar_community/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  late Isar isar;
  const testDbName = 'isar_document_state_put_get_test';
  const testDbPath = './isar_db';

  setUp(() async {
    // Delete database if it exists
    await IsarStorageService.deleteDatabaseFiles(testDbName);

    // Create Isar instance with IsarDocumentState schema
    isar = await Isar.open(
      [IsarDocumentStateSchema],
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
    'data_title_changeAt_',
    'data_title_cloudAt_',
    'data_rank_changeAt_',
    'data_rank_cloudAt_',
    'data_deleted_changeAt_',
    'data_deleted_cloudAt_',
    'data_parentId_changeAt_',
    'data_parentId_cloudAt_',
    'data_parentProp_changeAt_',
    'data_parentProp_cloudAt_',
  };

  const knownDocumentStateFields = {
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
    'data_title',
    'data_title_changeAt_',
    'data_title_cloudAt_',
    'data_title_cid_',
    'data_title_changeBy_',
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
    IsarDocumentState state, {
    required DateTime expectedDataTitleChangeAt,
    required DateTime expectedDataTitleCloudAt,
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

    // Test Document specific DateTime fields are UTC
    expect(
      state.data_title_changeAt_,
      equals(expectedDataTitleChangeAt.toUtc()),
      reason: '${prefix}data_title_changeAt_ should be UTC',
    );
    expect(
      state.data_title_cloudAt_,
      equals(expectedDataTitleCloudAt.toUtc()),
      reason: '${prefix}data_title_cloudAt_ should be UTC',
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

  group('put to and get from storage - IsarDocumentState', () {
    test('stores and retrieves with all expected fields - IsarDocumentState', () async {
      // Create individual local (non-UTC) DateTimes for testing - each field gets unique value
      final localChangeAt = DateTime.now(); // Local time
      final localCloudAt = DateTime.now().subtract(const Duration(hours: 1));
      final localStoredAt = DateTime.now().subtract(
        const Duration(minutes: 30),
      );
      final localDataTitleChangeAt = DateTime.now().subtract(
        const Duration(minutes: 15),
      );
      final localDataTitleCloudAt = DateTime.now().subtract(
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

      final cidOrig = generateCid(
        entityType: EntityType.document,
        userId: 'test-user-1',
      );

      // Create IsarDocumentState with all optional fields filled
      final entry = IsarDocumentState(
        entityId: 'test-document-1',
        entityType: 'document',
        domainType: 'document',
        unknownJson: '{}',
        schemaVersion: 1,
        change_domainId: 'test-domain-1',
        change_domainId_orig_: 'test-domain-1',
        change_changeAt: localChangeAt,
        change_changeAt_orig_: localChangeAt,
        change_storedAt: localStoredAt,
        change_storedAt_orig_: localStoredAt,
        change_cid: generateCid(
          entityType: EntityType.document,
          userId: 'test-user-6',
        ),
        change_cid_orig_: cidOrig,
        change_dataSchemaRev: 6,
        change_cloudAt: localCloudAt,
        change_changeBy: 'test-user-6',
        change_changeBy_orig_: 'test-user-1',
        // Document-specific fields
        data_title: 'Test Document',
        data_title_changeAt_: localDataTitleChangeAt,
        data_title_cloudAt_: localDataTitleCloudAt,
        data_title_cid_: generateCid(
          entityType: EntityType.document,
          userId: 'test-user-2',
        ),
        data_title_changeBy_: 'test-user-2',
        // Common data fields
        data_rank: '100',
        data_rank_dataSchemaRev_: 3,
        data_rank_changeAt_: localDataRankChangeAt,
        data_rank_cid_: generateCid(
          entityType: EntityType.document,
          userId: 'test-user-3',
        ),
        data_rank_changeBy_: 'test-user-3',
        data_rank_cloudAt_: localDataRankCloudAt,
        data_deleted: false,
        data_deleted_dataSchemaRev_: 4,
        data_deleted_changeAt_: localDataDeletedChangeAt,
        data_deleted_cid_: generateCid(
          entityType: EntityType.document,
          userId: 'test-user-4',
        ),
        data_deleted_changeBy_: 'test-user-4',
        data_deleted_cloudAt_: localDataDeletedCloudAt,
        data_parentId: 'root',
        data_parentId_dataSchemaRev_: 5,
        data_parentId_changeAt_: localDataParentIdChangeAt,
        data_parentId_cid_: generateCid(
          entityType: EntityType.document,
          userId: 'test-user-5',
        ),
        data_parentId_changeBy_: 'test-user-5',
        data_parentId_cloudAt_: localDataParentIdCloudAt,
        data_parentProp: 'pList',
        data_parentProp_dataSchemaRev_: 6,
        data_parentProp_changeAt_: localDataParentPropChangeAt,
        data_parentProp_cid_: generateCid(
          entityType: EntityType.document,
          userId: 'test-user-6',
        ),
        data_parentProp_changeBy_: 'test-user-6',
        data_parentProp_cloudAt_: localDataParentPropCloudAt,
      );

      // Test that instance DateTime fields are UTC before storing
      expectAllDateTimeFieldsUtc(
        entry,
        expectedDataTitleChangeAt: localDataTitleChangeAt,
        expectedDataTitleCloudAt: localDataTitleCloudAt,
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
        final newId = await isar.isarDocumentStates.put(entry);
        expect(entry.id, newId, reason: 'Entry id should match stored id');
      });

      // Retrieve from database
      final retrieved = await isar.isarDocumentStates
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
        expectedDataTitleChangeAt: localDataTitleChangeAt,
        expectedDataTitleCloudAt: localDataTitleCloudAt,
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
      expect(retrieved.data_title, equals(entry.data_title));
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
      for (final kv in jsonBase.entries) {
        expect(
          kv.value,
          isNotNull,
          reason:
              'Field ${kv.key} should not be null. If it is a DateTime, please test that has been converted to utc below',
        );
        expect(
          kv.key,
          isIn(knownDocumentStateFields),
          reason:
              'Field ${kv.key} is not a known DocumentState field. Update the expected value checks and knownDocumentStateFields accordingly.',
        );
        expect(
          kv.value,
          equals(jsonAfterRetrieve[kv.key]),
          reason:
              'Field ${kv.key} does not match after retrieval from database.',
        );
        processedAllFields.add(kv.key);
        if (kv.value is! String) continue;
        // Parse to see if it's a datetime field, if so make sure it's a known datetime field
        final maybeDateTime = DateTime.tryParse(kv.value);
        if (maybeDateTime != null) {
          processedDateTimeFields.add(kv.key);
          expect(kv.key, isIn(knownDateTimeFields));
          expect(
            maybeDateTime.isUtc,
            isTrue,
            reason:
                'Field ${kv.key} should be UTC DateTime string, got ${kv.value}',
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
        equals(knownDocumentStateFields),
        reason: 'Not all known DocumentState fields were processed.',
      );
    });
  });
}
