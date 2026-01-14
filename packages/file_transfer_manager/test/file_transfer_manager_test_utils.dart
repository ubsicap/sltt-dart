import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_transfer_manager/file_transfer_manager.dart';
import 'package:path/path.dart' as p;
import 'package:sltt_core/src/server/server_urls.dart';
import 'package:test/test.dart';

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

Future<TestEnv> buildOfflineEnv() async {
  final server = FakeMediaServer();
  await server.start();
  final client = MediaApiClient(server.baseUri.toString());
  return TestEnv(
    apiClient: client,
    fakeServer: server,
    dispose: () async {
      client.close();
      await server.stop();
    },
  );
}

Future<TestEnv> buildInternetEnv() async {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  final client = MediaApiClient(baseUrl);
  return TestEnv(
    apiClient: client,
    fakeServer: null,
    dispose: () async {
      client.close();
    },
  );
}

class TestEnv {
  TestEnv({
    required this.apiClient,
    required this.fakeServer,
    required this.dispose,
  });

  final MediaApiClient apiClient;
  final FakeMediaServer? fakeServer;
  final Future<void> Function() dispose;
}

class FakeMediaServer {
  FakeMediaServer();

  final Map<String, _UploadSession> _uploads = {};
  final Map<String, List<int>> completedObjects = {};
  int _uploadCounter = 0;
  HttpServer? _server;

