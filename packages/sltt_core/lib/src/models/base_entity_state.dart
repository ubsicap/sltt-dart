// ignore_for_file: non_constant_identifier_names

import 'package:sltt_core/src/services/json_serialization_service.dart';

/// Base class for entity state storage with common metadata
/// This provides the core state schema common across all entity types
/// Backend-agnostic - no database-specific dependencies
abstract class BaseEntityState
    with HasUnknownField
    implements
        CoreEntityMetaData,
        CoreEntityDataFields,
        CoreChangeLogEntryFields {
  /// Primary key - entityId with entity type abbreviation
  @override
  String get entityId;
  set entityId(String v);

  /// Immutable - entity type enum
  @override
  String get entityType;
  set entityType(String v);

  /// Schema Version number for EntityState
  @override
  int? get schemaVersion;
  set schemaVersion(int? v);

  /// Any fields not read from json are put here for future field migration.
  /// Store unknown/data/operationInfo as compact JSON strings to remain
  /// storage-agnostic; provide Map getters via the HasUnknownField mixin.
  @override
  String get unknownJson;
  @override
  set unknownJson(String v);

  /// Current project ID
  String get change_domainId;
  set change_domainId(String v);

  /// Original (first) values for tracking entity creation
  String get change_domainId_orig_;
  set change_domainId_orig_(String v);

  /// Latest change timestamp
  @override
  DateTime get change_changeAt;
  set change_changeAt(DateTime v);

  /// First UTC change timestamp
  DateTime? get change_changeAt_orig_;
  set change_changeAt_orig_(DateTime? v);

  /// Latest change ID
  @override
  String get change_cid;
  set change_cid(String v);

  /// Original (first) change ID
  String get change_cid_orig_;
  set change_cid_orig_(String v);

  /// latest data schema revision (no need for _orig_)
  @override
  int? get change_dataSchemaRev;
  set change_dataSchemaRev(int? v);

  /// Latest cloud timestamp
  @override
  DateTime? get change_cloudAt;
  set change_cloudAt(DateTime? v);

  /// First UTC cloud timestamp
  DateTime? get change_cloudAt_orig_;
  set change_cloudAt_orig_(DateTime? v);

  /// Latest change author
  @override
  String get change_changeBy;
  set change_changeBy(String v);

  /// Original (first) change author
  String get change_changeBy_orig_;
  set change_changeBy_orig_(String v);

  /// --- Mutable fields with conflict resolution support ---

  /// Change tracking fields for conflict resolution
  /// Each mutable field has corresponding changeAt, cid, and changeBy fields
  /// todo?: append _orig_? for debugging

  /// rank - Used to sort in parent
  @override
  String? get data_rank;
  set data_rank(String? v);

  /// rank field conflict resolution
  @override
  int? get data_rank_dataSchemaRev_;
  set data_rank_dataSchemaRev_(int? v);
  @override
  DateTime? get data_rank_changeAt_;
  set data_rank_changeAt_(DateTime? v);
  @override
  String? get data_rank_cid_;
  set data_rank_cid_(String? v);
  @override
  String? get data_rank_changeBy_;
  set data_rank_changeBy_(String? v);
  @override
  DateTime? get data_rank_cloudAt_;
  set data_rank_cloudAt_(DateTime? v);

  /// Deletion status
  @override
  bool? get data_deleted;
  set data_deleted(bool? v);

  // deleted field conflict resolution
  @override
  int? get data_deleted_dataSchemaRev_;
  set data_deleted_dataSchemaRev_(int? v);
  @override
  DateTime? get data_deleted_changeAt_;
  set data_deleted_changeAt_(DateTime? v);
  @override
  String? get data_deleted_cid_;
  set data_deleted_cid_(String? v);
  @override
  String? get data_deleted_changeBy_;
  set data_deleted_changeBy_(String? v);
  @override
  DateTime? get data_deleted_cloudAt_;
  set data_deleted_cloudAt_(DateTime? v);

  @override
  String get data_parentId;
  set data_parentId(String v);

  @override
  /// parentId field conflict resolution
  int? get data_parentId_dataSchemaRev_;
  set data_parentId_dataSchemaRev_(int? v);
  @override
  DateTime get data_parentId_changeAt_;
  set data_parentId_changeAt_(DateTime v);
  @override
  String get data_parentId_cid_;
  set data_parentId_cid_(String v);
  @override
  String get data_parentId_changeBy_;
  set data_parentId_changeBy_(String v);
  @override
  DateTime? get data_parentId_cloudAt_;
  set data_parentId_cloudAt_(DateTime? v);

  BaseEntityState({
    required String entityId,
    required String entityType,
    int? schemaVersion,
    required String change_domainId,
    required String change_domainId_orig_,
    required DateTime change_changeAt,
    DateTime? change_changeAt_orig_,
    required String change_cid,
    required String change_cid_orig_,
    int? change_dataSchemaRev,
    DateTime? change_cloudAt,
    DateTime? change_cloudAt_orig_,
    required String change_changeBy,
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
    required String data_parentId,
    int? data_parentId_dataSchemaRev_,
    required DateTime data_parentId_changeAt_,
    required String data_parentId_cid_,
    required String data_parentId_changeBy_,
    DateTime? data_parentId_cloudAt_,
  });

  // Abstract methods to be implemented by concrete subclasses
  Map<String, dynamic> toJson();
}

mixin CoreEntityMetaData {
  String get entityId;
  String get entityType;
  int? get schemaVersion;
  String? get unknownJson;
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
  DateTime get change_changeAt;
  String get change_changeBy;
  String get change_cid;
  DateTime? get change_cloudAt;
  int? get change_dataSchemaRev;
}
