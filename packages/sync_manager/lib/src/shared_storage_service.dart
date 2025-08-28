import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:sltt_core/sltt_core.dart';

import 'models/isar_change_log_entry.dart' as client;
import 'models/isar_document_state.dart';
import 'models/isar_project_state.dart';
import 'models/isar_team_state.dart';
import 'models/sync_state.dart';

class LocalStorageService extends BaseStorageService {
  final String _databaseName;
  final String _logPrefix;

  late Isar _isar;
  bool _initialized = false;
  late String _storageId;

  LocalStorageService(this._databaseName, this._logPrefix);

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
  Future<void> initialize() async {
    if (_initialized) return;

    // Create local directory for database
    final dir = Directory('./isar_db');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Initialize Isar with the specified database name
    _isar = await Isar.open(
      [
        client.IsarChangeLogEntrySchema,
        SyncStateSchema,
        IsarDocumentStateSchema,
        IsarProjectStateSchema,
        IsarTeamStateSchema,
      ],
      directory: dir.path,
      name: _databaseName,
    );

    _initialized = true;
    print(
      '[$_logPrefix] Isar database initialized at: ${dir.path}/$_databaseName.isar',
    );

    // Ensure storage ID is set
    _storageId = await ensureStorageId();
  }

  @override
  String getStorageType() => 'local';

  @override
  Future<String> getStorageId() async => _storageId;

  @override
  Future<String> ensureStorageId() async {
    // Generate a unique storage ID based on database name and timestamp
    _storageId = BaseStorageService.generateShortStorageId();
    return _storageId;
  }

