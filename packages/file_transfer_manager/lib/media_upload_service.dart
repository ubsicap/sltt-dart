import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:file_transfer_manager/media_transfer_service_shared.dart'
    show RequestLimiter, runWithConcurrency, MediaApiClientCore;
import 'package:path/path.dart' as p;

const _defaultPartSizeBytes = 5 * 1024 * 1024; // 5MB
const _defaultUploadRequestsConcurrency = 4;

class PendingUploadTotalsMessage {
  PendingUploadTotalsMessage({
    this.queuedFiles = const [],
    this.inProgressFiles = const [],
    this.bytes = 0,
    this.isProcessing = false,
    this.errorMessage = '',
  });

  final List<String> queuedFiles;
  final List<String> inProgressFiles;
  final int bytes;
  final bool isProcessing;
  final String errorMessage;
}

class MediaUploadService {
  static MediaUploadService? _singleton;

  /// Returns a shared upload service instance, creating it on first use so
  /// pending upload state/queue can be shared across the app.
  static MediaUploadService ensureSingleton({
    required MediaApiClient apiClient,
    required Directory pendingUploadBase,
    required Directory cloudedBase,
    String Function(File file)? remoteFileKeyResolver,
    int partSizeBytes = _defaultPartSizeBytes,
    int maxUploadRequestsConcurrency = _defaultUploadRequestsConcurrency,
  }) {
    _singleton ??= MediaUploadService(
      apiClient: apiClient,
      pendingUploadBase: pendingUploadBase,
      cloudedBase: cloudedBase,
      remoteFileKeyResolver: remoteFileKeyResolver,
      partSizeBytes: partSizeBytes,
      maxUploadRequestsConcurrency: maxUploadRequestsConcurrency,
    );
    return _singleton!;
  }

  static MediaUploadService? get instance => _singleton;

  static void clearInstance() {
    _singleton = null;
  }

  MediaUploadService({
    required this.apiClient,
    required this.pendingUploadBase,
    required this.cloudedBase,
    this.remoteFileKeyResolver,
    this.partSizeBytes = _defaultPartSizeBytes,
    this.maxUploadRequestsConcurrency = _defaultUploadRequestsConcurrency,
  }) : _requestLimiter = RequestLimiter(maxUploadRequestsConcurrency);

  final MediaApiClient apiClient;
  final Directory pendingUploadBase;
  final Directory cloudedBase;
  final String Function(File file)? remoteFileKeyResolver;
  final int partSizeBytes;
  final int maxUploadRequestsConcurrency;
  final _pendingUploadTotalsEvents =
      StreamController<PendingUploadTotalsMessage>.broadcast();

  Stream<PendingUploadTotalsMessage> get pendingUploadTotalsEvents =>
      _pendingUploadTotalsEvents.stream;

  final Queue<File> _fileQueue = Queue();
  final Set<String> _activeUploadPaths = {};
  final RequestLimiter _requestLimiter;
  int _activeUploads = 0;

  bool _processingQueue = false;
  bool _admitMoreUploads = true;

  bool _scanning = false;
  bool _rerunRequested = false;
  final Random _random = Random();
  bool _uploadsEnabled = false;
  StreamSubscription<FileSystemEvent>? _uploadWatch;

  void _reportTotals({String errorMessage = ''}) =>
      _pendingUploadTotalsEvents.isClosed
      ? null
      : _pendingUploadTotalsEvents.add(
          PendingUploadTotalsMessage(
            queuedFiles: _fileQueue.map((file) => file.path).toList(),
            inProgressFiles: _activeUploadPaths.toList(),
            bytes: _pendingBytes,
            isProcessing: _uploadsEnabled,
            errorMessage: errorMessage,
          ),
        );

  void _adjustPendingBytes(int delta) {
    _pendingBytes = ((_pendingBytes + delta).clamp(0, 1 << 62));
    _reportTotals();
  }

  int _pendingBytes = 0;

  void scanAndWatchPendingUploads() async {
    unawaited(processPendingUploads());
  }

