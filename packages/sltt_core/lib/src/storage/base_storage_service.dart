import '../models/base_change_log_entry.dart';
import '../services/field_change_detector.dart';

/// Result of creating changes with field-level change detection
class CreateChangesResult {
  /// Successfully created changes
  final List<ChangeLogEntry> createdChanges;

  /// Changes that resulted in no actual updates (no-op changes)
  final List<String> noOpChangeCids;

  /// Field change details for each processed change
  final Map<String, FieldChangeResult> changeDetails;

  CreateChangesResult({
    required this.createdChanges,
    required this.noOpChangeCids,
    required this.changeDetails,
  });
}

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

  /// Create changes with field-level change detection and no-op tracking
  ///
  /// This is the enhanced version that detects when field values haven't
  /// actually changed and returns information about which changes were no-ops.
  /// Implementations should override this for full field-level change detection.
  Future<CreateChangesResult> createChangesWithChangeDetection(
    List<Map<String, dynamic>> changesData,
  ) async {
    // Default implementation - fallback to basic createChange
    final createdChanges = <ChangeLogEntry>[];
    final changeDetails = <String, FieldChangeResult>{};

    for (final changeData in changesData) {
      final created = await createChange(changeData);
      createdChanges.add(created);

      // Default assumes all changes resulted in updates (no field-level detection)
      changeDetails[created.cid] = FieldChangeResult(
        updatedFields: (changeData['data'] as Map<String, dynamic>? ?? {}).keys
            .toList(),
        noOpFields: [],
        totalFields: (changeData['data'] as Map<String, dynamic>? ?? {}).length,
      );
    }

    return CreateChangesResult(
      createdChanges: createdChanges,
      noOpChangeCids: [], // Default implementation doesn't detect no-ops
      changeDetails: changeDetails,
    );
  }

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

  /// Get supported entity types for a project
  Future<List<String>> getSupportedEntityTypes(String projectId) async {
    // Default implementation - return all entity types that have changes
    final entityTypeStats = await getEntityTypeStats(projectId);
    return (entityTypeStats['entityTypeStats'] as Map<String, dynamic>? ?? {})
        .keys
        .toList();
  }

  /// Get entity state data for a specific entity type and project
  Future<Map<String, dynamic>> getEntityStates({
    required String projectId,
    required String entityType,
    String? cursor,
    int? limit,
    bool includeMetadata = false,
  }) async {
    // Default implementation - not supported for all storage types
    throw UnsupportedError(
      'getEntityStates not supported by this storage service',
    );
  }

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
