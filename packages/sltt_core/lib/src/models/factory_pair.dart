/// JsonSerialization methods used by both change-log and entity-state services
class JsonSerializationFactoryGroup<T> {
  /// factory method to create an instance from JSON
  final T Function(Map<String, dynamic>) create;

  /// factory method to restore an instance from JSON
  final T Function(Map<String, dynamic>) restore;

  /// factory method to convert an instance to JSON
  final Map<String, dynamic> Function(T) toBaseJson;

  JsonSerializationFactoryGroup(this.create, this.restore, this.toBaseJson);
}

/// Extended factory group for change-log entry factories.
/// Provides an additional `toSafeJson` function which can produce a
/// deserializable JSON shape suitable for recovery when deserialization
/// of arbitrary incoming JSON fails.
class SafeJsonSerializationFactoryGroup<T>
    extends JsonSerializationFactoryGroup<T> {
  final Map<String, dynamic> Function(Map<String, dynamic>) toSafeJson;

  SafeJsonSerializationFactoryGroup(
    super.create,
    super.restore,
    super.toBaseJson,
    this.toSafeJson,
  );
}
