import 'dart:convert';

import '../logging.dart';
import '../models/base_change_log_entry.dart';
import '../models/entity_type.dart';
import '../models/serializable_group.dart';
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
SerializableGroup<BaseChangeLogEntry>? _changeLogEntryFactoryGroup;

/// Register a single factory group for change-log entries. The group's
/// `toSafeJson` will be used during recovery to produce a JSON shape that
/// is safe to deserialize for the concrete change-log entry type.
void registerChangeLogEntryFactoryGroup(
  SerializableGroup<BaseChangeLogEntry> group,
) {
  _changeLogEntryFactoryGroup = group;
}

validateChangeLogEntryDataJson(BaseChangeLogEntry entry) {
  final group = _changeLogEntryFactoryGroup;
  if (group == null) {
    throw Exception('No registered change log entry SerializableGroup');
  }
  if (group.validate != null) {
    return group.validate!(entry);
  } else {
    throw Exception(
      'No validate function provided in registered change log entry SerializableGroup',
    );
  }
}

/// Serialize a registered BaseChangeLogEntry instance into a safe JSON map
/// using the registered SerializableGroup's toJsonBase and the
/// shared serializeWithUnknownFieldData helper which will merge unknown
/// fields stored in the object's unknownJson string.
Map<String, dynamic> serializeChangeLogEntryUsingRegistry(
  BaseChangeLogEntry entry,
) {
  final group = _changeLogEntryFactoryGroup;
  if (group == null) {
    throw Exception('No registered change log entry SerializableGroup');
  }
  // Use the group's toJsonBase to get known-fields map, then merge unknowns
  return serializeWithUnknownFieldData<BaseChangeLogEntry>(
    entry,
    group.toJsonBase,
  );
}

/// Deserialize the provided [json] into the registered `BaseChangeLogEntry`
/// instance for the indicated `entityType` using the safe deserialization
/// wrapper (which will produce a recovery JSON on error).
BaseChangeLogEntry deserializeChangeLogEntryUsingRegistry(
  Map<String, dynamic> json, {
  bool validateDataJson = false,
}) {
  final group = _changeLogEntryFactoryGroup;
  if (group == null) {
    throw Exception('No registered change log entry SerializableGroup');
  }
  // Reuse existing safe deserialization helper which will attempt recovery
  final changeLogEntry = deserializeChangeLogEntrySafely<BaseChangeLogEntry>(
    fromJsonBase: group.fromJsonBase,
    json: json,
    toJsonBase: group.toJsonBase,
    toSafeJson: group.toSafeJson,
  );
  // validate changeLogEntry dataJson if a validator is provided
  if (validateDataJson) {
    if (group.validate == null) {
      throw Exception(
        'No validate function provided in registered change log entry SerializableGroup',
      );
    }
    group.validate!(changeLogEntry);
  }
  return changeLogEntry;
}

List<BaseChangeLogEntry> fromJsonChangeLogEntryList(
  List<dynamic> jsonList, {
  bool validateDataJson = false,
}) {
  final group = _changeLogEntryFactoryGroup;
  if (group == null) {
    throw Exception('No registered change log entry SerializableGroup');
  }
  return jsonList.map((json) {
    if (json is Map<String, dynamic>) {
      return deserializeChangeLogEntryUsingRegistry(
        json,
        validateDataJson: validateDataJson,
      );
    } else {
      throw Exception('Invalid JSON object in list: $json');
    }
  }).toList();
}

List<Map<String, dynamic>> toJsonChangeLogEntryList(
  List<BaseChangeLogEntry> entries,
) {
  final group = _changeLogEntryFactoryGroup;
  if (group == null) {
    throw Exception('No registered change log entry SerializableGroup');
  }
  return entries
      .map((entry) => serializeChangeLogEntryUsingRegistry(entry))
      .toList();
}

/// Deserialize a BaseChangeLogEntry subclass using the provided factory.
/// If the json['entityType'] can't be parsed, returns an instance with
/// operation='hold', entityType=EntityType.unknown and
/// operationInfo capturing the unparsable value.
T deserializeChangeLogEntrySafely<T extends HasUnknownField>({
  required T Function(Map<String, dynamic>) fromJsonBase,
  required Map<String, dynamic> json,
  required Map<String, dynamic> Function(T) toJsonBase,
  required Map<String, dynamic> Function(Map<String, dynamic>) toSafeJson,
}) {
  late final Map<String, dynamic> json2;
  final parsed = _parseEntityType(json['entityType']);
  if (parsed.entityType == null && parsed.raw != null) {
    // Start from caller-provided safe shape and then overlay our hold semantics
    final safeJson = toSafeJson(json);
    safeJson['entityType'] = EntityType.unknown.value;
    safeJson['operation'] = 'hold';
    safeJson['operationInfoJson'] = jsonEncode({
      ...(jsonDecode(JsonUtils.normalize(safeJson['operationInfoJson']))),
      'hold': 'entityType',
      'entityType': parsed.raw,
    });
    json2 = safeJson;
  } else {
    json2 = json;
  }
  try {
    return deserializeWithUnknownFieldData(fromJsonBase, json2, toJsonBase);
  } catch (e, st) {
    // Delegate recovery JSON construction to the shared helper
    final recovery = _createSafeJsonFromDeserializationError(
      error: e,
      stack: st,
      originalJson: json,
      toSafeJson: toSafeJson,
    );
    return deserializeWithUnknownFieldData(fromJsonBase, recovery, toJsonBase);
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
  safeJson['operationInfoJson'] = jsonEncode({
    ...(jsonDecode(JsonUtils.normalize(safeJson['operationInfoJson']))),
    'error': errorInfo['error'] ?? '',
    'errorStack': errorInfo['errorStack'] ?? '',
    'json': originalJson,
  });
  // Log the deserialization failure including the recovered safe JSON.
  // Use the project logger so output can be controlled in tests and CI.
  SlttLogger.logger.severe(
    '** Deserialization error, using safe JSON, error: ${errorInfo['error']}. Safe JSON: ${const JsonEncoder.withIndent('  ').convert(safeJson)}',
  );
  return safeJson;
}
