import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:sltt_core/sltt_core.dart';

import 'models/change_log_entry.dart' as client;
import 'models/isar_document_state.dart';
import 'models/isar_project_state.dart';
import 'models/isar_team_state.dart';
import 'models/sync_state.dart';

class LocalStorageService implements BaseStorageService {
  final String _databaseName;
  final String _logPrefix;

  late Isar _isar;
  bool _initialized = false;

  LocalStorageService(this._databaseName, this._logPrefix);

  /// Helper method to convert ClientChangeLogEntry to ChangeLogEntry
  ChangeLogEntry _convertToChangeLogEntry(
    client.ClientChangeLogEntry clientEntry,
  ) {
    return ChangeLogEntry(
      projectId: clientEntry.projectId,
      entityType: clientEntry.entityType,
      operation: clientEntry.operation,
      changeAt: clientEntry.changeAt,
      entityId: clientEntry.entityId,
      dataJson: clientEntry.dataJson,
      outdatedBy: clientEntry.outdatedBy,
      cloudAt: clientEntry.cloudAt,
      changeBy: clientEntry.changeBy,
      cid: clientEntry.cid,
    )..seq = clientEntry.seq;
  }

  /// Helper method to convert list of ClientChangeLogEntry to list of ChangeLogEntry
  List<ChangeLogEntry> _convertToChangeLogEntries(
    List<client.ClientChangeLogEntry> clientEntries,
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
        client.ClientChangeLogEntrySchema,
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
  }

  /// Create a new change log entry in the storage.
  ///
  /// Returns the created change log entry with auto-generated sequence number.
  @override
  Future<ChangeLogEntry> createChange(Map<String, dynamic> changeData) async {
    print('changeData: ${jsonEncode(changeData)}');
    final change = client.ClientChangeLogEntry.fromApiData(changeData);

    // Set cloudAt if this is a cloud storage service
    change.cloudAt ??= maybeCreateCloudAt();

    print('change: ${jsonEncode(change)}');
    await _isar.writeTxn(() async {
      await _isar.collection<client.ClientChangeLogEntry>().put(change);
    });

    // Return as base ChangeLogEntry
    return ChangeLogEntry(
      projectId: change.projectId,
      entityType: change.entityType,
      operation: change.operation,
      changeAt: change.changeAt,
      entityId: change.entityId,
      dataJson: change.dataJson,
      outdatedBy: change.outdatedBy,
      cloudAt: change.cloudAt,
      changeBy: change.changeBy,
      cid: change.cid,
    )..seq = change.seq;
  }

  @override
  Future<ChangeLogEntry?> getChange(String projectId, int seq) async {
    final change = await _isar.clientChangeLogEntrys
        .where()
        .seqEqualTo(seq)
        .filter()
        .projectIdEqualTo(projectId)
        .findFirst();
    return change != null ? _convertToChangeLogEntry(change) : null;
  }

  Future<List<ChangeLogEntry>> getAllChanges() async {
    final results = await _isar.clientChangeLogEntrys
        .where()
        .sortByChangeAtDesc()
        .findAll();
    return _convertToChangeLogEntries(results);
  }

  Future<List<ChangeLogEntry>> getChangesByEntityType(
    EntityType entityType,
  ) async {
    final results = await _isar.clientChangeLogEntrys
        .filter()
        .entityTypeEqualTo(entityType)
        .sortByChangeAtDesc()
        .findAll();
    return _convertToChangeLogEntries(results);
  }

  Future<List<ChangeLogEntry>> getChangesByOperation(String operation) async {
    final results = await _isar.clientChangeLogEntrys
        .filter()
        .operationEqualTo(operation)
        .sortByChangeAtDesc()
        .findAll();
    return _convertToChangeLogEntries(results);
  }

  Future<List<ChangeLogEntry>> getChangesByEntityId(String entityId) async {
    final results = await _isar.clientChangeLogEntrys
        .filter()
        .entityIdEqualTo(entityId)
        .sortByChangeAtDesc()
        .findAll();
    return _convertToChangeLogEntries(results);
  }

