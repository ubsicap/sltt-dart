// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'note_comment_emoji_reacted.entity_state.dynamo.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
class DynamoNoteCommentEmojiReactedDataEntityState extends BaseEntityState {
  @override
  final String entityId;

  final String data_emoji;
  final int? data_emoji_dataSchemaRev_;
  final DateTime data_emoji_changeAt_;
  final String? data_emoji_cid_;
  final String data_emoji_changeBy_;
  final DateTime? data_emoji_cloudAt_;

  final String data_commentId;
  final int? data_commentId_dataSchemaRev_;
  final DateTime data_commentId_changeAt_;
  final String? data_commentId_cid_;
  final String data_commentId_changeBy_;
  final DateTime? data_commentId_cloudAt_;

  final String data_noteId;
  final int? data_noteId_dataSchemaRev_;
  final DateTime data_noteId_changeAt_;
  final String? data_noteId_cid_;
  final String data_noteId_changeBy_;
  final DateTime? data_noteId_cloudAt_;

  DynamoNoteCommentEmojiReactedDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypeCommentReaction,
    required this.entityId,
    required super.domainType,
    required super.change_domainId,
    required super.change_domainId_orig_,
    required super.change_changeAt,
    required super.change_changeAt_orig_,
    required super.change_storedAt,
    required super.change_storedAt_orig_,
    required super.change_cid,
    required super.change_cid_orig_,
    required super.change_changeBy,
    required super.change_changeBy_orig_,
    required super.data_parentId,
    required super.data_parentId_changeAt_,
    required super.data_parentId_cid_,
    required super.data_parentId_changeBy_,
    super.data_parentId_cloudAt_,
    super.data_parentId_dataSchemaRev_,
    required super.data_parentProp,
    required super.data_parentProp_changeAt_,
    required super.data_parentProp_cid_,
    required super.data_parentProp_changeBy_,
    required super.unknownJson,
    super.stateDataHash,
    super.stateDataHash_orig_,
    required this.data_emoji,
    this.data_emoji_dataSchemaRev_,
    required DateTime data_emoji_changeAt_,
    this.data_emoji_cid_,
    required this.data_emoji_changeBy_,
    DateTime? data_emoji_cloudAt_,
    required this.data_commentId,
    this.data_commentId_dataSchemaRev_,
    required DateTime data_commentId_changeAt_,
    this.data_commentId_cid_,
    required this.data_commentId_changeBy_,
    DateTime? data_commentId_cloudAt_,
    required this.data_noteId,
    this.data_noteId_dataSchemaRev_,
    required DateTime data_noteId_changeAt_,
    this.data_noteId_cid_,
    required this.data_noteId_changeBy_,
    DateTime? data_noteId_cloudAt_,
    super.change_cloudAt,
    super.change_dataSchemaRev,
    super.data_deleted,
    super.data_deleted_changeAt_,
    super.data_deleted_changeBy_,
    super.data_deleted_cid_,
    super.data_deleted_cloudAt_,
    super.data_deleted_dataSchemaRev_,
    super.data_parentProp_cloudAt_,
    super.data_parentProp_dataSchemaRev_,
    super.data_rank,
    super.data_rank_changeAt_,
    super.data_rank_changeBy_,
    super.data_rank_cid_,
    super.data_rank_cloudAt_,
    super.data_rank_dataSchemaRev_,
  }) : data_emoji_changeAt_ = data_emoji_changeAt_.toUtc(),
       data_emoji_cloudAt_ = data_emoji_cloudAt_?.toUtc(),
       data_commentId_changeAt_ = data_commentId_changeAt_.toUtc(),
       data_commentId_cloudAt_ = data_commentId_cloudAt_?.toUtc(),
       data_noteId_changeAt_ = data_noteId_changeAt_.toUtc(),
       data_noteId_cloudAt_ = data_noteId_cloudAt_?.toUtc();

  static DynamoNoteCommentEmojiReactedDataEntityState fromJsonBase(
    Map<String, dynamic> json,
  ) => _$DynamoNoteCommentEmojiReactedDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_emoji', () => '');
    j.putIfAbsent('data_commentId', () => '');
    j.putIfAbsent('data_noteId', () => '');
    return j;
  }

  factory DynamoNoteCommentEmojiReactedDataEntityState.fromJson(
    Map<String, dynamic> json,
  ) => deserializeWithUnknownFieldData(
    _$DynamoNoteCommentEmojiReactedDataEntityStateFromJson,
    json,
    _$DynamoNoteCommentEmojiReactedDataEntityStateToJson,
  );

  @override
  Map<String, dynamic> toJson() => serializeWithUnknownFieldData(
    this,
    _$DynamoNoteCommentEmojiReactedDataEntityStateToJson,
  );

  @override
  Map<String, dynamic> toJsonBase() =>
      _$DynamoNoteCommentEmojiReactedDataEntityStateToJson(this);
}
