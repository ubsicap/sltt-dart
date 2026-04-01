import 'dart:async';

import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart' show Isar;
import 'package:sync_manager/src/models/entity_state_pagination_job.isar.dart';
import 'package:sync_manager/src/models/entity_state_pagination_job_transition_log.isar.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  group('EntityStatePaginationService job persistence', () {
    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    test(
      'initialize() pre-loads persisted jobs into queue without starting processing',
      () async {
        const workspacePrefix = '__test_specific_prefix_initialize_preload';
        await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
          workspacePrefix: workspacePrefix,
        );

        final dio = _buildDeterministicDio();

        // Seed a job via a first-run service.
        final seedService = EntityStatePaginationService(
          baseUrl: 'https://example.invalid',
          dio: dio,
          workspacePrefix: workspacePrefix,
        );
        seedService.enqueueJobFetchEntityStateCollection(
          domainType: 'project',
          domainId: '__test_domain_preload',
          entityType: 'task',
        );
        await Future<void>.delayed(const Duration(milliseconds: 120));
        await seedService.dispose();

        // Simulate app restart: create new service instance and call initialize().
        final service = EntityStatePaginationService(
          baseUrl: 'https://example.invalid',
          dio: dio,
          workspacePrefix: workspacePrefix,
        );

        // Before initialize(), counts should be zero.
        expect(service.queuedCollectionJobCount, 0);

        await service.initialize();

        // After initialize(), the job is in the in-memory queue but processing
        // has NOT started, so it should still be 'queued' in the DB.
        expect(service.queuedCollectionJobCount, 1);
        expect(service.isProcessingEnabled, isFalse);

        // Give a moment to confirm processing does not run spontaneously.
        await Future<void>.delayed(const Duration(milliseconds: 150));
        final jobs = await service.debugListPersistedJobs();
        expect(jobs, hasLength(1));
        expect(jobs.first.status, 'queued');

        await service.dispose();
        await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
          workspacePrefix: workspacePrefix,
        );
      },
    );

    test(
      'startProcessing() after initialize() does not double-load jobs from DB',
      () async {
        const workspacePrefix = '__test_specific_prefix_no_double_load';
        await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
          workspacePrefix: workspacePrefix,
        );

        final dio = _buildDeterministicDio();

        // Seed two jobs.
        final seedService = EntityStatePaginationService(
          baseUrl: 'https://example.invalid',
          dio: dio,
          workspacePrefix: workspacePrefix,
        );
        seedService.enqueueJobFetchEntityStateCollection(
          domainType: 'project',
          domainId: '__test_domain_double_load_A',
          entityType: 'task',
        );
        seedService.enqueueJobFetchEntityStateCollection(
          domainType: 'project',
          domainId: '__test_domain_double_load_B',
          entityType: 'task',
        );
        await Future<void>.delayed(const Duration(milliseconds: 120));
        await seedService.dispose();

        final service = EntityStatePaginationService(
          baseUrl: 'https://example.invalid',
          dio: dio,
          workspacePrefix: workspacePrefix,
        );

        await service.initialize();
        expect(service.queuedCollectionJobCount, 2);

        // startProcessing() must not add duplicate jobs.
        service.startProcessing();
        expect(service.queuedCollectionJobCount, 2);

        await _waitForStatus(service, expectedStatus: 'completed');

        final completedJobs = await service.debugListPersistedJobs();
        // All completed — no duplicates that are still queued.
        expect(completedJobs.where((j) => j.status == 'queued'), isEmpty);

        await service.dispose();
        await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
          workspacePrefix: workspacePrefix,
        );
      },
    );

    test('startProcessing resumes persisted queued jobs', () async {
      const workspacePrefix = '__test_specific_prefix_resume_on_start';
      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: workspacePrefix,
      );

      final dio = _buildDeterministicDio();

      final firstService = EntityStatePaginationService(
        baseUrl: 'https://example.invalid',
        dio: dio,
        workspacePrefix: workspacePrefix,
      );

      firstService.enqueueJobFetchEntityStateCollection(
        domainType: 'project',
        domainId: '__test_domain_resume',
        entityType: 'task',
      );

      await Future<void>.delayed(const Duration(milliseconds: 120));
      final beforeRestartJobs = await firstService.debugListPersistedJobs();
      expect(beforeRestartJobs.length, 1);
      expect(beforeRestartJobs.first.status, 'queued');

      await firstService.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 120));

      final resumedService = EntityStatePaginationService(
        baseUrl: 'https://example.invalid',
        dio: dio,
        workspacePrefix: workspacePrefix,
      );

      resumedService.startProcessing();

      await _waitForStatus(resumedService, expectedStatus: 'completed');

      await resumedService.dispose();
      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: workspacePrefix,
      );
    });

    test('workspace prefix segments persisted jobs', () async {
      const prefixA = '__test_specific_prefix_segmentation_A';
      const prefixB = '__test_specific_prefix_segmentation_B';

      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: prefixA,
      );
      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: prefixB,
      );

      final serviceA = EntityStatePaginationService(
        baseUrl: 'https://example.invalid',
        dio: _buildDeterministicDio(),
        workspacePrefix: prefixA,
      );
      final serviceB = EntityStatePaginationService(
        baseUrl: 'https://example.invalid',
        dio: _buildDeterministicDio(),
        workspacePrefix: prefixB,
      );

      serviceA.enqueueJobFetchEntityStateCollection(
        domainType: 'project',
        domainId: '__test_domain_segmentation',
        entityType: 'task',
      );
      serviceB.enqueueJobFetchEntityStateCollection(
        domainType: 'project',
        domainId: '__test_domain_segmentation',
        entityType: 'task',
      );

      await Future<void>.delayed(const Duration(milliseconds: 120));

      final jobsA = await serviceA.debugListPersistedJobs();
      final jobsB = await serviceB.debugListPersistedJobs();

      expect(jobsA.length, 1);
      expect(jobsB.length, 1);
      expect(jobsA.first.jobKey, jobsB.first.jobKey);
      expect(jobsA.first.status, 'queued');
      expect(jobsB.first.status, 'queued');

      await serviceA.dispose();
      await serviceB.dispose();

      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: prefixA,
      );
      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: prefixB,
      );
    });

    test('job stays fetched until storage completes', () async {
      const workspacePrefix = '__test_specific_prefix_storage_pending';
      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: workspacePrefix,
      );

      final storageCompleter = Completer<void>();
      final service = EntityStatePaginationService(
        baseUrl: 'https://example.invalid',
        dio: _buildDeterministicDio(),
        workspacePrefix: workspacePrefix,
        onStoreFetchedItems:
            ({
              required String domainType,
              required String domainId,
              required String entityType,
              required List<Map<String, dynamic>> items,
              required DateTime storedAt,
            }) async {
              await storageCompleter.future;
            },
      );

      service.startProcessing();
      service.enqueueJobFetchEntityStateCollection(
        domainType: 'project',
        domainId: '__test_domain_storage_pending',
        entityType: 'task',
      );

      await _waitForStatus(service, expectedStatus: 'fetched');
      final fetchedJobs = await service.debugListPersistedJobs();
      expect(fetchedJobs, hasLength(1));
      expect(fetchedJobs.first.completedAt, isNull);
      expect(fetchedJobs.first.fetchedAt, isNotNull);
      expect(fetchedJobs.first.storedAt, isNull);

      storageCompleter.complete();

      await _waitForStatus(service, expectedStatus: 'completed');
      final completedJobs = await service.debugListPersistedJobs();
      expect(completedJobs.first.storedAt, isNotNull);
      expect(completedJobs.first.completedAt, isNotNull);

      await service.dispose();
      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: workspacePrefix,
      );
    });

    test(
      'storage failures are recorded separately from fetch failures',
      () async {
        const workspacePrefix = '__test_specific_prefix_storage_failed';
        await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
          workspacePrefix: workspacePrefix,
        );

        final service = EntityStatePaginationService(
          baseUrl: 'https://example.invalid',
          dio: _buildDeterministicDio(),
          workspacePrefix: workspacePrefix,
          onStoreFetchedItems:
              ({
                required String domainType,
                required String domainId,
                required String entityType,
                required List<Map<String, dynamic>> items,
                required DateTime storedAt,
              }) async {
                throw StateError('intentional storage failure');
              },
        );

        service.startProcessing();
        service.enqueueJobFetchEntityStateCollection(
          domainType: 'project',
          domainId: '__test_domain_storage_failed',
          entityType: 'task',
        );

        await _waitForStatus(service, expectedStatus: 'storage_failed');
        final jobs = await service.debugListPersistedJobs();
        expect(jobs, hasLength(1));
        expect(jobs.first.fetchedAt, isNotNull);
        expect(jobs.first.storedAt, isNull);
        expect(
          jobs.first.storageError,
          contains('intentional storage failure'),
        );
        expect(jobs.first.lastError, contains('intentional storage failure'));

        await service.dispose();
        await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
          workspacePrefix: workspacePrefix,
        );
      },
    );

    test('writes transition log entries for job lifecycle', () async {
      const workspacePrefix = '__test_specific_prefix_transition_lifecycle';
      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: workspacePrefix,
      );

      final service = EntityStatePaginationService(
        baseUrl: 'https://example.invalid',
        dio: _buildDeterministicDio(),
        workspacePrefix: workspacePrefix,
      );

      service.startProcessing();
      final requestKey = service.enqueueJobFetchEntityStateCollection(
        domainType: 'project',
        domainId: '__test_domain_transition_lifecycle',
        entityType: 'task',
      );
      final jobs = await _waitForPersistedJobCount(service, expectedCount: 1);
      final jobKey = jobs.first.jobKey;

      await _waitForStatus(service, expectedStatus: 'completed');
      await _waitForTransitionCount(service, jobKey: jobKey, minCount: 4);

      final transitions = await service.debugListPersistedJobTransitions(
        jobKey: jobKey,
        limit: 50,
      );

      final toStatuses = transitions.map((t) => t.toStatus).toSet();
      expect(
        toStatuses,
        containsAll(<String>['queued', 'active', 'completed']),
      );
      expect(
        transitions.every((t) => t.transitionAt.isBefore(DateTime.now())),
        isTrue,
      );

      // Ensure entries are linkable back to the same persisted job key.
      expect(
        transitions.every((t) => t.jobKey == jobKey),
        isTrue,
        reason: 'transition entries should point back to the owning job',
      );
      expect(requestKey, isNotEmpty);

      await service.dispose();
      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: workspacePrefix,
      );
    });

    test(
      'writes cursor update transition entries for paged collections',
      () async {
        const workspacePrefix = '__test_specific_prefix_transition_cursor';
        await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
          workspacePrefix: workspacePrefix,
        );

        final service = EntityStatePaginationService(
          baseUrl: 'https://example.invalid',
          dio: _buildPaginatedDio(),
          workspacePrefix: workspacePrefix,
        );

        service.startProcessing();
        service.enqueueJobFetchEntityStateCollection(
          domainType: 'project',
          domainId: '__test_domain_transition_cursor',
          entityType: 'task',
        );

        final jobs = await _waitForPersistedJobCount(service, expectedCount: 1);
        final jobKey = jobs.first.jobKey;

        await _waitForStatus(service, expectedStatus: 'completed');
        await _waitForTransitionType(
          service,
          jobKey: jobKey,
          transitionType: 'cursor_update',
        );

        final transitions = await service.debugListPersistedJobTransitions(
          jobKey: jobKey,
          limit: 50,
        );
        final cursorTransitions = transitions
            .where((t) => t.transitionType == 'cursor_update')
            .toList();

        expect(cursorTransitions, isNotEmpty);
        expect(cursorTransitions.any((t) => t.detailsJson != null), isTrue);

        await service.dispose();
        await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
          workspacePrefix: workspacePrefix,
        );
      },
    );
  });
}

