import 'dart:convert';
import 'dart:io';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';

import '../models/dynamo_change_log_entry.dart';
import '../models/dynamo_entity_state.dart';
import '../models/dynamo_entity_type_sync_state.dart';
import '../models/dynamo_serialization.dart';

/// DynamoDB implementation of [BaseStorageService].
///
/// All merge/conflict logic is delegated to [ChangeProcessingService]. This
/// class is responsible solely for persisting and retrieving change log entries
/// and entity state documents from a single DynamoDB table.
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

    late final DynamoEntityState newState;
    if (skipStateWrite && entityState != null && stateUpdates.isEmpty) {
      newState = entityState as DynamoEntityState;
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

      newState = DynamoEntityState.fromJson(mergedStateJson);

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
        'sk': {'S': entityId},
      },
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch entity state: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final item = payload['Item'] as Map<String, dynamic>?;
    if (item == null) return null;

    return DynamoEntityState.fromJson(_decodeItem(item));
  }

  @override
  Future<BaseChangeLogEntry?> getChange({
    required String domainType,
    required String domainId,
    required String cid,
  }) async {
    await initialize();

    final pkPrefix = _changePrimaryKeyPrefix(
      domainType: domainType,
      domainId: domainId,
    );

    final response = await _dynamoRequest('Query', {
      'TableName': tableName,
      'KeyConditionExpression': 'pk = :pk AND sk = :sk',
      'ExpressionAttributeValues': {
        ':pk': {'S': '$pkPrefix#CID#$cid'},
        ':sk': {'S': 'CID#$cid'},
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
      _decodeItem(items.first as Map<String, dynamic>),
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
      'KeyConditionExpression': 'gsi1pk = :pk',
      'ExpressionAttributeValues': {
        ':pk': {'S': gsiPk},
      },
      'ScanIndexForward': true,
    };

    if (cursor != null) {
      payload['ExclusiveStartKey'] = {
        'gsi1pk': {'S': gsiPk},
        'gsi1sk': {'S': _sequenceSortKey(cursor)},
        'pk': {'S': '$gsiPk#CUR'},
        'sk': {'S': 'CUR'},
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
            _decodeItem(item as Map<String, dynamic>),
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
    final pk = 'ETSC#$domainType#$domainId';

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
    final pk = 'ETSS#$domainType#$domainId';

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

    final pkPrefix = _statePrimaryKeyDomainPrefix(domainType: domainType);
    final response = await _dynamoRequest('Scan', {
      'TableName': tableName,
      'ProjectionExpression': 'pk',
      'FilterExpression': 'begins_with(pk, :pk)',
      'ExpressionAttributeValues': {
        ':pk': {'S': pkPrefix},
      },
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to list domains: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['Items'] as List<dynamic>? ?? <dynamic>[];

    final domainIds = <String>{};
    for (final raw in items) {
      final pk = (raw as Map<String, dynamic>)['pk']?['S'] as String?;
      if (pk == null) continue;
      final parts = pk.split('#');
      if (parts.length >= 4) domainIds.add(parts[3]);
    }

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
      final json = _decodeItem(item as Map<String, dynamic>);
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

    // Create a partition key for entity type sync state
    // Format: ETSS#domainType#domainId for entity states
    //         ETSC#domainType#domainId for change logs
    final pkPrefix = forChangeLog ? 'ETSC' : 'ETSS';
    final pk = '$pkPrefix#$domainType#${dynamoChange.domainId}';
    // Sort key is the entity type
    final sk = entityType;

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

    final pkPrefix = _statePrimaryKeyPrefix(
      domainType: domainType,
      domainId: domainId,
    );

    await _dynamoRequest('DeleteItem', {
      'TableName': tableName,
      'Key': {
        'pk': {'S': pkPrefix},
        'sk': {'S': domainId},
      },
    });
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
      'sk': {'S': 'CID#${entry.cid}'},
      'gsi1pk': {
        'S': _changeGsiPartition(
          domainType: entry.domainType,
          domainId: entry.domainId,
        ),
      },
      'gsi1sk': {'S': _sequenceSortKey(entry.seq)},
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

  Future<void> _putEntityState(DynamoEntityState state) async {
    final item = <String, dynamic>{
      'pk': {
        'S': _statePrimaryKey(
          domainType: state.domainType,
          domainId: state.change_domainId,
          entityType: state.entityType,
        ),
      },
      'sk': {'S': state.entityId},
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
        'pk': {'S': 'SEQ#$domainType#$domainId'},
        'sk': {'S': 'COUNTER'},
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

  String _changePrimaryKey({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
  }) {
    final prefix = _changePrimaryKeyPrefix(
      domainType: domainType,
      domainId: domainId,
    );
    return '$prefix#ET#$entityType#EI#$entityId';
  }

  String _changePrimaryKeyPrefix({
    required String domainType,
    required String domainId,
  }) => 'CHANGE#DT#$domainType#DI#$domainId';

  String _changeGsiPartition({
    required String domainType,
    required String domainId,
  }) => 'CHANGE#DT#$domainType#DI#$domainId';

  String _statePrimaryKeyDomainPrefix({required String domainType}) =>
      'STATE#DT#$domainType';

  String _statePrimaryKeyPrefix({
    required String domainType,
    required String domainId,
  }) => 'STATE#DT#$domainType#DI#$domainId';

  String _statePrimaryKey({
    required String domainType,
    required String domainId,
    required String entityType,
  }) => 'STATE#DT#$domainType#DI#$domainId#ET#$entityType';

  String _sequenceSortKey(int seq) => 'SEQ#${seq.toString().padLeft(19, '0')}';

  Map<String, dynamic> _encodeJson(Map<String, dynamic> json) {
    final result = <String, dynamic>{};
    for (final entry in json.entries) {
      result[entry.key] = _encodeValue(entry.value);
    }
    return result;
  }

  Map<String, dynamic> _decodeItem(Map<String, dynamic> item) {
    final result = <String, dynamic>{};
    for (final entry in item.entries) {
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
