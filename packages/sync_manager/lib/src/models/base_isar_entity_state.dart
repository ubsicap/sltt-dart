// ignore_for_file: non_constant_identifier_names, prefer_initializing_formals

import 'package:isar/isar.dart';
import 'package:sltt_core/sltt_core.dart';

/// Abstract base class for all Isar entity state collections
/// Contains all common fields and implementation
abstract class BaseIsarEntityState extends BaseEntityState {
  Id id = Isar.autoIncrement;

  /// Primary key - entityId with entity type abbreviation
  @override
  @Index(unique: true)
  late String entityId;

  @override
  int? schemaVersion;

  @override
  String unknownJson = '{}';

  /// Current domain ID
  @override
  late String change_domainId;

  /// Original (first) values for tracking entity creation
  @override
  late String change_domainId_orig_;

  /// Latest change timestamp
  @override
  late DateTime change_changeAt;

  /// First UTC change timestamp
  @override
  late DateTime change_changeAt_orig_;

  /// Latest change ID
  @override
  late String change_cid;

  /// Original (first) change ID
  @override
  late String change_cid_orig_;

  /// latest data schema revision (no need for _orig_)
  @override
  int? change_dataSchemaRev;

  /// Latest cloud timestamp
  @override
  DateTime? change_cloudAt;

  /// First UTC cloud timestamp
  @override
  late DateTime? change_cloudAt_orig_;

  /// Latest change author
  @override
  late String change_changeBy;

  /// Original (first) change author
  @override
  late String change_changeBy_orig_;

  @override
  String? data_rank;

  @override
  int? data_rank_dataSchemaRev_;
  @override
  DateTime? data_rank_changeAt_;
  @override
  String? data_rank_cid_;
  @override
  String? data_rank_changeBy_;
  @override
  DateTime? data_rank_cloudAt_;

  @override
  bool? data_deleted;

  // deleted field conflict resolution
  @override
  int? data_deleted_dataSchemaRev_;
  @override
  DateTime? data_deleted_changeAt_;
  @override
  String? data_deleted_cid_;
  @override
  String? data_deleted_changeBy_;
  @override
  DateTime? data_deleted_cloudAt_;

  @override
  late String data_parentId;

  @override
  /// parentId field conflict resolution
  int? data_parentId_dataSchemaRev_;
  @override
  late DateTime data_parentId_changeAt_;
  @override
  late String data_parentId_cid_;
  @override
  late String data_parentId_changeBy_;
  @override
  DateTime? data_parentId_cloudAt_;

  BaseIsarEntityState({
    required super.entityId,
    required super.entityType,
    super.schemaVersion,
    required super.change_domainId,
    super.change_domainId_orig_,
    required super.change_changeAt,
    super.change_changeAt_orig_,
    required super.change_cid,
    super.change_cid_orig_,
    super.change_dataSchemaRev,
    super.change_cloudAt,
    super.change_cloudAt_orig_,
    required super.change_changeBy,
    super.change_changeBy_orig_,
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
  }) : entityId = entityId,
       schemaVersion = schemaVersion,
       change_domainId = change_domainId,
       change_domainId_orig_ = change_domainId_orig_ ?? change_domainId,
       change_changeAt = change_changeAt,
       change_changeAt_orig_ = change_changeAt_orig_ ?? change_changeAt,
       change_cid = change_cid,
       change_cid_orig_ = change_cid_orig_ ?? change_cid,
       change_dataSchemaRev = change_dataSchemaRev,
       change_cloudAt = change_cloudAt,
       change_cloudAt_orig_ = change_cloudAt_orig_ ?? change_cloudAt,
       change_changeBy = change_changeBy,
       change_changeBy_orig_ = change_changeBy_orig_ ?? change_changeBy,
       data_rank = data_rank,
       data_rank_dataSchemaRev_ = data_rank_dataSchemaRev_,
       data_rank_changeAt_ = data_rank_changeAt_,
       data_rank_cid_ = data_rank_cid_,
       data_rank_changeBy_ = data_rank_changeBy_,
       data_rank_cloudAt_ = data_rank_cloudAt_,
       data_deleted = data_deleted,
       data_deleted_dataSchemaRev_ = data_deleted_dataSchemaRev_,
       data_deleted_changeAt_ = data_deleted_changeAt_,
       data_deleted_cid_ = data_deleted_cid_,
       data_deleted_changeBy_ = data_deleted_changeBy_,
       data_deleted_cloudAt_ = data_deleted_cloudAt_,
       data_parentId = data_parentId,
       data_parentId_dataSchemaRev_ = data_parentId_dataSchemaRev_,
       data_parentId_changeAt_ = data_parentId_changeAt_,
       data_parentId_cid_ = data_parentId_cid_,
       data_parentId_changeBy_ = data_parentId_changeBy_,
       data_parentId_cloudAt_ = data_parentId_cloudAt_;
}
