@Tags(['network'])
// NOTE: This Dynamo test runner should call individual tests from
// `packages/sltt_core/test/helpers/api_changes_network_suite.dart` rather
// than duplicating test logic. When you add a new API changes/stats test,
// register it in the suite and call it from this file plus the Isar/core
// runners so all backends exercise the same behavior.
import 'dart:async';
import 'dart:io';

import 'package:aws_backend/src/models/dynamo_change_log_entry.dart'
    show dynamoChangeLogEntryFactoryRegistration;
import 'package:aws_backend/src/storage/dynamodb_storage_service.dart';
import 'package:aws_common/aws_common.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import '../../sltt_core/test/helpers/api_changes_network_suite.dart'
    show ApiChangesNetworkTestSuite;
import 'helpers/test_utils.dart' show resetTestDomainData;

class TestServer extends BaseRestApiServer {
  TestServer({
    required super.serverName,
    required super.storage,
    required super.mediaStorage,
  });

  @override
  String get storageTypeDescription => storage.getStorageType();

  // Expose a public method that internally calls the protected buildRouter
  Router router() => buildRouter();
}

void main() {
  HttpServer? server;
  Uri? baseUrl;
  Completer<Uri>? baseUrlCompleter;
  DynamoDBStorageService? storage;
  const testTableName = 'test_local_api_changes_dynamo';

  Future<Uri> resolveBaseUrl() async {
    // Use a completer to serialize initialization and avoid double-starting
    // the server if multiple tests call resolveBaseUrl concurrently.
    if (baseUrlCompleter != null) return baseUrlCompleter!.future;
    if (baseUrl != null) return baseUrl!;

    // If an external base URL is provided via environment (or the constant),
    // use it and return synchronously. Do NOT create the completer in that
    // case because callers that return the completer's future would hang.
    final externalApiBaseUrl =
        Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
    if (externalApiBaseUrl.isNotEmpty) {
      baseUrl = Uri.parse(externalApiBaseUrl);
      return baseUrl!;
    }

    // Create DynamoDBStorageService pointing at a local DynamoDB instance.
    final localEndpoint =
        Platform.environment['LOCAL_DYNAMO_ENDPOINT'] ??
        'http://localhost:8080';

    storage = DynamoDBStorageService(
      tableName: testTableName,
      useLocalDynamoDB: true,
      localEndpoint: localEndpoint,
      credentials: const AWSCredentials(
        'test-key',
        'test-secret',
        'test-token',
      ),
    );

    await storage!.initialize();

    // Now we will actually start the local server; create the completer so
    // concurrent callers can await the same initialization.
    baseUrlCompleter = Completer<Uri>();

    final app = TestServer(
      serverName: 'dynamo-changes-it',
      storage: storage!,
      mediaStorage: NullMediaStorage(),
    );
    final handler = const Pipeline().addHandler(app.router().call);
    server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 0);
    baseUrl = Uri.parse('http://localhost:${server!.port}');
    baseUrlCompleter!.complete(baseUrl);
    final result = baseUrl!;
    baseUrlCompleter = null;
    return result;
  }

  Future<void> resetDomain(String domainId) async {
    final base = await resolveBaseUrl();
    await resetTestDomainData(base, domainId);
  }

  setUpAll(() async {
    // Register DynamoChangeLogEntry factory for api models usage.
    dynamoChangeLogEntryFactoryRegistration;
  });

  tearDownAll(() async {
    if (server != null) {
      await server!.close(force: true);
    }
    if (storage != null) {
      await storage!.close();
    }
  });

  group('Dynamo API Changes Network Tests (Individual Test Groups)', () {
    group('POST /api/changes', () {
      late ApiChangesNetworkTestSuite suite;
      late Map<
        String,
        Future<void> Function({
          FutureOr<void> Function(String domainId)? setup,
          FutureOr<void> Function(String domainId)? tearDown,
        })
      >
      postTests;

      setUp(() async {
        suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final testGroups = suite.getTestGroups();
        postTests = testGroups['POST /api/changes']!;
      });

      test(
        'with includeChangeUpdates/includeStateUpdates returns summaries',
        () async {
          await postTests['with includeChangeUpdates/includeStateUpdates returns summaries']!(
            setup: resetDomain,
          );
        },
      );

      test(
        'domain-isolated entity ids: same entityId in different domainIds stays create',
        () async {
          await postTests['domain-isolated entity ids: same entityId in different domainIds stays create']!(
            setup: resetDomain,
          );
        },
      );

      test(
        'save mode: returns error when summary has errors (returnErrorIfInResultsSummary=true)',
        () async {
          await postTests['save mode: returns error when summary has errors (returnErrorIfInResultsSummary=true)']!(
            setup: resetDomain,
          );
        },
      );

      test(
        'sync mode: returns success with errors in summary (returnErrorIfInResultsSummary=false)',
        () async {
          await postTests['sync mode: returns success with errors in summary (returnErrorIfInResultsSummary=false)']!(
            setup: resetDomain,
          );
        },
      );
    });

    group('GET /api/changes/{domainCollection}/{domainId}', () {
      late ApiChangesNetworkTestSuite suite;
      late Map<
        String,
        Future<void> Function({
          FutureOr<void> Function(String domainId)? setup,
          FutureOr<void> Function(String domainId)? tearDown,
        })
      >
      getTests;

      setUp(() async {
        suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final testGroups = suite.getTestGroups();
        getTests =
            testGroups['GET /api/changes/{domainCollection}/{domainId}']!;
      });

      test('returns empty list for project with no changes', () async {
        await getTests['returns empty list for project with no changes']!(
          setup: resetDomain,
        );
      });

      test('returns changes for project with seeded data', () async {
        await getTests['returns changes for project with seeded data']!(
          setup: resetDomain,
        );
      });

      test('respects limit parameter', () async {
        await getTests['respects limit parameter']!(setup: resetDomain);
      });

      test('supports cursor-based pagination', () async {
        await getTests['supports cursor-based pagination']!(setup: resetDomain);
      });

      test('handles URL-encoded project IDs correctly', () async {
        await getTests['handles URL-encoded project IDs correctly']!(
          setup: resetDomain,
        );
      });

      test('returns 400 for invalid limit values', () async {
        await getTests['returns 400 for invalid limit values']!(
          setup: resetDomain,
        );
      });

      test('returns 400 for invalid cursor values', () async {
        await getTests['returns 400 for invalid cursor values']!(
          setup: resetDomain,
        );
      });
    });

    group('POST /api/changes semantics', () {
      late ApiChangesNetworkTestSuite suite;
      late Map<
        String,
        Future<void> Function({
          FutureOr<void> Function(String domainId)? setup,
          FutureOr<void> Function(String domainId)? tearDown,
        })
      >
      semanticsTests;

      setUp(() async {
        suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final testGroups = suite.getTestGroups();
        semanticsTests = testGroups['POST /api/changes semantics']!;
      });

      test(
        'handles field-level conflict resolution (newer change wins)',
        () async {
          await semanticsTests['handles field-level conflict resolution (newer change wins)']!(
            setup: resetDomain,
          );
        },
      );
    });

    group('POST /api/changes srcStorageType/srcStorageId combinations', () {
      late ApiChangesNetworkTestSuite suite;
      late Map<
        String,
        Future<void> Function({
          FutureOr<void> Function(String domainId)? setup,
          FutureOr<void> Function(String domainId)? tearDown,
        })
      >
      combinationsTests;

      setUp(() async {
        suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final testGroups = suite.getTestGroups();
        combinationsTests =
            testGroups['POST /api/changes srcStorageType/srcStorageId combinations']!;
      });

      test(
        'srcStorageType: local, srcStorageId: matches server storage id',
        () async {
          await combinationsTests['srcStorageType: local, srcStorageId: matches server storage id']!(
            setup: resetDomain,
          );
        },
      );

      test(
        'srcStorageType: local, srcStorageId: different from server',
        () async {
          await combinationsTests['srcStorageType: local, srcStorageId: different from server']!(
            setup: resetDomain,
          );
        },
      );

      test('srcStorageType: cloud, srcStorageId: cloud', () async {
        await combinationsTests['srcStorageType: cloud, srcStorageId: cloud']!(
          setup: resetDomain,
        );
      });
    });

    group('GET /api/stats/{domainCollection}/{domainId}', () {
      late ApiChangesNetworkTestSuite suite;
      late Map<
        String,
        Future<void> Function({
          FutureOr<void> Function(String domainId)? setup,
          FutureOr<void> Function(String domainId)? tearDown,
        })
      >
      statsTests;

      setUp(() async {
        suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final testGroups = suite.getTestGroups();
        statsTests =
            testGroups['GET /api/stats/{domainCollection}/{domainId}']!;
      });

      test('includes entityTypeCollections for known entityType', () async {
        await statsTests['includes entityTypeCollections for known entityType']!(
          setup: resetDomain,
        );
      });

      test(
        'includes entityTypeCollections unknown for unknown entityType',
        () async {
          await statsTests['includes entityTypeCollections unknown for unknown entityType']!(
            setup: resetDomain,
          );
        },
      );

      test(
        'entityTypeStats latestSeq is independent from latestChangeAt',
        () async {
          await statsTests['entityTypeStats latestSeq is independent from latestChangeAt']!(
            setup: resetDomain,
          );
        },
      );
    });

    // Verification test to ensure all non-state suite tests are being run.
    test(
      'verifies all suite tests are being run (DynamoDBStorageService changes)',
      () async {
        final suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final allSuiteTests = suite.getTestGroups();

        final suiteTestNames = <String>{};
        for (final groupEntry in allSuiteTests.entries) {
          // State tests are exercised in dynamo_storage_api_state_network_test.dart.
          if (groupEntry.key == 'GET /api/state') continue;
          for (final testName in groupEntry.value.keys) {
            suiteTestNames.add(testName);
          }
        }

        final actuallyRunTestNames = {
          'with includeChangeUpdates/includeStateUpdates returns summaries',
          'domain-isolated entity ids: same entityId in different domainIds stays create',
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
          'includes entityTypeCollections for known entityType',
          'includes entityTypeCollections unknown for unknown entityType',
          'entityTypeStats latestSeq is independent from latestChangeAt',
        };

        final sortedSuiteTests = suiteTestNames.toList()..sort();
        final sortedRunTests = actuallyRunTestNames.toList()..sort();

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
      },
    );
  });
}
