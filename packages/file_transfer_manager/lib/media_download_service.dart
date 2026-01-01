part of 'file_transfer_manager.dart';

class MediaDownloadService {
  static MediaDownloadService? _singleton;

  /// Returns the shared download service instance after initializing it once.
  /// Subsequent calls reuse the first-created instance so download queue state
  /// is shared across the app.
  static MediaDownloadService ensureSingleton({
    required MediaApiClient apiClient,
    required Directory cloudedBase,
    int maxDownloadRequestsConcurrency = _defaultDownloadRequestsConcurrency,
    int? chunkSizeOverride,
    PendingDownloadTotalsCallback? pendingDownloadsCallback,
  }) {
    _singleton ??= MediaDownloadService(
      apiClient: apiClient,
      cloudedBase: cloudedBase,
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
    this.maxDownloadRequestsConcurrency = _defaultDownloadRequestsConcurrency,
    this.chunkSizeOverride,
    this.pendingDownloadsCallback,
  }) : _requestLimiter = _RequestLimiter(maxDownloadRequestsConcurrency);

  final MediaApiClient apiClient;
  final Directory cloudedBase;
  final int maxDownloadRequestsConcurrency;
  final int? chunkSizeOverride;
  final PendingDownloadTotalsCallback? pendingDownloadsCallback;

  /// LIFO queue for downloads: prioritize most-recently requested downloads, unless addAsLowestPriority is true.
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
    bool addAsLowestPriority = false,
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

