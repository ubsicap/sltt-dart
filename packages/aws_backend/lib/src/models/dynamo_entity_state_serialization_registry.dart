import 'package:aws_backend/src/models/passage_translation.entity_state.dynamo.dart';
import 'package:aws_backend/src/models/portion_translation.entity_state.dynamo.dart';
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

  // Register a generic Dynamo entity state factory for each supported entity type.
  for (final entityType in EntityType.values) {
    if (entityType == EntityType.unknown) {
      continue;
    }
    if (entityType == EntityType.portion) {
      // Portions are not stored as entity states.
      registerEntityStateFactory(
        entityType,
        (json) => DynamoPortionDataEntityState.fromJson(json),
        (json) => DynamoPortionDataEntityState.fromJsonBase(json),
        (state) => (state as DynamoPortionDataEntityState).toJson(),
        (state) => (state as DynamoPortionDataEntityState).toJsonBase(),
      );
    } else if (entityType == EntityType.passage) {
      registerEntityStateFactory(
        entityType,
        (json) => DynamoPassageDataEntityState.fromJson(json),
        (json) => DynamoPassageDataEntityState.fromJsonBase(json),
        (state) => (state as DynamoPassageDataEntityState).toJson(),
        (state) => (state as DynamoPassageDataEntityState).toJsonBase(),
      );
    }
    // default handler (especially for tests)
    registerEntityStateFactory(
      entityType,
      (json) => DynamoEntityState.fromJson(json),
      (json) => DynamoEntityState.fromJsonBase(json),
      (state) => (state as DynamoEntityState).toJson(),
      (state) => (state as DynamoEntityState).toJsonBase(),
    );
  }

  return true;
})();
