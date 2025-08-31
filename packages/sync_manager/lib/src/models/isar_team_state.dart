// ignore_for_file: non_constant_identifier_names, prefer_initializing_formals

import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

import 'base_isar_entity_state.dart';

part 'isar_team_state.g.dart';

/// Isar collection for team entity state storage
@Collection()
@JsonSerializable(includeIfNull: true, checked: true)
class IsarTeamState extends BaseIsarEntityState {
  // Team-specific fields following _meta_ convention
  String? data_name;
  int? data_name_dataSchemaRev_;
  DateTime? data_name_changeAt_;
  String? data_name_cid_;
  String? data_name_changeBy_;
  DateTime? data_name_cloudAt_;

  IsarTeamState({
    super.id,
    super.entityType = 'team',
    required super.entityId,
    required super.unknownJson,
    super.schemaVersion,
    required super.change_domainId,
    required super.change_domainId_orig_,
    required super.change_changeAt,
    required super.change_changeAt_orig_,
    required super.change_cid,
    required super.change_cid_orig_,
    super.change_dataSchemaRev,
    super.change_cloudAt,
    required super.change_changeBy,
    required super.change_changeBy_orig_,
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
    this.data_name,
    this.data_name_dataSchemaRev_,
    this.data_name_changeAt_,
    this.data_name_cid_,
    this.data_name_changeBy_,
    this.data_name_cloudAt_,
  });

  factory IsarTeamState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$IsarTeamStateFromJson,
        json,
        _$IsarTeamStateToJson,
      );

  @override
  Map<String, dynamic> toJson() {
    return serializeWithUnknownFieldData(this, _$IsarTeamStateToJson);
  }
}
