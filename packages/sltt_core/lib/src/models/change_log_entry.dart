import 'dart:convert';

import 'package:isar/isar.dart';

part 'change_log_entry.g.dart';

@Collection()
class ChangeLogEntry {
  Id seq = Isar.autoIncrement;

  @Index()
  late String projectId; // Project identifier for multi-tenancy
  late String entityType; // e.g., 'Document', 'Passage', 'Portion'
  late String operation; // e.g., 'create', 'update', 'delete'
  late DateTime changeAt; // When the change was originally made by the client
  late String entityId; // UUID or primary key of the entity
  late String dataJson; // JSON-encoded entity data
  int? outdatedBy; // id of the change that this entry is outdated by
  DateTime? cloudAt; // When the cloud storage received this change (optional)

  @ignore
  Map<String, dynamic> get data => jsonDecode(dataJson);
  set data(Map<String, dynamic> value) => dataJson = jsonEncode(value);

  ChangeLogEntry({
    required this.projectId,
    required this.entityType,
    required this.operation,
    required this.changeAt,
    required this.entityId,
    required this.dataJson,
    this.outdatedBy,
    this.cloudAt,
  });

  ChangeLogEntry.empty()
    : projectId = '',
      entityType = '',
      operation = '',
      changeAt = DateTime.now(),
      entityId = '',
      dataJson = '';

  Map<String, dynamic> toJson() {
    return {
      'seq': seq,
      'projectId': projectId,
      'entityType': entityType,
      'operation': operation,
      'changeAt': changeAt.toIso8601String(),
      'entityId': entityId,
      'data': data,
      'outdatedBy': outdatedBy,
      'cloudAt': cloudAt?.toIso8601String(),
    };
  }

  static ChangeLogEntry fromJson(Map<String, dynamic> json) {
    final entry = ChangeLogEntry(
      projectId: json['projectId'] as String,
      entityType: json['entityType'] as String,
      operation: json['operation'] as String,
      changeAt: DateTime.parse(json['changeAt'] as String),
      entityId: json['entityId'] as String,
      dataJson: json['data'] as String,
      outdatedBy: json['outdatedBy'] as int?,
      cloudAt: json['cloudAt'] != null
          ? DateTime.parse(json['cloudAt'] as String)
          : null,
    );

    if (json['seq'] != null) {
      entry.seq = json['seq'] as int;
    }

    return entry;
  }
}
