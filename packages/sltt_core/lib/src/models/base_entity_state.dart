// ignore_for_file: non_constant_identifier_names

import 'package:sltt_core/src/services/json_serialization_service.dart';

/// Base class for entity state storage with common metadata
/// This provides the core state schema common across all entity types
/// Backend-agnostic - no database-specific dependencies
abstract class BaseEntityState
    with HasUnknownField
    implements
        CoreEntityMetaData,
        CoreEntityStateDataFields,
        CoreChangeLogEntryFields,
        CoreChangeLogEntryOriginalFields {
  /// implement entityId in sub-class to allow @index annotation
  // String entityId;

  // keep the public contract
  @override
  final String entityType;
  @override
  final String domainType;

  @override
  String unknownJson;
  @override
  final int? schemaVersion;
  final String change_domainId;
  @override
  final String change_domainId_orig_;
  @override
  final DateTime change_changeAt;
  @override
  final DateTime change_changeAt_orig_;
  @override
  @UtcDateTimeConverter()
  final DateTime change_storedAt;
  @override
  @UtcDateTimeConverter()
  final DateTime change_storedAt_orig_;
  @override
  final String change_cid;
  @override
  final String change_cid_orig_;
  @override
  final int? change_dataSchemaRev;
  @override
  final DateTime? change_cloudAt;
  @override
  final String change_changeBy;
  @override
  final String change_changeBy_orig_;
  @override
  final String? data_rank;
  @override
  final int? data_rank_dataSchemaRev_;
  @override
  final DateTime? data_rank_changeAt_;
  @override
  final String? data_rank_cid_;
  @override
  final String? data_rank_changeBy_;
  @override
  final DateTime? data_rank_cloudAt_;
  @override
  final bool? data_deleted;
  @override
  final int? data_deleted_dataSchemaRev_;
  @override
  final DateTime? data_deleted_changeAt_;
  @override
  final String? data_deleted_cid_;
  @override
  final String? data_deleted_changeBy_;
  @override
  final DateTime? data_deleted_cloudAt_;
  @override
  final String data_parentId;
  @override
  final int? data_parentId_dataSchemaRev_;
  @override
  final DateTime data_parentId_changeAt_;
  @override
  final String data_parentId_cid_;
  @override
  final String data_parentId_changeBy_;
  @override
  final DateTime? data_parentId_cloudAt_;
  @override
  final String data_parentProp;
  @override
  final int? data_parentProp_dataSchemaRev_;
  @override
  final DateTime data_parentProp_changeAt_;
  @override
  final String data_parentProp_cid_;
  @override
  final String data_parentProp_changeBy_;
  @override
  final DateTime? data_parentProp_cloudAt_;

  BaseEntityState({
    required this.entityType,
    required this.domainType,
    this.schemaVersion,
    required String unknownJson,
    required this.change_domainId,
    required String change_domainId_orig_,
    required this.change_changeAt,
    required DateTime change_changeAt_orig_,
    required this.change_storedAt,
    required DateTime change_storedAt_orig_,
    required this.change_cid,
    required String change_cid_orig_,
    this.change_dataSchemaRev,
    this.change_cloudAt,
    required this.change_changeBy,
    required String change_changeBy_orig_,
    this.data_rank_dataSchemaRev_,
    this.data_rank,
    this.data_rank_changeAt_,
    this.data_rank_cid_,
    this.data_rank_changeBy_,
    this.data_rank_cloudAt_,
    this.data_deleted,
    this.data_deleted_dataSchemaRev_,
    this.data_deleted_changeAt_,
    this.data_deleted_cid_,
    this.data_deleted_changeBy_,
    this.data_deleted_cloudAt_,
    required this.data_parentId,
    this.data_parentId_dataSchemaRev_,
    required this.data_parentId_changeAt_,
    required this.data_parentId_cid_,
    required this.data_parentId_changeBy_,
    this.data_parentId_cloudAt_,
    required this.data_parentProp,
    this.data_parentProp_dataSchemaRev_,
    required this.data_parentProp_changeAt_,
    required this.data_parentProp_cid_,
    required this.data_parentProp_changeBy_,
    this.data_parentProp_cloudAt_,
  }) : unknownJson = JsonUtils.normalize(unknownJson),
       change_domainId_orig_ = BaseEntityState.normalizeOrigString(
         change_domainId_orig_,
         change_domainId,
       ),
       change_changeAt_orig_ = BaseEntityState.normalizeOrigDateTime(
         change_changeAt_orig_,
         change_changeAt,
       ),
       change_storedAt_orig_ = BaseEntityState.normalizeOrigDateTime(
         change_storedAt_orig_,
         change_storedAt,
       ),
       change_cid_orig_ = BaseEntityState.normalizeOrigString(
         change_cid_orig_,
         change_cid,
       ),
       change_changeBy_orig_ = BaseEntityState.normalizeOrigString(
         change_changeBy_orig_,
         change_changeBy,
       );

  // Abstract methods to be implemented by concrete subclasses
  Map<String, dynamic> toJson();
  Map<String, dynamic> toJsonBase();

  // Static helper methods for _orig_ field initialization
  static String normalizeOrigString(String? orig, String current) {
    if (orig == null) {
      return current;
    }
    return orig.isEmpty == true ? current : orig;
  }

  static DateTime defaultOrigDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(0).toUtc();
  }

  static DateTime normalizeOrigDateTime(DateTime? orig, DateTime current) {
    if (orig == null) {
      return current;
    }
    return orig.isAtSameMomentAs(defaultOrigDateTime()) == true
        ? current
        : orig;
  }

  /// Determine storedAt value for change entries.
  /// Preference order:
  /// 1) explicit storedAt (orig param)
  /// 2) cloudAt (if present)
  /// 3) changeAt (fallback)
  static DateTime normalizeStoredAt(
    DateTime? storedAt,
    DateTime? cloudAt,
    DateTime changeAt,
  ) {
    if (storedAt != null) return storedAt.toUtc();
    if (cloudAt != null) return cloudAt.toUtc();
    return changeAt.toUtc();
  }

  /// Similar to normalizeStoredAt but intended for initializing _orig_ fields
  /// where the provided orig value may be null or a default sentinel.
  static DateTime normalizeOrigStoredAt(
    DateTime? origStoredAt,
    DateTime? cloudAt,
    DateTime changeAt,
  ) {
    // If an explicit orig storedAt was provided, use it. Otherwise follow
    // the same fallback order as normalizeStoredAt.
    if (origStoredAt != null) return origStoredAt.toUtc();
    if (cloudAt != null) return cloudAt.toUtc();
    return changeAt.toUtc();
  }

  static DateTime? normalizeOrigDateTimeNullable(
    DateTime? orig,
    DateTime? current,
  ) {
    return orig ?? current;
  }
}

