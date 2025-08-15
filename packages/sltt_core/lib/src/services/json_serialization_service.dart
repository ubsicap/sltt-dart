mixin HasUnknownField {
  Map<String, dynamic> get unknown;
  set unknown(Map<String, dynamic> value);
  Map<String, dynamic> toJson();
}

T deserializeWithUnknownFieldData<T extends HasUnknownField>(
  T Function(Map<String, dynamic> json) fromJson,
  Map<String, dynamic> json,
) {
  final entry = fromJson(json);
  final knownFields = entry.toJson().keys.toSet();
  final unknownFields = Map<String, dynamic>.fromEntries(
    json.entries.where((entry) => !knownFields.contains(entry.key)),
  );
  entry.unknown = unknownFields;
  return entry;
}

Map<String, dynamic> serializeWithUnknownFieldData<T extends HasUnknownField>(
  T entry,
) {
  final json = entry.toJson();
  json.addAll(entry.unknown);
  return json;
}
