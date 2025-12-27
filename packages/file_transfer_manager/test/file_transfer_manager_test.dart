import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_transfer_manager/file_transfer_manager.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

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
  late Directory tempDir;
  late Directory pendingDir;
  late Directory cloudedDir;
  late FakeMediaServer server;
  late MediaApiClient apiClient;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ftm_test_');
    pendingDir = Directory(p.join(tempDir.path, 'pending'));
    cloudedDir = Directory(p.join(tempDir.path, 'clouded'));
    await pendingDir.create(recursive: true);
    await cloudedDir.create(recursive: true);

    server = FakeMediaServer();
    await server.start();
    apiClient = MediaApiClient(server.baseUri.toString());
  });

  tearDown(() async {
    apiClient.close();
    await server.stop();
    await tempDir.delete(recursive: true);
  });

  group('MediaUploadService', () {
    test('uploads pending files via multipart and moves to clouded', () async {
      final filePath = p.join(pendingDir.path, 'videos', 'clip.bin');
      final file = File(filePath);
      await file.parent.create(recursive: true);

      final content = List<int>.generate(32 * 1024, (i) => i % 256); // 32KB
      await file.writeAsBytes(content, flush: true);

      const testName =
          'uploads pending files via multipart and moves to clouded';
      final timestamp = DateTime.now();
      final remoteKey = buildTestRemoteKey(
        relativePath: p.relative(file.path, from: pendingDir.path),
        testName: testName,
        timestamp: timestamp,
      );

      final uploadService = MediaUploadService(
        apiClient: apiClient,
        pendingUploadBase: pendingDir,
        cloudedBase: cloudedDir,
        partSizeBytes: 8 * 1024, // force multipart
        remoteFileKeyResolver: (f) => buildTestRemoteKey(
          relativePath: p.relative(f.path, from: pendingDir.path),
          testName: testName,
          timestamp: timestamp,
        ),
      );

      await uploadService.processPendingUploads();
      final cloudedFile = File(
        p.joinAll([cloudedDir.path, ...remoteKey.split('/')]),
      );
      expect(await cloudedFile.exists(), isTrue);
      expect(await cloudedFile.readAsBytes(), equals(content));
      expect(await file.exists(), isFalse);

      final stored = server.completedObjects[remoteKey];
      expect(stored, equals(content));
    });
  });

  group('MediaDownloadService', () {
    test('downloads chunked file and assembles locally', () async {
      const testName = 'downloads chunked file and assembles locally';
      final timestamp = DateTime.now();
      final remoteKey = buildTestRemoteKey(
        relativePath: 'media/bigfile.bin',
        testName: testName,
        timestamp: timestamp,
      );
      final size = 21 * 1024 * 1024 + 123; // triggers chunked path
      final rand = Random(42);
      final bytes = List<int>.generate(size, (_) => rand.nextInt(256));
      server.completedObjects[remoteKey] = bytes;

      final downloadService = MediaDownloadService(
        apiClient: apiClient,
        cloudedBase: cloudedDir,
        maxPartConcurrency: 3,
      );

      final file = await downloadService.download(remoteFileKey: remoteKey);

      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), equals(bytes));

      final downloadingDir = Directory(
        p.join(cloudedDir.path, '__downloading', p.basename(remoteKey)),
      );
      expect(await downloadingDir.exists(), isFalse);
    });
  });
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
