import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/cursor_sync_state.dart';
import 'package:sync_manager/src/models/self_sync_state.dart';

import 'isar_entity_state_storage_group.dart';
import 'models/isar_change_log_entry.dart' as client;
import 'register_entity_states.dart';

/// Service function to create the correct Isar*State from JSON
///
/// This function first tries to use registered storage groups from the
/// IsarEntityStateStorageGroup system. If no storage group is found,
/// it falls back to hardcoded types for backwards compatibility.
///
/// To add a new entity type:
/// 1. Create your IsarXxxState class
/// 2. Register it using registerIsarEntityStateStorageGroup()
/// 3. The registration will automatically handle fromJson and put operations
BaseEntityState createIsarEntityStateFromJson(
  EntityType entityTypeEnum,
  Map<String, dynamic> json,
  String originalTypeString,
) {
  final storageGroup = getEntityStateStorageGroup(entityTypeEnum);
  if (storageGroup != null) {
    return storageGroup.fromJson(json);
  }

  throw UnimplementedError('Unknown entity type: $originalTypeString');
}

class IsarStorageService extends BaseStorageService {
  final String _databaseName;
  final String _logPrefix;

  late Isar _isar;
  bool _initialized = false;
  late String _storageId;

  IsarStorageService(this._databaseName, this._logPrefix);

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    // Create local directory for database
    final dir = Directory('./isar_db');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Initialize Isar with change log + sync state + registered entity schemas
    final schemas = <CollectionSchema>[
      SelfSyncStateSchema,
      CursorSyncStateSchema,
      client.IsarChangeLogEntrySchema,
      ...entityStateSchemas,
    ];

    // Initialize Isar with all schemas
    _isar = await Isar.open(schemas, directory: dir.path, name: _databaseName);

    // Now register the storage groups with the initialized Isar instance
    registerAllIsarEntityStateStorageGroups(_isar);

    _initialized = true;
    print(
      '[$_logPrefix] Isar database initialized at: ${dir.path}/$_databaseName.isar',
    );

