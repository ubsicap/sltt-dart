import 'package:sltt_core/sltt_core.dart';

import '../test_models.dart';

class InMemoryStorage implements BaseStorageService {
  final String _storageId;
  final List<TestChangeLogEntry> _changes = [];
  int _nextSeq = 1;
  final Map<String, TestEntityState> _states = {};

  InMemoryStorage({String? storageId}) : _storageId = storageId ?? 'local';

  String _key(String projectId, String entityType, String entityId) =>
      '$projectId|$entityType|$entityId';

  @override
  Future<void> initialize() async {}

  @override
  Future<void> close() async {}

  @override
  String getStorageType() => _storageId == 'local' ? 'local' : 'cloud';

  @override
  Future<String> getStorageId() async => _storageId;

  @override
  Future<String> ensureStorageId() async => _storageId;

  @override
  Future<BaseEntityState?> getCurrentEntityState(
    String projectId,
    String entityType,
    String entityId,
  ) async {
    return _states[_key(projectId, entityType, entityId)];
  }

  @override
  Future<UpdateChangeLogAndStateResult> updateChangeLogAndState({
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

    // persist change for subsequent queries
    _changes.add(newChange);

    final prior = (entityState?.toJson() ?? <String, dynamic>{});
    final merged = {...prior, ...stateUpdates}
      ..removeWhere((k, v) => v == null);

    final newState = TestEntityState.fromJson(merged);
    _states[_key(
          newChange.domainId,
          newChange.entityType,
          newChange.entityId,
        )] =
        newState;

    return (newChangeLogEntry: newChange, newEntityState: newState);
  }

  @override
  Future<BaseChangeLogEntry> createChange(
    Map<String, dynamic> changeData,
  ) async {
    final data = Map<String, dynamic>.from(changeData);
    if (data['seq'] == null || (data['seq'] is int && data['seq'] == 0)) {
      data['seq'] = _nextSeq++;
    }
    final change = TestChangeLogEntry.fromJson(data);
    _changes.add(change);
    return change;
  }

  @override
  Future<BaseChangeLogEntry?> getChange(String projectId, int seq) async {
    for (final c in _changes) {
      if (c.seq == seq && c.domainId == projectId) return c;
    }
    return null;
  }

  @override
  Future<List<BaseChangeLogEntry>> getChangesWithCursor({
    required String projectId,
    int? cursor,
    int? limit,
  }) async {
    final effectiveLimit = limit ?? 100;

    final filtered = _changes.where((c) => c.domainId == projectId).toList()
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
  Future<List<BaseChangeLogEntry>> getChangesSince(
    String projectId,
    int seq,
  ) async {
    return getChangesWithCursor(projectId: projectId, cursor: seq);
  }

  @override
  Future<Map<String, dynamic>> getChangeStats(String projectId) async {
    final proj = _changes.where((c) => c.domainId == projectId).toList();
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
  Future<Map<String, int>> getEntityTypeStats(String projectId) async =>
      <String, int>{};

  @override
  Future<List<String>> getAllProjects() async =>
      _states.keys.map((k) => k.split('|').first).toSet().toList();

  @override
  Future<Map<String, dynamic>> getEntityStates({
    required String projectId,
    required String entityType,
    String? cursor,
    int? limit,
    bool includeMetadata = false,
  }) async {
    final results = _states.entries
        .where(
          (e) =>
              e.key.startsWith('$projectId|$entityType|') &&
              (cursor == null ||
                  e.key.compareTo('$projectId|$entityType|$cursor') > 0),
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
  Future<void> markAsOutdated(
    String projectId,
    int seq,
    int outdatedBy,
  ) async {}

  @override
  Future<List<BaseChangeLogEntry>> getChangesNotOutdated(
    String projectId,
  ) async => getChangesWithCursor(projectId: projectId);
}