  Future<void> watchAndProcess() async => startProcessingUploads();

  Future<void> startProcessingUploads() async {
    _uploadsEnabled = true;
    await processPendingUploads();
  }

  Future<void> resumeProcessingUploads() async => startProcessingUploads();

  Future<void> stopProcessingUploads() async {
    _uploadsEnabled = false;
    _rerunRequested = false;
    _reportTotals();
  }

  Future<void> dispose() async {
    _uploadsEnabled = false;
    _rerunRequested = false;
    await _uploadWatch?.cancel();
    _uploadWatch = null;
    await _pendingUploadTotalsEvents.close();
  }

  void _ensureUploadWatch() {
    if (_uploadWatch != null) return;
    _uploadWatch = pendingUploadBase.watch(recursive: true).listen((
      event,
    ) async {
      await processPendingUploads();
    });
  }

  Future<void> processPendingUploads() async {
    if (_scanning) {
      _rerunRequested = true;
      return;
    }

    _ensureUploadWatch();
    _scanning = true;
    try {
      _pendingBytes = 0;
      final files = await _collectFiles();
      final pending = files.where(
        (file) => !_activeUploadPaths.contains(file.path),
      );
      _fileQueue
        ..clear()
        ..addAll(pending);
      _reportTotals();
      _admitMoreUploads = true;
      if (_uploadsEnabled) {
        _processQueue();
      }
    } finally {
      _scanning = false;
    }

    if (_rerunRequested) {
      _rerunRequested = false;
      await processPendingUploads();
    }
  }

  void _processQueue() {
    if (_processingQueue || !_uploadsEnabled || !_admitMoreUploads) return;
    _processingQueue = true;

    Future<void>.microtask(() async {
      try {
        while (_uploadsEnabled &&
            _admitMoreUploads &&
            _activeUploads < maxUploadRequestsConcurrency &&
            _fileQueue.isNotEmpty) {
          final file = _fileQueue.removeFirst();
          _activeUploads++;
          _admitMoreUploads = false;
          _activeUploadPaths.add(file.path);
          _uploadFile(file)
              .catchError((error, stackTrace) {
                if (error is UploadPausedException) {
                  // Re-enqueue the file for later processing
                  _fileQueue.addFirst(file);
                } else {
                  // Log other errors
                  // ignore: avoid_print
                  final errorMessage =
                      'Error uploading file ${file.path}: $error';
                  print(
                    'Error uploading file ${file.path}: $error\n$stackTrace',
                  );
                  _reportTotals(errorMessage: errorMessage);
                }
              })
              .whenComplete(() {
                _activeUploads--;
                _admitMoreUploads = true;
                _activeUploadPaths.remove(file.path);
                _reportTotals();
                _processingQueue = false;
                _processQueue();
              });
        }
      } finally {
        _processingQueue = false;
      }
    });
  }

  Future<List<File>> _collectFiles() async {
    final files = <File>[];
    await for (final entity in pendingUploadBase.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) {
        // Skip sidecar files that persist upload IDs between restarts.
        if (entity.path.endsWith('.uploadId')) continue;
        _pendingBytes += await entity.length();
        files.add(entity);
      }
    }

    files.sort((a, b) {
      final aStat = a.statSync();
      final bStat = b.statSync();
      return aStat.modified.compareTo(bStat.modified);
    });

    final ordered = <File>[];
    var left = 0;
    var right = files.length - 1;
    var takeOldest = true;
    while (left <= right) {
      if (takeOldest) {
        ordered.add(files[left]);
        left++;
      } else {
        ordered.add(files[right]);
        right--;
      }
      takeOldest = !takeOldest;
    }

