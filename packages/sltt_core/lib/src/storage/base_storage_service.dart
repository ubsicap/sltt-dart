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

  /// Create a new change entry
  Future<BaseChangeLogEntry> createChange(Map<String, dynamic> changeData);

  Future<UpdateChangeLogAndStateResult> updateChangeLogAndState({
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
  Future<BaseEntityState?> getCurrentEntityState(
    String domainId,
    String entityType,
    String entityId,
  );

  /// Get a specific change by sequence number
  Future<BaseChangeLogEntry?> getChange(String domainId, int seq);

  /// Get changes with cursor-based pagination
  Future<List<BaseChangeLogEntry>> getChangesWithCursor({
    required String domainId,
    int? cursor,
    int? limit,
  });

  /// Get all changes since a specific sequence number
  Future<List<BaseChangeLogEntry>> getChangesSince(String domainId, int seq);

  /// Get statistics about change operations
  Future<Map<String, dynamic>> getChangeStats(String domainId);

  /// Get statistics about entity types
  Future<Map<String, dynamic>> getEntityTypeStats(String domainId);

  /// Get all projects (based on changes with entityType 'project')
  Future<List<String>> getAllProjects();

  /// Get entity state data for a specific entity type and project
  ///
  /// Subclasses can use StorageServiceDefaults.getEntityStates() for a default implementation that throws UnsupportedError
  Future<Map<String, dynamic>> getEntityStates({
    required String domainId,
    required String entityType,
    String? cursor,
    int? limit,
    bool includeMetadata = false,
  });

  /// Mark a change as outdated by another change
  Future<void> markAsOutdated(String projectId, int seq, int outdatedBy);

  /// Get changes that are not outdated (for local storage services)
  Future<List<BaseChangeLogEntry>> getChangesNotOutdated(
    String projectId,
  ) async {
    // Default implementation - override in local storage services
    return getChangesWithCursor(domainId: projectId);
  }

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
