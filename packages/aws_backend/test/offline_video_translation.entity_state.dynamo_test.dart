import 'dart:convert';

import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:aws_backend/src/models/video_translation.data.dart';
import 'package:aws_backend/src/models/video_translation.entity_state.dynamo.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  group(
    'offline - Entity State - Serialization/Deserialization - DynamoVideoDataEntityState',
    () {
      test(
        'should detect field-drift and produce stateUpdates compatible with deserialization',
        () {
          final DateTime localTime = DateTime.parse('2023-01-01T00:00:00');
          final localChangeAt = localTime.add(const Duration(minutes: 1));
          final data = VideoTranslationData(
            name: 'Video Name',
            storedFilename: 'video_name.mp4',
            visibility: ['user1', 'user2'],
            durationMs: 45000,
            parentId: 'root',
            parentProp: 'videos',
            rank: 'aaaaz',
          );

          final changeLogEntry =
              ChangeLogEntryFactoryService.forChangeSave<
                DynamoChangeLogEntry,
                int,
                VideoTranslationData
              >(
                factory: DynamoChangeLogEntry.new,
                entityId: 'entity-drift-test',
                entityType: kEntityTypeVideo,
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
            entityState: null,
            fieldChanges: data.toJson()
              ..removeWhere((key, value) => value == null),
            noOpFields: [],
            storageMode: 'save',
            storageType: 'cloud',
            cs: computeCloudAndStoredAt(changeLogEntry, 'cloud'),
          );

          final testEntityState = DynamoVideoDataEntityState.fromJson(
            updates.stateUpdates,
          );

          if (testEntityState.unknownJson != '{}') {
            SlttLogger.logger.info(
              'DEBUG: Unknown fields detected: ${testEntityState.unknownJson}',
            );
            SlttLogger.logger.info(
              'DEBUG: Action needed: Either add missing fields to BaseEntityState or update DynamoVideoDataEntityState',
            );
            fail(
              'FIELD DRIFT DETECTED: DynamoVideoDataEntityState has unknown fields:\n${const JsonEncoder.withIndent(' ').convert(testEntityState.getUnknown())}',
            );
          }

          expect(
            testEntityState.unknownJson,
            equals('{}'),
            reason:
                'DynamoVideoDataEntityState should deserialize without unknown fields',
          );

          final serializedJson = testEntityState.toJson();
          final originalStateUpdates = Map<String, dynamic>.from(
            updates.stateUpdates,
          );

          serializedJson.remove('unknownJson');

          final strippedStateUpdates = Map<String, dynamic>.from(
            originalStateUpdates,
          )..removeWhere((key, value) => value == null);

          expect(
            serializedJson,
            equals(strippedStateUpdates),
            reason:
                'Round-trip serialization should produce consistent results',
          );

          expect(
            testEntityState.data_name,
            equals('Video Name'),
            reason: 'name field should be correctly deserialized',
          );
          expect(
            testEntityState.data_storedFilename,
            equals('video_name.mp4'),
            reason: 'storedFilename field should be correctly deserialized',
          );
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
            testEntityState.data_storedFilename_changeAt_,
            equals(localChangeAt.toUtc()),
            reason: 'data_storedFilename_changeAt_ should be in UTC',
          );
          expect(
            testEntityState.data_visibility_changeAt_,
            equals(localChangeAt.toUtc()),
            reason:
                'data_visibility_changeAt_ should match the original UTC time',
          );
          expect(
            serializedJson['data_name'],
            equals('Video Name'),
            reason: 'name field should be correctly serialized',
          );

          expectAllDateTimeFieldsAreUtc(serializedJson);

          final jsonWithNullValues = testEntityState.toJsonBase()
            ..removeWhere((key, value) => value != null);

          jsonWithNullValues.forEach((key, value) {
            updates.stateUpdates.forEach((stateKey, stateValue) {
              if (key == stateKey ||
                  !key.endsWith('_') &&
                      stateKey.endsWith('_') &&
                      stateKey.startsWith(key)) {
                expect(
                  stateValue,
                  isNull,
                  reason:
                      'Field "$key" has "null" value but stateUpdates["$stateKey"] has non-null value ($stateValue) in DynamoVideoDataEntityState',
                );
              }
            });
          });

          final stateUpdatesWithNullValues = <String, dynamic>{
            ...updates.stateUpdates,
          }..removeWhere((key, value) => value != null);
          stateUpdatesWithNullValues.putIfAbsent('stateDataHash', () => null);
          stateUpdatesWithNullValues.putIfAbsent(
            'stateDataHash_orig_',
            () => null,
          );

          expect(
            jsonWithNullValues.keys.toList()..sort(),
            equals(stateUpdatesWithNullValues.keys.toList()..sort()),
            reason:
                'DynamoVideoDataEntityState should include all optional fields with null values',
          );
        },
      );
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
