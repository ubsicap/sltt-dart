import 'dart:convert';
import 'dart:math';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';

import '../models/dynamo_change_log_entry.dart';
import '../models/dynamo_entity_state_serialization_registry.dart';
import '../models/dynamo_entity_type_sync_state.dart';
import '../models/dynamo_storage_state.dart';
import '../websocket/domain_change_payload.dart'
    show
        WsNotifyRecord,
        kNotifyTypeDomainChange,
        buildWsNotifyRecordMessage,
        buildWsNotifyStatsMessage;
import 'key_codec.dart';

/// Cached storageId at module (isolate) level so it survives across Lambda warm
/// invocations, regardless of whether a new [DynamoDBStorageService] instance
/// is constructed per request.
String? _cachedStorageId;

/// Storage key access map:
///
/// Separator: `#`
/// KeyValueField Separator: `@`
///
/// sample_values:
///   domainType: project
///   domainId: abc123
///   entityType: portion
///   entityId: entity1
///   cid: 1234567890
///   seq: 42
///   parentId: parent1
///   parentProp: tasks
///   change_changeAt_orig_: 2023-01-01T00:00:00Z
///
/// change_log:
///   write:
///     operation: Put change item in updateChangeLogAndStates
///     key_fields: [pk, sk, gsi1pk, gsi1sk]
///     keys:
///       pk: $sltt#@DOMAINTYPE#project#@DOMAINID#abc123#@ENTITYTYPE#portion#@ENTITYID#entity1
///       sk: $changes#change#@CID#1234567890
///       gsi1pk: $sltt#@DOMAINTYPE#project#@DOMAINID#abc123
///       gsi1sk: seq#@VALUE#0000000000000000042
///   read_cursor:
///     operation: Query GSI1 in getChangesWithCursor
///     key_fields: [gsi1pk, gsi1sk]
///     keys:
///       gsi1pk: $sltt#change#domainType_project#domainId_abc123
///       gsi1sk_condition: '> seq_0000000000000000042'
///   read_single_cid:
///     operation: Query base table in getChange
///     key_fields: [pk_prefix, sk]
///     keys:
///       pk_prefix: $sltt#change#domainType_project#domainId_abc123
///       sk: $changes#change#cid_1234567890
///   reset_reads:
///     operation: Query GSI1 plus fallback scan in testResetDomainStorage
///     key_fields: [gsi1pk, pk_prefix]
///     keys:
///       gsi1pk: $sltt#change#domainType_project#domainId_abc123
///       pk_prefix: $sltt#change#domainType_project#domainId_abc123
///
/// entity_state:
///   write:
///     operation: Put state item in updateChangeLogAndStates and testStoreState
///     key_fields: [pk, sk, gsi2pk, gsi2sk]
///     usage_notes: Within a single batch, the latest pending state write must be deduped by the full state key `(domainId, entityType, entityId)`, not by `entityId` alone, because the same entityId can appear in multiple domains.
///     keys:
///       pk: $sltt#@DOMAINTYPE#project#@DOMAINID#abc123#@ENTITYTYPE#portion
///       sk: $states#state#@ENTITYID#entity1
///       gsi2pk: $sltt#@DOMAINTYPE#project#@DOMAINID#abc123#@ENTITYTYPE#portion#@PARENTID#parent1
///       gsi2sk: @PARENTPROP#tasks#@CHANGEAT_ORIG#2023-01-01T00:00:00Z
///   read_single:
///     operation: GetItem in getEntityState
///     key_fields: [pk, sk]
///     keys:
///       pk: $sltt#state#domainType_project#domainId_abc123#entityType_portion
///       sk: $states#state#entityId_entity1
///   read_batch:
///     operation: BatchGetItem in batchGetEntityState
///     key_fields: [pk, sk]
///     usage_notes: API results are keyed by the composite identity from `BaseStorageService.batchEntityStateKey(...)`, not by `entityId` alone, so same entityIds across domains do not collide.
///     keys:
///       pk: $sltt#state#domainType_project#domainId_abc123#entityType_portion
///       sk: $states#state#entityId_entity1
///   read_list:
///     operation: Query in getEntityStates (base table or GSI2)
///     key_fields: [pk_and_sk_cursor, gsi2pk_and_gsi2sk_prefix]
///     keys:
///       base_pk: $sltt#state#domainType_project#domainId_abc123#entityType_portion
///       base_sk_cursor: $states#state#entityId_entity1
///       gsi2pk: $sltt#state#domainType_project#domainId_abc123#entityType_portion#parentId_parent1
///       gsi2sk_prefix: parentProp_tasks
///   reset_reads:
///     operation: Scan in testResetDomainStorage
///     key_fields: [pk_prefix]
///     keys:
///       pk_prefix: $sltt#state#domainType_project#domainId_abc123
///   read_cross_domain:
///     operation: Query GSI3 in getCrossDomainEntityStates
///     key_fields: [gsi3pk, gsi3sk]
///     usage_notes: gsi3pk/gsi3sk written for singleton root entities
///       (e.g. project) where entityId == domainId, but also special cases like
///       membership where domainId is projectId and entityId is userId
///     keys:
///       gsi3pk: $sltt#crossDomain#@DOMAINTYPE#{project|user|membership}
///       gsi3sk_prefix (all of type): states#@ENTITYTYPE#{project|user|member}
///       gsi3sk_prefix (specific):  states#@ENTITYTYPE#{project|user|member}#@ENTITYID#{projectId|userId|userId}#@DOMAINID#{projectId|userId|projectId}#@CHANGEAT_ORIG#{timestamp}
///
/// entity_type_sync_state:
///   etsc_write_read:
///     operation: Upsert and stats/reset reads for change-log counters
///     key_fields: [pk, sk]
///     usage_notes: latestChangeAt/cid track latest-by-changeAt while seq tracks latest-by-seq
///     keys:
///       pk: $sltt#etsc#domainType_project#domainId_abc123
///       sk: $etsc#etsc#entityType_portion
///   etss_write_read:
///     operation: Upsert and stats/reset reads for entity-state counters
///     key_fields: [pk, sk]
///     usage_notes: latestChangeAt/cid track latest-by-changeAt while seq tracks latest-by-seq
///     keys:
///       pk: $sltt#etss#domainType_project#domainId_abc123
///       sk: $etss#etss#entityType_portion
///
/// sequence_counter:
///   write_read:
///     operation: _bumpSeq, _getLatestSeq, and reset delete key
///     key_fields: [pk, sk]
///     keys:
///       pk: $sltt#seq#domainType_project#domainId_abc123
///       sk: $seq#counter

/// domain_change_publish:
///   publish:
///     operation: _publishDomainChangeEvents
///     payload_notes: websocket/SNS domain-change notifications publish the full
///       serialized change entry in `change` (including `dataJson`, `seq`, and
///       `changeAt`) rather than a derived summary payload.

/// storage_state:
///   write_read:
///     operation: Ensure a singleton persisted storage state (ensureStorageId)
///     key_fields: [pk, sk]
///     notes: Singleton record used to persist the canonical storageId and metadata for this storage instance. Used by `ensureStorageId()` to provide a stable storage id across invocations.
///     keys:
///       pk: $sltt#storage#singleton
///       sk: $storage#state

/// DynamoDB implementation of [BaseStorageService].
///
/// All merge/conflict logic is delegated to [ChangeProcessingService]. This
/// class is responsible solely for persisting and retrieving change log entries
/// and entity state documents from a single DynamoDB table.
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
/// gsi2pk: '$sltt#state#domainType_project#domainId_abc123#entityType_portion#parentId_parent1'
/// gsi2sk: 'parentProp_tasks' or 'parentProp_tasks#changeAt_orig__2023-01-01T00:00:00Z'
/// ```
class DynamoDBStorageService extends BaseStorageService {
  DynamoDBStorageService({
    required this.tableName,
    this.region = 'us-east-1',
    this.useLocalDynamoDB = false,
    this.localEndpoint,
    required this.credentials,
    Future<AWSCredentials> Function([bool? useAssumeRole])? credentialsResolver,
    http.Client? httpClient,
    this.domainChangeTopicArn,
  }) : _credentialsResolver = credentialsResolver,
       _httpClient = httpClient ?? http.Client();

