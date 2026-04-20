import 'dart:async' show StreamController;
import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'dart:io'
    show
        File,
        HttpClient,
        HttpClientResponse,
        HttpException,
        ContentType,
        FileSystemException;

export 'package:sltt_core/sltt_core.dart'
    show RequestLimiter, runWithConcurrency;

/// fast and memory-efficient file concatenation
Future<void> concatenateFiles({
  required List<File> parts,
  required File output,
}) async {
  if (parts.isEmpty) return;

  // Fast-path: a single part can simply be moved into place.
  if (parts.length == 1) {
    final single = parts.first;
    if (single.path != output.path) {
      await output.parent.create(recursive: true);
      if (await output.exists()) {
        await output.delete();
      }
      try {
        await single.rename(output.path);
        return;
      } on FileSystemException {
        // Fall back to streaming copy if rename fails (e.g., cross-volume move).
      }
    }
  }

  await output.parent.create(recursive: true);
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

enum TransferPriority { low, normal, high }

/// Transfer job metadata shared by upload/download services.
class TransferJob<TProgress, TResult> {
  TransferJob({
    required this.remoteFileKey,
    this.fileName,
    this.priority = TransferPriority.normal,
    DateTime? enqueuedAt,
    StreamController<TProgress>? progressController,
  }) : progressController = progressController ?? StreamController<TProgress>(),
       enqueuedAt = enqueuedAt ?? DateTime.now();

  int totalParts = -1;
  int partsCompleted = -1;
  int get partsRemaining => totalParts == -1 || partsCompleted == -1
      ? -1
      : totalParts - partsCompleted;
  int tries = 0;
  Object? retryReason;
  DateTime? retryAt;
  final String remoteFileKey;
  final String? fileName;
  final TransferPriority priority;
  final DateTime enqueuedAt;
  String? lastErrorMessage;
  final StreamController<TProgress> progressController;

  Stream<TProgress> get progressStream => progressController.stream;
}

/// Determines whether additional transfers can be admitted based on the
/// remaining parts across active jobs and the maximum concurrent request
/// budget.
bool shouldAdmitMoreTransfers({
  required Iterable<TransferJob<dynamic, dynamic>> activeJobs,
  required int maxConcurrentRequests,
}) {
  final overallPendingParts = activeJobs.fold<int>(
    0,
    (sum, activeJob) =>
        sum +
        (activeJob.partsRemaining != -1
            ? activeJob.partsRemaining
            : activeJob.totalParts),
  );

  return overallPendingParts < maxConcurrentRequests;
}

class MediaApiClientCore {
  MediaApiClientCore(String baseUrl, {HttpClient? client})
    : baseUri = Uri.parse(baseUrl),
      httpClient = client ?? HttpClient();

  final Uri baseUri;
  final HttpClient httpClient;

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

  Future<List<SignedUrlBundle>> getUrls({
    required String remoteFileKey,
    required List<String> clientMethods,
    int? partNumber,
    String? uploadId,
    Map<String, String>? headers,
  }) async {
    final uri = getFullPath('/api/media/get-urls');
    final body = <String, dynamic>{
      'remoteFileKey': remoteFileKey,
      'clientMethods': clientMethods,
    };

    if (partNumber != null) body['partNumber'] = partNumber;
    if (uploadId != null) body['uploadId'] = uploadId;
    if (headers != null && headers.isNotEmpty) body['headers'] = headers;

    final data = await postJson(uri, body);
    final urls = (data['urls'] as List<dynamic>? ?? [])
        .map((e) => SignedUrlBundle.fromJson(e as Map<String, dynamic>))
        .toList();

    return urls;
  }

  Uri getFullPath(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    final base = baseUri.toString().replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base/$normalized');
  }

  Future<Map<String, dynamic>> postJson(
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
}
