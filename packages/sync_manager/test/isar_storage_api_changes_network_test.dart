@Tags(['network'])
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/isar_storage_service.dart';
import 'package:sync_manager/src/models/isar_change_log_entry.dart'
    show isarChangeLogEntryFactoryRegistration;
import 'package:test/test.dart';

import '../../sltt_core/test/helpers/api_changes_network_suite.dart'
    show ApiChangesNetworkTestSuite;

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
  IsarStorageService? storage;
  const testDbName = 'test_local_api_changes';

  Future<void> cleanupTestDatabase() async {
    try {
      // Clean up any existing test database files
      final dir = Directory('./isar_db');
      if (await dir.exists()) {
        final files = await dir.list().toList();
        for (final file in files) {
          if (file.path.contains(testDbName)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // Ignore cleanup errors - they're not critical
      print('Warning: Could not clean up test database: $e');
    }
  }

  Future<Uri> resolveBaseUrl() async {
    if (baseUrl != null) return baseUrl!;
    final externalApiBaseUrl = Platform.environment['API_BASE_URL'];
    if (externalApiBaseUrl != null && externalApiBaseUrl.isNotEmpty) {
      baseUrl = Uri.parse(externalApiBaseUrl);
      return baseUrl!;
    }

    // Clean up any existing test database first
    await cleanupTestDatabase();

    // Create IsarStorageService with a consistent test database name
    storage = IsarStorageService(testDbName, 'TestLocalStorage');
    await storage!.initialize();
    final app = TestServer(serverName: 'sync-manager-it', storage: storage!);
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
    if (storage != null) {
      await storage!.close();
    }
    // Clean up test database after tests complete
    await cleanupTestDatabase();
  });

  // Create the test suite instance
  final testSuite = ApiChangesNetworkTestSuite(resolveBaseUrl);

  // Get individual test groups for flexible execution
  final testGroups = testSuite.getTestGroups();

  // Execute each test group individually with proper naming
  group(
    'API Changes Network Tests - Basic Operations (IsarStorageService)',
    () {
      testGroups['Basic Operations']!.forEach((testName, testFunction) {
        test(testName, testFunction);
      });
    },
  );

  group('API Changes Network Tests - Error Handling (IsarStorageService)', () {
    testGroups['Error Handling']!.forEach((testName, testFunction) {
      test(testName, testFunction);
    });
  });
}
