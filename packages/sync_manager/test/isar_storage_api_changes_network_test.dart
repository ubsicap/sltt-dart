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

  // Option 1: Run all tests automatically (recommended for full coverage)
  // testSuite.runAllTestsWithPrefix('API Changes Network Tests (IsarStorageService)');

  // Option 2: Run specific groups with automatic test discovery
  final availableGroups = testSuite.getTestGroupNames();
  print('Available test groups: $availableGroups'); // Helpful for debugging

  // Execute each test group individually with proper naming
  group(
    'API Changes Network Tests - POST /api/changes (IsarStorageService)',
    () {
      final tests = testSuite.getTestsForGroup('POST /api/changes');
      tests.forEach((testName, testFunction) {
        test(testName, testFunction);
      });
    },
  );

  group(
    'API Changes Network Tests - GET /api/projects/<projectId>/changes (IsarStorageService)',
    () {
      final tests = testSuite.getTestsForGroup(
        'GET /api/projects/<projectId>/changes',
      );
      tests.forEach((testName, testFunction) {
        test(testName, testFunction);
      });
    },
  );

  group(
    'API Changes Network Tests - POST /api/changes semantics (IsarStorageService)',
    () {
      final tests = testSuite.getTestsForGroup('POST /api/changes semantics');
      tests.forEach((testName, testFunction) {
        test(testName, testFunction);
      });
    },
  );

  group(
    'API Changes Network Tests - POST /api/changes srcStorageType/srcStorageId combinations (IsarStorageService)',
    () {
      final tests = testSuite.getTestsForGroup(
        'POST /api/changes srcStorageType/srcStorageId combinations',
      );
      tests.forEach((testName, testFunction) {
        test(testName, testFunction);
      });
    },
  );

  // Verification test to ensure all suite tests are being run
  test('verifies all suite tests are being run (IsarStorageService)', () async {
    final suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
    final allSuiteTests = suite.getTestGroups();

    // Flatten all test names from the suite
    final suiteTestNames = <String>{};
    for (final groupEntry in allSuiteTests.entries) {
      for (final testName in groupEntry.value.keys) {
        suiteTestNames.add(testName);
      }
    }

    // List of all test names that this file actually runs
    // This should match the suiteTestNames set
    final actuallyRunTestNames = {
      'with includeChangeUpdates/includeStateUpdates returns summaries',
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
    };

    // Check that we have the same number of tests
    expect(
      actuallyRunTestNames.length,
      equals(suiteTestNames.length),
      reason:
          'Number of tests in file (${actuallyRunTestNames.length}) '
          'does not match suite (${suiteTestNames.length})',
    );

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
}
