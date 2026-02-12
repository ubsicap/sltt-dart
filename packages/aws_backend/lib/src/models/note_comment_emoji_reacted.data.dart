import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'note_comment_emoji_reacted.data.g.dart';

@JsonSerializable(includeIfNull: false, checked: true)
class NoteCommentEmojiReactedData extends BaseDataFields {
  final String emoji;

  /// The ID of the comment that was reacted to.
  final String commentId;

  /// The ID of the note that contains the comment.
  /// We can use the noteId for the parentId to improve
  /// query performance in the context of an active note
  final String noteId;

  NoteCommentEmojiReactedData({
    required this.emoji,
    required this.commentId,
    required this.noteId,
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