  final String tableName;
  final String region;
  final bool useLocalDynamoDB;
  final String? localEndpoint;
  final AWSCredentials credentials;
  final Future<AWSCredentials> Function([bool? useAssumeRole])?
  _credentialsResolver;
  final String? domainChangeTopicArn;

  final http.Client _httpClient;

  bool _initialized = false;
  late String _endpoint;
  late Map<String, String> _baseHeaders;

  /// Maximum number of change log entries that can be processed in a single batch. Leave room for state updates in the same batch (max 25 items total).
  @override
  int get batchPutChangesLimit => 12;

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

    // Mark initialized BEFORE the DynamoDB calls below so that
    // _dynamoRequest()'s re-entrancy guard (`if (!_initialized) await initialize()`)
    // doesn't trigger infinite recursion when ensureStorageId() calls _dynamoRequest().
    _initialized = true;

    try {
      if (useLocalDynamoDB) {
        await createTableIfNotExists();
      }

      await ensureStorageId();
    } catch (e) {
      // Roll back so a subsequent call can retry initialization.
      _initialized = false;
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    _initialized = false;
    _httpClient.close();
  }

  @override
  String getStorageType() => 'cloud';

  @override
  Future<List<String>> getSupportedEntityTypes() async {
    // Ensure serializers are registered and return the registered types
    ensureDynamoSerializersRegistered();
    final types = getRegisteredEntityStateTypes();
    return types.map((e) => e.value).toList(growable: false);
  }

  @override
  Future<String> getStorageId() async {
    if (_cachedStorageId != null) return _cachedStorageId!;
    return ensureStorageId();
  }

  @override
  Future<String> ensureStorageId() async {
    if (_cachedStorageId != null) return _cachedStorageId!;

    try {
      // 1) Try to read canonical storage state from DynamoDB.
      final getResponse = await _dynamoRequest('GetItem', {
        'TableName': tableName,
        'Key': {
          'pk': {'S': _storageStatePrimaryKey()},
          'sk': {'S': _storageStateSortKey()},
        },
        'ConsistentRead': true,
      });

      if (getResponse.statusCode != 200) {
        throw Exception('Failed to read storage state: ${getResponse.body}');
      }

      final getBody =
          jsonDecode(utf8.decode(getResponse.bodyBytes))
              as Map<String, dynamic>;
      final item = getBody['Item'] as Map<String, dynamic>?;

      if (item != null) {
        final existing = DynamoStorageState.fromJson(_decodeItem(item));
        if (existing.storageId.isNotEmpty) {
          _cachedStorageId = existing.storageId;
          return _cachedStorageId!;
        }
      }

      // 2) Not found: create and persist a canonical storage state item.
      final now = DateTime.now().toUtc();
      final newState = DynamoStorageState(
        storageId: BaseStorageService.generateShortStorageId(),
        storageType: getStorageType(),
        createdAt: now,
        updatedAt: now,
      );

      final putResponse = await _dynamoRequest('PutItem', {
        'TableName': tableName,
        'Item': {
          'pk': {'S': _storageStatePrimaryKey()},
          'sk': {'S': _storageStateSortKey()},
          ..._encodeJson(newState.toJson()),
        },
        'ConditionExpression':
            'attribute_not_exists(pk) AND attribute_not_exists(sk)',
      });

      if (putResponse.statusCode == 200) {
        _cachedStorageId = newState.storageId;
        return _cachedStorageId!;
      }

      final putBody =
          jsonDecode(utf8.decode(putResponse.bodyBytes))
              as Map<String, dynamic>;
      final putErrorType = putBody['__type'] as String?;
      if (putErrorType != null &&
          putErrorType.contains('ConditionalCheckFailedException')) {
        final retryResponse = await _dynamoRequest('GetItem', {
          'TableName': tableName,
          'Key': {
            'pk': {'S': _storageStatePrimaryKey()},
            'sk': {'S': _storageStateSortKey()},
          },
          'ConsistentRead': true,
        });

        if (retryResponse.statusCode != 200) {
          throw Exception(
            'Failed to read storage state after concurrent put: ${retryResponse.body}',
          );
        }

        final retryBody =
            jsonDecode(utf8.decode(retryResponse.bodyBytes))
                as Map<String, dynamic>;
        final retryItem = retryBody['Item'] as Map<String, dynamic>?;
        if (retryItem != null) {
          final existing = DynamoStorageState.fromJson(_decodeItem(retryItem));
          if (existing.storageId.isNotEmpty) {
            _cachedStorageId = existing.storageId;
            return _cachedStorageId!;
          }
        }
      }

      throw Exception('Failed to persist storage state: ${putResponse.body}');
    } catch (e) {
      // Fallback for degraded environments; cache for warm invocation reuse.
      SlttLogger.logger.warning(
        '[DynamoDB] Failed to ensure persisted storage state, falling back to in-memory id: $e',
      );
      _cachedStorageId = BaseStorageService.generateShortStorageId();
      return _cachedStorageId!;
    }
  }

  @override
  Future<UpdateChangeLogAndStatesResult> updateChangeLogAndStates({
    required String domainType,
    required List<ChangeLogAndStateRequest> requests,
  }) async {
    await initialize();

    // Phase 1: Process all requests and prepare items
    final outChanges = <BaseChangeLogEntry>[];
    final outStates = <BaseEntityState?>[];
    final changeItemsToPut = <Map<String, dynamic>>[];
    // the states need to be unique within a batch, keyed by the full state
    // identity so the same entityId can be written in multiple domains.
    final stateItemsToPutByKey = <String, Map<String, dynamic>>{};
    final syncStatesToUpsert =
        <
          ({
            String entityType,
            DynamoChangeLogEntry change,
            OperationCounts operationCounts,
            bool forChangeLog,
          })
        >[];

    for (var req in requests) {
      // Merge change log entry with updates
      final mergedChangeJson = <String, dynamic>{
        ...req.changeLogEntry.toJson(),
        ...req.changeUpdates,
      }..removeWhere((key, value) => value == null);

      final newChange = DynamoChangeLogEntry.fromJson(mergedChangeJson);

      if (!req.skipChangeLogWrite) {
        // Assign sequence number
        newChange.seq = await _bumpSeq(
          domainType: domainType,
          domainId: newChange.domainId,
        );

        // Prepare change log item for batch put
        changeItemsToPut.add(_buildChangeLogItem(newChange));

        // Queue sync state update for change log
        syncStatesToUpsert.add((
          entityType: newChange.entityType,
          change: newChange,
          operationCounts: req.operationCounts,
          forChangeLog: true,
        ));
      }

      outChanges.add(newChange);

      // Process entity state
      late final BaseEntityState newState;
      if (req.skipStateWrite &&
          req.entityState != null &&
          req.stateUpdates.isEmpty) {
        newState = req.entityState!;
      } else {
        final currentStateJson = req.entityState?.toJson() ?? {};
        final mergedStateJson = <String, dynamic>{
          ...currentStateJson,
          ...req.stateUpdates,
        }..removeWhere((key, value) => value == null);

        newState = deserializeEntityStateSafely(mergedStateJson);

        if (!req.skipStateWrite) {
          // Prepare entity state item for batch put
          stateItemsToPutByKey[_stateBatchKey(newState)] =
              _buildEntityStateItem(newState);

          // Queue sync state update for entity state
          syncStatesToUpsert.add((
            entityType: newChange.entityType,
            change: newChange,
            operationCounts: req.operationCounts,
            forChangeLog: false,
          ));
        }
      }

      outStates.add(newState);
    }

    // Phase 2: Batch write change log entries
    if (changeItemsToPut.isNotEmpty) {
      await _batchPutItems(changeItemsToPut);
    }

    // Phase 3: Batch write entity states
    if (stateItemsToPutByKey.isNotEmpty) {
      await _batchPutItems(stateItemsToPutByKey.values.toList());
    }

    // Phase 4: Batch upsert entity type sync states
    if (syncStatesToUpsert.isNotEmpty) {
      await _batchUpsertEntityTypeSyncStates(
        domainType: domainType,
        syncStates: syncStatesToUpsert,
      );
    }

    if (_shouldPublishDomainChangeEvents && outChanges.isNotEmpty) {
      final latestByEntityType = <String, DynamoChangeLogEntry>{};
      for (final change in outChanges) {
        if (change is! DynamoChangeLogEntry) continue;
        final current = latestByEntityType[change.entityType];
        if (current == null || change.seq > current.seq) {
          latestByEntityType[change.entityType] = change;
        }
      }
      final latestChanges = latestByEntityType.values.toList()
        ..sort((a, b) => a.seq.compareTo(b.seq));
      await _publishDomainChangeEvents(latestChanges);
    }

    return (newChangeLogEntries: outChanges, newEntityStates: outStates);
  }

