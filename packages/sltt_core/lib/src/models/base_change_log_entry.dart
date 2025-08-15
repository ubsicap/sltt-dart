import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

import '../services/json_serialization_service.dart';
import 'entity_type.dart';

part 'base_change_log_entry.g.dart';

/// Abstract base class for ChangeLogEntry without Isar dependencies
/// Can be used by backend services that don't need Isar
/// implementations should provide their own `seq` handling
@JsonSerializable()
abstract class BaseChangeLogEntry
    with ImmutableFields, DbResponsibilities, HasUnknownField {
  /// unique id for changeLogEntry: YYYY-mmdd-HHMMss-sss±HHmm-{4-character-random} from generateCid()
  @override
  String cid;

  /// discrete sets for getting change logs: user, team, project
  @override
  String domainType;

  /// Unique identifier for the change log that has these entries
  /// (e.g. userId, teamId, projectId)
  @override
  String domainId;

  @override
  EntityType entityType; // Normalized entity type
  @override
  String operation; // e.g., 'create', 'update', 'delete', 'noOp', 'outdated', 'error'
  @override
  Map<String, dynamic> operationInfo; // Additional operation metadata
  @override
  bool stateChanged; // Indicates if the state of the entity has changed
  @override
  DateTime changeAt; // UTC when the change was originally made by the client
  @override
  String entityId; // UUID or primary key of the entity
  Map<String, dynamic> data;
  int? dataRev = 0; // data model revision for compatibility

  /// the payload of the change
  @override
  DateTime? cloudAt; // UTC When the cloud storage received this change (optional)
  @override
  String changeBy; // memberId who made the change
  int? version = 0; // change log schema version for compatibility
  /// any fields not read from json are put here for future field migration
  /// This will hold any unmapped fields
  @override
  @JsonKey(includeFromJson: true, includeToJson: true)
  Map<String, dynamic> unknown = {};

  BaseChangeLogEntry({
    required this.domainType,
    required this.domainId,
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
    final change = deserializeWithUnknownFieldData(
      _$BaseChangeLogEntryFromJson,
      json,
    );
    return change;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = serializeWithUnknownFieldData(this);
    return json;
  }
}

mixin ImmutableFields {
  String get cid;
  String get domainType;
  String get domainId;
  EntityType get entityType;
  String get entityId;
  DateTime get changeAt;
  String get changeBy;
}

/// implementations should provide this info
mixin DbResponsibilities {
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

/// Concrete implementation of BaseChangeLogEntry for cases where we need to instantiate it directly
/// Used internally by factory methods and can be used by backend services
class ChangeLogEntry extends BaseChangeLogEntry {
  @override
  int get seq => DateTime.now().millisecondsSinceEpoch; // override to provide ordering in a db

  ChangeLogEntry({
    required super.domainType,
    required super.domainId,
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
