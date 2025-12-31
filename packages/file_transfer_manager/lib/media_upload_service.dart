part of 'file_transfer_manager.dart';

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
    int maxPartConcurrency = maxConcurrency,
    PendingUploadTotalsCallback? pendingTotalsCallback,
  }) {
    _singleton ??= MediaUploadService(
      apiClient: apiClient,
      pendingUploadBase: pendingUploadBase,
      cloudedBase: cloudedBase,
      remoteFileKeyResolver: remoteFileKeyResolver,
      partSizeBytes: partSizeBytes,
      maxPartConcurrency: maxPartConcurrency,
      pendingTotalsCallback: pendingTotalsCallback,
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

    _ensureUploadWatch();
    _processing = true;
    try {
      _pendingFiles = 0;
      _pendingBytes = 0;
      final files = await _collectFiles();
      if (_uploadsEnabled) {
        await _runWithConcurrency<File>(
          items: files,
          concurrency: maxPartConcurrency,
          worker: _uploadFile,
        );
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
        _pendingFiles++;
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
