import 'package:sltt_core/sltt_core.dart';

/// Result of creating changes with field-level change detection
class CreateChangesResult {
  /// Successfully created changes
  final List<BaseChangeLogEntry> createdChanges;

  /// Changes that resulted in no actual updates (no-op changes)
  final List<String> noOpChangeCids;

  CreateChangesResult({
    required this.createdChanges,
    required this.noOpChangeCids,
  });
}

/// Default implementation functions that storage services can use
class StorageServiceDefaults {
  /// Default implementation for getting changes not outdated
  static Future<List<BaseChangeLogEntry>> getChangesNotOutdated(
    Future<List<BaseChangeLogEntry>> Function({
      required String domainId,
      int? cursor,
      int? limit,
    })
    getChangesWithCursor,
    String domainId,
  ) async {
    return getChangesWithCursor(domainId: domainId);
  }
}

/// Request object that groups all parameters for a single change+state update.
///
/// Storage implementations should process a list of these requests in order
/// to perform batch or sequential updates.
class ChangeLogAndStateRequest {
  final BaseChangeLogEntry changeLogEntry;
  final Map<String, dynamic> changeUpdates;
  final BaseEntityState? entityState;
  final Map<String, dynamic> stateUpdates;
  final OperationCounts operationCounts;
  final bool skipChangeLogWrite;
  final bool skipStateWrite;

  ChangeLogAndStateRequest({
    required this.changeLogEntry,
    required this.changeUpdates,
    this.entityState,
    required this.stateUpdates,
    required this.operationCounts,
    this.skipChangeLogWrite = false,
    this.skipStateWrite = false,
  });
}

