import 'package:sltt_core/sltt_core.dart';

import '../test_models.dart';

class InMemoryStorage implements BaseStorageService {
  final String _storageId;
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
    final newChange = TestChangeLogEntry.fromJson(newChangeJson);

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
    return TestChangeLogEntry.fromJson(changeData);
  }

  @override
  Future<BaseChangeLogEntry?> getChange(String projectId, int seq) async =>
      null;

  @override
  Future<List<BaseChangeLogEntry>> getChangesWithCursor({
    required String projectId,
    int? cursor,
    int? limit,
  }) async => <BaseChangeLogEntry>[];

  @override
  Future<List<BaseChangeLogEntry>> getChangesSince(
    String projectId,
    int seq,
  ) async => <BaseChangeLogEntry>[];

  @override
  Future<Map<String, dynamic>> getChangeStats(String projectId) async => {
    'total': 0,
    'creates': 0,
    'updates': 0,
    'deletes': 0,
  };

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
