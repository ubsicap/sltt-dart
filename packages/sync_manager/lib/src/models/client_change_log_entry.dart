import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'client_change_log_entry.g.dart';

// Register the ClientChangeLogEntry factory group for safe (de)serialization
final _clientChangeLogEntryFactoryRegistration = (() {
  registerChangeLogEntryFactoryGroup(
    FactoryGroup<BaseChangeLogEntry>(
      (json) => ClientChangeLogEntry.fromJson(json),
      (entry) => (entry as ClientChangeLogEntry).toJson(),
      (original) {
        // Build a safe JSON shape for recovery on deserialization errors
        // TODO: can we have a service do most of the mapping?
        final now = HlcTimestampGenerator.generate();
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
          'dataJson': original['dataJson'] ?? '{}',
          'operation': original['operation'] ?? 'update',
          'operationInfoJson': original['operationInfoJson'] ?? '{}',
          'stateChanged': original['stateChanged'] ?? false,
          'unknownJson': original['unknownJson'] ?? '{}',
        };
      },
    ),
  );
  return true;
})();

@Collection()
@JsonSerializable(checked: true)
class ClientChangeLogEntry extends BaseChangeLogEntry {
  // Isar id/seq
  @override
  Id seq = Isar.autoIncrement;

  ClientChangeLogEntry({
    required super.domainId,
    required super.entityType,
    required super.operation,
    required super.changeAt,
    required super.entityId,
    required super.dataJson,
    super.cloudAt,
    required super.changeBy,
    required super.cid,
    required super.storageId,
    required super.domainType,
    required super.stateChanged,
    super.operationInfoJson,
    super.unknownJson,
    super.dataSchemaRev,
    super.schemaVersion,
  });

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
