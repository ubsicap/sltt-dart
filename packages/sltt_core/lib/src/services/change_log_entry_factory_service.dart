import 'package:sltt_core/sltt_core.dart';

/// Service providing factory methods for creating change log entries with
/// standard defaults appropriate for different storage modes.
///
/// This service eliminates boilerplate when creating change log entries for
/// testing or in application code by providing sensible defaults.
class ChangeLogEntryFactoryService {
  /// Create a change log entry with defaults appropriate for "save" mode.
  ///
  /// Save mode is used when a client is creating new changes locally that
  /// have not yet been assigned storage metadata like sequence numbers.
  ///
  /// Type Parameters:
  /// - `T`: The concrete change log entry type (extends BaseChangeLogEntry)
  /// - `TSeq`: The sequence number type (extends int, e.g., int or Isar's Id)
  /// - `TData`: The data fields type (extends BaseDataFields)
  ///
  /// Default values for save mode:
  /// - `storageId`: empty string (not yet assigned)
  /// - `operation`: 'update'
  /// - `operationInfoJson`: '{}'
  /// - `stateChanged`: false (will be computed by storage)
  /// - `unknownJson`: '{}'
  /// - `seq`: 0 (not yet assigned)
  /// - `storedAt`: null (not yet stored)
  /// - `cloudAt`: null (not yet synced to cloud)
  /// - `dataSchemaRev`: null (optional)
  /// - `schemaVersion`: null (optional)
  ///
  /// Required parameters:
  /// - `factory`: Constructor function for the concrete change log entry type
  /// - `domainType`: Domain type (e.g., 'project')
  /// - `domainId`: Domain identifier
  /// - `entityType`: Entity type (e.g., 'task', 'project')
  /// - `entityId`: Entity identifier
  /// - `changeBy`: User identifier who made the change
  /// - `changeAt`: When the change was made (will be normalized to UTC)
  /// - `data`: Change data payload as a BaseDataFields object (or subclass)
  ///
  /// Optional parameters that can override defaults:
  /// - `cid`: Change ID (generated if not provided)
  /// - `operation`: Operation type (default: 'update')
  /// - `storageId`: Storage identifier (default: '')
  /// - `operationInfoJson`: Operation metadata (default: '{}')
  /// - `stateChanged`: Whether state changed (default: false)
  /// - `unknownJson`: Unknown fields (default: '{}')
  /// - `dataSchemaRev`: Data schema revision (default: null)
  /// - `seq`: Sequence number (default: 0)
  /// - `storedAt`: When stored (default: null)
  /// - `cloudAt`: When synced to cloud (default: null)
  /// - `schemaVersion`: Schema version (default: null)
  ///
  /// Example usage:
  /// ```dart
  /// final entry = ChangeLogEntryFactoryService.forChangeSave<TestChangeLogEntry, int, BaseDataFields>(
  ///   factory: TestChangeLogEntry.new,
  ///   domainType: 'project',
  ///   domainId: 'proj-123',
  ///   entityType: 'task',
  ///   entityId: 'task-1',
  ///   changeBy: 'user-1',
  ///   changeAt: DateTime.now(),
  ///   data: BaseDataFields(parentId: 'root', parentProp: 'pList'),
  /// );
  /// ```
  static T forChangeSave<
    T extends BaseChangeLogEntry,
    TSeq extends int,
    TData extends BaseDataFields
  >({
    required T Function({
      required String cid,
      required String entityId,
      required String entityType,
      required String domainId,
      required String domainType,
      required DateTime changeAt,
      DateTime? storedAt,
      required String storageId,
      required String changeBy,
      required String dataJson,
      required String operation,
      String operationInfoJson,
      required bool stateChanged,
      String unknownJson,
      int? dataSchemaRev,
      DateTime? cloudAt,
      int? schemaVersion,
      TSeq seq,
    })
    factory,
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
    required String changeBy,
    required TData data,
    DateTime? changeAt,
    String? cid,
    String operation = kChangeOperationNotYetDefined,
    int? dataSchemaRev,
    int? schemaVersion,
  }) {
    // Generate CID if not provided
    final effectiveCid =
        cid ??
        generateCid(
          entityType:
              EntityType.tryFromString(entityType) ?? EntityType.unknown,
          userId: changeBy,
        );

    final finalChangeAt = changeAt ?? DateTime.now();

    // Encode data as JSON string by calling toJson() on the BaseDataFields object
    final dataJson = stableStringify(data.toJson());

    return factory(
      cid: effectiveCid,
      entityId: entityId,
      entityType: entityType,
      domainId: domainId,
      domainType: domainType,
      changeAt: finalChangeAt,
      storedAt: null /* assigned when stored */,
      cloudAt: null /* assigned when synced to cloud */,
      storageId: '' /* assigned by storage when stored */,
      changeBy: changeBy,
      dataJson: dataJson,
      operation: operation,
      operationInfoJson: '{}',
      stateChanged: false /* computed by storeChanges() */,
      unknownJson: '{}',
      dataSchemaRev: dataSchemaRev,
      schemaVersion: schemaVersion,
      // seq: allow each sub-class to have their own default for seq
    );
  }
}
