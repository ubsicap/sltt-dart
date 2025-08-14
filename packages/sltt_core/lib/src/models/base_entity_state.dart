// ignore_for_file: non_constant_identifier_names

import 'entity_type.dart';

/// Base class for entity state storage with common metadata
/// This provides the core state schema common across all entity types
/// Backend-agnostic - no database-specific dependencies
abstract class BaseEntityState {
  /// Primary key - entityId with entity type abbreviation
  late String entityId;

  /// Immutable - entity type enum
  late EntityType entityType;

  /// Latest change timestamp
  DateTime? change_changeAt;

  /// First UTC change timestamp
  DateTime? change_changeAt_orig_;

  String change_cid = ''; // Latest change ID
  String change_cid_orig_ = ''; // First change ID

  DateTime? change_cloudAt; // Latest cloud timestamp
  DateTime? change_cloudAt_orig_; // First UTC cloud timestamp

  String change_changeBy = ''; // Latest change author
  String change_changeBy_orig_ = ''; // First change author

  int? change_dataRev = 0;

  /// Mutable fields with conflict resolution support
  String? data_rank; // Used to sort in parent

  bool data_deleted = false; // Deletion status

  String data_parentId = ''; // Points to parent entity

  String data_projectId = ''; // Current project ID
  /// Original (first) values for tracking entity creation
  String data_projectId_orig_ = ''; // Original project ID

  /// Change tracking fields for conflict resolution
  /// Each mutable field has corresponding changeAt, cid, and changeBy fields

  // rank field tracking
  DateTime? data_rank_changeAt_;
  String data_rank_cid = '';
  String data_rank_changeBy_ = '';

  // deleted field tracking
  DateTime? data_deleted_changeAt_;
  String data_deleted_cid = '';
  String data_deleted_changeBy_ = '';

  // parentId field tracking
  DateTime? data_parentId_changeAt_;
  String data_parentId_cid = '';
  String data_parentId_changeBy_ = '';

  // projectId field tracking
  DateTime? data_projectId_changeAt_;
  String data_projectId_cid = '';
  String data_projectId_changeBy_ = '';

  BaseEntityState();
}

mixin CoreEntityMetaData {
  String get entityId;
  EntityType get entityType;
}

mixin CoreEntityDataFields {}

mixin CoreChangeLogEntryFields {
  DateTime? changeAt;
  String get changeBy;
  String get cid;
  DateTime? get cloudAt;
}
