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
