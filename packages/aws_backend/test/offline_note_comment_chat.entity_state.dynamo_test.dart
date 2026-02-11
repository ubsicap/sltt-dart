import 'dart:convert';

import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:aws_backend/src/models/note_comment_chat.data.dart';
import 'package:aws_backend/src/models/note_comment_chat.entity_state.dynamo.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  group(
    'offline - Entity State - Serialization/Deserialization - DynamoNoteCommentChatDataEntityState',
    () {
      test(
        'should detect field-drift and produce stateUpdates compatible with deserialization',
        () {
          final DateTime localTime = DateTime.parse('2023-01-01T00:00:00');
          final localChangeAt = localTime.add(const Duration(minutes: 1));
          final data = NoteCommentChatData(
            text: 'Hello',
            videoId: 'video-id-1',
            dateMs: localTime.millisecondsSinceEpoch,
            visibleToUserIds: ['user2'],
            notifiedUserIds: ['user3'],
            parentId: 'note-1',
            parentProp: kEntityTypeCommentCollection,
            rank: 'aaaaz',
          );

          final changeLogEntry =
              ChangeLogEntryFactoryService.forChangeSave<
                DynamoChangeLogEntry,
                int,
                NoteCommentChatData
              >(
                factory: DynamoChangeLogEntry.new,
                entityId: 'comment-entity-drift-test',
                entityType: kEntityTypeComment,
                domainId: 'project1',
                domainType: 'project',
                changeAt: localChangeAt,
                cid: 'cid-comment-drift-test',
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

          SlttLogger.logger.info(
            'DEBUG: stateUpdates keys: ${updates['stateUpdates'].keys.toList()..sort()}',
          );

          final testEntityState = DynamoNoteCommentChatDataEntityState.fromJson(
            updates['stateUpdates'],
          );

          if (testEntityState.unknownJson != '{}') {
            SlttLogger.logger.info(
              'DEBUG: Unknown fields detected: ${testEntityState.unknownJson}',
            );
            SlttLogger.logger.info(
              'DEBUG: Action needed: Either add missing fields to BaseEntityState or update DynamoNoteCommentChatDataEntityState',
            );
            fail(
              'FIELD DRIFT DETECTED: DynamoNoteCommentChatDataEntityState has unknown fields:\n${const JsonEncoder.withIndent(' ').convert(testEntityState.getUnknown())}',
            );
          }

          expect(
            testEntityState.unknownJson,
            equals('{}'),
            reason:
                'DynamoNoteCommentChatDataEntityState should deserialize without unknown fields',
          );

          final serializedJson = testEntityState.toJson();
          final originalStateUpdates = Map<String, dynamic>.from(
            updates['stateUpdates'],
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
            testEntityState.data_text,
            equals('Hello'),
            reason: 'text field should be correctly deserialized',
          );
          expect(
            testEntityState.data_videoId,
            equals('video-id-1'),
            reason: 'videoId field should be correctly deserialized',
          );
          expect(
            testEntityState.data_dateMs,
            equals(localTime.millisecondsSinceEpoch),
            reason: 'dateMs should be correctly deserialized',
          );
          expect(
            testEntityState.change_changeAt,
            equals(localChangeAt.toUtc()),
            reason: 'changeAt should be in UTC',
          );
          expect(
            testEntityState.data_text_changeAt_,
            equals(localChangeAt.toUtc()),
            reason: 'data_text_changeAt_ should be in UTC',
          );

          expectAllDateTimeFieldsAreUtc(serializedJson);

          final jsonWithNullValues = testEntityState.toJsonBase()
            ..removeWhere((key, value) => value != null);

          jsonWithNullValues.forEach((key, value) {
            updates['stateUpdates'].forEach((stateKey, stateValue) {
              if (key == stateKey ||
                  (!key.endsWith('_') &&
                      stateKey.endsWith('_') &&
                      stateKey.startsWith(key))) {
                expect(
                  stateValue,
                  isNull,
                  reason:
                      'Field "$key" has "null" value but stateUpdates["$stateKey"] has non-null value ($stateValue) in DynamoNoteCommentChatDataEntityState',
                );
              }
            });
          });

          final stateUpdatesWithNullValues = <String, dynamic>{
            ...updates['stateUpdates'],
          }..removeWhere((key, value) => value != null);
          expect(
            jsonWithNullValues.keys.toList()..sort(),
            equals(stateUpdatesWithNullValues.keys.toList()..sort()),
            reason:
                'DynamoNoteCommentChatDataEntityState should include all optional fields with null values',
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
      .map((e) => MapEntry(e.key, e.value!.toUtc().toIso8601String()))
      .toList();

  for (final entry in dateTimeFields) {
    expect(
      json[entry.key],
      equals(entry.value),
      reason: 'DateTime field ${entry.key} should be in UTC',
    );
  }
}
