import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/cursor_sync_state.dart';
import 'package:sync_manager/src/models/isar_entity_type_state.dart';
import 'package:sync_manager/src/models/isar_storage_state.dart';
import 'package:sync_manager/sync_manager.dart';

import 'models/isar_change_log_entry.dart' as client;
import 'register_entity_states.dart';

class IsarStorageService extends BaseStorageService {
  final String _databaseName;
  final String _logPrefix;

  late Isar _isar;
  bool _initialized = false;
  late String _storageId;

  final IsarEntityStateStorageRegistry _entityStateRegistry =
      IsarEntityStateStorageRegistry();

  IsarEntityStateStorageRegistry get entityStateRegistry =>
      _entityStateRegistry;

  IsarStorageService(this._databaseName, this._logPrefix);

  @override
  Future<void> initialize({
    List<CollectionSchema>? providedEntityStateSchemas,
    void Function(IsarEntityStateStorageRegistry, Isar)? registerStorageGroups,
    bool inspector = false,
  }) async {
    if (_initialized) return;

    // Create local directory for database
    final dir = Directory('./isar_db');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Use provided schemas or fall back to default registered schemas
    final schemasToUse = providedEntityStateSchemas ?? entityStateSchemas;

    // Initialize Isar with change log + sync state + entity schemas
    final schemas = <CollectionSchema>[
      IsarStorageStateSchema,
      IsarEntityTypeSyncStateSchema,
      CursorSyncStateSchema,
      client.IsarChangeLogEntrySchema,
      ...schemasToUse,
    ];

    // Initialize Isar with all schemas
    _isar = await Isar.open(
      schemas,
      directory: dir.path,
      name: _databaseName,
      inspector: inspector,
    );

    // Register storage groups with the initialized Isar instance. Always
    // start from a clean registry so re-initialization doesn't duplicate
    // entries.
    _entityStateRegistry.clear();
    if (registerStorageGroups != null) {
      registerStorageGroups(_entityStateRegistry, _isar);
    } else {
      // Fall back to default registration
      registerAllIsarEntityStateStorageGroups(_entityStateRegistry, _isar);
    }

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

  BaseEntityState _createEntityStateFromJson(
    EntityType entityTypeEnum,
    Map<String, dynamic> json,
    String originalTypeString,
  ) {
    final storageGroup = _entityStateRegistry.get(entityTypeEnum);
    if (storageGroup != null) {
      return storageGroup.fromJson(json);
    }

    throw UnimplementedError('Unknown entity type: $originalTypeString');
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
      final existing = await _isar.isarStorageStates
          .filter()
          .storageTypeEqualTo('local')
          .findFirst();

      if (existing != null && existing.storageId.isNotEmpty) {
        _storageId = existing.storageId;
        return _storageId;
      }

      // Not found -> create a new canonical storage id and persist a SelfSyncState
      final newId = BaseStorageService.generateShortStorageId();
      final now = DateTime.now().toUtc();
      final storageState = IsarStorageState(
        storageId: newId,
        storageType: 'local',
        createdAt: now,
        updatedAt: now,
      );

      await _isar.writeTxn(() async {
        await _isar.isarStorageStates.put(storageState);
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
    // IMPORTANT: When writing to storage, avoid using an incoming
    // seq value from the caller. Isar uses `seq` as the primary key and
    // calling `put` with a specific seq can overwrite an existing entry
    // with the same id. To prevent accidental overwrites when syncing
    // changes into the cloud, force the cloud storage to assign a new
    // auto-increment id.
    newChange.seq = Isar.autoIncrement;

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

      newEntityState = _createEntityStateFromJson(
        entityTypeEnum,
        mergedStateJson,
        changeLogEntry.entityType,
      );
    } else {
      // Create new entity state from state updates
      // Make a shallow copy and ensure required metadata fields exist
      final stateJson = Map<String, dynamic>.from(stateUpdates);

      newEntityState = _createEntityStateFromJson(
        entityTypeEnum,
        stateJson,
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
      final storageGroup = _entityStateRegistry.get(entityTypeEnum);
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
      // Upsert entity-type sync state counters (created/updated/deleted)
      try {
        final existingEntityTypeSyncStates = await _isar
            .isarEntityTypeSyncStates
            .where()
            .entityTypeDomainIdEqualTo(
              changeLogEntry.entityType,
              newChange.domainId,
            )
            .findFirst();

        final op = newChange.operation;
        print(
          'updateChangeLogAndState - Upserting entity-type sync state for entityType=${changeLogEntry.entityType} entityId=${newChange.entityId} domainId=${newChange.domainId} op=$op existing=${existingEntityTypeSyncStates != null}',
        );
        if (existingEntityTypeSyncStates != null) {
          // Explicitly increment counters on the existing record so the
          // stored counts reflect the actual number of ops performed.
          final newEt = IsarEntityTypeSyncState(
            id: existingEntityTypeSyncStates.id,
            entityType: existingEntityTypeSyncStates.entityType,
            domainId: existingEntityTypeSyncStates.domainId,
            domainType: existingEntityTypeSyncStates.domainType,
            storageId: _storageId,
            storageType: getStorageType(),
            cid: newChange.cid,
            changeAt: newChange.changeAt,
            seq: newChange.seq,
            created:
                existingEntityTypeSyncStates.created + (op == 'create' ? 1 : 0),
            updated:
                existingEntityTypeSyncStates.updated + (op == 'update' ? 1 : 0),
            deleted:
                existingEntityTypeSyncStates.deleted + (op == 'delete' ? 1 : 0),
            createdAt: existingEntityTypeSyncStates.createdAt,
            updatedAt: DateTime.now(),
          );
          await _isar.isarEntityTypeSyncStates.putByEntityTypeDomainId(newEt);
        } else {
          // New record - initialize counters to 1 for the matching op, 0
          // otherwise.
          final newEt = IsarEntityTypeSyncState(
            entityType: changeLogEntry.entityType,
            domainId: newChange.domainId,
            domainType: domainType,
            storageId: _storageId,
            storageType: getStorageType(),
            cid: newChange.cid,
            changeAt: newChange.changeAt,
            seq: newChange.seq,
            created: newChange.operation == 'create' ? 1 : 0,
            updated: newChange.operation == 'update' ? 1 : 0,
            deleted: newChange.operation == 'delete' ? 1 : 0,
          );
          await _isar.isarEntityTypeSyncStates.putByEntityTypeDomainId(newEt);
        }
      } catch (e) {
        print(
          '[$_logPrefix] Warning: failed to upsert entity-type sync state: $e',
        );
      }
    });

    return (
      newChangeLogEntry: _convertToChangeLogEntry(newChange),
      newEntityState: newEntityState,
    );
  }

  /// AGENT: do not fix this. it's deprecated. Use ChangeProcessingService.processChanges
  Future<BaseChangeLogEntry> createChange({
    required String domainType,
    required Map<String, dynamic> changeData,
  }) async {
    // final newChange = client.IsarChangeLogEntry.fromJson(changeData);

    // // Save change in a transaction
    // await _isar.writeTxn(() async {
    //   await _isar.collection<client.IsarChangeLogEntry>().put(newChange);
    // });

    // return _convertToChangeLogEntry(newChange);

    throw UnimplementedError(
      'deprecated. Use ChangeProcessingService.processChanges',
    );
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

  /// Delete multiple changes by sequence numbers.
  ///
  /// Used for cleanup after successful outsync operations.
  /// Returns the number of changes actually deleted.
  Future<int> deleteChanges(List<String> cids) async {
    print(
      '[$_logPrefix, $_databaseName, ${getStorageType()}] deleteChanges called for cids=$cids',
    );
    int deletedCount = 0;
    await _isar.writeTxn(() async {
      // Debug: list entries that match the cids before deleting
      try {
        final all = await _isar.isarChangeLogEntrys.where().findAll();
        final before = all.where((e) => cids.contains(e.cid)).toList();
        print(
          '[$_logPrefix] deleteChanges - matching entries before delete: count=${before.length}',
        );
        for (final e in before) {
          print(
            '[$_logPrefix] deleteChanges - will delete: seq=${e.seq} cid=${e.cid} domain=${e.domainId} domainType=${e.domainType} entityType=${e.entityType} cloudAt=${e.cloudAt} storageId=${e.storageId}',
          );
        }
      } catch (e) {
        print(
          '[$_logPrefix] deleteChanges - debug: failed to list matching entries: $e',
        );
      }

      deletedCount = await _isar.isarChangeLogEntrys.deleteAllByCid(cids);

      print(
        '[$_logPrefix] deleteChanges - deletedCount=$deletedCount for cids=$cids',
      );
    });
    return deletedCount;
  }

  /// Subscribe to entity state changes for real-time updates
  StreamSubscription<void> lazyListenToEntityChanges({
    required String domainType,
    required String domainId,
    required String entityType,
    String? entityId,
    String? parentId,
    String? parentProp,
    required void Function() onChanged,
    bool fireImmediately = true,
  }) {
    // Use the registered storage group to get the right collection
    final storageGroup = _entityStateRegistry.get(
      EntityType.values.firstWhere(
        (e) => e.value == entityType,
        orElse: () => throw StateError('Unknown entity type: $entityType'),
      ),
    );

    if (storageGroup == null) {
      throw StateError(
        'No storage group registered for entity type: $entityType',
      );
    }

    if (storageGroup.lazyListenToEntityChanges == null) {
      throw StateError(
        'Storage group for entity type $entityType does not support subscriptions',
      );
    }

    return storageGroup.lazyListenToEntityChanges!(
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      entityId: entityId,
      parentId: parentId,
      parentProp: parentProp,
      onChanged: onChanged,
      fireImmediately: fireImmediately,
    );
  }

  // Statistics operations
  @override
  Future<EntityTypeStats> getChangeStats({
    required String domainType,
    required String domainId,
  }) async {
    // Aggregate change-log entries per entityType to compute creates/updates/deletes
    final changes = await _isar.isarChangeLogEntrys
        .filter()
        .domainIdEqualTo(domainId)
        .and()
        .domainTypeEqualTo(domainType)
        .findAll();

    // Debug: print change-log entries found for this domain
    try {
      print(
        '[$_logPrefix] getChangeStats - found ${changes.length} change-log entries for domainId=$domainId domainType=$domainType',
      );
      for (final c in changes) {
        print(
          '[$_logPrefix] getChangeStats - seq=${c.seq} cid=${c.cid} op=${c.operation} entityType=${c.entityType} cloudAt=${c.cloudAt} storageId=${c.storageId}',
        );
      }
    } catch (e) {
      print('[$_logPrefix] getChangeStats - debug print failed: $e');
    }

    final Map<String, Map<String, dynamic>> perType = {};
    int totalCreates = 0;
    int totalUpdates = 0;
    int totalDeletes = 0;
    DateTime? mostRecentChangeAt;
    int mostRecentSeq = -1;

    for (final c in changes) {
      final type = c.entityType;
      final map = perType[type] ??= {
        'creates': 0,
        'updates': 0,
        'deletes': 0,
        'total': 0,
      };

      if (c.operation == 'create') {
        map['creates'] = (map['creates'] ?? 0) + 1;
        totalCreates++;
      } else if (c.operation == 'update') {
        map['updates'] = (map['updates'] ?? 0) + 1;
        totalUpdates++;
      } else if (c.operation == 'delete') {
        map['deletes'] = (map['deletes'] ?? 0) + 1;
        totalDeletes++;
      }

      map['total'] =
          (map['creates'] ?? 0) + (map['updates'] ?? 0) + (map['deletes'] ?? 0);

      // latest per-type changeAt/seq
      final ca = c.changeAt.toUtc();
      final existing = map['latestChangeAt'] as String?;
      if (existing == null) {
        map['latestChangeAt'] = ca.toIso8601String();
      } else {
        final ex = DateTime.tryParse(existing)?.toUtc();
        if (ex == null || ca.isAfter(ex)) {
          map['latestChangeAt'] = ca.toIso8601String();
        }
      }
      if ((map['latestSeq'] as int? ?? -1) < c.seq) map['latestSeq'] = c.seq;

      if (mostRecentChangeAt == null || ca.isAfter(mostRecentChangeAt)) {
        mostRecentChangeAt = ca;
      }
      if (c.seq > mostRecentSeq) mostRecentSeq = c.seq;
    }

    final Map<String, EntityTypeSummary> typedPerType = {};
    perType.forEach((k, v) {
      typedPerType[k] = EntityTypeSummary(
        creates: v['creates'] as int? ?? 0,
        updates: v['updates'] as int? ?? 0,
        deletes: v['deletes'] as int? ?? 0,
        total: v['total'] as int? ?? 0,
        latestChangeAt:
            (v['latestChangeAt'] as String?) ?? '1970-01-01T00:00:00Z',
        latestSeq: v['latestSeq'] as int? ?? -1,
      );
    });

    final totals = EntityTypeSummary(
      creates: totalCreates,
      updates: totalUpdates,
      deletes: totalDeletes,
      total: totalCreates + totalUpdates + totalDeletes,
      latestChangeAt:
          mostRecentChangeAt?.toIso8601String() ?? '1970-01-01T00:00:00Z',
      latestSeq: mostRecentSeq,
    );

    return EntityTypeStats(entityTypes: typedPerType, totals: totals);
  }

  @override
  Future<EntityTypeStats> getStateStats({
    required String domainType,
    required String domainId,
  }) async {
    // Use the IsarEntityTypeSyncState collection which tracks per-entityType
    // created/updated/deleted counters. We will return a structured map with
    // per-entityType breakdowns and aggregate totals, e.g.:
    // {
    //   'entityTypes': {
    //     'project': {'creates': X, 'updates': Y, 'deletes': Z, 'total': T},
    //     ...
    //   },
    //   'totals': {'creates': X, 'updates': Y, 'deletes': Z, 'total': T}
    // }

    final entries = await _isar.isarEntityTypeSyncStates
        .filter()
        .domainIdEqualTo(domainId)
        .and()
        .domainTypeEqualTo(domainType)
        .findAll();

    // Debug: print entity-type sync state entries returned by Isar
    try {
      print(
        'DEBUG: isarEntityTypeSyncStates count=${entries.length} for domain=$domainId type=$domainType',
      );
      for (final e in entries) {
        print(
          'DEBUG: ET=${e.entityType} created=${e.created} updated=${e.updated} deleted=${e.deleted} changeAt=${e.changeAt} seq=${e.seq} cid=${e.cid}',
        );
      }
    } catch (e) {
      // ignore debugging failures
    }

    final Map<String, EntityTypeSummary> perType = {};
    int totalCreates = 0;
    int totalUpdates = 0;
    int totalDeletes = 0;
    DateTime? mostRecentChangeAt;
    int mostRecentSeq = -1;

    for (final e in entries) {
      final type = e.entityType;
      // Some implementations use Isar.autoIncrement as a marker to bump the
      // counter; interpret negative/autoIncrement values as +1 for counting
      // purposes.
      int creates = e.created;
      int updates = e.updated;
      int deletes = e.deleted;
      if (creates < 0) creates = 1;
      if (updates < 0) updates = 1;
      if (deletes < 0) deletes = 1;
      final total = creates + updates + deletes;

      final latestChangeAt = e.changeAt.toUtc().toIso8601String();
      final latestSeq = e.seq;

      perType[type] = EntityTypeSummary(
        creates: creates,
        updates: updates,
        deletes: deletes,
        total: total,
        latestChangeAt: latestChangeAt,
        latestSeq: latestSeq,
      );

      totalCreates += creates;
      totalUpdates += updates;
      totalDeletes += deletes;

      final parsed = DateTime.tryParse(latestChangeAt)?.toUtc();
      if (parsed != null) {
        if (mostRecentChangeAt == null || parsed.isAfter(mostRecentChangeAt)) {
          mostRecentChangeAt = parsed;
        }
      }
      if (latestSeq > mostRecentSeq) mostRecentSeq = latestSeq;
    }

    final totals = EntityTypeSummary(
      creates: totalCreates,
      updates: totalUpdates,
      deletes: totalDeletes,
      total: totalCreates + totalUpdates + totalDeletes,
      latestChangeAt:
          mostRecentChangeAt?.toIso8601String() ?? '1970-01-01T00:00:00Z',
      latestSeq: mostRecentSeq,
    );

    // Convert perType map values from dynamic to the typed map expected by
    // EntityTypeStats: Map<String, EntityTypeSummary>
    return EntityTypeStats(entityTypes: perType, totals: totals);
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
        .cloudAtIsNull()
        .findAll();

    // Debug: log which changes are being returned for sync
    try {
      print(
        '[$_logPrefix] getChangesForSync - returning ${results.length} changes (cursor=$cursor limit=$limit)',
      );
      for (final r in results) {
        print(
          '[$_logPrefix] getChangesForSync - seq=${r.seq} cid=${r.cid} domain=${r.domainId} domainType=${r.domainType} op=${r.operation} entityType=${r.entityType} cloudAt=${r.cloudAt} storageId=${r.storageId}',
        );
      }
    } catch (e) {
      print('[$_logPrefix] getChangesForSync - debug print failed: $e');
    }

    if (limit != null && results.length > limit) {
      results = results.sublist(0, limit);
    }
    return results;
  }

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

    final storageGroup = _entityStateRegistry.get(entityTypeEnum);
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
    final entityTypes = _entityStateRegistry.registeredEntityTypes();
    for (final et in entityTypes) {
      final group = _entityStateRegistry.get(et);
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

    print('[$_logPrefix] deleteAllChanges - totalEntries=${allChanges.length}');
    int deletedCount = 0;
    await _isar.writeTxn(() async {
      for (final seq in seqsToDelete) {
        if (await _isar.isarChangeLogEntrys.delete(seq)) {
          deletedCount++;
        }
      }
    });

    print('[$_logPrefix] deleteAllChanges - deletedCount=$deletedCount');
    return deletedCount;
  }

  /// Get all unique project IDs across all entityStates
  @override
  Future<List<String>> getAllDomainIds({required String domainType}) async {
    // Use the entity-type sync state collection which tracks domainIds
    // for each entityType/domain combination. This avoids scanning the
    // entire change log and is more efficient for discovering known domains.
    final entries = await _isar.isarEntityTypeSyncStates
        .filter()
        .domainTypeEqualTo(domainType)
        .findAll();

    final domainIds = <String>{};
    for (final e in entries) {
      if (e.domainId.isNotEmpty) domainIds.add(e.domainId);
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

  @override
  Future<Map<String, dynamic>> getEntityStates({
    required String domainType,
    required String domainId,
    required String entityType,
    String? cursor,
    int? limit,
    bool includeMetadata = false,
    String? parentId,
    String? parentProp,
  }) async {
    try {
      // Convert entityType string to EntityType enum
      final entityTypeEnum = EntityType.values.firstWhere(
        (e) => e.value == entityType,
        orElse: () => EntityType.unknown,
      );

      if (entityTypeEnum == EntityType.unknown) {
        throw ArgumentError('Unsupported entity type: $entityType');
      }

      // Get the storage group for this entity type
      final storageGroup = _entityStateRegistry.get(entityTypeEnum);
      if (storageGroup == null) {
        throw ArgumentError(
          'No storage group registered for entity type: $entityType',
        );
      }

      // Use the storage group's pagination function for efficient querying
      final effectiveLimit = limit ?? 100;

      // Use database-level parentId filtering for better performance
      final entities = await storageGroup.findByDomainWithPagination(
        domainId: domainId,
        cursor: cursor,
        limit: effectiveLimit + 1, // Get one extra to check if there are more
        parentId: parentId,
        parentProp: parentProp,
      );

      // Check if there are more results
      final hasMore = entities.length > effectiveLimit;
      final resultEntities = hasMore
          ? entities.take(effectiveLimit).toList()
          : entities;

      // Convert to JSON and determine next cursor. Rely on DB-level filtering
      // (generated Isar query helpers) to handle `parentProp` and `parentId`.
      final items = resultEntities
          .map((entity) => (entity as dynamic).toJson())
          .toList();

      final nextCursor = hasMore && resultEntities.isNotEmpty
          ? (resultEntities.last as dynamic).entityId as String?
          : null;

      return {'items': items, 'hasMore': hasMore, 'nextCursor': nextCursor};
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

  @override
  Future<void> testResetDomainStorage({
    required String domainType,
    required String domainId,
  }) {
    if (domainId.isEmpty) {
      throw ArgumentError('domainId cannot be empty');
    }
    if (domainType.isEmpty) {
      throw ArgumentError('domainType cannot be empty');
    }
    if (domainId.startsWith('__test') == false) {
      throw ArgumentError(
        'For safety, domainId must start with "__test" to prevent accidental data loss',
      );
    }

    print(
      '[$_logPrefix] testResetDomainStorage - Deleting all data for domainId=$domainId domainType=$domainType',
    );

    // Delete all change log entries for the domain
    return _isar.writeTxn(() async {
      final changesToDelete = await _isar.isarChangeLogEntrys
          .filter()
          .domainIdEqualTo(domainId)
          .and()
          .domainTypeEqualTo(domainType)
          .findAll();
      final seqsToDelete = changesToDelete.map((e) => e.seq).toList();
      await _isar.isarChangeLogEntrys.deleteAll(seqsToDelete);

      // Delete all entity states for the domain across all registered storage groups
      final entityTypes = _entityStateRegistry.registeredEntityTypes();
      for (final et in entityTypes) {
        final group = _entityStateRegistry.get(et);
        if (group == null) {
          throw StateError('Storage group not found: $et');
        }
        try {
          await group.deleteByDomain(
            domainType: domainType,
            domainId: domainId,
          );
        } catch (e) {
          print('Error deleting entity states for $et: $e');
        }
      }

      // Delete all cursor sync states for the domain
      final cursorStatesToDelete = await _isar.cursorSyncStates
          .filter()
          .domainIdEqualTo(domainId)
          .findAll();
      final cursorIdsToDelete = cursorStatesToDelete.map((e) => e.id).toList();
      await _isar.cursorSyncStates.deleteAll(cursorIdsToDelete);

      // Delete all entity-type sync states for the domain
      final entityTypeSyncStatesToDelete = await _isar.isarEntityTypeSyncStates
          .filter()
          .domainIdEqualTo(domainId)
          .findAll();
      final etsIdsToDelete = entityTypeSyncStatesToDelete
          .map((e) => e.id)
          .toList();
      await _isar.isarEntityTypeSyncStates.deleteAll(etsIdsToDelete);
    });
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
class LocalStorageService extends IsarStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance =>
      _instance ??= LocalStorageService._();

  LocalStorageService._() : super('local_storage', 'LocalStorage');
}

class CloudStorageService extends IsarStorageService {
  static CloudStorageService? _instance;
  static CloudStorageService get instance =>
      _instance ??= CloudStorageService._();

  CloudStorageService._() : super('cloud_storage', 'CloudStorage');

  @override
  String getStorageType() => 'cloud';

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
