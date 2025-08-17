// Shared lightweight factory pair used by both change-log and entity-state services
class FactoryPair<T> {
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toBaseJson;

  FactoryPair(this.fromJson, this.toBaseJson);
}
