// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'marker.entity_state.dynamo.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
class DynamoMarkerDataEntityState extends BaseEntityState {
  @override
  final String entityId;

  // data fields (mirror of MarkerData)
  final int data_colorValue;
  final int? data_colorValue_dataSchemaRev_;
  final DateTime data_colorValue_changeAt_;
  final String? data_colorValue_cid_;
  final String data_colorValue_changeBy_;
  final DateTime? data_colorValue_cloudAt_;

  final String data_shape;
  final int? data_shape_dataSchemaRev_;
  final DateTime data_shape_changeAt_;
  final String? data_shape_cid_;
  final String data_shape_changeBy_;
  final DateTime? data_shape_cloudAt_;

  final String data_description;
  final int? data_description_dataSchemaRev_;
  final DateTime data_description_changeAt_;
  final String? data_description_cid_;
  final String data_description_changeBy_;
  final DateTime? data_description_cloudAt_;
  final String? data_replacementId;
  final int? data_replacementId_dataSchemaRev_;
  final DateTime? data_replacementId_changeAt_;
  final String? data_replacementId_cid_;
  final String? data_replacementId_changeBy_;
  final DateTime? data_replacementId_cloudAt_;

  DynamoMarkerDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypeMarker,
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
    required this.data_colorValue,
    this.data_colorValue_dataSchemaRev_,
    required DateTime data_colorValue_changeAt_,
    this.data_colorValue_cid_,
    required this.data_colorValue_changeBy_,
    DateTime? data_colorValue_cloudAt_,
    required this.data_shape,
    this.data_shape_dataSchemaRev_,
    required DateTime data_shape_changeAt_,
    this.data_shape_cid_,
    required this.data_shape_changeBy_,
    DateTime? data_shape_cloudAt_,
    required this.data_description,
    this.data_description_dataSchemaRev_,
    required DateTime data_description_changeAt_,
    this.data_description_cid_,
    required this.data_description_changeBy_,
    DateTime? data_description_cloudAt_,
    this.data_replacementId,
    this.data_replacementId_dataSchemaRev_,
    DateTime? data_replacementId_changeAt_,
    this.data_replacementId_cid_,
    this.data_replacementId_changeBy_,
    DateTime? data_replacementId_cloudAt_,
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
  }) : data_colorValue_changeAt_ = data_colorValue_changeAt_.toUtc(),
       data_colorValue_cloudAt_ = data_colorValue_cloudAt_?.toUtc(),
       data_shape_changeAt_ = data_shape_changeAt_.toUtc(),
       data_shape_cloudAt_ = data_shape_cloudAt_?.toUtc(),
       data_description_changeAt_ = data_description_changeAt_.toUtc(),
       data_description_cloudAt_ = data_description_cloudAt_?.toUtc(),
       data_replacementId_changeAt_ = data_replacementId_changeAt_?.toUtc(),
       data_replacementId_cloudAt_ = data_replacementId_cloudAt_?.toUtc();

  static DynamoMarkerDataEntityState fromJsonBase(Map<String, dynamic> json) =>
      _$DynamoMarkerDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_colorValue', () => 0);
    j.putIfAbsent('data_shape', () => '');
    j.putIfAbsent('data_description', () => '');
    return j;
  }

  factory DynamoMarkerDataEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$DynamoMarkerDataEntityStateFromJson,
        json,
        _$DynamoMarkerDataEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$DynamoMarkerDataEntityStateToJson);

  @override
  Map<String, dynamic> toJsonBase() =>
      _$DynamoMarkerDataEntityStateToJson(this);
}
