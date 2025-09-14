/// Provides a group of functions for serializing and deserializing
class SerializableGroup<T> {
  final T Function(Map<String, dynamic>) fromJson;
  final T Function(Map<String, dynamic>) fromJsonBase;
  final Map<String, dynamic> Function(T) toJson;
  final Map<String, dynamic> Function(T) toJsonBase;
  final Map<String, dynamic> Function(Map<String, dynamic>) toSafeJson;

  SerializableGroup({
    required this.fromJson,
    required this.fromJsonBase,
    required this.toJson,
    required this.toJsonBase,
    required this.toSafeJson,
  });
}
