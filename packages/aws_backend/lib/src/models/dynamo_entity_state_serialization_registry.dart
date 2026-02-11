import 'package:aws_backend/src/models/marker.entity_state.dynamo.dart';
import 'package:aws_backend/src/models/note.entity_state.dynamo.dart';
import 'package:aws_backend/src/models/note_comment_chat.entity_state.dynamo.dart';
import 'package:aws_backend/src/models/note_comment_emoji_reacted.entity_state.dynamo.dart';
import 'package:aws_backend/src/models/passage_translation.entity_state.dynamo.dart';
import 'package:aws_backend/src/models/portion_translation.entity_state.dynamo.dart';
import 'package:aws_backend/src/models/video_translation.entity_state.dynamo.dart';
import 'package:sltt_core/sltt_core.dart';

import 'dynamo_change_log_entry.dart';
import 'dynamo_entity_state.dart';

/// Ensure all Dynamo serialization factories are registered.
///
/// This is idempotent, so calling it multiple times is safe.
bool ensureDynamoSerializersRegistered() {
  return _dynamoSerializationRegistration;
}

final bool _dynamoSerializationRegistration = (() {
  // Ensure the change-log entry registration runs.
  dynamoChangeLogEntryFactoryRegistration;
  // register a generic Dynamo entity state factory for unknown types.
  registerEntityStateFactory(
    EntityType.unknown,
    (json) => DynamoEntityState.fromJson(json),
    (json) => DynamoEntityState.fromJsonBase(json),
    (state) => (state as DynamoEntityState).toJson(),
    (state) => (state as DynamoEntityState).toJsonBase(),
  );
  // Register a Dynamo entity state factory for each supported entity type.
  registerEntityStateFactory(
    EntityType.portion,
    (json) => DynamoPortionDataEntityState.fromJson(json),
    (json) => DynamoPortionDataEntityState.fromJsonBase(json),
    (state) => (state as DynamoPortionDataEntityState).toJson(),
    (state) => (state as DynamoPortionDataEntityState).toJsonBase(),
  );
  registerEntityStateFactory(
    EntityType.passage,
    (json) => DynamoPassageDataEntityState.fromJson(json),
    (json) => DynamoPassageDataEntityState.fromJsonBase(json),
    (state) => (state as DynamoPassageDataEntityState).toJson(),
    (state) => (state as DynamoPassageDataEntityState).toJsonBase(),
  );

  registerEntityStateFactory(
    EntityType.video,
    (json) => DynamoVideoDataEntityState.fromJson(json),
    (json) => DynamoVideoDataEntityState.fromJsonBase(json),
    (state) => (state as DynamoVideoDataEntityState).toJson(),
    (state) => (state as DynamoVideoDataEntityState).toJsonBase(),
  );
  registerEntityStateFactory(
    EntityType.marker,
    (json) => DynamoMarkerDataEntityState.fromJson(json),
    (json) => DynamoMarkerDataEntityState.fromJsonBase(json),
    (state) => (state as DynamoMarkerDataEntityState).toJson(),
    (state) => (state as DynamoMarkerDataEntityState).toJsonBase(),
  );
  registerEntityStateFactory(
    EntityType.note,
    (json) => DynamoNoteDataEntityState.fromJson(json),
    (json) => DynamoNoteDataEntityState.fromJsonBase(json),
    (state) => (state as DynamoNoteDataEntityState).toJson(),
    (state) => (state as DynamoNoteDataEntityState).toJsonBase(),
  );
  registerEntityStateFactory(
    EntityType.comment,
    (json) => DynamoNoteCommentChatDataEntityState.fromJson(json),
    (json) => DynamoNoteCommentChatDataEntityState.fromJsonBase(json),
    (state) => (state as DynamoNoteCommentChatDataEntityState).toJson(),
    (state) => (state as DynamoNoteCommentChatDataEntityState).toJsonBase(),
  );
  registerEntityStateFactory(
    EntityType.commentReaction,
    (json) => DynamoNoteCommentEmojiReactedDataEntityState.fromJson(json),
    (json) => DynamoNoteCommentEmojiReactedDataEntityState.fromJsonBase(json),
    (state) => (state as DynamoNoteCommentEmojiReactedDataEntityState).toJson(),
    (state) =>
        (state as DynamoNoteCommentEmojiReactedDataEntityState).toJsonBase(),
  );
  return true;
})();
