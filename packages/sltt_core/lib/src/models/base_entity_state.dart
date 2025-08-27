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
  // keep the public contract

  // make orig_ private backing field and public getter (non-virtual storage)
  final String _change_domainId_orig_;
  String get change_domainId_orig_ => _change_domainId_orig_;

  // same for change_changeAt_orig_ and change_cid_orig_, etc.
  final DateTime _change_changeAt_orig_;
  DateTime get change_changeAt_orig_ => _change_changeAt_orig_;

  final String _change_cid_orig_;
  String get change_cid_orig_ => _change_cid_orig_;

  BaseEntityState({
    required String entityId,
    required String entityType,
    int? schemaVersion,
    required String change_domainId,
    String? change_domainId_orig_,
    required DateTime change_changeAt,
    DateTime? change_changeAt_orig_,
    required String change_cid,
    String? change_cid_orig_,
    int? change_dataSchemaRev,
    DateTime? change_cloudAt,
    DateTime? change_cloudAt_orig_,
    required String change_changeBy,
    String? change_changeBy_orig_,
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
  }) : _change_domainId_orig_ = change_domainId_orig_ ?? change_domainId,
       _change_changeAt_orig_ = change_changeAt_orig_ ?? change_changeAt,
       _change_cid_orig_ = change_cid_orig_ ?? change_cid {
    // other non-virtual initialization as needed
  }

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
