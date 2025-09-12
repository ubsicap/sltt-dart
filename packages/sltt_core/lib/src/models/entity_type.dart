import '../services/uid_service.dart';

// Top-level constants for entity type string values. Use these wherever a
// stable string literal for an entity type is needed to avoid duplication.
const String kEntityTypeUnknown = 'unknown';
const String kEntityTypeProject = 'project';
const String kEntityTypeProjectCollection = 'projects';
const String kEntityTypeTeam = 'team';
const String kEntityTypeTeamCollection = 'teams';
const String kEntityTypePlan = 'plan';
const String kEntityTypePlanCollection = 'plans';
const String kEntityTypeStage = 'stage';
const String kEntityTypeStageCollection = 'stages';
const String kEntityTypeTask = 'task';
const String kEntityTypeTaskCollection = 'tasks';
const String kEntityTypeMember = 'member';
const String kEntityTypeMemberCollection = 'members';
const String kEntityTypeMessage = 'message';
const String kEntityTypeMessageCollection = 'messages';
const String kEntityTypePortion = 'portion';
const String kEntityTypePortionCollection = 'portions';
const String kEntityTypePassage = 'passage';
const String kEntityTypePassageCollection = 'passages';
const String kEntityTypeReference = 'reference';
const String kEntityTypeReferenceCollection = 'references';
const String kEntityTypeDocument = 'document';
const String kEntityTypeDocumentCollection = 'documents';
const String kEntityTypeVideo = 'video';
const String kEntityTypeVideoCollection = 'videos';
const String kEntityTypePatch = 'patch';
const String kEntityTypePatchCollection = 'patches';
const String kEntityTypeGloss = 'gloss';
const String kEntityTypeGlossCollection = 'glosses';
const String kEntityTypeNote = 'note';
const String kEntityTypeNoteCollection = 'notes';
const String kEntityTypeComment = 'comment';
const String kEntityTypeCommentCollection = 'comments';

String? getCollectionByEntity(String entityType) {
  switch (entityType) {
    case kEntityTypeProject:
      return kEntityTypeProjectCollection;
    case kEntityTypeTeam:
      return kEntityTypeTeamCollection;
    case kEntityTypePlan:
      return kEntityTypePlanCollection;
    case kEntityTypeStage:
      return kEntityTypeStageCollection;
    case kEntityTypeTask:
      return kEntityTypeTaskCollection;
    case kEntityTypeMember:
      return kEntityTypeMemberCollection;
    case kEntityTypeMessage:
      return kEntityTypeMessageCollection;
    case kEntityTypePortion:
      return kEntityTypePortionCollection;
    case kEntityTypePassage:
      return kEntityTypePassageCollection;
    case kEntityTypeReference:
      return kEntityTypeReferenceCollection;
    case kEntityTypeDocument:
      return kEntityTypeDocumentCollection;
    case kEntityTypeVideo:
      return kEntityTypeVideoCollection;
    case kEntityTypePatch:
      return kEntityTypePatchCollection;
    case kEntityTypeGloss:
      return kEntityTypeGlossCollection;
    case kEntityTypeNote:
      return kEntityTypeNoteCollection;
    case kEntityTypeComment:
      return kEntityTypeCommentCollection;
    default:
      return null;
  }
}

String? getEntityByCollection(String collectionName) {
  switch (collectionName) {
    case kEntityTypeProjectCollection:
      return kEntityTypeProject;
    case kEntityTypeTeamCollection:
      return kEntityTypeTeam;
    case kEntityTypePlanCollection:
      return kEntityTypePlan;
    case kEntityTypeStageCollection:
      return kEntityTypeStage;
    case kEntityTypeTaskCollection:
      return kEntityTypeTask;
    case kEntityTypeMemberCollection:
      return kEntityTypeMember;
    case kEntityTypeMessageCollection:
      return kEntityTypeMessage;
    case kEntityTypePortionCollection:
      return kEntityTypePortion;
    case kEntityTypePassageCollection:
      return kEntityTypePassage;
    case kEntityTypeReferenceCollection:
      return kEntityTypeReference;
    case kEntityTypeDocumentCollection:
      return kEntityTypeDocument;
    case kEntityTypeVideoCollection:
      return kEntityTypeVideo;
    case kEntityTypePatchCollection:
      return kEntityTypePatch;
    case kEntityTypeGlossCollection:
      return kEntityTypeGloss;
    case kEntityTypeNoteCollection:
      return kEntityTypeNote;
    case kEntityTypeCommentCollection:
      return kEntityTypeComment;
    default:
      return null;
  }
}

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
