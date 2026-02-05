import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'note.data.g.dart';

@JsonSerializable(includeIfNull: false, checked: true)
class NoteData extends BaseDataFields {
  final String title;

  /// Optional id/reference to an uploaded video for this note (stored elsewhere).
  final String? videoCommentId;

  /// Optional textual description for the note.
  final String? textComment;

  /// Marker reference stored as a single id for serialization.
  final String markerId;

  /// Position within the video in milliseconds.
  final int positionMs;

  /// Resolution state stored as a string (e.g. 'locked','unresolved','resolved').
  final String resolution;

  NoteData({
    required this.title,
    this.videoCommentId,
    this.textComment,
    required this.markerId,
    required this.positionMs,
    required this.resolution,
    required super.parentId,
    required super.parentProp,
    required super.rank,
    super.deleted,
  });

  factory NoteData.fromJson(Map<String, dynamic> json) =>
      _$NoteDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NoteDataToJson(this);
}
