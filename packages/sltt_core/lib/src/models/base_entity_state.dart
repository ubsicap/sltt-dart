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
        CoreChangeLogEntryFields,
        CoreChangeLogEntryOriginalFields {
  // keep the public contract

  BaseEntityState({
    required String entityId,
    required String entityType,
    int? schemaVersion,
    required String change_domainId,
    required String change_domainId_orig_,
    required DateTime change_changeAt,
    required DateTime change_changeAt_orig_,
    required String change_cid,
    required String change_cid_orig_,
    int? change_dataSchemaRev,
    DateTime? change_cloudAt,
    required String change_changeBy,
    required String change_changeBy_orig_,
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

  // Static helper methods for _orig_ field initialization
  static String normalizeOrigString(String orig, String current) {
    return orig.isEmpty ? current : orig;
  }

  static DateTime defaultOrigDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(0).toUtc();
  }

  static DateTime normalizeOrigDateTime(DateTime orig, DateTime current) {
    return orig.isAtSameMomentAs(defaultOrigDateTime()) ? current : orig;
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
  int? get schemaVersion;
  String? get unknownJson;
}

mixin CoreEntityDataFields {
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
}

mixin CoreChangeLogEntryFields {
  DateTime get change_changeAt;
  String get change_changeBy;
  String get change_cid;
  DateTime? get change_cloudAt;
  int? get change_dataSchemaRev;
}

mixin CoreChangeLogEntryOriginalFields {
  String get change_domainId_orig_;
  DateTime get change_changeAt_orig_;
  String get change_cid_orig_;
  // NOT needed: DateTime? get change_cloudAt_orig_;
  String get change_changeBy_orig_;
  // NOT needed: int? get change_dataSchemaRev_orig_;
}
