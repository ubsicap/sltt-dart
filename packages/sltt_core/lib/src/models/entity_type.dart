import 'dart:math';

import 'package:sltt_core/sltt_core.dart';

// Top-level constants for entity type string values. Use these wherever a
// stable string literal for an entity type is needed to avoid duplication.

const String kEntityTypeMissing = 'missing';
const String kEntityTypeUnknown = 'unknown';
const String kEntityTypeProject = 'project';
const String kEntityTypeProjectCollection = 'projects';
const String kEntityTypeTeam = 'team';
const String kEntityTypeTeamCollection = 'teams';
const String kEntityTypeMarker = 'marker';
const String kEntityTypeMarkerCollection = 'markers';
const String kEntityTypePlan = 'plan';
const String kEntityTypePlanCollection = 'plans';
const String kEntityTypeStage = 'stage';
const String kEntityTypeStageCollection = 'stages';
const String kEntityTypeTask = 'task';
const String kEntityTypeTaskCollection = 'tasks';
const String kEntityTypeUser = 'user';
const String kEntityTypeUserCollection = 'users';
const String kEntityTypeMember = 'member';
const String kEntityTypeMemberCollection = 'members';
const String kEntityTypeMessage = 'message';
const String kEntityTypeMessageCollection = 'messages';
const String kEntityTypePortion = 'portion';
const String kEntityTypePortionCollection = 'portions';
const String kEntityTypePassage = 'passage';
const String kEntityTypePassageCollection = 'passages';
const String kEntityTypeStoryboard = 'storyboard';
const String kEntityTypeStoryboardCollection = 'storyboards';
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
    case kEntityTypeMarker:
      return kEntityTypeMarkerCollection;
    case kEntityTypePlan:
      return kEntityTypePlanCollection;
    case kEntityTypeStage:
      return kEntityTypeStageCollection;
    case kEntityTypeTask:
      return kEntityTypeTaskCollection;
    case kEntityTypeUser:
      return kEntityTypeUserCollection;
    case kEntityTypeMember:
      return kEntityTypeMemberCollection;
    case kEntityTypeMessage:
      return kEntityTypeMessageCollection;
    case kEntityTypePortion:
      return kEntityTypePortionCollection;
    case kEntityTypePassage:
      return kEntityTypePassageCollection;
    case kEntityTypeStoryboard:
      return kEntityTypeStoryboardCollection;
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
    case kEntityTypeMarkerCollection:
      return kEntityTypeMarker;
    case kEntityTypePlanCollection:
      return kEntityTypePlan;
    case kEntityTypeStageCollection:
      return kEntityTypeStage;
    case kEntityTypeTaskCollection:
      return kEntityTypeTask;
    case kEntityTypeUserCollection:
      return kEntityTypeUser;
    case kEntityTypeMemberCollection:
      return kEntityTypeMember;
    case kEntityTypeMessageCollection:
      return kEntityTypeMessage;
    case kEntityTypePortionCollection:
      return kEntityTypePortion;
    case kEntityTypePassageCollection:
      return kEntityTypePassage;
    case kEntityTypeStoryboardCollection:
      return kEntityTypeStoryboard;
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
  missing(kEntityTypeMissing),
  unknown(kEntityTypeUnknown),
  project(kEntityTypeProject),
  team(kEntityTypeTeam),
  marker(kEntityTypeMarker),
  plan(kEntityTypePlan),
  stage(kEntityTypeStage),
  task(kEntityTypeTask),
  user(kEntityTypeUser),
  member(kEntityTypeMember),
  message(kEntityTypeMessage),
  portion(kEntityTypePortion),
  passage(kEntityTypePassage),
  storyboard(kEntityTypeStoryboard),
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
    kEntityTypeMarker: 'mrkr',
    kEntityTypePlan: 'plan',
    kEntityTypeStage: 'stag',
    kEntityTypeTask: 'task',
    kEntityTypeUser: 'user',
    kEntityTypeMember: 'memb',
    kEntityTypeMessage: 'mesg',
    kEntityTypePortion: 'prtn',
    kEntityTypePassage: 'psgZ',
    kEntityTypeStoryboard: 'strb',
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
  static String getSuffix({required EntityType entityType}) {
    return suffixMapping[entityType.value] ??
        entityType.value.substring(0, 4).padRight(4, 'Z');
  }

  /// Generate a unique entity ID with embedded entity type short suffix
  /// Format: YYYY-mmdd-HHMMss-sss±HH{UC}-{4-character-random}-{entity-short}
  /// Similar to generateCid() but without -cid suffix
  /// ({String? [userId]}) embed 2 character hash of the userId after the timezone hour offset, 'UK' by default
  static String generateEntityId({
    required EntityType entityType,
    String? userId,
  }) {
    final suffix = getSuffix(entityType: entityType);
    final coreId = generateCoreId(userId: userId);
    return '$coreId-$suffix';
  }

  /// Extract entity type suffix from an entity ID
  /// Returns null if the entity ID doesn't follow the expected format
  static String? extractEntityTypeFromId(String entityId) {
    // Expected format: {base-cid}-{4-char-suffix}
    final parts = entityId.split(RegExp(r'[-_]'));
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

/// Example 2026-0108-161325-580-06UK-XQZK-proj
class EntityIdParts {
  final String YYYY;
  final String mmdd;
  final String HHMMss;
  final String zzz;

  /// [_-]HH
  final String tzOffset;

  /// {UC}
  final String usrHash;
  final String randomPart;
  final String entitySuffix;
  final String entityType;
  final String entityId;

  void validate() {
    if (entityId.length != 35) {
      throw FormatException(
        'Invalid entityId length: ${entityId.length}, expected 35',
      );
    }
    // all other fields should have expected lengths
    if (YYYY.length != 4 ||
        mmdd.length != 4 ||
        HHMMss.length != 6 ||
        zzz.length != 3 ||
        tzOffset.length != 3 ||
        usrHash.length != 2 ||
        randomPart.length != 4 ||
        entitySuffix.length != 4) {
      throw FormatException('Invalid entityId format: $entityId');
    }
  }

  EntityIdParts({required this.entityId})
    : YYYY = entityId.substring(0, 4),
      mmdd = entityId.substring(5, 9),
      HHMMss = entityId.substring(10, 16),
      zzz = entityId.substring(17, 20),
      tzOffset = entityId.substring(20, 23),
      usrHash = entityId.substring(23, 25),
      randomPart = entityId.substring(26, 30),
      entitySuffix = entityId.substring(31, 35),
      entityType =
          EntityType.extractEntityTypeFromId(entityId) ?? kEntityTypeUnknown;
}

/// Generates a unique CID (Change ID) in format: (local) YYYY-mmdd-HHMMss-sss[-_]HH{UC}-{4-character-random}
/// ({String? userId}) embed 2 character hash of the userId after the timezone hour offset, 'UK' by default
String generateCoreId({String? userId}) {
  final now = HlcTimestampGenerator.generate();
  final local = now.toLocal();

  // Format: YYYY-mmdd-HHMMss-sss
  final datePart =
      '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}${local.day.toString().padLeft(2, '0')}-'
      '${local.hour.toString().padLeft(2, '0')}${local.minute.toString().padLeft(2, '0')}${local.second.toString().padLeft(2, '0')}-'
      '${local.millisecond.toString().padLeft(3, '0')}';

  // Timezone offset: ±HHmm
  final offset = local.timeZoneOffset;

  /// NOTE: '+' is not as url safe as '_'
  final offsetSign = offset.isNegative ? '-' : '_';
  final offsetHours = offset.inHours.abs().toString().padLeft(2, '0');
  // final offsetMinutes = (offset.inMinutes.abs() % 60).toString().padLeft(
  //   2,
  //   '0',
  // );
  final timezonePart = '$offsetSign$offsetHours';

  // 4-character random part
  final rng = /* timestamp != null ? Random(timestamp.millisecond) : */
      Random();
  final randomPart = generateRandomChars(4, rng: rng);
  final userCode = (userId != null)
      ? generateRandomChars(
          2,
          chars: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',
          rng: Random(1234567890) /* stable for same userId */,
        )
      : 'UK' /* unknown */;
  return '$datePart$timezonePart$userCode-$randomPart';
}

/// Generate a unique CID (Change Log Entry ID) with embedded entity type suffix
/// Format: YYYY-mmdd-HHMMss-sss[_-]HH{UC}-{4chars}-{entity-short}-cid
/// ({String? userId}) embed 2 character hash of the userId after the timezone hour offset, 'UK' by default
String generateCid({required EntityType entityType, String? userId}) {
  final entityId = EntityType.generateEntityId(
    entityType: entityType,
    userId: userId,
  );
  return '$entityId-cid';
}
