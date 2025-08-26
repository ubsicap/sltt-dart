// ignore_for_file: non_constant_identifier_names, prefer_initializing_formals

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/src/models/base_change_log_entry.dart';
import 'package:sltt_core/src/models/base_entity_state.dart';
import 'package:sltt_core/src/services/json_serialization_service.dart';

part 'test_models.g.dart';

/// Concrete implementation of BaseChangeLogEntry for testing
/// This is similar to the existing ChangeLogEntry but specifically for tests
@JsonSerializable(checked: true)
class TestChangeLogEntry extends BaseChangeLogEntry {
  @override
  final int seq;

  // Forwarding implementations to satisfy HasUnknownField contract.
  // No explicit overrides needed here; the base mixin and class provide
  // the JSON-string fields and helper methods. Keeping Map getters above
  // gives test code convenient access.

  TestChangeLogEntry({
    required super.entityId,
    required super.entityType,
    required super.domainId,
    required super.domainType,
    required super.changeAt,
    required super.cid,
    super.storageId = 'local',
    required super.changeBy,
    required super.dataJson,
    required super.operation,
    super.operationInfoJson,
    required super.stateChanged,
    super.unknownJson,
    super.dataSchemaRev,
    super.cloudAt,
    super.schemaVersion,
    this.seq = 0,
  }) : super();

  // Convenience constructor for tests that want to pass Maps instead of
  // pre-encoded JSON strings for data/operationInfo/unknown.
  TestChangeLogEntry.fromMaps({
    required super.entityId,
    required super.entityType,
    required super.domainId,
    required super.domainType,
    required super.changeAt,
    required super.cid,
    super.storageId = 'local',
    required super.changeBy,
    required super.data,
    required super.operation,
    super.operationInfo,
    required super.stateChanged,
    super.unknown,
    super.dataSchemaRev,
    super.cloudAt,
    super.schemaVersion,
    this.seq = 0,
  }) : super.fromJsonWithMaps();

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

/// Concrete implementation of BaseEntityState for testing
/// This is similar to the existing EntityState but specifically for tests
@JsonSerializable(includeIfNull: true, checked: true)
class TestEntityState extends BaseEntityState {
  final String data_nameLocal;
  // Concrete backing fields to satisfy BaseEntityState abstract accessors
  @override
  String entityId = '';
  @override
  String entityType = '';
  @override
  int? schemaVersion;
  @override
  String unknownJson = '{}';
  @override
  String change_domainId = '';
  @override
  late String change_domainId_orig_;
  @override
  DateTime change_changeAt = DateTime.fromMillisecondsSinceEpoch(0);
  @override
  late DateTime change_changeAt_orig_;
  @override
  String change_cid = '';
  @override
  late String change_cid_orig_;
  @override
  int? change_dataSchemaRev;
  @override
  DateTime? change_cloudAt;
  @override
  late DateTime? change_cloudAt_orig_;
  @override
  String change_changeBy = '';
  @override
  late String change_changeBy_orig_;

  @override
  String? data_rank;
  @override
  int? data_rank_dataSchemaRev_;
  @override
  DateTime? data_rank_changeAt_;
  @override
  String? data_rank_cid_;
  @override
  String? data_rank_changeBy_;
  @override
  DateTime? data_rank_cloudAt_;

  @override
  bool? data_deleted = false;
  @override
  int? data_deleted_dataSchemaRev_ = 0;
  @override
  DateTime? data_deleted_changeAt_;
  @override
  String? data_deleted_cid_ = '';
  @override
  String? data_deleted_changeBy_ = '';
  @override
  DateTime? data_deleted_cloudAt_;

  @override
  String data_parentId = '';
  @override
  int? data_parentId_dataSchemaRev_;
  @override
  DateTime data_parentId_changeAt_ = DateTime.fromMillisecondsSinceEpoch(0);
  @override
  String data_parentId_cid_ = '';
  @override
  String data_parentId_changeBy_ = '';
  @override
  DateTime? data_parentId_cloudAt_;
  // Do not shadow base JSON storage fields; use the base accessors via
  // the helper methods (getData/getOperationInfo) instead.

  TestEntityState({
    this.data_nameLocal = '',
    required super.entityId,
    required super.entityType,
    super.schemaVersion,
    required super.change_domainId,
    super.change_domainId_orig_,
    required super.change_changeAt,
    super.change_changeAt_orig_,
    required super.change_cid,
    super.change_cid_orig_,
    super.change_dataSchemaRev,
    super.change_cloudAt,
    super.change_cloudAt_orig_,
    required super.change_changeBy,
    int? data_rank_dataSchemaRev_,
    String? data_rank,
    DateTime? data_rank_changeAt_,
    String? data_rank_cid_,
    String? data_rank_changeBy_,
    DateTime? data_rank_cloudAt_,
    bool? data_deleted,
    int? data_deleted_dataSchemaRev_,
    DateTime? data_deleted_changeAt_,
    String? data_deleted_cid_,
    String? data_deleted_changeBy_,
    DateTime? data_deleted_cloudAt_,
    required super.data_parentId,
    required super.data_parentId_dataSchemaRev_,
    required super.data_parentId_changeAt_,
    required super.data_parentId_cid_,
    required super.data_parentId_changeBy_,
    super.data_parentId_cloudAt_,
  }) : entityId = entityId,
       entityType = entityType,
       schemaVersion = schemaVersion,
       change_domainId = change_domainId,
       change_domainId_orig_ = change_domainId_orig_ ?? change_domainId,
       change_changeAt = change_changeAt,
       change_changeAt_orig_ = change_changeAt_orig_ ?? change_changeAt,
       change_cid = change_cid,
       change_cid_orig_ = change_cid_orig_ ?? change_cid,
       change_dataSchemaRev = change_dataSchemaRev,
       change_cloudAt = change_cloudAt,
       change_cloudAt_orig_ = change_cloudAt_orig_ ?? change_cloudAt,
       change_changeBy = change_changeBy,
       data_rank_dataSchemaRev_ = data_rank_dataSchemaRev_,
       data_rank = data_rank,
       data_rank_changeAt_ = data_rank_changeAt_,
       data_rank_cid_ = data_rank_cid_,
       data_rank_changeBy_ = data_rank_changeBy_,
       data_rank_cloudAt_ = data_rank_cloudAt_,
       data_deleted = data_deleted,
       data_deleted_dataSchemaRev_ = data_deleted_dataSchemaRev_,
       data_deleted_changeAt_ = data_deleted_changeAt_,
       data_deleted_cid_ = data_deleted_cid_,
       data_deleted_changeBy_ = data_deleted_changeBy_,
       data_deleted_cloudAt_ = data_deleted_cloudAt_,
       data_parentId = data_parentId,
       data_parentId_dataSchemaRev_ = data_parentId_dataSchemaRev_,
       data_parentId_changeAt_ = data_parentId_changeAt_,
       data_parentId_cid_ = data_parentId_cid_,
       data_parentId_changeBy_ = data_parentId_changeBy_,
       data_parentId_cloudAt_ = data_parentId_cloudAt_;

  factory TestEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$TestEntityStateFromJson,
        json,
        _$TestEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() {
    final json = serializeWithUnknownFieldData(this, _$TestEntityStateToJson);
    // Remove null values for normal serialization
    return Map<String, dynamic>.fromEntries(
      json.entries.where((entry) => entry.value != null),
    );
  }
}
