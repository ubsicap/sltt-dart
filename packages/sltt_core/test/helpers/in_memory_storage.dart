import 'package:sltt_core/sltt_core.dart';

import '../test_models.dart';

class InMemoryStorage implements BaseStorageService {
  /// cloud, local
  final String storageType;
  final String storageId;
  final Map<String, List<TestChangeLogEntry>> _changesByDomainType = {};
  int _nextSeq = 1;
  final Map<String, Map<String, TestEntityState>> _statesByDomainType = {};

  InMemoryStorage({required this.storageType, String? storageId})
    : storageId = storageId ?? BaseStorageService.generateShortStorageId();

  String _key(String projectId, String entityType, String entityId) =>
      '$projectId|$entityType|$entityId';

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
  Future<BaseEntityState?> getCurrentEntityState({
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
  Future<UpdateChangeLogAndStateResult> updateChangeLogAndState({
    required String domainType,
    required BaseChangeLogEntry changeLogEntry,
    required Map<String, dynamic> changeUpdates,
    BaseEntityState? entityState,
    required Map<String, dynamic> stateUpdates,
  }) async {
    final newChangeJson = {...changeLogEntry.toJson(), ...changeUpdates};
    // Ensure a sequence number exists and is monotonic for in-memory storage
    if (newChangeJson['seq'] == null ||
        (newChangeJson['seq'] is int && newChangeJson['seq'] == 0)) {
      newChangeJson['seq'] = _nextSeq++;
    }
    final newChange = TestChangeLogEntry.fromJson(newChangeJson);

    final changes = _changesByDomainType.putIfAbsent(domainType, () => []);
    // persist change for subsequent queries
    changes.add(newChange);

    final prior = (entityState?.toJson() ?? <String, dynamic>{});
    final merged = {...prior, ...stateUpdates}
      ..removeWhere((k, v) => v == null);

    // Debug: log merged state payload before constructing TestEntityState
    TestEntityState? newState;
    try {
      // Intentionally do not inject fallback fields here. Tests should provide
      // the minimal required fields
      print(
        'DEBUG: InMemoryStorage merged state for CID ${newChange.cid}: $merged',
      );
      newState = TestEntityState.fromJson(merged);
      final states = _statesByDomainType.putIfAbsent(domainType, () => {});
      // Use the entityId from the serialized state (newState.entityId)
      // because TestEntityState may include a namespaced id (e.g. 'seed-project-task-1')
      states[_key(
            newChange.domainId,
            newChange.entityType,
            newState.entityId,
          )] =
          newState;
    } catch (e, st) {
      // Surface parsing errors for diagnostics
      print(
        'ERROR: Failed to construct TestEntityState from merged payload: $e',
      );
      print('ERROR: merged payload: $merged');
      print(st);
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
        _changesByDomainType[domainType] ?? const <TestChangeLogEntry>[];
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
        _changesByDomainType[domainType] ?? const <TestChangeLogEntry>[];
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
    // Compute per-entityType creates/updates/deletes from the in-memory change log
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

      // Maintain latest changeAt/seq per entityType
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
    // Compute stats based on current persisted entity states
    final states = _statesByDomainType[domainType] ?? {};

    final Map<String, int> counts = {};
    DateTime? mostRecentChangeAt;

    for (final entry in states.entries) {
      final key = entry.key; // 'domainId|entityType|entityId'
      if (!key.startsWith('$domainId|')) continue;
      final parts = key.split('|');
      if (parts.length != 3) continue;
      final entityType = parts[1];
      counts[entityType] = (counts[entityType] ?? 0) + 1;

      final state = entry.value;
      // Attempt to read latest change metadata from TestEntityState fields
      try {
        final ca = state.change_changeAt.toUtc();
        if (mostRecentChangeAt == null || ca.isAfter(mostRecentChangeAt)) {
          mostRecentChangeAt = ca;
        }
      } catch (_) {}
      // TestEntityState doesn't have a seq field in this in-memory model; leave as -1
    }

    final Map<String, EntityTypeSummary> typedPerType = {};
    counts.forEach((k, v) {
      typedPerType[k] = EntityTypeSummary(
        creates: 0,
        updates: 0,
        deletes: 0,
        total: v,
        latestChangeAt:
            mostRecentChangeAt?.toIso8601String() ?? '1970-01-01T00:00:00Z',
        latestSeq: -1,
      );
    });

    final totals = EntityTypeSummary(
      creates: 0,
      updates: 0,
      deletes: 0,
      total: counts.values.fold(0, (a, b) => a + b),
      latestChangeAt:
          mostRecentChangeAt?.toIso8601String() ?? '1970-01-01T00:00:00Z',
      latestSeq: -1,
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
    bool includeMetadata = false,
  }) async {
    final states = _statesByDomainType[domainType] ?? {};
    final results = states.entries
        .where(
          (e) =>
              e.key.startsWith('$domainId|$entityType|') &&
              (cursor == null ||
                  e.key.compareTo('$domainId|$entityType|$cursor') > 0),
        )
        .take(limit ?? 100)
        .map((e) => e.value.toJson())
        .toList();
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
  Future<Map<String, dynamic>> getEntityState({
    required String domainType,
    required String domainId,
    required String entityId,
    bool includeMetadata = false,
  }) async {
    // Scan states map for the specific entity within the domain
    final states =
        _statesByDomainType[domainType] ?? const <String, TestEntityState>{};
    final prefix = '$domainId|';
    for (final entry in states.entries) {
      if (entry.key.startsWith(prefix)) {
        final parts = entry.key.split('|');
        if (parts.length == 3 && parts[2] == entityId) {
          return entry.value.toJson();
        }
      }
    }
    return <String, dynamic>{};
  }
}
