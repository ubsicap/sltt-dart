// entity type helpers moved to base_change_log_entry_service.dart

mixin HasUnknownField {
  Map<String, dynamic> get unknown;
  set unknown(Map<String, dynamic> value);
}

/// baseToJson() should return all fields even with null values.
T deserializeWithUnknownFieldData<T extends HasUnknownField>(
  T Function(Map<String, dynamic> json) fromJson,
  Map<String, dynamic> json,
  Map<String, dynamic> Function(T value) baseToJson,
) {
  // Normalize any nested Map values to Map<String, dynamic> so the
  // generated fromJson (which expects Map<String, dynamic>) doesn't fail
  // when given _Map<dynamic,dynamic> instances.
  final normalized = <String, dynamic>{};
  json.forEach((k, v) {
    if (v is Map) {
      normalized[k] = (v).cast<String, dynamic>();
    } else {
      normalized[k] = v;
    }
  });

  final entry = fromJson({'unknown': <String, dynamic>{}, ...normalized});
  // Use the generated/base toJson to get only known fields (no unknown merge)
  final knownFields = baseToJson(entry).keys.toSet();
  final unknownFields = Map<String, dynamic>.fromEntries(
    json.entries.where((e) => !knownFields.contains(e.key)),
  );
  entry.unknown = unknownFields;
  return entry;
}

Map<String, dynamic> serializeWithUnknownFieldData<T extends HasUnknownField>(
  T entry,
  Map<String, dynamic> Function(T value) baseToJson,
) {
  final json = baseToJson(entry);
  return {...json, ...entry.unknown};
}
