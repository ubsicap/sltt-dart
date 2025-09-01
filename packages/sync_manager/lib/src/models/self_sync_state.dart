import 'package:isar/isar.dart';

import 'sync_state.dart';

part 'self_sync_state.g.dart';

@collection
class SelfSyncState extends SyncState {
  SelfSyncState({
    required super.domainId,
    required super.domainType,
    required super.storageId,
    required super.storageType,
    required super.cid,
    required super.changeAt,
    required super.seq,
  });
}
