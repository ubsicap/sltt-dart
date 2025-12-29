import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

/// fast and memory-efficient file concatenation
Future<void> concatenateFiles({
  required List<File> parts,
  required File output,
}) async {
  final sink = output.openWrite();

  try {
    for (final part in parts) {
      await sink.addStream(part.openRead());
    }
  } finally {
    await sink.close();
  }
}

const maxConcurrency = 4;
const _defaultPartSizeBytes = 5 * 1024 * 1024; // 5MB
const _defaultDownloadConcurrency = 4;

typedef PendingUploadTotalsCallback = void Function(int files, int bytes);
typedef PendingDownloadTotalsCallback = void Function(int files);

/// Adaptive chunk size based on file size
int chooseChunkSize(int fileSizeBytes) {
  if (fileSizeBytes < 20 * 1024 * 1024) return fileSizeBytes;
  if (fileSizeBytes < 200 * 1024 * 1024) return 2 * 1024 * 1024;
  if (fileSizeBytes < 1000 * 1024 * 1024) return 5 * 1024 * 1024;
  return 10 * 1024 * 1024;
}

class SignedUrlBundle {
  SignedUrlBundle({
    required this.remoteFileKey,
    this.headObject,
    this.getObject,
    this.uploadPart,
    this.partNumber,
    this.uploadId,
    this.expiresAt,
  });

  final String remoteFileKey;
  final Uri? headObject;
  final Uri? getObject;
  final Uri? uploadPart;
  final int? partNumber;
  final String? uploadId;
  final DateTime? expiresAt;

  factory SignedUrlBundle.fromJson(Map<String, dynamic> json) {
    DateTime? expires;
    final expiresRaw = json['expiresAt'];
    if (expiresRaw is String) {
      expires = DateTime.tryParse(expiresRaw);
    }

    return SignedUrlBundle(
      remoteFileKey: json['remoteFileKey'] as String,
      headObject: json['head_object'] != null
          ? Uri.parse(json['head_object'] as String)
          : null,
      getObject: json['get_object'] != null
          ? Uri.parse(json['get_object'] as String)
          : null,
      uploadPart: json['upload_part'] != null
          ? Uri.parse(json['upload_part'] as String)
          : null,
      partNumber: json['partNumber'] as int?,
      uploadId: json['uploadId'] as String?,
      expiresAt: expires,
    );
  }
}

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

class MediaApiClient {
  MediaApiClient(String baseUrl, {HttpClient? client})
    : baseUri = Uri.parse(baseUrl),
      httpClient = client ?? HttpClient();

  final Uri baseUri;
  final HttpClient httpClient;

  Uri _path(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    final base = baseUri.toString().replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base/$normalized');
  }

