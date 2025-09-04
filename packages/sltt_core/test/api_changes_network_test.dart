@Tags(['network'])
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'helpers/api_changes_network_suite.dart';
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
        (entry) => (entry as TestChangeLogEntry).toJsonBase(),
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

  group('API Changes Network Tests (Individual Test Groups)', () {
    // Run individual test groups with proper naming
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
    });

    group('GET /api/projects/<projectId>/changes', () {
      late ApiChangesNetworkTestSuite suite;
      late Map<String, Future<void> Function()> getTests;

      setUp(() async {
        suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final testGroups = suite.getTestGroups();
        getTests = testGroups['GET /api/projects/<projectId>/changes']!;
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

    test('verifies all suite tests are being run', () async {
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
  });
}
