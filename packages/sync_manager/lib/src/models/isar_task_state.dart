// ignore_for_file: non_constant_identifier_names, prefer_initializing_formals

import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

import 'base_isar_entity_state.dart';

part 'isar_task_state.g.dart';

/// Isar collection for task entity state storage
@Collection()
@JsonSerializable(includeIfNull: true, checked: true)
class IsarTaskState extends BaseIsarEntityState {
  // Task-specific fields
  String data_nameLocal;
  DateTime data_nameLocal_changeAt_;
  String data_nameLocal_cid_;
  String data_nameLocal_changeBy_;
  DateTime? data_nameLocal_cloudAt_;
  int? data_nameLocal_dataSchemaRev_;

  IsarTaskState({
    super.id,
    super.entityType = 'task',
    required super.entityId,
    required super.unknownJson,
    required this.data_nameLocal,
    required this.data_nameLocal_changeAt_,
    required this.data_nameLocal_cid_,
    required this.data_nameLocal_changeBy_,
    this.data_nameLocal_cloudAt_,
    this.data_nameLocal_dataSchemaRev_,
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
  });

  factory IsarTaskState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$IsarTaskStateFromJson,
        json,
        _$IsarTaskStateToJson,
      );

  @override
  Map<String, dynamic> toJson() {
    return serializeWithUnknownFieldData(this, _$IsarTaskStateToJson);
  }
}
