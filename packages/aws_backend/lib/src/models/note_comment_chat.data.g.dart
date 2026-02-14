// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_comment_chat.data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteCommentChatData _$NoteCommentChatDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NoteCommentChatData', json, ($checkedConvert) {
      final val = NoteCommentChatData(
        text: $checkedConvert('text', (v) => v as String?),
        videoStoredFilename: $checkedConvert(
          'videoStoredFilename',
          (v) => v as String?,
        ),
        videoDurationMs: $checkedConvert(
          'videoDurationMs',
          (v) => (v as num?)?.toInt(),
        ),
        dateMs: $checkedConvert('dateMs', (v) => (v as num).toInt()),
        visibleToUserIds: $checkedConvert(
          'visibleToUserIds',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        notifiedUserIds: $checkedConvert(
          'notifiedUserIds',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        parentId: $checkedConvert('parentId', (v) => v as String),
        parentProp: $checkedConvert('parentProp', (v) => v as String),
        rank: $checkedConvert('rank', (v) => v as String?),
        deleted: $checkedConvert('deleted', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$NoteCommentChatDataToJson(
  NoteCommentChatData instance,
) => <String, dynamic>{
  'parentId': instance.parentId,
  'parentProp': instance.parentProp,
  'rank': ?instance.rank,
  'deleted': ?instance.deleted,
  'text': ?instance.text,
  'videoStoredFilename': ?instance.videoStoredFilename,
  'videoDurationMs': ?instance.videoDurationMs,
  'dateMs': instance.dateMs,
  'visibleToUserIds': ?instance.visibleToUserIds,
  'notifiedUserIds': instance.notifiedUserIds,
};
