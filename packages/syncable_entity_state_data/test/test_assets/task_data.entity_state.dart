// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// SyncableEntityStateDataGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: non_constant_identifier_names
library task_data_entity_state;

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'task_data.entity_state.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TaskDataEntityState extends BaseEntityState {
  // json config: required=true includeIfNull=true
  @override
  final String entityId;
  final String data_parentId;
  final int? data_parentId_dataSchemaRev_;
  final DateTime? data_parentId_changeAt_;
  final String? data_parentId_cid_;
  final String? data_parentId_changeBy_;
  final DateTime? data_parentId_cloudAt_;
  final bool? data_deleted;
  final int? data_deleted_dataSchemaRev_;
  final DateTime? data_deleted_changeAt_;
  final String? data_deleted_cid_;
  final String? data_deleted_changeBy_;
  final DateTime? data_deleted_cloudAt_;
  final String? data_rank;
  final int? data_rank_dataSchemaRev_;
  final DateTime? data_rank_changeAt_;
  final String? data_rank_cid_;
  final String? data_rank_changeBy_;
  final DateTime? data_rank_cloudAt_;
  final String data_nameLocal;
  final int? data_nameLocal_dataSchemaRev_;
  final DateTime? data_nameLocal_changeAt_;
  final String? data_nameLocal_cid_;
  final String? data_nameLocal_changeBy_;
  final DateTime? data_nameLocal_cloudAt_;
  TaskDataEntityState({
    required this.entityId,
    String? entityType, // optional override, defaults to inferred 'task'
    required super.change_domainId,
    required super.change_changeAt,
    required super.change_cid,
    required super.change_changeBy,
    required super.data_parentId,
    required super.data_parentId_changeAt_,
    required super.data_parentId_cid_,
    required super.data_parentId_changeBy_,
    required String unknownJson,
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
    required this.data_parentId,
    this.data_parentId_dataSchemaRev_,
    this.data_parentId_changeAt_,
    this.data_parentId_cid_,
    this.data_parentId_changeBy_,
    this.data_parentId_cloudAt_,
    required this.data_deleted,
    this.data_deleted_dataSchemaRev_,
    this.data_deleted_changeAt_,
    this.data_deleted_cid_,
    this.data_deleted_changeBy_,
    this.data_deleted_cloudAt_,
    required this.data_rank,
    this.data_rank_dataSchemaRev_,
    this.data_rank_changeAt_,
    this.data_rank_cid_,
    this.data_rank_changeBy_,
    this.data_rank_cloudAt_,
    required this.data_nameLocal,
    this.data_nameLocal_dataSchemaRev_,
    this.data_nameLocal_changeAt_,
    this.data_nameLocal_cid_,
    this.data_nameLocal_changeBy_,
    this.data_nameLocal_cloudAt_,
  }) : super(
          entityId: entityId,
          entityType: entityType ?? 'task',
          unknownJson: unknownJson,
          change_domainId_orig_: change_domainId,
          change_changeAt_orig_: change_changeAt,
          change_cid_orig_: change_cid,
          change_changeBy_orig_: change_changeBy,
          data_parentId_dataSchemaRev_: data_parentId_dataSchemaRev_,
          data_parentId_cloudAt_: data_parentId_cloudAt_,
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
