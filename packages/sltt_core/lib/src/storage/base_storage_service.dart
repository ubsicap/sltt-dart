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

  Future<UpdateChangeLogAndStateResult> updateChangeLogAndState({
    required String domainType,
    required BaseChangeLogEntry changeLogEntry,
    required Map<String, dynamic> changeUpdates,
    BaseEntityState? entityState,
    required Map<String, dynamic> stateUpdates,
  });

  /// Get the current state of an entity for field-level comparison.
  ///
  /// Storage implementations should override this method to provide entity lookup.
  /// This is used by the field-level change detection to determine what fields
  /// have actually changed.
  ///
  /// Returns the most recent change entry for the specified entity, or null if
  /// the entity doesn't exist.
  Future<BaseEntityState?> getCurrentEntityState({
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
    bool includeMetadata = false,
    String? parentId,
  });

  Future<Map<String, dynamic>> getEntityState({
    required String domainType,
    required String domainId,
    required String entityId,
    bool includeMetadata = false,
  });

  String getStorageType();

  /// Retrieve the persisted storageId for this storage backend/instance.
  /// Implementations should persist this across restarts when possible.
  /// Question: should this pass a domainType in case there are multiple storages?
  Future<String> getStorageId();

  /// Ensure a storageId exists and is persisted if possible; return it.
  /// Should be invoked during initialize().
  Future<String> ensureStorageId();
}

/// Return type for updateChangeLogAndState: a tuple of change log entry and entity state.
typedef UpdateChangeLogAndStateResult = ({
  BaseChangeLogEntry newChangeLogEntry,
  BaseEntityState newEntityState,
});

// Stats types are implemented in separate files under src/storage/stats/
