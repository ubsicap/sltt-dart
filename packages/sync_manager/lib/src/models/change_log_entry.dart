import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sltt_core/src/models/factory_pair.dart';
import 'package:sltt_core/src/services/base_change_log_entry_service.dart';
import 'package:sltt_core/src/services/json_serialization_service.dart';

part 'change_log_entry.g.dart';

// Register the ClientChangeLogEntry factory group for safe (de)serialization
final _clientChangeLogEntryFactoryRegistration = (() {
  registerChangeLogEntryFactoryGroup(
    FactoryGroup<BaseChangeLogEntry>(
      (json) => ClientChangeLogEntry.fromJson(json),
      (entry) => (entry as ClientChangeLogEntry).toJson(),
      (original) {
        // Build a safe JSON shape for recovery on deserialization errors
        final now = DateTime.now().toUtc();
        return {
          'entityId': original['entityId'] ?? 'e-client',
          'entityType': original['entityType'] ?? 'unknown',
          'domainId':
              original['domainId'] ?? original['projectId'] ?? 'p-client',
          'domainType': original['domainType'] ?? 'project',
          'changeAt': original['changeAt'] ?? now.toIso8601String(),
          'cid': original['cid'] ?? generateCid(now),
          'storageId': original['storageId'] ?? 'local',
          'changeBy': original['changeBy'] ?? 'client',
          'data':
              (original['data'] as Map<String, dynamic>?) ??
              <String, dynamic>{},
          'operation': original['operation'] ?? 'update',
          'operationInfo':
              (original['operationInfo'] as Map<String, dynamic>?) ??
              <String, dynamic>{},
          'stateChanged': original['stateChanged'] ?? false,
          'unknown':
              (original['unknown'] as Map<String, dynamic>?) ??
              <String, dynamic>{},
        };
      },
    ),
  );
  return true;
})();

@Collection()
@JsonSerializable(checked: true)
class ClientChangeLogEntry implements BaseChangeLogEntry {
  // Isar id/seq
  @override
  Id seq = Isar.autoIncrement;

  // Immutable/core fields
  @Index()
  @override
  String cid;

  @override
  String storageId;

  @override
  String domainType;

  @Index()
  @override
  String domainId;

  @Enumerated(EnumType.name)
  @override
  EntityType entityType;

  @override
  String entityId;

  @override
  DateTime changeAt;

  @override
  String changeBy;

  // Operation/meta
  @override
  String operation;

  // Persist Map fields as JSON strings for Isar, expose via computed getters
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  String dataJson;
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  String operationInfoJson;
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  String unknownJson;

  // JSON-facing (ignored by Isar)
  @ignore
  @override
  @JsonKey(name: 'data', toJson: _mapToJson, fromJson: _jsonToMap)
  Map<String, dynamic> get data => _jsonToMap(dataJson);
  @override
  set data(Map<String, dynamic> v) => dataJson = _mapToJson(v);

  @ignore
  @override
  @JsonKey(name: 'operationInfo', toJson: _mapToJson, fromJson: _jsonToMap)
  Map<String, dynamic> get operationInfo => _jsonToMap(operationInfoJson);
  @override
  set operationInfo(Map<String, dynamic> v) =>
      operationInfoJson = _mapToJson(v);

  @override
  bool stateChanged;

  @override
  DateTime? cloudAt;

  @override
  int? dataSchemaRev;
  @override
  int? schemaVersion;

  @ignore
  @override
  @JsonKey(name: 'unknown', toJson: _mapToJson, fromJson: _jsonToMap)
  Map<String, dynamic> get unknown => _jsonToMap(unknownJson);
  @override
  set unknown(Map<String, dynamic> v) => unknownJson = _mapToJson(v);

  // Provide HasUnknownField-style helper methods so that when this class
  // "implements BaseChangeLogEntry" it satisfies the mixin's interface.
  Map<String, dynamic> getUnknown() => _jsonToMap(unknownJson);

  Map<String, dynamic> getData() => _jsonToMap(dataJson);

  Map<String, dynamic> getOperationInfo() => _jsonToMap(operationInfoJson);

  void setUnknown(String k, dynamic v) {
    final m = _jsonToMap(unknownJson);
    m[k] = v;
    unknownJson = _mapToJson(m);
  }

  void setOperationInfo(String k, dynamic v) {
    final m = _jsonToMap(operationInfoJson);
    m[k] = v;
    operationInfoJson = _mapToJson(m);
  }

  ClientChangeLogEntry({
    required this.domainId,
    required this.entityType,
    required this.operation,
    required this.changeAt,
    required this.entityId,
    Map<String, dynamic> data = const {},
    this.cloudAt,
    required this.changeBy,
    required this.cid,
    required this.storageId,
    required this.domainType,
    required this.stateChanged,
    Map<String, dynamic> operationInfo = const {},
    Map<String, dynamic> unknown = const {},
    this.dataSchemaRev,
    this.schemaVersion,
  }) : dataJson = _mapToJson(data),
       operationInfoJson = _mapToJson(operationInfo),
       unknownJson = _mapToJson(unknown);

  // json_serializable with unknown-field preservation
  factory ClientChangeLogEntry.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$ClientChangeLogEntryFromJson,
        json,
        _$ClientChangeLogEntryToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$ClientChangeLogEntryToJson);
}

// Json helpers for map <-> string storage
String _mapToJson(Map<String, dynamic> map) => jsonEncode(map);
Map<String, dynamic> _jsonToMap(Object? value) {
  if (value == null) return <String, dynamic>{};
  if (value is String && value.isEmpty) return <String, dynamic>{};
  if (value is String) {
    final decoded = jsonDecode(value);
    if (decoded is Map) return decoded.cast<String, dynamic>();
  }
  if (value is Map) return value.cast<String, dynamic>();
  return <String, dynamic>{};
}
