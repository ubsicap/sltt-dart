import 'dart:math';

/// Enumeration of all supported entity types in the SLTT system.
/// Each entity type will eventually have its own schema and collections.
enum EntityType {
  project('project'),
  team('team'),
  plan('plan'),
  stage('stage'),
  task('task'),
  member('member'),
  message('message'),
  portion('portion'),
  passage('passage'),
  reference('reference'),
  document('document'),
  video('video'),
  patch('patch'),
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

  /// Entity type suffix mapping for consistent entity ID generation
  /// Uses most representative 4 characters, padding with Z where needed
  static const Map<String, String> suffixMapping = {
    'project': 'proj',
    'team': 'team',
    'plan': 'plan',
    'stage': 'stag',
    'task': 'task',
    'member': 'memb',
    'message': 'mesg',
    'portion': 'port',
    'passage': 'psgZ',
    'reference': 'refZ',
    'document': 'docu',
    'video': 'vidZ',
    'patch': 'ptch',
    'gloss': 'glos',
    'note': 'note',
    'comment': 'cmnt',
  };

  /// Get the 4-character suffix for this entity type
  String get suffix =>
      suffixMapping[value] ?? value.substring(0, 4).padRight(4, 'Z');

  /// Get entity suffix for any entity type value
  static String getSuffix(String entityType) {
    return suffixMapping[entityType] ??
        entityType.substring(0, 4).padRight(4, 'Z');
  }

  /// Generate a unique entity ID with embedded entity type suffix
  /// Format: YYYY-mmdd-HHMMss-sss±HHmm-{4-character-random}-{entity-suffix}
  /// Similar to BaseChangeLogEntry.generateCid() but with entity type suffix
  static String generateEntityId(String entityType, [DateTime? timestamp]) {
    final suffix = getSuffix(entityType);

    // Use the same base format as generateCid
    final now = timestamp ?? DateTime.now();
    final utc = now.toUtc();

    // Format: YYYY-mmdd-HHMMss-sss
    final datePart =
        '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}${utc.day.toString().padLeft(2, '0')}-'
        '${utc.hour.toString().padLeft(2, '0')}${utc.minute.toString().padLeft(2, '0')}${utc.second.toString().padLeft(2, '0')}-'
        '${utc.millisecond.toString().padLeft(3, '0')}';

    // Timezone offset: ±HHmm
    final offset = now.timeZoneOffset;
    final offsetSign = offset.isNegative ? '-' : '+';
    final offsetHours = offset.inHours.abs().toString().padLeft(2, '0');
    final offsetMinutes = (offset.inMinutes.abs() % 60).toString().padLeft(
      2,
      '0',
    );
    final timezonePart = '$offsetSign$offsetHours$offsetMinutes';

    // 4-character random part
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final randomPart = String.fromCharCodes(
      Iterable.generate(
        4,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );

    return '$datePart$timezonePart-$randomPart-$suffix';
  }

  /// Instance method to generate entity ID for this entity type
  String generateId([DateTime? timestamp]) =>
      generateEntityId(value, timestamp);

  /// Extract entity type suffix from an entity ID
  /// Returns null if the entity ID doesn't follow the expected format
  static String? extractEntityTypeFromId(String entityId) {
    // Expected format: {base-cid}-{4-char-suffix}
    final parts = entityId.split('-');
    if (parts.length >= 2) {
      final lastPart = parts.last;
      if (lastPart.length == 4) {
        // Find the entity type that matches this suffix
        for (final entry in suffixMapping.entries) {
          if (entry.value == lastPart) {
            return entry.key;
          }
        }
      }
    }
    return null;
  }

  @override
  String toString() => value;
}