    return ordered;
  }

  Future<void> _uploadFile(File file) async {
    final fileSize = await file.length();
    final remoteFileKey = _buildRemoteFileKey(file);

    final persistedUploadId = await _readPersistedUploadId(file);

    final headUrls = await apiClient.getUrls(
      remoteFileKey: remoteFileKey,
      clientMethods: ['head_object'],
    );

    final headUrl = headUrls
        .firstWhere((u) => u.headObject != null)
        .headObject!;
    final headResponse = await apiClient.head(headUrl);
    if (headResponse.statusCode == HttpStatus.ok) {
      _adjustPendingBytes(-fileSize);
      await _moveToClouded(file, remoteFileKey);
      _reportTotals();
      return;
    }

    if (_uploadsEnabled == false) {
      throw UploadPausedException();
    }

    final listed = await _listPartsExhaustive(
      remoteFileKey: remoteFileKey,
      uploadId: persistedUploadId,
    );
    final existingParts = <int, String>{
      for (final part in listed.parts) part.partNumber: part.eTag,
    };

    if (_uploadsEnabled == false) {
      throw UploadPausedException();
    }

    var uploadId = listed.uploadId;
    if (uploadId == null || uploadId.isEmpty) {
      uploadId = (await apiClient.createMultipart(remoteFileKey)).uploadId;
    }
    final resolvedUploadId = uploadId;
    await _persistUploadId(file, resolvedUploadId);

    final totalParts = (fileSize / partSizeBytes).ceil();
    final missingParts = <int>[];
    for (var partNumber = 1; partNumber <= totalParts; partNumber++) {
      if (!existingParts.containsKey(partNumber)) {
        missingParts.add(partNumber);
      }
    }

    final remainingUploadSlots = _requestLimiter.availablePermits;

    if (remainingUploadSlots > 0 &&
        missingParts.length < remainingUploadSlots) {
      _admitMoreUploads = true;
      _processQueue();
    }

    if (missingParts.isNotEmpty && existingParts.isNotEmpty) {
      missingParts.shuffle(_random);
    }

    final uploaded = <UploadedPartSummary>[
      for (final entry in existingParts.entries)
        UploadedPartSummary(partNumber: entry.key, eTag: entry.value),
    ];

    final missingBytes = missingParts.fold<int>(
      0,
      (sum, partNumber) => sum + _partLength(fileSize, partNumber),
    );
    _adjustPendingBytes(missingBytes - fileSize);

    if (_uploadsEnabled == false) {
      throw UploadPausedException();
    }

    if (missingParts.isNotEmpty) {
      await runWithConcurrency<int>(
        items: missingParts,
        concurrency: maxUploadRequestsConcurrency,
        worker: (partNumber) async {
          final eTag = await _uploadPart(
            file: file,
            partNumber: partNumber,
            uploadId: resolvedUploadId,
            remoteFileKey: remoteFileKey,
          );
          uploaded.add(UploadedPartSummary(partNumber: partNumber, eTag: eTag));
        },
      );
    }

    uploaded.sort((a, b) => a.partNumber.compareTo(b.partNumber));
    await apiClient.completeMultipart(
      remoteFileKey: remoteFileKey,
      uploadId: uploadId,
      parts: uploaded,
    );
    await _deletePersistedUploadId(file);
    await _moveToClouded(file, remoteFileKey);
    _reportTotals();
  }

  Future<String> _uploadPart({
    required File file,
    required int partNumber,
    required String uploadId,
    required String remoteFileKey,
  }) async {
    final start = (partNumber - 1) * partSizeBytes;
    final endExclusive = min(start + partSizeBytes, await file.length());

    // Read part bytes once to compute checksum and reuse for upload
    final partBytes = await file.openRead(start, endExclusive).fold<List<int>>(
      <int>[],
      (prev, chunk) {
        prev.addAll(chunk);
        return prev;
      },
    );
    final length = partBytes.length;

    // Compute Content-MD5 for Object Lock / checksum enforcement
    final md5Digest = md5.convert(partBytes);
    final contentMd5 = base64.encode(md5Digest.bytes);

    var attempt = 0;
    while (true) {
      attempt++;
      if (_uploadsEnabled == false) {
        throw UploadPausedException();
      }

      final bundle = await apiClient.getUrls(
        remoteFileKey: remoteFileKey,
        clientMethods: ['upload_part'],
        partNumber: partNumber,
        uploadId: uploadId,
        headers: {'content-md5': contentMd5},
      );

      final signed = bundle.firstWhere((u) => u.uploadPart != null);
      if (signed.expiresAt != null &&
          DateTime.now().isAfter(signed.expiresAt!)) {
        continue;
      }

      await _requestLimiter.acquire();
      late HttpClientResponse response;
      try {
        if (_uploadsEnabled == false) {
          throw UploadPausedException();
        }
        response = await apiClient.putStream(
          url: signed.uploadPart!,
          bytes: Stream.value(partBytes),
          contentLength: length,
          headers: {'Content-MD5': contentMd5},
        );
      } finally {
        _requestLimiter.release();
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final eTag = response.headers.value('etag');
        if (eTag == null || eTag.isEmpty) {
          throw StateError(
            'upload_part missing ETag for $remoteFileKey part $partNumber',
          );
        }
        _adjustPendingBytes(-length);
        return eTag;
      }

      if (response.statusCode == HttpStatus.forbidden && attempt < 3) {
        continue;
      }

      final body = await response.transform(utf8.decoder).join();
      throw HttpException(
        'Failed to upload part $partNumber for $remoteFileKey (${response.statusCode}): $body',
        uri: signed.uploadPart,
      );
    }
  }

  int _partLength(int fileSize, int partNumber) {
    final start = (partNumber - 1) * partSizeBytes;
    final endExclusive = min(start + partSizeBytes, fileSize);
    return endExclusive - start;
  }

  Future<void> _moveToClouded(File file, String remoteFileKey) async {
    final relative = remoteFileKey.replaceAll('\\', '/');
    final destination = File(p.join(cloudedBase.path, relative));
    await destination.parent.create(recursive: true);

    try {
      await file.rename(destination.path);
    } on FileSystemException {
      await file.copy(destination.path);
      await file.delete();
    }
  }

  String _buildRemoteFileKey(File file) {
    if (remoteFileKeyResolver != null) {
      return remoteFileKeyResolver!(file);
    }
    final relative = p.relative(file.path, from: pendingUploadBase.path);
    return p.toUri(relative).path;
  }

  Future<_ResolvedParts> _listPartsExhaustive({
    required String remoteFileKey,
    String? uploadId,
  }) async {
    var cursor = '';
    var resolvedUploadId = uploadId;
    final parts = <ListedPart>[];

    while (true) {
      final response = await apiClient.listParts(
        remoteFileKey: remoteFileKey,
        uploadId: resolvedUploadId,
        cursor: cursor.isEmpty ? null : cursor,
      );

      if (resolvedUploadId == null || resolvedUploadId.isEmpty) {
        if (response.uploadId != null && response.uploadId!.isNotEmpty) {
          resolvedUploadId = response.uploadId;
        }
      }

      parts.addAll(response.parts);

      final hasCursor = response.cursor != null && response.cursor!.isNotEmpty;
      final searchingForUploadId =
          (resolvedUploadId == null || resolvedUploadId.isEmpty) && hasCursor;
      final pagingParts = response.isTruncated && hasCursor;

      if (searchingForUploadId || pagingParts) {
        cursor = response.cursor!;
        continue;
      }

      break;
    }

    return _ResolvedParts(uploadId: resolvedUploadId, parts: parts);
  }

  Future<String?> _readPersistedUploadId(File file) async {
    final sidecar = File('${file.path}.uploadId');
    if (!await sidecar.exists()) return null;
    final contents = (await sidecar.readAsString()).trim();
    return contents.isEmpty ? null : contents;
  }

  Future<void> _persistUploadId(File file, String uploadId) async {
    final sidecar = File('${file.path}.uploadId');
    await sidecar.parent.create(recursive: true);
    await sidecar.writeAsString(uploadId, flush: true);
  }

  Future<void> _deletePersistedUploadId(File file) async {
    final sidecar = File('${file.path}.uploadId');
    if (await sidecar.exists()) {
      await sidecar.delete();
    }
  }
}

