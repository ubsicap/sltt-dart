// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_comment_emoji_reacted.data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteCommentEmojiReactedData _$NoteCommentEmojiReactedDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NoteCommentEmojiReactedData', json, ($checkedConvert) {
  final val = NoteCommentEmojiReactedData(
    emoji: $checkedConvert('emoji', (v) => v as String),
    parentId: $checkedConvert('parentId', (v) => v as String),
    parentProp: $checkedConvert('parentProp', (v) => v as String),
    rank: $checkedConvert('rank', (v) => v as String?),
    deleted: $checkedConvert('deleted', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$NoteCommentEmojiReactedDataToJson(
  NoteCommentEmojiReactedData instance,
) => <String, dynamic>{
  'parentId': instance.parentId,
  'parentProp': instance.parentProp,
  'rank': ?instance.rank,
  'deleted': ?instance.deleted,
  'emoji': instance.emoji,
};
