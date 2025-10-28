import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  const knownDateTimeFields = {
    'change_changeAt',
    'change_changeAt_orig_',
    'change_storedAt',
    'change_storedAt_orig_',
    'change_cloudAt',
    'data_nameLocal_changeAt_',
    'data_nameLocal_cloudAt_',
    'data_nameOptionalField_changeAt_',
    'data_nameOptionalField_cloudAt_',
    'data_rank_changeAt_',
    'data_rank_cloudAt_',
    'data_deleted_changeAt_',
    'data_deleted_cloudAt_',
    'data_parentId_changeAt_',
    'data_parentId_cloudAt_',
    'data_parentProp_changeAt_',
    'data_parentProp_cloudAt_',
  };

  const knownTestEntityStateFields = {
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
    'data_nameOptionalField',
    'data_nameOptionalField_dataSchemaRev_',
    'data_nameOptionalField_changeAt_',
    'data_nameOptionalField_cid_',
    'data_nameOptionalField_changeBy_',
    'data_nameOptionalField_cloudAt_',
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
    TestEntityState state, {
    required DateTime expectedDataNameLocalChangeAt,
    required DateTime expectedDataNameLocalCloudAt,
    required DateTime expectedDataNameOptionalFieldChangeAt,
    required DateTime expectedDataNameOptionalFieldCloudAt,
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

    // Test TestEntityState specific DateTime fields are UTC
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
    expect(
      state.data_nameOptionalField_changeAt_,
      equals(expectedDataNameOptionalFieldChangeAt.toUtc()),
      reason: '${prefix}data_nameOptionalField_changeAt_ should be UTC',
    );
    expect(
      state.data_nameOptionalField_cloudAt_,
      equals(expectedDataNameOptionalFieldCloudAt.toUtc()),
      reason: '${prefix}data_nameOptionalField_cloudAt_ should be UTC',
    );

    // Test all remaining DateTime fields are UTC
    expect(
      state.change_changeAt,
      equals(expectedChangeAt.toUtc()),
      reason: '${prefix}change_changeAt should be UTC',
    );
    expect(
      state.change_changeAt_orig_,
      equals(expectedChangeAt.toUtc()),
      reason: '${prefix}change_changeAt_orig_ should be UTC',
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
      state.change_storedAt_orig_,
      equals(expectedStoredAt.toUtc()),
      reason: '${prefix}change_storedAt_orig_ should be UTC',
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

  group('TestEntityState field coverage', () {
    test('verifies all expected fields with UTC DateTime conversion', () {
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
      final localDataNameOptionalFieldChangeAt = DateTime.now().subtract(
        const Duration(minutes: 13),
      );
      final localDataNameOptionalFieldCloudAt = DateTime.now().subtract(
        const Duration(minutes: 16),
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
        entityType: EntityType.project,
        userId: 'test-user-1',
      );

      // Create TestEntityState with all optional fields filled
      final entry = TestEntityState(
        entityId: 'test-entity-1',
        entityType: 'task',
        domainType: 'project',
        unknownJson: '{}',
        schemaVersion: 1,
        change_domainId: 'test-domain-1',
        change_domainId_orig_: 'test-domain-1',
        change_changeAt: localChangeAt,
        change_changeAt_orig_: localChangeAt,
        change_storedAt: localStoredAt,
        change_storedAt_orig_: localStoredAt,
        change_cid: generateCid(
          entityType: EntityType.task,
          userId: 'test-user-6',
        ),
        change_cid_orig_: cidOrig,
        change_dataSchemaRev: 6,
        change_cloudAt: localCloudAt,
        change_changeBy: 'test-user-6',
        change_changeBy_orig_: 'test-user-1',
        // TestEntityState specific fields
        data_nameLocal: 'Test Entity',
        data_nameLocal_dataSchemaRev_: 2,
        data_nameLocal_changeAt_: localDataNameLocalChangeAt,
        data_nameLocal_cid_: generateCid(
          entityType: EntityType.task,
          userId: 'test-user-2',
        ),
        data_nameLocal_changeBy_: 'test-user-2',
        data_nameLocal_cloudAt_: localDataNameLocalCloudAt,
        data_nameOptionalField: 'Optional Value',
        data_nameOptionalField_dataSchemaRev_: 7,
        data_nameOptionalField_changeAt_: localDataNameOptionalFieldChangeAt,
        data_nameOptionalField_cid_: generateCid(
          entityType: EntityType.task,
          userId: 'test-user-7',
        ),
        data_nameOptionalField_changeBy_: 'test-user-7',
        data_nameOptionalField_cloudAt_: localDataNameOptionalFieldCloudAt,
        // Common data fields
        data_rank: '100',
        data_rank_dataSchemaRev_: 3,
        data_rank_changeAt_: localDataRankChangeAt,
        data_rank_cid_: generateCid(
          entityType: EntityType.task,
          userId: 'test-user-3',
        ),
        data_rank_changeBy_: 'test-user-3',
        data_rank_cloudAt_: localDataRankCloudAt,
        data_deleted: false,
        data_deleted_dataSchemaRev_: 4,
        data_deleted_changeAt_: localDataDeletedChangeAt,
        data_deleted_cid_: generateCid(
          entityType: EntityType.task,
          userId: 'test-user-4',
        ),
        data_deleted_changeBy_: 'test-user-4',
        data_deleted_cloudAt_: localDataDeletedCloudAt,
        data_parentId: 'root',
        data_parentId_dataSchemaRev_: 5,
        data_parentId_changeAt_: localDataParentIdChangeAt,
        data_parentId_cid_: generateCid(
          entityType: EntityType.task,
          userId: 'test-user-5',
        ),
        data_parentId_changeBy_: 'test-user-5',
        data_parentId_cloudAt_: localDataParentIdCloudAt,
        data_parentProp: 'pList',
        data_parentProp_dataSchemaRev_: 6,
        data_parentProp_changeAt_: localDataParentPropChangeAt,
        data_parentProp_cid_: generateCid(
          entityType: EntityType.task,
          userId: 'test-user-6',
        ),
        data_parentProp_changeBy_: 'test-user-6',
        data_parentProp_cloudAt_: localDataParentPropCloudAt,
      );

      // Test that instance DateTime fields are UTC
      expectAllDateTimeFieldsUtc(
        entry,
        expectedDataNameLocalChangeAt: localDataNameLocalChangeAt,
        expectedDataNameLocalCloudAt: localDataNameLocalCloudAt,
        expectedDataNameOptionalFieldChangeAt:
            localDataNameOptionalFieldChangeAt,
        expectedDataNameOptionalFieldCloudAt: localDataNameOptionalFieldCloudAt,
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
        context: 'TestEntityState instance',
      );

      final processedDateTimeFields = <String>{};
      final processedAllFields = <String>{};

      // Use toJsonBase() to check for any missing fields
      final jsonBase = entry.toJsonBase();
      for (final kv in jsonBase.entries) {
        expect(
          kv.value,
          isNotNull,
          reason:
              'Field ${kv.key} should not be null. If it is a DateTime, please test that has been converted to UTC',
        );
        expect(
          kv.key,
          isIn(knownTestEntityStateFields),
          reason:
              'Field ${kv.key} is not a known TestEntityState field. Update the expected value checks and knownTestEntityStateFields accordingly.',
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
        equals(knownTestEntityStateFields),
        reason: 'Not all known TestEntityState fields were processed.',
      );
    });
  });
}
