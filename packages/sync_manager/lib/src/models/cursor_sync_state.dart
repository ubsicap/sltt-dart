import 'package:isar/isar.dart';

import 'sync_state.dart';

part 'cursor_sync_state.g.dart';

@collection
class CursorSyncState extends SyncState {
  final Id id;

  CursorSyncState({
    this.id = Isar.autoIncrement,
    required super.domainId,
    required super.domainType,

    /// The storageId from which we are syncing changes
    required super.storageId,

    /// The storageType from which we are syncing changes
    required super.storageType,
    required super.cid,
    required super.changeAt,
    required super.seq,
    super.createdAt,
    super.updatedAt,
  });
}
