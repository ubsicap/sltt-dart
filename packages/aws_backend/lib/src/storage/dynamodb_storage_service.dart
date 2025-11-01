import 'dart:convert';
import 'dart:io';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';

import '../models/dynamo_change_log_entry.dart';
import '../models/dynamo_entity_type_sync_state.dart';
import '../models/dynamo_serialization.dart';

/// DynamoDB implementation of [BaseStorageService].
///
/// All merge/conflict logic is delegated to [ChangeProcessingService]. This
/// class is responsible solely for persisting and retrieving change log entries
/// and entity state documents from a single DynamoDB table.
///
/// ## Key Pattern Convention (ElectroDB-Compatible)
///
/// This implementation follows ElectroDB conventions for DynamoDB key patterns:
/// - Service prefix: `$sltt` (multi-tenant isolation)
/// - Collection concept: `$changes`, `$states`, `$etsc`, `$etss`, `$seq`
/// - Descriptive field names: `domainType_`, `domainId_`, `entityType_`, etc.
///
/// Examples:
/// ```dart
/// // Change Log
/// pk: '$sltt#change#domainType_project#domainId_abc123#entityType_portion#entityId_entity1'
/// sk: '$changes#change#cid_1234567890'
///
/// // Entity State
/// pk: '$sltt#state#domainType_project#domainId_abc123#entityType_portion'
/// sk: '$states#state#entityId_entity1'
/// ```
class DynamoDBStorageService extends BaseStorageService {
  DynamoDBStorageService({
    required this.tableName,
    this.region = 'us-east-1',
    this.useLocalDynamoDB = false,
    this.localEndpoint,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String tableName;
  final String region;
  final bool useLocalDynamoDB;
  final String? localEndpoint;

  final http.Client _httpClient;

  /// ElectroDB-compatible service prefix for multi-tenant isolation
  static const String _servicePrefix = 'sltt';

  bool _initialized = false;
  late String _endpoint;
  late Map<String, String> _baseHeaders;

  String? _storageId;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    ensureDynamoSerializersRegistered();

    if (useLocalDynamoDB) {
      _endpoint = localEndpoint ?? 'http://localhost:8000';
      _baseHeaders = <String, String>{
        'Content-Type': 'application/x-amz-json-1.0',
        'Authorization':
            'AWS4-HMAC-SHA256 Credential=fake/20230101/$region/dynamodb/aws4_request, SignedHeaders=host;x-amz-date, Signature=fake',
        'X-Amz-Target': 'DynamoDB_20120810',
      };
    } else {
      _endpoint = 'https://dynamodb.$region.amazonaws.com';
      _baseHeaders = <String, String>{
        'Content-Type': 'application/x-amz-json-1.0',
        'X-Amz-Target': 'DynamoDB_20120810',
      };
    }

    if (useLocalDynamoDB) {
      await _createTableIfNotExists();
    }

    await ensureStorageId();

    _initialized = true;
  }

  @override
  Future<void> close() async {
    _initialized = false;
    _httpClient.close();
  }

  @override
  String getStorageType() => 'cloud';

  @override
  Future<String> getStorageId() async {
    if (_storageId != null) return _storageId!;
    return ensureStorageId();
  }

  @override
  Future<String> ensureStorageId() async {
    if (_storageId != null) return _storageId!;
    _storageId = BaseStorageService.generateShortStorageId();
    return _storageId!;
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
    await initialize();

    final mergedChangeJson = <String, dynamic>{
      ...changeLogEntry.toJson(),
      ...changeUpdates,
    }..removeWhere((key, value) => value == null);

    final newChange = DynamoChangeLogEntry.fromJson(mergedChangeJson);

    if (!skipChangeLogWrite) {
      if (newChange.seq <= 0) {
        newChange.seq = await _nextSequence(
          domainType: domainType,
          domainId: newChange.domainId,
        );
      }
      await _putChangeLogEntry(newChange);

      // Upsert entity type sync state counters for change log
      await upsertEntityTypeSyncStates(
        domainType: domainType,
        entityType: newChange.entityType,
        newChange: newChange,
        operationCounts: operationCounts,
        forChangeLog: true,
      );
    }

    late final BaseEntityState newState;
    if (skipStateWrite && entityState != null && stateUpdates.isEmpty) {
      newState = entityState;
    } else {
      final currentStateJson =
          entityState?.toJson() ??
          _buildInitialStateJson(
            domainType: domainType,
            domainId: newChange.domainId,
            entityType: newChange.entityType,
            entityId: newChange.entityId,
            change: newChange,
          );
      final mergedStateJson = <String, dynamic>{
        ...currentStateJson,
        ...stateUpdates,
      }..removeWhere((key, value) => value == null);

      mergedStateJson['entityId'] = newChange.entityId;
      mergedStateJson['entityType'] = newChange.entityType;
      mergedStateJson['domainType'] = domainType;
      mergedStateJson['unknownJson'] = JsonUtils.normalize(
        mergedStateJson['unknownJson'] as String?,
      );

      newState = deserializeEntityStateSafely(mergedStateJson);

      if (!skipStateWrite) {
        await _putEntityState(newState);

        // Upsert entity type sync state counters
        await upsertEntityTypeSyncStates(
          domainType: domainType,
          entityType: newChange.entityType,
          newChange: newChange,
          operationCounts: operationCounts,
        );
      }
    }

    return (newChangeLogEntry: newChange, newEntityState: newState);
  }

  /// Stores an entity state without updating change log or sync states.
  ///
  /// This is a simplified version of updateChangeLogAndState that only handles
  /// entity state storage. Useful for testing or direct state manipulation.
  ///
  /// Parameters:
  /// - [entityState]: The complete entity state to store
  ///
  /// Returns the stored entity state (same instance).
  @override
  Future<TEntityState> testStoreState<TEntityState extends BaseEntityState>({
    required TEntityState entityState,
  }) async {
    await initialize();

    await _putEntityState(entityState);

    return entityState;
  }

  /// For testing: Store a change log entry directly without any processing or side effects.
  ///
  /// This is a simplified version that only handles change log storage.
  /// Useful for testing change log entry storage and retrieval.
  ///
  /// Parameters:
  /// - [changeJson]: The complete change log entry JSON to store
  ///
  /// Returns the stored change log entry.
  @override
  Future<BaseChangeLogEntry> testStoreChangeFromJson({
    required Map<String, dynamic> changeJson,
  }) async {
    await initialize();

    final change = DynamoChangeLogEntry.fromJson(changeJson);
    await _putChangeLogEntry(change);

    return change;
  }

  @override
  Future<BaseEntityState?> getEntityState({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
  }) async {
    await initialize();

    final response = await _dynamoRequest('GetItem', {
      'TableName': tableName,
      'Key': {
        'pk': {
          'S': _statePrimaryKey(
            domainType: domainType,
            domainId: domainId,
            entityType: entityType,
          ),
        },
        'sk': {'S': _stateSortKey(entityId: entityId)},
      },
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch entity state: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final item = payload['Item'] as Map<String, dynamic>?;
    if (item == null) return null;

    final decodedItem = _decodeItem(item, excludeStorageKeys: true);

    return deserializeEntityStateSafely(decodedItem);
  }

  @override
  Future<BaseChangeLogEntry?> getChange({
    required String domainType,
    required String domainId,
    required String cid,
  }) async {
    await initialize();

    // We need to query by domain prefix and cid sort key
    // Since we don't have entityType/entityId, we can't build complete pk
    // Use the domain prefix for begins_with query
    final pkPrefix = _changePrimaryKeyPrefix(
      domainType: domainType,
      domainId: domainId,
    );

    final sk = _changeSortKey(cid);

    final response = await _dynamoRequest('Query', {
      'TableName': tableName,
      'KeyConditionExpression': 'begins_with(pk, :pkPrefix) AND sk = :sk',
      'ExpressionAttributeValues': {
        ':pkPrefix': {'S': pkPrefix},
        ':sk': {'S': sk},
      },
      'Limit': 1,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch change: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['Items'] as List<dynamic>?;
    if (items == null || items.isEmpty) return null;

    return DynamoChangeLogEntry.fromJson(
      _decodeItem(
        items.first as Map<String, dynamic>,
        excludeStorageKeys: true,
      ),
    );
  }

  @override
  Future<List<BaseChangeLogEntry>> getChangesWithCursor({
    required String domainType,
    required String domainId,
    int? cursor,
    int? limit,
  }) async {
    await initialize();

    final gsiPk = _changeGsiPartition(
      domainType: domainType,
      domainId: domainId,
    );

    final payload = <String, dynamic>{
      'TableName': tableName,
      'IndexName': 'GSI1',
      'ScanIndexForward': true,
    };

    if (cursor != null) {
      // Use a range condition to get changes AFTER the cursor (exclusive)
      payload['KeyConditionExpression'] = 'gsi1pk = :pk AND gsi1sk > :sk';
      payload['ExpressionAttributeValues'] = {
        ':pk': {'S': gsiPk},
        ':sk': {'S': _changeGsiSortKey(cursor)},
      };
    } else {
      // No cursor, get all changes
      payload['KeyConditionExpression'] = 'gsi1pk = :pk';
      payload['ExpressionAttributeValues'] = {
        ':pk': {'S': gsiPk},
      };
    }

    if (limit != null) {
      payload['Limit'] = limit;
    }

    final response = await _dynamoRequest('Query', payload);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch changes: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['Items'] as List<dynamic>? ?? <dynamic>[];

    return items
        .map(
          (item) => DynamoChangeLogEntry.fromJson(
            _decodeItem(item as Map<String, dynamic>, excludeStorageKeys: true),
          ),
        )
        .toList();
  }

  @override
  Future<EntityTypeStats> getChangeStats({
    required String domainType,
    required String domainId,
  }) async {
    await initialize();

    // Query all EntityTypeSyncState records for change logs
    final pk = _entityTypeSyncStatePrimaryKey(
      domainType: domainType,
      domainId: domainId,
      forChangeLog: true,
    );

    final response = await _dynamoRequest('Query', {
      'TableName': tableName,
      'KeyConditionExpression': 'pk = :pk',
      'ExpressionAttributeValues': {
        ':pk': {'S': pk},
      },
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to get change stats: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (body['Items'] as List<dynamic>?) ?? <dynamic>[];

    // Build per-entity-type statistics
    final entityTypes = <String, EntityTypeSummary>{};
    var totalCreates = 0;
    var totalUpdates = 0;
    var totalDeletes = 0;
    var latestChangeAt = DateTime.fromMillisecondsSinceEpoch(0);
    var latestSeq = -1;

    for (final item in items) {
      // Deserialize DynamoEntityTypeSyncState from DynamoDB item
      final state = DynamoEntityTypeSyncState.fromJson(_decodeItem(item));

      entityTypes[state.entityType] = EntityTypeSummary(
        creates: state.created,
        updates: state.updated,
        deletes: state.deleted,
        total: state.totalOperations,
        latestChangeAt: state.changeAt.toIso8601String(),
        latestSeq: state.seq,
      );

      totalCreates += state.created;
      totalUpdates += state.updated;
      totalDeletes += state.deleted;

      if (state.changeAt.isAfter(latestChangeAt)) {
        latestChangeAt = state.changeAt;
        latestSeq = state.seq;
      }
    }

    final totals = EntityTypeSummary(
      creates: totalCreates,
      updates: totalUpdates,
      deletes: totalDeletes,
      total: totalCreates + totalUpdates + totalDeletes,
      latestChangeAt: latestChangeAt.toIso8601String(),
      latestSeq: latestSeq,
    );

    return EntityTypeStats(entityTypes: entityTypes, totals: totals);
  }

  @override
  Future<EntityTypeStats> getStateStats({
    required String domainType,
    required String domainId,
  }) async {
    await initialize();

    // Query all EntityTypeSyncState records for this domain
    final pk = _entityTypeSyncStatePrimaryKey(
      domainType: domainType,
      domainId: domainId,
      forChangeLog: false,
    );

    final response = await _dynamoRequest('Query', {
      'TableName': tableName,
      'KeyConditionExpression': 'pk = :pk',
      'ExpressionAttributeValues': {
        ':pk': {'S': pk},
      },
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to get state stats: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (body['Items'] as List<dynamic>?) ?? <dynamic>[];

    // Build per-entity-type statistics
    final entityTypes = <String, EntityTypeSummary>{};
    var totalCreates = 0;
    var totalUpdates = 0;
    var totalDeletes = 0;
    var latestChangeAt = DateTime.fromMillisecondsSinceEpoch(0);
    var latestSeq = -1;

    for (final item in items) {
      // Deserialize DynamoEntityTypeSyncState from DynamoDB item
      final state = DynamoEntityTypeSyncState.fromJson(_decodeItem(item));

      entityTypes[state.entityType] = EntityTypeSummary(
        creates: state.created,
        updates: state.updated,
        deletes: state.deleted,
        total: state.totalOperations,
        latestChangeAt: state.changeAt.toIso8601String(),
        latestSeq: state.seq,
      );

      totalCreates += state.created;
      totalUpdates += state.updated;
      totalDeletes += state.deleted;

      if (state.changeAt.isAfter(latestChangeAt)) {
        latestChangeAt = state.changeAt;
        latestSeq = state.seq;
      }
    }

    final totals = EntityTypeSummary(
      creates: totalCreates,
      updates: totalUpdates,
      deletes: totalDeletes,
      total: totalCreates + totalUpdates + totalDeletes,
      latestChangeAt: latestChangeAt.toIso8601String(),
      latestSeq: latestSeq,
    );

    return EntityTypeStats(entityTypes: entityTypes, totals: totals);
  }

  @override
  Future<List<String>> getAllDomainIds({required String domainType}) async {
    await initialize();

    // Use Scan with filter to find all ETSS records for this domain type
    // ETSS records are created for each entity type in each domain
    final domainIds = <String>{};
    final etssPkPrefix =
        '\$$_servicePrefix#etss#domainType_$domainType#domainId_';

    Map<String, dynamic>? exclusiveStartKey;

    do {
      final scanPayload = <String, dynamic>{
        'TableName': tableName,
        'FilterExpression': 'begins_with(pk, :pkPrefix)',
        'ExpressionAttributeValues': {
          ':pkPrefix': {'S': etssPkPrefix},
        },
        'ProjectionExpression': 'pk',
      };

      if (exclusiveStartKey != null) {
        scanPayload['ExclusiveStartKey'] = exclusiveStartKey;
      }

      final response = await _dynamoRequest('Scan', scanPayload);

      if (response.statusCode != 200) {
        throw Exception('Failed to list domains: ${response.body}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = body['Items'] as List<dynamic>? ?? <dynamic>[];

      for (final raw in items) {
        final pk = (raw as Map<String, dynamic>)['pk']?['S'] as String?;
        if (pk == null) continue;
        // Parse ElectroDB format: $sltt#etss#domainType_X#domainId_Y
        final domainIdMatch = RegExp(r'domainId_([^#]+)').firstMatch(pk);
        if (domainIdMatch != null) {
          domainIds.add(domainIdMatch.group(1)!);
        }
      }

      exclusiveStartKey = body['LastEvaluatedKey'] as Map<String, dynamic>?;
    } while (exclusiveStartKey != null);

    final sorted = domainIds.toList()..sort();
    return sorted;
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
  }) async {
    await initialize();

    final pk = _statePrimaryKey(
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
    );

    final payload = <String, dynamic>{
      'TableName': tableName,
      'KeyConditionExpression': 'pk = :pk',
      'ExpressionAttributeValues': {
        ':pk': {'S': pk},
      },
      'ScanIndexForward': true,
    };

    if (cursor != null) {
      payload['ExclusiveStartKey'] = {
        'pk': {'S': pk},
        'sk': {'S': cursor},
      };
    }

    if (limit != null) {
      payload['Limit'] = limit;
    }

    final response = await _dynamoRequest('Query', payload);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch entity states: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['Items'] as List<dynamic>? ?? <dynamic>[];

    final results = <Map<String, dynamic>>[];
    for (final item in items) {
      final json = _decodeItem(
        item as Map<String, dynamic>,
        excludeStorageKeys: true,
      );
      if (parentId != null && json['data_parentId'] != parentId) continue;
      if (parentProp != null && json['data_parentProp'] != parentProp) continue;

      results.add(json);
    }

    return {
      'items': results,
      'nextCursor': body['LastEvaluatedKey']?['sk']?['S'],
      'hasMore': body['LastEvaluatedKey'] != null,
    };
  }

  @override
  Future<void> upsertEntityTypeSyncStates({
    required String domainType,
    required String entityType,
    required BaseChangeLogEntry newChange,
    required OperationCounts operationCounts,
    bool forChangeLog = false,
  }) async {
    await initialize();

    // Cast to DynamoChangeLogEntry to access seq field
    final dynamoChange = newChange as DynamoChangeLogEntry;

    // Create keys using ElectroDB-compatible methods
    final pk = _entityTypeSyncStatePrimaryKey(
      domainType: domainType,
      domainId: dynamoChange.domainId,
      forChangeLog: forChangeLog,
    );
    final sk = _entityTypeSyncStateSortKey(
      entityType: entityType,
      forChangeLog: forChangeLog,
    );

    try {
      // First, try to get the existing entity type sync state
      final getResponse = await _dynamoRequest('GetItem', {
        'TableName': tableName,
        'Key': {
          'pk': {'S': pk},
          'sk': {'S': sk},
        },
      });

      final body = jsonDecode(getResponse.body);
      final existingItem = body['Item'];

      late final DateTime latestChangeAt;
      late final String latestCid;
      late final int latestSeq;
      late final int created;
      late final int updated;
      late final int deleted;
      // ignore: non_constant_identifier_names
      late final DateTime storedAt_orig_;

      if (existingItem != null) {
        // Decode existing state
        final existingState = DynamoEntityTypeSyncState.fromJson(
          _decodeItem(existingItem),
        );

        // Determine latest change metadata
        if (dynamoChange.changeAt.isAfter(existingState.changeAt) ||
            dynamoChange.changeAt.isAtSameMomentAs(existingState.changeAt)) {
          latestChangeAt = dynamoChange.changeAt;
          latestCid = dynamoChange.cid;
          latestSeq = dynamoChange.seq;
        } else {
          latestChangeAt = existingState.changeAt;
          latestCid = existingState.cid;
          latestSeq = existingState.seq;
        }

        // Increment counters
        created = existingState.created + operationCounts.create;
        updated = existingState.updated + operationCounts.update;
        deleted = existingState.deleted + operationCounts.delete;
        storedAt_orig_ = existingState.storedAt_orig_ ?? existingState.storedAt;
      } else {
        // New record - initialize with current change metadata
        latestChangeAt = dynamoChange.changeAt;
        latestCid = dynamoChange.cid;
        latestSeq = dynamoChange.seq;
        created = operationCounts.create;
        updated = operationCounts.update;
        deleted = operationCounts.delete;
        storedAt_orig_ = dynamoChange.storedAt ?? DateTime.now().toUtc();
      }

      // Create the updated entity type sync state
      final newState = DynamoEntityTypeSyncState(
        entityType: entityType,
        domainId: dynamoChange.domainId,
        domainType: domainType,
        storageId: await getStorageId(),
        storageType: getStorageType(),
        cid: latestCid,
        changeAt: latestChangeAt,
        seq: latestSeq,
        created: created,
        updated: updated,
        deleted: deleted,
        storedAt: dynamoChange.storedAt ?? DateTime.now().toUtc(),
        storedAt_orig_: storedAt_orig_,
      );

      // Put the updated state back to DynamoDB
      final item = <String, dynamic>{
        'pk': {'S': pk},
        'sk': {'S': sk},
        ..._encodeJson(newState.toJson()),
      };

      final putResponse = await _dynamoRequest('PutItem', {
        'TableName': tableName,
        'Item': item,
      });

      if (putResponse.statusCode != 200) {
        throw Exception(
          'Failed to upsert entity type sync state: ${putResponse.body}',
        );
      }
    } catch (e) {
      SlttLogger.logger.warning(
        '[DynamoDB] Warning: failed to upsert entity-type sync state: $e',
      );
    }
  }

  @override
  Future<void> testResetDomainStorage({
    required String domainType,
    required String domainId,
  }) async {
    await initialize();

    // Safety check: only allow deletion of test domains
    if (!domainId.startsWith('__test')) {
      throw Exception(
        'testResetDomainStorage can only delete test domains. '
        'Domain ID must start with "__test" but got: $domainId',
      );
    }

    // Collect all items to delete for this domain
    // Use a Set with composite keys to ensure uniqueness
    final itemKeys = <String>{};
    final itemsToDelete = <Map<String, dynamic>>[];

    // 1. Query GSI for change log entries (this is the most efficient way)
    final changeGsiPk = _changeGsiPartition(
      domainType: domainType,
      domainId: domainId,
    );

    await _queryGsiAndCollectItems(
      gsiPk: changeGsiPk,
      itemKeys: itemKeys,
      itemsToDelete: itemsToDelete,
    );

    // 2. Scan for any change log entries not caught by GSI (fallback)
    final changePkPrefix = _changePrimaryKeyPrefix(
      domainType: domainType,
      domainId: domainId,
    );

    await _scanAndCollectItems(
      filterExpression: 'begins_with(pk, :pkPrefix)',
      expressionValues: {
        ':pkPrefix': {'S': changePkPrefix},
      },
      itemKeys: itemKeys,
      itemsToDelete: itemsToDelete,
    );

    // 3. Scan for entity states
    final statePkPrefix = _statePrimaryKeyDomainPrefix(
      domainType: domainType,
      domainId: domainId,
    );

    await _scanAndCollectItems(
      filterExpression: 'begins_with(pk, :pkPrefix)',
      expressionValues: {
        ':pkPrefix': {'S': statePkPrefix},
      },
      itemKeys: itemKeys,
      itemsToDelete: itemsToDelete,
    );

    // 4. Scan for entity type sync states (change logs)
    final etscPk = _entityTypeSyncStatePrimaryKey(
      domainType: domainType,
      domainId: domainId,
      forChangeLog: true,
    );

    await _scanAndCollectItems(
      filterExpression: 'pk = :pk',
      expressionValues: {
        ':pk': {'S': etscPk},
      },
      itemKeys: itemKeys,
      itemsToDelete: itemsToDelete,
    );

    // 5. Scan for entity type sync states (entity states)
    final etssPk = _entityTypeSyncStatePrimaryKey(
      domainType: domainType,
      domainId: domainId,
      forChangeLog: false,
    );

    await _scanAndCollectItems(
      filterExpression: 'pk = :pk',
      expressionValues: {
        ':pk': {'S': etssPk},
      },
      itemKeys: itemKeys,
      itemsToDelete: itemsToDelete,
    );

    // 6. Add sequence counter to delete list
    final seqPk = _sequencePrimaryKey(
      domainType: domainType,
      domainId: domainId,
    );
    final seqSk = _sequenceCounterSortKey();

    final seqCompositeKey = '$seqPk#$seqSk';
    if (!itemKeys.contains(seqCompositeKey)) {
      itemKeys.add(seqCompositeKey);
      itemsToDelete.add({
        'pk': {'S': seqPk},
        'sk': {'S': seqSk},
      });
    }

    // 7. Batch delete all collected items
    await _batchDeleteItems(itemsToDelete);
  }

  /// Helper method to query GSI and collect items for deletion
  Future<void> _queryGsiAndCollectItems({
    required String gsiPk,
    required Set<String> itemKeys,
    required List<Map<String, dynamic>> itemsToDelete,
  }) async {
    Map<String, dynamic>? lastEvaluatedKey;

    do {
      final payload = <String, dynamic>{
        'TableName': tableName,
        'IndexName': 'GSI1',
        'KeyConditionExpression': 'gsi1pk = :pk',
        'ExpressionAttributeValues': {
          ':pk': {'S': gsiPk},
        },
        'ProjectionExpression': 'pk, sk',
      };

      if (lastEvaluatedKey != null) {
        payload['ExclusiveStartKey'] = lastEvaluatedKey;
      }

      final response = await _dynamoRequest('Query', payload);

      if (response.statusCode != 200) {
        throw Exception('Failed to query GSI: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['Items'] as List<dynamic>? ?? [];

      for (final item in items) {
        final itemMap = item as Map<String, dynamic>;
        final pk = itemMap['pk'];
        final sk = itemMap['sk'];

        if (pk != null && sk != null) {
          // Use composite key to ensure uniqueness
          final pkValue = pk['S'] as String?;
          final skValue = sk['S'] as String?;

          if (pkValue != null && skValue != null) {
            final compositeKey = '$pkValue#$skValue';
            if (!itemKeys.contains(compositeKey)) {
              itemKeys.add(compositeKey);
              itemsToDelete.add({'pk': pk, 'sk': sk});
            }
          }
        }
      }

      lastEvaluatedKey = data['LastEvaluatedKey'] as Map<String, dynamic>?;
    } while (lastEvaluatedKey != null);
  }

  /// Helper method to scan and collect items for deletion
  Future<void> _scanAndCollectItems({
    required String filterExpression,
    required Map<String, dynamic> expressionValues,
    required Set<String> itemKeys,
    required List<Map<String, dynamic>> itemsToDelete,
  }) async {
    Map<String, dynamic>? exclusiveStartKey;

    do {
      final scanPayload = <String, dynamic>{
        'TableName': tableName,
        'FilterExpression': filterExpression,
        'ExpressionAttributeValues': expressionValues,
        'ProjectionExpression': 'pk, sk',
      };

      if (exclusiveStartKey != null) {
        scanPayload['ExclusiveStartKey'] = exclusiveStartKey;
      }

      final response = await _dynamoRequest('Scan', scanPayload);

      if (response.statusCode != 200) {
        throw Exception('Failed to scan items: ${response.body}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = body['Items'] as List<dynamic>? ?? <dynamic>[];

      for (final item in items) {
        final itemMap = item as Map<String, dynamic>;
        final pk = itemMap['pk'];
        final sk = itemMap['sk'];

        if (pk != null && sk != null) {
          // Use composite key to ensure uniqueness
          final pkValue = pk['S'] as String?;
          final skValue = sk['S'] as String?;

          if (pkValue != null && skValue != null) {
            final compositeKey = '$pkValue#$skValue';
            if (!itemKeys.contains(compositeKey)) {
              itemKeys.add(compositeKey);
              itemsToDelete.add({'pk': pk, 'sk': sk});
            }
          }
        }
      }

      exclusiveStartKey = body['LastEvaluatedKey'] as Map<String, dynamic>?;
    } while (exclusiveStartKey != null);
  }

  /// Helper method to batch delete items (max 25 per request)
  Future<void> _batchDeleteItems(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;

    // DynamoDB BatchWriteItem supports max 25 items per request
    const batchSize = 25;

    for (var i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize).toList();

      final deleteRequests = batch.map((item) {
        return {
          'DeleteRequest': {'Key': item},
        };
      }).toList();

      final response = await _dynamoRequest('BatchWriteItem', {
        'RequestItems': {tableName: deleteRequests},
      });

      if (response.statusCode != 200) {
        throw Exception('Failed to batch delete items: ${response.body}');
      }

      // Handle unprocessed items (throttling, etc.)
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final unprocessed = body['UnprocessedItems'] as Map<String, dynamic>?;

      if (unprocessed != null && unprocessed.isNotEmpty) {
        // Retry unprocessed items after a brief delay
        await Future.delayed(const Duration(milliseconds: 100));

        final unprocessedForTable =
            unprocessed[tableName] as List<dynamic>? ?? <dynamic>[];
        final retryItems = unprocessedForTable.map((req) {
          final deleteReq = req as Map<String, dynamic>;
          return deleteReq['DeleteRequest']['Key'] as Map<String, dynamic>;
        }).toList();

        await _batchDeleteItems(retryItems);
      }
    }
  }

  Map<String, dynamic> _buildInitialStateJson({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
    required BaseChangeLogEntry change,
  }) {
    final changeAt = change.changeAt.toUtc().toIso8601String();
    final changeBy = change.changeBy;
    final cid = change.cid;

    return {
      'entityId': entityId,
      'entityType': entityType,
      'domainType': domainType,
      'unknownJson': JsonUtils.normalize('{}'),
      'change_domainId': domainId,
      'change_domainId_orig_': domainId,
      'change_changeAt': changeAt,
      'change_changeAt_orig_': changeAt,
      'change_cid': cid,
      'change_cid_orig_': cid,
      'change_changeBy': changeBy,
      'change_changeBy_orig_': changeBy,
      'change_storedAt':
          change.storedAt?.toUtc().toIso8601String() ??
          change.cloudAt?.toUtc().toIso8601String() ??
          changeAt,
      'data_parentId': '',
      'data_parentId_changeAt_': changeAt,
      'data_parentId_changeBy_': changeBy,
      'data_parentId_cid_': cid,
      'data_parentProp': '',
      'data_parentProp_changeAt_': changeAt,
      'data_parentProp_changeBy_': changeBy,
      'data_parentProp_cid_': cid,
    };
  }

  Future<void> _putChangeLogEntry(DynamoChangeLogEntry entry) async {
    final item = <String, dynamic>{
      'pk': {
        'S': _changePrimaryKey(
          domainType: entry.domainType,
          domainId: entry.domainId,
          entityType: entry.entityType,
          entityId: entry.entityId,
        ),
      },
      'sk': {'S': _changeSortKey(entry.cid)},
      'gsi1pk': {
        'S': _changeGsiPartition(
          domainType: entry.domainType,
          domainId: entry.domainId,
        ),
      },
      'gsi1sk': {'S': _changeGsiSortKey(entry.seq)},
      'seq': {'N': entry.seq.toString()},
      ..._encodeJson(entry.toJson()),
    };

    final response = await _dynamoRequest('PutItem', {
      'TableName': tableName,
      'Item': item,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to store change: ${response.body}');
    }
  }

  Future<void> _putEntityState<TEntityState extends BaseEntityState>(
    TEntityState state,
  ) async {
    final item = <String, dynamic>{
      'pk': {
        'S': _statePrimaryKey(
          domainType: state.domainType,
          domainId: state.change_domainId,
          entityType: state.entityType,
        ),
      },
      'sk': {'S': _stateSortKey(entityId: state.entityId)},
      ..._encodeJson(state.toJson()),
    };

    final response = await _dynamoRequest('PutItem', {
      'TableName': tableName,
      'Item': item,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to store entity state: ${response.body}');
    }
  }

  Future<int> _nextSequence({
    required String domainType,
    required String domainId,
  }) async {
    final response = await _dynamoRequest('UpdateItem', {
      'TableName': tableName,
      'Key': {
        'pk': {
          'S': _sequencePrimaryKey(domainType: domainType, domainId: domainId),
        },
        'sk': {'S': _sequenceCounterSortKey()},
      },
      'UpdateExpression': 'SET #v = if_not_exists(#v, :start) + :inc',
      'ExpressionAttributeNames': {'#v': 'value'},
      'ExpressionAttributeValues': {
        ':start': {'N': '0'},
        ':inc': {'N': '1'},
      },
      'ReturnValues': 'UPDATED_NEW',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to increment sequence: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final value = body['Attributes']?['value']?['N'] as String?;
    return int.tryParse(value ?? '0') ?? 0;
  }

  Future<http.Response> _dynamoRequest(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse(_endpoint);
    final body = jsonEncode(payload);

    if (useLocalDynamoDB) {
      final headers = Map<String, String>.from(_baseHeaders)
        ..['X-Amz-Target'] = 'DynamoDB_20120810.$operation';
      return _httpClient.post(uri, headers: headers, body: body);
    }

    final accessKey = Platform.environment['AWS_ACCESS_KEY_ID'];
    final secretKey = Platform.environment['AWS_SECRET_ACCESS_KEY'];
    final sessionToken = Platform.environment['AWS_SESSION_TOKEN'];

    if (accessKey == null || secretKey == null) {
      throw Exception('AWS credentials not available in environment');
    }

    final credentials = AWSCredentials(accessKey, secretKey, sessionToken);
    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(credentials),
    );

    final encodedBody = utf8.encode(body);

    final signedRequest = await signer.sign(
      AWSHttpRequest(
        method: AWSHttpMethod.post,
        uri: uri,
        headers: {
          'Content-Type': 'application/x-amz-json-1.0',
          'X-Amz-Target': 'DynamoDB_20120810.$operation',
          'host': uri.host,
        },
        body: encodedBody,
      ),
      credentialScope: AWSCredentialScope(
        region: region,
        service: AWSService.dynamoDb,
      ),
    );

    final request = http.Request('POST', signedRequest.uri);
    request.headers.addAll(signedRequest.headers);
    request.bodyBytes = encodedBody;

    final streamed = await _httpClient.send(request);
    return http.Response.fromStream(streamed);
  }

  Future<void> _createTableIfNotExists() async {
    final describe = await _dynamoRequest('DescribeTable', {
      'TableName': tableName,
    });

    if (describe.statusCode == 200) return;

    final response = await _dynamoRequest('CreateTable', {
      'TableName': tableName,
      'KeySchema': [
        {'AttributeName': 'pk', 'KeyType': 'HASH'},
        {'AttributeName': 'sk', 'KeyType': 'RANGE'},
      ],
      'AttributeDefinitions': [
        {'AttributeName': 'pk', 'AttributeType': 'S'},
        {'AttributeName': 'sk', 'AttributeType': 'S'},
        {'AttributeName': 'gsi1pk', 'AttributeType': 'S'},
        {'AttributeName': 'gsi1sk', 'AttributeType': 'S'},
      ],
      'BillingMode': 'PAY_PER_REQUEST',
      'GlobalSecondaryIndexes': [
        {
          'IndexName': 'GSI1',
          'KeySchema': [
            {'AttributeName': 'gsi1pk', 'KeyType': 'HASH'},
            {'AttributeName': 'gsi1sk', 'KeyType': 'RANGE'},
          ],
          'Projection': {'ProjectionType': 'ALL'},
        },
      ],
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to create DynamoDB table: ${response.body}');
    }
  }

  // ========================================================================
  // KEY GENERATION METHODS (ElectroDB Convention)
  // ========================================================================
  //
  // All keys follow ElectroDB conventions with:
  // - Service prefix: $_servicePrefix
  // - Descriptive field names (not abbreviations)
  // - Collection concept for sort keys
  //
  // Format: $<service>#<entity>#<fieldName_value>#...

  /// Generates primary key for change log entries.
  ///
  /// Format: `$sltt#change#domainType_X#domainId_Y#entityType_Z#entityId_W`
  String _changePrimaryKey({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
  }) =>
      '\$$_servicePrefix#change#domainType_$domainType#domainId_$domainId#entityType_$entityType#entityId_$entityId';

  /// Generates primary key prefix for querying change logs by domain.
  ///
  /// Format: `$sltt#change#domainType_X#domainId_Y`
  String _changePrimaryKeyPrefix({
    required String domainType,
    required String domainId,
  }) => '\$$_servicePrefix#change#domainType_$domainType#domainId_$domainId';

  /// Generates sort key for change log entries.
  ///
  /// Format: `$changes#change#cid_12345`
  String _changeSortKey(String cid) => '\$changes#change#cid_$cid';

  /// Generates GSI partition key for querying changes by domain in sequence order.
  ///
  /// Format: `$sltt#change#domainType_X#domainId_Y`
  String _changeGsiPartition({
    required String domainType,
    required String domainId,
  }) => '\$$_servicePrefix#change#domainType_$domainType#domainId_$domainId';

  /// Generates GSI sort key for change log entries (sequence-based).
  ///
  /// Format: `seq_00000012345` (padded to 19 digits)
  String _changeGsiSortKey(int seq) => 'seq_${seq.toString().padLeft(19, '0')}';

  /// Generates primary key domain prefix for entity states.
  ///
  /// Format: `$sltt#state#domainType_X#domainId_Y`
  String _statePrimaryKeyDomainPrefix({
    required String domainType,
    required String domainId,
  }) => '\$$_servicePrefix#state#domainType_$domainType#domainId_$domainId';

  /// Generates full primary key for entity states.
  ///
  /// Format: `$sltt#state#domainType_X#domainId_Y#entityType_Z`
  String _statePrimaryKey({
    required String domainType,
    required String domainId,
    required String entityType,
  }) =>
      '\$$_servicePrefix#state#domainType_$domainType#domainId_$domainId#entityType_$entityType';

  /// Generates sort key for entity states.
  ///
  /// Format: `$states#state#entityId_abc123`
  String _stateSortKey({required String entityId}) =>
      '\$states#state#entityId_$entityId';

  /// Generates primary key for entity type sync state (change log or entity state).
  ///
  /// Format: `$sltt#etsc#domainType_X#domainId_Y` (for change logs)
  /// Format: `$sltt#etss#domainType_X#domainId_Y` (for entity states)
  String _entityTypeSyncStatePrimaryKey({
    required String domainType,
    required String domainId,
    required bool forChangeLog,
  }) {
    final prefix = forChangeLog ? 'etsc' : 'etss';
    return '\$$_servicePrefix#$prefix#domainType_$domainType#domainId_$domainId';
  }

  /// Generates sort key for entity type sync state.
  ///
  /// Format: `$etsc#etsc#entityType_portion` (for change logs)
  /// Format: `$etss#etss#entityType_portion` (for entity states)
  String _entityTypeSyncStateSortKey({
    required String entityType,
    required bool forChangeLog,
  }) {
    final prefix = forChangeLog ? 'etsc' : 'etss';
    return '\$$prefix#$prefix#entityType_$entityType';
  }

  /// Generates primary key for sequence counter.
  ///
  /// Format: `$sltt#seq#domainType_X#domainId_Y`
  String _sequencePrimaryKey({
    required String domainType,
    required String domainId,
  }) => '\$$_servicePrefix#seq#domainType_$domainType#domainId_$domainId';

  /// Generates sort key for sequence counter.
  ///
  /// Format: `$seq#counter`
  String _sequenceCounterSortKey() => '\$seq#counter';

  Map<String, dynamic> _encodeJson(Map<String, dynamic> json) {
    final result = <String, dynamic>{};
    for (final entry in json.entries) {
      result[entry.key] = _encodeValue(entry.value);
    }
    return result;
  }

  Map<String, dynamic> _decodeItem(
    Map<String, dynamic> item, {
    bool excludeStorageKeys = false,
  }) {
    final result = <String, dynamic>{};
    for (final entry in item.entries) {
      // Skip DynamoDB partition/sort keys and GSI keys if requested
      if (excludeStorageKeys &&
          (entry.key == 'pk' ||
              entry.key == 'sk' ||
              entry.key == 'gsi1pk' ||
              entry.key == 'gsi1sk')) {
        continue;
      }
      result[entry.key] = _decodeValue(entry.value);
    }
    return result;
  }

  dynamic _encodeValue(dynamic value) {
    if (value == null) return {'NULL': true};
    if (value is String) return {'S': value};
    if (value is num) return {'N': value.toString()};
    if (value is bool) return {'BOOL': value};
    if (value is DateTime) return {'S': value.toUtc().toIso8601String()};
    if (value is Map<String, dynamic>) {
      return {'M': value.map((key, v) => MapEntry(key, _encodeValue(v)))};
    }
    if (value is List) {
      return {'L': value.map(_encodeValue).toList()};
    }
    return {'S': value.toString()};
  }

  dynamic _decodeValue(dynamic attr) {
    if (attr is Map<String, dynamic>) {
      if (attr.containsKey('S')) return attr['S'];
      if (attr.containsKey('N')) {
        final numeric = attr['N'] as String;
        return num.tryParse(numeric) ?? numeric;
      }
      if (attr.containsKey('BOOL')) return attr['BOOL'];
      if (attr.containsKey('NULL')) return null;
      if (attr.containsKey('M')) {
        final map = attr['M'] as Map<String, dynamic>;
        return map.map((key, value) => MapEntry(key, _decodeValue(value)));
      }
      if (attr.containsKey('L')) {
        final list = attr['L'] as List;
        return list.map(_decodeValue).toList();
      }
    }
    return attr;
  }
}
