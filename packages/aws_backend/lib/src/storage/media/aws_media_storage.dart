import 'dart:io';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:xml/xml.dart';

/// S3-backed media storage that issues presigned URLs and lists multipart parts.
class AwsMediaStorage extends BaseMediaStorage {
  AwsMediaStorage({
    required this.bucketName,
    required this.region,
    Duration presignedUrlDuration = const Duration(minutes: 15),
    http.Client? httpClient,
  }) : _presignedUrlDuration = presignedUrlDuration,
       _httpClient = httpClient ?? http.Client(),
       _ownsHttpClient = httpClient == null;

  final String bucketName;
  final String region;
  final Duration _presignedUrlDuration;
  static final S3ServiceConfiguration _s3Config = S3ServiceConfiguration(
    signPayload: false,
  );

  final http.Client _httpClient;
  final bool _ownsHttpClient;

  AWSSigV4Signer? _signer;
  AWSCredentialsProvider? _credentialsProvider;
  bool _initialized = false;

  String get _host => '$bucketName.s3.$region.amazonaws.com';

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    final accessKey = Platform.environment['AWS_ACCESS_KEY_ID'];
    final secretKey = Platform.environment['AWS_SECRET_ACCESS_KEY'];
    final sessionToken = Platform.environment['AWS_SESSION_TOKEN'];

    if (accessKey == null || secretKey == null) {
      throw UnsupportedError(
        'AWS credentials are required for media storage (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY).',
      );
    }

