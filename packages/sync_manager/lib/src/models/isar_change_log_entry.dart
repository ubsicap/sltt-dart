import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'isar_change_log_entry.g.dart';

/// Public getter to ensure IsarChangeLogEntry factory registration in tests
// ignore: library_private_types_in_public_api
bool get isarChangeLogEntryFactoryRegistration =>
    _isarChangeLogEntryFactoryRegistration;

// Register the IsarChangeLogEntry factory group for safe (de)serialization
// ignore: unused_element
final _isarChangeLogEntryFactoryRegistration = (() {
  registerChangeLogEntryFactoryGroup(
    SerializableGroup<BaseChangeLogEntry>(
      (json) => IsarChangeLogEntry.fromJson(json),
      (json) => IsarChangeLogEntry.fromJsonBase(json),
      (entry) => (entry as IsarChangeLogEntry).toJson(),
      (original) {
        // Build a safe JSON shape for recovery on deserialization errors
        // TODO: can we have a service do most of the mapping?
        final now = HlcTimestampGenerator.generate();
        return {
          'entityId': original['entityId'] ?? 'e-client',
          'entityType': original['entityType'] ?? 'unknown',
          'domainId': original['domainId'] ?? 'p-client',
          'domainType': original['domainType'] ?? 'project',
          'changeAt': original['changeAt'] ?? now.toIso8601String(),
          'cid': original['cid'] ?? generateCid(now),
          'storageId': original['storageId'] ?? 'local',
          'changeBy': original['changeBy'] ?? 'client',
          'dataJson': JsonUtils.normalize(original['dataJson']),
          'operation': original['operation'] ?? 'update',
          'operationInfoJson': JsonUtils.normalize(
            original['operationInfoJson'],
          ),
          'stateChanged': original['stateChanged'] ?? false,
          'unknownJson': JsonUtils.normalize(original['unknownJson']),
        };
      },
    ),
  );
  return true;
})();

@Collection()
@JsonSerializable(includeIfNull: true, checked: true)
class IsarChangeLogEntry extends BaseChangeLogEntry {
  // Isar id/seq
  @override
  Id seq = Isar.autoIncrement;

  @override
  @Index(unique: true)
  String cid;

  IsarChangeLogEntry({
    required this.cid,
    this.seq = Isar.autoIncrement,
    required super.domainId,
    required super.entityType,
    required super.operation,
    required super.changeAt,
    required super.entityId,
    required super.dataJson,
    super.cloudAt,
    required super.changeBy,
    required super.storageId,
    required super.domainType,
    required super.stateChanged,
    super.operationInfoJson,
    super.unknownJson,
    super.dataSchemaRev,
    super.schemaVersion,
  });

  // json_serializable with unknown-field preservation
  factory IsarChangeLogEntry.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$IsarChangeLogEntryFromJson,
        json,
        _$IsarChangeLogEntryToJson,
      );

  factory IsarChangeLogEntry.fromJsonBase(Map<String, dynamic> json) =>
      _$IsarChangeLogEntryFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$IsarChangeLogEntryToJson);

  @override
  Map<String, dynamic> toJsonBase() => _$IsarChangeLogEntryToJson(this);
}
