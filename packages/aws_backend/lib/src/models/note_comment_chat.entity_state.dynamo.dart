// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'note_comment_chat.entity_state.dynamo.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
class DynamoNoteCommentChatDataEntityState extends BaseEntityState {
  @override
  final String entityId;

  final String data_text;
  final int? data_text_dataSchemaRev_;
  final DateTime data_text_changeAt_;
  final String? data_text_cid_;
  final String data_text_changeBy_;
  final DateTime? data_text_cloudAt_;

  final String data_videoId;
  final int? data_videoId_dataSchemaRev_;
  final DateTime data_videoId_changeAt_;
  final String? data_videoId_cid_;
  final String data_videoId_changeBy_;
  final DateTime? data_videoId_cloudAt_;

  final int data_dateMs;
  final int? data_dateMs_dataSchemaRev_;
  final DateTime data_dateMs_changeAt_;
  final String? data_dateMs_cid_;
  final String data_dateMs_changeBy_;
  final DateTime? data_dateMs_cloudAt_;

  final List<String>? data_visibleToUserIds;
  final int? data_visibleToUserIds_dataSchemaRev_;
  final DateTime? data_visibleToUserIds_changeAt_;
  final String? data_visibleToUserIds_cid_;
  final String? data_visibleToUserIds_changeBy_;
  final DateTime? data_visibleToUserIds_cloudAt_;

  final List<String> data_notifiedUserIds;
  final int? data_notifiedUserIds_dataSchemaRev_;
  final DateTime data_notifiedUserIds_changeAt_;
  final String data_notifiedUserIds_cid_;
  final String data_notifiedUserIds_changeBy_;
  final DateTime? data_notifiedUserIds_cloudAt_;

  DynamoNoteCommentChatDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypeComment,
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
    required this.data_text,
    this.data_text_dataSchemaRev_,
    required DateTime data_text_changeAt_,
    this.data_text_cid_,
    required this.data_text_changeBy_,
    DateTime? data_text_cloudAt_,
    required this.data_videoId,
    this.data_videoId_dataSchemaRev_,
    required DateTime data_videoId_changeAt_,
    this.data_videoId_cid_,
    required this.data_videoId_changeBy_,
    DateTime? data_videoId_cloudAt_,
    required this.data_dateMs,
    this.data_dateMs_dataSchemaRev_,
    required DateTime data_dateMs_changeAt_,
    this.data_dateMs_cid_,
    required this.data_dateMs_changeBy_,
    DateTime? data_dateMs_cloudAt_,
    this.data_visibleToUserIds,
    this.data_visibleToUserIds_dataSchemaRev_,
    DateTime? data_visibleToUserIds_changeAt_,
    this.data_visibleToUserIds_cid_,
    this.data_visibleToUserIds_changeBy_,
    DateTime? data_visibleToUserIds_cloudAt_,
    required this.data_notifiedUserIds,
    this.data_notifiedUserIds_dataSchemaRev_,
    required DateTime data_notifiedUserIds_changeAt_,
    required this.data_notifiedUserIds_cid_,
    required this.data_notifiedUserIds_changeBy_,
    DateTime? data_notifiedUserIds_cloudAt_,
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
  }) : data_text_changeAt_ = data_text_changeAt_.toUtc(),
       data_text_cloudAt_ = data_text_cloudAt_?.toUtc(),
       data_videoId_changeAt_ = data_videoId_changeAt_.toUtc(),
       data_videoId_cloudAt_ = data_videoId_cloudAt_?.toUtc(),
       data_dateMs_changeAt_ = data_dateMs_changeAt_.toUtc(),
       data_dateMs_cloudAt_ = data_dateMs_cloudAt_?.toUtc(),
       data_visibleToUserIds_changeAt_ =
           data_visibleToUserIds_changeAt_?.toUtc(),
       data_visibleToUserIds_cloudAt_ =
           data_visibleToUserIds_cloudAt_?.toUtc(),
       data_notifiedUserIds_changeAt_ = data_notifiedUserIds_changeAt_.toUtc(),
       data_notifiedUserIds_cloudAt_ =
           data_notifiedUserIds_cloudAt_?.toUtc();

  static DynamoNoteCommentChatDataEntityState fromJsonBase(
    Map<String, dynamic> json,
  ) =>
      _$DynamoNoteCommentChatDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_text', () => '');
    j.putIfAbsent('data_videoId', () => '');
    j.putIfAbsent('data_dateMs', () => 0);
    j.putIfAbsent('data_notifiedUserIds', () => <String>[]);
    return j;
  }

  factory DynamoNoteCommentChatDataEntityState.fromJson(
    Map<String, dynamic> json,
  ) =>
      deserializeWithUnknownFieldData(
        _$DynamoNoteCommentChatDataEntityStateFromJson,
        json,
        _$DynamoNoteCommentChatDataEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() => serializeWithUnknownFieldData(
        this,
        _$DynamoNoteCommentChatDataEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJsonBase() =>
      _$DynamoNoteCommentChatDataEntityStateToJson(this);
}
