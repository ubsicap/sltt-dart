import 'package:uuid/uuid.dart';

// Base mixin for common entity fields
mixin BaseEntityMixin {
  late String uuid;
  late DateTime createdAt;
  late DateTime updatedAt;
  SyncStatus syncStatus = SyncStatus.local;
  String? lastSyncedAt;
  
  void initializeEntity() {
    uuid = const Uuid().v7();
    final now = DateTime.now();
    createdAt = now;
    updatedAt = now;
  }
  
  void markUpdated() {
    updatedAt = DateTime.now();
    syncStatus = SyncStatus.pending;
  }
  
  void markSynced(SyncTarget target) {
    lastSyncedAt = DateTime.now().toIso8601String();
    if (target == SyncTarget.cloud) {
      syncStatus = SyncStatus.synced;
    }
  }
}

enum SyncStatus {
  local,     // Only exists locally
  pending,   // Has local changes, needs sync
  syncing,   // Currently syncing
  synced,    // Synced to cloud
  conflict   // Sync conflict detected
}

enum SyncTarget {
  lan,
  cloud
}
