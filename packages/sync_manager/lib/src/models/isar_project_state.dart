// ignore_for_file: non_constant_identifier_names

import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'isar_project_state.g.dart';

/// Isar collection for project entity state storage
@Collection()
@JsonSerializable(checked: true)
class IsarProjectState extends BaseEntityState {
  Id id = Isar.autoIncrement;

  /// Primary key - entityId with entity type abbreviation
  @override
  @Index(unique: true)
  late String entityId;

  @override
  String entityType = 'project';

  @override
  int? schemaVersion;

  @override
  String unknownJson = '{}';

  /// Current project ID
  @override
  String change_domainId = '';

  /// Original (first) values for tracking entity creation
  @override
  String change_domainId_orig_ = '';

  /// Latest change timestamp
  @override
  DateTime change_changeAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// First UTC change timestamp
  @override
  DateTime? change_changeAt_orig_;

  /// Latest change ID
  @override
  String change_cid = '';

  /// Original (first) change ID
  @override
  String change_cid_orig_ = '';

  /// latest data schema revision (no need for _orig_)
  @override
  int? change_dataSchemaRev;

  /// Latest cloud timestamp
  @override
  DateTime? change_cloudAt;

  /// First UTC cloud timestamp
  @override
  DateTime? change_cloudAt_orig_;

  /// Latest change author
  @override
  String change_changeBy = '';

  /// Original (first) change author
  @override
  String change_changeBy_orig_ = '';

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
  bool? data_deleted = false;

  // deleted field conflict resolution
  @override
  int? data_deleted_dataSchemaRev_ = 0;
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

  @override
  /// parentId field conflict resolution
  int? data_parentId_dataSchemaRev_;
  @override
  DateTime data_parentId_changeAt_ = DateTime.fromMillisecondsSinceEpoch(0);
  @override
  String data_parentId_cid_ = '';
  @override
  String data_parentId_changeBy_ = '';
  @override
  DateTime? data_parentId_cloudAt_;

  IsarProjectState({
    required this.entityId,
    super.entityType = 'project',
    super.schemaVersion,
    required super.change_domainId,
    required super.change_domainId_orig_,
    required super.change_changeAt,
    super.change_changeAt_orig_,
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
    super.data_parentId_dataSchemaRev_,
    required super.data_parentId_changeAt_,
    required super.data_parentId_cid_,
    required super.data_parentId_changeBy_,
    super.data_parentId_cloudAt_,
  }) : super(entityId: entityId);

  factory IsarProjectState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$IsarProjectStateFromJson,
        json,
        _$IsarProjectStateToJson,
      );

  @override
  Map<String, dynamic> toJson() {
    return serializeWithUnknownFieldData(this, _$IsarProjectStateToJson);
  }
}
