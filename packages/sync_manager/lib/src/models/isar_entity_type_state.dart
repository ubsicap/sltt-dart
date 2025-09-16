import 'package:isar_community/isar.dart';

import 'sync_state.dart';

part 'isar_entity_type_state.g.dart';

/// Track latest sync state per entity type for a given domain
@collection
class IsarEntityTypeSyncState extends SyncState {
  final Id id;
  @Index(unique: true, replace: true, composite: [CompositeIndex('domainId')])
  final String entityType;
  // some basic entityType statistics
  int created = 0;
  int updated = 0;
  int deleted = 0;

  IsarEntityTypeSyncState({
    this.id = Isar.autoIncrement,
    required this.entityType,
    required super.domainId,
    required super.domainType,
    required super.storageId,
    required super.storageType,
    required super.cid,
    required super.changeAt,
    required super.seq,

    required this.created,
    required this.updated,
    required this.deleted,
    super.createdAt,
    super.updatedAt,
  });
}
