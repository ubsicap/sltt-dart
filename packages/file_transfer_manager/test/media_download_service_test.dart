import 'dart:async';
import 'dart:convert' show utf8, jsonDecode, jsonEncode;
import 'dart:io';
import 'dart:math';

import 'package:fake_async/fake_async.dart';
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

  group('offline (fake server) - catchError paths', () {
    late Directory tempDir;
    late Directory cloudedDir;
    late StubDownloadServer stub;
    late MediaDownloadService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ftm_catch_');
      cloudedDir = Directory(p.join(tempDir.path, 'clouded'));
      await cloudedDir.create(recursive: true);
      stub = await StubDownloadServer.start();
      service = MediaDownloadService(
        apiClient: MediaApiClient(stub.baseUri.toString()),
        cloudedBase: cloudedDir,
        chunkSizeOverride: 1024, // small parts to hit range code
        maxDownloadRequestsConcurrency: 2,
      );
      service.startProcessingDownloads();
    });

    tearDown(() async {
      await stub.stop();
      await tempDir.delete(recursive: true);
    });

    test('replaces active job when newer high-priority exists', () async {
      final keyA = 'media/a.bin';
      final keyB = 'media/b.bin';
      final bytesA = List<int>.generate(2048, (i) => i % 256);
      final bytesB = List<int>.generate(1024, (i) => (i * 7) % 256);
      stub.addObject(keyA, bytesA);
      stub.addObject(keyB, bytesB);

      final progressA = service.enqueueDownload(remoteFileKey: keyA);
      // Enqueue newer job with default (normal) priority; should replace A.
      final progressB = service.enqueueDownload(remoteFileKey: keyB);

      final results = await Future.wait([
        progressB.last, // should complete first after replacement
        progressA.last,
      ]);

      final fileB = File(results[0].destFilePath!);
      final fileA = File(results[1].destFilePath!);
      expect(await fileB.readAsBytes(), equals(bytesB));
      expect(await fileA.readAsBytes(), equals(bytesA));
    });

    test('paused download requeues and completes after resume', () async {
      final key = 'media/pause.bin';
      final bytes = List<int>.generate(1024, (i) => (i * 5) % 256);
      stub.addObject(key, bytes);

      final progress = service.enqueueDownload(remoteFileKey: key);
      // Pause immediately so the in-flight download throws _DownloadPausedException.
      service.stopProcessingDownloads();
      service.resumeProcessingDownloads();

      final last = await progress.last;
      final file = File(last.destFilePath!);
      expect(await file.readAsBytes(), equals(bytes));
    });

    test('transient error schedules retry and eventually succeeds', () async {
      fakeAsync((async) {
        final key = 'media/transient.bin';
        final bytes = List<int>.generate(2048, (i) => (i * 11) % 256);
        stub.addObject(
          key,
          bytes,
          getStatuses: [HttpStatus.serviceUnavailable, HttpStatus.ok],
        );

        late Future<DownloadProgress> future;
        async.run((_) {
          future = service.enqueueDownload(remoteFileKey: key).last;
        });

        async.flushMicrotasks();
        async.elapse(const Duration(minutes: 1));
        async.flushMicrotasks();

        final last = async.run((_) => future) as DownloadProgress?;
        expect(last, isNotNull);
        final file = File(last!.destFilePath!);
        expect(file.readAsBytesSync(), equals(bytes));
      });
    });

    test('missing remote triggers not found handling', () async {
      final key = 'media/missing.bin';
      final pendingFuture = service.pendingDownloadTotalsEvents.firstWhere(
        (message) => message.missingFiles.contains(key),
      );
      // no stub object added -> 404
      final progress = service.enqueueDownload(remoteFileKey: key);

      final errorProgress = await progress.firstWhere(
        (update) => update.errorMessage.isNotEmpty,
      );
      expect(errorProgress.errorMessage, contains('Remote media missing'));

      final pending = await pendingFuture;
      expect(pending.missingFiles, contains(key));
    });

    test('non-retriable failure bubbles error', () async {
      final key = 'media/fail.bin';
      // Force GET to return 400 so _getWithRenewal throws HttpException.
      stub.addObject(key, List<int>.filled(1024, 1), getStatuses: [400]);
      final progress = service.enqueueDownload(remoteFileKey: key);

      await expectLater(progress, emitsError(isA<HttpException>()));
    });
  });
}

class StubDownloadServer {
  StubDownloadServer._(this._server);

  final HttpServer _server;
  Uri get baseUri => Uri.parse('http://localhost:${_server.port}');

  final Map<String, _StubObject> _objects = {};

  void addObject(
    String key,
    List<int> bytes, {
    List<int> getStatuses = const [HttpStatus.ok],
  }) {
    _objects[key] = _StubObject(bytes, getStatuses);
  }

  static Future<StubDownloadServer> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final stub = StubDownloadServer._(server);
    server.listen(stub._handle);
    return stub;
  }

  Future<void> stop() async => _server.close(force: true);

  Future<void> _handle(HttpRequest request) async {
    final path = request.uri.path;
    if (path == '/api/media/get-urls') {
      final body = await utf8.decodeStream(request);
      final data = jsonDecode(body) as Map<String, dynamic>;
      final key = data['remoteFileKey'] as String;
      final urls = [
        {
          'remoteFileKey': key,
          'head_object': baseUri.resolve('/signed/head/$key').toString(),
          'get_object': baseUri.resolve('/signed/get/$key').toString(),
          'expiresAt': DateTime.now()
              .add(const Duration(minutes: 30))
              .toIso8601String(),
        },
      ];
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'urls': urls}));
      await request.response.close();
      return;
    }

    if (path.startsWith('/signed/head/')) {
      final key = path.substring('/signed/head/'.length);
      final obj = _objects[key];
      if (obj == null) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.add(HttpHeaders.contentLengthHeader, obj.bytes.length);
      await request.response.close();
      return;
    }

    if (path.startsWith('/signed/get/')) {
      final key = path.substring('/signed/get/'.length);
      final obj = _objects[key];
      if (obj == null) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      final status = obj.nextStatus();
      if (status < 200 || status >= 300) {
        request.response.statusCode = status;
        await request.response.close();
        return;
      }

      final range = request.headers.value(HttpHeaders.rangeHeader);
      var start = 0;
      var end = obj.bytes.length - 1;
      if (range != null && range.startsWith('bytes=')) {
        final parts = range.substring(6).split('-');
        start = int.parse(parts[0]);
        if (parts.length > 1 && parts[1].isNotEmpty) {
          end = int.parse(parts[1]);
        }
        end = end.clamp(start, obj.bytes.length - 1);
        request.response.statusCode = HttpStatus.partialContent;
        request.response.headers.add(
          HttpHeaders.contentRangeHeader,
          'bytes $start-$end/${obj.bytes.length}',
        );
      } else {
        request.response.statusCode = HttpStatus.ok;
      }

      request.response.headers
        ..add(HttpHeaders.contentLengthHeader, end - start + 1)
        ..add(HttpHeaders.acceptRangesHeader, 'bytes');
      request.response.add(obj.bytes.sublist(start, end + 1));
      await request.response.close();
      return;
    }

    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }
}

class _StubObject {
  _StubObject(this.bytes, this.statuses);

  final List<int> bytes;
  final List<int> statuses;
  int _idx = 0;

  int nextStatus() {
    if (_idx >= statuses.length) return statuses.last;
    return statuses[_idx++];
  }
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
