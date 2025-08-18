import 'dart:math';

import '../models/base_change_log_entry.dart';
import '../models/entity_type.dart';
import '../models/factory_pair.dart';
import 'json_serialization_service.dart';

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
// Single factory group used for change-log entry deserialization and
// for producing a safe JSON shape on recovery.
FactoryGroup<BaseChangeLogEntry>? _changeLogEntryFactoryGroup;

/// Register a single factory group for change-log entries. The group's
/// `toSafeJson` will be used during recovery to produce a JSON shape that
/// is safe to deserialize for the concrete change-log entry type.
void registerChangeLogEntryFactoryGroup(
  FactoryGroup<BaseChangeLogEntry> group,
) {
  _changeLogEntryFactoryGroup = group;
}

/// Deserialize the provided [json] into the registered `BaseChangeLogEntry`
/// instance for the indicated `entityType` using the safe deserialization
/// wrapper (which will produce a recovery JSON on error).
BaseChangeLogEntry deserializeChangeLogEntryUsingRegistry(
  Map<String, dynamic> json,
) {
  final group = _changeLogEntryFactoryGroup;
  if (group == null) {
    throw Exception('No registered change log entry factory group');
  }
  // Reuse existing safe deserialization helper which will attempt recovery
  return deserializeChangeLogEntrySafely<BaseChangeLogEntry>(
    fromJson: group.fromJson,
    json: json,
    baseToJson: group.toBaseJson,
    toSafeJson: group.toSafeJson,
  );
}

/// Deserialize a BaseChangeLogEntry subclass using the provided factory.
/// If the json['entityType'] can't be parsed, returns an instance with
/// operation='unknownEntityType', entityType=EntityType.unknown and
/// operationInfo capturing the unparseable value.
T deserializeChangeLogEntrySafely<T extends HasUnknownField>({
  required T Function(Map<String, dynamic>) fromJson,
  required Map<String, dynamic> json,
  required Map<String, dynamic> Function(T) baseToJson,
  required Map<String, dynamic> Function(Map<String, dynamic>) toSafeJson,
}) {
  final parsed = _parseEntityType(json['entityType']);

  if (parsed.entityType == null && parsed.raw != null) {
    // Start from caller-provided safe shape and then overlay our hold semantics
    final safeJson = toSafeJson(json);
    safeJson['entityType'] = EntityType.unknown.value;
    safeJson['operation'] = 'hold';
    safeJson['operationInfo'] = {
      ...(safeJson['operationInfo'] as Map<String, dynamic>? ?? {}),
      'hold': 'entityType',
      'entityType': parsed.raw,
    };
    try {
      return deserializeWithUnknownFieldData(fromJson, safeJson, baseToJson);
    } catch (e, st) {
      final recovery = _createSafeJsonFromDeserializationError(
        error: e,
        stack: st,
        originalJson: json,
        toSafeJson: toSafeJson,
      );
      return deserializeWithUnknownFieldData(fromJson, recovery, baseToJson);
    }
  }
  try {
    return deserializeWithUnknownFieldData(fromJson, json, baseToJson);
  } catch (e, st) {
    // Delegate recovery JSON construction to the shared helper
    final recovery = _createSafeJsonFromDeserializationError(
      error: e,
      stack: st,
      originalJson: json,
      toSafeJson: toSafeJson,
    );
    return deserializeWithUnknownFieldData(fromJson, recovery, baseToJson);
  }
}

/// Build a safe JSON to use when deserialization of the original JSON fails.
Map<String, dynamic> _createSafeJsonFromDeserializationError({
  required Object error,
  StackTrace? stack,
  required Map<String, dynamic> originalJson,
  required Map<String, dynamic> Function(Map<String, dynamic>) toSafeJson,
}) {
  final serializedError = error.toString();
  final errorInfo = <String, dynamic>{'error': serializedError};
  if (stack != null) errorInfo['errorStack'] = stack.toString();

  // Start with caller-provided safe shape to maximize compatibility with
  // concrete fromJson, then overlay standardized error semantics.
  final safeJson = toSafeJson(originalJson);

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
  safeJson['storageId'] = safeJson['storageId'] ?? '';
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