    // Ensure storage ID is set
    _storageId = await ensureStorageId();
  }

  /// Helper method to convert IsarChangeLogEntry to BaseChangeLogEntry
  BaseChangeLogEntry _convertToChangeLogEntry(
    client.IsarChangeLogEntry clientEntry,
  ) {
    // Since BaseChangeLogEntry is abstract, we need to return the IsarChangeLogEntry itself
    // which extends BaseChangeLogEntry
    return clientEntry;
  }

  /// Helper method to convert list of IsarChangeLogEntry to list of BaseChangeLogEntry
  List<BaseChangeLogEntry> _convertToChangeLogEntries(
    List<client.IsarChangeLogEntry> clientEntries,
  ) {
    return clientEntries.map(_convertToChangeLogEntry).toList();
  }

  @override
  String getStorageType() => 'local';

  @override
  Future<String> getStorageId() async => _storageId;

  @override
  Future<String> ensureStorageId() async {
    // Try to find an existing SelfSyncState with the reserved root domainId.
    // If present, reuse its storageId. Otherwise create and persist a new one.
    try {
      final existing = await _isar.selfSyncStates
          .filter()
          .domainIdEqualTo('root')
          .findFirst();

      if (existing != null && existing.storageId.isNotEmpty) {
        _storageId = existing.storageId;
        return _storageId;
      }

      // Not found -> create a new canonical storage id and persist a SelfSyncState
      final newId = BaseStorageService.generateShortStorageId();
      final now = DateTime.now().toUtc();
      const kSelfStorage = 'self-storage';
      final self = IsarEntityTypeSyncState(
        domainType: 'storage',
        domainId: kSelfStorage,
        entityType: 'storage',
        storageId: newId,
        storageType: 'local',
        cid: newId,
        changeAt: now,
        seq: 0,
      );

      await _isar.writeTxn(() async {
        await _isar.selfSyncStates.put(self);
      });

      _storageId = newId;
      return _storageId;
    } catch (e) {
      // Fallback: if anything goes wrong, still generate an id but don't persist
      _storageId = BaseStorageService.generateShortStorageId();
      return _storageId;
    }
  }

  @override
  Future<UpdateChangeLogAndStateResult> updateChangeLogAndState({
    required String domainType,
    required BaseChangeLogEntry changeLogEntry,
    required Map<String, dynamic> changeUpdates,
    BaseEntityState? entityState,
    required Map<String, dynamic> stateUpdates,
  }) async {
    // Create updated change log entry
    final newChangeJson = {...changeLogEntry.toJson(), ...changeUpdates};
    final newChange = client.IsarChangeLogEntry.fromJson(newChangeJson);

    // Convert to appropriate Isar state type based on entity type
    final entityTypeEnum = EntityType.values.firstWhere(
      (e) => e.value == changeLogEntry.entityType,
      orElse: () => EntityType.unknown,
    );

    // Create or update entity state
    late final BaseEntityState newEntityState;
    if (entityState != null) {
      // Merge state updates into existing state
      print(
        'updateChangeLogAndState - before merge - entityState id: ${entityState.toJson()['id']}',
      );
      final mergedStateJson = {...entityState.toJson(), ...stateUpdates}
        ..removeWhere((k, v) => v == null);

      print(
        'updateChangeLogAndState - after merge - mergedStateJson id: ${mergedStateJson['id']}',
      );

      newEntityState = createIsarEntityStateFromJson(
        entityTypeEnum,
        mergedStateJson,
        changeLogEntry.entityType,
      );
    } else {
      // Create new entity state from state updates
      newEntityState = createIsarEntityStateFromJson(
        entityTypeEnum,
        stateUpdates,
        changeLogEntry.entityType,
      );
    }

    print(
      'updateChangeLogAndState - before put - newChange seq: ${newChange.seq}',
    );
    print(
      'updateChangeLogAndState - before put - newEntityState id: ${newEntityState.toJson()['id']}',
    );
    print(
      'updateChangeLogAndState - before put - newEntityState entityId: ${newEntityState.entityId}',
    );

    // Save both change and state in a transaction
    await _isar.writeTxn(() async {
      await _isar.collection<client.IsarChangeLogEntry>().put(newChange);

      print(
        'updateChangeLogAndState - after put - newChange id: ${newChange.seq}',
      );

      // Try to use registered storage group first
      final storageGroup = getEntityStateStorageGroup(entityTypeEnum);
      if (storageGroup != null) {
        await storageGroup.put(newEntityState);
      } else {
        throw UnimplementedError(
          'No storage group registered for entity type: ${changeLogEntry.entityType}',
        );
      }

      print(
        'updateChangeLogAndState - after put - newEntityState id: ${newEntityState.toJson()['id']}',
      );
    });

    return (
      newChangeLogEntry: _convertToChangeLogEntry(newChange),
      newEntityState: newEntityState,
    );
  }

  /// Create a new change log entry in the storage.
  ///
  /// Returns the created change log entry with auto-generated sequence number.
  @override
  Future<BaseChangeLogEntry> createChange({
    required String domainType,
    required Map<String, dynamic> changeData,
  }) async {
    print('changeData: ${jsonEncode(changeData)}');
    final change = client.IsarChangeLogEntry.fromJson(changeData);

    // Set cloudAt if this is a cloud storage service
    change.cloudAt ??= maybeCreateCloudAt();

    print('change: ${jsonEncode(change)}');
    await _isar.writeTxn(() async {
      await _isar.collection<client.IsarChangeLogEntry>().put(change);
    });

    // Return as base BaseChangeLogEntry
    return _convertToChangeLogEntry(change);
  }

  @override
  Future<BaseChangeLogEntry?> getChange({
    required String domainType,
    required String domainId,
    required String cid,
  }) async {
    final change = await _isar.isarChangeLogEntrys
        .where()
        .cidEqualTo(cid)
        .filter()
        .domainIdEqualTo(domainId)
        .and()
        .domainTypeEqualTo(domainType)
        .findFirst();
    return change != null ? _convertToChangeLogEntry(change) : null;
  }

  // COMMENTED OUT HELPER METHODS UNTIL FIXED
  /*
  Future<List<BaseChangeLogEntry>> getAllChanges() async {
    final results = await _isar.isarChangeLogEntrys
        .where()
        .sortByChangeAtDesc()
        .findAll();
    return _convertToChangeLogEntries(results);
  }

  Future<List<BaseChangeLogEntry>> getChangesByEntityType(
    EntityType entityType,
  ) async {
    final results = await _isar.isarChangeLogEntrys
        .filter()
        .entityTypeEqualTo(entityType)
        .sortByChangeAtDesc()
        .findAll();
    return _convertToChangeLogEntries(results);
  }

  Future<List<BaseChangeLogEntry>> getChangesByOperation(
    String operation,
  ) async {
    final results = await _isar.isarChangeLogEntrys
        .filter()
        .operationEqualTo(operation)
        .sortByChangeAtDesc()
        .findAll();
    return _convertToChangeLogEntries(results);
  }
  */

  // COMMENTED OUT HELPER METHODS THAT NEED TO BE FIXED LATER
  /*
  Future<List<BaseChangeLogEntry>> getChangesByEntityId(String entityId) async {
    final results = await _isar.isarChangeLogEntrys
        .filter()
        .entityIdEqualTo(entityId)
        .sortByChangeAtDesc()
        .findAll();
    return _convertToChangeLogEntries(results);
  }

  Future<List<BaseChangeLogEntry>> getChangesInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final results = await _isar.isarChangeLogEntrys
        .filter()
        .changeAtBetween(startDate, endDate)
        .sortByChangeAtDesc()
        .findAll();
    return _convertToChangeLogEntries(results);
  }

  /// Get the total count of change log entries.
  Future<int> getChangeCount() async {
    return await _isar.isarChangeLogEntrys.count();
  }
  */

  /// Delete multiple changes by sequence numbers.
  ///
  /// Used for cleanup after successful outsync operations.
  /// Returns the number of changes actually deleted.
  Future<int> deleteChanges(List<String> cids) async {
    int deletedCount = 0;
    await _isar.writeTxn(() async {
      deletedCount = await _isar.isarChangeLogEntrys.deleteAllByCid(cids);
    });
    return deletedCount;
  }

  // Statistics operations
  @override
  @override
  Future<Map<String, dynamic>> getChangeStats({
    required String domainType,
    required String domainId,
  }) async {
    final total = await _isar.isarChangeLogEntrys
        .filter()
        .domainIdEqualTo(domainId)
        .and()
        .domainTypeEqualTo(domainType)
        .count();
    final creates = await _isar.isarChangeLogEntrys
        .filter()
        .domainIdEqualTo(domainId)
        .and()
        .domainTypeEqualTo(domainType)
        .and()
        .operationEqualTo('create')
        .count();
    final updates = await _isar.isarChangeLogEntrys
        .filter()
        .domainIdEqualTo(domainId)
        .and()
        .domainTypeEqualTo(domainType)
        .and()
        .operationEqualTo('update')
        .count();
    final deletes = await _isar.isarChangeLogEntrys
        .filter()
        .domainIdEqualTo(domainId)
        .and()
        .domainTypeEqualTo(domainType)
        .and()
        .operationEqualTo('delete')
        .count();

    return {
      'total': total,
      'creates': creates,
      'updates': updates,
      'deletes': deletes,
    };
  }

  @override
  Future<Map<String, dynamic>> getEntityTypeStats({
    required String domainType,
    required String domainId,
  }) async {
    final allEntries = await _isar.isarChangeLogEntrys
        .filter()
        .domainIdEqualTo(domainId)
        .and()
        .domainTypeEqualTo(domainType)
        .findAll();
    final stats = <String, int>{};

    for (final entry in allEntries) {
      final entityTypeKey = entry.entityType;
      stats[entityTypeKey] = (stats[entityTypeKey] ?? 0) + 1;
    }

    return stats;
  }

  @override
  Future<void> close() async {
    if (_initialized) {
      await _isar.close();
      _initialized = false;
      print('[$_logPrefix] Isar database closed');
    }
  }

  // COMMENTED OUT - deleteOutdatedChanges needs collection fix
  /*
  /// Delete outdated changes to save storage space.
  ///
  /// This removes change log entries that have been marked as outdated
  /// by newer changes, helping to keep the storage size manageable.
  Future<int> deleteOutdatedChanges() async {
    final outdatedChanges = await _isar.isarChangeLogEntrys
        .filter()
        .outdatedByIsNotNull()
        .findAll();

    final seqsToDelete = outdatedChanges.map((e) => e.seq).toList();

    int deletedCount = 0;
    await _isar.writeTxn(() async {
      for (final seq in seqsToDelete) {
        if (await _isar.isarChangeLogEntrys.delete(seq)) {
          deletedCount++;
        }
      }
    });

    return deletedCount;
  }
  */

  // Cursor-based pagination and filtering
  @override
  Future<List<BaseChangeLogEntry>> getChangesWithCursor({
    required String domainType,
    required String domainId,
    int? cursor,
    int? limit,
  }) async {
    var query = _isar.isarChangeLogEntrys
        .where()
        .seqGreaterThan(cursor ?? 0)
        .filter()
        .domainIdEqualTo(domainId)
        .and()
        .domainTypeEqualTo(domainType);

    var results = await query.findAll();

    if (limit != null && results.length > limit) {
      results = results.sublist(0, limit);
    }
    return _convertToChangeLogEntries(results);
  }

  /// Get changes for syncing - excludes outdated changes.
  ///
  /// Returns only changes that haven't been marked as outdated,
  /// which prevents syncing obsolete change log entries.
  Future<List<BaseChangeLogEntry>> getChangesNotOutdated(
    String projectId,
  ) async {
    var results = await _isar.isarChangeLogEntrys
        .where()
        .filter()
        .domainIdEqualTo(projectId)
        .findAll();
    return _convertToChangeLogEntries(results);
  }

  /// Get changes for syncing - excludes outdated changes.
  ///
  /// Returns only changes that haven't been cloud-synced yet.
  Future<List<client.IsarChangeLogEntry>> getChangesForSync({
    int? cursor,
    int? limit,
  }) async {
    var query = _isar.isarChangeLogEntrys.where();
    var results = await query
        .seqGreaterThan(cursor ?? 0)
        .filter()
        .cloudAtIsNotNull()
        .findAll();

    if (limit != null && results.length > limit) {
      results = results.sublist(0, limit);
    }
    return results;
  }

  // COMMENTED OUT - markAsOutdated needs collection fix (this is the duplicate)
  /*
  /// Mark a change as outdated by another change.
  ///
  /// Updates the outdatedBy field to indicate this change has been
  /// superseded by a newer change with the specified sequence number.
  @override
  Future<void> markAsOutdated(
    String projectId,
    int seq,
    int outdatedBySeq,
  ) async {
    await _isar.writeTxn(() async {
      final change = await _isar.isarChangeLogEntrys.get(seq);
      if (change != null && change.projectId == projectId) {
        change.outdatedBy = outdatedBySeq;
        await _isar.isarChangeLogEntrys.put(change);
      }
    });
  }
  */

  // COMMENTED OUT - getLastSeq needs collection fix
  /*
  // Get the highest sequence number in the database
  Future<int> getLastSeq() async {
    final result = await _isar.isarChangeLogEntrys.where().findAll();
    if (result.isEmpty) {
      return 0;
    }
    return result.map((e) => e.seq).reduce((a, b) => a > b ? a : b);
  }
  */

  // Get changes since a specific sequence number (for syncing)
  Future<List<BaseChangeLogEntry>> getChangesSince(
    String domainId,
    int seq,
  ) async {
    final results = await _isar.isarChangeLogEntrys
        .where()
        .seqGreaterThan(seq)
        .filter()
        .domainIdEqualTo(domainId)
        .findAll();

    // Sort by seq in ascending order
    results.sort((a, b) => a.seq.compareTo(b.seq));
    return _convertToChangeLogEntries(results);
  }

  // COMMENTED OUT FOR NOW - TO BE FIXED LATER
  /*
  // Store multiple changes (for batch operations)
  Future<List<BaseChangeLogEntry>> createChanges(
    List<Map<String, dynamic>> changesData,
  ) async {
    final changes = changesData
        .map((changeData) => client.IsarChangeLogEntry.fromJson(changeData))
        .toList();

    // Set cloudAt for changes if this is a cloud storage service
    for (final change in changes) {
      change.cloudAt ??= maybeCreateCloudAt();
    }

    await _isar.writeTxn(() async {
      await _isar.collection<client.IsarChangeLogEntry>().putAll(changes);
    });

    // Convert IsarChangeLogEntry to BaseChangeLogEntry for the interface
    return changes
        .map(
          (clientEntry) => _convertToChangeLogEntry(clientEntry),
        )
        .toList();
  }
  */

  /// Get the current state of an entity for field-level comparison
  @override
  Future<BaseEntityState?> getCurrentEntityState({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
  }) async {
    // Convert entityType string to EntityType enum
    // Map the incoming entityType string to the enum. `firstWhere` with
    // `orElse` will return `EntityType.unknown` when no match is found and
    // will not throw, so an explicit try/catch is unnecessary.
    final entityTypeEnum = EntityType.values.firstWhere(
      (e) => e.value == entityType,
      orElse: () => EntityType.unknown,
    );

    if (entityTypeEnum == EntityType.unknown) {
      print('getCurrentEntityState - Unknown entity type: "$entityType"');
      return null;
    }

    final storageGroup = getEntityStateStorageGroup(entityTypeEnum);
    if (storageGroup == null) {
      throw Exception('Storage group not found: $entityTypeEnum');
    }

    // Use the type-safe finder function instead of dynamic collection access
    return await storageGroup.findByDomainAndEntity(_isar, domainId, entityId);
  }

  @override
  Future<Map<String, dynamic>> getEntityState({
    required String domainType,
    required String domainId,
    required String entityId,
    bool includeMetadata = false,
  }) async {
    // Search all registered storage groups for the entity
    final entityTypes = getAllRegisteredEntityTypes();
    for (final et in entityTypes) {
      final group = getEntityStateStorageGroup(et);
      if (group == null) continue;
      final state = await group.findByDomainAndEntity(
        _isar,
        domainId,
        entityId,
      );
      if (state != null) return state.toJson();
    }
    return <String, dynamic>{};
  }

  /// Hook method for subclasses to optionally add cloud timestamp.
  /// Override this in CloudStorageService to return DateTime.now().
  DateTime? maybeCreateCloudAt() => null;

  /// Delete all changes - useful for testing cleanup
  Future<int> deleteAllChanges() async {
    final allChanges = await _isar.isarChangeLogEntrys.where().findAll();

    final seqsToDelete = allChanges.map((e) => e.seq).toList();

    int deletedCount = 0;
    await _isar.writeTxn(() async {
      for (final seq in seqsToDelete) {
        if (await _isar.isarChangeLogEntrys.delete(seq)) {
          deletedCount++;
        }
      }
    });

    return deletedCount;
  }

  /// Get all unique project IDs across all entityStates
  @override
  Future<List<String>> getAllDomainIds({required String domainType}) async {
    final allChanges = await _isar.isarChangeLogEntrys
        .filter()
        .domainTypeEqualTo(domainType)
        .findAll();

    // Extract unique domain IDs
    final domainIds = <String>{};
    for (final change in allChanges) {
      if (change.domainId.isNotEmpty) {
        domainIds.add(change.domainId);
      }
    }

    return domainIds.toList()..sort();
  }

  /// Get sync state for a specific project
  Future<CursorSyncState?> getCursorSyncState(String domainId) async {
    return await _isar
        .collection<CursorSyncState>()
        .filter()
        .domainIdEqualTo(domainId)
        .findFirst();
  }

  // STUBBED METHODS THAT NEED TO BE PROPERLY IMPLEMENTED LATER

  Future<void> markAsOutdated(String projectId, int seq, int outdatedBy) async {
    // TODO: Implement when fixing Isar queries
    // For now, just stub this out
  }

  /// Create or update sync state for a project
  Future<CursorSyncState> upsertCursorSyncState({
    required String domainType,
    required String domainId,
    required String srcStorageType,
    required String srcStorageId,
    required int seq,
    required String cid,
    required DateTime changeAt,
  }) async {
    CursorSyncState updatedCursorState;
    final existing = await getCursorSyncState(domainId);
    if (existing != null) {
      /*
          required super.domainId,
          required super.domainType,
          required super.storageId,
          required super.storageType,
          required super.cid,
          required super.changeAt,
          required super.seq,
          super.createdAt,
          super.updatedAt,
      */
      // Update existing
      updatedCursorState = CursorSyncState(
        id: existing.id,
        domainId: existing.domainId,
        domainType: existing.domainType,
        storageId: srcStorageId,
        storageType: srcStorageType,
        cid: cid,
        changeAt: changeAt,
        seq: seq,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now().toUtc(),
      );
    } else {
      // Create new
      final now = DateTime.now().toUtc();
      updatedCursorState = CursorSyncState(
        domainId: domainId,
        domainType: domainType,
        storageId: srcStorageId,
        storageType: srcStorageType,
        cid: cid,
        changeAt: changeAt,
        seq: seq,
        createdAt: now,
        updatedAt: now,
      );
    }
    await _isar.writeTxn(() async {
      await _isar.cursorSyncStates.put(updatedCursorState);
    });
    return updatedCursorState;
  }

  /*
  /// Get all sync states
  Future<List<SyncState>> getAllSyncStates() async {
    return await _isar.syncStates.where().findAll();
  }

  /// Delete sync state for a project
  Future<bool> deleteSyncState(String projectId) async {
    // TODO: Implement when fixing sync state management
    return false;
  }
  */

  /// Clear all sync states (useful for testing)
  Future<void> clearAllCursorSyncStates() async {
    await _isar.writeTxn(() async {
      await _isar.cursorSyncStates.clear();
    });
  }

  /*

  // State management methods for IsarProjectState
  Future<void> saveProjectState(IsarProjectState projectState) async {
    await _isar.writeTxn(() async {
      await _isar.isarProjectStates.put(projectState);
    });
  }

  Future<IsarProjectState?> getProjectState(String projectId) async {
    return await _isar.isarProjectStates
        .filter()
        .change_domainIdEqualTo(projectId)
        .findFirst();
  }

  Future<List<IsarProjectState>> getAllProjectStates() async {
    return await _isar.isarProjectStates.where().findAll();
  }

  Future<bool> deleteProjectState(String projectId) async {
    // TODO: Implement when fixing project state management
    return false;
  }

  // State management methods for IsarTeamState
  Future<void> saveTeamState(IsarTeamState teamState) async {
    await _isar.writeTxn(() async {
      await _isar.isarTeamStates.put(teamState);
    });
  }

  Future<IsarTeamState?> getTeamState(String teamId) async {
    return await _isar.isarTeamStates
        .filter()
        .entityIdEqualTo(teamId)
        .findFirst();
  }

  Future<List<IsarTeamState>> getAllTeamStates() async {
    return await _isar.isarTeamStates.where().findAll();
  }

  Future<bool> deleteTeamState(String teamId) async {
    // TODO: Implement when fixing team state management
    return false;
  }

  /// Applies a changelog entry to the appropriate state collection
  /// Returns the updated state entity
  Future<dynamic> applyChangelogToState(
    client.IsarChangeLogEntry changeLogEntry,
  ) async {
    // TODO: Fix when implementing state application logic
    throw UnimplementedError('State application needs to be implemented');
  }

  /// Applies changelog entry to project state
  Future<IsarProjectState> _applyChangelogToProjectState(
    client.IsarChangeLogEntry changeLogEntry,
  ) async {
    // TODO: Fix when implementing project state updates
    throw UnimplementedError('Project state updates need to be implemented');
  }

  /// Applies changelog entry to team state
  Future<IsarTeamState> _applyChangelogToTeamState(
    client.IsarChangeLogEntry changeLogEntry,
  ) async {
    // TODO: Fix when implementing team state updates
    throw UnimplementedError('Team state updates need to be implemented');
  }

  /// Applies changelog entry to document state
  Future<IsarDocumentState> _applyChangelogToDocumentState(
    client.IsarChangeLogEntry changeLogEntry,
  ) async {
    // TODO: Fix when implementing document state updates
    throw UnimplementedError('Document state updates need to be implemented');
  }

  /// Gets document state by entity ID
  Future<IsarDocumentState?> getDocumentState(String entityId) async {
    return await _isar.isarDocumentStates
        .filter()
        .entityIdEqualTo(entityId)
        .findFirst();
  }

  /// Saves document state
  Future<void> saveDocumentState(IsarDocumentState documentState) async {
    await _isar.writeTxn(() async {
      await _isar.isarDocumentStates.put(documentState);
    });
  }
  */

  @override
  Future<Map<String, dynamic>> getEntityStates({
    required String domainType,
    required String domainId,
    required String entityType,
    String? cursor,
    int? limit,
    bool includeMetadata = false,
  }) async {
    try {
      // Simple stub implementation that returns empty results
      // TODO: Implement proper entity state querying once Isar models are fixed
      return {
        'items': <Map<String, dynamic>>[],
        'hasMore': false,
        'nextCursor': null,
      };
    } on ArgumentError {
      // Re-throw ArgumentError so it can be caught by the API handler as a 400 error
      rethrow;
    } on StateError {
      // Convert StateError to ArgumentError for proper API error handling
      throw ArgumentError('Unsupported entity type: $entityType');
    } catch (e) {
      throw Exception('Failed to get entity states: $e');
    }
  }

  // STUBBED HELPER METHODS FOR PAGINATION - TO BE IMPLEMENTED LATER
  /*
  Future<Map<String, dynamic>> _getProjectStatesWithPagination(
    String projectId,
    int limit,
    String? cursor,
    bool includeMetadata,
  ) async {
    final query = _isar.isarProjectStates.filter().change_domainIdEqualTo(projectId);

    final queryWithCursor = cursor != null
        ? query.entityIdGreaterThan(cursor)
        : query;

    final entities = await queryWithCursor
        .sortByEntityId()
        .limit(limit + 1)
        .findAll();

    final hasMore = entities.length > limit;
    final resultEntities = hasMore ? entities.take(limit).toList() : entities;

    return {
      'items': resultEntities
          .map((e) => _projectStateToMap(e, includeMetadata))
          .toList(),
      'hasMore': hasMore,
      'nextCursor': hasMore ? resultEntities.last.entityId : null,
    };
  }
  */
}

