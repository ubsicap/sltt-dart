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
      print(
        'DEBUG: InMemoryStorage merged state for CID ${newChange.cid}: $merged',
      );
      newState = TestEntityState.fromJson(merged);
      final states = _statesByDomainType.putIfAbsent(domainType, () => {});
      states[_key(
            newChange.domainId,
            newChange.entityType,
            newChange.entityId,
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
    required domainType,
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
    for (final c in _changes) {
      if (c.cid == cid && c.domainId == domainId && c.domainType == domainType)
        return c;
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

    final filtered = _changes.where((c) => c.domainId == domainId).toList()
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
  }) {
    // TODO: implement getEntityState
    throw UnimplementedError();
  }
}
