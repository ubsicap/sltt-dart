import 'package:aws_backend/aws_backend.dart';
import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:aws_backend/src/models/dynamo_entity_state.dart';
import 'package:aws_backend/src/models/dynamo_entity_state_serialization_registry.dart';
import 'package:sltt_core/sltt_core.dart';

class FakeDynamoDBStorageService extends DynamoDBStorageService {
  FakeDynamoDBStorageService()
    : super(
        tableName: 'test-table',
        region: 'us-east-1',
        useLocalDynamoDB: true,
      ) {
    // Ensure serialization factories are registered for tests that
    // deserialize/validate change-log entries without calling real storage
    ensureDynamoSerializersRegistered();
  }

  final String _storageId = 'test-storage';

  @override
  String getStorageType() => 'cloud';

  @override
  Future<void> initialize() async {}

  @override
  Future<void> close() async {}

  @override
  Future<String> ensureStorageId() async => _storageId;

  @override
  Future<String> getStorageId() async => _storageId;

  @override
  Future<List<String>> getAllDomainIds({required String domainType}) async {
    return ['__test1', 'project1'];
  }

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
    return {
      'items': <Map<String, dynamic>>[],
      'hasMore': false,
      'nextCursor': null,
    };
  }

  @override
  Future<EntityTypeStats> getStateStats({
    required String domainType,
    required String domainId,
  }) async {
    return EntityTypeStats(
      entityTypes: const {},
      totals: EntityTypeSummary(
        total: 0,
        creates: 0,
        updates: 0,
        deletes: 0,
        latestChangeAt: '1970-01-01T00:00:00Z',
        latestSeq: -1,
      ),
    );
  }

  @override
  Future<EntityTypeStats> getChangeStats({
    required String domainType,
    required String domainId,
  }) async {
    return EntityTypeStats(
      entityTypes: const {},
      totals: EntityTypeSummary(
        total: 0,
        creates: 0,
        updates: 0,
        deletes: 0,
        latestChangeAt: '1970-01-01T00:00:00Z',
        latestSeq: -1,
      ),
    );
  }

  @override
  Future<BaseEntityState?> getEntityState({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
  }) async {
    // For unit tests we simulate that no prior state exists by default.
    return null;
  }

  @override
  Future<UpdateChangeLogAndStateResult> updateChangeLogAndState({
    required String domainType,
    required BaseChangeLogEntry changeLogEntry,
    required Map<String, dynamic> changeUpdates,
    BaseEntityState? entityState,
    required Map<String, dynamic> stateUpdates,
    required OperationCounts operationCounts,
    bool skipChangeLogWrite = false,
    bool skipStateWrite = false,
  }) async {
    if (skipChangeLogWrite && skipStateWrite) {
      return (newChangeLogEntry: changeLogEntry, newEntityState: null);
    }

    // Build merged change JSON and ensure required metadata for tests
    final mergedChangeJson = <String, dynamic>{
      ...changeLogEntry.toJson(),
      ...changeUpdates,
    }..removeWhere((k, v) => v == null);

    // Ensure seq exists for deterministic behavior
    var seq = mergedChangeJson['seq'] as int? ?? 0;
    if (seq <= 0) seq = 1;
    mergedChangeJson['seq'] = seq;

    // Normalize operation: default to 'create' for empty operations in tests
    if (mergedChangeJson['operation'] == null ||
        (mergedChangeJson['operation'] as String).isEmpty) {
      mergedChangeJson['operation'] = 'create';
    }

    // Construct a DynamoChangeLogEntry (uses registered serializers)
    final newChange = DynamoChangeLogEntry.fromJson(mergedChangeJson);

    final now = DateTime.now().toUtc();
    // Build new entity state JSON by merging prior state (if any) with updates.
    // Provide safe defaults for required fields when prior state is absent.
    final prior = entityState?.toJson() ?? <String, dynamic>{};
    final mergedState = <String, dynamic>{...prior, ...stateUpdates}
      ..removeWhere((k, v) => v == null);

    // Ensure canonical and required fields exist on state for tests
    mergedState['entityId'] = mergedState['entityId'] ?? newChange.entityId;
    mergedState['entityType'] =
        mergedState['entityType'] ?? newChange.entityType;
    mergedState['domainType'] = mergedState['domainType'] ?? domainType;
    mergedState['unknownJson'] = mergedState['unknownJson'] ?? '{}';

    // Populate change_* fields from the new change if missing
    mergedState['change_domainId'] =
        mergedState['change_domainId'] ?? newChange.domainId;
    mergedState['change_domainId_orig_'] =
        mergedState['change_domainId_orig_'] ?? newChange.domainId;
    mergedState['change_changeAt'] =
        mergedState['change_changeAt'] ?? now.toIso8601String();
    mergedState['change_changeAt_orig_'] =
        mergedState['change_changeAt_orig_'] ?? now.toIso8601String();
    mergedState['change_cid'] = mergedState['change_cid'] ?? newChange.cid;
    mergedState['change_cid_orig_'] =
        mergedState['change_cid_orig_'] ?? newChange.cid;
    mergedState['change_changeBy'] =
        mergedState['change_changeBy'] ?? newChange.changeBy;
    mergedState['change_changeBy_orig_'] =
        mergedState['change_changeBy_orig_'] ?? newChange.changeBy;
    mergedState['change_storedAt'] =
        mergedState['change_storedAt'] ?? now.toIso8601String();

    // Minimal data_* required fields
    mergedState['data_parentId'] = mergedState['data_parentId'] ?? '';
    mergedState['data_parentId_changeAt_'] =
        mergedState['data_parentId_changeAt_'] ?? now.toIso8601String();
    mergedState['data_parentId_cid_'] =
        mergedState['data_parentId_cid_'] ?? newChange.cid;
    mergedState['data_parentId_changeBy_'] =
        mergedState['data_parentId_changeBy_'] ?? newChange.changeBy;
    mergedState['data_parentProp'] = mergedState['data_parentProp'] ?? '';
    mergedState['data_parentProp_changeAt_'] =
        mergedState['data_parentProp_changeAt_'] ?? now.toIso8601String();
    mergedState['data_parentProp_cid_'] =
        mergedState['data_parentProp_cid_'] ?? newChange.cid;
    mergedState['data_parentProp_changeBy_'] =
        mergedState['data_parentProp_changeBy_'] ?? newChange.changeBy;

    final newState = DynamoEntityState.fromJson(mergedState);

    // Validate core storage responsibilities (no mutation)
    ChangeProcessingService.checkCoreChangeStorageResponsibilities(
      storage: this,
      changeToPut: newChange,
      entityStateToPut: newState,
      skipChangeLogWrite: skipChangeLogWrite,
      skipStateWrite: skipStateWrite,
    );

    return (newChangeLogEntry: newChange, newEntityState: newState);
  }

  @override
  Future<void> upsertEntityTypeSyncStates({
    required String domainType,
    required String entityType,
    required BaseChangeLogEntry newChange,
    required OperationCounts operationCounts,
    bool forChangeLog = false,
  }) async {
    // No-op for fake storage
  }

  @override
  Future<void> testResetDomainStorage({
    required String domainType,
    required String domainId,
    bool isAdminReset = false,
  }) async {}
}
