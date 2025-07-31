import 'package:isar/isar.dart';

import 'base_change_log_entry.dart';
import 'entity_type.dart';

part 'change_log_entry.g.dart';

@Collection()
class ClientChangeLogEntry extends BaseChangeLogEntry {
  @override
  Id get seq =>
      super.seq == -9223372036854775808 ? Isar.autoIncrement : super.seq;
  @override
  set seq(int value) => super.seq = value;

  @Index()
  @override
  String get projectId => super.projectId;
  @override
  set projectId(String value) => super.projectId = value;

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

  @ignore
  @override
  Map<String, dynamic> get data => super.data;

  ClientChangeLogEntry({
    required super.projectId,
    required super.entityType,
    required super.operation,
    required super.changeAt,
    required super.entityId,
    required super.dataJson,
    super.outdatedBy,
    super.cloudAt,
    super.cid,
  });

  ClientChangeLogEntry.empty() : super.empty();

  static ClientChangeLogEntry fromJson(Map<String, dynamic> json) {
    final baseEntry = BaseChangeLogEntry.fromJson(json);
    final entry = ClientChangeLogEntry(
      projectId: baseEntry.projectId,
      entityType: baseEntry.entityType,
      operation: baseEntry.operation,
      changeAt: baseEntry.changeAt,
      entityId: baseEntry.entityId,
      dataJson: baseEntry.dataJson,
      outdatedBy: baseEntry.outdatedBy,
      cloudAt: baseEntry.cloudAt,
      cid: baseEntry.cid,
    );
    entry.seq = baseEntry.seq;
    return entry;
  }

  /// Factory method to create ClientChangeLogEntry from API data (Map<String, dynamic>)
  /// Handles proper data conversion and provides defaults for missing fields
  static ClientChangeLogEntry fromApiData(Map<String, dynamic> changeData) {
    final baseEntry = BaseChangeLogEntry.fromApiData(changeData);
    final entry = ClientChangeLogEntry(
      projectId: baseEntry.projectId,
      entityType: baseEntry.entityType,
      operation: baseEntry.operation,
      changeAt: baseEntry.changeAt,
      entityId: baseEntry.entityId,
      dataJson: baseEntry.dataJson,
      outdatedBy: baseEntry.outdatedBy,
      cloudAt: baseEntry.cloudAt,
      cid: baseEntry.cid,
    );
    entry.seq = baseEntry.seq;
    return entry;
  }
}
