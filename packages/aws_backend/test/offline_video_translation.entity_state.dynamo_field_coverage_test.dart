import 'package:aws_backend/src/models/video_translation.entity_state.dynamo.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  const knownDateTimeFields = {
    'change_changeAt',
    'change_changeAt_orig_',
    'change_storedAt',
    'change_storedAt_orig_',
    'change_cloudAt',
    'data_name_changeAt_',
    'data_name_cloudAt_',
    'data_storedFilename_changeAt_',
    'data_storedFilename_cloudAt_',
    'data_durationMs_changeAt_',
    'data_durationMs_cloudAt_',
    'data_visibility_changeAt_',
    'data_visibility_cloudAt_',
    'data_rank_changeAt_',
    'data_rank_cloudAt_',
    'data_deleted_changeAt_',
    'data_deleted_cloudAt_',
    'data_parentId_changeAt_',
    'data_parentId_cloudAt_',
    'data_parentProp_changeAt_',
    'data_parentProp_cloudAt_',
  };

  const knownVideoDataEntityStateFields = {
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
    'data_name',
    'data_name_dataSchemaRev_',
    'data_name_changeAt_',
    'data_name_cid_',
    'data_name_changeBy_',
    'data_name_cloudAt_',
    'data_storedFilename',
    'data_storedFilename_dataSchemaRev_',
    'data_storedFilename_changeAt_',
    'data_storedFilename_cid_',
    'data_storedFilename_changeBy_',
    'data_storedFilename_cloudAt_',
    'data_durationMs',
    'data_durationMs_dataSchemaRev_',
    'data_durationMs_changeAt_',
    'data_durationMs_cid_',
    'data_durationMs_changeBy_',
    'data_durationMs_cloudAt_',
    'data_visibility',
    'data_visibility_dataSchemaRev_',
    'data_visibility_changeAt_',
    'data_visibility_cid_',
    'data_visibility_changeBy_',
    'data_visibility_cloudAt_',
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

  void expectAllDateTimeFieldsUtc(
    DynamoVideoDataEntityState state, {
    required DateTime expectedDataNameChangeAt,
    required DateTime expectedDataNameCloudAt,
    required DateTime expectedDataStoredFilenameChangeAt,
    required DateTime expectedDataStoredFilenameCloudAt,
    required DateTime expectedDataDurationMsChangeAt,
    required DateTime expectedDataDurationMsCloudAt,
    required DateTime expectedDataVisibilityChangeAt,
    required DateTime expectedDataVisibilityCloudAt,
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

    expect(
      state.data_name_changeAt_,
      equals(expectedDataNameChangeAt.toUtc()),
      reason: '${prefix}data_name_changeAt_ should be UTC',
    );
    expect(
      state.data_name_cloudAt_,
      equals(expectedDataNameCloudAt.toUtc()),
      reason: '${prefix}data_name_cloudAt_ should be UTC',
    );
    expect(
      state.data_storedFilename_changeAt_,
      equals(expectedDataStoredFilenameChangeAt.toUtc()),
      reason: '${prefix}data_storedFilename_changeAt_ should be UTC',
    );
    expect(
      state.data_storedFilename_cloudAt_,
      equals(expectedDataStoredFilenameCloudAt.toUtc()),
      reason: '${prefix}data_storedFilename_cloudAt_ should be UTC',
    );
    expect(
      state.data_durationMs_changeAt_,
      equals(expectedDataDurationMsChangeAt.toUtc()),
      reason: '${prefix}data_durationMs_changeAt_ should be UTC',
    );
    expect(
      state.data_durationMs_cloudAt_,
      equals(expectedDataDurationMsCloudAt.toUtc()),
      reason: '${prefix}data_durationMs_cloudAt_ should be UTC',
    );
    expect(
      state.data_visibility_changeAt_,
      equals(expectedDataVisibilityChangeAt.toUtc()),
      reason: '${prefix}data_visibility_changeAt_ should be UTC',
    );
    expect(
      state.data_visibility_cloudAt_,
      equals(expectedDataVisibilityCloudAt.toUtc()),
      reason: '${prefix}data_visibility_cloudAt_ should be UTC',
    );

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

  group('offline - DynamoVideoDataEntityState field coverage', () {
    test('verifies all expected fields with UTC DateTime conversion', () {
      final localChangeAt = DateTime.now();
      final localCloudAt = DateTime.now().subtract(const Duration(hours: 1));
      final localStoredAt = DateTime.now().subtract(
        const Duration(minutes: 30),
      );
      final localDataNameChangeAt = DateTime.now().subtract(
        const Duration(minutes: 15),
      );
      final localDataNameCloudAt = DateTime.now().subtract(
        const Duration(minutes: 18),
      );
      final localDataStoredFilenameChangeAt = DateTime.now().subtract(
        const Duration(minutes: 12),
      );
      final localDataStoredFilenameCloudAt = DateTime.now().subtract(
        const Duration(minutes: 17),
      );
      final localDataDurationMsChangeAt = DateTime.now().subtract(
        const Duration(minutes: 14),
      );
      final localDataDurationMsCloudAt = DateTime.now().subtract(
        const Duration(minutes: 13),
      );
      final localDataVisibilityChangeAt = DateTime.now().subtract(
        const Duration(minutes: 13),
      );
      final localDataVisibilityCloudAt = DateTime.now().subtract(
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

      final entry = DynamoVideoDataEntityState(
        entityId: 'test-video-1',
        entityType: kEntityTypeVideo,
        domainType: 'project',
        unknownJson: '{}',
        schemaVersion: 1,
        change_domainId: '__test_video_state_coverage__',
        change_domainId_orig_: '__test_video_state_coverage__',
        change_changeAt: localChangeAt,
        change_changeAt_orig_: localChangeAt,
        change_storedAt: localStoredAt,
        change_storedAt_orig_: localStoredAt,
        change_cid: generateCid(
          entityType: EntityType.video,
          userId: 'test-user-1',
        ),
        change_cid_orig_: generateCid(
          entityType: EntityType.video,
          userId: 'test-user-2',
        ),
        change_dataSchemaRev: 1,
        change_cloudAt: localCloudAt,
        change_changeBy: 'test-user-1',
        change_changeBy_orig_: 'test-user-2',
        data_name: 'Video Name',
        data_name_dataSchemaRev_: 1,
        data_name_changeAt_: localDataNameChangeAt,
        data_name_cid_: generateCid(
          entityType: EntityType.video,
          userId: 'test-user-1',
        ),
        data_name_changeBy_: 'test-user-1',
        data_name_cloudAt_: localDataNameCloudAt,
        data_storedFilename: 'video_name.mp4',
        data_storedFilename_dataSchemaRev_: 1,
        data_storedFilename_changeAt_: localDataStoredFilenameChangeAt,
        data_storedFilename_cid_: generateCid(
          entityType: EntityType.video,
          userId: 'test-user-1',
        ),
        data_storedFilename_changeBy_: 'test-user-1',
        data_storedFilename_cloudAt_: localDataStoredFilenameCloudAt,
        data_durationMs: 45000,
        data_durationMs_dataSchemaRev_: 1,
        data_durationMs_changeAt_: localDataDurationMsChangeAt,
        data_durationMs_cid_: generateCid(
          entityType: EntityType.video,
          userId: 'test-user-1',
        ),
        data_durationMs_changeBy_: 'test-user-1',
        data_durationMs_cloudAt_: localDataDurationMsCloudAt,
        data_visibility: ['test-user-1'],
        data_visibility_dataSchemaRev_: 1,
        data_visibility_changeAt_: localDataVisibilityChangeAt,
        data_visibility_cid_: generateCid(
          entityType: EntityType.video,
          userId: 'test-user-1',
        ),
        data_visibility_changeBy_: 'test-user-1',
        data_visibility_cloudAt_: localDataVisibilityCloudAt,
        data_rank: 'aaaaz',
        data_rank_dataSchemaRev_: 1,
        data_rank_changeAt_: localDataRankChangeAt,
        data_rank_cid_: generateCid(
          entityType: EntityType.video,
          userId: 'test-user-1',
        ),
        data_rank_changeBy_: 'test-user-1',
        data_rank_cloudAt_: localDataRankCloudAt,
        data_deleted: false,
        data_deleted_dataSchemaRev_: 1,
        data_deleted_changeAt_: localDataDeletedChangeAt,
        data_deleted_cid_: generateCid(
          entityType: EntityType.video,
          userId: 'test-user-1',
        ),
        data_deleted_changeBy_: 'test-user-1',
        data_deleted_cloudAt_: localDataDeletedCloudAt,
        data_parentId: 'root',
        data_parentId_dataSchemaRev_: 1,
        data_parentId_changeAt_: localDataParentIdChangeAt,
        data_parentId_cid_: generateCid(
          entityType: EntityType.video,
          userId: 'test-user-1',
        ),
        data_parentId_changeBy_: 'test-user-1',
        data_parentId_cloudAt_: localDataParentIdCloudAt,
        data_parentProp: 'videos',
        data_parentProp_dataSchemaRev_: 1,
        data_parentProp_changeAt_: localDataParentPropChangeAt,
        data_parentProp_cid_: generateCid(
          entityType: EntityType.video,
          userId: 'test-user-1',
        ),
        data_parentProp_changeBy_: 'test-user-1',
        data_parentProp_cloudAt_: localDataParentPropCloudAt,
      );

      expectAllDateTimeFieldsUtc(
        entry,
        expectedDataNameChangeAt: localDataNameChangeAt,
        expectedDataNameCloudAt: localDataNameCloudAt,
        expectedDataStoredFilenameChangeAt: localDataStoredFilenameChangeAt,
        expectedDataStoredFilenameCloudAt: localDataStoredFilenameCloudAt,
        expectedDataDurationMsChangeAt: localDataDurationMsChangeAt,
        expectedDataDurationMsCloudAt: localDataDurationMsCloudAt,
        expectedDataVisibilityChangeAt: localDataVisibilityChangeAt,
        expectedDataVisibilityCloudAt: localDataVisibilityCloudAt,
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
      );

      final json = entry.toJson();
      final jsonKeys = json.keys.toSet();

      for (final field in knownVideoDataEntityStateFields) {
        expect(
          jsonKeys.contains(field),
          isTrue,
          reason: 'Expected field $field to be in JSON',
        );
      }

      final unknownFields = jsonKeys.difference(
        knownVideoDataEntityStateFields,
      );
      expect(
        unknownFields,
        isEmpty,
        reason: 'Unexpected fields in JSON: $unknownFields',
      );

      for (final dateTimeField in knownDateTimeFields) {
        expect(
          json[dateTimeField],
          isA<String>(),
          reason:
              'DateTime field $dateTimeField should be serialized as string',
        );
      }
    });
  });
}