  Future<List<ChangeLogEntry>> getChangesInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final results = await _isar.clientChangeLogEntrys
        .filter()
        .changeAtBetween(startDate, endDate)
        .sortByChangeAtDesc()
        .findAll();
    return _convertToChangeLogEntries(results);
  }

  /// Get the total count of change log entries.
  Future<int> getChangeCount() async {
    return await _isar.clientChangeLogEntrys.count();
  }

  /// Delete multiple changes by sequence numbers.
  ///
  /// Used for cleanup after successful outsync operations.
  /// Returns the number of changes actually deleted.
  Future<int> deleteChanges(List<int> seqs) async {
    int deletedCount = 0;
    await _isar.writeTxn(() async {
      for (final seq in seqs) {
        if (await _isar.clientChangeLogEntrys.delete(seq)) {
          deletedCount++;
        }
      }
    });
    return deletedCount;
  }

  // Statistics operations
  @override
  Future<Map<String, dynamic>> getChangeStats(String projectId) async {
    final total = await _isar.clientChangeLogEntrys
        .filter()
        .projectIdEqualTo(projectId)
        .count();
    final creates = await _isar.clientChangeLogEntrys
        .filter()
        .projectIdEqualTo(projectId)
        .and()
        .operationEqualTo('create')
        .count();
    final updates = await _isar.clientChangeLogEntrys
        .filter()
        .projectIdEqualTo(projectId)
        .and()
        .operationEqualTo('update')
        .count();
    final deletes = await _isar.clientChangeLogEntrys
        .filter()
        .projectIdEqualTo(projectId)
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
    final allEntries = await _isar.clientChangeLogEntrys
        .filter()
        .projectIdEqualTo(projectId)
        .findAll();
    final stats = <String, int>{};

    for (final entry in allEntries) {
      final entityTypeKey = entry.entityType.value;
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

  /// Delete outdated changes to save storage space.
  ///
  /// This removes change log entries that have been marked as outdated
  /// by newer changes, helping to keep the storage size manageable.
  Future<int> deleteOutdatedChanges() async {
    final outdatedChanges = await _isar.clientChangeLogEntrys
        .filter()
        .outdatedByIsNotNull()
        .findAll();

    final seqsToDelete = outdatedChanges.map((e) => e.seq).toList();

    int deletedCount = 0;
    await _isar.writeTxn(() async {
      for (final seq in seqsToDelete) {
        if (await _isar.clientChangeLogEntrys.delete(seq)) {
          deletedCount++;
        }
      }
    });

    return deletedCount;
  }

  // Cursor-based pagination and filtering
  @override
  Future<List<ChangeLogEntry>> getChangesWithCursor({
    required String projectId,
    int? cursor,
    int? limit,
  }) async {
    var query = _isar.clientChangeLogEntrys
        .where()
        .seqGreaterThan(cursor ?? 0)
        .filter()
        .projectIdEqualTo(projectId);

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
  Future<List<ChangeLogEntry>> getChangesNotOutdated(String projectId) async {
    var results = await _isar.clientChangeLogEntrys
        .where()
        .filter()
        .projectIdEqualTo(projectId)
        .and()
        .outdatedByIsNull()
        .findAll();
    return _convertToChangeLogEntries(results);
  }

  /// Get changes for syncing - excludes outdated changes.
  ///
  /// Returns only changes that haven't been marked as outdated,
  /// which prevents syncing obsolete change log entries.
  Future<List<Map<String, dynamic>>> getChangesForSync({
    int? cursor,
    int? limit,
  }) async {
    var query = _isar.clientChangeLogEntrys.where();
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
      final change = await _isar.clientChangeLogEntrys.get(seq);
      if (change != null && change.projectId == projectId) {
        change.outdatedBy = outdatedBySeq;
        await _isar.clientChangeLogEntrys.put(change);
      }
    });
  }

  // Get the highest sequence number in the database
  Future<int> getLastSeq() async {
    final result = await _isar.clientChangeLogEntrys.where().findAll();
    if (result.isEmpty) {
      return 0;
    }
    return result.map((e) => e.seq).reduce((a, b) => a > b ? a : b);
  }

  // Get changes since a specific sequence number (for syncing)
  @override
  Future<List<ChangeLogEntry>> getChangesSince(
    String projectId,
    int seq,
  ) async {
    final results = await _isar.clientChangeLogEntrys
        .where()
        .seqGreaterThan(seq)
        .filter()
        .projectIdEqualTo(projectId)
        .findAll();

    // Sort by seq in ascending order
    results.sort((a, b) => a.seq.compareTo(b.seq));
    return _convertToChangeLogEntries(results);
  }

  // Store multiple changes (for batch operations)
  Future<List<ChangeLogEntry>> createChanges(
    List<Map<String, dynamic>> changesData,
  ) async {
    final changes = changesData
        .map(
          (changeData) => client.ClientChangeLogEntry.fromApiData(changeData),
        )
        .toList();

    // Set cloudAt for changes if this is a cloud storage service
    for (final change in changes) {
      change.cloudAt ??= maybeCreateCloudAt();
    }

    await _isar.writeTxn(() async {
      await _isar.collection<client.ClientChangeLogEntry>().putAll(changes);
    });

    // Convert ClientChangeLogEntry to ChangeLogEntry for the interface
    return changes
        .map(
          (clientEntry) => ChangeLogEntry(
            projectId: clientEntry.projectId,
            entityType: clientEntry.entityType,
            operation: clientEntry.operation,
            changeAt: clientEntry.changeAt,
            entityId: clientEntry.entityId,
            dataJson: clientEntry.dataJson,
            outdatedBy: clientEntry.outdatedBy,
            cloudAt: clientEntry.cloudAt,
            changeBy: clientEntry.changeBy,
            cid: clientEntry.cid,
          )..seq = clientEntry.seq,
        )
        .toList();
  }

  /// Store multiple changes with field-level change detection
  @override
  Future<CreateChangesResult> createChangesWithChangeDetection(
    List<Map<String, dynamic>> changesData,
  ) async {
    // Use the shared change detection service from sltt_core
    return await ChangeDetectionService.processChangesWithDetection(
      changesData,
      this,
      getCurrentEntityState: getCurrentEntityState,
    );
  }

  /// Get the current state of an entity for field-level comparison
  @override
  Future<ChangeLogEntry?> getCurrentEntityState(
    String projectId,
    String entityType,
    String entityId,
  ) async {
    // Get the most recent change for this entity
    final results = await _isar.clientChangeLogEntrys
        .where()
        .filter()
        .projectIdEqualTo(projectId)
        .and()
        .entityTypeEqualTo(
          EntityType.values.firstWhere(
            (e) => e.value == entityType,
            orElse: () => EntityType.document,
          ),
        )
        .and()
        .entityIdEqualTo(entityId)
        .sortByChangeAtDesc()
        .findAll();

    if (results.isEmpty) {
      return null;
    }

    return _convertToChangeLogEntry(results.first);
  }

  /// Hook method for subclasses to optionally add cloud timestamp.
  /// Override this in CloudStorageService to return DateTime.now().
  DateTime? maybeCreateCloudAt() => null;

  /// Delete all changes - useful for testing cleanup
  Future<int> deleteAllChanges() async {
    final allChanges = await _isar.clientChangeLogEntrys.where().findAll();

    final seqsToDelete = allChanges.map((e) => e.seq).toList();

    int deletedCount = 0;
    await _isar.writeTxn(() async {
      for (final seq in seqsToDelete) {
        if (await _isar.clientChangeLogEntrys.delete(seq)) {
          deletedCount++;
        }
      }
    });

    return deletedCount;
  }

  /// Get all unique project IDs from all changes
  @override
  Future<List<String>> getAllProjects() async {
    final allChanges = await _isar.clientChangeLogEntrys.where().findAll();

    // Extract unique project IDs
    final projectIds = <String>{};
    for (final change in allChanges) {
      if (change.projectId.isNotEmpty) {
        projectIds.add(change.projectId);
      }
    }

    return projectIds.toList()..sort();
  }

  /// Get sync state for a specific project
  Future<SyncState?> getSyncState(String projectId) async {
    return await _isar
        .collection<SyncState>()
        .filter()
        .projectIdEqualTo(projectId)
        .findFirst();
  }

  /// Create or update sync state for a project
  Future<SyncState> upsertSyncState(
    String projectId, {
    String? changeLogId,
    DateTime? lastChangeAt,
    int? lastSeq,
  }) async {
    late SyncState syncState;

    await _isar.writeTxn(() async {
      // Try to find existing sync state
      SyncState? existing = await _isar.syncStates
          .filter()
          .projectIdEqualTo(projectId)
          .findFirst();

      if (existing != null) {
        // Update existing
        existing.updateSync(
          changeLogId: changeLogId,
          lastChangeAt: lastChangeAt,
          lastSeq: lastSeq,
        );
        await _isar.syncStates.put(existing);
        syncState = existing;
      } else {
        // Create new
        syncState = SyncState.forProject(projectId);
        syncState.updateSync(
          changeLogId: changeLogId,
          lastChangeAt: lastChangeAt,
          lastSeq: lastSeq,
        );
        await _isar.syncStates.put(syncState);
      }
    });

    return syncState;
  }

  /// Get all sync states
  Future<List<SyncState>> getAllSyncStates() async {
    return await _isar.syncStates.where().findAll();
  }

  /// Delete sync state for a project
  Future<bool> deleteSyncState(String projectId) async {
    late bool deleted;
    await _isar.writeTxn(() async {
      final syncState = await _isar.syncStates
          .filter()
          .projectIdEqualTo(projectId)
          .findFirst();

      if (syncState != null) {
        deleted = await _isar.syncStates.delete(syncState.id);
      } else {
        deleted = false;
      }
    });
    return deleted;
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
        .projectIdEqualTo(projectId)
        .findFirst();
  }

  Future<List<IsarProjectState>> getAllProjectStates() async {
    return await _isar.isarProjectStates.where().findAll();
  }

  Future<bool> deleteProjectState(String projectId) async {
    bool deleted = false;
    await _isar.writeTxn(() async {
      final projectState = await _isar.isarProjectStates
          .filter()
          .projectIdEqualTo(projectId)
          .findFirst();

      if (projectState != null) {
        deleted = await _isar.isarProjectStates.delete(projectState.id);
      } else {
        deleted = false;
      }
    });
    return deleted;
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
    bool deleted = false;
    await _isar.writeTxn(() async {
      final teamState = await _isar.isarTeamStates
          .filter()
          .entityIdEqualTo(teamId)
          .findFirst();

      if (teamState != null) {
        deleted = await _isar.isarTeamStates.delete(teamState.id);
      } else {
        deleted = false;
      }
    });
    return deleted;
  }

  /// Applies a changelog entry to the appropriate state collection
  /// Returns the updated state entity
  Future<dynamic> applyChangelogToState(
    client.ClientChangeLogEntry changeLogEntry,
  ) async {
    // Determine entity type and route to appropriate collection
    final entityType = changeLogEntry.entityType;

    switch (entityType) {
      case EntityType.document:
        return await _applyChangelogToDocumentState(changeLogEntry);
      case EntityType.project:
        return await _applyChangelogToProjectState(changeLogEntry);
      case EntityType.team:
        return await _applyChangelogToTeamState(changeLogEntry);
      default:
        throw ArgumentError('Unsupported entity type for state: $entityType');
    }
  }

  /// Applies changelog entry to project state
  Future<IsarProjectState> _applyChangelogToProjectState(
    client.ClientChangeLogEntry changeLogEntry,
  ) async {
    IsarProjectState? existingState;

    await _isar.writeTxn(() async {
      // Get existing state or create new
      existingState = await getProjectState(changeLogEntry.projectId);

      if (existingState == null) {
        // Create new project state from changelog entry
        existingState = IsarProjectState();
        existingState!.entityId = changeLogEntry.entityId;
        existingState!.entityType = EntityType.project;
        existingState!.projectId = changeLogEntry.projectId;
      }

      // Apply the changelog entry to update the state
      existingState!.updateFromChangeLogEntry(
        changeAt: changeLogEntry.changeAt,
        cid: changeLogEntry.cid,
        changeBy: changeLogEntry.changeBy,
        cloudAt: changeLogEntry.cloudAt,
        data: changeLogEntry.data,
      );

      // Save the updated state
      await _isar.isarProjectStates.put(existingState!);
    });

    return existingState!;
  }

  /// Applies changelog entry to team state
  Future<IsarTeamState> _applyChangelogToTeamState(
    client.ClientChangeLogEntry changeLogEntry,
  ) async {
    IsarTeamState? existingState;

    await _isar.writeTxn(() async {
      // Get existing state by entityId (team ID)
      existingState = await getTeamState(changeLogEntry.entityId);

      if (existingState == null) {
        // Create new team state from changelog entry
        existingState = IsarTeamState();
        existingState!.entityId = changeLogEntry.entityId;
        existingState!.entityType = EntityType.team;
        existingState!.projectId = changeLogEntry.projectId;
      }

      // Apply the changelog entry to update the state
      existingState!.updateFromChangeLogEntry(
        changeAt: changeLogEntry.changeAt,
        cid: changeLogEntry.cid,
        changeBy: changeLogEntry.changeBy,
        cloudAt: changeLogEntry.cloudAt,
        data: changeLogEntry.data,
      );

      // Save the updated state
      await _isar.isarTeamStates.put(existingState!);
    });

    return existingState!;
  }

  /// Applies changelog entry to document state
  Future<IsarDocumentState> _applyChangelogToDocumentState(
    client.ClientChangeLogEntry changeLogEntry,
  ) async {
    IsarDocumentState? existingState;

    await _isar.writeTxn(() async {
      // Get existing state by entityId (document ID)
      existingState = await getDocumentState(changeLogEntry.entityId);

      if (existingState == null) {
        // Create new document state from changelog entry
        existingState = IsarDocumentState();
        existingState!.entityId = changeLogEntry.entityId;
        existingState!.entityType = EntityType.document;
        existingState!.projectId = changeLogEntry.projectId;
      }

      // Apply the changelog entry to update the state
      existingState!.updateFromChangeLogEntry(
        changeAt: changeLogEntry.changeAt,
        cid: changeLogEntry.cid,
        changeBy: changeLogEntry.changeBy,
        cloudAt: changeLogEntry.cloudAt,
        data: changeLogEntry.data,
      );

      // Save the updated state
      await _isar.isarDocumentStates.put(existingState!);
    });

    return existingState!;
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

  @override
  Future<List<String>> getSupportedEntityTypes(String projectId) async {
    // Return all entity types supported by this storage service
    return EntityType.values.map((e) => e.name).toList();
  }

  @override
  Future<Map<String, dynamic>> getEntityStates({
    required String projectId,
    required String entityType,
    String? cursor,
    int? limit,
    bool includeMetadata = false,
  }) async {
    final actualLimit = limit ?? 50;
    try {
      final entityTypeEnum = EntityType.values.firstWhere(
        (e) => e.name == entityType,
        orElse: () =>
            throw ArgumentError('Unsupported entity type: $entityType'),
      );

      switch (entityTypeEnum) {
        case EntityType.project:
          return await _getProjectStatesWithPagination(
            projectId,
            actualLimit,
            cursor,
            includeMetadata,
          );
        case EntityType.document:
          return await _getDocumentStatesWithPagination(
            projectId,
            actualLimit,
            cursor,
            includeMetadata,
          );
        case EntityType.team:
          return await _getTeamStatesWithPagination(
            projectId,
            actualLimit,
            cursor,
            includeMetadata,
          );
        default:
          return {
            'entities': <Map<String, dynamic>>[],
            'hasMore': false,
            'nextCursor': null,
          };
      }
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

  Future<Map<String, dynamic>> _getProjectStatesWithPagination(
    String projectId,
    int limit,
    String? cursor,
    bool includeMetadata,
  ) async {
    final query = _isar.isarProjectStates.filter().projectIdEqualTo(projectId);

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
      'entities': resultEntities
          .map((e) => _projectStateToMap(e, includeMetadata))
          .toList(),
      'hasMore': hasMore,
      'nextCursor': hasMore ? resultEntities.last.entityId : null,
    };
  }

  Future<Map<String, dynamic>> _getDocumentStatesWithPagination(
    String projectId,
    int limit,
    String? cursor,
    bool includeMetadata,
  ) async {
    final query = _isar.isarDocumentStates.filter().projectIdEqualTo(projectId);

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
      'entities': resultEntities
          .map((e) => _documentStateToMap(e, includeMetadata))
          .toList(),
      'hasMore': hasMore,
      'nextCursor': hasMore ? resultEntities.last.entityId : null,
    };
  }

  Future<Map<String, dynamic>> _getTeamStatesWithPagination(
    String projectId,
    int limit,
    String? cursor,
    bool includeMetadata,
  ) async {
    final query = _isar.isarTeamStates.filter().projectIdEqualTo(projectId);

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
      'entities': resultEntities
          .map((e) => _teamStateToMap(e, includeMetadata))
          .toList(),
      'hasMore': hasMore,
      'nextCursor': hasMore ? resultEntities.last.entityId : null,
    };
  }

  Map<String, dynamic> _projectStateToMap(
    IsarProjectState state,
    bool includeMetadata,
  ) {
    final result = <String, dynamic>{
      'entityId': state.entityId,
      'projectId': state.projectId,
      'name': state.name,
      'description': state.description,
      'status': state.status.name,
      'priority': state.priority.name,
      'leadId': state.leadId,
      'dueDate': state.dueDate?.toIso8601String(),
      'settings': state.settings,
      'deleted': state.deleted,
    };

    if (includeMetadata) {
      result['metadata'] = {
        'changeAt': state.changeAt?.toIso8601String(),
        'cloudAt': state.cloudAt?.toIso8601String(),
        'cid': state.cid,
        'changeBy': state.changeBy,
        'rank': state.rank,
        'parentId': state.parentId,
      };
    }

    return result;
  }

  Map<String, dynamic> _documentStateToMap(
    IsarDocumentState state,
    bool includeMetadata,
  ) {
    final result = <String, dynamic>{
      'entityId': state.entityId,
      'projectId': state.projectId,
      'title': state.title,
      'content': state.content,
      'deleted': state.deleted,
    };

    if (includeMetadata) {
      result['metadata'] = {
        'changeAt': state.changeAt?.toIso8601String(),
        'cloudAt': state.cloudAt?.toIso8601String(),
        'cid': state.cid,
        'changeBy': state.changeBy,
        'rank': state.rank,
        'parentId': state.parentId,
      };
    }

    return result;
  }

  Map<String, dynamic> _teamStateToMap(
    IsarTeamState state,
    bool includeMetadata,
  ) {
    final result = <String, dynamic>{
      'entityId': state.entityId,
      'projectId': state.projectId,
      'name': state.name,
      'description': state.description,
      'leadId': state.leadId,
      'settings': state.settings,
      'deleted': state.deleted,
    };

    if (includeMetadata) {
      result['metadata'] = {
        'changeAt': state.changeAt?.toIso8601String(),
        'cloudAt': state.cloudAt?.toIso8601String(),
        'cid': state.cid,
        'changeBy': state.changeBy,
        'rank': state.rank,
        'parentId': state.parentId,
      };
    }

    return result;
  }
}

