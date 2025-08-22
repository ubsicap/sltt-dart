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
            'data':
                (original['data'] as Map<String, dynamic>?) ??
                <String, dynamic>{},
            'operation': original['operation'] ?? 'update',
            'operationInfo':
                (original['operationInfo'] as Map<String, dynamic>?) ??
                <String, dynamic>{},
            'stateChanged': original['stateChanged'] ?? false,
            'unknown':
                (original['unknown'] as Map<String, dynamic>?) ??
                <String, dynamic>{},
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
}
