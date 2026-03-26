import '../logging.dart';
import '../models/base_change_log_entry.dart';
import '../models/base_entity_state.dart';
import '../models/entity_type.dart';
import '../services/change_entity_state_service.dart';
import '../services/change_processing_service.dart';
import 'base_storage_service.dart';
import 'stats/entity_type_stats.dart';
import 'stats/entity_type_summary.dart';

/// A fully in-memory [BaseStorageService] implementation suitable for use in
/// tests and non-persisted contexts such as migration scripts.
///
/// Callers must supply concrete factory functions for deserializing change-log
/// entries and entity states so the storage is not tied to any single model
/// implementation.
///
/// Example – using Dynamo types (for a migration script):
/// ```dart
/// InMemoryStorage(
///   storageType: 'cloud',
///   fromJsonChangeLogEntry: DynamoChangeLogEntry.fromJson,
///   fromJsonEntityState: DynamoEntityState.fromJson,
/// )
/// ```
///
/// Example – using test types (via the test helpers shim):
/// ```dart
/// testInMemoryStorage(storageType: 'local')
/// ```
class InMemoryStorage implements BaseStorageService {
  /// `cloud` or `local`
  final String storageType;

  final String storageId;

  /// Factory that deserializes a change-log entry from JSON.
  final BaseChangeLogEntry Function(Map<String, dynamic>)
  _fromJsonChangeLogEntry;

  /// Factory that deserializes an entity state from JSON.
  /// The map already contains the `entityType` key.
  final BaseEntityState Function(Map<String, dynamic>) _fromJsonEntityState;

  final Map<String, List<BaseChangeLogEntry>> _changesByDomainType = {};
  int _nextSeq = 1;
  final Map<String, Map<String, BaseEntityState>> _statesByDomainType = {};

  InMemoryStorage({
    required this.storageType,
    String? storageId,
    required BaseChangeLogEntry Function(Map<String, dynamic>)
    fromJsonChangeLogEntry,
    required BaseEntityState Function(Map<String, dynamic>) fromJsonEntityState,
  }) : storageId = storageId ?? BaseStorageService.generateShortStorageId(),
       _fromJsonChangeLogEntry = fromJsonChangeLogEntry,
       _fromJsonEntityState = fromJsonEntityState;

  @override
  int get batchPutChangesLimit => 1000;

  @override
  BaseEntityState createEntityStateFromJson({
    required String entityType,
    required Map<String, dynamic> json,
  }) {
    final normalized = <String, dynamic>{...json, 'entityType': entityType};
    return _fromJsonEntityState(normalized);
  }

  String _key(String domainId, String entityType, String entityId) =>
      '$domainId|$entityType|$entityId';

  @override
  Future<void> initialize() async {}

  @override
  Future<void> close() async {}

  @override
  String getStorageType() => storageType;

  @override
  Future<String> getStorageId() async => storageId;

  @override
  Future<String> ensureStorageId() async => storageId;

  @override
  Future<List<String>> getSupportedEntityTypes() async => EntityType.allValues;

  @override
  Future<BaseEntityState?> getEntityState({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
  }) async {
    return _statesByDomainType[domainType]?[_key(
      domainId,
      entityType,
      entityId,
    )];
  }

  @override
  Future<Map<String, BaseEntityState?>> batchGetEntityState({
    required List<
      ({String domainType, String domainId, String entityType, String entityId})
    >
    keys,
  }) async {
    final result = <String, BaseEntityState?>{};
    for (final key in keys) {
      result[key.entityId] = await getEntityState(
        domainType: key.domainType,
        domainId: key.domainId,
        entityType: key.entityType,
        entityId: key.entityId,
      );
    }
    return result;
  }

  @override
  Future<UpdateChangeLogAndStatesResult> updateChangeLogAndStates({
    required String domainType,
    required List<ChangeLogAndStateRequest> requests,
  }) async {
    final outChanges = <BaseChangeLogEntry>[];
    final outStates = <BaseEntityState?>[];
    for (var req in requests) {
      final res = await _updateOneChangeLogAndState(
        domainType: domainType,
        changeLogEntry: req.changeLogEntry,
        changeUpdates: req.changeUpdates,
        entityState: req.entityState,
        stateUpdates: req.stateUpdates,
        operationCounts: req.operationCounts,
        skipChangeLogWrite: req.skipChangeLogWrite,
        skipStateWrite: req.skipStateWrite,
      );
      outChanges.add(res.newChangeLogEntry);
      outStates.add(res.newEntityState);
    }
    return (newChangeLogEntries: outChanges, newEntityStates: outStates);
  }