  /// Builds a DynamoDB item for a change log entry.
  Map<String, dynamic> _buildChangeLogItem(DynamoChangeLogEntry entry) {
    return {
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
  }

  /// Builds a DynamoDB item for an entity state.
  Map<String, dynamic> _buildEntityStateItem<
    TEntityState extends BaseEntityState
  >(TEntityState state) {
    final stateJson = state.toJson();
    final parentId = stateJson['data_parentId'] as String? ?? '';
    final parentProp = stateJson['data_parentProp'] as String? ?? '';
    final changeAtOrig = stateJson['change_changeAt_orig_']?.toString() ?? '';
    final item = <String, dynamic>{
      'pk': {
        'S': _statePrimaryKey(
          domainType: state.domainType,
          domainId: state.change_domainId,
          entityType: state.entityType,
        ),
      },
      'sk': {'S': _stateSortKey(entityId: state.entityId)},
      'gsi2pk': {
        'S': _stateGsi2Partition(
          domainType: state.domainType,
          domainId: state.change_domainId,
          entityType: state.entityType,
          parentId: parentId,
        ),
      },
      'gsi2sk': {
        'S': _stateGsi2SortKey(
          parentProp: parentProp,
          changeAtOrig: changeAtOrig,
        ),
      },
      ..._encodeJson(stateJson),
    };

    // Conditionally add GSI3 keys only for root/top-level entities. GSI3
    // indexes root entities by domainType and entityType+entityId+domainId+changeAt_orig_.
    // by default we want to index singleton root entities (e.g. project) identified by their  matching entityId and domainId. However, we also should index domainTypes like membership have a list where domainId is projectId and entityId is userId
    if ((state.entityId == state.change_domainId) ||
        getDomainRootEntityType(state.domainType) == state.entityType) {
      item['gsi3pk'] = {
        'S': buildStateGsi3Partition(domainType: state.domainType),
      };
      item['gsi3sk'] = {
        'S': buildStateGsi3SortKey(
          entityType: state.entityType,
          entityId: state.entityId,
          domainId: state.change_domainId,
          changeAtOrig: changeAtOrig,
        ),
      };
    }

    return item;
  }

  String _stateBatchKey(BaseEntityState state) {
    return '${state.domainType}|${state.change_domainId}|${state.entityType}|${state.entityId}';
  }

  /// Batch puts items to DynamoDB (max 25 per request).
  Future<void> _batchPutItems(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;

    // DynamoDB BatchWriteItem supports max 25 items per request
    const batchSize = 25;

    for (var i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize).toList();

      final putRequests = batch.map((item) {
        return {
          'PutRequest': {'Item': item},
        };
      }).toList();

      final response = await _dynamoRequest('BatchWriteItem', {
        'RequestItems': {tableName: putRequests},
      });

      if (response.statusCode != 200) {
        throw Exception('Failed to batch put items: ${response.body}');
      }

      // Handle unprocessed items (throttling, etc.)
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final unprocessed = body['UnprocessedItems'] as Map<String, dynamic>?;

      if (unprocessed != null && unprocessed.isNotEmpty) {
        // Retry unprocessed items after a brief delay
        await Future.delayed(const Duration(milliseconds: 100));

        final unprocessedForTable =
            unprocessed[tableName] as List<dynamic>? ?? <dynamic>[];
        final retryItems = unprocessedForTable.map((req) {
          final putReq = req as Map<String, dynamic>;
          return putReq['PutRequest']['Item'] as Map<String, dynamic>;
        }).toList();

        await _batchPutItems(retryItems);
      }
    }
  }

  /// Batch puts formatted change log entries to DynamoDB (max 25 per request).
  /// Accessible public method for batch writing changes.
  Future<void> batchPutChangeLogEntries(
    List<DynamoChangeLogEntry> entries,
  ) async {
    if (entries.isEmpty) return;
    final items = entries.map(_buildChangeLogItem).toList();
    await _batchPutItems(items);
  }

  /// Batch puts formatted entity states to DynamoDB (max 25 per request).
  /// Accessible public method for batch writing states.
  Future<void> batchPutEntityStates(List<BaseEntityState> states) async {
    if (states.isEmpty) return;
    final items = states.map((state) => _buildEntityStateItem(state)).toList();
    await _batchPutItems(items);
  }

  /// Batch upserts entity type sync states.
  ///
  /// Note: DynamoDB doesn't support batch conditional updates, so we still need
  /// to fetch existing states first, then batch write the updates.
  Future<void> _batchUpsertEntityTypeSyncStates({
    required String domainType,
    required List<
      ({
        String entityType,
        DynamoChangeLogEntry change,
        OperationCounts operationCounts,
        bool forChangeLog,
      })
    >
    syncStates,
  }) async {
    if (syncStates.isEmpty) return;

    // Group by (entityType, forChangeLog) to aggregate operation counts
    final grouped =
        <
          String,
          ({
            String entityType,
            DynamoChangeLogEntry latestChangeAtChange,
            DynamoChangeLogEntry latestSeqChange,
            int creates,
            int updates,
            int deletes,
            bool forChangeLog,
          })
        >{};

    for (final syncState in syncStates) {
      final key = '${syncState.entityType}#${syncState.forChangeLog}';
      final existing = grouped[key];

      if (existing == null) {
        grouped[key] = (
          entityType: syncState.entityType,
          latestChangeAtChange: syncState.change,
          latestSeqChange: syncState.change,
          creates: syncState.operationCounts.create,
          updates: syncState.operationCounts.update,
          deletes: syncState.operationCounts.delete,
          forChangeLog: syncState.forChangeLog,
        );
      } else {
        // Track latest-by-time and latest-by-seq independently.
        final latestChangeAtChange =
            syncState.change.changeAt.isAfter(
              existing.latestChangeAtChange.changeAt,
            )
            ? syncState.change
            : existing.latestChangeAtChange;
        final latestSeqChange =
            syncState.change.seq >= existing.latestSeqChange.seq
            ? syncState.change
            : existing.latestSeqChange;

        grouped[key] = (
          entityType: existing.entityType,
          latestChangeAtChange: latestChangeAtChange,
          latestSeqChange: latestSeqChange,
          creates: existing.creates + syncState.operationCounts.create,
          updates: existing.updates + syncState.operationCounts.update,
          deletes: existing.deletes + syncState.operationCounts.delete,
          forChangeLog: existing.forChangeLog,
        );
      }
    }

    // Batch get existing sync states
    final keysToGet = <Map<String, dynamic>>[];
    for (final entry in grouped.values) {
      final pk = _entityTypeSyncStatePrimaryKey(
        domainType: domainType,
        domainId: entry.latestChangeAtChange.domainId,
        forChangeLog: entry.forChangeLog,
      );
      final sk = _entityTypeSyncStateSortKey(
        entityType: entry.entityType,
        forChangeLog: entry.forChangeLog,
      );
      keysToGet.add({
        'pk': {'S': pk},
        'sk': {'S': sk},
      });
    }

    final existingStates = await _batchGetItems(keysToGet);
    final existingByKey = <String, DynamoEntityTypeSyncState>{};
    for (final item in existingStates) {
      final state = DynamoEntityTypeSyncState.fromJson(_decodeItem(item));
      final key =
          '${state.entityType}#${item['pk']['S'].toString().contains('etsc')}';
      existingByKey[key] = state;
    }

    // Prepare batch puts
    final itemsToPut = <Map<String, dynamic>>[];
    final storageId = await getStorageId();

    for (final entry in grouped.entries) {
      final key = entry.key;
      final data = entry.value;
      final existing = existingByKey[key];

      late final DateTime latestChangeAt;
      late final String latestCid;
      late final int latestSeq;
      late final int created;
      late final int updated;
      late final int deleted;
      // ignore: non_constant_identifier_names
      late final DateTime storedAt_orig_;

      if (existing != null) {
        // Determine latest change metadata
        if (data.latestChangeAtChange.changeAt.isAfter(existing.changeAt) ||
            data.latestChangeAtChange.changeAt.isAtSameMomentAs(
              existing.changeAt,
            )) {
          latestChangeAt = data.latestChangeAtChange.changeAt;
          latestCid = data.latestChangeAtChange.cid;
        } else {
          latestChangeAt = existing.changeAt;
          latestCid = existing.cid;
        }
        latestSeq = data.latestSeqChange.seq > existing.seq
            ? data.latestSeqChange.seq
            : existing.seq;

        created = existing.created + data.creates;
        updated = existing.updated + data.updates;
        deleted = existing.deleted + data.deletes;
        storedAt_orig_ = existing.storedAt_orig_ ?? existing.storedAt;
      } else {
        latestChangeAt = data.latestChangeAtChange.changeAt;
        latestCid = data.latestChangeAtChange.cid;
        latestSeq = data.latestSeqChange.seq;
        created = data.creates;
        updated = data.updates;
        deleted = data.deletes;
        storedAt_orig_ =
            data.latestChangeAtChange.storedAt ?? DateTime.now().toUtc();
      }

      final newState = DynamoEntityTypeSyncState(
        entityType: data.entityType,
        domainId: data.latestChangeAtChange.domainId,
        domainType: domainType,
        storageId: storageId,
        storageType: getStorageType(),
        cid: latestCid,
        changeAt: latestChangeAt,
        seq: latestSeq,
        created: created,
        updated: updated,
        deleted: deleted,
        storedAt: data.latestChangeAtChange.storedAt ?? DateTime.now().toUtc(),
        storedAt_orig_: storedAt_orig_,
      );

      final pk = _entityTypeSyncStatePrimaryKey(
        domainType: domainType,
        domainId: data.latestChangeAtChange.domainId,
        forChangeLog: data.forChangeLog,
      );
      final sk = _entityTypeSyncStateSortKey(
        entityType: data.entityType,
        forChangeLog: data.forChangeLog,
      );

      itemsToPut.add({
        'pk': {'S': pk},
        'sk': {'S': sk},
        ..._encodeJson(newState.toJson()),
      });
    }

    // Batch put all sync states
    if (itemsToPut.isNotEmpty) {
      await _batchPutItems(itemsToPut);
    }
  }

