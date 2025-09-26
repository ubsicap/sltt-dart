import 'dart:async';

import 'package:isar_community/isar.dart';
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
  final IsarCollection<T> Function(Isar) collection;
  final Future<T?> Function(Isar, String, String) findByDomainAndEntity;
  final Future<List<T>> Function({
    required String domainId,
    String? cursor,
    int? limit,
    String? parentId,
    String? parentProp,
  })
  findByDomainWithPagination;

  final StreamSubscription<void> Function({
    required String domainType,
    required String domainId,
    required String entityType,
    String? entityId,
    String? parentId,
    String? parentProp,
    required void Function() onChanged,
    bool fireImmediately,
  })?
  lazyListenToEntityChanges;

  Future<void> Function({required String domainType, required String domainId})
  deleteByDomain;

  IsarEntityStateStorageGroup({
    required this.entityType,
    required this.fromJson,
    required this.put,
    required this.collection,
    required this.findByDomainAndEntity,
    required this.findByDomainWithPagination,
    required this.deleteByDomain,
    this.lazyListenToEntityChanges,
  });
}

/// Registry container that stores entity state storage groups. Each
/// `IsarStorageService` instance should own its own registry so that
/// multiple services can coexist without sharing registrations.
class IsarEntityStateStorageRegistry {
  final Map<EntityType, IsarEntityStateStorageGroup> _storageGroups = {};

  /// Register or replace the storage group for the given entity type.
  void register<T extends BaseEntityState>(
    IsarEntityStateStorageGroup<T> group,
  ) {
    _storageGroups[group.entityType] = group;
  }

  /// Retrieve the storage group for the specified entity type, if registered.
  IsarEntityStateStorageGroup? get(EntityType entityType) {
    return _storageGroups[entityType];
  }

  /// Return all registered storage groups as an immutable list.
  List<IsarEntityStateStorageGroup> allGroups() {
    return _storageGroups.values.toList(growable: false);
  }

  /// Return all registered entity types as an immutable list.
  List<EntityType> registeredEntityTypes() {
    return _storageGroups.keys.toList(growable: false);
  }

  /// Remove all registered groups.
  void clear() => _storageGroups.clear();
}