  Future<Map<String, dynamic>> _postJson(
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    final request = await httpClient.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));

    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(text) as Map<String, dynamic>;
    }

    throw HttpException(
      'POST ${uri.path} failed (${response.statusCode}): $text',
      uri: uri,
    );
  }

  Future<List<SignedUrlBundle>> getUrls({
    required String remoteFileKey,
    required List<String> clientMethods,
    int? partNumber,
    String? uploadId,
  }) async {
    final uri = _path('/api/media/get-urls');
    final body = <String, dynamic>{
      'remoteFileKey': remoteFileKey,
      'clientMethods': clientMethods,
    };

    if (partNumber != null) body['partNumber'] = partNumber;
    if (uploadId != null) body['uploadId'] = uploadId;

    final data = await _postJson(uri, body);
    final urls = (data['urls'] as List<dynamic>? ?? [])
        .map((e) => SignedUrlBundle.fromJson(e as Map<String, dynamic>))
        .toList();

    return urls;
  }

  Future<ListPartsResponse> listParts({
    required String remoteFileKey,
    String? uploadId,
    String? cursor,
  }) async {
    final uri = _path('/api/media/list-parts');
    final body = <String, dynamic>{'remoteFileKey': remoteFileKey};
    if (uploadId != null) body['uploadId'] = uploadId;
    if (cursor != null) body['cursor'] = cursor;

    final data = await _postJson(uri, body);
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
    final uri = _path('/api/media/multipart-create');
    final data = await _postJson(uri, {'remoteFileKey': remoteFileKey});
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
    final uri = _path('/api/media/multipart-complete');
    final body = {
      'remoteFileKey': remoteFileKey,
      'uploadId': uploadId,
      'parts': parts
          .map((p) => {'partNumber': p.partNumber, 'eTag': p.eTag})
          .toList(),
    };

    await _postJson(uri, body);
  }

  Future<HttpClientResponse> head(Uri url) async {
    final request = await httpClient.openUrl('HEAD', url);
    return request.close();
  }

  Future<HttpClientResponse> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final request = await httpClient.getUrl(url);
    headers?.forEach(request.headers.set);
    return request.close();
  }

  Future<HttpClientResponse> putStream({
    required Uri url,
    required Stream<List<int>> bytes,
    required int contentLength,
  }) async {
    final request = await httpClient.putUrl(url);
    request.contentLength = contentLength;
    await request.addStream(bytes);
    return request.close();
  }

  void close() {
    httpClient.close(force: true);
  }
}

class MediaUploadService {
  MediaUploadService({
    required this.apiClient,
    required this.pendingUploadBase,
    required this.cloudedBase,
    this.remoteFileKeyResolver,
    this.partSizeBytes = _defaultPartSizeBytes,
    this.maxPartConcurrency = maxConcurrency,
    this.pendingTotalsCallback,
  });

  final MediaApiClient apiClient;
  final Directory pendingUploadBase;
  final Directory cloudedBase;
  final String Function(File file)? remoteFileKeyResolver;
  final int partSizeBytes;
  final int maxPartConcurrency;
  final PendingUploadTotalsCallback? pendingTotalsCallback;

  bool _processing = false;
  bool _rerunRequested = false;
  final Random _random = Random();
  bool _uploadsEnabled = false;
  StreamSubscription<FileSystemEvent>? _uploadWatch;
  void _reportTotals() =>
      pendingTotalsCallback?.call(_pendingFiles, _pendingBytes);

  void _adjustPendingFiles(int delta) {
    _pendingFiles = ((_pendingFiles + delta).clamp(0, 1 << 30));
    _reportTotals();
  }

  void _adjustPendingBytes(int delta) {
    _pendingBytes = ((_pendingBytes + delta).clamp(0, 1 << 62));
    _reportTotals();
  }

  int _pendingFiles = 0;
  int _pendingBytes = 0;

  Future<void> watchAndProcess() async => startProcessingUploads();

  Future<void> startProcessingUploads() async {
    _uploadsEnabled = true;
    _ensureUploadWatch();
    await processPendingUploads();
  }

  Future<void> resumeProcessingUploads() async => startProcessingUploads();

  Future<void> stopProcessingUploads() async {
    _uploadsEnabled = false;
    _rerunRequested = false;
  }

  Future<void> dispose() async {
    _uploadsEnabled = false;
    _rerunRequested = false;
    await _uploadWatch?.cancel();
    _uploadWatch = null;
  }

  void _ensureUploadWatch() {
    if (_uploadWatch != null) return;
    _uploadWatch = pendingUploadBase.watch(recursive: true).listen((
      event,
    ) async {
      if (_processing) {
        _rerunRequested = true;
        return;
      }
      await processPendingUploads();
    });
  }

  Future<void> processPendingUploads() async {
    if (_processing) {
      _rerunRequested = true;
      return;
    }

    _processing = true;
    try {
      _pendingFiles = 0;
      _pendingBytes = 0;
      final files = await _collectFiles();
      if (_uploadsEnabled) {
        for (final file in files) {
          await _uploadFile(file);
        }
      }
    } finally {
      _processing = false;
    }

    if (_rerunRequested) {
      _rerunRequested = false;
      await processPendingUploads();
    }
  }

