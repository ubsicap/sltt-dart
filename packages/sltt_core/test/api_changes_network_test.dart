@Tags(['network'])
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'helpers/api_changes_network_suite.dart' show runApiChangesNetworkTests;
import 'helpers/in_memory_storage.dart';
import 'test_models.dart';

class TestServer extends BaseRestApiServer {
  TestServer({required super.serverName, required super.storage});

  @override
  String get storageTypeDescription => storage.getStorageType();

  // Expose a public method that internally calls the protected buildRouter
  Router router() => buildRouter();
}

void main() {
  HttpServer? server;
  Uri? baseUrl;

  Future<Uri> resolveBaseUrl() async {
    if (baseUrl != null) return baseUrl!;
    final externalApiBaseUrl = Platform.environment['API_BASE_URL'];
    if (externalApiBaseUrl != null && externalApiBaseUrl.isNotEmpty) {
      baseUrl = Uri.parse(externalApiBaseUrl);
      return baseUrl!;
    }
    // Fallback: start in-memory server for this test file
    final storage = InMemoryStorage(storageType: 'local');
    final app = TestServer(serverName: 'core-it', storage: storage);
    final handler = const Pipeline().addHandler(app.router().call);
    server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 0);
    baseUrl = Uri.parse('http://localhost:${server!.port}');
    return baseUrl!;
  }

  setUpAll(() async {
    // Register change-log entry factory group for tests
    registerChangeLogEntryFactoryGroup(
      SerializableGroup<BaseChangeLogEntry>(
        (json) => TestChangeLogEntry.fromJson(json),
        (json) => TestChangeLogEntry.fromJsonBase(json),
        (entry) => (entry as TestChangeLogEntry).toJson(),
        (original) {
          // Produce a safe shape for TestChangeLogEntry
          final now = HlcTimestampGenerator.generate();
          return {
            'entityId': original['entityId'] ?? 'e-test',
            'entityType': original['entityType'] ?? 'project',
            'domainId': original['domainId'] ?? 'p-test',
            'domainType': original['domainType'] ?? 'project',
            'changeAt': original['changeAt'] ?? now.toIso8601String(),
            'cid': original['cid'] ?? generateCid(now),
            'storageId': original['storageId'] ?? 'local',
            'changeBy': original['changeBy'] ?? 'tester',
            'dataJson': JsonUtils.normalize(original['dataJson']),
            'operation': original['operation'] ?? 'update',
            'operationInfoJson': JsonUtils.normalize(
              original['operationInfoJson'],
            ),
            'stateChanged': original['stateChanged'] ?? false,
            'unknownJson': JsonUtils.normalize(original['unknownJson']),
          };
        },
      ),
    );
  });

  tearDownAll(() async {
    if (server != null) {
      await server!.close(force: true);
    }
  });

  group('Run All Tests', () {
    runApiChangesNetworkTests(resolveBaseUrl);
  });
}
