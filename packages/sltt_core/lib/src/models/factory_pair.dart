/// Provides a group of functions for serializing and deserializing
class SerializableGroup<T> {
  final T Function(Map<String, dynamic>) fromJson;
  final T Function(Map<String, dynamic>) fromJsonBase;
  final Map<String, dynamic> Function(T) toJson;
  final Map<String, dynamic> Function(T) toJsonBase;
  final Map<String, dynamic> Function(Map<String, dynamic>) toSafeJson;

  SerializableGroup(
    this.fromJson,
    this.fromJsonBase,
    this.toJson,
    this.toJsonBase,
    this.toSafeJson,
  );
}