Dio _buildDeterministicDio() {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final segments = options.uri.pathSegments;
        final isCollectionRequest =
            segments.isNotEmpty && segments.last == 'tasks';
        if (!isCollectionRequest) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'state': {'entityId': 'single'},
              },
            ),
          );
          return;
        }

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'items': [
                {'entityId': 'item-1'},
              ],
              'hasMore': false,
              'cursor': null,
            },
          ),
        );
      },
    ),
  );
  return dio;
}

Future<void> _waitForStatus(
  EntityStatePaginationService service, {
  required String expectedStatus,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  List<EntityStatePaginationJobRecord> lastJobs = const [];
  while (DateTime.now().isBefore(deadline)) {
    final jobs = await service.debugListPersistedJobs();
    lastJobs = jobs;
    if (jobs.any((job) => job.status == expectedStatus)) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  fail(
    'Timed out waiting for persisted job status: '
    '$expectedStatus. Last jobs: $lastJobs',
  );
}

Future<List<EntityStatePaginationJobRecord>> _waitForPersistedJobCount(
  EntityStatePaginationService service, {
  required int expectedCount,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  List<EntityStatePaginationJobRecord> lastJobs = const [];
  while (DateTime.now().isBefore(deadline)) {
    final jobs = await service.debugListPersistedJobs();
    lastJobs = jobs;
    if (jobs.length >= expectedCount) {
      return jobs;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  fail(
    'Timed out waiting for persisted job count: '
    '$expectedCount. Last jobs: $lastJobs',
  );
}

Future<void> _waitForTransitionCount(
  EntityStatePaginationService service, {
  required String jobKey,
  required int minCount,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  List<EntityStatePaginationJobTransitionLogRecord> lastTransitions = const [];
  while (DateTime.now().isBefore(deadline)) {
    final transitions = await service.debugListPersistedJobTransitions(
      jobKey: jobKey,
      limit: 200,
    );
    lastTransitions = transitions;
    if (transitions.length >= minCount) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  fail(
    'Timed out waiting for transition count >= $minCount '
    'for job=$jobKey. Last transitions: $lastTransitions',
  );
}

Future<void> _waitForTransitionType(
  EntityStatePaginationService service, {
  required String jobKey,
  required String transitionType,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  List<EntityStatePaginationJobTransitionLogRecord> lastTransitions = const [];
  while (DateTime.now().isBefore(deadline)) {
    final transitions = await service.debugListPersistedJobTransitions(
      jobKey: jobKey,
      limit: 200,
    );
    lastTransitions = transitions;
    if (transitions.any((t) => t.transitionType == transitionType)) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  fail(
    'Timed out waiting for transitionType=$transitionType '
    'for job=$jobKey. Last transitions: $lastTransitions',
  );
}

Dio _buildPaginatedDio() {
  final dio = Dio();
  var collectionCallCount = 0;
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final segments = options.uri.pathSegments;
        final isCollectionRequest =
            segments.isNotEmpty && segments.last == 'tasks';
        if (!isCollectionRequest) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'state': {'entityId': 'single'},
              },
            ),
          );
          return;
        }

        collectionCallCount++;
        if (collectionCallCount == 1) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'items': [
                  {'entityId': 'item-1'},
                ],
                'hasMore': true,
                'cursor': 'cursor-1',
              },
            ),
          );
          return;
        }

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'items': [
                {'entityId': 'item-2'},
              ],
              'hasMore': false,
              'cursor': null,
            },
          ),
        );
      },
    ),
  );
  return dio;
}
