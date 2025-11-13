@Tags(['network'])
// NOTE: This Dynamo test runner should call individual tests from
// `packages/sltt_core/test/helpers/api_changes_network_suite.dart` rather
// than duplicating test logic. When you add a new GET /api/state test,
// register it in the suite and call it from both this file and the
// Isar/network test so all backends exercise the same behavior.
import 'dart:async';
import 'dart:io';

import 'package:aws_backend/src/models/dynamo_change_log_entry.dart'
    show dynamoChangeLogEntryFactoryRegistration;
import 'package:aws_backend/src/storage/dynamodb_storage_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import '../../sltt_core/test/helpers/api_changes_network_suite.dart'
    show ApiChangesNetworkTestSuite;
import 'helpers/test_utils.dart' show resetTestProject;

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
  DynamoDBStorageService? storage;
  const testTableName = 'test_local_api_state_dynamo';

  Future<Uri> resolveBaseUrl() async {
    // Use a completer to serialize initialization and avoid double-starting
    // the server if multiple tests call resolveBaseUrl concurrently.
    if (baseUrlCompleter != null) return baseUrlCompleter!.future;
    if (baseUrl != null) return baseUrl!;
    baseUrlCompleter = Completer<Uri>();
    final externalApiBaseUrl =
        Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
    if (externalApiBaseUrl.isNotEmpty) {
      baseUrl = Uri.parse(externalApiBaseUrl);
      return baseUrl!;
    }

    // Create DynamoDBStorageService pointing at a local DynamoDB instance
    final localEndpoint =
        Platform.environment['LOCAL_DYNAMO_ENDPOINT'] ??
        'http://localhost:8080';

    storage = DynamoDBStorageService(
      tableName: testTableName,
      useLocalDynamoDB: true,
      localEndpoint: localEndpoint,
    );

    // Initialize will create the table if it doesn't exist when useLocalDynamoDB=true
    await storage!.initialize();

    final app = TestServer(serverName: 'dynamo-state-it', storage: storage!);
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
    // register DynamoChangeLogEntry factory for api models usage
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

  group('Dynamo API State Network Tests (Individual Test Groups)', () {
    // Run individual test groups with proper naming
    group('GET /api/state', () {
      late ApiChangesNetworkTestSuite suite;
      late Map<
        String,
        Future<void> Function({
          FutureOr<void> Function(String domainId)? setup,
          FutureOr<void> Function(String domainId)? tearDown,
        })
      >
      stateTests;

      setUp(() async {
        suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final testGroups = suite.getTestGroups();
        stateTests = testGroups['GET /api/state']!;
      });

      test('returns empty list for entityCollection with no states', () async {
        await stateTests['returns empty list for entityCollection with no states']!(
          setup: (String domainId) async {
            final base = await resolveBaseUrl();
            await resetTestProject(base, domainId);
          },
        );
      });

      test(
        'returns seeded entity state by entityCollection and entityId',
        () async {
          await stateTests['returns seeded entity state by entityCollection and entityId']!(
            setup: (String domainId) async {
              final base = await resolveBaseUrl();
              await resetTestProject(base, domainId);
            },
          );
        },
      );

      test('filters by parentId when parameter is provided', () async {
        await stateTests['filters by parentId when parameter is provided']!(
          setup: (String domainId) async {
            final base = await resolveBaseUrl();
            await resetTestProject(base, domainId);
          },
        );
      });

      test('filters by storedAfter timestamp', () async {
        await stateTests['filters by storedAfter timestamp']!(
          setup: (String domainId) async {
            final base = await resolveBaseUrl();
            await resetTestProject(base, domainId);
          },
        );
      });

      test('storedAfter + pagination returns correct filtered page', () async {
        await stateTests['storedAfter + pagination returns correct filtered page']!(
          setup: (String domainId) async {
            final base = await resolveBaseUrl();
            await resetTestProject(base, domainId);
          },
        );
      });

      test('storedAfter with old timestamp returns all items', () async {
        await stateTests['storedAfter with old timestamp returns all items']!(
          setup: (String domainId) async {
            final base = await resolveBaseUrl();
            await resetTestProject(base, domainId);
          },
        );
      });

      test('storedAfter with future timestamp returns empty', () async {
        await stateTests['storedAfter with future timestamp returns empty']!(
          setup: (String domainId) async {
            final base = await resolveBaseUrl();
            await resetTestProject(base, domainId);
          },
        );
      });
    });

    // Verification test to ensure all suite tests are being run
    test(
      'verifies all suite tests are being run (DynamoDBStorageService)',
      () async {
        final suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
        final allSuiteTests = suite.getTestGroups();

        // Extract tests from the 'GET /api/state' group
        final stateGroupTests = allSuiteTests['GET /api/state'] ?? {};

        // List of all test names that this file actually runs
        final actuallyRunTestNames = {
          'returns empty list for entityCollection with no states',
          'returns seeded entity state by entityCollection and entityId',
          'filters by parentId when parameter is provided',
          'filters by storedAfter timestamp',
          'storedAfter + pagination returns correct filtered page',
          'storedAfter with old timestamp returns all items',
          'storedAfter with future timestamp returns empty',
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
      },
    );
  });
}
