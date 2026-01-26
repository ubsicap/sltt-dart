// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'video_translation.entity_state.dynamo.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
class DynamoVideoDataEntityState extends BaseEntityState {
  @override
  final String entityId;

  // data fields (mirror of VideoTranslationData)
  final String data_name;
  final int? data_name_dataSchemaRev_;
  final DateTime data_name_changeAt_;
  final String? data_name_cid_;
  final String data_name_changeBy_;
  final DateTime? data_name_cloudAt_;

  final String data_storedFilename;
  final int? data_storedFilename_dataSchemaRev_;
  final DateTime data_storedFilename_changeAt_;
  final String? data_storedFilename_cid_;
  final String data_storedFilename_changeBy_;
  final DateTime? data_storedFilename_cloudAt_;

  final int data_durationMs;
  final int? data_durationMs_dataSchemaRev_;
  final DateTime data_durationMs_changeAt_;
  final String? data_durationMs_cid_;
  final String data_durationMs_changeBy_;
  final DateTime? data_durationMs_cloudAt_;

  final List<String> data_visibility;
  final int? data_visibility_dataSchemaRev_;
  final DateTime data_visibility_changeAt_;
  final String data_visibility_cid_;
  final String data_visibility_changeBy_;
  final DateTime? data_visibility_cloudAt_;

  DynamoVideoDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypeVideo,
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
    required this.data_name,
    this.data_name_dataSchemaRev_,
    required DateTime data_name_changeAt_,
    this.data_name_cid_,
    required this.data_name_changeBy_,
    DateTime? data_name_cloudAt_,
    required this.data_storedFilename,
    this.data_storedFilename_dataSchemaRev_,
    required DateTime data_storedFilename_changeAt_,
    this.data_storedFilename_cid_,
    required this.data_storedFilename_changeBy_,
    DateTime? data_storedFilename_cloudAt_,
    required this.data_durationMs,
    this.data_durationMs_dataSchemaRev_,
    required DateTime data_durationMs_changeAt_,
    this.data_durationMs_cid_,
    required this.data_durationMs_changeBy_,
    DateTime? data_durationMs_cloudAt_,
    required this.data_visibility,
    this.data_visibility_dataSchemaRev_,
    required DateTime data_visibility_changeAt_,
    required this.data_visibility_cid_,
    required this.data_visibility_changeBy_,
    DateTime? data_visibility_cloudAt_,
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
  }) : data_name_changeAt_ = data_name_changeAt_.toUtc(),
       data_name_cloudAt_ = data_name_cloudAt_?.toUtc(),
       data_storedFilename_changeAt_ = data_storedFilename_changeAt_.toUtc(),
       data_storedFilename_cloudAt_ = data_storedFilename_cloudAt_?.toUtc(),
       data_durationMs_changeAt_ = data_durationMs_changeAt_.toUtc(),
       data_durationMs_cloudAt_ = data_durationMs_cloudAt_?.toUtc(),
       data_visibility_changeAt_ = data_visibility_changeAt_.toUtc(),
       data_visibility_cloudAt_ = data_visibility_cloudAt_?.toUtc();

  static DynamoVideoDataEntityState fromJsonBase(Map<String, dynamic> json) =>
      _$DynamoVideoDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_name', () => '');
    j.putIfAbsent('data_storedFilename', () => '');
    j.putIfAbsent('data_durationMs', () => 0);
    j.putIfAbsent('data_visibility', () => <String>[]);
    return j;
  }

  factory DynamoVideoDataEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$DynamoVideoDataEntityStateFromJson,
        json,
        _$DynamoVideoDataEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$DynamoVideoDataEntityStateToJson);

  @override
  Map<String, dynamic> toJsonBase() => _$DynamoVideoDataEntityStateToJson(this);
}
