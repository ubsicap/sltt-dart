// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/src/models/base_change_log_entry.dart';
import 'package:sltt_core/src/models/base_entity_state.dart';
import 'package:sltt_core/src/models/entity_type.dart';
import 'package:sltt_core/src/services/json_serialization_service.dart';
import 'package:sltt_core/src/services/client_id_service.dart';

part 'test_models.g.dart';

/// Concrete implementation of BaseChangeLogEntry for testing
/// This is similar to the existing ChangeLogEntry but specifically for tests
@JsonSerializable(checked: true)
class TestChangeLogEntry extends BaseChangeLogEntry {
  @override
  final int seq;
  // Provide concrete clientId to satisfy ImmutableFields contract.
  @override
  final String clientId;

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
    String? clientId,
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
  }) : clientId = clientId ?? ClientIdService.clientId;

  // Convenience constructor for tests that want to pass Maps instead of
  // pre-encoded JSON strings for data/operationInfo/unknown.
  TestChangeLogEntry.fromMaps({
    required super.entityId,
    required super.entityType,
    required super.domainId,
    required super.domainType,
    required super.changeAt,
    required super.cid,
    String? clientId,
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
  }) : clientId = clientId ?? ClientIdService.clientId,
       super.fromJsonWithMaps();

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
  // Do not shadow base JSON storage fields; use the base accessors via
  // the helper methods (getData/getOperationInfo) instead.

  TestEntityState({
    this.data_nameLocal = '',
    required super.entityId,
    required super.entityType,
    super.schemaVersion,
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
