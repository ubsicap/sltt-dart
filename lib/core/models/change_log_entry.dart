import 'dart:convert';
import 'package:isar/isar.dart';

part 'change_log_entry.g.dart';

@Collection()
class ChangeLogEntry {
  Id id = Isar.autoIncrement;

  late String entityType; // e.g., 'Document', 'Passage', 'Portion'
  late String operation; // e.g., 'create', 'update', 'delete'
  late DateTime timestamp;
  late String entityId; // UUID or primary key of the entity
  late String dataJson; // JSON-encoded entity data

  Map<String, dynamic> get data => jsonDecode(dataJson);
  set data(Map<String, dynamic> value) => dataJson = jsonEncode(value);

  ChangeLogEntry({
    required this.entityType,
    required this.operation,
    required this.timestamp,
    required this.entityId,
    required Map<String, dynamic> data,
  }) {
    dataJson = jsonEncode(data);
  }

  ChangeLogEntry.empty();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'operation': operation,
      'timestamp': timestamp.toIso8601String(),
      'entityId': entityId,
      'data': data,
    };
  }

  static ChangeLogEntry fromJson(Map<String, dynamic> json) {
    final entry = ChangeLogEntry(
      entityType: json['entityType'] as String,
      operation: json['operation'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      entityId: json['entityId'] as String,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );

    if (json['id'] != null) {
      entry.id = json['id'] as int;
    }

    return entry;
  }
}
