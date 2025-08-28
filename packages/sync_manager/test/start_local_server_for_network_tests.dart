@Tags(['network'])
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sltt_core/src/testing/test_server_registry.dart'
    show registerExternalApiBaseUrl;
import 'package:sync_manager/src/shared_storage_service.dart';
import 'package:test/test.dart';

class LocalTestServer extends BaseRestApiServer {
  LocalTestServer({required super.serverName, required super.storage});

  @override
  String get storageTypeDescription => storage.getStorageType();

  // Expose protected buildRouter for test harness
  Router router() => buildRouter();
}

void main() {
  HttpServer? server;
  setUpAll(() async {
    final storage = OutsyncsStorageService.instance;
    final app = LocalTestServer(
      serverName: 'sync-manager-local',
      storage: storage,
    );
    // initialize storage and start shelf server
    await storage.initialize();
    final handler = const Pipeline().addHandler(app.router().call);
    server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 0);

    final baseUrl = Uri.parse('http://localhost:${server!.port}');
    print('sync_manager local server started at $baseUrl');

    // Register base URL for other tests to consume
    registerExternalApiBaseUrl(baseUrl);
  });

  tearDownAll(() async {
    if (server != null) await server!.close(force: true);
  });

  test('local server started', () async {
    expect(true, isTrue);
  });
}
