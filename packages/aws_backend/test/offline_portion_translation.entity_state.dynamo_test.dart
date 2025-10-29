import 'dart:convert';

import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:aws_backend/src/models/portion_translation.data.dart';
import 'package:aws_backend/src/models/portion_translation.entity_state.dynamo.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  group(
    'offline - Entity State - Serialization/Deserialization - DynamoPortionDataEntityState',
    () {
      test(
        'should detect field-drift and produce stateUpdates compatible with deserialization',
        () {
          final DateTime localTime = DateTime.parse('2023-01-01T00:00:00');
          final localChangeAt = localTime.add(const Duration(minutes: 1));
          final data = PortionTranslationData(
            name: 'Portion Name',
            visibility: '{}',
            parentId: 'root',
            parentProp: 'portions',
            rank: 'aaaaz',
          );

          // Create a change log entry for a new entity with all required fields
          final changeLogEntry =
              ChangeLogEntryFactoryService.forChangeSave<
                DynamoChangeLogEntry,
                int,
                PortionTranslationData
              >(
                factory: DynamoChangeLogEntry.new,
                entityId: 'entity-drift-test',
                entityType: kEntityTypePortion,
                domainId: 'project1',
                domainType: 'project',
                changeAt: localChangeAt,
                cid: 'cid-drift-test',
                changeBy: 'user1',
                data: data,
                operation: 'create',
                dataSchemaRev: 0,
              );

          final updates = getDataAndStateUpdatesOrOutdatedBys(
            changeLogEntry: changeLogEntry,
            entityState: null, // No existing entity state
            fieldChanges: data.toJson(),
            noOpFields: [],
            storageMode: 'save',
            storageType: 'cloud',
            cs: computeCloudAndStoredAt(changeLogEntry, 'cloud'),
          );

          // Debug: Print stateUpdates to understand what fields are being generated
          SlttLogger.logger.info(
            'DEBUG: stateUpdates keys: ${updates['stateUpdates'].keys.toList()..sort()}',
          );

          // Step 2: Deserialize stateUpdates back to DynamoPortionDataEntityState
          final testEntityState = DynamoPortionDataEntityState.fromJson(
            updates['stateUpdates'],
          );

          // Step 2 verification: Check if there are unknown fields
          if (testEntityState.unknownJson != '{}') {
            SlttLogger.logger.info(
              'DEBUG: Unknown fields detected: ${testEntityState.unknownJson}',
            );
            SlttLogger.logger.info(
              'DEBUG: Action needed: Either add missing fields to BaseEntityState or update DynamoPortionDataEntityState',
            );
            fail(
              'FIELD DRIFT DETECTED: DynamoPortionDataEntityState has unknown fields:\n${const JsonEncoder.withIndent(' ').convert(testEntityState.getUnknown())}',
            );
          }

          expect(
            testEntityState.unknownJson,
            equals('{}'),
            reason:
                'DynamoPortionDataEntityState should deserialize without unknown fields',
          );

          // Step 3: Round-trip serialize the entity state
          final serializedJson = testEntityState.toJson();

          // Step 3 verification: The serialized version should contain the same fields and values
          // as the original stateUpdates (excluding dynamic timestamps that we handle separately)
          final originalStateUpdates = Map<String, dynamic>.from(
            updates['stateUpdates'],
          );

          // remove unknownJson for comparison
          serializedJson.remove('unknownJson');

          // remove optional fields for field-drift detection
          final strippedStateUpdates = Map<String, dynamic>.from(
            originalStateUpdates,
          )..removeWhere((key, value) => value == null);

          expect(
            serializedJson,
            equals(strippedStateUpdates),
            reason:
                'Round-trip serialization should produce consistent results',
          );

          // Verify specific field was properly handled
          expect(
            testEntityState.data_name,
            equals('Portion Name'),
            reason: 'name field should be correctly deserialized',
          );
          // test changeAt is utc
          expect(
            testEntityState.change_changeAt,
            equals(localChangeAt.toUtc()),
            reason: 'changeAt should be in UTC',
          );
          expect(
            testEntityState.data_name_changeAt_,
            equals(localChangeAt.toUtc()),
            reason: 'data_name_changeAt_ should be in UTC',
          );
          expect(
            testEntityState.data_rank_changeAt_,
            equals(localChangeAt.toUtc()),
            reason: 'data_rank_changeAt_ should match the original UTC time',
          );
          expect(
            testEntityState.data_visibility_changeAt_,
            equals(localChangeAt.toUtc()),
            reason:
                'data_visibility_changeAt_ should match the original UTC time',
          );
          expect(
            serializedJson['data_name'],
            equals('Portion Name'),
            reason: 'name field should be correctly serialized',
          );

          expectAllDateTimeFieldsAreUtc(serializedJson);

          // now see if DynamoPortionDataEntityState has any additional (optional) fields
          final jsonWithNullValues = testEntityState.toJsonBase()
            ..removeWhere((key, value) => value != null);
          // compare with null values from stateUpdates
          final stateUpdatesWithNullValues = <String, dynamic>{
            ...updates['stateUpdates'],
          }..removeWhere((key, value) => value != null);
          expect(
            jsonWithNullValues.keys.toList()..sort(),
            equals(stateUpdatesWithNullValues.keys.toList()..sort()),
            reason:
                'DynamoPortionDataEntityState should include all optional fields with null values',
          );
        },
      );
    },
  );
}

/// Helper to parse datetime strings
DateTime? maybeValidDateTime(String input) {
  try {
    return DateTime.parse(input);
  } catch (e) {
    return null;
  }
}

/// Verify all DateTime fields in JSON are UTC
void expectAllDateTimeFieldsAreUtc(Map<String, dynamic> json) {
  // test to make sure all dateTime fields are utc
  final dateTimeFields = json.entries
      .where((e) => e.value is String)
      .map((e) => MapEntry(e.key, maybeValidDateTime(e.value as String)))
      .where((e) => e.value != null)
      .toList();

  for (final entry in dateTimeFields) {
    expect(entry.value!.isUtc, isTrue, reason: '${entry.key} is not in UTC');
  }
}