// Singleton wrappers for each storage type
class OutsyncsStorageService extends LocalStorageService {
  static OutsyncsStorageService? _instance;
  static OutsyncsStorageService get instance =>
      _instance ??= OutsyncsStorageService._();

  OutsyncsStorageService._() : super('outsyncs', 'OutsyncsStorage');
}

class DownsyncsStorageService extends LocalStorageService {
  static DownsyncsStorageService? _instance;
  static DownsyncsStorageService get instance =>
      _instance ??= DownsyncsStorageService._();

  DownsyncsStorageService._() : super('downsyncs', 'DownsyncsStorage');
}

class CloudStorageService extends LocalStorageService {
  static CloudStorageService? _instance;
  static CloudStorageService get instance =>
      _instance ??= CloudStorageService._();

  CloudStorageService._() : super('cloud_storage', 'CloudStorage');

  @override
  DateTime? maybeCreateCloudAt() => DateTime.now().toUtc();

  @override
  Future<ChangeLogEntry> createChange(Map<String, dynamic> changeData) async {
    print('changeData: ${jsonEncode(changeData)}');

    // For cloud storage, always force sequence auto-generation by removing seq
    final cloudChangeData = Map<String, dynamic>.from(changeData);
    cloudChangeData.remove('seq'); // Force auto-increment in cloud storage

    final change = client.ClientChangeLogEntry.fromApiData(cloudChangeData);

    // Set cloudAt since this is a cloud storage service
    change.cloudAt ??= maybeCreateCloudAt();

    print('change: ${jsonEncode(change)}');
    await _isar.writeTxn(() async {
      await _isar.collection<client.ClientChangeLogEntry>().put(change);
    });

    // Return as base ChangeLogEntry
    return ChangeLogEntry(
      projectId: change.projectId,
      entityType: change.entityType,
      operation: change.operation,
      changeAt: change.changeAt,
      entityId: change.entityId,
      dataJson: change.dataJson,
      outdatedBy: change.outdatedBy,
      cloudAt: change.cloudAt,
      changeBy: change.changeBy,
      cid: change.cid,
    )..seq = change.seq;
  }
}
