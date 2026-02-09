import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:aws_backend/src/models/marker.data.dart';
import 'package:aws_backend/src/models/marker.entity_state.dynamo.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

// This is an online/integration-style test that requires DynamoDB access.
// It verifies that the entity state shape covers expected fields when
// interacting with the Dynamo serialization flow. Run only when AWS/localstack
// environment is configured (see setup_test_env scripts).

void main() {
  group('online - DynamoMarkerDataEntityState - field coverage', () {
    test(
      'round-trip via change-log and state-updates preserves fields',
      () async {
        final DateTime localTime = DateTime.parse('2023-01-01T00:00:00');
        final localChangeAt = localTime.add(const Duration(minutes: 1));

        final data = MarkerData(
          colorValue: 0xFF00FF00,
          shape: 'pin',
          description: 'integration marker',
          parentId: 'root',
          parentProp: 'markers',
          rank: 'zzz',
        );

        final changeLogEntry =
            ChangeLogEntryFactoryService.forChangeSave<
              DynamoChangeLogEntry,
              int,
              MarkerData
            >(
              factory: DynamoChangeLogEntry.new,
              entityId: 'marker-int-1-${DateTime.now().millisecondsSinceEpoch}',
              entityType: kEntityTypeMarker,
              domainId: 'integration-project',
              domainType: 'project',
              changeAt: localChangeAt,
              cid: 'cid-int',
              changeBy: 'integration-test',
              data: data,
              operation: 'create',
              dataSchemaRev: 0,
            );

        final updates = getDataAndStateUpdatesOrOutdatedBys(
          changeLogEntry: changeLogEntry,
          entityState: null,
          fieldChanges: data.toJson()..removeWhere((k, v) => v == null),
          noOpFields: [],
          storageMode: 'save',
          storageType: 'cloud',
          cs: computeCloudAndStoredAt(changeLogEntry, 'cloud'),
        );

        final testEntityState = DynamoMarkerDataEntityState.fromJson(
          updates['stateUpdates'],
        );

        // Ensure unknownJson is empty
        expect(testEntityState.unknownJson, equals('{}'));

        // Ensure key data fields are present and correctly typed
        expect(testEntityState.data_colorValue, isA<int>());
        expect(testEntityState.data_shape, isA<String>());
        expect(testEntityState.data_description, isA<String>());

        // Ensure UTC timestamps
        expect(testEntityState.change_changeAt.isUtc, isTrue);
        expect(testEntityState.data_colorValue_changeAt_.isUtc, isTrue);

        // Optionally: serialize and ensure keys exist
        final base = testEntityState.toJsonBase();
        expect(base.containsKey('data_colorValue'), isTrue);
        expect(base.containsKey('data_shape'), isTrue);
        expect(base.containsKey('data_description'), isTrue);
        expect(base.containsKey('data_replacementId'), isTrue);
      },
    );
  });
}
