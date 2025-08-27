// ignore_for_file: non_constant_identifier_names, prefer_initializing_formals

import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

import 'base_isar_entity_state.dart';

part 'isar_project_state.g.dart';

/// Isar collection for project entity state storage
@Collection()
@JsonSerializable(includeIfNull: true, checked: true)
class IsarProjectState extends BaseIsarEntityState {
  @override
  String entityType = 'project';

  // Project-specific fields
  String? data_nameLocal;
  int? data_nameLocal_dataSchemaRev_;
  DateTime? data_nameLocal_changeAt_;
  String? data_nameLocal_cid_;
  String? data_nameLocal_changeBy_;
  DateTime? data_nameLocal_cloudAt_;

  IsarProjectState({
    required super.entityId,
    super.entityType = 'project',
    this.data_nameLocal,
    this.data_nameLocal_dataSchemaRev_,
    this.data_nameLocal_changeAt_,
    this.data_nameLocal_cid_,
    this.data_nameLocal_changeBy_,
    this.data_nameLocal_cloudAt_,
    super.schemaVersion,
    required super.change_domainId,
    required super.change_changeAt,
    required super.change_cid,
    super.change_dataSchemaRev,
    super.change_cloudAt,
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
    required super.data_parentId_dataSchemaRev_,
    required super.data_parentId_changeAt_,
    required super.data_parentId_cid_,
    required super.data_parentId_changeBy_,
    super.data_parentId_cloudAt_,
  });

  IsarProjectState.withOrig({
    required super.entityId,
    super.entityType = 'project',
    this.data_nameLocal,
    this.data_nameLocal_dataSchemaRev_,
    this.data_nameLocal_changeAt_,
    this.data_nameLocal_cid_,
    this.data_nameLocal_changeBy_,
    this.data_nameLocal_cloudAt_,
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
  }) : super.withOrig();

  factory IsarProjectState.fromJson(Map<String, dynamic> json) {
    // Create with _orig_ parameters for proper initialization
    final instance = IsarProjectState.withOrig(
      entityId: json['entityId'] as String,
      entityType: json['entityType'] as String? ?? 'project',
      data_nameLocal: json['data_nameLocal'] as String?,
      data_nameLocal_dataSchemaRev_:
          (json['data_nameLocal_dataSchemaRev_'] as num?)?.toInt(),
      data_nameLocal_changeAt_: json['data_nameLocal_changeAt_'] == null
          ? null
          : DateTime.parse(json['data_nameLocal_changeAt_'] as String),
      data_nameLocal_cid_: json['data_nameLocal_cid_'] as String?,
      data_nameLocal_changeBy_: json['data_nameLocal_changeBy_'] as String?,
      data_nameLocal_cloudAt_: json['data_nameLocal_cloudAt_'] == null
          ? null
          : DateTime.parse(json['data_nameLocal_cloudAt_'] as String),
      schemaVersion: (json['schemaVersion'] as num?)?.toInt(),
      change_domainId: json['change_domainId'] as String,
      change_domainId_orig_: json['change_domainId_orig_'] as String?,
      change_changeAt: DateTime.parse(json['change_changeAt'] as String),
      change_changeAt_orig_: json['change_changeAt_orig_'] == null
          ? null
          : DateTime.parse(json['change_changeAt_orig_'] as String),
      change_cid: json['change_cid'] as String,
      change_cid_orig_: json['change_cid_orig_'] as String?,
      change_dataSchemaRev: (json['change_dataSchemaRev'] as num?)?.toInt(),
      change_cloudAt: json['change_cloudAt'] == null
          ? null
          : DateTime.parse(json['change_cloudAt'] as String),
      change_cloudAt_orig_: json['change_cloudAt_orig_'] == null
          ? null
          : DateTime.parse(json['change_cloudAt_orig_'] as String),
      change_changeBy: json['change_changeBy'] as String,
      change_changeBy_orig_: json['change_changeBy_orig_'] as String?,
      data_rank_dataSchemaRev_: (json['data_rank_dataSchemaRev_'] as num?)
          ?.toInt(),
      data_rank: json['data_rank'] as String?,
      data_rank_changeAt_: json['data_rank_changeAt_'] == null
          ? null
          : DateTime.parse(json['data_rank_changeAt_'] as String),
      data_rank_cid_: json['data_rank_cid_'] as String?,
      data_rank_changeBy_: json['data_rank_changeBy_'] as String?,
      data_rank_cloudAt_: json['data_rank_cloudAt_'] == null
          ? null
          : DateTime.parse(json['data_rank_cloudAt_'] as String),
      data_deleted: json['data_deleted'] as bool?,
      data_deleted_dataSchemaRev_: (json['data_deleted_dataSchemaRev_'] as num?)
          ?.toInt(),
      data_deleted_changeAt_: json['data_deleted_changeAt_'] == null
          ? null
          : DateTime.parse(json['data_deleted_changeAt_'] as String),
      data_deleted_cid_: json['data_deleted_cid_'] as String?,
      data_deleted_changeBy_: json['data_deleted_changeBy_'] as String?,
      data_deleted_cloudAt_: json['data_deleted_cloudAt_'] == null
          ? null
          : DateTime.parse(json['data_deleted_cloudAt_'] as String),
      data_parentId: json['data_parentId'] as String,
      data_parentId_dataSchemaRev_:
          (json['data_parentId_dataSchemaRev_'] as num?)?.toInt(),
      data_parentId_changeAt_: DateTime.parse(
        json['data_parentId_changeAt_'] as String,
      ),
      data_parentId_cid_: json['data_parentId_cid_'] as String,
      data_parentId_changeBy_: json['data_parentId_changeBy_'] as String,
      data_parentId_cloudAt_: json['data_parentId_cloudAt_'] == null
          ? null
          : DateTime.parse(json['data_parentId_cloudAt_'] as String),
    );

    // Handle unknown fields by using the base serialization to find known fields
    final knownFields = instance.toJson().keys.toSet();
    final unknownFields = Map<String, dynamic>.fromEntries(
      json.entries.where((e) => !knownFields.contains(e.key)),
    );
    instance.unknownJson = jsonEncode(unknownFields);

    return instance;
  }

  @override
  Map<String, dynamic> toJson() {
    return serializeWithUnknownFieldData(this, _$IsarProjectStateToJson);
  }
}
