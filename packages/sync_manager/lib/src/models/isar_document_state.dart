// ignore_for_file: non_constant_identifier_names, prefer_initializing_formals

import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

import 'base_isar_entity_state.dart';

part 'isar_document_state.g.dart';

/// Isar collection for document entity state storage
@Collection()
@JsonSerializable(includeIfNull: true, checked: true)
class IsarDocumentState extends BaseIsarEntityState {
  // Document-specific fields
  String? data_title;
  int? data_contentLength;
  DateTime? data_title_changeAt_;
  String? data_title_cid_;

  IsarDocumentState({
    super.id,
    super.entityType = 'document',
    required super.domainType,
    required super.entityId,
    super.schemaVersion,
    required super.unknownJson,
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
    this.data_title,
    this.data_contentLength,
    this.data_title_changeAt_,
    this.data_title_cid_,
  });

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
