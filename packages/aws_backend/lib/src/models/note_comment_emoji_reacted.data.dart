import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'note_comment_emoji_reacted.data.g.dart';

@JsonSerializable(includeIfNull: false, checked: true)
class NoteCommentEmojiReactedData extends BaseDataFields {
  final String emoji;

  NoteCommentEmojiReactedData({
    required this.emoji,
    required super.parentId,
    required super.parentProp,
    required super.rank,
    super.deleted,
  });

  factory NoteCommentEmojiReactedData.fromJson(Map<String, dynamic> json) =>
      _$NoteCommentEmojiReactedDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NoteCommentEmojiReactedDataToJson(this);
}
