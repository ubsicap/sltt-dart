part of 'file_transfer_manager.dart';

class MediaDownloadService {
  static MediaDownloadService? _singleton;

  /// Returns the shared download service instance after initializing it once.
  /// Subsequent calls reuse the first-created instance so download queue state
  /// is shared across the app.
  static MediaDownloadService ensureSingleton({
    required MediaApiClient apiClient,
    required Directory cloudedBase,
    int maxPartConcurrency = maxConcurrency,
    int maxDownloadConcurrency = _defaultDownloadConcurrency,
    int maxDownloadRequestsConcurrency = _defaultDownloadRequestsConcurrency,
    int? chunkSizeOverride,
    PendingDownloadTotalsCallback? pendingDownloadsCallback,
  }) {
    _singleton ??= MediaDownloadService(
      apiClient: apiClient,
      cloudedBase: cloudedBase,
      maxPartConcurrency: maxPartConcurrency,
      maxDownloadRequestsConcurrency: maxDownloadRequestsConcurrency,
      chunkSizeOverride: chunkSizeOverride,
      pendingDownloadsCallback: pendingDownloadsCallback,
    );
    return _singleton!;
  }

  static MediaDownloadService? get instance => _singleton;

  static void clearInstance() {
    _singleton = null;
  }

  MediaDownloadService({
    required this.apiClient,
    required this.cloudedBase,
    this.maxPartConcurrency = maxConcurrency,
    this.maxDownloadRequestsConcurrency = _defaultDownloadRequestsConcurrency,
    this.chunkSizeOverride,
    this.pendingDownloadsCallback,
  }) : _requestLimiter = _RequestLimiter(maxDownloadRequestsConcurrency);

  final MediaApiClient apiClient;
  final Directory cloudedBase;
  final int maxPartConcurrency;
  final int maxDownloadRequestsConcurrency;
  final int? chunkSizeOverride;
  final PendingDownloadTotalsCallback? pendingDownloadsCallback;

  /// LIFO queue for downloads: prioritize most-recently requested downloads, unless addToEnd is true.
  final List<_DownloadJob> _queueLIFO = [];
  final Map<String, _DownloadJob> _activeJobs = {};
  final _RequestLimiter _requestLimiter;
  int _activeDownloads = 0;
  bool _processingQueue = false;
  bool _admitMoreJobs = true;
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
    bool addToEnd = true,
    required DownloadProgressCallback onProgress,
  }) {
    final activeJob = _activeJobs[remoteFileKey];
    if (activeJob != null) {
      return activeJob.completer.future;
    }

    final existingIndex = _queueLIFO.indexWhere(
      (job) => job.remoteFileKey == remoteFileKey,
    );
    if (existingIndex != -1) {
      final existingJob = _queueLIFO.removeAt(existingIndex);
      _queueLIFO.add(existingJob);
      return existingJob.completer.future;
    }

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

    if (addToEnd) {
      _queueLIFO.add(job);
    } else {
      _queueLIFO.insert(0, job);
    }

    _processQueue();
    return job.completer.future;
  }

  void _processQueue() {
    if (_processingQueue || !_downloadsEnabled || !_admitMoreJobs) return;
    _processingQueue = true;

    Future<void>.microtask(() async {
      try {
        while (_downloadsEnabled &&
            _activeDownloads < maxDownloadRequestsConcurrency &&
            _queueLIFO.isNotEmpty &&
            _admitMoreJobs) {
          final job = _queueLIFO.removeLast();
          _activeJobs[job.remoteFileKey] = job;
          _activeDownloads++;
          _admitMoreJobs = false; // pause admitting until job signals readiness
          _runSingleDownload(job).whenComplete(() {
            _activeDownloads--;
            _adjustPendingDownloads(-1);
            _activeJobs.remove(job.remoteFileKey);
            _admitMoreJobs = true;
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
      if (headResponse.statusCode == HttpStatus.notFound) {
        throw DownloadNotFoundException(
          remoteFileKey: job.remoteFileKey,
          statusCode: headResponse.statusCode,
          uri: headUrl,
        );
      }
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

      final allowsAnotherJob = totalParts < maxDownloadRequestsConcurrency;
      if (allowsAnotherJob) {
        _admitMoreJobs = true;
        _processQueue();
      }

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
        await _requestLimiter.acquire();
        try {
          final response = await _getWithRenewal(getUrl, expiresAt);
          final sink = destFile.openWrite();
          await sink.addStream(response);
          await sink.close();
        } finally {
          _requestLimiter.release();
        }

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
        await _requestLimiter.acquire();
        try {
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
        } finally {
          _requestLimiter.release();
        }
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

class DownloadNotFoundException extends HttpException {
  DownloadNotFoundException({
    required this.remoteFileKey,
    required int statusCode,
    required super.uri,
  }) : super('Remote media missing ($statusCode) for $remoteFileKey');

  final String remoteFileKey;
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

class _RequestLimiter {
  _RequestLimiter(int permits) : _permits = permits <= 0 ? 1 : permits;

  int _permits;
  final Queue<Completer<void>> _waiters = Queue();

  Future<void> acquire() {
    if (_permits > 0) {
      _permits--;
      return Future.value();
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    return completer.future;
  }

  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
      return;
    }
    _permits++;
  }
}
