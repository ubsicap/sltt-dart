// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/src/services/json_serialization_service.dart';

import 'entity_type.dart';

part 'base_entity_state.g.dart';

/// Base class for entity state storage with common metadata
/// This provides the core state schema common across all entity types
/// Backend-agnostic - no database-specific dependencies
@JsonSerializable()
abstract class BaseEntityState
    implements
        CoreEntityMetaData,
        CoreEntityDataFields,
        CoreChangeLogEntryFields,
        HasUnknownField {
  /// Primary key - entityId with entity type abbreviation
  @override
  String entityId;

  /// Immutable - entity type enum
  @override
  EntityType entityType;

  /// Schema Version number for EntityState
  @override
  int? schemaVersion;

  /// Any fields not read from json are put here for future field migration
  /// This will hold any unmapped fields
  @override
  Map<String, dynamic> unknown = {};

  /// Current project ID
  String change_domainId = '';

  /// Original (first) values for tracking entity creation
  String change_domainId_orig_ = '';

  /// Latest change timestamp
  DateTime? change_changeAt;

  /// First UTC change timestamp
  DateTime? change_changeAt_orig_;

  /// Latest change ID
  String change_cid = '';

  /// Original (first) change ID
  String change_cid_orig_ = '';

  /// latest data schema revision (no need for _orig_)
  int? change_dataSchemaRev;

  /// Latest cloud timestamp
  DateTime? change_cloudAt;

  /// First UTC cloud timestamp
  DateTime? change_cloudAt_orig_;

  /// Latest change author
  String change_changeBy = '';

  /// Original (first) change author
  String change_changeBy_orig_ = '';

  /// --- Mutable fields with conflict resolution support ---

  /// Change tracking fields for conflict resolution
  /// Each mutable field has corresponding changeAt, cid, and changeBy fields
  /// todo?: append _orig_? for debugging

  /// rank - Used to sort in parent
  @override
  String? data_rank;

  /// rank field conflict resolution
  int? data_rank_dataSchemaRev;
  @override
  DateTime? data_rank_changeAt_;
  @override
  String? data_rank_cid_;
  @override
  String? data_rank_changeBy_;
  @override
  DateTime? data_rank_cloudAt_;

  /// Deletion status
  @override
  bool? data_deleted = false;

  // deleted field conflict resolution
  int? data_deleted_dataSchemaRev;
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

  /// parentId field conflict resolution
  int? data_parentId_dataSchemaRev;
  @override
  DateTime data_parentId_changeAt_;
  @override
  String data_parentId_cid_ = '';
  @override
  String data_parentId_changeBy_ = '';
  @override
  DateTime? data_parentId_cloudAt_;

  BaseEntityState({
    required this.entityId,
    required this.entityType,
    required this.change_domainId,
    required this.change_domainId_orig_,
    required this.change_changeAt,
    required this.change_changeAt_orig_,
    required this.change_cid,
    required this.change_cid_orig_,
    this.change_dataSchemaRev,
    this.change_cloudAt,
    this.change_cloudAt_orig_,
    required this.change_changeBy,
    this.data_rank_dataSchemaRev,
    this.data_rank,
    this.data_rank_changeAt_,
    this.data_rank_cid_,
    this.data_rank_changeBy_,
    this.data_rank_cloudAt_,
    this.data_deleted,
    this.data_deleted_dataSchemaRev,
    this.data_deleted_changeAt_,
    this.data_deleted_cid_,
    this.data_deleted_changeBy_,
    this.data_deleted_cloudAt_,
    required this.data_parentId,
    required this.data_parentId_dataSchemaRev,
    required this.data_parentId_changeAt_,
    required this.data_parentId_cid_,
    required this.data_parentId_changeBy_,
    this.data_parentId_cloudAt_,
  });

  factory BaseEntityState.fromJson(Map<String, dynamic> json) {
    final baseEntityState = deserializeWithUnknownFieldData(
      _$BaseEntityStateFromJson,
      json,
      _$BaseEntityStateToJson,
    );
    return baseEntityState;
  }

  Map<String, dynamic> toJson() {
    final json = serializeWithUnknownFieldData(this, _$BaseEntityStateToJson);
    return json;
  }
}

mixin CoreEntityMetaData {
  String get entityId;
  EntityType get entityType;
  int? get schemaVersion;
  Map<String, dynamic> get unknown;
}

mixin CoreEntityDataFields {
  String? get data_rank;
  int? get data_rank_dataSchemaRev_;
  DateTime? get data_rank_changeAt_;
  String? get data_rank_cid_;
  String? get data_rank_changeBy_;
  DateTime? get data_rank_cloudAt_;

  bool? get data_deleted;
  int? get data_deleted_dataSchemaRev_;
  DateTime? get data_deleted_changeAt_;
  String? get data_deleted_cid_;
  String? get data_deleted_changeBy_;
  DateTime? get data_deleted_cloudAt_;

  String get data_parentId;
  int? get data_parentId_dataSchemaRev_;
  DateTime get data_parentId_changeAt_;
  String get data_parentId_cid_;
  String get data_parentId_changeBy_;
  DateTime? get data_parentId_cloudAt_;
}

mixin CoreChangeLogEntryFields {
  DateTime? changeAt;
  String get changeBy;
  String get cid;
  String get dataSchemaRev;
  DateTime? get cloudAt;
}
