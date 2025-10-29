// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'dynamo_entity_type_sync_state.g.dart';

/// Track latest sync state per entity type for a given domain in DynamoDB.
/// This model extends SyncState to track entity type-specific synchronization
/// information and statistics.
@JsonSerializable(includeIfNull: true, checked: true)
class DynamoEntityTypeSyncState extends SyncState {
  /// The entity type being tracked (e.g., 'project', 'document', 'team')
  final String entityType;

  /// Number of entities created for this entity type
  int created;

  /// Number of entities updated for this entity type
  int updated;

  /// Number of entities deleted for this entity type
  int deleted;

  DynamoEntityTypeSyncState({
    required this.entityType,
    required super.domainId,
    required super.domainType,
    required super.storageId,
    required super.storageType,
    required super.cid,
    required super.changeAt,
    required super.seq,
    this.created = 0,
    this.updated = 0,
    this.deleted = 0,
    required super.storedAt,
    super.storedAt_orig_,
  });

  factory DynamoEntityTypeSyncState.fromJson(Map<String, dynamic> json) =>
      _$DynamoEntityTypeSyncStateFromJson(json);

  Map<String, dynamic> toJson() => _$DynamoEntityTypeSyncStateToJson(this);

  /// Create a composite key for DynamoDB queries (entityType + domainId)
  String get compositeKey => '$entityType#$domainId';

  /// Increment the created counter
  void incrementCreated() {
    created++;
  }

  /// Increment the updated counter
  void incrementUpdated() {
    updated++;
  }

  /// Increment the deleted counter
  void incrementDeleted() {
    deleted++;
  }

  /// Get total number of operations tracked
  int get totalOperations => created + updated + deleted;

  @override
  String toString() {
    return 'DynamoEntityTypeSyncState('
        'entityType: $entityType, '
        'domainId: $domainId, '
        'domainType: $domainType, '
        'storageId: $storageId, '
        'cid: $cid, '
        'seq: $seq, '
        'created: $created, '
        'updated: $updated, '
        'deleted: $deleted, '
        'changeAt: $changeAt, '
        'storedAt: $storedAt)';
  }
}
