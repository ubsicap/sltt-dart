import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_transfer_manager/media_transfer_service_shared.dart'
    show
        RequestLimiter,
        concatenateFiles,
        runWithConcurrency,
        MediaApiClientCore,
        TransferJob,
        shouldAdmitMoreTransfers;
import 'package:path/path.dart' as p;

const _defaultDownloadRequestsConcurrency = 4;

class PendingDownloadTotalsMessage {
  PendingDownloadTotalsMessage({
    this.errorMessage = '',
    this.queuedFiles = const [],
    this.missingFiles = const [],
    this.erroredFiles = const [],
    this.inProgressFiles = const [],
    this.isProcessing = false,
  });

  final String errorMessage;
  final List<String> queuedFiles;
  final List<String> missingFiles;
  final List<Map<String, String>> erroredFiles;
  final List<String> inProgressFiles;
  final bool isProcessing;
}

class MediaDownloadService {
  static MediaDownloadService? _singleton;

  /// Returns the shared download service instance after initializing it once.
  /// Subsequent calls reuse the first-created instance so download queue state
  /// is shared across the app.
  static MediaDownloadService ensureSingleton({
    required MediaApiClientCore apiClient,
    required Directory cloudedBase,
    int maxDownloadRequestsConcurrency = _defaultDownloadRequestsConcurrency,
    int? chunkSizeOverride,
  }) {
    _singleton ??= MediaDownloadService(
      apiClient: apiClient,
      cloudedBase: cloudedBase,
      maxDownloadRequestsConcurrency: maxDownloadRequestsConcurrency,
      chunkSizeOverride: chunkSizeOverride,
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
  }) : _requestLimiter = RequestLimiter(maxDownloadRequestsConcurrency);

  final MediaApiClientCore apiClient;
  final Directory cloudedBase;
  final int maxDownloadRequestsConcurrency;
  final int? chunkSizeOverride;
  final _pendingDownloadTotalsEvents =
      StreamController<PendingDownloadTotalsMessage>.broadcast();

  Stream<PendingDownloadTotalsMessage> get pendingDownloadsStream =>
      _pendingDownloadTotalsEvents.stream;

  /// LIFO queue for downloads: prioritize most-recently requested downloads, unless addAsLowestPriority is true.
  final List<TransferJob<DownloadProgress, File>> _queueLIFO = [];
  final Map<String, _RetryLater> _retryLaterJobs = {};
  final Map<String, TransferJob<DownloadProgress, File>> _activeJobs = {};
  final RequestLimiter _requestLimiter;
  int _activeDownloads = 0;
  bool _processingQueue = false;
  bool _admitMoreJobs = true;
  bool _downloadsEnabled = false;

  void _clearRetryLaterJobs({
    bool cancelTimers = false,
    bool removeEntries = true,
  }) {
    if (cancelTimers) {
      for (final retry in _retryLaterJobs.values) {
        retry.timer.cancel();
      }
    }
    if (removeEntries) {
      _retryLaterJobs.clear();
    }
  }

  void _cancelRetryLaterJob(String remoteFileKey) {
    final retry = _retryLaterJobs.remove(remoteFileKey);
    retry?.timer.cancel();
  }

  void _scheduleRetry(TransferJob<DownloadProgress, File> job) {
    final now = DateTime.now();
    final retryAt = job.retryAt;
    final delay = retryAt == null
        ? const Duration(minutes: 1)
        : retryAt.isBefore(now)
        ? Duration.zero
        : retryAt.difference(now);

    _cancelRetryLaterJob(job.remoteFileKey);

    final timer = Timer(delay, () {
      _cancelRetryLaterJob(job.remoteFileKey);
      enqueueDownload(
        remoteFileKey: job.remoteFileKey,
        addAsLowestPriority: true,
      );
    });

    _retryLaterJobs[job.remoteFileKey] = _RetryLater(job: job, timer: timer);
  }

  void dispose() {
    _downloadsEnabled = false;
    _clearRetryLaterJobs(cancelTimers: true, removeEntries: false);
    final seen = <TransferJob<DownloadProgress, File>>{};
    void closeJob(TransferJob<DownloadProgress, File> job) {
      if (seen.contains(job)) return;
      seen.add(job);
      if (!job.progressController.isClosed) {
        job.progressController.addError(
          StateError('Download service disposed'),
        );
        job.progressController.close();
      }
    }

    _activeJobs.values.forEach(closeJob);
    _queueLIFO.forEach(closeJob);
    for (final retry in _retryLaterJobs.values) {
      closeJob(retry.job);
    }
    _retryLaterJobs.clear();
    _pendingDownloadTotalsEvents.close();
  }

  Stream<PendingDownloadTotalsMessage> get pendingDownloadTotalsEvents =>
      _pendingDownloadTotalsEvents.stream;

