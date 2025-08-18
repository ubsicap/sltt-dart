import 'package:isar/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sltt_core/src/models/base_change_log_entry_service.dart';

part 'change_log_entry.g.dart';

registerChangeLogEntryFactoryGroup(
  'ClientChangeLogEntry',
  (Map<String, dynamic> json) => ClientChangeLogEntry.fromJson(json),
  (BaseChangeLogEntry entry) => entry.toJson(),
);

@Collection()
class ClientChangeLogEntry extends BaseChangeLogEntry {
  Id _seq = Isar.autoIncrement;
  @override
  Id get seq => _seq;
  set seq(int value) => _seq = value;

  @Index()
  @override
  String get domainId => super.domainId;
  @override
  set domainId(String value) => super.domainId = value;

  @Enumerated(EnumType.name)
  @override
  EntityType get entityType => super.entityType;
  @override
  set entityType(EntityType value) => super.entityType = value;

  @Index()
  @override
  String get cid => super.cid; // unique id for changeLogEntry: YYYY-mmdd-HHMMss-sss±HHmm-{4-character-random}
  @override
  set cid(String value) => super.cid = value;

  @override
  @ignore
  Map<String, dynamic> get data => getData();

  @override
  set data(Map<String, dynamic> value) => setData(value);

  ClientChangeLogEntry({
    required super.domainId,
    required super.entityType,
    required super.operation,
    required super.changeAt,
    required super.entityId,
    required super.data,
    super.cloudAt,
    required super.changeBy,
    required super.cid,
    required super.storageId,
    required super.domainType,
    required super.stateChanged,
    required super.operationInfo,
    required super.unknown,
  });

  static ClientChangeLogEntry fromJson(Map<String, dynamic> json) {
    final entry = deserializeChangeLogEntryUsingRegistry(json);
    return entry as ClientChangeLogEntry;
  }
}
