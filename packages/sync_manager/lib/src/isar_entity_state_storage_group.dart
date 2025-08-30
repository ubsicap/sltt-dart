import 'package:isar/isar.dart';
import 'package:sltt_core/sltt_core.dart';

/// Storage group for Isar entity state operations
///
/// This class encapsulates all the operations needed for a specific entity type:
/// - fromJson: Factory function to create instances from JSON
/// - put: Function to store instances in Isar database
/// - schema: Optional Isar schema for automatic registration during initialization
/// - collection: Function to get the collection from Isar
/// - findByDomainAndEntity: Function to find entity by domain ID and entity ID
///
/// Example usage:
/// ```dart
/// registerIsarEntityStateStorageGroup(
///   IsarEntityStateStorageGroup<IsarTaskState>(
///     entityType: EntityType.task,
///     fromJson: IsarTaskState.fromJson,
///     put: (state) async => await isar.isarTaskStates.put(state),
///     schema: IsarTaskStateSchema,
///     collection: (isar) => isar.isarTaskStates,
///     findByDomainAndEntity: (isar, projectId, entityId) =>
///       isar.isarTaskStates.filter()
///         .change_domainIdEqualTo(projectId)
///         .and()
///         .entityIdEqualTo(entityId)
///         .findFirst(),
///   ),
/// );
/// ```
class IsarEntityStateStorageGroup<T extends BaseEntityState> {
  final EntityType entityType;
  final T Function(Map<String, dynamic>) fromJson;
  final Future<void> Function(BaseEntityState) put;
  // schema removed - declare schema list separately in register_entity_states
  final dynamic Function(Isar) collection;
  final Future<T?> Function(Isar, String, String) findByDomainAndEntity;

  IsarEntityStateStorageGroup({
    required this.entityType,
    required this.fromJson,
    required this.put,
    // schema removed
    required this.collection,
    required this.findByDomainAndEntity,
  });
}

/// Registry for Isar entity state storage groups
final Map<EntityType, IsarEntityStateStorageGroup> _storageGroups = {};

/// Register an Isar entity state storage group
void registerIsarEntityStateStorageGroup<T extends BaseEntityState>(
  IsarEntityStateStorageGroup<T> group,
) {
  _storageGroups[group.entityType] = group;
}

/// Get the storage group for a specific entity type
IsarEntityStateStorageGroup? getEntityStateStorageGroup(EntityType entityType) {
  return _storageGroups[entityType];
}

/// Get all registered schemas for Isar initialization
List<CollectionSchema> getAllRegisteredSchemas() {
  // Schemas are defined explicitly in register_entity_states.dart
  return <CollectionSchema>[];
}

/// Get all registered entity types
List<EntityType> getAllRegisteredEntityTypes() {
  return _storageGroups.keys.toList();
}
