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
}
