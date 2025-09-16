@Tags(['network'])
// NOTE: This Isar test runner should call individual tests from
// `packages/sltt_core/test/helpers/api_changes_network_suite.dart` rather
// than duplicating test logic. When you add a new GET /api/state test,
// register it in the suite and call it from both this file and
// `packages/sltt_core/test/api_state_network_test.dart` so all backends
// exercise the same behavior.
import 'dart:async';
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
  Completer<Uri>? baseUrlCompleter;
  IsarStorageService? storage;
  const testDbName = 'test_local_api_state';

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
    // Use a completer to serialize initialization and avoid double-starting
    // the server if multiple tests call resolveBaseUrl concurrently.
    // If a previous init is in progress, await its completion.
    // This also ensures the Isar DB is initialized exactly once per test run.
    if (baseUrlCompleter != null) return baseUrlCompleter!.future;
    if (baseUrl != null) return baseUrl!;
    baseUrlCompleter = Completer<Uri>();
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
    final app = TestServer(
      serverName: 'sync-manager-state-it',
      storage: storage!,
    );
    final handler = const Pipeline().addHandler(app.router().call);
    server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 0);
    baseUrl = Uri.parse('http://localhost:${server!.port}');
    // Complete the completer so any concurrent callers can proceed
    baseUrlCompleter!.complete(baseUrl);
    final result = baseUrl!;
    baseUrlCompleter = null;
    return result;
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

  group('API State Network Tests (Individual Test Groups)', () {
    // Run individual test groups with proper naming
    // NOTE: When adding new GET /api/state tests, register them in
    // `packages/sltt_core/test/helpers/api_changes_network_suite.dart` and
    // add a corresponding `test()` call in this file and
    // `packages/sltt_core/test/api_state_network_test.dart` so all
    // storage backends execute the same behavior.
    group('GET /api/state', () {
      late ApiChangesNetworkTestSuite suite;
      late Map<String, Future<void> Function()> stateTests;

      setUp(() async {
        suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final testGroups = suite.getTestGroups();
        stateTests = testGroups['GET /api/state']!;
      });

      test('returns empty list for entityCollection with no states', () async {
        await stateTests['returns empty list for entityCollection with no states']!();
      });

      test(
        'returns seeded entity state by entityCollection and entityId',
        () async {
          await stateTests['returns seeded entity state by entityCollection and entityId']!();
        },
      );

      test('filters by parentId when parameter is provided', () async {
        await stateTests['filters by parentId when parameter is provided']!();
      });
    });

    // Verification test to ensure all suite tests are being run
    test('verifies all suite tests are being run (IsarStorageService)', () async {
      final suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
      final allSuiteTests = suite.getTestGroups();

      // Extract tests from the 'GET /api/state' group
      final stateGroupTests = allSuiteTests['GET /api/state'] ?? {};

      // List of all test names that this file actually runs
      final actuallyRunTestNames = {
        'returns empty list for entityCollection with no states',
        'returns seeded entity state by entityCollection and entityId',
        'filters by parentId when parameter is provided',
      };

      // Sort both sets for consistent comparison
      final sortedSuiteTests = stateGroupTests.keys.toList()..sort();
      final sortedRunTests = actuallyRunTestNames.toList()..sort();

      // Check that the test lists match exactly
      expect(
        sortedRunTests,
        equals(sortedSuiteTests),
        reason:
            'Test names in file do not match suite tests.\n'
            'Suite tests: $sortedSuiteTests\n'
            'File tests: $sortedRunTests\n'
            'Missing from file: ${stateGroupTests.keys.toSet().difference(actuallyRunTestNames)}\n'
            'Extra in file: ${actuallyRunTestNames.difference(stateGroupTests.keys.toSet())}',
      );
    });
  });
}