class _ResolvedParts {
  _ResolvedParts({required this.uploadId, required this.parts});

  final String? uploadId;
  final List<ListedPart> parts;
}

class UploadPausedException implements Exception {}

class ListedPart {
  ListedPart({
    required this.partNumber,
    required this.size,
    required this.eTag,
    this.lastModified,
  });

  final int partNumber;
  final int size;
  final String eTag;
  final DateTime? lastModified;
}

class ListPartsResponse {
  ListPartsResponse({
    required this.remoteFileKey,
    this.uploadId,
    required this.parts,
    this.isTruncated = false,
    this.cursor,
  });

  final String remoteFileKey;
  final String? uploadId;
  final List<ListedPart> parts;
  final bool isTruncated;
  final String? cursor;
}

class MultipartCreateResponse {
  MultipartCreateResponse({
    required this.remoteFileKey,
    required this.uploadId,
    this.bucket,
  });

  final String remoteFileKey;
  final String uploadId;
  final String? bucket;
}

class UploadedPartSummary {
  UploadedPartSummary({required this.partNumber, required this.eTag});

  final int partNumber;
  final String eTag;
}

class MediaApiClient extends MediaApiClientCore {
  MediaApiClient(super.baseUrl, {super.client});

  Future<ListPartsResponse> listParts({
    required String remoteFileKey,
    String? uploadId,
    String? cursor,
  }) async {
    final uri = getFullPath('/api/media/list-parts');
    final body = <String, dynamic>{'remoteFileKey': remoteFileKey};
    if (uploadId != null) body['uploadId'] = uploadId;
    if (cursor != null) body['cursor'] = cursor;

    final data = await postJson(uri, body);
    final rawUploadId = (data['UploadId'] as String?) ?? uploadId;
    final normalizedUploadId = rawUploadId == null || rawUploadId.isEmpty
        ? null
        : rawUploadId;
    final partsJson = (data['Parts'] as List<dynamic>? ?? []);
    final parts = partsJson.map((e) {
      final m = e as Map<String, dynamic>;
      DateTime? lastModified;
      final last = m['LastModified'];
      if (last is String) lastModified = DateTime.tryParse(last);
      return ListedPart(
        partNumber: (m['PartNumber'] as num).toInt(),
        size: (m['Size'] as num).toInt(),
        eTag: m['ETag'] as String,
        lastModified: lastModified,
      );
    }).toList();

    return ListPartsResponse(
      remoteFileKey: data['Key'] as String? ?? remoteFileKey,
      uploadId: normalizedUploadId,
      parts: parts,
      isTruncated: data['IsTruncated'] as bool? ?? false,
      cursor: data['Cursor'] as String?,
    );
  }