  void _reportPendingDownloads({String errorMessage = ''}) =>
      _pendingDownloadTotalsEvents.isClosed
      ? null
      : _pendingDownloadTotalsEvents.add(
          PendingDownloadTotalsMessage(
            isProcessing: _downloadsEnabled,
            queuedFiles: _queueLIFO.map((job) => job.remoteFileKey).toList(),
            inProgressFiles: _activeJobs.keys.toList(),
            erroredFiles: _retryLaterJobs.values
                .where(
                  (retry) => [
                    RetryReason.transientError,
                    RetryReason.unknown,
                  ].contains(retry.job.retryReason),
                )
                .map((retry) {
                  final job = retry.job;
                  return {
                    'remoteFileKey': job.remoteFileKey,
                    'errorMessage': job.lastErrorMessage ?? '',
                    'retryReason': job.retryReason.toString(),
                  };
                })
                .toList(),
            missingFiles: _retryLaterJobs.values
                .where((retry) => retry.job.retryReason == RetryReason.notFound)
                .map((retry) => retry.job.remoteFileKey)
                .toList(),
            errorMessage: errorMessage,
          ),
        );

  void stopProcessingDownloads() {
    _downloadsEnabled = false;
    _clearRetryLaterJobs(cancelTimers: true, removeEntries: false);
    _reportPendingDownloads();
  }

  void startProcessingDownloads() {
    if (_retryLaterJobs.isNotEmpty) {
      final retryRemoteFileKeys = _retryLaterJobs.keys.toList();
      _clearRetryLaterJobs(cancelTimers: true);
      // add them back in reverse order so last retry is processed first
      for (final remoteFileKey in retryRemoteFileKeys.reversed) {
        enqueueDownload(
          remoteFileKey: remoteFileKey,
          addAsLowestPriority: true,
        );
      }
    }
    _downloadsEnabled = true;
    _processQueue();
  }

  void resumeProcessingDownloads() => startProcessingDownloads();

  Stream<DownloadProgress> enqueueDownload({
    required String remoteFileKey,
    bool addAsLowestPriority = false,
  }) {
    _cancelRetryLaterJob(remoteFileKey);

    final activeJob = _activeJobs[remoteFileKey];
    if (activeJob != null) {
      return activeJob.progressStream;
    }

    final existingIndex = _queueLIFO.indexWhere(
      (job) => job.remoteFileKey == remoteFileKey,
    );
    if (existingIndex != -1) {
      final existingJob = _queueLIFO.removeAt(existingIndex);
      _queueLIFO.add(existingJob);
      return existingJob.progressStream;
    }

    final progressController = StreamController<DownloadProgress>();
    final job = TransferJob<DownloadProgress, File>(
      remoteFileKey: remoteFileKey,
      fileName: p.basename(remoteFileKey),
      progressController: progressController,
      completer: Completer<File>(),
    );

    // Signal queued state.
    progressController.isClosed
        ? null
        : progressController.add(
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
    return job.progressStream;
  }

  void _processQueue() {
    _reportPendingDownloads();
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
                    _scheduleRetry(job);
                    _reportPendingDownloads(errorMessage: error.toString());
                  } else {
                    // re-add current job as top priority
                    _queueLIFO.add(job);
                  }
                  _processQueue();
                  return;
                }

                job.lastErrorMessage = error.toString();
                _reportPendingDownloads(errorMessage: error.toString());

                // Real failure: finish the job with error and adjust pending.
                _activeJobs.remove(job.remoteFileKey);
                if (!job.completer.isCompleted) {
                  job.completer.completeError(error, stack);
                }
                if (!job.progressController.isClosed) {
                  job.progressController.addError(error, stack);
                  job.progressController.close();
                }
                _processQueue();
              });
        }
      } finally {
        _processingQueue = false;
      }
    });
  }

  void _reassessAdmissionBasedOnPendingParts() {
    if (shouldAdmitMoreTransfers(
      activeJobs: _activeJobs.values,
      maxConcurrentRequests: maxDownloadRequestsConcurrency,
    )) {
      _admitMoreJobs = true;
      _processQueue();
    }
  }

  Future<File> _runSingleDownload(
    TransferJob<DownloadProgress, File> job,
  ) async {
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
        job.progressController.add(
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
      job.totalParts = totalParts;
      // TODO: _reportProgress

      _reassessAdmissionBasedOnPendingParts();

      job.progressController.add(
        DownloadProgress(
          partsCompleted: 0,
          partsTotal: totalParts,
          bytesCompleted: 0,
          bytesTotal: contentLength,
          bytesPerChunk: chunkSize,
        ),
      );

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

        job.partsCompleted = partsCompleted;
        // TODO: _reportProgress
        _reassessAdmissionBasedOnPendingParts();

        if (partsCompleted > 0) {
          job.progressController.add(
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
        job.partsCompleted = partsCompleted;
        bytesCompleted += partBytes;
        job.progressController.add(
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
          _reassessAdmissionBasedOnPendingParts();
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
        await runWithConcurrency<int>(
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
      job.progressController.add(
        DownloadProgress(
          partsCompleted: totalParts,
          partsTotal: totalParts,
          bytesCompleted: contentLength,
          bytesTotal: contentLength,
          bytesPerChunk: chunkSize,
          destFilePath: destFile.path,
        ),
      );
      job.completer.complete(destFile);
      await job.progressController.close();
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
    this.destFilePath,
  });

  final int partsCompleted;
  final int partsTotal;
  final int bytesCompleted;
  final int bytesTotal;
  final int bytesPerChunk;
  final String errorMessage;
  final String? destFilePath;
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

class _RetryLater {
  _RetryLater({required this.job, required this.timer});

  final TransferJob<DownloadProgress, File> job;
  final Timer timer;
}

// Download-specific retry reasons retained locally; TransferJob is shared.

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
