import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_transfer_manager/file_transfer_manager.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'file_transfer_manager_test_utils.dart';

void main() {
  final skipInternetTests = false;

  group('offline (fake server) - download', () {
    late Directory tempDir;
    late Directory pendingDir;
    late Directory cloudedDir;
    late TestEnv env;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ftm_test_');
      pendingDir = Directory(p.join(tempDir.path, 'pending'));
      cloudedDir = Directory(p.join(tempDir.path, 'clouded'));
      await pendingDir.create(recursive: true);
      await cloudedDir.create(recursive: true);

      env = await buildOfflineEnv();
    });

    tearDown(() async {
      await env.dispose();
      await tempDir.delete(recursive: true);
    });

    test('downloads single-chunk file', () async {
      const testName = 'downloads single-chunk file';
      await testSingleChunkDownload(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
        testName: testName,
      );
    });

    test('downloads chunked file and assembles locally', () async {
      const testName = 'downloads chunked file and assembles locally';
      final timestamp = DateTime.now();
      final remoteKey = buildTestRemoteKey(
        relativePath: 'media/bigfile.bin',
        testName: testName,
        timestamp: timestamp,
      );
      final size = 10 * 1024 * 1024 + 123;
      final rand = Random(42);
      final bytes = List<int>.generate(size, (_) => rand.nextInt(256));
      env.fakeServer!.completedObjects[remoteKey] = bytes;
      await runDownloadTest(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
        remoteKey: remoteKey,
        bytes: bytes,
      );
    });

    test('stops and resumes download processing', () async {
      const testName = 'stops and resumes download processing';
      final timestamp = DateTime.now();
      final remoteKey = buildTestRemoteKey(
        relativePath: 'media/pause.bin',
        testName: testName,
        timestamp: timestamp,
      );
      final bytes = List<int>.generate(2048, (i) => (i * 3) % 256);
      env.fakeServer!.completedObjects[remoteKey] = bytes;
      await runStopsAndResumesDownloadProcessing(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
        remoteKey: remoteKey,
        bytes: bytes,
      );
    });

    test('resumes download using existing parts', () async {
      const testName = 'resumes download using existing parts';
      final timestamp = DateTime.now();
      final remoteKey = buildTestRemoteKey(
        relativePath: 'media/resume.bin',
        testName: testName,
        timestamp: timestamp,
      );
      final chunkSize = 2 * 1024 * 1024;
      final size = 6 * 1024 * 1024 + 321;
      final rand = Random(7);
      final bytes = List<int>.generate(size, (_) => rand.nextInt(256));
      env.fakeServer!.completedObjects[remoteKey] = bytes;
      await runResumesDownloadUsingExistingParts(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
        remoteKey: remoteKey,
        bytes: bytes,
        chunkSize: chunkSize,
      );
    });
  });

  group('internet (cloud API) - download', () {
    late Directory tempDir;
    late Directory pendingDir;
    late Directory cloudedDir;
    late TestEnv env;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ftm_test_');
      pendingDir = Directory(p.join(tempDir.path, 'pending'));
      cloudedDir = Directory(p.join(tempDir.path, 'clouded'));
      await pendingDir.create(recursive: true);
      await cloudedDir.create(recursive: true);

      env = await buildInternetEnv();
    });

    tearDown(() async {
      await env.dispose();
      await tempDir.delete(recursive: true);
    });

    test('downloads single-chunk file', () async {
      const testName = 'downloads single-chunk file';
      await testSingleChunkDownload(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
        testName: testName,
      );
    });

    test('downloads chunked file and assembles locally', () async {
      const testName = 'downloads chunked file and assembles locally';
      final timestamp = DateTime.now();
      final remoteKey = buildTestRemoteKey(
        relativePath: 'media/bigfile.bin',
        testName: testName,
        timestamp: timestamp,
      );
      final size = 10 * 1024 * 1024 + 123;
      final rand = Random(42);
      final bytes = List<int>.generate(size, (_) => rand.nextInt(256));
      await seedRemoteBytes(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
        remoteKey: remoteKey,
        bytes: bytes,
      );
      await runDownloadTest(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
        remoteKey: remoteKey,
        bytes: bytes,
      );
    });

    test('stops and resumes download processing', () async {
      const testName = 'stops and resumes download processing';
      final timestamp = DateTime.now();
      final remoteKey = buildTestRemoteKey(
        relativePath: 'media/pause.bin',
        testName: testName,
        timestamp: timestamp,
      );
      final bytes = List<int>.generate(2048, (i) => (i * 3) % 256);
      await seedRemoteBytes(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
        remoteKey: remoteKey,
        bytes: bytes,
      );
      await runStopsAndResumesDownloadProcessing(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
        remoteKey: remoteKey,
        bytes: bytes,
      );
    });

    test('resumes download using existing parts', () async {
      const testName = 'resumes download using existing parts';
      final timestamp = DateTime.now();
      final remoteKey = buildTestRemoteKey(
        relativePath: 'media/resume.bin',
        testName: testName,
        timestamp: timestamp,
      );
      final chunkSize = 2 * 1024 * 1024;
      final size = 6 * 1024 * 1024 + 321;
      final rand = Random(7);
      final bytes = List<int>.generate(size, (_) => rand.nextInt(256));
      await seedRemoteBytes(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
        remoteKey: remoteKey,
        bytes: bytes,
      );
      await runResumesDownloadUsingExistingParts(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
        remoteKey: remoteKey,
        bytes: bytes,
        chunkSize: chunkSize,
      );
    });
  }, skip: skipInternetTests);
}

