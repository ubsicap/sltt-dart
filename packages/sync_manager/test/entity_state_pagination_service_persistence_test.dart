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

      firstService.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 120));

      final resumedService = EntityStatePaginationService(
        baseUrl: 'https://example.invalid',
        dio: dio,
        workspacePrefix: workspacePrefix,
      );

      resumedService.startProcessing();

      await _waitForStatus(resumedService, expectedStatus: 'completed');

      resumedService.dispose();
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

      serviceA.dispose();
      serviceB.dispose();

      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: prefixA,
      );
      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: prefixB,
      );
    });
  });
}

Dio _buildDeterministicDio() {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final path = options.path;
        if (path.contains('/api/state/') && !path.endsWith('/task')) {
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
  while (DateTime.now().isBefore(deadline)) {
    final jobs = await service.debugListPersistedJobs();
    if (jobs.isNotEmpty && jobs.first['status'] == expectedStatus) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  fail('Timed out waiting for persisted job status: $expectedStatus');
}