  Future<List<File>> _collectFiles() async {
    final files = <File>[];
    await for (final entity in pendingUploadBase.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) {
        final size = await entity.length();
        files.add(entity);
        _adjustPendingFiles(1);
        _adjustPendingBytes(size);
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
      _adjustPendingFiles(-1);
      await _moveToClouded(file, remoteFileKey);
      return;
    }

    final listed = await apiClient.listParts(remoteFileKey: remoteFileKey);
    final existingParts = <int, String>{
      for (final part in listed.parts) part.partNumber: part.eTag,
    };

    final uploadId =
        listed.uploadId ??
        (await apiClient.createMultipart(remoteFileKey)).uploadId;

    final totalParts = (fileSize / partSizeBytes).ceil();
    final missingParts = <int>[];
    for (var partNumber = 1; partNumber <= totalParts; partNumber++) {
      if (!existingParts.containsKey(partNumber)) {
        missingParts.add(partNumber);
      }
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

    if (missingParts.isNotEmpty) {
      await _runWithConcurrency<int>(
        items: missingParts,
        concurrency: maxPartConcurrency,
        worker: (partNumber) async {
          final eTag = await _uploadPart(
            file: file,
            partNumber: partNumber,
            uploadId: uploadId,
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

    _adjustPendingFiles(-1);
    await _moveToClouded(file, remoteFileKey);
  }

  Future<String> _uploadPart({
    required File file,
    required int partNumber,
    required String uploadId,
    required String remoteFileKey,
  }) async {
    final start = (partNumber - 1) * partSizeBytes;
    final endExclusive = min(start + partSizeBytes, await file.length());
    final length = endExclusive - start;

    var attempt = 0;
    while (true) {
      attempt++;
      final bundle = await apiClient.getUrls(
        remoteFileKey: remoteFileKey,
        clientMethods: ['upload_part'],
        partNumber: partNumber,
        uploadId: uploadId,
      );

      final signed = bundle.firstWhere((u) => u.uploadPart != null);
      if (signed.expiresAt != null &&
          DateTime.now().isAfter(signed.expiresAt!)) {
        continue;
      }

      final stream = file.openRead(start, endExclusive);
      final response = await apiClient.putStream(
        url: signed.uploadPart!,
        bytes: stream,
        contentLength: length,
      );

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
}

class MediaDownloadService {
  MediaDownloadService({
    required this.apiClient,
    required this.cloudedBase,
    this.maxPartConcurrency = maxConcurrency,
    this.maxDownloadConcurrency = _defaultDownloadConcurrency,
    this.chunkSizeOverride,
    this.pendingDownloadsCallback,
  });

  final MediaApiClient apiClient;
  final Directory cloudedBase;
  final int maxPartConcurrency;
  final int maxDownloadConcurrency;
  final int? chunkSizeOverride;
  final PendingDownloadTotalsCallback? pendingDownloadsCallback;

  final List<_DownloadJob> _queue = [];
  int _activeDownloads = 0;
  bool _processingQueue = false;
  int _pendingDownloads = 0;
  bool _downloadsEnabled = false;

  void _reportPendingDownloads() =>
      pendingDownloadsCallback?.call(_pendingDownloads);

  void _adjustPendingDownloads(int delta) {
    _pendingDownloads = ((_pendingDownloads + delta).clamp(0, 1 << 30));
    _reportPendingDownloads();
  }

  void stopProcessingDownloads() {
    _downloadsEnabled = false;
  }

  void startProcessingDownloads() {
    _downloadsEnabled = true;
    _processQueue();
  }

  void resumeProcessingDownloads() => startProcessingDownloads();

  Future<File> enqueueDownload({
    required String remoteFileKey,
    String? fileName,
    bool addToFront = false,
    required DownloadProgressCallback onProgress,
  }) {
    _adjustPendingDownloads(1);
    final job = _DownloadJob(
      remoteFileKey: remoteFileKey,
      fileName: fileName,
      onProgress: onProgress,
    );

    // Signal queued state.
    onProgress(
      DownloadProgress(
        partsCompleted: -1,
        partsTotal: 0,
        bytesCompleted: 0,
        bytesTotal: 0,
        bytesPerChunk: 0,
      ),
    );

    if (addToFront) {
      _queue.insert(0, job);
    } else {
      _queue.add(job);
    }

    _processQueue();
    return job.completer.future;
  }

  void _processQueue() {
    if (_processingQueue || !_downloadsEnabled) return;
    _processingQueue = true;

    Future<void>.microtask(() async {
      try {
        while (_downloadsEnabled &&
            _activeDownloads < maxDownloadConcurrency &&
            _queue.isNotEmpty) {
          final job = _queue.removeAt(0);
          _activeDownloads++;
          _runSingleDownload(job).whenComplete(() {
            _activeDownloads--;
            _adjustPendingDownloads(-1);
            _processingQueue = false;
            _processQueue();
          });
        }
      } finally {
        _processingQueue = false;
      }
    });
  }

  Future<File> _runSingleDownload(_DownloadJob job) async {
    try {
      final signed = await apiClient.getUrls(
        remoteFileKey: job.remoteFileKey,
        clientMethods: ['head_object', 'get_object'],
      );

      final headUrl = signed
          .firstWhere((u) => u.headObject != null)
          .headObject!;
      final getUrl = signed.firstWhere((u) => u.getObject != null).getObject!;
      final expiresAt = signed.first.expiresAt;

      final headResponse = await apiClient.head(headUrl);
      if (headResponse.statusCode != HttpStatus.ok) {
        throw HttpException(
          'HEAD failed for ${job.remoteFileKey} (${headResponse.statusCode})',
          uri: headUrl,
        );
      }

      final contentLengthStr = headResponse.headers.value(
        HttpHeaders.contentLengthHeader,
      );
      if (contentLengthStr == null) {
        throw StateError('Missing content-length for ${job.remoteFileKey}');
      }

      final contentLength = int.parse(contentLengthStr);
      final resolvedFileName = job.fileName ?? p.basename(job.remoteFileKey);
      final targetDir = Directory(
        p.join(
          cloudedBase.path,
          resolvedFileName.length >= 7
              ? resolvedFileName.substring(0, 7)
              : resolvedFileName,
        ),
      );
      await targetDir.create(recursive: true);

      final chunkSize = chunkSizeOverride ?? chooseChunkSize(contentLength);
      final totalParts = (contentLength / chunkSize).ceil();

      job.onProgress(
        DownloadProgress(
          partsCompleted: 0,
          partsTotal: totalParts,
          bytesCompleted: 0,
          bytesTotal: contentLength,
          bytesPerChunk: chunkSize,
        ),
      );

      if (chunkSize >= contentLength) {
        final destFile = File(p.join(targetDir.path, resolvedFileName));
        final response = await _getWithRenewal(getUrl, expiresAt);
        final sink = destFile.openWrite();
        await sink.addStream(response);
        await sink.close();

        job.onProgress(
          DownloadProgress(
            partsCompleted: totalParts,
            partsTotal: totalParts,
            bytesCompleted: contentLength,
            bytesTotal: contentLength,
            bytesPerChunk: chunkSize,
          ),
        );
        job.completer.complete(destFile);
        return destFile;
      }

      final downloadDir = Directory(
        p.join(cloudedBase.path, '__downloading', resolvedFileName),
      );
      await downloadDir.create(recursive: true);

      var partsCompleted = 0;
      var bytesCompleted = 0;
      void reportProgress(int partBytes) {
        partsCompleted++;
        bytesCompleted += partBytes;
        job.onProgress(
          DownloadProgress(
            partsCompleted: partsCompleted,
            partsTotal: totalParts,
            bytesCompleted: bytesCompleted,
            bytesTotal: contentLength,
            bytesPerChunk: chunkSize,
          ),
        );
      }

      Future<File> downloadPart(int partNumber) async {
        final start = (partNumber - 1) * chunkSize;
        final end = min(contentLength - 1, start + chunkSize - 1);
        final response = await _getWithRenewal(
          getUrl,
          expiresAt,
          headers: {HttpHeaders.rangeHeader: 'bytes=$start-$end'},
        );

        final partFile = File(
          p.join(
            downloadDir.path,
            '$resolvedFileName-${partNumber.toString().padLeft(7, '0')}',
          ),
        );
        final sink = partFile.openWrite();
        await sink.addStream(response);
        await sink.close();
        reportProgress(end - start + 1);
        return partFile;
      }

      // Download last part first.
      await downloadPart(totalParts);

      final remainingParts = [for (var i = 1; i < totalParts; i++) i];
      remainingParts.shuffle(Random());

      await _runWithConcurrency<int>(
        items: remainingParts,
        concurrency: maxPartConcurrency,
        worker: (part) => downloadPart(part).then((_) => null),
      );

      final orderedParts = [for (var i = 1; i <= totalParts; i++) i]
          .map(
            (part) => File(
              p.join(
                downloadDir.path,
                '$resolvedFileName-${part.toString().padLeft(7, '0')}',
              ),
            ),
          )
          .toList();

      final destFile = File(p.join(targetDir.path, resolvedFileName));
      await concatenateFiles(parts: orderedParts, output: destFile);

      await downloadDir.delete(recursive: true);
      job.onProgress(
        DownloadProgress(
          partsCompleted: totalParts,
          partsTotal: totalParts,
          bytesCompleted: contentLength,
          bytesTotal: contentLength,
          bytesPerChunk: chunkSize,
        ),
      );
      job.completer.complete(destFile);
      return destFile;
    } catch (e, st) {
      if (!job.completer.isCompleted) {
        job.completer.completeError(e, st);
      }
      rethrow;
    }
  }

  Future<Stream<List<int>>> _getWithRenewal(
    Uri initialUrl,
    DateTime? expiresAt, {
    Map<String, String>? headers,
  }) async {
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      throw StateError('Signed URL expired before download started');
    }

    final response = await apiClient.get(initialUrl, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    final body = await response.transform(utf8.decoder).join();
    throw HttpException(
      'GET failed (${response.statusCode}): $body',
      uri: initialUrl,
    );
  }
}

class DownloadProgress {
  DownloadProgress({
    required this.partsCompleted,
    required this.partsTotal,
    required this.bytesCompleted,
    required this.bytesTotal,
    required this.bytesPerChunk,
  });

  final int partsCompleted;
  final int partsTotal;
  final int bytesCompleted;
  final int bytesTotal;
  final int bytesPerChunk;
}

typedef DownloadProgressCallback = void Function(DownloadProgress progress);

class _DownloadJob {
  _DownloadJob({
    required this.remoteFileKey,
    this.fileName,
    required this.onProgress,
  });

  final String remoteFileKey;
  final String? fileName;
  final DownloadProgressCallback onProgress;
  final Completer<File> completer = Completer<File>();
}

Future<void> _runWithConcurrency<T>({
  required List<T> items,
  required int concurrency,
  required Future<void> Function(T item) worker,
}) async {
  if (items.isEmpty) return;

  final capped = concurrency <= 0 ? 1 : min(concurrency, items.length);
  var index = 0;

  Future<void> runWorker() async {
    while (true) {
      if (index >= items.length) return;
      final item = items[index++];
      await worker(item);
    }
  }

  await Future.wait(List.generate(capped, (_) => runWorker()));
}
