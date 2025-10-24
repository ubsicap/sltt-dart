// ignore_for_file: non_constant_identifier_names

import 'package:isar_community/isar.dart';

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
    required super.storedAt,
    super.storedAt_orig_,
  });
}