  Future<MultipartCreateResponse> createMultipart(String remoteFileKey) async {
    final uri = getFullPath('/api/media/multipart-create');
    final data = await postJson(uri, {'remoteFileKey': remoteFileKey});
    return MultipartCreateResponse(
      remoteFileKey: data['remoteFileKey'] as String? ?? remoteFileKey,
      uploadId: data['uploadId'] as String,
      bucket: data['bucket'] as String?,
    );
  }

  Future<void> completeMultipart({
    required String remoteFileKey,
    required String uploadId,
    required List<UploadedPartSummary> parts,
  }) async {
    final uri = getFullPath('/api/media/multipart-complete');
    final body = {
      'remoteFileKey': remoteFileKey,
      'uploadId': uploadId,
      'parts': parts
          .map((p) => {'partNumber': p.partNumber, 'eTag': p.eTag})
          .toList(),
    };

    await postJson(uri, body);
  }

  Future<HttpClientResponse> putStream({
    required Uri url,
    required Stream<List<int>> bytes,
    required int contentLength,
    Map<String, String>? headers,
  }) async {
    final request = await httpClient.putUrl(url);
    request.contentLength = contentLength;
    headers?.forEach(request.headers.set);
    await request.addStream(bytes);
    return request.close();
  }

  void close() {
    httpClient.close(force: true);
  }
}
