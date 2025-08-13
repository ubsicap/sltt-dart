import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

import 'entity_type.dart';

part 'base_change_log_entry.g.dart';

/// implementations should provide this info
abstract class DbResponsibilities {
  /// used for sorting changes in a database
  int get seq;

  /// The type of operation being performed
  String get operation;

  /// Additional metadata about the operation
  /// the shape varies by operation type
  Map<String, dynamic> get operationInfo;

  /// Indicates if the state of the entity has changed
  bool get stateChanged;

  /// The unique ID for this change log entry
  /// added by cloud storage server
  DateTime? get cloudAt;
}

/// Abstract base class for ChangeLogEntry without Isar dependencies
/// Can be used by backend services that don't need Isar
/// implementations should provide their own `seq` handling
@JsonSerializable()
abstract class BaseChangeLogEntry implements DbResponsibilities {
  String
  cid; // unique id for changeLogEntry: YYYY-mmdd-HHMMss-sss±HHmm-{4-character-random} from generateCid()
  String projectId; // Project identifier
  EntityType entityType; // Normalized entity type
  @override
  String operation; // e.g., 'create', 'update', 'delete', 'noOp', 'outdated', 'error'
  @override
  Map<String, dynamic> operationInfo; // Additional operation metadata
  @override
  bool stateChanged; // Indicates if the state of the entity has changed
  DateTime changeAt; // When the change was originally made by the client
  String entityId; // UUID or primary key of the entity
  Map<String, dynamic> data;
  int? dataRev = 1; // data model revision for compatibility

  /// the payload of the change
  @override
  DateTime? cloudAt; // When the cloud storage received this change (optional)
  String changeBy; // memberId who made the change
  int? version = 1; // change log schema version for compatibility
  /// any fields not read from json are put here for future field migration
  /// This will hold any unmapped fields
  @JsonKey(includeFromJson: true, includeToJson: true)
  Map<String, dynamic> unknown = {};

  BaseChangeLogEntry({
    required this.projectId,
    required this.entityType,
    required this.operation,
    required this.stateChanged,
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

  factory BaseChangeLogEntry.fromJson(Map<String, dynamic> json) {
    final change = _$BaseChangeLogEntryFromJson(json);

    // establish known fields
    // (By default nullable fields are included)
    final knownFields = change.toJson().keys.toSet();
    final unknownFields = Map<String, dynamic>.fromEntries(
      json.entries.where((entry) => !knownFields.contains(entry.key)),
    );
    // preserve unknown fields
    change.unknown = unknownFields;
    return change;
  }

  Map<String, dynamic> toJson() {
    final json = _$BaseChangeLogEntryToJson(this);
    json.addAll(unknown); // Re-include unknown fields
    return json;
  }
}

/// Concrete implementation of BaseChangeLogEntry for cases where we need to instantiate it directly
/// Used internally by factory methods and can be used by backend services
class ChangeLogEntry extends BaseChangeLogEntry {
  @override
  int get seq => DateTime.now().millisecondsSinceEpoch; // override to provide ordering in a db

  ChangeLogEntry({
    required super.projectId,
    required super.entityType,
    required super.operation,
    required super.operationInfo,
    required super.changeAt,
    required super.entityId,
    required super.data,
    required super.stateChanged,
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
