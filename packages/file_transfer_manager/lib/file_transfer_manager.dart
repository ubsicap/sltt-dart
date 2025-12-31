import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

part 'media_download_service.dart';
part 'media_upload_service.dart';

typedef PendingUploadTotalsCallback = void Function(int files, int bytes);
typedef PendingDownloadTotalsCallback = void Function(int files);

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
