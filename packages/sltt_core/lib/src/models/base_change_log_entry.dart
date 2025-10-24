import 'dart:convert';

import '../services/json_serialization_service.dart';

/// (Isar compatible)
/// abstract base for change log entries. Stores map-like payloads as JSON
/// strings (`dataJson`, `operationInfoJson`, `unknownJson`) to remain
/// storage-agnostic.
abstract class BaseChangeLogEntry
    with
        Serializable,
        ImmutableFields,
        StorageResponsibilities,
        HasUnknownField {
  @override
  String get cid;
  set cid(String value);

  @override
  final String storageId;

  @override
  final String domainType;

  @override
  final String domainId;

  @override
  final String entityType;

  @override
  final String operation;

  @override
  String operationInfoJson = '{}';

  @override
  final bool stateChanged;

  @override
  final DateTime changeAt;

  @override
  final String entityId;

  String dataJson = '{}';

  int? dataSchemaRev = 0;

  @override
  final DateTime? cloudAt;

  @override
  final DateTime? storedAt;

  @override
  final String changeBy;

  int? schemaVersion = 0;

  @override
  String unknownJson = '{}';

  /// Return parsed data map.
  Map<String, dynamic> getData() {
    if (dataJson.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(dataJson);
    return (decoded is Map)
        ? decoded.cast<String, dynamic>()
        : <String, dynamic>{};
  }

  /// Set single key inside data map and persist as JSON.
  void setData(String k, dynamic v) {
    final m = getData();
    m[k] = v;
    dataJson = jsonEncode(m);
  }

  /// Set the entire data map and persist as JSON.
  void setDataMap(Map<String, dynamic> data) {
    dataJson = jsonEncode(data);
  }

  /// Return parsed operationInfo map.
  Map<String, dynamic> getOperationInfo() {
    if (operationInfoJson.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(operationInfoJson);
    return (decoded is Map)
        ? decoded.cast<String, dynamic>()
        : <String, dynamic>{};
  }

  /// Set single key inside operationInfo and persist.
  void setOperationInfo(String k, dynamic v) {
    final m = getOperationInfo();
    m[k] = v;
    operationInfoJson = jsonEncode(m);
  }

  /// Set the entire operationInfo map and persist as JSON.
  void setOperationInfoMap(Map<String, dynamic> operationInfo) {
    operationInfoJson = jsonEncode(operationInfo);
  }

  /// Set the entire unknown map and persist as JSON.
  void setUnknownMap(Map<String, dynamic> unknown) {
    unknownJson = jsonEncode(unknown);
  }

  // Primary constructor: work directly with JSON-string payload fields
  BaseChangeLogEntry({
    required this.storageId,
    required this.domainType,
    required this.domainId,
    required this.entityType,
    required this.operation,
    required this.stateChanged,
    required DateTime changeAt,
    required this.entityId,
    required this.dataJson,
    this.operationInfoJson = '{}',
    this.dataSchemaRev,
    DateTime? cloudAt,
    DateTime? storedAt,
    required this.changeBy,
    this.schemaVersion,
    this.unknownJson = '{}',
  }) : changeAt = changeAt.toUtc(),
       storedAt = storedAt?.toUtc(),
       cloudAt = cloudAt?.toUtc();
}

mixin Serializable {
  Map<String, dynamic> toJson();
  Map<String, dynamic> toJsonBase();
}

mixin ImmutableFields {
  String get cid;
  String get storageId;
  String get domainType;
  String get domainId;
  String get entityType;
  String get entityId;
  DateTime get changeAt;
  String get changeBy;
}

mixin StorageResponsibilities {
  int get seq;
  String get operation;
  String get operationInfoJson;
  bool get stateChanged;

  /// we always expect this to eventually be set in getUpdatesForChangeLogEntryAndEntityState
  DateTime? get storedAt;

  /// for cloud storage, we always expect this to eventually be set in getUpdatesForChangeLogEntryAndEntityState
  DateTime? get cloudAt;

  /// The ID of the storage used to save this change log entry.
  /// Expected to be empty string in `save` mode, but in `sync` mode it may be populated from BaseChangeLogEntry.generateShortStorageId()
  String get storageId;
}

/// These fields are shared across entity types in dataJson.
/// See also CoreEntityStateDataFields
mixin CoreDataFields {
  String? get rank;
  bool? get deleted;
  String get parentId;
  String get parentProp;
}
