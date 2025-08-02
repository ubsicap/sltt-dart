import 'package:isar/isar.dart';

part 'sync_state.g.dart';

/// Tracks the last sync state for each project.
/// This collection does not inherit from BaseEntityState as it's purely
/// for sync tracking and doesn't represent domain entities.
@collection
class SyncState {
  /// Unique identifier for this sync state entry
  Id id = Isar.autoIncrement;

  /// Project ID (primary key for sync tracking)
  @Index(unique: true)
  late String projectId;

  /// ID of the last change log entry that was synced
  String? changeLogId;

  /// Timestamp of the last change that was synced
  DateTime? lastChangeAt;

  /// Sequence number of the last change that was synced
  int? lastSeq;

  /// When this sync state was created
  @Index()
  late DateTime createdAt;

  /// When this sync state was last updated
  @Index()
  late DateTime updatedAt;

  SyncState();

  /// Create a new sync state for a project
  SyncState.forProject(this.projectId) {
    final now = DateTime.now();
    createdAt = now;
    updatedAt = now;
  }

  /// Update the sync state with new sync information
  void updateSync({String? changeLogId, DateTime? lastChangeAt, int? lastSeq}) {
    if (changeLogId != null) this.changeLogId = changeLogId;
    if (lastChangeAt != null) this.lastChangeAt = lastChangeAt;
    if (lastSeq != null) this.lastSeq = lastSeq;
    updatedAt = DateTime.now();
  }

  /// Convert to JSON for debugging/logging
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'changeLogId': changeLogId,
      'lastChangeAt': lastChangeAt?.toIso8601String(),
      'lastSeq': lastSeq,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SyncState(projectId: $projectId, changeLogId: $changeLogId, '
        'lastSeq: $lastSeq, lastChangeAt: $lastChangeAt)';
  }
}