  Uri get baseUri => Uri.parse('http://localhost:${_server!.port}');

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen(_handleRequest);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      final path = request.uri.path;
      if (path == '/api/media/get-urls') {
        return _handleGetUrls(request);
      }
      if (path == '/api/media/list-parts') {
        return _handleListParts(request);
      }
      if (path == '/api/media/multipart-create') {
        return _handleMultipartCreate(request);
      }
      if (path == '/api/media/multipart-complete') {
        return _handleMultipartComplete(request);
      }
      if (path.startsWith('/signed/head/')) {
        return _handleSignedHead(request);
      }
      if (path.startsWith('/signed/get/')) {
        return _handleSignedGet(request);
      }
      if (path.startsWith('/signed/upload/')) {
        return _handleSignedUpload(request);
      }

      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
    } catch (e, st) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('error: $e\n$st');
      await request.response.close();
    }
  }

  Future<void> _handleGetUrls(HttpRequest request) async {
    final body = await utf8.decodeStream(request);
    final data = jsonDecode(body) as Map<String, dynamic>;
    final remoteFileKey = data['remoteFileKey'] as String;
    final methods = (data['clientMethods'] as List<dynamic>).cast<String>();
    final partNumber = data['partNumber'] as int?;
    final uploadId = data['uploadId'] as String?;

    final urls = <Map<String, dynamic>>[];
    final bundle = <String, dynamic>{'remoteFileKey': remoteFileKey};

    if (methods.contains('head_object')) {
      bundle['head_object'] = baseUri
          .resolve('/signed/head/$remoteFileKey')
          .toString();
    }
    if (methods.contains('get_object')) {
      bundle['get_object'] = baseUri
          .resolve('/signed/get/$remoteFileKey')
          .toString();
    }
    if (methods.contains('upload_part')) {
      final upload = uploadId ?? _uploads.values.firstOrNull?.uploadId;
      if (upload == null || partNumber == null) {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
        return;
      }
      bundle['upload_part'] = baseUri
          .resolve('/signed/upload/$upload/$partNumber')
          .toString();
      bundle['uploadId'] = upload;
      bundle['partNumber'] = partNumber;
    }

    bundle['expiresAt'] = DateTime.now()
        .add(const Duration(minutes: 30))
        .toIso8601String();
    urls.add(bundle);

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'urls': urls}));
    await request.response.close();
  }

  Future<void> _handleListParts(HttpRequest request) async {
    final body = await utf8.decodeStream(request);
    final data = jsonDecode(body) as Map<String, dynamic>;
    final remoteFileKey = data['remoteFileKey'] as String;
    final uploadId = data['uploadId'] as String?;

    final session = uploadId != null
        ? _uploads[uploadId]
        : _uploads.values.firstWhere(
            (u) => u.remoteFileKey == remoteFileKey,
            orElse: () => _UploadSession(remoteFileKey, ''),
          );

    final parts = session?.parts ?? <int, List<int>>{};
    final response = {
      'Key': remoteFileKey,
      'UploadId': session?.uploadId,
      'IsTruncated': false,
      'Parts': [
        for (final entry in parts.entries)
          {
            'PartNumber': entry.key,
            'Size': entry.value.length,
            'ETag': 'etag-${entry.key}',
          },
      ],
    };

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(response));
    await request.response.close();
  }

  Future<void> _handleMultipartCreate(HttpRequest request) async {
    final body = await utf8.decodeStream(request);
    final data = jsonDecode(body) as Map<String, dynamic>;
    final remoteFileKey = data['remoteFileKey'] as String;

    final uploadId = 'upload-${_uploadCounter++}';
    _uploads[uploadId] = _UploadSession(remoteFileKey, uploadId);

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(
        jsonEncode({
          'remoteFileKey': remoteFileKey,
          'uploadId': uploadId,
          'bucket': 'test-bucket',
        }),
      );
    await request.response.close();
  }

  Future<void> _handleMultipartComplete(HttpRequest request) async {
    final body = await utf8.decodeStream(request);
    final data = jsonDecode(body) as Map<String, dynamic>;
    final remoteFileKey = data['remoteFileKey'] as String;
    final uploadId = data['uploadId'] as String;
    final parts = (data['parts'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    final session = _uploads[uploadId];
    if (session == null) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }

    final ordered = parts
      ..sort((a, b) => (a['partNumber'] as int).compareTo(b['partNumber']));

    final bytes = <int>[];
    for (final part in ordered) {
      final num partNum = part['partNumber'] as num;
      final dataBytes = session.parts[partNum.toInt()];
      if (dataBytes != null) bytes.addAll(dataBytes);
    }
    completedObjects[remoteFileKey] = bytes;
    _uploads.remove(uploadId);

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(
        jsonEncode({
          'remoteFileKey': remoteFileKey,
          'uploadId': uploadId,
          'bucket': 'test-bucket',
          'location': remoteFileKey,
          'eTag': 'complete-etag',
        }),
      );
    await request.response.close();
  }

  Future<void> _handleSignedHead(HttpRequest request) async {
    final key = request.uri.pathSegments.skip(2).join('/');
    final bytes = completedObjects[key];
    if (bytes == null) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.add(HttpHeaders.contentLengthHeader, bytes.length.toString());
    await request.response.close();
  }

  Future<void> _handleSignedGet(HttpRequest request) async {
    final key = request.uri.pathSegments.skip(2).join('/');
    final bytes = completedObjects[key];
    if (bytes == null) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);
    int start = 0;
    int end = bytes.length - 1;
    if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
      final parts = rangeHeader.substring(6).split('-');
      start = int.parse(parts[0]);
      end = parts.length > 1 && parts[1].isNotEmpty ? int.parse(parts[1]) : end;
      end = end.clamp(start, bytes.length - 1);
      request.response.statusCode = HttpStatus.partialContent;
      request.response.headers.add(
        HttpHeaders.contentRangeHeader,
        'bytes $start-$end/${bytes.length}',
      );
    } else {
      request.response.statusCode = HttpStatus.ok;
    }

    request.response.headers
      ..add(HttpHeaders.contentLengthHeader, (end - start + 1).toString())
      ..add(HttpHeaders.acceptRangesHeader, 'bytes');
    request.response.add(bytes.sublist(start, end + 1));
    await request.response.close();
  }

  Future<void> _handleSignedUpload(HttpRequest request) async {
    final segments = request.uri.pathSegments;
    final uploadId = segments[2];
    final partNumber = int.parse(segments[3]);
    final session = _uploads[uploadId];
    if (session == null) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final body = await request.fold<List<int>>([], (prev, element) {
      prev.addAll(element);
      return prev;
    });

    session.parts[partNumber] = body;

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.add('etag', 'etag-$partNumber');
    await request.response.close();
  }
}

class _UploadSession {
  _UploadSession(this.remoteFileKey, this.uploadId);

  final String remoteFileKey;
  final String uploadId;
  final Map<int, List<int>> parts = {};
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}

