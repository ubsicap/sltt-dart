import 'dart:convert';
import 'dart:io';

import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'helpers/in_memory_storage.dart';
import 'test_models.dart';

// Small server harness for running the BaseRestApiServer with InMemoryStorage
class TestServer extends BaseRestApiServer {
  TestServer({required super.serverName, required super.storage});

  @override
  String get storageTypeDescription => storage.getStorageType();
}

void main() {
  late Uri baseUrl;
  final storage = InMemoryStorage(storageType: 'local');
  final server = TestServer(serverName: 'test-server', storage: storage);

  setUpAll(() async {
    // Start on ephemeral port
    await server.start(port: 0);
    final addr = server.address;
    expect(addr, isNotNull);
    baseUrl = Uri.parse(addr!);

    // Register change-log entry factory group for tests
    registerChangeLogEntryFactoryGroup(
      SerializableGroup<BaseChangeLogEntry>(
        fromJson: TestChangeLogEntry.fromJson,
        fromJsonBase: TestChangeLogEntry.fromJsonBase,
        toJson: (entry) => (entry as TestChangeLogEntry).toJson(),
        toJsonBase: (entry) => (entry as TestChangeLogEntry).toJsonBase(),
        toSafeJson: (original) {
          // Use the common safe JSON service
          return SafeJsonService.generateSafeChangeLogJson(original);
        },
      ),
    );
  });

  tearDownAll(() async {
    await server.stop();
  });

  group('GET /api/state tests', () {
    test('returns empty list for entityCollection with no states', () async {
      final uri = baseUrl.replace(
        path: '/api/state/projects/test-project/tasks',
      );
      final req = await HttpClient().getUrl(uri);
      final res = await req.close();
      expect(res.statusCode, 200);
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      expect(json['items'], isA<List>());
      expect(json['items'], isEmpty);
      expect(json['hasMore'], isFalse);
    });

    test('returns seeded entity state by entityCollection and entityId', () async {
      // Seed a state directly into storage via updateChangeLogAndState
      final expectedNameLocal = 'Seeded Task';
      final expectedParentId = 'seed-project';
      final change = TestChangeLogEntry(
        cid: 'seed-cid',
        entityId: 'seed-project-task-1',
        entityType: 'task',
        domainId: 'seed-project',
        domainType: 'project',
        changeAt: DateTime.now(),
        changeBy: 'tester',
        operation: 'create',
        stateChanged: false,
        dataJson: jsonEncode({
          'nameLocal': expectedNameLocal,
          'parentId': expectedParentId,
        }),
      );

      // Route the seeded change through the production change processing pipeline
      // so a canonical state is produced rather than seeding the state directly.
      final changeJson = change.toJson();
      final procResult = await ChangeProcessingService.processChanges(
        storageMode: 'save',
        changes: [changeJson],
        srcStorageType: 'cloud',
        srcStorageId: 'cloudId',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );

      expect(
        procResult.isSuccess,
        isTrue,
        reason:
            'ChangeProcessingService failed: ${procResult.errorMessage ?? "Unknown error"}\nresultsSummary: ${procResult.resultsSummary}',
      );

      // Query collection
      final uri = baseUrl.replace(
        path: '/api/state/projects/seed-project/tasks',
      );
      final req = await HttpClient().getUrl(uri);
      final res = await req.close();
      expect(res.statusCode, 200);
      final body = await res.transform(utf8.decoder).join();
      print('DEBUG: collection response body: $body');
      final json = jsonDecode(body) as Map<String, dynamic>;
      expect(json['items'], isA<List>());
      expect(json['items'].length, 1);
      final item = json['items'].first as Map<String, dynamic>;
      print('DEBUG: collection first item: $item');
      print(
        'DEBUG: data_nameLocal exists: ${item.containsKey('data_nameLocal')}',
      );
      print('DEBUG: data_nameLocal value: ${item['data_nameLocal']}');
      print(
        'DEBUG: data_nameLocal runtimeType: ${item['data_nameLocal']?.runtimeType}',
      );
      expect(item['data_nameLocal'], expectedNameLocal, reason: body);

      // Query specific entity
      final uri2 = baseUrl.replace(
        path: '/api/state/projects/seed-project/tasks/${change.entityId}',
      );
      final req2 = await HttpClient().getUrl(uri2);
      final res2 = await req2.close();
      expect(res2.statusCode, 200);
      final body2 = await res2.transform(utf8.decoder).join();
      final json2 = jsonDecode(body2) as Map<String, dynamic>;
      expect(json2['entityId'], change.entityId);
      final state = json2['state'] as Map<String, dynamic>;
      expect(state['data_nameLocal'], expectedNameLocal, reason: body2);
      expect(state['data_parentId'], expectedParentId, reason: body2);
    });
  });
}
