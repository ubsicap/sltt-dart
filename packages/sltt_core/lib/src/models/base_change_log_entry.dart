import 'dart:math';

import 'entity_type.dart';

abstract class HasSeq {
  int? get seq;
}

/// Abstract base class for ChangeLogEntry without Isar dependencies
/// Can be used by backend services that don't need Isar
/// implementations should provide their own `seq` handling
abstract class BaseChangeLogEntry implements HasSeq {
  String
  cid; // unique id for changeLogEntry: YYYY-mmdd-HHMMss-sss±HHmm-{4-character-random} from generateCid()
  String projectId; // Project identifier
  EntityType entityType; // Normalized entity type
  String
  operation; // e.g., 'create', 'update', 'delete', 'noOp', 'outdated', 'error'
  Map<String, dynamic> operationInfo = {}; // Additional operation metadata
  DateTime changeAt; // When the change was originally made by the client
  String entityId; // UUID or primary key of the entity
  Map<String, dynamic> data;
  int? dataRev = 1; // data model revision for compatibility

  /// the payload of the change
  DateTime? cloudAt; // When the cloud storage received this change (optional)
  String changeBy; // memberId who made the change
  int? version = 1; // change log schema version for compatibility
  /// any fields not read from json are put here for future field migration
  Map<String, dynamic> unknown = {};

  BaseChangeLogEntry({
    required this.projectId,
    required this.entityType,
    required this.operation,
    required this.operationInfo,
    required this.changeAt,
    required this.entityId,
    required this.data,
    this.dataRev,
    this.cloudAt,
    required this.changeBy,
    required this.cid,
    this.version,
    required this.unknown,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'entityType': entityType.value,
      'operation': operation,
      'operationInfo': operationInfo,
      'changeAt': changeAt.toUtc().toIso8601String(),
      'entityId': entityId,
      'data': data,
      'dataRev': dataRev,
      'cloudAt': cloudAt?.toIso8601String(),
      'changeBy': changeBy,
      'cid': cid,
      'version': version,
      'unknown': unknown,
    };
  }

  static BaseChangeLogEntry fromJson(Map<String, dynamic> json) {
    // any fields not read from json should be put in unknown
    // this allows for future compatibility without breaking changes
    final usedFields = <String>{};

    // track all fields that are used
    dynamic readField(Map<String, dynamic> json, String field) {
      usedFields.add(field);
      return json[field];
    }

    final entry = ChangeLogEntry(
      projectId: readField(json, 'projectId') as String,
      entityType: EntityType.fromString(
        readField(json, 'entityType') as String,
      ),
      operation: readField(json, 'operation') as String,
      operationInfo:
          readField(json, 'operationInfo') as Map<String, dynamic>? ?? {},
      changeAt: DateTime.parse(readField(json, 'changeAt') as String),
      entityId: readField(json, 'entityId') as String,
      data: readField(json, 'data') as Map<String, dynamic>? ?? {},
      dataRev: readField(json, 'dataRev') as int?,
      cloudAt: readField(json, 'cloudAt') != null
          ? DateTime.parse(readField(json, 'cloudAt') as String)
          : null,
      changeBy: readField(json, 'changeBy') as String? ?? '',
      cid: readField(json, 'cid') as String? ?? generateCid(),
      version: readField(json, 'version') as int?,
      unknown: getUnknownFields(json, usedFields),
    );

    return entry;
  }
}

/// Concrete implementation of BaseChangeLogEntry for cases where we need to instantiate it directly
/// Used internally by factory methods and can be used by backend services
class ChangeLogEntry extends BaseChangeLogEntry {
  @override
  int? get seq => DateTime.now().millisecondsSinceEpoch; // override to provide ordering in a db

  ChangeLogEntry({
    required super.projectId,
    required super.entityType,
    required super.operation,
    required super.operationInfo,
    required super.changeAt,
    required super.entityId,
    required super.data,
    super.dataRev,
    super.cloudAt,
    required super.changeBy,
    required super.cid,
    super.version,
    super.unknown = const {},
  });
}

Map<String, dynamic> getUnknownFields(
  Map<String, dynamic> json,
  Set<String> usedFields,
) {
  return Map.fromEntries(
    json.entries.where((entry) => !usedFields.contains(entry.key)),
  );
}

/// operation enum
enum ChangeLogOperation { create, update, delete, noOp, outdated, error }

/// Helper to convert string to ChangeLogOperation enum
ChangeLogOperation _operationFromString(String value) {
  switch (value) {
    case 'create':
      return ChangeLogOperation.create;
    case 'update':
      return ChangeLogOperation.update;
    case 'delete':
      return ChangeLogOperation.delete;
    case 'noOp':
      return ChangeLogOperation.noOp;
    case 'outdated':
      return ChangeLogOperation.outdated;
    case 'error':
      return ChangeLogOperation.error;
    default:
      return ChangeLogOperation.error;
  }
}

/// Generates a unique CID (Change ID) in format: YYYY-mmdd-HHMMss-sss±HHmm-{4-character-random}
String generateCid([DateTime? timestamp]) {
  final now = timestamp ?? DateTime.now();
  final utc = now.toUtc();

  // Format: YYYY-mmdd-HHMMss-sss
  final datePart =
      '${utc.year.toString().padLeft(4, '0')}-'
      '${utc.month.toString().padLeft(2, '0')}${utc.day.toString().padLeft(2, '0')}-'
      '${utc.hour.toString().padLeft(2, '0')}${utc.minute.toString().padLeft(2, '0')}${utc.second.toString().padLeft(2, '0')}-'
      '${utc.millisecond.toString().padLeft(3, '0')}';

  // Timezone offset: ±HHmm
  final offset = now.timeZoneOffset;
  final offsetSign = offset.isNegative ? '-' : '+';
  final offsetHours = offset.inHours.abs().toString().padLeft(2, '0');
  final offsetMinutes = (offset.inMinutes.abs() % 60).toString().padLeft(
    2,
    '0',
  );
  final timezonePart = '$offsetSign$offsetHours$offsetMinutes';

  // 4-character random part
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  final randomPart = String.fromCharCodes(
    Iterable.generate(4, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
  );

  return '$datePart$timezonePart-$randomPart';
}