  @override
  Future<UpdateChangeLogAndStateResult> updateChangeLogAndState({
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

      switch (entityTypeEnum) {
        case EntityType.project:
          newEntityState = IsarProjectState.fromJson(mergedStateJson);
          break;
        case EntityType.document:
          newEntityState = IsarDocumentState.fromJson(mergedStateJson);
          break;
        case EntityType.team:
          newEntityState = IsarTeamState.fromJson(mergedStateJson);
          break;
        default:
          throw UnimplementedError(
            'Unknown entity type: ${changeLogEntry.entityType}',
          );
      }
    } else {
      // Create new entity state from state updates
      switch (entityTypeEnum) {
        case EntityType.project:
          newEntityState = IsarProjectState.fromJson(stateUpdates);
          break;
        case EntityType.document:
          newEntityState = IsarDocumentState.fromJson(stateUpdates);
          break;
        case EntityType.team:
          newEntityState = IsarTeamState.fromJson(stateUpdates);
          break;
        default:
          // Fallback to document state
          // TODO: safeJson with unknown?
          throw UnimplementedError(
            'Unknown entity type: ${changeLogEntry.entityType}',
          );
      }
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

      switch (entityTypeEnum) {
        case EntityType.project:
          await _isar.isarProjectStates.put(newEntityState as IsarProjectState);
          break;
        case EntityType.document:
          await _isar.isarDocumentStates.put(
            newEntityState as IsarDocumentState,
          );
          break;
        case EntityType.team:
          await _isar.isarTeamStates.put(newEntityState as IsarTeamState);
          break;
        default:
          // Handle all other entity types (plan, stage, unknown, etc.)
          // TODO: Add proper state storage for each type when models are available
          break;
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
  Future<BaseChangeLogEntry> createChange(
    Map<String, dynamic> changeData,
  ) async {
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
  Future<BaseChangeLogEntry?> getChange(String projectId, int seq) async {
    final change = await _isar.isarChangeLogEntrys
        .where()
        .seqEqualTo(seq)
        .filter()
        .domainIdEqualTo(projectId)
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

  /// Delete multiple changes by sequence numbers.
  ///
  /// Used for cleanup after successful outsync operations.
  /// Returns the number of changes actually deleted.
  Future<int> deleteChanges(List<int> seqs) async {
    int deletedCount = 0;
    await _isar.writeTxn(() async {
      for (final seq in seqs) {
        if (await _isar.isarChangeLogEntrys.delete(seq)) {
          deletedCount++;
        }
      }
    });
    return deletedCount;
  }
  */

  // Statistics operations
  @override
  Future<Map<String, dynamic>> getChangeStats(String projectId) async {
    final total = await _isar.isarChangeLogEntrys
        .filter()
        .domainIdEqualTo(projectId)
        .count();
    final creates = await _isar.isarChangeLogEntrys
        .filter()
        .domainIdEqualTo(projectId)
        .and()
        .operationEqualTo('create')
        .count();
    final updates = await _isar.isarChangeLogEntrys
        .filter()
        .domainIdEqualTo(projectId)
        .and()
        .operationEqualTo('update')
        .count();
    final deletes = await _isar.isarChangeLogEntrys
        .filter()
        .domainIdEqualTo(projectId)
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
  Future<Map<String, dynamic>> getEntityTypeStats(String projectId) async {
    final allEntries = await _isar.isarChangeLogEntrys
        .filter()
        .domainIdEqualTo(projectId)
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
    required String projectId,
    int? cursor,
    int? limit,
  }) async {
    var query = _isar.isarChangeLogEntrys
        .where()
        .seqGreaterThan(cursor ?? 0)
        .filter()
        .domainIdEqualTo(projectId);

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
  @override
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

  // COMMENTED OUT - getChangesForSync needs collection fix
  /*
  /// Get changes for syncing - excludes outdated changes.
  ///
  /// Returns only changes that haven't been marked as outdated,
  /// which prevents syncing obsolete change log entries.
  Future<List<Map<String, dynamic>>> getChangesForSync({
    int? cursor,
    int? limit,
  }) async {
    var query = _isar.isarChangeLogEntrys.where();
    var results = await query
        .seqGreaterThan(cursor ?? 0)
        .filter()
        .outdatedByIsNull()
        .findAll();

    if (limit != null && results.length > limit) {
      results = results.sublist(0, limit);
    }
    return results.map((e) => e.toJson()).toList();
  }
  */

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
  @override
  Future<List<BaseChangeLogEntry>> getChangesSince(
    String projectId,
    int seq,
  ) async {
    final results = await _isar.isarChangeLogEntrys
        .where()
        .seqGreaterThan(seq)
        .filter()
        .domainIdEqualTo(projectId)
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
  Future<BaseEntityState?> getCurrentEntityState(
    String projectId,
    String entityType,
    String entityId,
  ) async {
    // Convert entityType string to EntityType enum
    EntityType entityTypeEnum;
    try {
      entityTypeEnum = EntityType.values.firstWhere(
        (e) => e.value == entityType,
        orElse: () => EntityType.unknown,
      );
    } catch (e) {
      return null;
    }

    switch (entityTypeEnum) {
      case EntityType.project:
        return await _isar.isarProjectStates
            .filter()
            .change_domainIdEqualTo(projectId)
            .and()
            .entityIdEqualTo(entityId)
            .findFirst();
      case EntityType.document:
        return await _isar.isarDocumentStates
            .filter()
            .change_domainIdEqualTo(projectId)
            .and()
            .entityIdEqualTo(entityId)
            .findFirst();
      case EntityType.team:
        return await _isar.isarTeamStates
            .filter()
            .change_domainIdEqualTo(projectId)
            .and()
            .entityIdEqualTo(entityId)
            .findFirst();
      default:
        return null;
    }
  }

  /// Hook method for subclasses to optionally add cloud timestamp.
  /// Override this in CloudStorageService to return DateTime.now().
  DateTime? maybeCreateCloudAt() => null;

  // STUBBED/COMMENTED OUT HELPER METHODS THAT NEED TO BE FIXED LATER

  /*
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
  */

  /// Get all unique project IDs from all changes
  @override
  Future<List<String>> getAllProjects() async {
    final allChanges = await _isar.isarChangeLogEntrys.where().findAll();

    // Extract unique project IDs
    final projectIds = <String>{};
    for (final change in allChanges) {
      if (change.domainId.isNotEmpty) {
        projectIds.add(change.domainId);
      }
    }

    return projectIds.toList()..sort();
  }

  // STUBBED/COMMENTED OUT METHODS THAT NEED TO BE FIXED LATER
  /*
  /// Get sync state for a specific project
  Future<SyncState?> getSyncState(String projectId) async {
    return await _isar
        .collection<SyncState>()
        .filter()
        .change_domainIdEqualTo(projectId)
        .findFirst();
  }
  */

  // STUBBED METHODS THAT NEED TO BE PROPERLY IMPLEMENTED LATER

  @override
  Future<void> markAsOutdated(String projectId, int seq, int outdatedBy) async {
    // TODO: Implement when fixing Isar queries
    // For now, just stub this out
  }

  /*
  /// Create or update sync state for a project
  Future<SyncState> upsertSyncState(
    String projectId, {
    String? changeLogId,
    DateTime? lastChangeAt,
    int? lastSeq,
  }) async {
    // TODO: Fix when implementing sync state management
    throw UnimplementedError('Sync state management needs to be implemented');
  }

  /// Get all sync states
  Future<List<SyncState>> getAllSyncStates() async {
    return await _isar.syncStates.where().findAll();
  }

  /// Delete sync state for a project
  Future<bool> deleteSyncState(String projectId) async {
    // TODO: Implement when fixing sync state management
    return false;
  }

  /// Clear all sync states (useful for testing)
  Future<void> clearAllSyncStates() async {
    await _isar.writeTxn(() async {
      await _isar.syncStates.clear();
    });
  }

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
    required String projectId,
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
class OutsyncsStorageService extends LocalStorageService {
  static OutsyncsStorageService? _instance;
  static OutsyncsStorageService get instance =>
      _instance ??= OutsyncsStorageService._();

  OutsyncsStorageService._() : super('outsyncs', 'OutsyncsStorage');
}

class CloudStorageService extends LocalStorageService {
  static CloudStorageService? _instance;
  static CloudStorageService get instance =>
      _instance ??= CloudStorageService._();

  CloudStorageService._() : super('cloud_storage', 'CloudStorage');

  @override
  DateTime? maybeCreateCloudAt() => DateTime.now().toUtc();

  @override
  Future<BaseChangeLogEntry> createChange(
    Map<String, dynamic> changeData,
  ) async {
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
