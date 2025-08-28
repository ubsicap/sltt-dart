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
  final String entityId;

  @override
  final String entityType;

  @override
  final int? schemaVersion;

  @override
  String unknownJson;

  /// Current domain ID
  final String change_domainId;

  /// Latest change timestamp
  @override
  final DateTime change_changeAt;

  /// Latest change ID
  @override
  final String change_cid;

  /// latest data schema revision (no need for _orig_)
  @override
  final int? change_dataSchemaRev;

  /// Latest cloud timestamp (no need for _orig_)
  @override
  final DateTime? change_cloudAt;

  /// Latest change author
  @override
  final String change_changeBy;

  @override
  final DateTime change_changeAt_orig_;

  @override
  final String change_changeBy_orig_;

  @override
  final String change_cid_orig_;

  @override
  final String change_domainId_orig_;

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
  bool? data_deleted;

  // deleted field conflict resolution
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
  /// parentId field conflict resolution
  final int? data_parentId_dataSchemaRev_;
  @override
  final DateTime data_parentId_changeAt_;
  @override
  final String data_parentId_cid_;
  @override
  final String data_parentId_changeBy_;
  @override
  final DateTime? data_parentId_cloudAt_;

  BaseIsarEntityState({
    this.id = Isar.autoIncrement,
    required super.entityId,
    required super.entityType,
    super.schemaVersion,
    required String unknownJson,
    required super.change_domainId,
    required super.change_domainId_orig_,
    required super.change_changeAt,
    required super.change_changeAt_orig_,
    required super.change_cid,
    required super.change_cid_orig_,
    super.change_dataSchemaRev,
    super.change_cloudAt,
    required super.change_changeBy,
    required super.change_changeBy_orig_,
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
       entityType = entityType,
       unknownJson = JsonUtils.normalize(unknownJson),
       change_domainId = change_domainId,
       change_domainId_orig_ = BaseEntityState.normalizeOrigString(
         change_domainId_orig_,
         change_domainId,
       ),
       change_changeAt = change_changeAt,
       change_changeAt_orig_ = BaseEntityState.normalizeOrigDateTime(
         change_changeAt_orig_,
         change_changeAt,
       ),
       change_cid = change_cid,
       change_cid_orig_ = BaseEntityState.normalizeOrigString(
         change_cid_orig_,
         change_cid,
       ),
       change_dataSchemaRev = change_dataSchemaRev,
       change_cloudAt = change_cloudAt,
       change_changeBy = change_changeBy,
       change_changeBy_orig_ = BaseEntityState.normalizeOrigString(
         change_changeBy_orig_,
         change_changeBy,
       ),
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
