import 'package:isar/isar.dart';
import 'package:sltt_core/sltt_core.dart';

/// Storage group for Isar entity state operations
///
/// This class encapsulates all the operations needed for a specific entity type:
/// - fromJson: Factory function to create instances from JSON
/// - put: Function to store instances in Isar database
/// - schema: Optional Isar schema for automatic registration during initialization
///
/// Example usage:
/// ```dart
/// registerIsarEntityStateStorageGroup(
///   IsarEntityStateStorageGroup<IsarTaskState>(
///     entityType: EntityType.task,
///     fromJson: IsarTaskState.fromJson,
///     put: (state) async => await isar.isarTaskStates.put(state),
///     schema: IsarTaskStateSchema,
///   ),
/// );
/// ```
class IsarEntityStateStorageGroup<T extends BaseEntityState> {
  final EntityType entityType;
  final T Function(Map<String, dynamic>) fromJson;
  final Future<void> Function(BaseEntityState) put;
  final CollectionSchema<T>? schema;
  IsarEntityStateStorageGroup({
    required this.entityType,
    required this.fromJson,
    required this.put,
    this.schema,
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
  return _storageGroups.values
      .where((group) => group.schema != null)
      .map((group) => group.schema!)
      .toList();
}

/// Get all registered entity types
List<EntityType> getAllRegisteredEntityTypes() {
  return _storageGroups.keys.toList();
}
