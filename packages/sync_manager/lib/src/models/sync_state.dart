/// Tracks the last sync state for each domain.
/// This collection does not inherit from BaseEntityState as it's purely
/// for sync tracking and doesn't represent domain entity data.
abstract class SyncState {
  /// Domain ID (primary key for sync tracking)
  final String domainId;

  final String domainType;

  final String storageId;

  final String storageType;

  /// ID of the last change log entry that was synced
  final String cid;

  /// Timestamp of the last change that was synced
  final DateTime changeAt;

  /// Sequence number of the last change that was synced
  final int seq;

  /// Local datetime when this sync state was created
  /// expect to always be set, either by default or from deserialization
  final DateTime? createdAt;

  /// Local datetime when this sync state was last updated
  /// expect to always be set, either by default or from deserialization
  final DateTime? updatedAt;

  SyncState({
    required this.domainId,
    required this.domainType,
    required this.storageId,
    required this.storageType,
    required this.cid,
    required this.changeAt,
    required this.seq,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
}