mixin CoreEntityMetaData {
  String get entityId;
  String get entityType;
  String get domainType;

  /// although change_storedAt originates from change log entry
  /// it's different from the other change_ fields in that it's not
  /// necessarily connected to the same changset cid.
  /// It should get bumped for every change that gets merged to state,
  /// even if it isn't with cid that has the latest change_changeAt
  /// TODO: consider renaming this to just `storedAt`
  DateTime get change_storedAt;
  int? get schemaVersion;
  String? get unknownJson;
}

mixin CoreEntityStateDataFields {
  /// Padded string value for rank (e.g., '00001', '00002').
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

  /// Arbitrary parent property extracted from change.dataJson.
  /// Required in schema (mirror of data_parentId semantics).
  String get data_parentProp;
  int? get data_parentProp_dataSchemaRev_;
  DateTime get data_parentProp_changeAt_;
  String get data_parentProp_cid_;
  String get data_parentProp_changeBy_;
  DateTime? get data_parentProp_cloudAt_;
}

mixin CoreChangeLogEntryFields {
  /// the remaining change_ fields are from the cid change that
  /// resulted in the latest _changeAt
  String get change_cid;
  DateTime get change_changeAt;
  String get change_changeBy;
  DateTime? get change_cloudAt;
  int? get change_dataSchemaRev;
}

mixin CoreChangeLogEntryOriginalFields {
  String get change_domainId_orig_;
  DateTime get change_changeAt_orig_;
  DateTime get change_storedAt_orig_;
  String get change_cid_orig_;
  // NOT needed: DateTime? get change_cloudAt_orig_;
  String get change_changeBy_orig_;
  // NOT needed: int? get change_dataSchemaRev_orig_;
}
