@Tags(['network'])
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/isar_change_log_entry.dart'
    show isarChangeLogEntryFactoryRegistration;
import 'package:sync_manager/src/shared_storage_service.dart';
import 'package:test/test.dart';

import '../../sltt_core/test/helpers/api_changes_network_suite.dart'
    show runApiChangesNetworkTests;

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
    // Fallback: start LocalStorageService for this test file
    final storage = LocalStorageService('test_local', 'TestLocalStorage');
    await storage.initialize();
    final app = TestServer(serverName: 'sync-manager-it', storage: storage);
    final handler = const Pipeline().addHandler(app.router().call);
    server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 0);
    baseUrl = Uri.parse('http://localhost:${server!.port}');
    return baseUrl!;
  }

  setUpAll(() async {
    // Ensure IsarChangeLogEntry factory is registered for tests
    isarChangeLogEntryFactoryRegistration;
  });

  tearDownAll(() async {
    if (server != null) {
      await server!.close(force: true);
    }
  });

  group('Run All Tests (LocalStorageService)', () {
    runApiChangesNetworkTests(resolveBaseUrl);
  });
}
