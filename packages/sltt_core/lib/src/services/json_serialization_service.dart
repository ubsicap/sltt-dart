mixin HasUnknownField {
  Map<String, dynamic> get unknown;
  set unknown(Map<String, dynamic> value);
}

T deserializeWithUnknownFieldData<T extends HasUnknownField>(
  T Function(Map<String, dynamic> json) fromJson,
  Map<String, dynamic> json,
  Map<String, dynamic> Function(T value) baseToJson,
) {
  final entry = fromJson(json);
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
