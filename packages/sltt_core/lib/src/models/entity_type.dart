/// Enumeration of all supported entity types in the SLTT system.
/// Each entity type will eventually have its own schema and collections.
enum EntityType {
  project('project'),
  plan('plan'),
  member('member'),
  message('message'),
  portion('portion'),
  passage('passage'),
  reference('reference'),
  document('document'),
  video('video'),
  gloss('gloss'),
  note('note'),
  comment('comment');

  const EntityType(this.value);

  /// The string representation of the entity type
  final String value;

  /// Convert from string to EntityType enum
  static EntityType fromString(String value) {
    for (final entityType in EntityType.values) {
      if (entityType.value.toLowerCase() == value.toLowerCase()) {
        return entityType;
      }
    }
    throw ArgumentError('Unknown entity type: $value');
  }

  /// Convert from string to EntityType enum, returning null for unknown values
  static EntityType? tryFromString(String? value) {
    if (value == null) return null;
    try {
      return fromString(value);
    } catch (e) {
      return null;
    }
  }

  /// Get all entity type values as strings
  static List<String> get allValues =>
      EntityType.values.map((e) => e.value).toList();

  @override
  String toString() => value;
}
