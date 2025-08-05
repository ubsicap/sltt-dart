import 'package:sltt_core/sltt_core.dart';
import 'package:sltt_core/src/services/change_analysis_service.dart';
import 'package:test/test.dart';

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
        return ChangeLogEntry(
          cid: 'existing-cid',
          changeAt: DateTime.now().subtract(const Duration(hours: 1)),
          operation: 'create',
          projectId: projectId,
          entityType: EntityType.fromString(entityType),
          entityId: entityId,
          dataJson: '{"name": "existing name", "value": 42, "active": true}',
          changeBy: '',
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

    test(
      'update operation with partial field changes optimizes data',
      () async {
        final changesData = [
          {
            'projectId': 'test-project',
            'entityType': 'document',
            'entityId': 'existing-entity',
            'operation': 'update',
            'data': {
              'name': 'existing name', // Same value - no change
              'value': 999, // Different value - changed
              'active': true, // Same value - no change
              'newField': 'added', // New field - changed
            },
          },
        ];

        final result = await analyzeChanges(
          changesData,
          mockGetCurrentEntityState,
        );

        expect(result.changesToCreate, hasLength(1));
        expect(result.noOpChangeCids, isEmpty);

        // Should only include changed fields in the optimized data
        final changeData = result.changesToCreate.first.changeData;
        expect(changeData['data'], equals({'value': 999, 'newField': 'added'}));

        final cid = result.changesToCreate.first.cid;
        final details = result.changeDetails[cid]!;
        expect(details.updatedFields, containsAll(['value', 'newField']));
        expect(details.noOpFields, containsAll(['name', 'active']));
        expect(details.hasUpdates, isTrue);
        expect(details.hasNoOps, isTrue);
      },
    );

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

    test('handles error during entity state lookup gracefully', () async {
      Future<ChangeLogEntry?> errorGetCurrentEntityState(
        String projectId,
        String entityType,
        String entityId,
      ) async {
        throw Exception('Database connection failed');
      }

      final changesData = [
        {
          'projectId': 'test-project',
          'entityType': 'document',
          'entityId': 'any-entity',
          'operation': 'update',
          'data': {'name': 'test'},
        },
      ];

      final result = await analyzeChanges(
        changesData,
        errorGetCurrentEntityState,
      );

      expect(result.changesToCreate, hasLength(1));
      expect(result.changesToCreate.first.resolvedOperation, equals('update'));
      expect(result.changesToCreate.first.requestedOperation, equals('update'));
      expect(
        result.changesToCreate.first.operationChangeReason,
        contains('Analysis failed: Exception: Database connection failed'),
      );
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

    test('preserves provided CID', () async {
      final providedCid = 'custom-cid-123';
      final changesData = [
        {
          'projectId': 'test-project',
          'entityType': 'document',
          'entityId': 'new-entity',
          'operation': 'create',
          'data': {'name': 'test'},
          'cid': providedCid,
        },
      ];

      final result = await analyzeChanges(
        changesData,
        mockGetCurrentEntityState,
      );

      expect(result.changesToCreate, hasLength(1));
      expect(result.changesToCreate.first.cid, equals(providedCid));
      expect(
        result.changesToCreate.first.changeData['cid'],
        equals(providedCid),
      );
    });

    test('defaults operation to create when not specified', () async {
      final changesData = [
        {
          'projectId': 'test-project',
          'entityType': 'document',
          'entityId': 'new-entity',
          'data': {'name': 'test'},
          // No operation specified
        },
      ];

      final result = await analyzeChanges(
        changesData,
        mockGetCurrentEntityState,
      );

      expect(result.changesToCreate, hasLength(1));
      expect(result.changesToCreate.first.resolvedOperation, equals('create'));
      expect(result.changesToCreate.first.requestedOperation, equals('create'));
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

  group('hasValueChanged', () {
    test('null value comparisons', () {
      expect(hasValueChanged(null, null), isFalse);
      expect(hasValueChanged(null, 'value'), isTrue);
      expect(hasValueChanged('value', null), isTrue);
    });

    test('basic type comparisons', () {
      expect(hasValueChanged('same', 'same'), isFalse);
      expect(hasValueChanged('old', 'new'), isTrue);
      expect(hasValueChanged(42, 42), isFalse);
      expect(hasValueChanged(42, 43), isTrue);
      expect(hasValueChanged(true, true), isFalse);
      expect(hasValueChanged(true, false), isTrue);
    });

    test('map comparisons', () {
      expect(hasValueChanged({}, {}), isFalse);
      expect(hasValueChanged({'a': 1}, {'a': 1}), isFalse);
      expect(hasValueChanged({'a': 1}, {'a': 2}), isTrue);
      expect(hasValueChanged({'a': 1}, {'b': 1}), isTrue);
      expect(hasValueChanged({'a': 1, 'b': 2}, {'a': 1}), isTrue);
      expect(hasValueChanged({'a': 1}, {'a': 1, 'b': 2}), isTrue);
    });

    test('list comparisons', () {
      expect(hasValueChanged([], []), isFalse);
      expect(hasValueChanged([1, 2], [1, 2]), isFalse);
      expect(hasValueChanged([1, 2], [1, 3]), isTrue);
      expect(hasValueChanged([1, 2], [1]), isTrue);
      expect(hasValueChanged([1], [1, 2]), isTrue);
    });

    test('nested structure comparisons', () {
      expect(
        hasValueChanged(
          {
            'list': [1, 2],
            'map': {'nested': 'value'},
          },
          {
            'list': [1, 2],
            'map': {'nested': 'value'},
          },
        ),
        isFalse,
      );

      expect(
        hasValueChanged(
          {
            'list': [1, 2],
            'map': {'nested': 'value'},
          },
          {
            'list': [1, 3],
            'map': {'nested': 'value'},
          },
        ),
        isTrue,
      );
    });

    test('fallback string comparison', () {
      // For custom objects, should compare toString()
      final obj1 = DateTime(2023, 1, 1);
      final obj2 = DateTime(2023, 1, 1);
      final obj3 = DateTime(2023, 1, 2);

      expect(hasValueChanged(obj1, obj2), isFalse); // Same toString
      expect(hasValueChanged(obj1, obj3), isTrue); // Different toString
    });
  });
}

/// Mock TestChangeLogEntry for testing (no longer used, use ChangeLogEntry from sltt_core)
class TestChangeLogEntry {
  final int seq;
  final String cid;
  final DateTime changeAt;
  final String operation;
  final String projectId;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> data;

  TestChangeLogEntry({
    required this.seq,
    required this.cid,
    required this.changeAt,
    required this.operation,
    required this.projectId,
    required this.entityType,
    required this.entityId,
    required this.data,
  });
}
