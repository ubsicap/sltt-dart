import '../services/json_serialization_service.dart';
import 'entity_type.dart';

/// Abstract base class for ChangeLogEntry without Isar dependencies
/// Can be used by backend services that don't need Isar
/// implementations should provide their own `seq` handling
abstract class BaseChangeLogEntry
    with ImmutableFields, StorageResponsibilities {
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
  int? dataSchemaRev = 0; // data model revision for compatibility

  /// the payload of the change
  @override
  DateTime? cloudAt; // UTC When the cloud storage received this change (optional)
  @override
  String changeBy; // memberId who made the change
  int? schemaVersion = 0; // change log schema version for compatibility
  /// any fields not read from json are put here for future field migration
  /// This will hold any unmapped fields
  @override
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
    this.dataSchemaRev,
    this.cloudAt,
    required this.changeBy,
    required this.cid,
    this.schemaVersion,
    required this.unknown,
  });

  // Abstract methods to be implemented by concrete subclasses
  Map<String, dynamic> toJson();
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
mixin StorageResponsibilities implements HasUnknownField {
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
