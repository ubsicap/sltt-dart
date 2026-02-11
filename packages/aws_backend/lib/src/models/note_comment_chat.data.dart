import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'note_comment_chat.data.g.dart';

@JsonSerializable(includeIfNull: false, checked: true)
class NoteCommentChatData extends BaseDataFields {
  final String text;
  final String videoId;
  final int dateMs;
  final List<String>? visibleToUserIds;
  final List<String> notifiedUserIds;

  NoteCommentChatData({
    required this.text,
    required this.videoId,
    required this.dateMs,
    this.visibleToUserIds,
    required this.notifiedUserIds,
    required super.parentId,
    required super.parentProp,
    required super.rank,
    super.deleted,
  });

  factory NoteCommentChatData.fromJson(Map<String, dynamic> json) =>
      _$NoteCommentChatDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NoteCommentChatDataToJson(this);
}
