// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'note.entity_state.dynamo.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
class DynamoNoteDataEntityState extends BaseEntityState {
  @override
  final String entityId;

  // data fields (mirror of NoteData)
  final String data_title;
  final int? data_title_dataSchemaRev_;
  final DateTime data_title_changeAt_;
  final String? data_title_cid_;
  final String data_title_changeBy_;
  final DateTime? data_title_cloudAt_;

  final String? data_videoCommentId;
  final int? data_videoCommentId_dataSchemaRev_;
  final DateTime data_videoCommentId_changeAt_;
  final String? data_videoCommentId_cid_;
  final String data_videoCommentId_changeBy_;
  final DateTime? data_videoCommentId_cloudAt_;

  final String? data_textComment;
  final int? data_textComment_dataSchemaRev_;
  final DateTime data_textComment_changeAt_;
  final String? data_textComment_cid_;
  final String data_textComment_changeBy_;
  final DateTime? data_textComment_cloudAt_;

  final int data_markerColorValue;
  final int? data_markerColorValue_dataSchemaRev_;
  final DateTime data_markerColorValue_changeAt_;
  final String? data_markerColorValue_cid_;
  final String data_markerColorValue_changeBy_;
  final DateTime? data_markerColorValue_cloudAt_;

  final String data_markerShape;
  final int? data_markerShape_dataSchemaRev_;
  final DateTime data_markerShape_changeAt_;
  final String? data_markerShape_cid_;
  final String data_markerShape_changeBy_;
  final DateTime? data_markerShape_cloudAt_;

  final String data_markerDescription;
  final int? data_markerDescription_dataSchemaRev_;
  final DateTime data_markerDescription_changeAt_;
  final String? data_markerDescription_cid_;
  final String data_markerDescription_changeBy_;
  final DateTime? data_markerDescription_cloudAt_;

  final int data_positionMs;
  final int? data_positionMs_dataSchemaRev_;
  final DateTime data_positionMs_changeAt_;
  final String? data_positionMs_cid_;
  final String data_positionMs_changeBy_;
  final DateTime? data_positionMs_cloudAt_;

  final String data_resolution;
  final int? data_resolution_dataSchemaRev_;
  final DateTime data_resolution_changeAt_;
  final String? data_resolution_cid_;
  final String data_resolution_changeBy_;
  final DateTime? data_resolution_cloudAt_;

  DynamoNoteDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypeNote,
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
    required this.data_title,
    this.data_title_dataSchemaRev_,
    required DateTime data_title_changeAt_,
    this.data_title_cid_,
    required this.data_title_changeBy_,
    DateTime? data_title_cloudAt_,
    this.data_videoCommentId,
    this.data_videoCommentId_dataSchemaRev_,
    required DateTime data_videoCommentId_changeAt_,
    this.data_videoCommentId_cid_,
    required this.data_videoCommentId_changeBy_,
    DateTime? data_videoCommentId_cloudAt_,
    this.data_textComment,
    this.data_textComment_dataSchemaRev_,
    required DateTime data_textComment_changeAt_,
    this.data_textComment_cid_,
    required this.data_textComment_changeBy_,
    DateTime? data_textComment_cloudAt_,
    required this.data_markerColorValue,
    this.data_markerColorValue_dataSchemaRev_,
    required DateTime data_markerColorValue_changeAt_,
    this.data_markerColorValue_cid_,
    required this.data_markerColorValue_changeBy_,
    DateTime? data_markerColorValue_cloudAt_,
    required this.data_markerShape,
    this.data_markerShape_dataSchemaRev_,
    required DateTime data_markerShape_changeAt_,
    this.data_markerShape_cid_,
    required this.data_markerShape_changeBy_,
    DateTime? data_markerShape_cloudAt_,
    required this.data_markerDescription,
    this.data_markerDescription_dataSchemaRev_,
    required DateTime data_markerDescription_changeAt_,
    this.data_markerDescription_cid_,
    required this.data_markerDescription_changeBy_,
    DateTime? data_markerDescription_cloudAt_,
    required this.data_positionMs,
    this.data_positionMs_dataSchemaRev_,
    required DateTime data_positionMs_changeAt_,
    this.data_positionMs_cid_,
    required this.data_positionMs_changeBy_,
    DateTime? data_positionMs_cloudAt_,
    required this.data_resolution,
    this.data_resolution_dataSchemaRev_,
    required DateTime data_resolution_changeAt_,
    this.data_resolution_cid_,
    required this.data_resolution_changeBy_,
    DateTime? data_resolution_cloudAt_,
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
  }) : data_title_changeAt_ = data_title_changeAt_.toUtc(),
       data_title_cloudAt_ = data_title_cloudAt_?.toUtc(),
       data_videoCommentId_changeAt_ = data_videoCommentId_changeAt_.toUtc(),
       data_videoCommentId_cloudAt_ = data_videoCommentId_cloudAt_?.toUtc(),
       data_textComment_changeAt_ = data_textComment_changeAt_.toUtc(),
       data_textComment_cloudAt_ = data_textComment_cloudAt_?.toUtc(),
       data_markerColorValue_changeAt_ = data_markerColorValue_changeAt_
           .toUtc(),
       data_markerColorValue_cloudAt_ = data_markerColorValue_cloudAt_?.toUtc(),
       data_markerShape_changeAt_ = data_markerShape_changeAt_.toUtc(),
       data_markerShape_cloudAt_ = data_markerShape_cloudAt_?.toUtc(),
       data_markerDescription_changeAt_ = data_markerDescription_changeAt_
           .toUtc(),
       data_markerDescription_cloudAt_ = data_markerDescription_cloudAt_
           ?.toUtc(),
       data_positionMs_changeAt_ = data_positionMs_changeAt_.toUtc(),
       data_positionMs_cloudAt_ = data_positionMs_cloudAt_?.toUtc(),
       data_resolution_changeAt_ = data_resolution_changeAt_.toUtc(),
       data_resolution_cloudAt_ = data_resolution_cloudAt_?.toUtc();

  static DynamoNoteDataEntityState fromJsonBase(Map<String, dynamic> json) =>
      _$DynamoNoteDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_title', () => '');
    j.putIfAbsent('data_markerColorValue', () => 0);
    j.putIfAbsent('data_markerShape', () => '');
    j.putIfAbsent('data_markerDescription', () => '');
    j.putIfAbsent('data_positionMs', () => 0);
    j.putIfAbsent('data_resolution', () => '');
    return j;
  }

  factory DynamoNoteDataEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$DynamoNoteDataEntityStateFromJson,
        json,
        _$DynamoNoteDataEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$DynamoNoteDataEntityStateToJson);

  @override
  Map<String, dynamic> toJsonBase() => _$DynamoNoteDataEntityStateToJson(this);
}
