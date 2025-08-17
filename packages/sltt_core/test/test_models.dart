// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/src/models/base_change_log_entry.dart';
import 'package:sltt_core/src/models/base_entity_state.dart';
import 'package:sltt_core/src/models/entity_type.dart';
import 'package:sltt_core/src/services/json_serialization_service.dart';

part 'test_models.g.dart';

/// Concrete implementation of BaseChangeLogEntry for testing
/// This is similar to the existing ChangeLogEntry but specifically for tests
@JsonSerializable()
class TestChangeLogEntry extends BaseChangeLogEntry {
  @override
  final int seq;

  TestChangeLogEntry({
    required String entityId,
    required EntityType entityType,
    required String domainId,
    required String domainType,
    required DateTime changeAt,
    required String cid,
    String storageId = 'local',
    required String changeBy,
    required Map<String, dynamic> data,
    required String operation,
    required Map<String, dynamic> operationInfo,
    required bool stateChanged,
    required Map<String, dynamic> unknown,
    int? dataSchemaRev,
    DateTime? cloudAt,
    int? schemaVersion,
    this.seq = 0,
  }) : super(
         storageId: storageId,
         domainType: domainType,
         domainId: domainId,
         entityType: entityType,
         operation: operation,
         stateChanged: stateChanged,
         operationInfo: operationInfo,
         changeAt: changeAt,
         entityId: entityId,
         data: data,
         dataSchemaRev: dataSchemaRev,
         cloudAt: cloudAt,
         changeBy: changeBy,
         cid: cid,
         schemaVersion: schemaVersion,
         unknown: unknown,
       );

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
@JsonSerializable(includeIfNull: true)
class TestEntityState extends BaseEntityState {
  final String data_nameLocal;

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
