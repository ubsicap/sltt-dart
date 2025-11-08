// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'portion_translation.entity_state.dynamo.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
class DynamoPortionDataEntityState extends BaseEntityState {
  @override
  final String entityId;

  // data fields (mirror of PortionDataEntityState)
  final String data_name;
  final int? data_name_dataSchemaRev_;
  final DateTime data_name_changeAt_;
  final String? data_name_cid_;
  final String data_name_changeBy_;
  final DateTime? data_name_cloudAt_;
  final List<String> data_visibility;
  final int? data_visibility_dataSchemaRev_;
  final DateTime data_visibility_changeAt_;
  final String data_visibility_cid_;
  final String data_visibility_changeBy_;
  final DateTime? data_visibility_cloudAt_;

  DynamoPortionDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypePortion,
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
       data_visibility_changeAt_ = data_visibility_changeAt_.toUtc(),
       data_visibility_cloudAt_ = data_visibility_cloudAt_?.toUtc();

  static DynamoPortionDataEntityState fromJsonBase(Map<String, dynamic> json) =>
      _$DynamoPortionDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_name', () => '');
    j.putIfAbsent('data_visibility', () => <String>[]);
    return j;
  }

  factory DynamoPortionDataEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$DynamoPortionDataEntityStateFromJson,
        json,
        _$DynamoPortionDataEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$DynamoPortionDataEntityStateToJson);

  @override
  Map<String, dynamic> toJsonBase() =>
      _$DynamoPortionDataEntityStateToJson(this);
}
