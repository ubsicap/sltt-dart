import 'dart:async';

import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart' show Isar;
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  group('EntityStatePaginationService job persistence', () {
    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

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
      expect(beforeRestartJobs.first['status'], 'queued');

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
      expect(jobsA.first['jobKey'], jobsB.first['jobKey']);
      expect(jobsA.first['status'], 'queued');
      expect(jobsB.first['status'], 'queued');

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
      expect(fetchedJobs.first['completedAt'], isNull);
      expect(fetchedJobs.first['fetchedAt'], isNotNull);
      expect(fetchedJobs.first['storedAt'], isNull);

      storageCompleter.complete();

      await _waitForStatus(service, expectedStatus: 'completed');
      final completedJobs = await service.debugListPersistedJobs();
      expect(completedJobs.first['storedAt'], isNotNull);
      expect(completedJobs.first['completedAt'], isNotNull);

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
        expect(jobs.first['fetchedAt'], isNotNull);
        expect(jobs.first['storedAt'], isNull);
        expect(
          jobs.first['storageError'],
          contains('intentional storage failure'),
        );
        expect(
          jobs.first['lastError'],
          contains('intentional storage failure'),
        );

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
  List<Map<String, dynamic>> lastJobs = const [];
  while (DateTime.now().isBefore(deadline)) {
    final jobs = await service.debugListPersistedJobs();
    lastJobs = jobs;
    if (jobs.any((job) => job['status'] == expectedStatus)) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  fail(
    'Timed out waiting for persisted job status: '
    '$expectedStatus. Last jobs: $lastJobs',
  );
}