    _credentialsProvider = AWSCredentialsProvider(
      AWSCredentials(accessKey, secretKey, sessionToken),
    );
    _signer = AWSSigV4Signer(credentialsProvider: _credentialsProvider!);
    _initialized = true;
  }

  @override
  Future<void> close() async {
    _initialized = false;
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }

  @override
  Future<MediaSignedUrlResponse> getSignedUrls(
    MediaSignedUrlRequest request,
  ) async {
    await initialize();

    final key = _normalizeKey(request.remoteFileKey);
    final expiresAt = DateTime.now().toUtc().add(_presignedUrlDuration);

    Uri? headUrl;
    Uri? uploadPartUrl;
    int? partNumber;
    String? uploadId;

    if (request.clientMethods.contains('head_object')) {
      headUrl = await _presignUri(method: AWSHttpMethod.head, key: key);
    }

    if (request.clientMethods.contains('upload_part')) {
      uploadId = request.uploadId;
      partNumber = request.partNumber;
      if (uploadId == null || uploadId.isEmpty) {
        throw ArgumentError('uploadId is required for upload_part');
      }
      if (partNumber == null || partNumber <= 0) {
        throw ArgumentError('partNumber must be a positive integer');
      }

      uploadPartUrl = await _presignUri(
        method: AWSHttpMethod.put,
        key: key,
        query: {'uploadId': uploadId, 'partNumber': partNumber.toString()},
      );
    }

    return MediaSignedUrlResponse(
      urls: [
        MediaSignedUrlEntry(
          remoteFileKey: key,
          headObjectUrl: headUrl,
          uploadPartUrl: uploadPartUrl,
          partNumber: partNumber,
          uploadId: uploadId,
          expiresAt: expiresAt,
        ),
      ],
    );
  }

  /// Locate an existing multipart upload for a key using the S3
  /// ListMultipartUploads API. If found, returns the uploadId. If not found
  /// but more pages exist, returns a cursor encoded as
  /// "<NextKeyMarker>|<NextUploadIdMarker>" so callers can continue the
  /// search. An empty uploadId with a non-empty cursor means keep paging; an
  /// empty uploadId with an empty cursor means nothing was found.
  Future<MultipartUploadLookupResult> findMultipartUpload({
    required String remoteFileKey,
    String? cursor,
  }) async {
    await initialize();

    final key = _normalizeKey(remoteFileKey);

    String? keyMarker;
    String? uploadIdMarker;
    if (cursor != null && cursor.isNotEmpty) {
      final parts = cursor.split('|');
      keyMarker = parts.isNotEmpty ? parts[0] : null;
      uploadIdMarker = parts.length > 1 ? parts[1] : null;
    }

    final query = <String, String>{'uploads': '', 'prefix': key};

    if (keyMarker != null && keyMarker.isNotEmpty) {
      query['key-marker'] = keyMarker;
    }
    if (uploadIdMarker != null && uploadIdMarker.isNotEmpty) {
      query['upload-id-marker'] = uploadIdMarker;
    }

    final request = AWSHttpRequest(
      method: AWSHttpMethod.get,
      uri: Uri(scheme: 'https', host: _host, path: '/', queryParameters: query),
      headers: {'host': _host},
    );

    final response = await _sendSigned(request);
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to list multipart uploads (status ${response.statusCode}): ${response.body}',
      );
    }

    final doc = XmlDocument.parse(response.body);
    for (final upload in doc.findAllElements('Upload')) {
      final uploadKey = _text(upload, 'Key');
      final foundUploadId = _text(upload, 'UploadId');
      if (uploadKey == key &&
          foundUploadId != null &&
          foundUploadId.isNotEmpty) {
        return MultipartUploadLookupResult(uploadId: foundUploadId);
      }
    }

    final isTruncated =
        (_text(doc.rootElement, 'IsTruncated') ?? '').toLowerCase().trim() ==
        'true';

    if (isTruncated) {
      final nextKeyMarker = _text(doc.rootElement, 'NextKeyMarker');
      final nextUploadIdMarker = _text(doc.rootElement, 'NextUploadIdMarker');
      final nextCursor = _encodeMultipartCursor(
        nextKeyMarker,
        nextUploadIdMarker,
      );
      if (nextCursor != null) {
        return MultipartUploadLookupResult(uploadId: '', cursor: nextCursor);
      }
    }

    return MultipartUploadLookupResult(uploadId: '');
  }

  @override
  Future<MediaListPartsResponse> listFileParts({
    required String remoteFileKey,
    String? uploadId,
    String? cursor,
  }) async {
    await initialize();

    final key = _normalizeKey(remoteFileKey);
    String resolvedUploadId = uploadId ?? '';
    String? partsCursor = cursor;

    if (resolvedUploadId.isEmpty) {
      final lookup = await findMultipartUpload(
        remoteFileKey: key,
        cursor: cursor,
      );

      if (lookup.uploadId.isEmpty) {
        return MediaListPartsResponse(
          bucket: bucketName,
          remoteFileKey: key,
          uploadId: '',
          partNumberMarker: null,
          nextPartNumberMarker: null,
          maxParts: null,
          isTruncated: lookup.cursor != null,
          parts: const <MediaPartSummary>[],
          cursor: lookup.cursor,
        );
      }

      resolvedUploadId = lookup.uploadId;
      partsCursor = null;
    }

    int? partNumberMarker;
    if (partsCursor != null && partsCursor.isNotEmpty) {
      partNumberMarker = int.tryParse(partsCursor);
      if (partNumberMarker == null) {
        throw ArgumentError('cursor must be a valid integer');
      }
    }

    final query = <String, String>{'uploadId': resolvedUploadId};
    if (partNumberMarker != null) {
      query['part-number-marker'] = partNumberMarker.toString();
    }

    final request = AWSHttpRequest(
      method: AWSHttpMethod.get,
      uri: _objectUri(key, query),
      headers: {'host': _host},
    );

    final response = await _sendSigned(request);
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to list multipart parts (status ${response.statusCode}): ${response.body}',
      );
    }

    final doc = XmlDocument.parse(response.body);
    final parts = doc.findAllElements('Part').map((partEl) {
      final partNum = int.tryParse(_text(partEl, 'PartNumber') ?? '');
      final size = int.tryParse(_text(partEl, 'Size') ?? '');
      if (partNum == null || size == null) {
        throw Exception('Invalid part entry in ListParts response');
      }

      final lastModified = DateTime.tryParse(
        _text(partEl, 'LastModified') ?? '',
      );

      final eTag = _text(partEl, 'ETag')?.replaceAll('"', '');

      return MediaPartSummary(
        partNumber: partNum,
        size: size,
        eTag: eTag,
        lastModified: lastModified,
      );
    }).toList();

    final bucket = _text(doc.rootElement, 'Bucket');
    final parsedUploadId = _text(doc.rootElement, 'UploadId');
    final partMarker = int.tryParse(
      _text(doc.rootElement, 'PartNumberMarker') ?? '',
    );
    final nextMarker = int.tryParse(
      _text(doc.rootElement, 'NextPartNumberMarker') ?? '',
    );
    final maxParts = int.tryParse(_text(doc.rootElement, 'MaxParts') ?? '');
    final isTruncated =
        (_text(doc.rootElement, 'IsTruncated') ?? '').toLowerCase().trim() ==
        'true';

    return MediaListPartsResponse(
      bucket: bucket,
      remoteFileKey: key,
      uploadId: parsedUploadId ?? resolvedUploadId,
      partNumberMarker: partMarker,
      nextPartNumberMarker: nextMarker,
      maxParts: maxParts,
      isTruncated: isTruncated,
      parts: parts,
      cursor: isTruncated && nextMarker != null ? nextMarker.toString() : null,
    );
  }

  @override
  Future<MediaCreateMultipartResponse> createMultipartUpload({
    required String remoteFileKey,
  }) async {
    await initialize();
    final key = _normalizeKey(remoteFileKey);

    final request = AWSHttpRequest(
      method: AWSHttpMethod.post,
      uri: _objectUri(key, {'uploads': ''}),
      headers: {'host': _host},
    );

    final response = await _sendSigned(request);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to create multipart upload (status ${response.statusCode}): ${response.body}',
      );
    }

    final doc = XmlDocument.parse(response.body);
    final uploadId = _text(doc.rootElement, 'UploadId');
    if (uploadId == null || uploadId.isEmpty) {
      throw Exception('UploadId missing from CreateMultipartUpload response');
    }

    return MediaCreateMultipartResponse(
      remoteFileKey: key,
      uploadId: uploadId,
      bucket: bucketName,
    );
  }

  Uri _objectUri(String key, [Map<String, String>? query]) {
    return Uri(
      scheme: 'https',
      host: _host,
      path: '/$key',
      queryParameters: query,
    );
  }

  String _normalizeKey(String key) =>
      key.startsWith('/') ? key.substring(1) : key;

  String? _encodeMultipartCursor(String? keyMarker, String? uploadIdMarker) {
    final hasKey = keyMarker != null && keyMarker.isNotEmpty;
    final hasUploadId = uploadIdMarker != null && uploadIdMarker.isNotEmpty;

    if (!hasKey && !hasUploadId) {
      return null;
    }

    final safeKeyMarker = hasKey ? keyMarker : '';
    final safeUploadMarker = hasUploadId ? uploadIdMarker : '';
    return '$safeKeyMarker|$safeUploadMarker';
  }

  Future<Uri> _presignUri({
    required AWSHttpMethod method,
    required String key,
    Map<String, String>? query,
  }) async {
    final presigned = await _signer!.presign(
      AWSHttpRequest(
        method: method,
        uri: _objectUri(key, query),
        headers: {'host': _host},
      ),
      credentialScope: AWSCredentialScope(
        region: region,
        service: AWSService.s3,
      ),
      expiresIn: _presignedUrlDuration,
      serviceConfiguration: _s3Config,
    );

    return presigned;
  }

  Future<http.Response> _sendSigned(AWSHttpRequest request) async {
    final signed = await _signer!.sign(
      request,
      credentialScope: AWSCredentialScope(
        region: region,
        service: AWSService.s3,
      ),
      serviceConfiguration: _s3Config,
    );

    final httpRequest = http.Request(signed.method.value, signed.uri)
      ..headers.addAll(signed.headers);

    final streamed = await _httpClient.send(httpRequest);
    return http.Response.fromStream(streamed);
  }

  String? _text(XmlElement element, String tag) {
    final found = element.findAllElements(tag);
    if (found.isEmpty) return null;
    return found.first.value;
  }
}

class MultipartUploadLookupResult {
  MultipartUploadLookupResult({required this.uploadId, this.cursor});

  final String uploadId;
  final String? cursor;

  bool get hasUploadId => uploadId.isNotEmpty;
}
