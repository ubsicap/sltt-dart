import 'package:sltt_core/src/models/base_entity_state.dart';
import 'package:sltt_core/src/models/entity_type.dart';
import 'package:sltt_core/src/models/factory_pair.dart';
import 'package:sltt_core/src/services/json_serialization_service.dart';

final Map<EntityType, FactoryPair<BaseEntityState>> _entityStateFactories = {};

/// Register a factory pair for a specific [entityType] to deserialize
/// `BaseEntityState` subclasses.
void registerEntityStateFactory(
  EntityType entityType,
  BaseEntityState Function(Map<String, dynamic>) fromJson,
  Map<String, dynamic> Function(BaseEntityState) toBaseJson,
) {
  _entityStateFactories[entityType] = FactoryPair(fromJson, toBaseJson);
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
      pair.fromJson,
      json,
      pair.toBaseJson,
    );
  } catch (e, st) {
    final recovery = _createSafeJsonFromDeserializationError(e, st, json);
    return deserializeWithUnknownFieldData(
      pair.fromJson,
      recovery,
      pair.toBaseJson,
    );
  }
}