  Future<UpdateChangeLogAndStateResult> _updateOneChangeLogAndState({
    required String domainType,
    required BaseChangeLogEntry changeLogEntry,
    required Map<String, dynamic> changeUpdates,
    BaseEntityState? entityState,
    required Map<String, dynamic> stateUpdates,
    required OperationCounts operationCounts,
    bool skipChangeLogWrite = false,
    bool skipStateWrite = false,
  }) async {
    final newChangeJson = {...changeLogEntry.toJson(), ...changeUpdates};

    // Ensure a sequence number exists and is monotonic for in-memory storage.
    if (!skipChangeLogWrite &&
        (newChangeJson['seq'] == null ||
            (newChangeJson['seq'] is int && newChangeJson['seq'] == 0))) {
      newChangeJson['seq'] = _nextSeq++;
    }
    final newChange = _fromJsonChangeLogEntry(newChangeJson);

    final prior = entityState?.toJson() ?? <String, dynamic>{};
    final merged = {...prior, ...stateUpdates}
      ..removeWhere((k, v) => v == null);

    BaseEntityState? newState;
    try {
      SlttLogger.logger.fine(
        'DEBUG: InMemoryStorage merged state for CID ${newChange.cid}: $merged',
      );
      newState = skipStateWrite ? null : _fromJsonEntityState(merged);
      final states = _statesByDomainType.putIfAbsent(domainType, () => {});
      ChangeProcessingService.checkCoreChangeStorageResponsibilities(
        storage: this,
        changeToPut: newChange,
        entityStateToPut: newState ?? entityState!,
        skipChangeLogWrite: skipChangeLogWrite,
        skipStateWrite: skipStateWrite,
      );
      if (!skipChangeLogWrite) {
        final changes = _changesByDomainType.putIfAbsent(domainType, () => []);
        changes.add(newChange);
      }
      if (!skipStateWrite && newState != null) {
        // Use entityId from the deserialized state (may differ from
        // changeLogEntry.entityId for namespaced ids).
        states[_key(
              newChange.domainId,
              newChange.entityType,
              newState.entityId,
            )] =
            newState;
      }
    } catch (e, st) {
      SlttLogger.logger.severe(
        'ERROR: InMemoryStorage failed to construct entity state from merged payload: $e',
      );
      SlttLogger.logger.severe('ERROR: merged payload: $merged');
      SlttLogger.logger.severe(st.toString());
      rethrow;
    }

    return (newChangeLogEntry: newChange, newEntityState: newState);
  }

  @override
  Future<BaseChangeLogEntry?> getChange({
    required String domainType,
    required String domainId,
    required String cid,
  }) async {
    final changes =
        _changesByDomainType[domainType] ?? const <BaseChangeLogEntry>[];
    for (final c in changes) {
      if (c.cid == cid && c.domainId == domainId) return c;
    }
    return null;
  }