Future<void> seedRemoteBytes({
  required TestEnv env,
  required Directory pendingDir,
  required Directory cloudedDir,
  required String remoteKey,
  required List<int> bytes,
}) async {
  if (env.fakeServer != null) {
    env.fakeServer!.completedObjects[remoteKey] = bytes;
    return;
  }

  // Seed via upload when using real server.
  final seedFile = File(
    p.join(pendingDir.path, 'seed_${remoteKey.replaceAll('/', '_')}'),
  );
  await seedFile.parent.create(recursive: true);
  await seedFile.writeAsBytes(bytes, flush: true);
  final seedingUpload = MediaUploadService(
    apiClient: env.apiClient,
    pendingUploadBase: pendingDir,
    cloudedBase: cloudedDir,
    remoteFileKeyResolver: (_) => remoteKey,
    partSizeBytes: s3CompatiblePartSize,
  );
  await seedingUpload.startProcessingUploads();
  final cloudedSeedFile = File(
    p.joinAll([cloudedDir.path, ...remoteKey.split('/')]),
  );
  // Wait for seed upload to finish by checking clouded file presence (max 10s)
  final seedWaitStart = DateTime.now();
  while (!await cloudedSeedFile.exists() &&
      DateTime.now().difference(seedWaitStart).inSeconds < 10) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  await seedingUpload.dispose();

  if (await cloudedSeedFile.exists()) {
    await cloudedSeedFile.delete();
  }

  // Wait for remote file to exist (HEAD returns 200) with timeout
  final timeout = Duration(seconds: 10);
  final pollInterval = Duration(milliseconds: 100);
  final start = DateTime.now();
  while (true) {
    try {
      final urls = await env.apiClient.getUrls(
        remoteFileKey: remoteKey,
        clientMethods: ['head_object'],
      );
      final headUrl = urls.firstWhere((u) => u.headObject != null).headObject!;
      final headRequest = await HttpClient().headUrl(headUrl);
      final headResponse = await headRequest.close();
      if (headResponse.statusCode == 200) {
        break;
      }
    } catch (e) {
      // ignore and retry
    }
    if (DateTime.now().difference(start) > timeout) {
      throw Exception('Timeout waiting for remote file $remoteKey to exist');
    }
    await Future.delayed(pollInterval);
  }
}

Future<void> runDownloadTest({
  required TestEnv env,
  required Directory pendingDir,
  required Directory cloudedDir,
  required String remoteKey,
  required List<int> bytes,
}) async {
  final downloadService = MediaDownloadService(
    apiClient: env.apiClient,
    cloudedBase: cloudedDir,
    maxDownloadRequestsConcurrency: 3,
    chunkSizeOverride: 2 * 1024 * 1024,
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

  final downloadingDir = Directory(
    p.join(cloudedDir.path, '__downloading', p.basename(remoteKey)),
  );
  expect(await downloadingDir.exists(), isFalse);

  expect(lastProgress.partsCompleted, equals(lastProgress.partsTotal));
  expect(lastProgress.bytesCompleted, equals(bytes.length));
}

Future<void> runStopsAndResumesDownloadProcessing({
  required TestEnv env,
  required Directory pendingDir,
  required Directory cloudedDir,
  required String remoteKey,
  required List<int> bytes,
}) async {
  final downloadService = MediaDownloadService(
    apiClient: env.apiClient,
    cloudedBase: cloudedDir,
  );

  downloadService.stopProcessingDownloads();

  final downloadStream = downloadService.enqueueDownload(
    remoteFileKey: remoteKey,
  );
  final downloadFuture = downloadStream.last;

  final destFile = File(p.normalize(p.join(cloudedDir.path, remoteKey)));

  await Future<void>.delayed(const Duration(milliseconds: 50));
  expect(
    await destFile.exists(),
    isFalse,
    reason: 'download should not start while stopped',
  );

  downloadService.resumeProcessingDownloads();
  final lastProgress = await downloadFuture;
  final completedFile = File(lastProgress.destFilePath!);

  expect(completedFile.path, equals(destFile.path));
  expect(await completedFile.exists(), isTrue);
  expect(await completedFile.readAsBytes(), equals(bytes));
}
