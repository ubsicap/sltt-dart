// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/src/models/base_change_log_entry.dart';
import 'package:sltt_core/src/models/base_entity_state.dart';
import 'package:sltt_core/src/models/entity_type.dart';
import 'package:sltt_core/src/services/json_serialization_service.dart';

part 'test_models.g.dart';

/// Concrete test implementation of BaseChangeLogEntry
@JsonSerializable()
class TestChangeLogEntry extends BaseChangeLogEntry {
  TestChangeLogEntry({
    required super.entityId,
    required super.entityType,
    required super.domainId,
    required super.domainType,
    required super.changeAt,
    required super.cid,
    required super.changeBy,
    required super.data,
    required super.operation,
    required super.operationInfo,
    required super.stateChanged,
    required super.unknown,
    super.dataSchemaRev,
    super.cloudAt,
    super.schemaVersion,
    this.seq = 0,
  });

  @override
  final int seq;

  factory TestChangeLogEntry.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$TestChangeLogEntryFromJson,
        json,
        _$TestChangeLogEntryToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$TestChangeLogEntryToJson);
}

/// Concrete test implementation of BaseEntityState
@JsonSerializable()
class TestEntityState extends BaseEntityState {
  TestEntityState({
    required super.entityId,
    required super.entityType,
    required super.change_domainId,
    required super.change_domainId_orig_,
    required super.change_changeAt,
    required super.change_changeAt_orig_,
    required super.change_cid,
    required super.change_cid_orig_,
    super.change_dataSchemaRev,
    super.change_cloudAt,
    super.change_cloudAt_orig_,
    required super.change_changeBy,
    super.data_rank_dataSchemaRev,
    super.data_rank,
    super.data_rank_changeAt_,
    super.data_rank_cid_,
    super.data_rank_changeBy_,
    super.data_rank_cloudAt_,
    super.data_deleted,
    super.data_deleted_dataSchemaRev,
    super.data_deleted_changeAt_,
    super.data_deleted_cid_,
    super.data_deleted_changeBy_,
    super.data_deleted_cloudAt_,
    required super.data_parentId,
    required super.data_parentId_dataSchemaRev,
    required super.data_parentId_changeAt_,
    required super.data_parentId_cid_,
    required super.data_parentId_changeBy_,
    super.data_parentId_cloudAt_,
  });

  // Implement CoreChangeLogEntryFields getters
  @override
  DateTime? get changeAt => change_changeAt;

  @override
  String get changeBy => change_changeBy;

  @override
  String get cid => change_cid;

  @override
  String get dataSchemaRev => change_dataSchemaRev?.toString() ?? '0';

  @override
  DateTime? get cloudAt => change_cloudAt;

  // Implement CoreChangeLogEntryFields setter
  @override
  set changeAt(DateTime? value) {
    change_changeAt = value;
  }

  // Implement CoreEntityDataFields getters
  @override
  int? get data_deleted_dataSchemaRev_ => data_deleted_dataSchemaRev;

  @override
  int? get data_parentId_dataSchemaRev_ => data_parentId_dataSchemaRev;

  @override
  int? get data_rank_dataSchemaRev_ => data_rank_dataSchemaRev;

  factory TestEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$TestEntityStateFromJson,
        json,
        _$TestEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$TestEntityStateToJson);
}
