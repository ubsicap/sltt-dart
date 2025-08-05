import 'package:sltt_core/src/models/base_change_log_entry.dart';
import 'package:sltt_core/src/models/entity_type.dart';
import 'package:sltt_core/src/services/change_analysis_service.dart';
import 'package:test/test.dart';

/// Mock ChangeLogEntry for testing
class MockChangeLogEntry extends ChangeLogEntry {
  MockChangeLogEntry({
    required int seq,
    required super.cid,
    required super.changeAt,
    required super.operation,
    required super.projectId,
    required super.entityType,
    required super.entityId,
    required Map<String, dynamic> data,
    required super.changeBy,
  }) : super(dataJson: '') {
    super.seq = seq;
    setData(data);
  }
}

void main() {
  group('analyzeChanges', () {
    // Mock function for getting current entity state
    Future<ChangeLogEntry?> mockGetCurrentEntityState(
      String projectId,
      String entityType,
      String entityId,
    ) async {
      // Return mock state for entity 'existing-entity'
      if (entityId == 'existing-entity') {
        return MockChangeLogEntry(
          seq: 1,
          cid: 'existing-cid',
          changeAt: DateTime.now().subtract(const Duration(hours: 1)),
          operation: 'create',
          projectId: projectId,
          entityType: EntityType.values.firstWhere(
            (e) => e.name == entityType,
            orElse: () => EntityType.document,
          ),
          entityId: entityId,
          changeBy: 'test-user',
          data: {'name': 'existing name', 'value': 42, 'active': true},
        );
      }
      return null; // Entity doesn't exist
    }

    test(
      'create operation on non-existent entity proceeds as create',
      () async {
        final changesData = [
          {
            'projectId': 'test-project',
            'entityType': 'document',
            'entityId': 'new-entity',
            'operation': 'create',
            'data': {'name': 'test', 'value': 123},
          },
        ];

        final result = await analyzeChanges(
          changesData,
          mockGetCurrentEntityState,
        );

        expect(result.changesToCreate, hasLength(1));
        expect(result.noOpChangeCids, isEmpty);
        expect(
          result.changesToCreate.first.resolvedOperation,
          equals('create'),
        );
        expect(
          result.changesToCreate.first.requestedOperation,
          equals('create'),
        );
        expect(result.changesToCreate.first.operationChanged, isFalse);
        expect(result.changesToCreate.first.operationChangeReason, isNull);
      },
    );

    test('create operation on existing entity converts to update', () async {
      final changesData = [
        {
          'projectId': 'test-project',
          'entityType': 'document',
          'entityId': 'existing-entity',
          'operation': 'create',
          'data': {'name': 'updated name', 'value': 999},
        },
      ];

      final result = await analyzeChanges(
        changesData,
        mockGetCurrentEntityState,
      );

      expect(result.changesToCreate, hasLength(1));
      expect(result.changesToCreate.first.resolvedOperation, equals('update'));
      expect(result.changesToCreate.first.requestedOperation, equals('create'));
      expect(result.changesToCreate.first.operationChanged, isTrue);
      expect(
        result.changesToCreate.first.operationChangeReason,
        equals('Entity already exists, converting create to update'),
      );
    });

    test(
      'update operation on non-existent entity converts to create',
      () async {
        final changesData = [
          {
            'projectId': 'test-project',
            'entityType': 'document',
            'entityId': 'new-entity',
            'operation': 'update',
            'data': {'name': 'test', 'value': 123},
          },
        ];

        final result = await analyzeChanges(
          changesData,
          mockGetCurrentEntityState,
        );

        expect(result.changesToCreate, hasLength(1));
        expect(
          result.changesToCreate.first.resolvedOperation,
          equals('create'),
        );
        expect(
          result.changesToCreate.first.requestedOperation,
          equals('update'),
        );
        expect(result.changesToCreate.first.operationChanged, isTrue);
        expect(
          result.changesToCreate.first.operationChangeReason,
          equals('Entity does not exist, converting update to create'),
        );
      },
    );

    test('update operation with actual field changes creates change', () async {
      final changesData = [
        {
          'projectId': 'test-project',
          'entityType': 'document',
          'entityId': 'existing-entity',
          'operation': 'update',
          'data': {'name': 'updated name', 'value': 999},
        },
      ];

      final result = await analyzeChanges(
        changesData,
        mockGetCurrentEntityState,
      );

      expect(result.changesToCreate, hasLength(1));
      expect(result.noOpChangeCids, isEmpty);
      expect(result.changesToCreate.first.resolvedOperation, equals('update'));
      expect(result.changesToCreate.first.requestedOperation, equals('update'));
      expect(result.changesToCreate.first.operationChanged, isFalse);

      // Should only include changed fields in the data
      final changeData = result.changesToCreate.first.changeData;
      expect(
        changeData['data'],
        equals({'name': 'updated name', 'value': 999}),
      );
    });

    test('update operation with no field changes creates no-op', () async {
      final changesData = [
        {
          'projectId': 'test-project',
          'entityType': 'document',
          'entityId': 'existing-entity',
          'operation': 'update',
          'data': {'name': 'existing name', 'value': 42, 'active': true},
        },
      ];

      final result = await analyzeChanges(
        changesData,
        mockGetCurrentEntityState,
      );

      expect(result.changesToCreate, isEmpty);
      expect(result.noOpChangeCids, hasLength(1));

      final cid = result.noOpChangeCids.first;
      expect(result.changeDetails[cid]?.hasUpdates, isFalse);
      expect(result.changeDetails[cid]?.allNoOps, isTrue);
    });

    test('delete operation always proceeds as requested', () async {
      final changesData = [
        {
          'projectId': 'test-project',
          'entityType': 'document',
          'entityId': 'existing-entity',
          'operation': 'delete',
          'data': {},
        },
      ];

      final result = await analyzeChanges(
        changesData,
        mockGetCurrentEntityState,
      );

      expect(result.changesToCreate, hasLength(1));
      expect(result.noOpChangeCids, isEmpty);
      expect(result.changesToCreate.first.resolvedOperation, equals('delete'));
      expect(result.changesToCreate.first.requestedOperation, equals('delete'));
      expect(result.changesToCreate.first.operationChanged, isFalse);
    });

    test('generates CID when not provided', () async {
      final changesData = [
        {
          'projectId': 'test-project',
          'entityType': 'document',
          'entityId': 'new-entity',
          'operation': 'create',
          'data': {'name': 'test'},
          // No CID provided
        },
      ];

      final result = await analyzeChanges(
        changesData,
        mockGetCurrentEntityState,
      );

      expect(result.changesToCreate, hasLength(1));
      expect(result.changesToCreate.first.cid, isNotEmpty);
      expect(result.changesToCreate.first.changeData['cid'], isNotEmpty);
    });

    test('handles multiple changes in batch', () async {
      final changesData = [
        {
          'projectId': 'test-project',
          'entityType': 'document',
          'entityId': 'new-entity-1',
          'operation': 'create',
          'data': {'name': 'test1'},
        },
        {
          'projectId': 'test-project',
          'entityType': 'document',
          'entityId': 'existing-entity',
          'operation': 'update',
          'data': {'name': 'existing name', 'value': 42}, // No changes
        },
        {
          'projectId': 'test-project',
          'entityType': 'document',
          'entityId': 'existing-entity',
          'operation': 'update',
          'data': {'name': 'updated name'}, // Has changes
        },
      ];

      final result = await analyzeChanges(
        changesData,
        mockGetCurrentEntityState,
      );

      expect(
        result.changesToCreate,
        hasLength(2),
      ); // create + update with changes
      expect(result.noOpChangeCids, hasLength(1)); // update with no changes
      expect(result.changeDetails, hasLength(3)); // All changes tracked
    });
  });
}
