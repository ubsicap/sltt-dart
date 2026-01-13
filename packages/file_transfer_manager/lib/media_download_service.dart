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
  final List<_DownloadJob> _retryLaterJobs = [];
  final Map<String, _DownloadJob> _activeJobs = {};
  final _RequestLimiter _requestLimiter;
  int _activeDownloads = 0;
  bool _processingQueue = false;
  bool _admitMoreJobs = true;
  bool _downloadsEnabled = false;
  String _lastErrorMessage = '';

  void _reportPendingDownloads() => pendingDownloadsCallback?.call(
    queuedFiles: _queueLIFO.map((job) => job.remoteFileKey).toList(),
    inProgressFiles: _activeJobs.keys.toList(),
    erroredFiles: _retryLaterJobs
        .where(
          (job) => [
            RetryReason.transientError,
            RetryReason.unknown,
          ].contains(job.retryReason),
        )
        .map((job) {
          return {
            'remoteFileKey': job.remoteFileKey,
            'errorMessage': job.lastErrorMessage ?? '',
            'retryReason': job.retryReason.toString(),
          };
        })
        .toList(),
    missingFiles: _retryLaterJobs
        .where((job) => job.retryReason == RetryReason.notFound)
        .map((job) => job.remoteFileKey)
        .toList(),
    errorMessage: _lastErrorMessage,
  );

  void stopProcessingDownloads() {
    _downloadsEnabled = false;
  }

  void startProcessingDownloads() {
    if (_retryLaterJobs.isNotEmpty) {
      // preserve top priority queue job
      final topPriorityJob = _queueLIFO.isNotEmpty
          ? _queueLIFO.removeLast()
          : null;
      // user re-started downloads, so just add retries back to the main queue
      for (final retryJob in _retryLaterJobs) {
        _queueLIFO.add(retryJob);
      }
      _retryLaterJobs.clear();
      // re-add preserved top priority job
      if (topPriorityJob != null) {
        _queueLIFO.add(topPriorityJob);
      }
    }
    // re-add current job as top priority
    _downloadsEnabled = true;
    _processQueue();
  }

  void resumeProcessingDownloads() => startProcessingDownloads();

  Future<File> enqueueDownload({
    required String remoteFileKey,
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

    final job = _DownloadJob(
      remoteFileKey: remoteFileKey,
      fileName: p.basename(remoteFileKey),
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
    if (_retryLaterJobs.isNotEmpty) {
      // if job got enqueued again remove from retry list
      _retryLaterJobs.removeWhere(
        (job) => _queueLIFO.any(
          (queuedJob) => queuedJob.remoteFileKey == job.remoteFileKey,
        ),
      );
      final now = DateTime.now();
      final readyJobs = _retryLaterJobs.where((job) {
        final retryAt = job.retryAt;
        return retryAt != null && now.isAfter(retryAt);
      }).toList();
      for (final job in readyJobs) {
        _retryLaterJobs.remove(job);
        _queueLIFO.add(job);
      }
    }
    _reportPendingDownloads();
    _lastErrorMessage = ''; // clear last error on new processing attempt
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
                    error is _DownloadTransientException ||
                    error is DownloadNotFoundException) {
                  _activeJobs.remove(job.remoteFileKey);
                  // Requeue incomplete job; do not decrement pending.
                  if (error is _DownloadTransientException ||
                      error is DownloadNotFoundException) {
                    if (error is DownloadNotFoundException) {
                      job.retryReason = RetryReason.notFound;
                    } else if (error is _DownloadTransientException) {
                      job.retryReason = RetryReason.transientError;
                    } else {
                      job.retryReason = RetryReason.unknown;
                    }
                    job.lastErrorMessage = error.toString();
                    job.retryAt = DateTime.now().add(
                      const Duration(minutes: 1),
                    );
                    job.tries += 1;
                    _retryLaterJobs.add(job);
                    _lastErrorMessage = error.toString();
                  } else {
                    // re-add current job as top priority
                    _queueLIFO.add(job);
                  }
                  _processQueue();
                  return;
                }

                job.lastErrorMessage = error.toString();
                _lastErrorMessage = error.toString();

                // Real failure: finish the job with error and adjust pending.
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
        final newError = DownloadNotFoundException(
          remoteFileKey: job.remoteFileKey,
          statusCode: headResponse.statusCode,
          uri: headUrl,
        );
        job.onProgress(
          DownloadProgress(
            partsCompleted: 0,
            partsTotal: 0,
            bytesCompleted: 0,
            bytesTotal: 0,
            bytesPerChunk: 0,
            errorMessage: newError.toString(),
          ),
        );
        throw newError;
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
      final targetDir = Directory(
        p.normalize(p.join(cloudedBase.path, p.dirname(job.remoteFileKey))),
      );
      await targetDir.create(recursive: true);

      final chunkSize = chunkSizeOverride ?? chooseChunkSize(contentLength);
      final totalParts = (contentLength / chunkSize).ceil();

      final remainingDownloadSlots = _requestLimiter.availablePermits;
      if (remainingDownloadSlots > 0 && totalParts < remainingDownloadSlots) {
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
        final destFile = File(p.join(targetDir.path, job.fileName));
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
        p.join(cloudedBase.path, '__downloading', job.fileName),
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
              '${job.fileName}-${partNumber.toString().padLeft(7, '0')}',
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
                '${job.fileName}-${part.toString().padLeft(7, '0')}',
              ),
            ),
          )
          .toList();

      final destFile = File(p.join(targetDir.path, job.fileName));
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
    this.errorMessage = '',
  });

  final int partsCompleted;
  final int partsTotal;
  final int bytesCompleted;
  final int bytesTotal;
  final int bytesPerChunk;
  final String errorMessage;
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

  int tries = 0;
  RetryReason? retryReason;
  DateTime? retryAt;
  final String remoteFileKey;
  final String? fileName;
  String? lastErrorMessage;
  final DownloadProgressCallback onProgress;
  final Completer<File> completer = Completer<File>();
}

enum RetryReason { unknown, transientError, notFound }

/// Adaptive chunk size for cross‑platform downloads (mobile + desktop)
/// tuned for 4 parallel requests.
int chooseChunkSize(int fileSizeBytes) {
  // Minimum chunk size: 1 MB (avoid 0.5 MB when using 4 parallel streams)
  if (fileSizeBytes < 20 * 1024 * 1024) return 1 * 1024 * 1024; // 1 MB

  // Medium files: 2 MB chunks
  if (fileSizeBytes < 200 * 1024 * 1024) return 2 * 1024 * 1024; // 2 MB

  // Large files: 5 MB chunks
  if (fileSizeBytes < 2 * 1024 * 1024 * 1024) return 5 * 1024 * 1024; // 5 MB

  // Very large (multi‑GB) files: 8 MB chunks
  return 8 * 1024 * 1024; // 8 MB
}
