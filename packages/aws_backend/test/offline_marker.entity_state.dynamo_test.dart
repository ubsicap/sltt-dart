import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:aws_backend/src/models/marker.data.dart';
import 'package:aws_backend/src/models/marker.entity_state.dynamo.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  group(
    'offline - Entity State - Serialization/Deserialization - DynamoMarkerDataEntityState',
    () {
      test('should serialize/deserialize without unknown fields', () {
        final DateTime localTime = DateTime.parse('2023-01-01T00:00:00');
        final localChangeAt = localTime.add(const Duration(minutes: 1));

        final data = MarkerData(
          colorValue: 0xFF00FF00,
          shape: 'pin',
          description: 'test marker',
          parentId: 'root',
          parentProp: 'markers',
          rank: 'aaaa',
        );

        final changeLogEntry =
            ChangeLogEntryFactoryService.forChangeSave<
              DynamoChangeLogEntry,
              int,
              MarkerData
            >(
              factory: DynamoChangeLogEntry.new,
              entityId: 'marker-1',
              entityType: kEntityTypeMarker,
              domainId: 'project1',
              domainType: 'project',
              changeAt: localChangeAt,
              cid: 'cid-1',
              changeBy: 'user1',
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

        if (testEntityState.unknownJson != '{}') {
          fail('FIELD DRIFT DETECTED: ${testEntityState.unknownJson}');
        }

        expect(testEntityState.unknownJson, equals('{}'));

        final serializedJson = testEntityState.toJson();
        final originalStateUpdates = Map<String, dynamic>.from(
          updates['stateUpdates'],
        );

        serializedJson.remove('unknownJson');

        final strippedStateUpdates = Map<String, dynamic>.from(
          originalStateUpdates,
        )..removeWhere((k, v) => v == null);

        expect(serializedJson, equals(strippedStateUpdates));

        expect(testEntityState.data_shape, equals('pin'));
        expect(testEntityState.data_description, equals('test marker'));
        expect(testEntityState.data_colorValue, equals(0xFF00FF00));

        expectAllDateTimeFieldsAreUtc(serializedJson);
      });
    },
  );
}

DateTime? maybeValidDateTime(String input) {
  try {
    return DateTime.parse(input);
  } catch (e) {
    return null;
  }
}

void expectAllDateTimeFieldsAreUtc(Map<String, dynamic> json) {
  final dateTimeFields = json.entries
      .where((e) => e.value is String)
      .map((e) => MapEntry(e.key, maybeValidDateTime(e.value as String)))
      .where((e) => e.value != null)
      .toList();

  for (final entry in dateTimeFields) {
    expect(entry.value!.isUtc, isTrue, reason: '${entry.key} is not in UTC');
  }
}