// Singleton wrappers for each storage type
class OutsyncsStorageService extends IsarStorageService {
  static OutsyncsStorageService? _instance;
  static OutsyncsStorageService get instance =>
      _instance ??= OutsyncsStorageService._();

  OutsyncsStorageService._() : super('outsyncs', 'OutsyncsStorage');
}

class CloudStorageService extends IsarStorageService {
  static CloudStorageService? _instance;
  static CloudStorageService get instance =>
      _instance ??= CloudStorageService._();

  CloudStorageService._() : super('cloud_storage', 'CloudStorage');

  @override
  DateTime? maybeCreateCloudAt() => DateTime.now().toUtc();

  @override
  Future<BaseChangeLogEntry> createChange({
    required String domainType,
    required Map<String, dynamic> changeData,
  }) async {
    print('changeData: ${jsonEncode(changeData)}');

    // For cloud storage, always force sequence auto-generation by removing seq
    final cloudChangeData = Map<String, dynamic>.from(changeData);
    cloudChangeData.remove('seq'); // Force auto-increment in cloud storage

    final change = client.IsarChangeLogEntry.fromJson(cloudChangeData);

    // Set cloudAt since this is a cloud storage service
    change.cloudAt ??= maybeCreateCloudAt();

    print('change: ${jsonEncode(change)}');
    await _isar.writeTxn(() async {
      await _isar.collection<client.IsarChangeLogEntry>().put(change);
    });

    // Return as base BaseChangeLogEntry
    return _convertToChangeLogEntry(change);
  }
}
