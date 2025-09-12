import 'package:isar/isar.dart';

import 'sync_state.dart';

part 'self_sync_state.g.dart';

/// Track latest sync state per entity type for a given domain
@collection
class IsarSelfEntityTypeSyncState extends SyncState {
  final Id id;
  @Index(
    unique: true,
    replace: true,
    composite: [CompositeIndex('domainId'), CompositeIndex('entityType')],
  )
  final String entityType;
  // some basic entityType statistics
  int created = Isar.autoIncrement;
  int updated = Isar.autoIncrement;
  int deleted = Isar.autoIncrement;

  IsarSelfEntityTypeSyncState({
    this.id = Isar.autoIncrement,
    required this.entityType,
    required super.domainId,
    required super.domainType,
    required super.storageId,
    required super.storageType,
    required super.cid,
    required super.changeAt,
    required super.seq,
    super.createdAt,
    super.updatedAt,
  });
}