/// Abstract base class for all storage service implementations.
///
/// This interface defines the contract that all storage services must implement,
/// whether they use local Isar databases, DynamoDB, or other storage backends.
abstract class BaseStorageService {
  /// Generate a short (16 char), human-ish storage id: YYMMDDHHMM + 2 timezone + 1 random [A-Z] + 2 random [0-9A-Z]
  static String generateShortStorageId() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final yy = two(now.year % 100);
    final mm = two(now.month);
    final dd = two(now.day);
    final hh = two(now.hour);
    final min = two(now.minute);
    final tzOffsetHours = now.timeZoneOffset.inHours;
    final tzSign = tzOffsetHours.isNegative ? '-' : '_';
    final prefix = '$yy$mm$dd$hh$min$tzSign${two(tzOffsetHours.abs())}';
    // start random characters with alphabet to visually separate from timestamp
    final medial = generateRandomChars(1, chars: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    // end with 3 random alphanumeric characters
    final suffix = generateRandomChars(
      2,
      chars: '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    );
    final id = prefix + medial + suffix;
    return id;
  }

  /// Initialize the storage service
  Future<void> initialize();

  /// Close and cleanup the storage service
  Future<void> close();

  /// Process a list of change+state update requests. Implementations may
  /// process them sequentially or in bulk depending on backend capabilities.
  Future<UpdateChangeLogAndStatesResult> updateChangeLogAndStates({
    required String domainType,
    required List<ChangeLogAndStateRequest> requests,
  });

  /// Get the current state of an entity for field-level comparison.
  Future<BaseEntityState?> getEntityState({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
  });

  /// Get a specific change by sequence number
  Future<BaseChangeLogEntry?> getChange({
    required String domainType,
    required String domainId,
    required String cid,
  });

  /// Get changes with cursor-based pagination
  Future<List<BaseChangeLogEntry>> getChangesWithCursor({
    required String domainType,
    required String domainId,
    int? cursor,
    int? limit,
  });

  /// Get statistics about change operations
  ///
  /// NOTE: This returns an `EntityTypeStats` structure that includes per-
  /// entity-type summaries and global totals. This unifies the stats shape
  /// so callers only need to handle one typed structure.
  Future<EntityTypeStats> getChangeStats({
    required String domainType,
    required String domainId,
  });

  /// Get statistics about entity state (based on current persisted entity state)
  ///
  /// This returns stats derived from the current entity state storage (e.g. counts
  /// of existing entities per entityType and latest state metadata). It is distinct
  /// from `getChangeStats`, which is computed from the change log.
  Future<EntityTypeStats> getStateStats({
    required String domainType,
    required String domainId,
  });

  /// Get all domainIds (for a given domain collection, e.g. 'projects')
  Future<List<String>> getAllDomainIds({required String domainType});

  /// Get entity state data for a specific entity type and project
  ///
  /// Subclasses can use StorageServiceDefaults.getEntityStates() for a default implementation that throws UnsupportedError
  Future<Map<String, dynamic>> getEntityStates({
    required String domainType,
    required String domainId,
    required String entityType,
    String? cursor,
    int? limit,
    String? parentId,
    String? parentProp,
    DateTime? storedAfter,
  });

  String getStorageType();

  /// Retrieve the persisted storageId for this storage backend/instance.
  /// Implementations should persist this across restarts when possible.
  /// Question: should this pass a domainType in case there are multiple storages?
  Future<String> getStorageId();

  /// Ensure a storageId exists and is persisted if possible; return it.
  /// Should be invoked during initialize().
  Future<String> ensureStorageId();

  /// Upsert entity type sync state counters (created/updated/deleted) for tracking.
  ///
  /// This method updates or creates entity type sync state records that track
  /// per-entity-type operation counts and latest sync metadata. Implementations
  /// should:
  /// - Update existing records by incrementing counters based on operationCounts
  /// - Create new records if no existing state is found
  /// - Update sync metadata (cid, changeAt, seq) to reflect the latest change
  /// - Use the latest changeAt if newChange is more recent than existing state
  ///
  /// For in-memory storage implementations, this can be a no-op.
  ///
  /// Parameters:
  /// - [domainType]: The type of domain (e.g., 'project', 'team')
  /// - [entityType]: The entity type being tracked (e.g., 'document', 'portion')
  /// - [newChange]: The change log entry being processed
  /// - [operationCounts]: Counts of operations (create/update/delete) to add
  /// - [forChangeLog]: If true, track for change log stats; if false, track for entity state stats
  Future<void> upsertEntityTypeSyncStates({
    required String domainType,
    required String entityType,
    required BaseChangeLogEntry newChange,
    required OperationCounts operationCounts,
    bool forChangeLog = false,
  });

  /// For testing: reset storage for a specific domainId (e.g. '__test_1')
  Future<void> testResetDomainStorage({
    required String domainType,
    required String domainId,
    bool isAdminReset = false,
  });

  /// For testing: Store an entity state directly without updating change log or sync states.
  ///
  /// This is useful for testing entity state storage and retrieval in isolation.
  /// The method accepts any BaseEntityState subtype and returns the stored state
  /// with DateTimes normalized to UTC.
  Future<TEntityState> testStoreState<TEntityState extends BaseEntityState>({
    required TEntityState entityState,
  });

  /// For testing: Store a change log entry directly without any processing or side effects.
  ///
  /// This is useful for testing change log entry storage and retrieval in isolation.
  /// The method accepts JSON and returns the stored entry with DateTimes normalized to UTC.
  /// The JSON is deserialized using the storage-specific change log entry type.
  Future<BaseChangeLogEntry> testStoreChangeFromJson({
    required Map<String, dynamic> changeJson,
  });
}

/// Return type for updateChangeLogAndStates: lists of change log entries and entity states.
typedef UpdateChangeLogAndStatesResult = ({
  List<BaseChangeLogEntry> newChangeLogEntries,
  List<BaseEntityState?> newEntityStates,
});

/// Legacy return type for single-item processing (deprecated, use UpdateChangeLogAndStatesResult)
typedef UpdateChangeLogAndStateResult = ({
  BaseChangeLogEntry newChangeLogEntry,
  BaseEntityState? newEntityState,
});

// Stats types are implemented in separate files under src/storage/stats/
