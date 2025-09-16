// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// SyncableEntityStateDataGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

import 'task_data.dart';

part 'task_data.entity_state.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TaskDataEntityState extends BaseEntityState {
  // json config: required=true includeIfNull=true
  @override
  final String entityId;
  final String data_nameLocal;
  final int? data_nameLocal_dataSchemaRev_;
  final DateTime? data_nameLocal_changeAt_;
  final String? data_nameLocal_cid_;
  final String? data_nameLocal_changeBy_;
  final DateTime? data_nameLocal_cloudAt_;
  TaskDataEntityState({
    required this.entityId,
  required super.domainType,
    required super.change_domainId,
    required super.change_changeAt,
    required super.change_cid,
    required super.change_changeBy,
    required super.data_parentId,
    required super.data_parentId_changeAt_,
    required super.data_parentId_cid_,
    required super.data_parentId_changeBy_,
    // parentProp related meta (required to match BaseEntityState)
    required super.data_parentProp,
    super.data_parentProp_dataSchemaRev_,
    required super.data_parentProp_changeAt_,
    required super.data_parentProp_cid_,
    required super.data_parentProp_changeBy_,
    super.data_parentProp_cloudAt_,
  required super.unknownJson,
    super.change_dataSchemaRev,
    super.change_cloudAt,
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
    required this.data_nameLocal,
    this.data_nameLocal_dataSchemaRev_,
    this.data_nameLocal_changeAt_,
    this.data_nameLocal_cid_,
    this.data_nameLocal_changeBy_,
    this.data_nameLocal_cloudAt_,
  }) : super(
          entityId: entityId,
          entityType: 'task',
          change_domainId_orig_: change_domainId,
          change_changeAt_orig_: change_changeAt,
          change_cid_orig_: change_cid,
          change_changeBy_orig_: change_changeBy,
        );
  static TaskDataEntityState fromJsonBase(Map<String, dynamic> json) =>
      _$TaskDataEntityStateFromJson(json);
  Map<String, dynamic> toJsonBase() => _$TaskDataEntityStateToJson(this);
  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_parentId', () => '');
    j.putIfAbsent('data_deleted', () => false);
    j.putIfAbsent('data_rank', () => '');
    j.putIfAbsent('data_nameLocal', () => '');
    return j;
  }

  factory TaskDataEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$TaskDataEntityStateFromJson,
        json,
        _$TaskDataEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$TaskDataEntityStateToJson);
}

// Mapper back to the original data class
TaskData _TaskDataEntityStateToData(TaskDataEntityState s) => TaskData(
      parentId: s.data_parentId,
      deleted: s.data_deleted,
      rank: s.data_rank,
      nameLocal: s.data_nameLocal,
    );

extension TaskDataEntityStateDataExt on TaskDataEntityState {
  TaskData toData() => _TaskDataEntityStateToData(this);
}
