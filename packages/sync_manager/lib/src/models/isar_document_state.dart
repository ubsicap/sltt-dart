// ignore_for_file: non_constant_identifier_names

import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'isar_document_state.g.dart';

/// Isar collection for document entity state storage
/// Uses composition instead of inheritance to avoid Isar limitations
@Collection()
@JsonSerializable(includeIfNull: true, checked: true)
class IsarDocumentState extends BaseEntityState {
  Id id = Isar.autoIncrement;

  @override
  @Index(unique: true)
  late String entityId;

  @override
  String entityType = 'document';

  @override
  int? schemaVersion;

  @override
  String unknownJson = '{}';

  // --- common change tracking fields (override base)
  @override
  String change_domainId = '';

  @override
  late String change_domainId_orig_;

  @override
  DateTime change_changeAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  late DateTime change_changeAt_orig_;

  @override
  String change_cid = '';

  @override
  late String change_cid_orig_;

  @override
  int? change_dataSchemaRev;

  @override
  DateTime? change_cloudAt;

  @override
  late DateTime? change_cloudAt_orig_;

  @override
  String change_changeBy = '';

  @override
  late String change_changeBy_orig_;

  // --- per-entity data fields you care about (examples)
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

  // document-specific example fields
  String? data_title;
  int? data_contentLength;
  DateTime? data_title_changeAt_;
  String? data_title_cid_;

  @override
  bool? data_deleted = false;

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
  int? data_parentId_dataSchemaRev_;
  @override
  DateTime data_parentId_changeAt_ = DateTime.fromMillisecondsSinceEpoch(0);
  @override
  String data_parentId_cid_ = '';
  @override
  String data_parentId_changeBy_ = '';
  @override
  DateTime? data_parentId_cloudAt_;

  IsarDocumentState({
    required super.entityId,
    super.entityType = 'document',
    super.schemaVersion,
    required super.change_domainId,
    required super.change_changeAt,
    required super.change_cid,
    super.change_dataSchemaRev,
    super.change_cloudAt,
    required super.change_changeBy,
    // document-specific ctor params (optional)
    String? data_title,
    int? data_contentLength,
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
    required super.data_parentId,
    required super.data_parentId_dataSchemaRev_,
    required super.data_parentId_changeAt_,
    required super.data_parentId_cid_,
    required super.data_parentId_changeBy_,
    super.data_parentId_cloudAt_,
  }) : data_title = data_title,
       data_contentLength = data_contentLength,
       data_rank_dataSchemaRev_ = data_rank_dataSchemaRev_,
       data_rank = data_rank,
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
       data_parentId_cloudAt_ = data_parentId_cloudAt_,
       // do not forward `super.*_orig_` parameters — avoid isar_generator mismatch
       super();

  factory IsarDocumentState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$IsarDocumentStateFromJson,
        json,
        _$IsarDocumentStateToJson,
      );

  @override
  Map<String, dynamic> toJson() {
    return serializeWithUnknownFieldData(this, _$IsarDocumentStateToJson);
  }
}
