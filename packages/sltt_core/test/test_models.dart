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

  @override
  String cid;

  // Forwarding implementations to satisfy HasUnknownField contract.
  // No explicit overrides needed here; the base mixin and class provide
  // the JSON-string fields and helper methods. Keeping Map getters above
  // gives test code convenient access.

  TestChangeLogEntry({
    required this.cid,
    required super.entityId,
    required super.entityType,
    required super.domainId,
    required super.domainType,
    required super.changeAt,
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
  @override
  String entityId;

  TestEntityState({
    required this.data_nameLocal,
    required this.entityId,
    required super.entityType,
    super.schemaVersion,
    required super.unknownJson,
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
    super.data_parentId_dataSchemaRev_,
    required super.data_parentId_changeAt_,
    required super.data_parentId_cid_,
    required super.data_parentId_changeBy_,
    super.data_parentId_cloudAt_,
  }) : super(entityId: entityId);

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
