import 'package:sltt_core/sltt_core.dart' show SlttLogger;
import 'package:sltt_core/src/models/base_entity_state.dart';
import 'package:sltt_core/src/models/entity_type.dart';
import 'package:sltt_core/src/models/serializable_group.dart';
import 'package:sltt_core/src/services/json_serialization_service.dart';

final Map<EntityType, SerializableGroup<BaseEntityState>>
_entityStateFactories = {};

/// Register a factory group for a specific [entityType] to deserialize
/// `BaseEntityState` subclasses.
void registerEntityStateFactory(
  EntityType entityType,
  BaseEntityState Function(Map<String, dynamic>) fromJson,
  BaseEntityState Function(Map<String, dynamic>) fromJsonBase,
  Map<String, dynamic> Function(BaseEntityState) toJson,
  Map<String, dynamic> Function(BaseEntityState) toJsonBase,
) {
  _entityStateFactories[entityType] = SerializableGroup(
    fromJson: fromJson,
    fromJsonBase: fromJsonBase,
    toJson: toJson,
    toJsonBase: toJsonBase,
    toSafeJson: (json) {
      throw Exception('No safe JSON conversion implemented for $entityType');
    },
  );
}

/// Deserialize the provided [json] into the registered `BaseEntityState`
/// instance for the indicated `entityType`.
BaseEntityState deserializeEntityStateSafely(Map<String, dynamic> json) {
  final raw = json['entityType'];
  final parsed = raw is String ? EntityType.tryFromString(raw) : null;
  final entityType = parsed ?? EntityType.missing;
  final group =
      _entityStateFactories[entityType] ??
      _entityStateFactories[EntityType.unknown];
  if (group == null) {
    throw Exception('No entity state factory registered for entityType=$raw');
  }
  if (parsed == EntityType.unknown) {
    throw Exception('entityType `unknown` is reserved for unregistered types.');
  }
  if (parsed == EntityType.missing) {
    throw Exception(
      'entityType `missing` is reserved for missing entityType field data.',
    );
  }
  final groupKey = _entityStateFactories[entityType] != null
      ? entityType
      : EntityType.unknown;
  if (groupKey == EntityType.unknown) {
    SlttLogger.logger.warning(
      'Deserializing entity state with unregistered entityType="$raw"',
    );
  }
  try {
    return deserializeWithUnknownFieldData(
      group.fromJsonBase,
      json,
      group.toJsonBase,
    );
  } catch (e) {
    // Entity-state specific deserialization errors are not recovered here.
    // Let the caller handle or surface the error so higher-level logic
    // (e.g., change-log deserialization recovery) can decide how to proceed.
    rethrow;
  }
}

/// Return the list of registered `EntityType` keys that have entity state
/// factories registered. This is intended for storage implementations to
/// surface which entity types they can handle as persisted entity states.
List<EntityType> getRegisteredEntityStateTypes() {
  return _entityStateFactories.keys.toList(growable: false);
}

SerializableGroup<BaseEntityState>? getSerializableGroup(
  EntityType entityType,
) {
  return _entityStateFactories[entityType];
}
