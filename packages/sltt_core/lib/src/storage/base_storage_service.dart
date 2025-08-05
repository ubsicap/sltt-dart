import '../models/base_change_log_entry.dart';
import '../services/change_analysis_service.dart';
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

/// Default implementation functions that storage services can use
class StorageServiceDefaults {
  /// Default implementation for getting supported entity types
  static Future<List<String>> getSupportedEntityTypes(
    Future<Map<String, dynamic>> Function(String) getEntityTypeStats,
    String projectId,
  ) async {
    final entityTypeStats = await getEntityTypeStats(projectId);
    return (entityTypeStats['entityTypeStats'] as Map<String, dynamic>? ?? {})
        .keys
        .toList();
  }

  /// Default implementation for getting changes not outdated
  static Future<List<ChangeLogEntry>> getChangesNotOutdated(
    Future<List<ChangeLogEntry>> Function({
      required String projectId,
      int? cursor,
      int? limit,
    })
    getChangesWithCursor,
    String projectId,
  ) async {
    return getChangesWithCursor(projectId: projectId);
  }
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
  /// This method uses the pure analyzeChanges function to determine what should
  /// be stored, then calls the appropriate storage methods.
  Future<CreateChangesResult> createChangesWithChangeDetection(
    List<Map<String, dynamic>> changesData,
  ) async {
    // Use the pure function to analyze what needs to be done
    final analysis = await analyzeChanges(changesData, getCurrentEntityState);

    final createdChanges = <ChangeLogEntry>[];

    // Create the changes that were determined to be necessary
    for (final analyzedChange in analysis.changesToCreate) {
      final change = await createChange(analyzedChange.changeData);
      createdChanges.add(change);
    }

    return CreateChangesResult(
      createdChanges: createdChanges,
      noOpChangeCids: analysis.noOpChangeCids,
      changeDetails: analysis.changeDetails,
    );
  }

  /// Get the current state of an entity for field-level comparison.
  ///
  /// Storage implementations should override this method to provide entity lookup.
  /// This is used by the field-level change detection to determine what fields
  /// have actually changed.
  ///
  /// Returns the most recent change entry for the specified entity, or null if
  /// the entity doesn't exist.
  Future<ChangeLogEntry?> getCurrentEntityState(
    String projectId,
    String entityType,
    String entityId,
  );

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
  ///
  /// Subclasses can use StorageServiceDefaults.getSupportedEntityTypes() for a default implementation
  Future<List<String>> getSupportedEntityTypes(String projectId);

  /// Get entity state data for a specific entity type and project
  ///
  /// Subclasses can use StorageServiceDefaults.getEntityStates() for a default implementation that throws UnsupportedError
  Future<Map<String, dynamic>> getEntityStates({
    required String projectId,
    required String entityType,
    String? cursor,
    int? limit,
    bool includeMetadata = false,
  });

  /// Mark a change as outdated by another change
  Future<void> markAsOutdated(String projectId, int seq, int outdatedBy);

  /// Get changes that are not outdated (for local storage services)
  Future<List<ChangeLogEntry>> getChangesNotOutdated(String projectId) async {
    // Default implementation - override in local storage services
    return getChangesWithCursor(projectId: projectId);
  }
}
