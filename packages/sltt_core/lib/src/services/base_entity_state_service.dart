import 'package:sltt_core/src/models/base_entity_state.dart';
import 'package:sltt_core/src/models/entity_type.dart';
import 'package:sltt_core/src/models/serializable_group.dart';
import 'package:sltt_core/src/services/json_serialization_service.dart';

final Map<EntityType, SerializableGroup<BaseEntityState>>
_entityStateFactories = {};

/// Register a factory pair for a specific [entityType] to deserialize
/// `BaseEntityState` subclasses.
void registerEntityStateFactory(
  EntityType entityType,
  BaseEntityState Function(Map<String, dynamic>) fromJson,
  BaseEntityState Function(Map<String, dynamic>) fromJsonBase,
  Map<String, dynamic> Function(BaseEntityState) toJson,
  Map<String, dynamic> Function(BaseEntityState) toJsonBase,
) {
  _entityStateFactories[entityType] = SerializableGroup(
    fromJson,
    fromJsonBase,
    toJson,
    toJsonBase,
    (json) {
      throw Exception('No safe JSON conversion implemented for $entityType');
    },
  );
}

/// Deserialize the provided [json] into the registered `BaseEntityState`
/// instance for the indicated `entityType`.
BaseEntityState deserializeEntityStateSafely(Map<String, dynamic> json) {
  final raw = json['entityType'];
  final parsed = raw is String ? EntityType.tryFromString(raw) : null;
  final entityType = parsed ?? EntityType.unknown;
  final pair = _entityStateFactories[entityType];
  if (pair == null) {
    throw Exception('No registered entity state factory for $entityType');
  }
  try {
    return deserializeWithUnknownFieldData(
      pair.fromJsonBase,
      json,
      pair.toJsonBase,
    );
  } catch (e) {
    // Entity-state specific deserialization errors are not recovered here.
    // Let the caller handle or surface the error so higher-level logic
    // (e.g., change-log deserialization recovery) can decide how to proceed.
    rethrow;
  }
}