Future<void> runResumesDownloadUsingExistingParts({
  required TestEnv env,
  required Directory pendingDir,
  required Directory cloudedDir,
  required String remoteKey,
  required List<int> bytes,
  required int chunkSize,
}) async {
  final size = bytes.length;
  final resolvedFileName = p.basename(remoteKey);
  final downloadDir = Directory(
    p.join(cloudedDir.path, '__downloading', resolvedFileName),
  );
  await downloadDir.create(recursive: true);

  int partLength(int partNumber) {
    final start = (partNumber - 1) * chunkSize;
    final endExclusive = min(start + chunkSize, size);
    return endExclusive - start;
  }

  // Seed parts 1 and 2 as already downloaded.
  for (final partNumber in [1, 2]) {
    final start = (partNumber - 1) * chunkSize;
    final endExclusive = start + partLength(partNumber);
    final partFile = File(
      p.join(
        downloadDir.path,
        '$resolvedFileName-${partNumber.toString().padLeft(7, '0')}',
      ),
    );
    await partFile.writeAsBytes(
      bytes.sublist(start, endExclusive),
      flush: true,
    );
  }

  final downloadService = MediaDownloadService(
    apiClient: env.apiClient,
    cloudedBase: cloudedDir,
    chunkSizeOverride: chunkSize,
  );

  downloadService.startProcessingDownloads();

  final progressStream = downloadService.enqueueDownload(
    remoteFileKey: remoteKey,
  );

  final progressUpdates = await progressStream.toList();
  final file = File(progressUpdates.last.destFilePath!);

  expect(await file.exists(), isTrue);
  expect(await file.readAsBytes(), equals(bytes));

  final downloadingDir = Directory(
    p.join(cloudedDir.path, '__downloading', resolvedFileName),
  );
  expect(await downloadingDir.exists(), isFalse);

  final preDownloadedBytes = partLength(1) + partLength(2);
  final resumedProgress = progressUpdates.lastWhere(
    (p) => p.partsCompleted >= 2,
    orElse: () => progressUpdates.last,
  );
  expect(resumedProgress.partsCompleted, greaterThanOrEqualTo(2));
  expect(
    resumedProgress.bytesCompleted,
    greaterThanOrEqualTo(preDownloadedBytes),
  );

  final lastProgress = progressUpdates.last;
  final totalParts = (size / chunkSize).ceil();
  expect(lastProgress.partsCompleted, equals(totalParts));
  expect(lastProgress.bytesCompleted, equals(size));
}

Future<void> testSingleChunkDownload({
  required TestEnv env,
  required Directory pendingDir,
  required Directory cloudedDir,
  required String testName,
}) async {
  final timestamp = DateTime.now();
  final remoteKey = buildTestRemoteKey(
    relativePath: 'media/single_chunk.bin',
    testName: testName,
    timestamp: timestamp,
  );
  final bytes = List<int>.generate(128 * 1024 + 13, (i) => i % 256);

  await seedRemoteBytes(
    env: env,
    pendingDir: pendingDir,
    cloudedDir: cloudedDir,
    remoteKey: remoteKey,
    bytes: bytes,
  );

  final downloadService = MediaDownloadService(
    apiClient: env.apiClient,
    cloudedBase: cloudedDir,
    // Force a single part by setting chunk size larger than the payload.
    chunkSizeOverride: bytes.length * 2,
  );

  downloadService.startProcessingDownloads();

  final progressStream = downloadService.enqueueDownload(
    remoteFileKey: remoteKey,
  );

  final progressUpdates = await progressStream.toList();
  final lastProgress = progressUpdates.last;
  final file = File(lastProgress.destFilePath!);

  expect(await file.exists(), isTrue);
  expect(await file.readAsBytes(), equals(bytes));
  expect(lastProgress.partsTotal, equals(1));
  expect(lastProgress.partsCompleted, equals(1));
  expect(lastProgress.bytesCompleted, equals(bytes.length));

  final downloadingDir = Directory(
    p.join(cloudedDir.path, '__downloading', p.basename(remoteKey)),
  );
  expect(await downloadingDir.exists(), isFalse);
}
