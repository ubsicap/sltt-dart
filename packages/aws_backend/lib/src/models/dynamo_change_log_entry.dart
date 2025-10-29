import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'dynamo_change_log_entry.g.dart';

/// Public getter that ensures the Dynamo change log registration runs.
bool get dynamoChangeLogEntryFactoryRegistration =>
    _dynamoChangeLogEntryFactoryRegistration;

/// Lazily register the Dynamo change log entry SerializableGroup.
final _dynamoChangeLogEntryFactoryRegistration = (() {
  registerChangeLogEntryFactoryGroup(
    SerializableGroup<BaseChangeLogEntry>(
      fromJson: (map) => DynamoChangeLogEntry.fromJson(map),
      fromJsonBase: (map) => DynamoChangeLogEntry.fromJsonBase(map),
      toJson: (entry) => (entry as DynamoChangeLogEntry).toJson(),
      toJsonBase: (entry) => (entry as DynamoChangeLogEntry).toJsonBase(),
      toSafeJson: (original) =>
          SafeJsonService.generateSafeChangeLogJson(original),
      validate: (entry) async {
        final change = entry as DynamoChangeLogEntry;
        if (change.dataJson.isEmpty || change.dataJson == '{}') {
          throw Exception('ChangeLogEntry dataJson is empty');
        }
        BaseDataFields.fromJson(change.getData());
      },
    ),
  );
  return true;
})();

@JsonSerializable(includeIfNull: true, checked: true)
class DynamoChangeLogEntry extends BaseChangeLogEntry {
  @override
  int seq;

  @override
  String cid;

  DynamoChangeLogEntry({
    required this.cid,
    this.seq = -1 /* auto increment placeholder */,
    required super.storageId,
    required super.domainType,
    required super.domainId,
    required super.entityType,
    required super.operation,
    required super.stateChanged,
    required super.changeAt,
    required super.entityId,
    required super.dataJson,
    super.operationInfoJson,
    super.dataSchemaRev,
    super.cloudAt,
    super.storedAt,
    required super.changeBy,
    super.schemaVersion,
    super.unknownJson,
  });

  factory DynamoChangeLogEntry.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$DynamoChangeLogEntryFromJson,
        json,
        _$DynamoChangeLogEntryToJson,
      );

  factory DynamoChangeLogEntry.fromJsonBase(Map<String, dynamic> json) =>
      _$DynamoChangeLogEntryFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$DynamoChangeLogEntryToJson);

  @override
  Map<String, dynamic> toJsonBase() => _$DynamoChangeLogEntryToJson(this);
}
