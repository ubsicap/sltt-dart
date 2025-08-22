import 'dart:convert';

import '../services/json_serialization_service.dart';
import 'entity_type.dart';

/// Abstract base for change log entries. Stores map-like payloads as JSON
/// strings (`dataJson`, `operationInfoJson`, `unknownJson`) to remain
/// storage-agnostic.
abstract class BaseChangeLogEntry
    with
        Serializable,
        ImmutableFields,
        StorageResponsibilities,
        HasUnknownField {
  @override
  String cid;

  @override
  String storageId;

  @override
  String domainType;

  @override
  String domainId;

  @override
  EntityType entityType;

  @override
  String operation;

  @override
  String operationInfoJson = '{}';

  @override
  bool stateChanged;

  @override
  DateTime changeAt;

  @override
  String entityId;

  @override
  String dataJson = '{}';

  int? dataSchemaRev = 0;

  @override
  DateTime? cloudAt;

  @override
  String changeBy;

  int? schemaVersion = 0;

  @override
  String unknownJson = '{}';

  BaseChangeLogEntry({
    required this.storageId,
    required this.domainType,
    required this.domainId,
    required this.entityType,
    required this.operation,
    required this.stateChanged,
    Map<String, dynamic> operationInfo = const {},
    required this.changeAt,
    required this.entityId,
    required Map<String, dynamic> data,
    this.dataSchemaRev,
    this.cloudAt,
    required this.changeBy,
    required this.cid,
    this.schemaVersion,
    Map<String, dynamic> unknown = const {},
  }) {
    operationInfoJson = jsonEncode(operationInfo);
    dataJson = jsonEncode(data);
    unknownJson = jsonEncode(unknown);
  }
}

mixin Serializable {
  Map<String, dynamic> toJson();
}

mixin ImmutableFields {
  String get cid;
  String get storageId;
  String get domainType;
  String get domainId;
  EntityType get entityType;
  String get entityId;
  DateTime get changeAt;
  String get changeBy;
}

mixin StorageResponsibilities {
  int get seq;
  String get operation;
  String get operationInfoJson;
  bool get stateChanged;
  DateTime? get cloudAt;
}