  @override
  Future<List<BaseChangeLogEntry>> getChangesWithCursor({
    required String domainType,
    required String domainId,
    int? cursor,
    int? limit,
  }) async {
    final effectiveLimit = limit ?? 100;

    final source =
        _changesByDomainType[domainType] ?? const <BaseChangeLogEntry>[];
    final filtered = source.where((c) => c.domainId == domainId).toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));

    final startIndex = cursor == null
        ? 0
        : filtered.indexWhere((c) => c.seq > cursor);
    if (startIndex < 0) {
      return <BaseChangeLogEntry>[];
    }

    final endIndex = (startIndex + effectiveLimit).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  @override
  Future<EntityTypeStats> getChangeStats({
    required String domainType,
    required String domainId,
  }) async {
    final changes = _changesByDomainType[domainType] ?? [];

    final Map<String, Map<String, dynamic>> perType = {};
    int totalCreates = 0;
    int totalUpdates = 0;
    int totalDeletes = 0;
    DateTime? mostRecentChangeAt;
    int mostRecentSeq = -1;

    for (final c in changes) {
      if (c.domainId != domainId) continue;
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
      total: changes.length,
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
    final changeStats = await getChangeStats(
      domainType: domainType,
      domainId: domainId,
    );
    final states = _statesByDomainType[domainType] ?? {};

    final Map<String, int> counts = {};
    final Map<String, DateTime> mostRecentChangeAtByType = {};
    DateTime? mostRecentChangeAt;

    for (final entry in states.entries) {
      final key = entry.key; // 'domainId|entityType|entityId'
      if (!key.startsWith('$domainId|')) continue;
      final parts = key.split('|');
      if (parts.length != 3) continue;

      final entityType = parts[1];
      counts[entityType] = (counts[entityType] ?? 0) + 1;

      final state = entry.value;
      try {
        final ca = state.change_changeAt.toUtc();
        final existingByType = mostRecentChangeAtByType[entityType];
        if (existingByType == null || ca.isAfter(existingByType)) {
          mostRecentChangeAtByType[entityType] = ca;
        }
        if (mostRecentChangeAt == null || ca.isAfter(mostRecentChangeAt)) {
          mostRecentChangeAt = ca;
        }
      } catch (_) {}
    }

    final Map<String, EntityTypeSummary> typedPerType = {};
    counts.forEach((entityType, totalStates) {
      final changeSummary = changeStats.entityTypes[entityType];
      typedPerType[entityType] = EntityTypeSummary(
        creates: changeSummary?.creates ?? 0,
        updates: changeSummary?.updates ?? 0,
        deletes: changeSummary?.deletes ?? 0,
        total: totalStates,
        latestChangeAt:
            mostRecentChangeAtByType[entityType]?.toIso8601String() ??
            '1970-01-01T00:00:00Z',
        latestSeq: changeSummary?.latestSeq ?? -1,
      );
    });

    final totals = EntityTypeSummary(
      creates: changeStats.totals.creates,
      updates: changeStats.totals.updates,
      deletes: changeStats.totals.deletes,
      total: counts.values.fold(0, (a, b) => a + b),
      latestChangeAt:
          mostRecentChangeAt?.toIso8601String() ?? '1970-01-01T00:00:00Z',
      latestSeq: changeStats.totals.latestSeq,
    );

    return EntityTypeStats(entityTypes: typedPerType, totals: totals);
  }

  @override
  Future<List<String>> getAllDomainIds({required String domainType}) async =>
      _statesByDomainType[domainType]?.keys
          .map((k) => k.split('|').first)
          .toSet()
          .toList() ??
      [];

  @override
  Future<Map<String, dynamic>> getEntityStates({
    required String domainType,
    required String domainId,
    required String entityType,
    String? cursor,
    int? limit,
    String? parentId,
    String? parentProp,
    DateTime? storedAfter,
  }) async {
    final states = _statesByDomainType[domainType] ?? {};
    var results = states.entries
        .where(
          (e) =>
              e.key.startsWith('$domainId|$entityType|') &&
              (cursor == null ||
                  e.key.compareTo('$domainId|$entityType|$cursor') > 0),
        )
        .map((e) => e.value.toJson())
        .toList();

    if (parentId != null) {
      results = results
          .where((state) => state['data_parentId'] == parentId)
          .toList();
    }
    if (parentProp != null) {
      results = results
          .where((state) => state['data_parentProp'] == parentProp)
          .toList();
    }
    if (storedAfter != null) {
      results = results.where((state) {
        final storedAtStr = state['change_storedAt'] as String?;
        if (storedAtStr == null) return false;
        final storedAt = DateTime.tryParse(storedAtStr);
        if (storedAt == null) return false;
        return storedAt.isAfter(storedAfter);
      }).toList();
    }

    results = results.take(limit ?? 100).toList();

    if (results.isEmpty) {
      return {'items': [], 'nextCursor': null, 'hasMore': false};
    }
    return {
      'items': results,
      'nextCursor': results.last['entityId'] as String,
      'hasMore': false,
    };
  }

  @override
  Future<void> testResetDomainStorage({
    required String domainType,
    required String domainId,
    bool isAdminReset = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<TEntityState> testStoreState<TEntityState extends BaseEntityState>({
    required TEntityState entityState,
  }) async {
    final states = _statesByDomainType.putIfAbsent(
      entityState.domainType,
      () => {},
    );
    states[_key(
          entityState.change_domainId,
          entityState.entityType,
          entityState.entityId,
        )] =
        entityState;
    return entityState;
  }

  @override
  Future<void> upsertEntityTypeSyncStates({
    required String domainType,
    required String entityType,
    required BaseChangeLogEntry newChange,
    required OperationCounts operationCounts,
    bool forChangeLog = false,
  }) async {
    // No-op for in-memory storage.
  }

  @override
  Future<BaseChangeLogEntry> testStoreChangeFromJson({
    required Object changeJson,
  }) async {
    final json = changeJson as Map<String, dynamic>;
    final change = _fromJsonChangeLogEntry(json);
    final changes = _changesByDomainType.putIfAbsent(
      change.domainType,
      () => [],
    );
    changes.add(change);
    return change;
  }
}
