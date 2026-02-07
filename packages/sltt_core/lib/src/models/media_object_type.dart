import 'id_service.dart';

const String kMediaObjectTypeVideoTranslation = 'videoTranslation';
const String kMediaObjectTypeVideoComment = 'videoComment';
const String kMediaObjectTypeVideoChat = 'videoChat';
const String kMediaObjectTypeBlob = 'blob';

/// Example: use CoreIdParts from id_service.dart for parsing media object IDs
typedef MediaObjectIdParts = CoreIdParts;

enum MediaObjectType {
  videoTranslation(kMediaObjectTypeVideoTranslation),
  videoComment(kMediaObjectTypeVideoComment),
  videoChat(kMediaObjectTypeVideoChat),
  blob(kMediaObjectTypeBlob);

  const MediaObjectType(this.value);
  final String value;

  /// 'vi' => video,
  /// 'im' => image,
  /// 'dc' => document,
  /// 'dr' => drawing
  static const Map<String, String> suffixMapping = {
    kMediaObjectTypeVideoTranslation: 'viTr',
    kMediaObjectTypeVideoComment: 'viCm',
    kMediaObjectTypeVideoChat: 'viCh',
    kMediaObjectTypeBlob: 'blob',
  };

  /// Generate a unique media object ID with embedded entity type short suffix
  /// Format: YYYY-mmdd-HHMMss-sss±HH{UC}-{4-character-random}-{entity-short}
  /// Similar to generateCid() but without -cid suffix
  /// ({String? [userId]}) embed 2 character hash of the userId after the timezone hour offset, 'UK' by default
  static String generateId({
    required MediaObjectType mediaObjectType,
    String? userId,
  }) {
    final suffix = getSuffix(mediaObjectType: mediaObjectType);
    final entityId = generateCoreId(userId: userId, suffix: suffix);
    return entityId;
  }

  static String getSuffix({required MediaObjectType mediaObjectType}) {
    return suffixMapping[mediaObjectType.value] ??
        mediaObjectType.value.substring(0, 4).padRight(4, 'Z');
  }
}
