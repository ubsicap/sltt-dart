// entity type helpers moved to base_change_log_entry_service.dart
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

/// Storage-agnostic contract for preserving unknown-field data. To avoid
/// exposing `Map<String,dynamic>` typed members in base types (which
/// causes some code-generators like Isar to fail when scanning class
/// hierarchies), implementations store the unknown/data/operationInfo payloads
/// as JSON strings. Helpers below read/write those JSON fields.
mixin HasUnknownField {
  String get unknownJson;
  set unknownJson(String value);

  /// Return parsed unknown map.
  Map<String, dynamic> getUnknown() {
    if (unknownJson.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(unknownJson);
    return (decoded is Map)
        ? decoded.cast<String, dynamic>()
        : <String, dynamic>{};
  }

  /// Set a single key inside unknown map and persist as JSON.
  void setUnknown(String k, dynamic v) {
    final m = getUnknown();
    m[k] = v;
    unknownJson = jsonEncode(m);
  }
}

/// baseToJson() should return all fields even with null values.
T deserializeWithUnknownFieldData<T extends HasUnknownField>(
  T Function(Map<String, dynamic> json) fromJson,
  Map<String, dynamic> json,
  Map<String, dynamic> Function(T value) baseToJson,
) {
  // Give fromJson an empty `unknown` map to satisfy generated constructors
  final entry = fromJson({'unknownJson': '{}', ...json});
  // Use the generated/base toJson to get only known fields (no unknown merge)
  final knownFields = baseToJson(entry).keys.toSet();
  final unknownFields = Map<String, dynamic>.fromEntries(
    json.entries.where((e) => !knownFields.contains(e.key)),
  );
  // Store unknown fields as a compact JSON string on the implementation
  entry.unknownJson = jsonEncode(unknownFields);
  return entry;
}

Map<String, dynamic> serializeWithUnknownFieldData<T extends HasUnknownField>(
  T entry,
  Map<String, dynamic> Function(T value) baseToJson,
) {
  final json = baseToJson(entry);
  // Merge in unknown fields decoded from the stored JSON string
  final unknown = (entry.unknownJson.isEmpty)
      ? <String, dynamic>{}
      : (jsonDecode(entry.unknownJson) as Map<String, dynamic>);
  return {...json, ...unknown};
}

// (no extension helpers required; mixin provides default implementations)

/// Converter that forces DateTime values to UTC when serializing/deserializing
/// with json_serializable.
///
/// Usage:
/// ```dart
/// @UtcDateTimeConverter()
/// final DateTime changeAt;
/// ```
class UtcDateTimeConverter implements JsonConverter<DateTime, String> {
  const UtcDateTimeConverter();

  @override
  DateTime fromJson(String json) {
    // Parse and normalize to UTC
    // if this were stored in UTC this should be a no-op
    return DateTime.parse(json).toUtc();
  }

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}
