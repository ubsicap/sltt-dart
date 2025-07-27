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
  Future<Map<String, dynamic>> createChange(Map<String, dynamic> changeData);

  /// Get a specific change by sequence number
  Future<Map<String, dynamic>?> getChange(int seq);

  /// Get changes with cursor-based pagination
  Future<List<Map<String, dynamic>>> getChangesWithCursor({
    int? cursor,
    int? limit,
  });

  /// Get all changes since a specific sequence number
  Future<List<Map<String, dynamic>>> getChangesSince(int seq);

  /// Get statistics about change operations
  Future<Map<String, dynamic>> getChangeStats();

  /// Get statistics about entity types
  Future<Map<String, dynamic>> getEntityTypeStats();

  /// Mark a change as outdated (for local storage services)
  Future<void> markAsOutdated(int seq, int outdatedBy) async {
    // Default implementation - override in local storage services
    throw UnsupportedError('markAsOutdated not supported by this storage service');
  }

  /// Get changes that are not outdated (for local storage services)  
  Future<List<Map<String, dynamic>>> getChangesNotOutdated() async {
    // Default implementation - override in local storage services
    return getChangesWithCursor();
  }
}
