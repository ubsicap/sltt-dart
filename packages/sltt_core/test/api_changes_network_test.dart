@Tags(['network'])
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sltt_core/src/models/factory_pair.dart';
import 'package:sltt_core/src/services/base_change_log_entry_service.dart';
import 'package:test/test.dart';

import 'test_models.dart';

/// Minimal in-memory storage to exercise _handleCreateChanges
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
    // Build new change log entry JSON by overlaying updates
    final newChangeJson = {...changeLogEntry.toJson(), ...changeUpdates};
    final newChange = TestChangeLogEntry.fromJson(newChangeJson);

    // Merge state updates into prior state JSON
    final prior = (entityState?.toJson() ?? <String, dynamic>{});
    final merged = {...prior, ...stateUpdates}
      ..removeWhere((k, v) => v == null);
    // Ensure required defaults for entity state
    merged.putIfAbsent('entityId', () => newChange.entityId);
    merged.putIfAbsent('entityType', () => newChange.entityType.value);
    merged.putIfAbsent('change_domainId', () => newChange.domainId);
    merged.putIfAbsent('change_domainId_orig_', () => newChange.domainId);
    merged.putIfAbsent(
      'change_changeAt',
      () => newChange.changeAt.toIso8601String(),
    );
    merged.putIfAbsent(
      'change_changeAt_orig_',
      () => newChange.changeAt.toIso8601String(),
    );
    merged.putIfAbsent('change_cid', () => newChange.cid);
    merged.putIfAbsent('change_cid_orig_', () => newChange.cid);
    merged.putIfAbsent('change_changeBy', () => newChange.changeBy);

    final newState = TestEntityState.fromJson(merged);
    _states[_key(
          newChange.domainId,
          newChange.entityType.value,
          newChange.entityId,
        )] =
        newState;

    return (newChangeLogEntry: newChange, newEntityState: newState);
  }

  // Unused in this test; provide minimal implementations
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
  Future<Map<String, dynamic>> getEntityTypeStats(String projectId) async =>
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
  }) async => {'items': [], 'nextCursor': null, 'hasMore': false};

  @override
  Future<void> markAsOutdated(
    String projectId,
    int seq,
    int outdatedBy,
  ) async {}

  @override
  Future<CreateChangesResult> createChangesWithChangeDetection(
    List<Map<String, dynamic>> changesData,
  ) async {
    return CreateChangesResult(
      createdChanges: const [],
      noOpChangeCids: const [],
    );
  }

  @override
  Future<List<BaseChangeLogEntry>> getChangesNotOutdated(
    String projectId,
  ) async {
    return getChangesWithCursor(projectId: projectId);
  }
}

class TestServer extends BaseRestApiServer {
  TestServer({required super.serverName, required super.storage});

  @override
  String get storageTypeDescription => storage.getStorageType();

  // Expose a public method that internally calls the protected buildRouter
  Router router() => buildRouter();
}

