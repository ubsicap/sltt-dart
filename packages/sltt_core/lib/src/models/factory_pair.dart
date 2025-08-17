// Shared lightweight factory pair used by both change-log and entity-state services
class FactoryPair<T> {
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toBaseJson;

  FactoryPair(this.fromJson, this.toBaseJson);
}

/// Extended factory group for change-log entry factories.
/// Provides an additional `toSafeJson` function which can produce a
/// deserializable JSON shape suitable for recovery when deserialization
/// of arbitrary incoming JSON fails.
class FactoryGroup<T> extends FactoryPair<T> {
  final Map<String, dynamic> Function(Map<String, dynamic>) toSafeJson;

  FactoryGroup(super.fromJson, super.toBaseJson, this.toSafeJson);
}