  /// Batch gets items from DynamoDB (max 100 per request).
  Future<List<Map<String, dynamic>>> _batchGetItems(
    List<Map<String, dynamic>> keys,
  ) async {
    if (keys.isEmpty) return [];

    final results = <Map<String, dynamic>>[];

    // DynamoDB BatchGetItem supports max 100 items per request
    const batchSize = 100;

    for (var i = 0; i < keys.length; i += batchSize) {
      final batch = keys.skip(i).take(batchSize).toList();

      final response = await _dynamoRequest('BatchGetItem', {
        'RequestItems': {
          tableName: {'Keys': batch},
        },
      });

      if (response.statusCode != 200) {
        throw Exception('Failed to batch get items: ${response.body}');
      }

      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final responses = body['Responses'] as Map<String, dynamic>?;
      if (responses != null && responses.containsKey(tableName)) {
        final items = responses[tableName] as List<dynamic>? ?? [];
        results.addAll(items.cast<Map<String, dynamic>>());
      }

      // Handle unprocessed keys (throttling, etc.)
      final unprocessed = body['UnprocessedKeys'] as Map<String, dynamic>?;
      if (unprocessed != null && unprocessed.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 100));

        final unprocessedForTable =
            unprocessed[tableName] as Map<String, dynamic>?;
        if (unprocessedForTable != null) {
          final retryKeys = unprocessedForTable['Keys'] as List<dynamic>? ?? [];
          final retryResults = await _batchGetItems(
            retryKeys.cast<Map<String, dynamic>>(),
          );
          results.addAll(retryResults);
        }
      }
    }

    return results;
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

    final payload =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final item = payload['Item'] as Map<String, dynamic>?;
    if (item == null) return null;

    final decodedItem = _decodeItem(item, excludeStorageKeys: true);

    return deserializeEntityStateSafely(decodedItem);
  }

  @override
  Future<Map<String, BaseEntityState?>> batchGetEntityState({
    required List<
      ({String domainType, String domainId, String entityType, String entityId})
    >
    keys,
  }) async {
    await initialize();
    if (keys.isEmpty) return <String, BaseEntityState?>{};

    // Build DynamoDB keys (pk/sk) for each requested state
    final dynamoKeys = <Map<String, dynamic>>[];
    for (final k in keys) {
      dynamoKeys.add({
        'pk': {
          'S': _statePrimaryKey(
            domainType: k.domainType,
            domainId: k.domainId,
            entityType: k.entityType,
          ),
        },
        'sk': {'S': _stateSortKey(entityId: k.entityId)},
      });
    }

    // Batch get (Dynamo limits 100 per request handled internally)
    final items = await _batchGetItems(dynamoKeys);
    final out = <String, BaseEntityState?>{};

    // Decode found items and map by composite state identity
    for (final item in items) {
      final decoded = _decodeItem(item, excludeStorageKeys: true);
      final state = deserializeEntityStateSafely(decoded);
      out[BaseStorageService.batchEntityStateKey(
            domainType: state.domainType,
            domainId: state.change_domainId,
            entityType: state.entityType,
            entityId: state.entityId,
          )] =
          state;
    }

    // Ensure all requested identities are present; fill missing with null
    for (final k in keys) {
      out.putIfAbsent(
        BaseStorageService.batchEntityStateKey(
          domainType: k.domainType,
          domainId: k.domainId,
          entityType: k.entityType,
          entityId: k.entityId,
        ),
        () => null,
      );
    }

    return out;
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

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
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

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
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

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final items = (body['Items'] as List<dynamic>?) ?? <dynamic>[];

    // Build per-entity-type statistics
    final entityTypes = <String, EntityTypeSummary>{};
    var totalCreates = 0;
    var totalUpdates = 0;
    var totalDeletes = 0;
    var latestChangeAt = DateTime.fromMillisecondsSinceEpoch(0).toUtc();

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
      }
    }

    // Query actual changes to get the true latest seq and total count
    // This includes all changes, not just those categorized as create/update/delete
    // Use the sequence counter to get the latest seq
    final latestSeq = await _getLatestSeq(
      domainType: domainType,
      domainId: domainId,
    );

    // Total changes is the latest seq (assuming seq starts at 1 and increments by 1)
    final totalChanges = latestSeq > 0 ? latestSeq : 0;

    final totals = EntityTypeSummary(
      creates: totalCreates,
      updates: totalUpdates,
      deletes: totalDeletes,
      total: totalChanges > 0
          ? totalChanges
          : totalCreates + totalUpdates + totalDeletes,
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

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final items = (body['Items'] as List<dynamic>?) ?? <dynamic>[];

    // Build per-entity-type statistics
    final entityTypes = <String, EntityTypeSummary>{};
    var totalCreates = 0;
    var totalUpdates = 0;
    var totalDeletes = 0;
    var latestChangeAt = DateTime.fromMillisecondsSinceEpoch(0).toUtc();
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
        '${buildKey([KeyLabel(r'$sltt'), KeyLabel('etss'), KeyField('DOMAINTYPE', domainType)])}#@DOMAINID#';

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

      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final items = body['Items'] as List<dynamic>? ?? <dynamic>[];

      for (final raw in items) {
        final pk = (raw as Map<String, dynamic>)['pk']?['S'] as String?;
        if (pk == null) continue;
        final fields = parseKeyFields(pk);
        final domainId = fields['DOMAINID'];
        if (domainId != null) {
          domainIds.add(domainId);
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
    DateTime? storedAfter,
  }) async {
    await initialize();

    // Determine whether to use GSI2 or main table query
    final useGsi2 = parentId != null && parentId.isNotEmpty;

    final payload = <String, dynamic>{
      'TableName': tableName,
      'ScanIndexForward': true,
    };

    if (useGsi2) {
      // Query via GSI2 for efficient parent-based filtering
      payload['IndexName'] = 'GSI2';

      final gsi2pk = _stateGsi2Partition(
        domainType: domainType,
        domainId: domainId,
        entityType: entityType,
        parentId: parentId,
      );

      if (parentProp != null && parentProp.isNotEmpty) {
        // Filter by parentProp using begins_with on GSI2 sort key
        final skPrefix = buildStateGsi2SortKey(parentProp: parentProp);
        payload['KeyConditionExpression'] =
            'gsi2pk = :pk AND begins_with(gsi2sk, :skPrefix)';
        payload['ExpressionAttributeValues'] = {
          ':pk': {'S': gsi2pk},
          ':skPrefix': {'S': skPrefix},
        };
      } else {
        // Query all items for this parent
        payload['KeyConditionExpression'] = 'gsi2pk = :pk';
        payload['ExpressionAttributeValues'] = {
          ':pk': {'S': gsi2pk},
        };
      }

      if (cursor != null) {
        // Cursor for GSI2 needs pk, sk, gsi2pk, gsi2sk
        // We'll use the cursor as gsi2sk value and reconstruct the full key
        payload['ExclusiveStartKey'] = {
          'pk': {
            'S': _statePrimaryKey(
              domainType: domainType,
              domainId: domainId,
              entityType: entityType,
            ),
          },
          'sk': {'S': cursor}, // cursor should encode the sk value
          'gsi2pk': {'S': gsi2pk},
          'gsi2sk': {'S': cursor}, // For simplicity, use cursor as gsi2sk
        };
      }
    } else {
      // Query via main table (no parent filter or empty parentId)
      final pk = _statePrimaryKey(
        domainType: domainType,
        domainId: domainId,
        entityType: entityType,
      );

      payload['KeyConditionExpression'] = 'pk = :pk';
      payload['ExpressionAttributeValues'] = {
        ':pk': {'S': pk},
      };

      if (cursor != null) {
        payload['ExclusiveStartKey'] = {
          'pk': {'S': pk},
          'sk': {'S': cursor},
        };
      }
    }

    if (limit != null) {
      payload['Limit'] = limit;
    }

    final response = await _dynamoRequest('Query', payload);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch entity states: ${response.body}');
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final items = body['Items'] as List<dynamic>? ?? <dynamic>[];

    final results = <Map<String, dynamic>>[];
    for (final item in items) {
      final json = _decodeItem(
        item as Map<String, dynamic>,
        excludeStorageKeys: true,
      );

      // Apply post-query filters if not using GSI2 or if needed
      if (!useGsi2) {
        if (parentId != null && json['data_parentId'] != parentId) continue;
        if (parentProp != null && json['data_parentProp'] != parentProp) {
          continue;
        }
      }

      if (storedAfter != null) {
        final storedAtStr = json['change_storedAt'] as String?;
        if (storedAtStr != null) {
          final storedAt = DateTime.tryParse(storedAtStr);
          if (storedAt == null || !storedAt.isAfter(storedAfter.toUtc())) {
            continue;
          }
        }
      }

      results.add(json);
    }

    // Return the appropriate cursor based on which index was used
    String? nextCursor;
    if (body['LastEvaluatedKey'] != null) {
      final lastKey = body['LastEvaluatedKey'] as Map<String, dynamic>;
      if (useGsi2) {
        nextCursor = lastKey['gsi2sk']?['S'] as String?;
      } else {
        nextCursor = lastKey['sk']?['S'] as String?;
      }
    }

    return {
      'items': results,
      'nextCursor': nextCursor,
      'hasMore': body['LastEvaluatedKey'] != null,
    };
  }

  /// Query GSI3 for root/top-level entity states for a domainType.
  /// If `entityIdPrefix` is provided, restricts results to items whose
  /// `gsi3sk` begins with `states#entityId_{entityIdPrefix}#` (useful to scope to a
  /// single user's entityId prefix).
  Future<EntityStateQueryResult> getCrossDomainEntityStates({
    required String domainType,
    String? entityIdPrefix,
    int? limit,
    String? cursor,
    Set<String>? projectionExpressionFields,
    String sortDirection = 'asc',
    bool excludeDeleted = false,
    bool includeTestDomains = false,
  }) async {
    await initialize();

    final gsi3pk = buildStateGsi3Partition(domainType: domainType);
    final rootEntityType = getDomainRootEntityType(domainType);
    if (rootEntityType == null) {
      throw ArgumentError.value(
        domainType,
        'domainType',
        'No root entity type defined for this domain type.',
      );
    }

    final payload = <String, dynamic>{
      'TableName': tableName,
      'IndexName': 'GSI3',
      'ScanIndexForward': sortDirection == 'asc',
    };

    if (limit != null) {
      payload['Limit'] = limit;
    }

    // FIX 2 & 3: base64-decode → JSON-parse the cursor into the full key map.
    // DynamoDB requires ALL key attributes (table pk+sk AND GSI gsi3pk+gsi3sk).
    if (cursor != null) {
      final decoded = utf8.decode(base64Url.decode(cursor));
      final keyMap = jsonDecode(decoded) as Map<String, dynamic>;
      payload['ExclusiveStartKey'] = keyMap;
    }

    // NOTE: if projectExpressionFields is null, then all fields are included
    if (projectionExpressionFields != null &&
        (!includeTestDomains || excludeDeleted)) {
      // If we need to filter out test domains or deleted items, we must project those fields.
      projectionExpressionFields = {
        ...projectionExpressionFields,
        if (!includeTestDomains) 'change_domainId',
        if (excludeDeleted) 'data_deleted',
      };
    }

    // Use ExpressionAttributeNames to safely alias every projected field,
    // guarding against reserved-word collisions (e.g. "name", "status", "data").
    if (projectionExpressionFields != null &&
        projectionExpressionFields.isNotEmpty) {
      final nameAliases = <String, String>{};
      final projectionParts = <String>[];

      for (final field in projectionExpressionFields) {
        final alias = '#proj_$field';
        nameAliases[alias] = field;
        projectionParts.add(alias);
      }

      payload['ProjectionExpression'] = projectionParts.join(', ');
      // Merge into ExpressionAttributeNames (may already exist from key conditions)
      payload['ExpressionAttributeNames'] = {
        ...?payload['ExpressionAttributeNames'] as Map<String, String>?,
        ...nameAliases,
      };
    }

    String keyCondition = 'gsi3pk = :pk';
    final expressionValues = <String, dynamic>{
      ':pk': {'S': gsi3pk},
    };

    if (entityIdPrefix != null && entityIdPrefix.isNotEmpty) {
      keyCondition += ' AND begins_with(gsi3sk, :skPrefix)';
      expressionValues[':skPrefix'] = {
        'S': buildStateGsi3SortKeyEntityIdPrefix(
          entityType: rootEntityType,
          entityIdPrefix: entityIdPrefix,
        ),
      };
    }

    payload['KeyConditionExpression'] = keyCondition;
    payload['ExpressionAttributeValues'] = expressionValues;

    final response = await _dynamoRequest('Query', payload);
    if (response.statusCode != 200) {
      throw Exception('Failed to query root entity states: ${response.body}');
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final items = body['Items'] as List<dynamic>? ?? <dynamic>[];

    final results = <Map<String, dynamic>>[];
    for (final item in items) {
      final decodedItem = _decodeItem(
        item as Map<String, dynamic>,
        excludeStorageKeys: true,
      );
      if (excludeDeleted && decodedItem['data_deleted'] == true) {
        continue;
      }
      if (!includeTestDomains &&
          decodedItem['change_domainId'].toString().startsWith('__test')) {
        continue;
      }
      results.add(decodedItem);
    }

    // encode LastEvaluatedKey → nextCursor so callers can paginate.
    String? nextCursor;
    if (body.containsKey('LastEvaluatedKey')) {
      final lek = body['LastEvaluatedKey'];
      nextCursor = base64Url.encode(utf8.encode(jsonEncode(lek)));
    }

    return EntityStateQueryResult(items: results, nextCursor: nextCursor);
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
    bool isAdminReset = false,
  }) async {
    await initialize();

    // Safety check: only allow deletion of test domains
    if (!isAdminReset && !domainId.startsWith('__test')) {
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

    // 4. Collect entity type sync states (change logs) by querying the PK
    // Use Query instead of Scan to avoid a full table scan and reduce RCU usage
    final etscPk = _entityTypeSyncStatePrimaryKey(
      domainType: domainType,
      domainId: domainId,
      forChangeLog: true,
    );

    await _queryAndCollectItems(
      keyConditionExpression: 'pk = :pk',
      expressionValues: {
        ':pk': {'S': etscPk},
      },
      itemKeys: itemKeys,
      itemsToDelete: itemsToDelete,
    );

    // 5. Collect entity type sync states (entity states) by querying the PK
    final etssPk = _entityTypeSyncStatePrimaryKey(
      domainType: domainType,
      domainId: domainId,
      forChangeLog: false,
    );

    await _queryAndCollectItems(
      keyConditionExpression: 'pk = :pk',
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

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
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

    // Retry configuration for Scan (handle transient throttling)
    const int maxAttempts = 6;
    const int baseDelayMs = 100;
    final rand = Random();

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

      int attempt = 0;
      int delayMs = baseDelayMs;

      while (true) {
        final response = await _dynamoRequest('Scan', scanPayload);

        if (response.statusCode == 200) {
          final body =
              jsonDecode(utf8.decode(response.bodyBytes))
                  as Map<String, dynamic>;
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
          break; // page handled
        }

        // Non-200 response - check for throttling and retry with backoff
        final bodyStr = utf8.decode(response.bodyBytes);
        bool isThrottling = false;
        try {
          final parsed = jsonDecode(bodyStr) as Map<String, dynamic>;
          final type = parsed['__type']?.toString() ?? '';
          if (type.contains('Throttling') ||
              type.contains('ProvisionedThroughputExceededException') ||
              type.contains('TableReadKeyRangeThroughputExceeded')) {
            isThrottling = true;
          }
        } catch (_) {
          // ignore parse errors
        }

        attempt++;
        if (isThrottling && attempt <= maxAttempts) {
          final jitter = rand.nextInt(100);
          await Future.delayed(Duration(milliseconds: delayMs + jitter));
          delayMs = (delayMs * 2).clamp(baseDelayMs, 30 * 1000);
          continue; // retry this page
        }

        throw Exception('Failed to scan items: ${response.body}');
      }
    } while (exclusiveStartKey != null);
  }

  /// Helper to query by PK/KeyConditionExpression and collect pk/sk for deletion
  Future<void> _queryAndCollectItems({
    required String keyConditionExpression,
    required Map<String, dynamic> expressionValues,
    required Set<String> itemKeys,
    required List<Map<String, dynamic>> itemsToDelete,
    String? indexName,
  }) async {
    Map<String, dynamic>? lastEvaluatedKey;

    // Retry configuration for Query (handle transient throttling)
    const int maxAttempts = 6;
    const int baseDelayMs = 100;
    final rand = Random();

    do {
      final payload = <String, dynamic>{
        'TableName': tableName,
        'KeyConditionExpression': keyConditionExpression,
        'ExpressionAttributeValues': expressionValues,
        'ProjectionExpression': 'pk, sk',
      };

      if (indexName != null) payload['IndexName'] = indexName;
      if (lastEvaluatedKey != null) {
        payload['ExclusiveStartKey'] = lastEvaluatedKey;
      }

      int attempt = 0;
      int delayMs = baseDelayMs;

      while (true) {
        final response = await _dynamoRequest('Query', payload);

        if (response.statusCode == 200) {
          final body =
              jsonDecode(utf8.decode(response.bodyBytes))
                  as Map<String, dynamic>;
          final items = body['Items'] as List<dynamic>? ?? <dynamic>[];

          for (final item in items) {
            final itemMap = item as Map<String, dynamic>;
            final pk = itemMap['pk'];
            final sk = itemMap['sk'];

            if (pk != null && sk != null) {
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

          lastEvaluatedKey = body['LastEvaluatedKey'] as Map<String, dynamic>?;
          break; // page handled
        }

        // Non-200 response - detect throttling and retry with backoff
        final bodyStr = utf8.decode(response.bodyBytes);
        bool isThrottling = false;
        try {
          final parsed = jsonDecode(bodyStr) as Map<String, dynamic>;
          final type = parsed['__type']?.toString() ?? '';
          if (type.contains('Throttling') ||
              type.contains('ProvisionedThroughputExceededException') ||
              type.contains('TableReadKeyRangeThroughputExceeded')) {
            isThrottling = true;
          }
        } catch (_) {
          // ignore parse errors
        }

        attempt++;
        if (isThrottling && attempt <= maxAttempts) {
          final jitter = rand.nextInt(100);
          await Future.delayed(Duration(milliseconds: delayMs + jitter));
          delayMs = (delayMs * 2).clamp(baseDelayMs, 30 * 1000);
          continue; // retry this page
        }

        throw Exception('Failed to query items: ${response.body}');
      }
    } while (lastEvaluatedKey != null);
  }

  /// Helper method to batch delete items (max 25 per request)
  Future<void> _batchDeleteItems(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;

    // DynamoDB BatchWriteItem supports max 25 items per request
    const batchSize = 25;

    // Retry configuration
    const int maxAttempts = 6; // exponential backoff attempts
    const int baseDelayMs = 100; // initial backoff
    final rand = Random();

    for (var i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize).toList();

      // We'll loop and retry any unprocessed items or throttled responses
      List<Map<String, dynamic>> toDelete = batch;
      int attempt = 0;
      int delayMs = baseDelayMs;

      while (toDelete.isNotEmpty) {
        final deleteRequests = toDelete.map((item) {
          return {
            'DeleteRequest': {'Key': item},
          };
        }).toList();

        final response = await _dynamoRequest('BatchWriteItem', {
          'RequestItems': {tableName: deleteRequests},
        });

        // Successful HTTP response
        if (response.statusCode == 200) {
          final body =
              jsonDecode(utf8.decode(response.bodyBytes))
                  as Map<String, dynamic>;

          final unprocessed = body['UnprocessedItems'] as Map<String, dynamic>?;

          if (unprocessed != null && unprocessed.isNotEmpty) {
            final unprocessedForTable =
                unprocessed[tableName] as List<dynamic>? ?? <dynamic>[];
            final retryItems = unprocessedForTable.map((req) {
              final deleteReq = req as Map<String, dynamic>;
              return deleteReq['DeleteRequest']['Key'] as Map<String, dynamic>;
            }).toList();

            attempt++;
            if (attempt > maxAttempts) {
              throw Exception(
                'Failed to batch delete items after $attempt attempts; '
                'remaining=${retryItems.length}; lastResponse=${response.body}',
              );
            }

            // Backoff with jitter
            final jitter = rand.nextInt(100);
            await Future.delayed(Duration(milliseconds: delayMs + jitter));
            delayMs = (delayMs * 2).clamp(baseDelayMs, 30 * 1000);
            toDelete = retryItems.cast<Map<String, dynamic>>();
            continue; // retry loop
          }

          // No unprocessed items - batch succeeded
          break;
        }

        // Non-200 response - try to detect throttling and retry with backoff
        final bodyStr = utf8.decode(response.bodyBytes);
        bool isThrottling = false;
        try {
          final parsed = jsonDecode(bodyStr) as Map<String, dynamic>;
          final type = parsed['__type']?.toString() ?? '';
          if (type.contains('Throttling') ||
              type.contains('ProvisionedThroughputExceededException')) {
            isThrottling = true;
          }
        } catch (_) {
          // ignore parse errors
        }

        attempt++;
        if (isThrottling && attempt <= maxAttempts) {
          final jitter = rand.nextInt(100);
          await Future.delayed(Duration(milliseconds: delayMs + jitter));
          delayMs = (delayMs * 2).clamp(baseDelayMs, 30 * 1000);
          // retry same toDelete list
          continue;
        }

        // If we've exhausted retries or it's not a throttling error, fail with the last response
        throw Exception('Failed to batch delete items: ${response.body}');
      }
    }
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
    // Extract parentId, parentProp, and changeAt_orig from state for GSI2
    final stateJson = state.toJson();
    final parentId = stateJson['data_parentId'] as String? ?? '';
    final parentProp = stateJson['data_parentProp'] as String? ?? '';

    // Extract changeAt_orig from change_changeAt_orig_ if present
    final changeAtOrig = stateJson['change_changeAt_orig_']?.toString() ?? '';
    // computeDataHash
    final stateDataHash = computeStateDataHash(stateJson);
    // ignore: non_constant_identifier_names
    final stateDataHash_orig_ = stateDataHash;

    final item = <String, dynamic>{
      'pk': {
        'S': _statePrimaryKey(
          domainType: state.domainType,
          domainId: state.change_domainId,
          entityType: state.entityType,
        ),
      },
      'sk': {'S': _stateSortKey(entityId: state.entityId)},
      'gsi2pk': {
        'S': _stateGsi2Partition(
          domainType: state.domainType,
          domainId: state.change_domainId,
          entityType: state.entityType,
          parentId: parentId,
        ),
      },
      'gsi2sk': {
        'S': _stateGsi2SortKey(
          parentProp: parentProp,
          changeAtOrig: changeAtOrig,
        ),
      },
      ..._encodeJson({
        ...stateJson,
        'stateDataHash': stateDataHash,
        'stateDataHash_orig_': stateDataHash_orig_,
      }),
    };

    final response = await _dynamoRequest('PutItem', {
      'TableName': tableName,
      'Item': item,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to store entity state: ${response.body}');
    }
  }

  /// Gets the current sequence counter value without incrementing it.
  /// Returns 0 if the counter doesn't exist yet.
  Future<int> _getLatestSeq({
    required String domainType,
    required String domainId,
  }) async {
    final response = await _dynamoRequest('GetItem', {
      'TableName': tableName,
      'Key': {
        'pk': {
          'S': _sequencePrimaryKey(domainType: domainType, domainId: domainId),
        },
        'sk': {'S': _sequenceCounterSortKey()},
      },
      'ProjectionExpression': '#v',
      'ExpressionAttributeNames': {'#v': 'value'},
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to get sequence: ${response.body}');
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final item = body['Item'] as Map<String, dynamic>?;

    if (item == null) return 0;

    final value = item['value']?['N'] as String?;
    return int.tryParse(value ?? '0') ?? 0;
  }

  Future<int> _bumpSeq({
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

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final value = body['Attributes']?['value']?['N'] as String?;
    return int.tryParse(value ?? '0') ?? 0;
  }

  Future<http.Response> _dynamoRequest(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    // Ensure initialization has run so `_endpoint` and headers are populated.
    // Some callers may invoke low-level operations without explicitly
    // calling `initialize()` (or there may be a race). Defensively ensure
    // initialization here to avoid a LateInitializationError on `_endpoint`.
    if (!_initialized) await initialize();

    final uri = Uri.parse(_endpoint);
    final body = jsonEncode(payload);

    if (useLocalDynamoDB) {
      final headers = Map<String, String>.from(_baseHeaders)
        ..['X-Amz-Target'] = 'DynamoDB_20120810.$operation';
      return _httpClient.post(uri, headers: headers, body: body);
    }

    final signingCredentials =
        await (_credentialsResolver?.call() ??
            Future<AWSCredentials>.value(credentials));
    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(signingCredentials),
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

  bool get _shouldPublishDomainChangeEvents =>
      domainChangeTopicArn != null && domainChangeTopicArn!.isNotEmpty;

  Future<void> _publishDomainChangeEvents(
    List<DynamoChangeLogEntry> latestChanges,
  ) async {
    if (!_shouldPublishDomainChangeEvents) return;

    final groupedLatestChanges = <String, List<DynamoChangeLogEntry>>{};
    for (final change in latestChanges) {
      final key = '${change.domainType}|${change.domainId}';
      groupedLatestChanges.putIfAbsent(key, () => []).add(change);
    }

    for (final group in groupedLatestChanges.values) {
      group.sort((a, b) => a.seq.compareTo(b.seq));
      final latestStats = {
        ..._buildStatsSummaryFromChanges(group),
        'isIncremental': true,
      };
      final statsMessage = jsonEncode(
        buildWsNotifyStatsMessage(
          domainType: group.first.domainType,
          domainId: group.first.domainId,
          stats: latestStats,
        ),
      );

      final statsAttributes = <String, String>{
        'domainType': group.first.domainType,
        'domainId': group.first.domainId,
      };

      try {
        await _publishSnsMessage(
          topicArn: domainChangeTopicArn!,
          message: statsMessage,
          messageAttributes: statsAttributes,
        );
      } catch (error, stackTrace) {
        SlttLogger.logger.warning(
          '[DynamoDBStorageService] failed to publish domain stats event',
          error,
          stackTrace,
        );
      }

      for (final change in group) {
        final record = WsNotifyRecord(
          notifyType: kNotifyTypeDomainChange,
          domainType: change.domainType,
          domainId: change.domainId,
          entityType: change.entityType,
          change: change.toJson(),
          index: change.seq,
        );

        final message = jsonEncode(
          buildWsNotifyRecordMessage(
            domainType: record.domainType,
            domainId: record.domainId,
            entityType: record.entityType,
            change: record.change,
          ),
        );

        final messageAttributes = <String, String>{
          'domainType': record.domainType,
          'domainId': record.domainId,
        };
        messageAttributes['entityType'] = record.entityType;

        try {
          await _publishSnsMessage(
            topicArn: domainChangeTopicArn!,
            message: message,
            messageAttributes: messageAttributes,
          );
        } catch (error, stackTrace) {
          SlttLogger.logger.warning(
            '[DynamoDBStorageService] failed to publish domain change event',
            error,
            stackTrace,
          );
        }
      }
    }
  }

  Map<String, dynamic> _buildStatsSummaryFromChanges(
    List<DynamoChangeLogEntry> changes,
  ) {
    final entityTypeStats = <String, Map<String, dynamic>>{};
    var totalCreates = 0;
    var totalUpdates = 0;
    var totalDeletes = 0;
    var latestChangeAt = DateTime.fromMillisecondsSinceEpoch(0).toUtc();
    var latestSeq = -1;

    for (final change in changes) {
      final type = change.entityType;
      final entry = entityTypeStats.putIfAbsent(
        type,
        () => {
          'creates': 0,
          'updates': 0,
          'deletes': 0,
          'total': 0,
          'latestChangeAt': '1970-01-01T00:00:00.000Z',
          'latestSeq': -1,
        },
      );

      switch (change.operation) {
        case 'create':
          entry['creates'] = (entry['creates'] as int) + 1;
          totalCreates++;
          break;
        case 'update':
          entry['updates'] = (entry['updates'] as int) + 1;
          totalUpdates++;
          break;
        case 'delete':
          entry['deletes'] = (entry['deletes'] as int) + 1;
          totalDeletes++;
          break;
        default:
      }

      entry['total'] =
          (entry['creates'] as int) +
          (entry['updates'] as int) +
          (entry['deletes'] as int);

      final changeAt = change.changeAt.toUtc();
      final currentLatest = DateTime.tryParse(
        entry['latestChangeAt'] as String,
      )?.toUtc();
      if (currentLatest == null || changeAt.isAfter(currentLatest)) {
        entry['latestChangeAt'] = changeAt.toIso8601String();
      }
      if ((entry['latestSeq'] as int) < change.seq) {
        entry['latestSeq'] = change.seq;
      }

      if (changeAt.isAfter(latestChangeAt)) {
        latestChangeAt = changeAt;
      }
      if (change.seq > latestSeq) {
        latestSeq = change.seq;
      }
    }

    return {
      'changeStats': {
        'creates': totalCreates,
        'updates': totalUpdates,
        'deletes': totalDeletes,
        'total': changes.length,
        'latestChangeAt': latestChangeAt.toIso8601String(),
        'latestSeq': latestSeq,
      },
      'entityTypeStats': {
        'entityTypes': entityTypeStats,
        'totals': {
          'creates': totalCreates,
          'updates': totalUpdates,
          'deletes': totalDeletes,
          'total': changes.length,
          'latestChangeAt': latestChangeAt.toIso8601String(),
          'latestSeq': latestSeq,
        },
      },
    };
  }

  Future<void> _publishSnsMessage({
    required String topicArn,
    required String message,
    required Map<String, String> messageAttributes,
  }) async {
    final uri = Uri.parse('https://sns.$region.amazonaws.com/');
    final bodyEntries = <String, String>{
      'Action': 'Publish',
      'TopicArn': topicArn,
      'Message': message,
      'Version': '2010-03-31',
    };

    var attributeIndex = 1;
    for (final entry in messageAttributes.entries) {
      bodyEntries['MessageAttributes.entry.$attributeIndex.Name'] = entry.key;
      bodyEntries['MessageAttributes.entry.$attributeIndex.Value.DataType'] =
          'String';
      bodyEntries['MessageAttributes.entry.$attributeIndex.Value.StringValue'] =
          entry.value;
      attributeIndex += 1;
    }

    final body = bodyEntries.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');
    final encodedBody = utf8.encode(body);

    final signingCredentials =
        await (_credentialsResolver?.call(false) ??
            Future<AWSCredentials>.value(credentials));
    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(signingCredentials),
    );

    final signedRequest = await signer.sign(
      AWSHttpRequest(
        method: AWSHttpMethod.post,
        uri: uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'host': uri.host,
        },
        body: encodedBody,
      ),
      credentialScope: AWSCredentialScope(
        region: region,
        service: AWSService.sns,
      ),
    );

    final request = http.Request('POST', signedRequest.uri)
      ..headers.addAll(signedRequest.headers)
      ..bodyBytes = encodedBody;

    final streamed = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'SNS publish failed (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> createTableIfNotExists() async {
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
        {'AttributeName': 'gsi2pk', 'AttributeType': 'S'},
        {'AttributeName': 'gsi2sk', 'AttributeType': 'S'},
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
        {
          'IndexName': 'GSI2',
          'KeySchema': [
            {'AttributeName': 'gsi2pk', 'KeyType': 'HASH'},
            {'AttributeName': 'gsi2sk', 'KeyType': 'RANGE'},
          ],
          'Projection': {'ProjectionType': 'ALL'},
        },
      ],
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to create DynamoDB table: ${response.body}');
    }
  }

  /// Generates primary key for change log entries.
  ///
  /// Format: `$sltt#change#domainType_X#domainId_Y#entityType_Z#entityId_W`
  String _changePrimaryKey({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
  }) => buildChangePrimaryKey(
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    entityId: entityId,
  );

  /// Generates primary key prefix for querying change logs by domain.
  ///
  /// Format: `$sltt#change#domainType_X#domainId_Y`
  String _changePrimaryKeyPrefix({
    required String domainType,
    required String domainId,
  }) => buildChangePrimaryKeyPrefix(domainType: domainType, domainId: domainId);

  /// Generates sort key for change log entries.
  ///
  /// Format: `$changes#change#cid_12345`
  String _changeSortKey(String cid) => buildChangeSortKey(cid);

  /// Generates GSI partition key for querying changes by domain in sequence order.
  ///
  /// Format: `$sltt#change#domainType_X#domainId_Y`
  String _changeGsiPartition({
    required String domainType,
    required String domainId,
  }) => buildChangeGsiPartition(domainType: domainType, domainId: domainId);

  /// Generates GSI sort key for change log entries (sequence-based).
  ///
  /// Format: `seq_00000012345` (padded to 19 digits)
  String _changeGsiSortKey(int seq) => buildChangeGsiSortKey(seq);

  /// Generates primary key domain prefix for entity states.
  ///
  /// Format: `$sltt#state#domainType_X#domainId_Y`
  String _statePrimaryKeyDomainPrefix({
    required String domainType,
    required String domainId,
  }) => buildStatePrimaryKeyDomainPrefix(
    domainType: domainType,
    domainId: domainId,
  );

  /// Generates full primary key for entity states.
  ///
  /// Format: `$sltt#state#domainType_X#domainId_Y#entityType_Z`
  String _statePrimaryKey({
    required String domainType,
    required String domainId,
    required String entityType,
  }) => buildStatePrimaryKey(
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
  );

  /// Generates sort key for entity states.
  ///
  /// Format: `$states#state#entityId_abc123`
  String _stateSortKey({required String entityId}) =>
      buildStateSortKey(entityId: entityId);

  /// Generates GSI2 partition key for entity states (for querying by parent).
  ///
  /// Format: `$sltt#state#domainType_X#domainId_Y#entityType_Z#parentId_W`
  String _stateGsi2Partition({
    required String domainType,
    required String domainId,
    required String entityType,
    required String parentId,
  }) => buildStateGsi2Partition(
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    parentId: parentId,
  );

  /// Generates GSI2 sort key for entity states (for sorting by parentProp and changeAt_orig).
  ///
  /// Format: `parentProp_P` (when changeAt_orig is empty)
  ///         `parentProp_P#changeAt_orig__{ISO}` (when changeAt_orig exists)
  String _stateGsi2SortKey({required String parentProp, String? changeAtOrig}) {
    return buildStateGsi2SortKey(
      parentProp: parentProp,
      changeAtOrig: changeAtOrig,
    );
  }

  /// Generates primary key for entity type sync state (change log or entity state).
  ///
  /// Format: `$sltt#etsc#domainType_X#domainId_Y` (for change logs)
  /// Format: `$sltt#etss#domainType_X#domainId_Y` (for entity states)
  String _entityTypeSyncStatePrimaryKey({
    required String domainType,
    required String domainId,
    required bool forChangeLog,
  }) => buildEntityTypeSyncStatePrimaryKey(
    domainType: domainType,
    domainId: domainId,
    forChangeLog: forChangeLog,
  );

  /// Generates sort key for entity type sync state.
  ///
  /// Format: `$etsc#etsc#entityType_portion` (for change logs)
  /// Format: `$etss#etss#entityType_portion` (for entity states)
  String _entityTypeSyncStateSortKey({
    required String entityType,
    required bool forChangeLog,
  }) => buildEntityTypeSyncStateSortKey(
    entityType: entityType,
    forChangeLog: forChangeLog,
  );

  /// Generates primary key for sequence counter.
  ///
  /// Format: `$sltt#seq#domainType_X#domainId_Y`
  String _sequencePrimaryKey({
    required String domainType,
    required String domainId,
  }) => buildSequencePrimaryKey(domainType: domainType, domainId: domainId);

  /// Generates sort key for sequence counter.
  ///
  /// Format: `$seq#counter`
  String _sequenceCounterSortKey() => buildSequenceCounterSortKey();

  /// Generates singleton primary key for storage state.
  ///
  /// Format: `$sltt#storage#singleton`
  String _storageStatePrimaryKey() => buildStorageStatePrimaryKey();

  /// Generates singleton sort key for storage state.
  ///
  /// Format: `$storage#state`
  String _storageStateSortKey() => buildStorageStateSortKey();

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
              entry.key == 'gsi1sk' ||
              entry.key == 'gsi2pk' ||
              entry.key == 'gsi2sk' ||
              entry.key == 'gsi3pk' ||
              entry.key == 'gsi3sk')) {
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

  // ----------------------------------------------------------------------
  // DynamoDB Export Helpers
  // ----------------------------------------------------------------------
  /// Start an export job via DynamoDB ExportTableToPointInTime API.
  ///
  /// The [exportRequest] should match the AWS API payload (e.g. include
  /// `TableArn`, `S3Bucket`, `S3Prefix`, `ExportFormat`, `RoleArn`, etc.).
  /// Returns the decoded JSON response from AWS on success.
  Future<Map<String, dynamic>> startExportToS3(
    Map<String, dynamic> exportRequest,
  ) async {
    final response = await _dynamoRequest(
      'ExportTableToPointInTime',
      exportRequest,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to start ExportTableToPointInTime: ${response.body}',
      );
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  /// List export jobs via DynamoDB ListExports API.
  ///
  /// [listRequest] may include `TableArn`, `MaxResults`, `NextToken`, etc.
  Future<Map<String, dynamic>> listExports(
    Map<String, dynamic> listRequest,
  ) async {
    final response = await _dynamoRequest('ListExports', listRequest);
    if (response.statusCode != 200) {
      throw Exception('Failed to list exports: ${response.body}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  /// Describe a specific export job via DynamoDB DescribeExport API.
  ///
  /// [describeRequest] should include `ExportArn`.
  Future<Map<String, dynamic>> describeExport(
    Map<String, dynamic> describeRequest,
  ) async {
    final response = await _dynamoRequest('DescribeExport', describeRequest);
    if (response.statusCode != 200) {
      throw Exception('Failed to describe export: ${response.body}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }
}

/// Result wrapper so callers can paginate using [nextCursor].
class EntityStateQueryResult {
  final List<Map<String, dynamic>> items;
  final String?
  nextCursor; // base64(jsonStringified(LastEvaluatedKey)), null if no more pages

  const EntityStateQueryResult({required this.items, this.nextCursor});
}
