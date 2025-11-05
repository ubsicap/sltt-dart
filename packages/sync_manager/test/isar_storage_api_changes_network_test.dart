@Tags(['network'])
// NOTE: This Isar test runner should call individual tests from
// `packages/sltt_core/test/helpers/api_changes_network_suite.dart` rather
// than duplicating test logic. When you add a new POST /api/changes test,
// register it in the suite and call it from both this file and
// `packages/sltt_core/test/api_changes_network_test.dart` so all backends
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
  const testDbName = 'test_local_api_changes';

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

    // Create IsarStorageService with a consistent test database name
    storage = IsarStorageService(testDbName, 'TestLocalStorage');
    // Clean up any existing test database first
    await storage!.deleteDatabase();
    await storage!.initialize();
    final app = TestServer(serverName: 'sync-manager-it', storage: storage!);
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

  setUp(() async {
    // Ensure the server is started and baseUrl is available before each test
    await resolveBaseUrl();
  });

  tearDownAll(() async {
    if (server != null) {
      await server!.close(force: true);
    }
    if (storage != null) {
      await storage!.close();
    }
  });

  // Create the test suite instance
  final testSuite = ApiChangesNetworkTestSuite(resolveBaseUrl);

  // Option 1: Run all tests automatically (recommended for full coverage)
  // testSuite.runAllTestsWithPrefix('API Changes Network Tests (IsarStorageService)');

  // Option 2: Run specific groups with automatic test discovery
  final availableGroups = testSuite.getTestGroupNames();
  SlttLogger.logger.info(
    'Available test groups: $availableGroups',
  ); // Helpful for debugging

  group('API Changes Network Tests (Individual Test Groups)', () {
    // Run individual test groups with proper naming
    // NOTE: When adding new POST /api/changes tests, register them in
    // `packages/sltt_core/test/helpers/api_changes_network_suite.dart` and
    // add a corresponding `test()` call in this file and
    // `packages/sltt_core/test/api_changes_network_test.dart` so all
    // storage backends execute the same behavior.
    group('POST /api/changes', () {
      late ApiChangesNetworkTestSuite suite;
      late Map<String, Future<void> Function()> postTests;

      setUp(() async {
        suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final testGroups = suite.getTestGroups();
        postTests = testGroups['POST /api/changes']!;
      });

      test(
        'with includeChangeUpdates/includeStateUpdates returns summaries',
        () async {
          await postTests['with includeChangeUpdates/includeStateUpdates returns summaries']!();
        },
      );

      test(
        'save mode: returns error when summary has errors (returnErrorIfInResultsSummary=true)',
        () async {
          await postTests['save mode: returns error when summary has errors (returnErrorIfInResultsSummary=true)']!();
        },
      );

      test(
        'sync mode: returns success with errors in summary (returnErrorIfInResultsSummary=false)',
        () async {
          await postTests['sync mode: returns success with errors in summary (returnErrorIfInResultsSummary=false)']!();
        },
      );
    });

    group('GET /api/changes/{domainCollection}/{domainId}', () {
      late ApiChangesNetworkTestSuite suite;
      late Map<String, Future<void> Function()> getTests;

      setUp(() async {
        suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final testGroups = suite.getTestGroups();
        getTests =
            testGroups['GET /api/changes/{domainCollection}/{domainId}']!;
      });

      test('returns empty list for project with no changes', () async {
        await getTests['returns empty list for project with no changes']!();
      });

      test('returns changes for project with seeded data', () async {
        await getTests['returns changes for project with seeded data']!();
      });

      test('respects limit parameter', () async {
        await getTests['respects limit parameter']!();
      });

      test('supports cursor-based pagination', () async {
        await getTests['supports cursor-based pagination']!();
      });

      test('handles URL-encoded project IDs correctly', () async {
        await getTests['handles URL-encoded project IDs correctly']!();
      });

      test('returns 400 for invalid limit values', () async {
        await getTests['returns 400 for invalid limit values']!();
      });

      test('returns 400 for invalid cursor values', () async {
        await getTests['returns 400 for invalid cursor values']!();
      });
    });

    group('POST /api/changes semantics', () {
      late ApiChangesNetworkTestSuite suite;
      late Map<String, Future<void> Function()> semanticsTests;

      setUp(() async {
        suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final testGroups = suite.getTestGroups();
        semanticsTests = testGroups['POST /api/changes semantics']!;
      });

      test(
        'handles field-level conflict resolution (newer change wins)',
        () async {
          await semanticsTests['handles field-level conflict resolution (newer change wins)']!();
        },
      );
    });

    group('POST /api/changes srcStorageType/srcStorageId combinations', () {
      late ApiChangesNetworkTestSuite suite;
      late Map<String, Future<void> Function()> combinationsTests;

      setUp(() async {
        suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final testGroups = suite.getTestGroups();
        combinationsTests =
            testGroups['POST /api/changes srcStorageType/srcStorageId combinations']!;
      });

      test(
        'srcStorageType: local, srcStorageId: matches server storage id',
        () async {
          await combinationsTests['srcStorageType: local, srcStorageId: matches server storage id']!();
        },
      );

      test(
        'srcStorageType: local, srcStorageId: different from server',
        () async {
          await combinationsTests['srcStorageType: local, srcStorageId: different from server']!();
        },
      );

      test('srcStorageType: cloud, srcStorageId: cloud', () async {
        await combinationsTests['srcStorageType: cloud, srcStorageId: cloud']!();
      });
    });

    // GET /api/state tests are exercised in the dedicated
    // `isar_storage_api_state_network_test.dart` runner to avoid running
    // duplicate state tests across multiple test files. See that file for
    // the per-backend state tests which call into the shared suite.

    // The returnErrorIfInResultsSummary behaviors are covered by the
    // 'POST /api/changes' group above which calls the centralized suite
    // entries. Removing the duplicate group prevents test duplication.

    // Verification test to ensure all suite tests are being run
    test('verifies all suite tests are being run (IsarStorageService)', () async {
      final suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
      final allSuiteTests = suite.getTestGroups();

      // Flatten all test names from the suite
      final suiteTestNames = <String>{};
      for (final groupEntry in allSuiteTests.entries) {
        // skip state tests as they are run in a different file
        if (groupEntry.key == 'GET /api/state') continue;
        for (final testName in groupEntry.value.keys) {
          suiteTestNames.add(testName);
        }
      }

      // List of all test names that this file actually runs
      // This should match the suiteTestNames set
      final actuallyRunTestNames = {
        'with includeChangeUpdates/includeStateUpdates returns summaries',
        'save mode: returns error when summary has errors (returnErrorIfInResultsSummary=true)',
        'sync mode: returns success with errors in summary (returnErrorIfInResultsSummary=false)',
        'returns empty list for project with no changes',
        'returns changes for project with seeded data',
        'respects limit parameter',
        'supports cursor-based pagination',
        'handles URL-encoded project IDs correctly',
        'returns 400 for invalid limit values',
        'returns 400 for invalid cursor values',
        'handles field-level conflict resolution (newer change wins)',
        'srcStorageType: local, srcStorageId: matches server storage id',
        'srcStorageType: local, srcStorageId: different from server',
        'srcStorageType: cloud, srcStorageId: cloud',
        // State-specific tests are exercised in
        // `isar_storage_api_state_network_test.dart` to avoid duplication.
      };

      // Sort both sets for consistent comparison
      final sortedSuiteTests = suiteTestNames.toList()..sort();
      final sortedRunTests = actuallyRunTestNames.toList()..sort();

      // Check that the test lists match exactly
      expect(
        sortedRunTests,
        equals(sortedSuiteTests),
        reason:
            'Test names in file do not match suite tests.\n'
            'Suite tests: $sortedSuiteTests\n'
            'File tests: $sortedRunTests\n'
            'Missing from file: ${suiteTestNames.difference(actuallyRunTestNames)}\n'
            'Extra in file: ${actuallyRunTestNames.difference(suiteTestNames)}',
      );
    });
  });
}
