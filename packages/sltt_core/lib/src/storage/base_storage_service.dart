import '../models/change_log_entry.dart';

/// Abstract base class for all storage service implementations.
///
/// This interface defines the contract that all storage services must implement,
/// whether they use local Isar databases, DynamoDB, or other storage backends.
abstract class BaseStorageService {
  /// Initialize the storage service
  Future<void> initialize();

  /// Close and cleanup the storage service
  Future<void> close();

  /// Create a new change entry
  Future<ChangeLogEntry> createChange(Map<String, dynamic> changeData);

  /// Get a specific change by sequence number
  Future<ChangeLogEntry?> getChange(String projectId, int seq);

  /// Get changes with cursor-based pagination
  Future<List<ChangeLogEntry>> getChangesWithCursor({
    required String projectId,
    int? cursor,
    int? limit,
  });

  /// Get all changes since a specific sequence number
  Future<List<ChangeLogEntry>> getChangesSince(String projectId, int seq);

  /// Get statistics about change operations
  Future<Map<String, dynamic>> getChangeStats(String projectId);

  /// Get statistics about entity types
  Future<Map<String, dynamic>> getEntityTypeStats(String projectId);

  /// Get all projects (based on changes with entityType 'project')
  Future<List<String>> getAllProjects();

  /// Mark a change as outdated (for local storage services)
  Future<void> markAsOutdated(String projectId, int seq, int outdatedBy) async {
    // Default implementation - override in local storage services
    throw UnsupportedError(
      'markAsOutdated not supported by this storage service',
    );
  }

  /// Get changes that are not outdated (for local storage services)
  Future<List<ChangeLogEntry>> getChangesNotOutdated(String projectId) async {
    // Default implementation - override in local storage services
    return getChangesWithCursor(projectId: projectId);
  }
}
