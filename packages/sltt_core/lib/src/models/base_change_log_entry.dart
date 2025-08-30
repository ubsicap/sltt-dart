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
  String storageId;

  @override
  String domainType;

  @override
  String domainId;

  @override
  String entityType;

  @override
  String operation;

  @override
  String operationInfoJson = '{}';

  @override
  bool stateChanged;

  @override
  @UtcDateTimeConverter()
  DateTime changeAt;

  @override
  String entityId;

  String dataJson = '{}';

  int? dataSchemaRev = 0;

  @override
  @UtcDateTimeConverter()
  DateTime? cloudAt;

  @override
  String changeBy;

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
    required this.changeAt,
    required this.entityId,
    required this.dataJson,
    this.operationInfoJson = '{}',
    this.dataSchemaRev,
    this.cloudAt,
    required this.changeBy,
    this.schemaVersion,
    this.unknownJson = '{}',
  });

  // Convenience constructor: accept Maps and encode to JSON strings
  BaseChangeLogEntry.fromJsonWithMaps({
    required String storageId,
    required String domainType,
    required String domainId,
    required String entityType,
    required String operation,
    required bool stateChanged,
    Map<String, dynamic> operationInfo = const {},
    required DateTime changeAt,
    required String entityId,
    required Map<String, dynamic> data,
    int? dataSchemaRev,
    DateTime? cloudAt,
    required String changeBy,
    required String cid,
    int? schemaVersion,
    Map<String, dynamic> unknown = const {},
  }) : this(
         storageId: storageId,
         domainType: domainType,
         domainId: domainId,
         entityType: entityType,
         operation: operation,
         stateChanged: stateChanged,
         changeAt: changeAt,
         entityId: entityId,
         dataJson: jsonEncode(data),
         operationInfoJson: jsonEncode(operationInfo),
         dataSchemaRev: dataSchemaRev,
         cloudAt: cloudAt,
         changeBy: changeBy,
         schemaVersion: schemaVersion,
         unknownJson: jsonEncode(unknown),
       );
}

mixin Serializable {
  Map<String, dynamic> toJson();
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
  DateTime? get cloudAt;
}
