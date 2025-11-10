// ignore_for_file: avoid_print
import 'dart:io';

import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:aws_backend/src/models/passage_translation.data.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'helpers/test_utils.dart';

/// Manual benchmark tests for cloud AWS REST API using saveChanges helper.
/// Run with:
///   dart test packages/aws_backend/test/manual_cloud_aws_rest_api_benchmarks.dart
/// Ensure CLOUD_BASE_URL env var points to target server (defaults to dev URL).
void main() {
  final baseUrl = Uri.parse(
    Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl,
  );

  group('Manual Cloud REST API Benchmarks - PassageTranslationData', () {
    const projectId = '__test_benchmark_passages__';
    const domainType = 'project';
    const parentId = 'root';
    const parentProp = 'passages';

    setUpAll(() async {
      dynamoChangeLogEntryFactoryRegistration;
      // Reset project domain so benchmark starts clean
      await resetTestProject(baseUrl, projectId);
    });

    tearDownAll(() async {
      // Optionally clean after benchmark
      await resetTestProject(baseUrl, projectId);
    });

    PassageTranslationData makePassage(int i) => PassageTranslationData(
      name: 'Σ passage $i',
      visibility: const [],
      type: 'verse',
      difficulty: 'normal',
      references: const [],
      tags: const [],
      parentId: parentId,
      parentProp: parentProp,
      rank: 'r$i',
    );

    test('POST single passage change', () async {
      final data = makePassage(0);
      final sw = Stopwatch()..start();
      final resp = await saveChanges<PassageTranslationData>(
        baseUrl,
        domainType: domainType,
        domainId: projectId,
        entityType: 'passage',
        entityId: 'passage_single',
        changesToSave: [data],
        changeBy: 'bench-user',
        srcStorageType: 'cloud',
        srcStorageId: 'bench',
      );
      sw.stop();
      expect(
        resp.statusCode,
        anyOf([200, 201]),
        reason: 'Single change failed: ${resp.statusCode} ${resp.body}',
      );
      print(
        'Benchmark: single POST of 1 PassageTranslationData change took ${sw.elapsedMilliseconds} ms',
      );
    });

    test('POST 100 passage changes in single batch (saveChanges list)', () async {
      final batch = List.generate(100, makePassage);
      final sw = Stopwatch()..start();
      final resp = await saveChanges<PassageTranslationData>(
        baseUrl,
        domainType: domainType,
        domainId: projectId,
        entityType: 'passage',
        entityId: 'passage_batch',
        changesToSave: batch,
        changeBy: 'bench-user',
        srcStorageType: 'cloud',
        srcStorageId: 'bench',
      );
      sw.stop();
      expect(
        resp.statusCode,
        anyOf([200, 201]),
        reason: 'Batch failed: ${resp.statusCode} ${resp.body}',
      );
      print(
        'Benchmark: single batch POST of 100 PassageTranslationData changes took ${sw.elapsedMilliseconds} ms',
      );
    });
  });
}
