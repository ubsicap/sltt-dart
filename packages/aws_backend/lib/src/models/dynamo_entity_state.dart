// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'dynamo_entity_state.g.dart';

@JsonSerializable(includeIfNull: true, checked: true)
class DynamoEntityState extends BaseEntityState {
  @override
  final String entityId;

  DynamoEntityState({
    required this.entityId,
    required super.entityType,
    required super.domainType,
    super.schemaVersion,
    required super.unknownJson,
    required super.change_domainId,
    required super.change_domainId_orig_,
    required super.change_changeAt,
    required super.change_changeAt_orig_,
    super.change_dataSchemaRev,
    super.change_cloudAt,
    required super.change_cid,
    required super.change_cid_orig_,
    required super.change_changeBy,
    required super.change_changeBy_orig_,
    super.data_rank,
    super.data_rank_dataSchemaRev_,
    super.data_rank_changeAt_,
    super.data_rank_cid_,
    super.data_rank_changeBy_,
    super.data_rank_cloudAt_,
    super.data_deleted,
    super.data_deleted_dataSchemaRev_,
    super.data_deleted_changeAt_,
    super.data_deleted_cid_,
    super.data_deleted_changeBy_,
    super.data_deleted_cloudAt_,
    required super.data_parentId,
    super.data_parentId_dataSchemaRev_,
    required super.data_parentId_changeAt_,
    required super.data_parentId_cid_,
    required super.data_parentId_changeBy_,
    super.data_parentId_cloudAt_,
    required super.data_parentProp,
    super.data_parentProp_dataSchemaRev_,
    required super.data_parentProp_changeAt_,
    required super.data_parentProp_cid_,
    required super.data_parentProp_changeBy_,
    super.data_parentProp_cloudAt_,
  }) : super(entityId: entityId);

  factory DynamoEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$DynamoEntityStateFromJson,
        json,
        _$DynamoEntityStateToJson,
      );

  factory DynamoEntityState.fromJsonBase(Map<String, dynamic> json) =>
      _$DynamoEntityStateFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$DynamoEntityStateToJson);

  Map<String, dynamic> toJsonBase() => _$DynamoEntityStateToJson(this);
}