    if (addAsLowestPriority) {
      _queueLIFO.insert(0, job);
    } else {
      _queueLIFO.add(job);
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
          _runSingleDownload(job)
              .then((_) {
                _activeDownloads--;
                _adjustPendingDownloads(-1);
                _activeJobs.remove(job.remoteFileKey);
                _admitMoreJobs = true;
                _processingQueue = false;
                _processQueue();
              })
              .catchError((error, stack) {
                _activeDownloads--;
                _processingQueue = false;
                _admitMoreJobs = true;

                if (error is _DownloadPausedException ||
                    error is _DownloadTransientException) {
                  // Requeue incomplete job; do not decrement pending.
                  _activeJobs.remove(job.remoteFileKey);
                  _queueLIFO.add(job);
                  _processQueue();
                  return;
                }

                // Real failure: finish the job with error and adjust pending.
                _adjustPendingDownloads(-1);
                _activeJobs.remove(job.remoteFileKey);
                if (!job.completer.isCompleted) {
                  job.completer.completeError(error, stack);
                }
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
      var getUrl = signed.firstWhere((u) => u.getObject != null).getObject!;
      var expiresAt = signed.first.expiresAt!;

      Future<_RenewedUrl> refreshGetUrl() async {
        final refreshed = await apiClient.getUrls(
          remoteFileKey: job.remoteFileKey,
          clientMethods: ['get_object'],
        );
        final refreshedGet = refreshed
            .firstWhere((u) => u.getObject != null)
            .getObject!;
        final refreshedExpires = refreshed.first.expiresAt!;
        getUrl = refreshedGet;
        expiresAt = refreshedExpires;
        return _RenewedUrl(refreshedGet, refreshedExpires);
      }

      final headResponse = await apiClient.head(headUrl);
      if (headResponse.statusCode == HttpStatus.notFound) {
        throw DownloadNotFoundException(
          remoteFileKey: job.remoteFileKey,
          statusCode: headResponse.statusCode,
          uri: headUrl,
        );
      }
      if (headResponse.statusCode != HttpStatus.ok) {
        if (_isTransientStatus(headResponse.statusCode)) {
          throw _DownloadTransientException();
        }
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
          if (!_downloadsEnabled) {
            throw _DownloadPausedException();
          }
          final response = await _getWithRenewal(
            currentUrl: getUrl,
            expiresAt: expiresAt,
            renewUrl: refreshGetUrl,
            onRenewed: (url, newExpires) {
              getUrl = url;
              expiresAt = newExpires;
            },
          );
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
      final existingParts = <int>{};

      int expectedPartLength(int partNumber) {
        final start = (partNumber - 1) * chunkSize;
        final endExclusive = min(start + chunkSize, contentLength);
        return endExclusive - start;
      }

      Future<void> loadExistingParts() async {
        if (!await downloadDir.exists()) return;
        await for (final entity in downloadDir.list()) {
          if (entity is! File) continue;
          final name = p.basename(entity.path);
          final maybePart = name.split('-').last;
          final partNumber = int.tryParse(maybePart) ?? -1;
          if (partNumber <= 0) continue;

          final expectedLength = expectedPartLength(partNumber);
          final actualLength = await entity.length();
          if (actualLength == expectedLength) {
            existingParts.add(partNumber);
            partsCompleted++;
            bytesCompleted += actualLength;
          } else {
            await entity.delete(); // discard corrupt/incomplete part
          }
        }

        if (partsCompleted > 0) {
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
      }

      await loadExistingParts();

      if (!_downloadsEnabled) {
        throw _DownloadPausedException();
      }

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
        if (!_downloadsEnabled) {
          throw _DownloadPausedException();
        }
        await _requestLimiter.acquire();
        try {
          final response = await _getWithRenewal(
            currentUrl: getUrl,
            expiresAt: expiresAt,
            renewUrl: refreshGetUrl,
            onRenewed: (url, newExpires) {
              getUrl = url;
              expiresAt = newExpires;
            },
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

      // Download last part first if missing.
      if (!existingParts.contains(totalParts)) {
        if (!_downloadsEnabled) {
          throw _DownloadPausedException();
        }
        await downloadPart(totalParts);
      }

      final remainingParts = [
        for (var i = 1; i < totalParts; i++)
          if (!existingParts.contains(i)) i,
      ];
      remainingParts.shuffle(Random());

      if (remainingParts.isNotEmpty) {
        await _runWithConcurrency<int>(
          items: remainingParts,
          concurrency: maxDownloadRequestsConcurrency,
          worker: (part) => downloadPart(part).then((_) => null),
        );
      }

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
      if (e is _DownloadPausedException || e is _DownloadTransientException) {
        // Do not complete the future; let caller requeue.
        rethrow;
      }
      if (!job.completer.isCompleted) {
        job.completer.completeError(e, st);
      }
      rethrow;
    }
  }

  Future<Stream<List<int>>> _getWithRenewal({
    required Uri currentUrl,
    required Future<_RenewedUrl> Function() renewUrl,
    required void Function(Uri newUrl, DateTime newExpiresAt) onRenewed,
    required DateTime expiresAt,
    Map<String, String>? headers,
    int maxAttempts = 3,
    Duration earlyRefreshWindow = const Duration(minutes: 2),
  }) async {
    var attempts = 0;
    var url = currentUrl;
    var urlExpiry = expiresAt;

    Future<void> ensureFreshUrl() async {
      final now = DateTime.now();
      if (now.isAfter(urlExpiry) ||
          now.add(earlyRefreshWindow).isAfter(urlExpiry)) {
        final renewed = await renewUrl();
        url = renewed.url;
        urlExpiry = renewed.expiresAt;
        onRenewed(url, urlExpiry);
      }
    }

    while (true) {
      attempts++;
      await ensureFreshUrl();

      try {
        final response = await apiClient.get(url, headers: headers);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        if (_isTransientStatus(response.statusCode)) {
          throw _DownloadTransientException();
        }

        final body = await response.transform(utf8.decoder).join();
        final looksExpired = _looksLikeExpired(response.statusCode, body);
        final canRetry = attempts < maxAttempts && looksExpired;

        if (canRetry) {
          final renewed = await renewUrl();
          url = renewed.url;
          urlExpiry = renewed.expiresAt;
          onRenewed(url, urlExpiry);
          continue;
        }

        throw HttpException(
          'GET failed (${response.statusCode}): $body',
          uri: url,
        );
      } on SocketException catch (_) {
        throw _DownloadTransientException();
      } on HandshakeException catch (_) {
        throw _DownloadTransientException();
      }
    }
  }

  bool _looksLikeExpired(int statusCode, String body) {
    if (statusCode != HttpStatus.forbidden &&
        statusCode != HttpStatus.badRequest) {
      return false;
    }
    final lower = body.toLowerCase();
    return lower.contains('expired') || lower.contains('request has expired');
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

class _RenewedUrl {
  _RenewedUrl(this.url, this.expiresAt);

  final Uri url;
  final DateTime expiresAt;
}

class DownloadNotFoundException extends HttpException {
  DownloadNotFoundException({
    required this.remoteFileKey,
    required int statusCode,
    required super.uri,
  }) : super('Remote media missing ($statusCode) for $remoteFileKey');

  final String remoteFileKey;
}

class _DownloadPausedException implements Exception {}

class _DownloadTransientException implements Exception {}

bool _isTransientStatus(int statusCode) {
  return statusCode == HttpStatus.requestTimeout ||
      statusCode == 429 ||
      (statusCode >= 500 && statusCode < 600);
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
