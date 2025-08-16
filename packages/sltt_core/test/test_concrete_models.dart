// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/src/models/base_change_log_entry.dart';
import 'package:sltt_core/src/models/base_entity_state.dart';
import 'package:sltt_core/src/models/entity_type.dart';
import 'package:sltt_core/src/services/json_serialization_service.dart';

part 'test_concrete_models.g.dart';

/// Concrete implementation of BaseChangeLogEntry for testing
/// This is similar to the existing ChangeLogEntry but specifically for tests
@JsonSerializable()
class ConcreteChangeLogEntry extends BaseChangeLogEntry {
  @override
  final int seq;

  ConcreteChangeLogEntry({
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

  factory ConcreteChangeLogEntry.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$ConcreteChangeLogEntryFromJson,
        json,
        _$ConcreteChangeLogEntryToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$ConcreteChangeLogEntryToJson);
}

/// Concrete implementation of BaseEntityState for testing
/// This is similar to the existing EntityState but specifically for tests
@JsonSerializable(includeIfNull: true)
class ConcreteEntityState extends BaseEntityState {
  ConcreteEntityState({
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

  // Implement CoreEntityDataFields getters
  @override
  int? get data_deleted_dataSchemaRev_ => data_deleted_dataSchemaRev;

  @override
  int? get data_parentId_dataSchemaRev_ => data_parentId_dataSchemaRev;

  @override
  int? get data_rank_dataSchemaRev_ => data_rank_dataSchemaRev;

  factory ConcreteEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$ConcreteEntityStateFromJson,
        json,
        _$ConcreteEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() {
    final json = serializeWithUnknownFieldData(
      this,
      _$ConcreteEntityStateToJson,
    );
    // Remove null values for normal serialization
    return Map<String, dynamic>.fromEntries(
      json.entries.where((entry) => entry.value != null),
    );
  }
}
