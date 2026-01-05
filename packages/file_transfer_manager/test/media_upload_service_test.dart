import 'dart:io';

import 'package:file_transfer_manager/file_transfer_manager.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'file_transfer_manager_test_utils.dart';

const s3CompatiblePartSize = 6 * 1024 * 1024; // 6MB, exceeds 5MB minimum

String buildTestRemoteKey({
  required String relativePath,
  required String testName,
  required DateTime timestamp,
}) {
  final normalized = relativePath.replaceAll('\\', '/');
  final dir = p.posix.dirname(normalized);
  final base = p.posix.basename(normalized);
  final sanitizedTest = testName.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  final suffix = '${base}_${timestamp.toUtc().millisecondsSinceEpoch}';
  final dirPart = dir == '.' ? '' : '$dir/';
  return '__test/$sanitizedTest/$dirPart$suffix';
}

void main() {
  final skipInternetTests = false;

  group('offline (fake server) - upload', () {
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

    test('uploads pending files via multipart and moves to clouded', () async {
      await runUploadTest(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
      );
    });

    test('stops and resumes upload processing', () async {
      await runStopsAndResumesUploadProcessing(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
      );
    });
  });

  group('internet (cloud API) - upload', () {
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

    test('uploads pending files via multipart and moves to clouded', () async {
      await runUploadTest(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
      );
    }, timeout: Timeout.none);

    test('stops and resumes upload processing', () async {
      await runStopsAndResumesUploadProcessing(
        env: env,
        pendingDir: pendingDir,
        cloudedDir: cloudedDir,
      );
    });
  }, skip: skipInternetTests);
}

Future<void> runUploadTest({
  required TestEnv env,
  required Directory pendingDir,
  required Directory cloudedDir,
}) async {
  final filePath = p.join(pendingDir.path, 'videos', 'clip.bin');
  final file = File(filePath);
  await file.parent.create(recursive: true);

  final content = List<int>.generate(
    s3CompatiblePartSize + 512 * 1024,
    (i) => i % 256,
  ); // ~6.5MB to ensure first part >5MB and multipart
  await file.writeAsBytes(content, flush: true);

  const testName = 'uploads pending files via multipart and moves to clouded';
  final timestamp = DateTime.now();
  final remoteKey = buildTestRemoteKey(
    relativePath: p.relative(file.path, from: pendingDir.path),
    testName: testName,
    timestamp: timestamp,
  );

  final uploadService = MediaUploadService(
    apiClient: env.apiClient,
    pendingUploadBase: pendingDir,
    cloudedBase: cloudedDir,
    partSizeBytes: s3CompatiblePartSize,
    remoteFileKeyResolver: (f) => buildTestRemoteKey(
      relativePath: p.relative(f.path, from: pendingDir.path),
      testName: testName,
      timestamp: timestamp,
    ),
  );

  await uploadService.startProcessingUploads();
  final cloudedFile = File(
    p.joinAll([cloudedDir.path, ...remoteKey.split('/')]),
  );
  // Wait for file to appear in clouded dir (max 5s)
  final start = DateTime.now();
  while (!await cloudedFile.exists() &&
      DateTime.now().difference(start).inSeconds < 5) {
    await Future.delayed(const Duration(milliseconds: 50));
  }
  expect(await cloudedFile.exists(), isTrue);
  expect(await cloudedFile.readAsBytes(), equals(content));
  expect(await file.exists(), isFalse);

  final remoteBytes = await fetchRemoteBytes(env.apiClient, remoteKey);
  expect(remoteBytes, equals(content));

  await uploadService.dispose();
}

Future<void> runStopsAndResumesUploadProcessing({
  required TestEnv env,
  required Directory pendingDir,
  required Directory cloudedDir,
}) async {
  final filePath = p.join(pendingDir.path, 'videos', 'pause.bin');
  final file = File(filePath);
  await file.parent.create(recursive: true);
  final content = List<int>.generate(1024, (i) => i % 256);
  await file.writeAsBytes(content, flush: true);

  const testName = 'stops and resumes upload processing';
  final timestamp = DateTime.now();
  final remoteKey = buildTestRemoteKey(
    relativePath: p.relative(file.path, from: pendingDir.path),
    testName: testName,
    timestamp: timestamp,
  );

  final uploadService = MediaUploadService(
    apiClient: env.apiClient,
    pendingUploadBase: pendingDir,
    cloudedBase: cloudedDir,
    remoteFileKeyResolver: (_) => remoteKey,
  );

  await uploadService.stopProcessingUploads();
  await uploadService.processPendingUploads();

  expect(await file.exists(), isTrue, reason: 'upload should be paused');

  await uploadService.startProcessingUploads();

  final cloudedFile = File(
    p.joinAll([cloudedDir.path, ...remoteKey.split('/')]),
  );
  // Wait for file to appear in clouded dir (max 5s)
  final start = DateTime.now();
  while (!await cloudedFile.exists() &&
      DateTime.now().difference(start).inSeconds < 5) {
    await Future.delayed(const Duration(milliseconds: 50));
  }
  expect(await cloudedFile.exists(), isTrue);
  expect(await cloudedFile.readAsBytes(), equals(content));
  expect(await file.exists(), isFalse);

  final remoteBytes = await fetchRemoteBytes(env.apiClient, remoteKey);
  expect(remoteBytes, equals(content));

  await uploadService.dispose();
}

Future<List<int>> fetchRemoteBytes(
  MediaApiClient apiClient,
  String remoteKey,
) async {
  final urls = await apiClient.getUrls(
    remoteFileKey: remoteKey,
    clientMethods: ['get_object'],
  );
  final signed = urls.firstWhere((u) => u.getObject != null).getObject!;
  final response = await apiClient.get(signed);
  final bytes = await response.fold<List<int>>([], (prev, element) {
    prev.addAll(element);
    return prev;
  });
  return bytes;
}
