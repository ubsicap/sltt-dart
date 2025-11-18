// ignore_for_file: avoid_print

@Tags(['manual', 'benchmark'])
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/passage_translation.entity_state.isar.dart';
import 'package:sync_manager/src/models/portion_translation.entity_state.isar.dart';
import 'package:sync_manager/src/register_entity_states.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  group('Manual Sync Benchmarks', () {
    test(
      'HELLO downsync (portion + passage schemas registered)',
      () async {
        final cloudUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
        final storage = await _createBenchmarkStorage();
        final syncManager = SyncManager.instance;

        addTearDown(() async {
          await syncManager.close();
          await storage.close();
        });

        await syncManager.initialize(
          localStorage: storage,
          closeStorageOnDispose: false,
        );
        syncManager.configureCloudUrl(cloudUrl);

        const projectId = 'HELLO';
        final stopwatch = Stopwatch()..start();
        final downsyncResult = await syncManager.downsyncFromCloud(
          domainIds: const [projectId],
        );
        stopwatch.stop();

        final totalChanges = _countChanges(downsyncResult.projectCursorChanges);
        final processedStates = _countProcessed(
          downsyncResult.storageSummaries,
        );
        final portionStates = await storage.getEntityStates(
          domainType: 'project',
          domainId: projectId,
          entityType: kEntityTypePortion,
          limit: 200000,
        );
        final passageStates = await storage.getEntityStates(
          domainType: 'project',
          domainId: projectId,
          entityType: kEntityTypePassage,
          limit: 200000,
        );

        _printSummary(
          cloudUrl: cloudUrl,
          projectId: projectId,
          duration: stopwatch.elapsed,
          result: downsyncResult,
          totalChanges: totalChanges,
          processedStates: processedStates,
          portionCount: (portionStates['items'] as List<dynamic>?)?.length ?? 0,
          passageCount: (passageStates['items'] as List<dynamic>?)?.length ?? 0,
          databasePath: storage.databasePath?.toString() ?? 'unknown',
        );

        expect(downsyncResult.success, isTrue, reason: downsyncResult.message);
      },
      timeout: Timeout.none,
    );
  });
}

Future<IsarStorageService> _createBenchmarkStorage() async {
  const dbName = 'manual_sync_benchmark';
  await IsarStorageService.deleteDatabaseFiles(dbName);
  final storage = IsarStorageService(dbName, 'ManualSyncBench');

  final schemas = <CollectionSchema>[
    ...entityStateSchemas,
    IsarPortionDataEntityStateSchema,
    IsarPassageDataEntityStateSchema,
  ];

  await storage.initialize(
    providedEntityStateSchemas: schemas,
    registerStorageGroups: (registry, isar) {
      registerIsarPortionDataEntityStateStorageGroup(registry, isar);
      registerIsarPassageDataEntityStateStorageGroup(registry, isar);
    },
  );

  return storage;
}

int _countChanges(ProjectCursorChanges cursorChanges) {
  return cursorChanges.values.fold<int>(0, (sum, batch) => sum + batch.length);
}

int _countProcessed(StorageSummaries storageSummaries) {
  return storageSummaries.values.fold<int>(
    0,
    (sum, summary) => sum + (summary?.processed.length ?? 0),
  );
}

void _printSummary({
  required String cloudUrl,
  required String projectId,
  required Duration duration,
  required DownsyncResult result,
  required int totalChanges,
  required int processedStates,
  required int portionCount,
  required int passageCount,
  required String databasePath,
}) {
  final buffer = StringBuffer()
    ..writeln('--- Manual HELLO Downsync Benchmark ---')
    ..writeln('Cloud URL        : $cloudUrl')
    ..writeln('Project          : $projectId')
    ..writeln('Duration         : ${duration.inMilliseconds} ms')
    ..writeln('Batches          : ${result.projectCursorChanges.length}')
    ..writeln('Changes downloaded: $totalChanges')
    ..writeln('States processed : $processedStates')
    ..writeln('Portions stored  : $portionCount')
    ..writeln('Passages stored  : $passageCount')
    ..writeln('DB path          : $databasePath')
    ..writeln('Message          : ${result.message}')
    ..writeln('Success          : ${result.success}');

  if (result.error != null) {
    buffer
      ..writeln('Error            : ${result.error}')
      ..writeln('Stack            : ${result.errorStackTrace}');
  }

  if (result.storageSummaries.values.any((s) => (s?.errors ?? []).isNotEmpty)) {
    final errorSummaries = result.storageSummaries.entries
        .map((entry) {
          final summary = entry.value;
          final errors = summary?.errors ?? const [];
          return '${entry.key}: ${errors.length} errors';
        })
        .join(', ');
    buffer.writeln('Storage errors   : $errorSummaries');
  }

  print(buffer.toString());
}
