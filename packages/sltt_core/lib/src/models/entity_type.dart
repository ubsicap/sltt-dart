import '../services/uid_service.dart';

// Top-level constants for entity type string values. Use these wherever a
// stable string literal for an entity type is needed to avoid duplication.
const String kEntityTypeUnknown = 'unknown';
const String kEntityTypeProject = 'project';
const String kEntityTypeTeam = 'team';
const String kEntityTypePlan = 'plan';
const String kEntityTypeStage = 'stage';
const String kEntityTypeTask = 'task';
const String kEntityTypeMember = 'member';
const String kEntityTypeMessage = 'message';
const String kEntityTypePortion = 'portion';
const String kEntityTypePassage = 'passage';
const String kEntityTypeReference = 'reference';
const String kEntityTypeDocument = 'document';
const String kEntityTypeVideo = 'video';
const String kEntityTypePatch = 'patch';
const String kEntityTypeGloss = 'gloss';
const String kEntityTypeNote = 'note';
const String kEntityTypeComment = 'comment';

/// Enumeration of all supported entity types in the SLTT system.
/// Each entity type will eventually have its own schema and collections.
enum EntityType {
  /// Unknown value for forward compatibility when clients send newer entity types
  unknown(kEntityTypeUnknown),
  project(kEntityTypeProject),
  team(kEntityTypeTeam),
  plan(kEntityTypePlan),
  stage(kEntityTypeStage),
  task(kEntityTypeTask),
  member(kEntityTypeMember),
  message(kEntityTypeMessage),
  portion(kEntityTypePortion),
  passage(kEntityTypePassage),
  reference(kEntityTypeReference),
  document(kEntityTypeDocument),
  video(kEntityTypeVideo),
  patch(kEntityTypePatch),
  gloss(kEntityTypeGloss),
  note(kEntityTypeNote),
  comment(kEntityTypeComment);

  const EntityType(this.value);

  /// The string representation of the entity type
  final String value;

  /// Entity type suffix mapping for consistent entity ID generation
  /// Uses most representative 4 characters, padding with Z where needed
  static const Map<String, String> suffixMapping = {
    kEntityTypeProject: 'proj',
    kEntityTypeTeam: 'team',
    kEntityTypePlan: 'plan',
    kEntityTypeStage: 'stag',
    kEntityTypeTask: 'task',
    kEntityTypeMember: 'memb',
    kEntityTypeMessage: 'mesg',
    kEntityTypePortion: 'port',
    kEntityTypePassage: 'psgZ',
    kEntityTypeReference: 'refZ',
    kEntityTypeDocument: 'docu',
    kEntityTypeVideo: 'vidZ',
    kEntityTypePatch: 'ptch',
    kEntityTypeGloss: 'glos',
    kEntityTypeNote: 'note',
    kEntityTypeComment: 'cmnt',
  };

  /// Get the 4-character suffix for this entity type
  String get suffix =>
      suffixMapping[value] ?? value.substring(0, 4).padRight(4, 'Z');

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
    final cid = generateCid(timestamp);
    return '$cid-$suffix';
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
