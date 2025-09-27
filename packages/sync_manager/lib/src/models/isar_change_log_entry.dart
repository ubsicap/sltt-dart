import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'isar_change_log_entry.g.dart';

/// Public getter to ensure IsarChangeLogEntry factory registration in tests
bool get isarChangeLogEntryFactoryRegistration =>
    _isarChangeLogEntryFactoryRegistration;

// Register the IsarChangeLogEntry factory group for safe (de)serialization
final _isarChangeLogEntryFactoryRegistration = (() {
  registerChangeLogEntryFactoryGroup(
    // Register as BaseChangeLogEntry to ensure function signatures match
    SerializableGroup<BaseChangeLogEntry>(
      fromJson: (m) => IsarChangeLogEntry.fromJson(m),
      fromJsonBase: (m) => IsarChangeLogEntry.fromJsonBase(m),
      toJson: (entry) => (entry as IsarChangeLogEntry).toJson(),
      toJsonBase: (entry) => (entry as IsarChangeLogEntry).toJsonBase(),
      toSafeJson: (original) {
        // Use the common safe JSON service
        return SafeJsonService.generateSafeChangeLogJson(original);
      },
      validate: (entry) async {
        // TODO: Validate the entry dataJson against the schema for the entity type
        // for now just validate BaseDataFields
        final e = entry as IsarChangeLogEntry;
        if (e.dataJson.isEmpty || e.dataJson == '{}') {
          throw Exception('ChangeLogEntry dataJson is empty');
        }
        BaseDataFields.fromJson(e.getData());
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