void main() {
  late HttpServer server;
  late Uri baseUrl;
  // Use a fixed base time for deterministic field-level tests
  final baseTime = DateTime.parse('2023-01-01T00:00:00Z');

  Future<Map<String, dynamic>> postSingleChange(
    Map<String, dynamic> change,
  ) async {
    final uri = baseUrl.replace(
      path: '/api/changes',
      queryParameters: {'changeUpdates': 'true', 'stateUpdates': 'true'},
    );

    final req = await HttpClient().postUrl(uri);
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode([change]));
    final res = await req.close();
    expect(res.statusCode, 200);
    final body = await res.transform(utf8.decoder).join();
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<void> seedChange(Map<String, dynamic> change) async {
    await postSingleChange(change);
  }

  Map<String, dynamic> changePayload({
    required String projectId,
    required String entityType,
    required String entityId,
    required DateTime changeAt,
    String storageId = 'local',
    Map<String, dynamic> data = const <String, dynamic>{},
    String operation = 'update',
    bool addDefaultParentId = true,
  }) {
    final adjustedData = Map<String, dynamic>.from(data);
    // Ensure required parentId is present for TestEntityState unless it's an explicit delete
    if (addDefaultParentId &&
        operation != 'delete' &&
        !adjustedData.containsKey('parentId')) {
      adjustedData['parentId'] = 'root';
    }
    return {
      'projectId': projectId,
      'domainId': projectId,
      'domainType': 'project',
      'entityType': entityType,
      'entityId': entityId,
      'changeBy': 'tester',
      'changeAt': changeAt.toUtc().toIso8601String(),
      'cid': generateCid(changeAt),
      'storageId': storageId,
      'operation': operation,
      'operationInfoJson': '{}',
      'stateChanged': false,
      'unknownJson': '{}',
      'dataJson': jsonEncode(adjustedData),
    };
  }

  setUpAll(() async {
    // Register change-log entry factory group for tests
    registerChangeLogEntryFactoryGroup(
      FactoryGroup<BaseChangeLogEntry>(
        (json) => TestChangeLogEntry.fromJson(json),
        (entry) => (entry as TestChangeLogEntry).toJson(),
        (original) {
          // Produce a safe shape for TestChangeLogEntry
          final now = DateTime.now().toUtc();
          return {
            'entityId': original['entityId'] ?? 'e-test',
            'entityType': original['entityType'] ?? 'project',
            'domainId':
                original['domainId'] ?? original['projectId'] ?? 'p-test',
            'domainType': original['domainType'] ?? 'project',
            'changeAt': original['changeAt'] ?? now.toIso8601String(),
            'cid': original['cid'] ?? generateCid(now),
            'storageId': original['storageId'] ?? 'local',
            'changeBy': original['changeBy'] ?? 'tester',
            'dataJson': original['dataJson'] ?? '{}',
            'operation': original['operation'] ?? 'update',
            'operationInfoJson': original['operationInfoJson'] ?? '{}',
            'stateChanged': original['stateChanged'] ?? false,
            'unknownJson': original['unknownJson'] ?? '{}',
          };
        },
      ),
    );

    final storage = InMemoryStorage(storageId: 'local');
    final app = TestServer(serverName: 'core-it', storage: storage);

    final handler = const Pipeline().addHandler(app.router().call);
    server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 0);
    baseUrl = Uri.parse('http://localhost:${server.port}');
  });

  tearDownAll(() async {
    await server.close(force: true);
  });

  test(
    'POST /api/changes?changeUpdates=true&stateUpdates=true returns summaries',
    () async {
      final uri = baseUrl.replace(
        path: '/api/changes',
        queryParameters: {'changeUpdates': 'true', 'stateUpdates': 'true'},
      );

      final payload = [
        {
          'projectId': 'proj-1', // accepted as domainId
          'domainId': 'proj-1',
          'domainType': 'project',
          'entityType': 'project',
          'entityId': 'entity-1',
          'changeBy': 'tester',
          // minimal required fields for a valid TestChangeLogEntry
          'changeAt': DateTime.now().toUtc().toIso8601String(),
          'cid': generateCid(),
          'storageId': 'local',
          'operation': 'update',
          'operationInfo': <String, dynamic>{},
          'stateChanged': false,
          'unknown': <String, dynamic>{},
          'data': {'nameLocal': 'Core API Net Test', 'parentId': 'root'},
        },
      ];

      final req = await HttpClient().postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(payload));
      final res = await req.close();

      expect(res.statusCode, 200);
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;

      expect(json['storageType'], isNotEmpty);
      expect(json['storageId'], isNotEmpty);
      // change summaries
      expect(json['created'], anyOf(isA<List>(), isNotNull));
      expect(json['updated'], anyOf(isA<List>(), isNotNull));
      expect(json['deleted'], anyOf(isA<List>(), isNotNull));
      expect(json['noOps'], anyOf(isA<List>(), isNotNull));
      // optional details due to query params
      expect(json['changeUpdates'], isA<List>());
      expect(json['stateUpdates'], isA<List>());
      expect((json['changeUpdates'] as List).first, contains('cid'));
      expect((json['stateUpdates'] as List).first, contains('cid'));
    },
  );

  group(
    'POST /api/changes semantics (like getUpdatesForChangeLogEntryAndEntityState)',
    () {
      test(
        'handles field-level conflict resolution (newer change wins)',
        () async {
          final project = 'proj-fl';
          final entity = 'entity-fl-1';
          // Seed initial state rank=1 at baseTime
          await seedChange(
            changePayload(
              projectId: project,
              entityType: 'task',
              entityId: entity,
              changeAt: baseTime,
              data: {'rank': '1'},
            ),
          );
          // Apply newer change rank=2
          final newer = baseTime.add(const Duration(minutes: 5));
          final resp = await postSingleChange(
            changePayload(
              projectId: project,
              entityType: 'task',
              entityId: entity,
              changeAt: newer,
              data: {'rank': '2'},
              addDefaultParentId: false,
            ),
          );
          final cu =
              (resp['changeUpdates'] as List).first['updates']
                  as Map<String, dynamic>;
          final su =
              (resp['stateUpdates'] as List).first['state']
                  as Map<String, dynamic>;
          expect(cu['operation'], 'update');
          expect(cu['operationInfo']['outdatedBys'], []);
          expect(cu['operationInfo']['noOpFields'], []);
          expect(cu['stateChanged'], isTrue);
          expect((cu['data'] as Map<String, dynamic>), {'rank': '2'});
          expect(su['data_rank'], '2');
          expect(su['data_rank_changeAt_'], newer.toUtc().toIso8601String());
        },
      );

      test(
        'preserves incoming data when storageId differs (no data in changeUpdates)',
        () async {
          final project = 'proj-cross';
          final entity = 'entity-cross-1';
          // Seed initial state rank=1
          await seedChange(
            changePayload(
              projectId: project,
              entityType: 'task',
              entityId: entity,
              changeAt: baseTime,
              data: {'rank': '1'},
            ),
          );
          // Post same rank with different storageId to trigger data omission
          final resp = await postSingleChange(
            changePayload(
              projectId: project,
              entityType: 'task',
              entityId: entity,
              changeAt: baseTime.add(const Duration(minutes: 1)),
              storageId: 'cloud', // differs from server's 'local'
              data: {'rank': '1'},
              addDefaultParentId: false,
            ),
          );
          final cu =
              (resp['changeUpdates'] as List).first['updates']
                  as Map<String, dynamic>;
          expect(cu['operation'], 'noOp');
          expect(cu['operationInfo']['noOpFields'], contains('rank'));
          // Data is omitted in changeUpdates when storageId != targetStorageId
          expect(cu['data'], isNull);
        },
      );

      test(
        'records noOpFields and only includes changed fields in data',
        () async {
          final project = 'proj-noop';
          final entity = 'entity-noop-1';
          // Seed initial state: rank=1, parentId=parent1
          await seedChange(
            changePayload(
              projectId: project,
              entityType: 'task',
              entityId: entity,
              changeAt: baseTime,
              data: {'rank': '1', 'parentId': 'parent1'},
            ),
          );
          // Update with rank same (no-op), parentId changed, nameLocal new
          final resp = await postSingleChange(
            changePayload(
              projectId: project,
              entityType: 'task',
              entityId: entity,
              changeAt: baseTime.add(const Duration(minutes: 1)),
              data: {
                'rank': '1',
                'parentId': 'parent2',
                'nameLocal': 'New Name',
              },
            ),
          );
          final cu =
              (resp['changeUpdates'] as List).first['updates']
                  as Map<String, dynamic>;
          expect(cu['operation'], 'update');
          expect(cu['operationInfo']['noOpFields'], contains('rank'));
          final data = (cu['data'] as Map<String, dynamic>);
          expect(data.keys.toSet(), {'parentId', 'nameLocal'});
          expect(data['parentId'], 'parent2');
          expect(data['nameLocal'], 'New Name');
          final su =
              (resp['stateUpdates'] as List).first['state']
                  as Map<String, dynamic>;
          expect(su['data_parentId'], 'parent2');
          expect(su['data_nameLocal'], 'New Name');
        },
      );

      test(
        'includes only non-outdated, non-noop fields in output data',
        () async {
          final project = 'proj-mix';
          final entity = 'entity-mix-1';
          final olderTime = baseTime.subtract(const Duration(minutes: 5));
          final newerFieldTime = baseTime.add(const Duration(minutes: 2));
          // Seed older parentId and nameLocal
          await seedChange(
            changePayload(
              projectId: project,
              entityType: 'task',
              entityId: entity,
              changeAt: olderTime,
              data: {
                'parentId': 'parent1',
                'nameLocal': 'Same Name',
                'rank': '1',
              },
            ),
          );
          // Update rank to be newer than upcoming changeAt
          await seedChange(
            changePayload(
              projectId: project,
              entityType: 'task',
              entityId: entity,
              changeAt: newerFieldTime,
              data: {'rank': '9'},
              addDefaultParentId: false,
            ),
          );
          // Now send a change between olderTime and newerFieldTime
          final resp = await postSingleChange(
            changePayload(
              projectId: project,
              entityType: 'task',
              entityId: entity,
              changeAt: baseTime,
              data: {
                'rank': '1',
                'parentId': 'parent2',
                'nameLocal': 'Same Name',
              },
              addDefaultParentId: false,
            ),
          );
          final cu =
              (resp['changeUpdates'] as List).first['updates']
                  as Map<String, dynamic>;
          expect(cu['operation'], anyOf('update', 'outdated'));
          expect(cu['operationInfo']['outdatedBys'], contains('rank'));
          expect(cu['operationInfo']['noOpFields'], contains('nameLocal'));
          expect(cu['data'], {'parentId': 'parent2'});
        },
      );

      test('rejects older changes (outdated)', () async {
        final project = 'proj-old';
        final entity = 'entity-old-1';
        // Seed at baseTime
        await seedChange(
          changePayload(
            projectId: project,
            entityType: 'task',
            entityId: entity,
            changeAt: baseTime,
            data: {'rank': '1'},
          ),
        );
        // Older update
        final older = baseTime.subtract(const Duration(minutes: 5));
        final resp = await postSingleChange(
          changePayload(
            projectId: project,
            entityType: 'task',
            entityId: entity,
            changeAt: older,
            data: {'rank': '2'},
            addDefaultParentId: false,
          ),
        );
        final cu =
            (resp['changeUpdates'] as List).first['updates']
                as Map<String, dynamic>;
        expect(cu['operation'], 'outdated');
        expect(cu['stateChanged'], isFalse);
        expect(cu['data'], {});
      });

      test('handles new entity creation', () async {
        final project = 'proj-create';
        final entity = 'entity-new-1';
        final resp = await postSingleChange(
          changePayload(
            projectId: project,
            entityType: 'task',
            entityId: entity,
            changeAt: baseTime.add(const Duration(minutes: 1)),
            operation: 'create',
            data: {'rank': '1', 'parentId': 'parent2'},
          ),
        );
        final cu =
            (resp['changeUpdates'] as List).first['updates']
                as Map<String, dynamic>;
        final su =
            (resp['stateUpdates'] as List).first['state']
                as Map<String, dynamic>;
        expect(cu['operation'], 'create');
        expect(cu['stateChanged'], isTrue);
        final data = (cu['data'] as Map<String, dynamic>);
        expect(data.keys.toSet(), containsAll(['rank', 'parentId']));
        expect(su['entityId'], entity);
        expect(su['data_rank'], '1');
        expect(su['data_parentId'], 'parent2');
      });

      test('populates nameLocal from change data on create', () async {
        final project = 'proj-name';
        final entity = 'entity-name-1';
        final resp = await postSingleChange(
          changePayload(
            projectId: project,
            entityType: 'task',
            entityId: entity,
            changeAt: baseTime.add(const Duration(minutes: 2)),
            operation: 'create',
            data: {'parentId': 'parent3', 'nameLocal': 'New Name'},
          ),
        );
        final cu =
            (resp['changeUpdates'] as List).first['updates']
                as Map<String, dynamic>;
        final su =
            (resp['stateUpdates'] as List).first['state']
                as Map<String, dynamic>;
        expect(cu['operation'], 'create');
        expect(su['data_parentId'], 'parent3');
        expect(su['data_nameLocal'], 'New Name');
        final data = (cu['data'] as Map<String, dynamic>);
        expect(data['nameLocal'], 'New Name');
        expect(data['parentId'], 'parent3');
      });

      test('handles entity deletion', () async {
        final project = 'proj-del';
        final entity = 'entity-del-1';
        // Seed entity
        await seedChange(
          changePayload(
            projectId: project,
            entityType: 'task',
            entityId: entity,
            changeAt: baseTime,
            data: {'rank': '1'},
          ),
        );
        // Delete
        final resp = await postSingleChange(
          changePayload(
            projectId: project,
            entityType: 'task',
            entityId: entity,
            changeAt: baseTime.add(const Duration(minutes: 10)),
            operation: 'delete',
            data: {'deleted': true},
          ),
        );
        final cu =
            (resp['changeUpdates'] as List).first['updates']
                as Map<String, dynamic>;
        final su =
            (resp['stateUpdates'] as List).first['state']
                as Map<String, dynamic>;
        expect(cu['operation'], 'delete');
        expect(cu['stateChanged'], isTrue);
        expect(cu['data'], {'deleted': true});
        expect(su['data_deleted'], true);
      });
    },
  );
}
