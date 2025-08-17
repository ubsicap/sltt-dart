import 'dart:math';

import '../services/json_serialization_service.dart';
import 'base_change_log_entry.dart';
import 'entity_type.dart';
import 'factory_pair.dart';

/// Helper used when parsing potentially unknown entityType strings
class _EntityTypeOrRaw {
  final EntityType? entityType;
  final String? raw;
  _EntityTypeOrRaw({required this.entityType, required this.raw});
}

_EntityTypeOrRaw _parseEntityType(dynamic raw) {
  if (raw == null) return _EntityTypeOrRaw(entityType: null, raw: null);
  if (raw is String) {
    final parsed = EntityType.tryFromString(raw);
    if (parsed != null) return _EntityTypeOrRaw(entityType: parsed, raw: null);
    return _EntityTypeOrRaw(entityType: null, raw: raw);
  }
  return _EntityTypeOrRaw(entityType: null, raw: raw?.toString());
}

// --- Factory registration helpers -----------------------------------------
// These maps hold registered (fromJson, toBaseJson) pairs per EntityType.
final Map<EntityType, FactoryPair<BaseChangeLogEntry>>
_changeLogEntryFactories = {};

/// Register a factory pair for a specific [entityType] to deserialize
/// `BaseEntityState` subclasses.
// Note: entity-state factory helpers were moved to `base_entity_state_service.dart`.

/// Register a factory pair for a specific [entityType] to deserialize
/// `BaseChangeLogEntry` subclasses.
void registerChangeLogEntryFactory(
  EntityType entityType,
  BaseChangeLogEntry Function(Map<String, dynamic>) fromJson,
  Map<String, dynamic> Function(BaseChangeLogEntry) toBaseJson,
) {
  _changeLogEntryFactories[entityType] = FactoryPair(fromJson, toBaseJson);
}

/// Deserialize the provided [json] into the registered `BaseChangeLogEntry`
/// instance for the indicated `entityType` using the safe deserialization
/// wrapper (which will produce a recovery JSON on error).
BaseChangeLogEntry deserializeChangeLogEntryUsingRegistry(
  Map<String, dynamic> json,
) {
  final parsed = _parseEntityType(json['entityType']);
  final entityType = parsed.entityType ?? EntityType.unknown;
  final pair = _changeLogEntryFactories[entityType];
  if (pair == null) {
    throw Exception('No registered change log entry factory for $entityType');
  }
  // Reuse existing safe deserialization helper which will attempt recovery
  return deserializeChangeLogEntrySafely<BaseChangeLogEntry>(
    pair.fromJson,
    json,
    pair.toBaseJson,
  );
}

/// Deserialize a BaseChangeLogEntry subclass using the provided factory.
/// If the json['entityType'] can't be parsed, returns an instance with
/// operation='unknownEntityType', entityType=EntityType.unknown and
/// operationInfo capturing the unparseable value.
T deserializeChangeLogEntrySafely<T extends HasUnknownField>(
  T Function(Map<String, dynamic>) fromJson,
  Map<String, dynamic> json,
  Map<String, dynamic> Function(T) baseToJson,
) {
  final parsed = _parseEntityType(json['entityType']);

  if (parsed.entityType == null && parsed.raw != null) {
    final safeJson = Map<String, dynamic>.from(json);
    safeJson['entityType'] = EntityType.unknown.value;
    // Directly set the sentinel operation and record the raw entityType so
    // the entry contains the information needed for later rehydration.
    safeJson['operation'] = 'unknownEntityType';
    safeJson['operationInfo'] = {
      ...(safeJson['operationInfo'] as Map<String, dynamic>? ?? {}),
      'entityType': parsed.raw,
    };
    try {
      return deserializeWithUnknownFieldData(fromJson, safeJson, baseToJson);
    } catch (e, st) {
      final recovery = _createSafeJsonFromDeserializationError(e, st, json);
      return deserializeWithUnknownFieldData(fromJson, recovery, baseToJson);
    }
  }
  try {
    return deserializeWithUnknownFieldData(fromJson, json, baseToJson);
  } catch (e, st) {
    final recovery = _createSafeJsonFromDeserializationError(e, st, json);
    return deserializeWithUnknownFieldData(fromJson, recovery, baseToJson);
  }
}

/// Build a safe JSON to use when deserialization of the original JSON fails.
Map<String, dynamic> _createSafeJsonFromDeserializationError(
  Object error,
  StackTrace? stack,
  Map<String, dynamic> originalJson,
) {
  final serializedError = error.toString();
  final errorInfo = <String, dynamic>{'error': serializedError};
  if (stack != null) errorInfo['errorStack'] = stack.toString();

  final safeJson = Map<String, dynamic>.from(originalJson);

  // Ensure minimal required fields exist and normalize entityType
  safeJson['entityType'] = EntityType.unknown.value;
  safeJson['operation'] = 'error';
  safeJson['operationInfo'] = {
    ...(safeJson['operationInfo'] as Map<String, dynamic>? ?? {}),
    'error': errorInfo['error'] ?? '',
    'errorStack': errorInfo['errorStack'] ?? '',
    'json': originalJson,
  };

  // Ensure required change-log fields exist so fromJson factories can succeed
  safeJson['entityId'] = safeJson['entityId'] ?? 'unknown';
  safeJson['domainId'] = safeJson['domainId'] ?? '';
  safeJson['domainType'] = safeJson['domainType'] ?? '';
  safeJson['changeAt'] =
      safeJson['changeAt'] ?? DateTime.now().toIso8601String();
  safeJson['cid'] = safeJson['cid'] ?? generateCid();
  safeJson['changeBy'] = safeJson['changeBy'] ?? '';
  safeJson['data'] = safeJson['data'] ?? <String, dynamic>{};
  safeJson['stateChanged'] = safeJson['stateChanged'] ?? false;
  safeJson['unknown'] = safeJson['unknown'] ?? <String, dynamic>{};

  return safeJson;
}

/// Generates a unique CID (Change ID) in format: YYYY-mmdd-HHMMss-sss±HHmm-{4-character-random}
String generateCid([DateTime? timestamp]) {
  final now = timestamp ?? DateTime.now();
  final utc = now.toUtc();

  // Format: YYYY-mmdd-HHMMss-sss
  final datePart =
      '${utc.year.toString().padLeft(4, '0')}-'
      '${utc.month.toString().padLeft(2, '0')}${utc.day.toString().padLeft(2, '0')}-'
      '${utc.hour.toString().padLeft(2, '0')}${utc.minute.toString().padLeft(2, '0')}${utc.second.toString().padLeft(2, '0')}-'
      '${utc.millisecond.toString().padLeft(3, '0')}';

  // Timezone offset: ±HHmm
  final offset = now.timeZoneOffset;
  final offsetSign = offset.isNegative ? '-' : '+';
  final offsetHours = offset.inHours.abs().toString().padLeft(2, '0');
  final offsetMinutes = (offset.inMinutes.abs() % 60).toString().padLeft(
    2,
    '0',
  );
  final timezonePart = '$offsetSign$offsetHours$offsetMinutes';

  // 4-character random part
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  final randomPart = String.fromCharCodes(
    Iterable.generate(4, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
  );

  return '$datePart$timezonePart-$randomPart';
}
