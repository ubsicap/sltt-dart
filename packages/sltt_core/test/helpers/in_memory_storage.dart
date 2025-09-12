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
      // Ensure required test-state fields are present to avoid JSON deserialization errors
      if (!merged.containsKey('data_nameLocal')) {
        merged['data_nameLocal'] = '';
      }
      // Make sure domainType and entityType are present for test deserializers
      if (!merged.containsKey('domainType')) {
        merged['domainType'] = domainType;
      }
      if (!merged.containsKey('entityType')) {
        merged['entityType'] = newChange.entityType;
      }
      // Ensure presence of fields expected by TestEntityState.fromJson
      merged['unknownJson'] = merged['unknownJson'] ?? '{}';
      merged['change_domainId'] =
          merged['change_domainId'] ?? newChange.domainId;
      merged['change_domainId_orig_'] =
          merged['change_domainId_orig_'] ?? newChange.domainId;
      merged['change_changeAt'] =
          merged['change_changeAt'] ?? newChange.changeAt.toIso8601String();
      merged['change_changeAt_orig_'] =
          merged['change_changeAt_orig_'] ??
          newChange.changeAt.toIso8601String();
      merged['change_cid'] = merged['change_cid'] ?? newChange.cid;
      merged['change_cid_orig_'] = merged['change_cid_orig_'] ?? newChange.cid;
      merged['change_changeBy'] =
          merged['change_changeBy'] ?? newChange.changeBy;
      merged['change_changeBy_orig_'] =
          merged['change_changeBy_orig_'] ?? newChange.changeBy;
      merged['data_parentId'] = merged['data_parentId'] ?? '';
      merged['data_parentId_changeAt_'] =
          merged['data_parentId_changeAt_'] ??
          newChange.changeAt.toIso8601String();
      merged['data_parentId_cid_'] =
          merged['data_parentId_cid_'] ?? newChange.cid;
      merged['data_parentId_changeBy_'] =
          merged['data_parentId_changeBy_'] ?? newChange.changeBy;
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
  Future<BaseChangeLogEntry> createChange({
    required String domainType,
    required Map<String, dynamic> changeData,
  }) async {
    final data = Map<String, dynamic>.from(changeData);
    if (data['seq'] == null || (data['seq'] is int && data['seq'] == 0)) {
      data['seq'] = _nextSeq++;
    }
    final change = TestChangeLogEntry.fromJson(data);
    final changes = _changesByDomainType.putIfAbsent(domainType, () => []);
    changes.add(change);
    return change;
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
  Future<Map<String, dynamic>> getChangeStats({
    required String domainType,
    required String domainId,
  }) async {
    final changes = _changesByDomainType[domainType] ?? [];
    final proj = changes.where((c) => c.domainId == domainId).toList();
    final total = proj.length;
    final creates = proj.where((c) => c.operation == 'create').length;
    final updates = proj.where((c) => c.operation == 'update').length;
    final deletes = proj.where((c) => c.operation == 'delete').length;
    return {
      'total': total,
      'creates': creates,
      'updates': updates,
      'deletes': deletes,
    };
  }

  @override
  Future<Map<String, int>> getEntityTypeStats({
    required String domainType,
    String? domainId,
  }) async => <String, int>{};

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
