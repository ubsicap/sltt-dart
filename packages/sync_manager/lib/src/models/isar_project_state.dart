// ignore_for_file: non_constant_identifier_names, prefer_initializing_formals

import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

import 'base_isar_entity_state.dart';

part 'isar_project_state.g.dart';

/// Isar collection for project entity state storage
@Collection()
@JsonSerializable()
class IsarProjectState extends BaseIsarEntityState {
  @override
  String entityType = 'project';

  // Project-specific fields
  String? data_nameLocal;
  int? data_nameLocal_dataSchemaRev_;
  DateTime? data_nameLocal_changeAt_;
  String? data_nameLocal_cid_;
  String? data_nameLocal_changeBy_;
  DateTime? data_nameLocal_cloudAt_;

  IsarProjectState({
    required super.entityId,
    super.entityType = 'project',
    this.data_nameLocal,
    this.data_nameLocal_dataSchemaRev_,
    this.data_nameLocal_changeAt_,
    this.data_nameLocal_cid_,
    this.data_nameLocal_changeBy_,
    this.data_nameLocal_cloudAt_,
    super.schemaVersion,
    required super.change_domainId,
    String? change_domainId_orig_,
    required super.change_changeAt,
    DateTime? change_changeAt_orig_,
    required super.change_cid,
    String? change_cid_orig_,
    super.change_dataSchemaRev,
    super.change_cloudAt,
    DateTime? change_cloudAt_orig_,
    required super.change_changeBy,
    String? change_changeBy_orig_,
    super.data_rank_dataSchemaRev_,
    super.data_rank,
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
    required super.data_parentId_dataSchemaRev_,
    required super.data_parentId_changeAt_,
    required super.data_parentId_cid_,
    required super.data_parentId_changeBy_,
    super.data_parentId_cloudAt_,
  }) : super(
         change_domainId_orig_: change_domainId_orig_ ?? change_domainId,
         change_changeAt_orig_: change_changeAt_orig_ ?? change_changeAt,
         change_cid_orig_: change_cid_orig_ ?? change_cid,
         change_cloudAt_orig_: change_cloudAt_orig_ ?? change_cloudAt,
         change_changeBy_orig_: change_changeBy_orig_ ?? change_changeBy,
       );

  factory IsarProjectState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$IsarProjectStateFromJson,
        json,
        _$IsarProjectStateToJson,
      );

  @override
  Map<String, dynamic> toJson() {
    return serializeWithUnknownFieldData(this, _$IsarProjectStateToJson);
  }
}
