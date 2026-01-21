import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:xml/xml.dart';

/// S3-backed media storage that issues presigned URLs and lists multipart parts.
class AwsMediaStorage extends BaseMediaStorage {
  AwsMediaStorage({
    required this.bucketName,
    required this.region,
    String? cloudFrontDomain,
    String? cloudFrontKeyPairId,
    String? cloudFrontPrivateKey,
    bool enableTransferAcceleration = true,
    Duration presignedUrlDuration = const Duration(minutes: 15),
    http.Client? httpClient,
  }) : _enableTransferAcceleration = enableTransferAcceleration,
       _presignedUrlDuration = presignedUrlDuration,
       _httpClient = httpClient ?? http.Client(),
       _ownsHttpClient = httpClient == null,
       _cloudFrontDomain = cloudFrontDomain,
       _cloudFrontKeyPairId = cloudFrontKeyPairId,
       _cloudFrontPrivateKeyPem = cloudFrontPrivateKey;

  final String bucketName;
  final String region;
  final bool _enableTransferAcceleration;
  final Duration _presignedUrlDuration;
  static final S3ServiceConfiguration _s3Config = S3ServiceConfiguration(
    signPayload: false,
  );

  final http.Client _httpClient;
  final bool _ownsHttpClient;

  String? _cloudFrontDomain;
  String? _cloudFrontKeyPairId;
  String? _cloudFrontPrivateKeyPem;
  RSAPrivateKey? _cloudFrontPrivateKey;

  AWSSigV4Signer? _signer;
  AWSCredentialsProvider? _credentialsProvider;
  bool _initialized = false;

  String get _standardHost => '$bucketName.s3.$region.amazonaws.com';
  String get _accelerateHost => '$bucketName.s3-accelerate.amazonaws.com';
  String _endpointHost({bool useAccelerate = false}) =>
      useAccelerate && _enableTransferAcceleration
      ? _accelerateHost
      : _standardHost;

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

    _cloudFrontDomain ??=
      Platform.environment['MEDIA_CLOUDFRONT_DOMAIN'] ??
      Platform.environment['CLOUDFRONT_DOMAIN'];
    _cloudFrontKeyPairId ??=
      Platform.environment['MEDIA_CLOUDFRONT_KEY_PAIR_ID'] ??
      Platform.environment['CLOUDFRONT_KEY_PAIR_ID'];
    _cloudFrontPrivateKeyPem ??=
      Platform.environment['MEDIA_CLOUDFRONT_PRIVATE_KEY'] ??
      Platform.environment['CLOUDFRONT_PRIVATE_KEY'];

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
    Uri? getObjectUrl;
    Uri? uploadPartUrl;
    int? partNumber;
    String? uploadId;

    if (request.clientMethods.contains('head_object')) {
      headUrl = _cloudFrontSignedUrl(
        method: AWSHttpMethod.head,
        key: key,
        expiresAt: expiresAt,
      );
      headUrl ??= await _presignUri(method: AWSHttpMethod.head, key: key);
    }

    if (request.clientMethods.contains('get_object')) {
      getObjectUrl = _cloudFrontSignedUrl(
        method: AWSHttpMethod.get,
        key: key,
        expiresAt: expiresAt,
      );
      getObjectUrl ??= await _presignUri(method: AWSHttpMethod.get, key: key);
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

      final accelerateHost = _endpointHost(useAccelerate: true);
      final headers = _canonicalizeHeaders(
        request.headers,
        host: accelerateHost,
      );
      uploadPartUrl = await _presignUri(
        method: AWSHttpMethod.put,
        key: key,
        query: {'uploadId': uploadId, 'partNumber': partNumber.toString()},
        headers: headers,
        useAccelerate: true,
      );
    }

    return MediaSignedUrlResponse(
      urls: [
        MediaSignedUrlEntry(
          remoteFileKey: key,
          headObjectUrl: headUrl,
          getObjectUrl: getObjectUrl,
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
      uri: Uri(
        scheme: 'https',
        host: _endpointHost(),
        path: '/',
        queryParameters: query,
      ),
      headers: {'host': _endpointHost()},
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
      headers: {'host': _endpointHost()},
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
      headers: {'host': _endpointHost()},
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

  @override
  Future<MediaCompleteMultipartResponse> completeMultipartUpload({
    required String remoteFileKey,
    required String uploadId,
    required List<MediaCompletedPart> parts,
  }) async {
    await initialize();
    final key = _normalizeKey(remoteFileKey);

    if (uploadId.isEmpty) {
      throw ArgumentError('uploadId is required to complete multipart upload');
    }
    if (parts.isEmpty) {
      throw ArgumentError('parts must include at least one entry');
    }

    final sortedParts = [...parts]
      ..sort((a, b) => a.partNumber.compareTo(b.partNumber));

    final buffer = StringBuffer('<CompleteMultipartUpload>');
    for (final part in sortedParts) {
      if (part.partNumber <= 0) {
        throw ArgumentError('partNumber must be positive');
      }
      if (part.eTag.isEmpty) {
        throw ArgumentError('eTag is required for each part');
      }
      buffer
        ..write('<Part>')
        ..write('<PartNumber>${part.partNumber}</PartNumber>')
        ..write('<ETag>"${part.eTag}"</ETag>')
        ..write('</Part>');
    }
    buffer.write('</CompleteMultipartUpload>');
    final payloadBytes = utf8.encode(buffer.toString());

    final request = AWSHttpRequest(
      method: AWSHttpMethod.post,
      uri: _objectUri(key, {'uploadId': uploadId}),
      headers: {'host': _endpointHost(), 'content-type': 'application/xml'},
    );

    final response = await _sendSigned(request, body: payloadBytes);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to complete multipart upload (status ${response.statusCode}): ${response.body}',
      );
    }

    final doc = XmlDocument.parse(response.body);

    return MediaCompleteMultipartResponse(
      remoteFileKey: _text(doc.rootElement, 'Key') ?? key,
      uploadId: uploadId,
      bucket: _text(doc.rootElement, 'Bucket'),
      location: _text(doc.rootElement, 'Location'),
      eTag: _text(doc.rootElement, 'ETag')?.replaceAll('"', ''),
    );
  }

  Uri _objectUri(
    String key, [
    Map<String, String>? query,
    bool useAccelerate = false,
  ]) {
    return Uri(
      scheme: 'https',
      host: _endpointHost(useAccelerate: useAccelerate),
      path: '/$key',
      queryParameters: query,
    );
  }

  Uri? _cloudFrontSignedUrl({
    required AWSHttpMethod method,
    required String key,
    required DateTime expiresAt,
  }) {
    if (method != AWSHttpMethod.get && method != AWSHttpMethod.head) {
      return null;
    }
    if (!_hasCloudFrontSigning) {
      return null;
    }

    final domain = _normalizeCloudFrontDomain(_cloudFrontDomain!);
    if (domain.isEmpty) {
      return null;
    }

    final resource = Uri(
      scheme: 'https',
      host: domain,
      path: '/$key',
    );

    return _signCloudFrontUrl(resource, expiresAt);
  }

  bool get _hasCloudFrontSigning {
    final domain = _cloudFrontDomain;
    final keyPairId = _cloudFrontKeyPairId;
    final privateKey = _cloudFrontPrivateKeyPem;
    return domain != null &&
        domain.trim().isNotEmpty &&
        keyPairId != null &&
        keyPairId.trim().isNotEmpty &&
        privateKey != null &&
        privateKey.trim().isNotEmpty;
  }

  String _normalizeCloudFrontDomain(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Uri.parse(trimmed).host;
    }
    return trimmed;
  }

  Uri _signCloudFrontUrl(Uri resource, DateTime expiresAt) {
    final expiryEpoch = expiresAt.toUtc().millisecondsSinceEpoch ~/ 1000;
    final policy = _buildCloudFrontPolicy(resource, expiryEpoch);
    final signature = _cloudFrontSignPolicy(policy);
    final encodedSignature = _cloudFrontEncode(signature);

    final params = <String, String>{
      ...resource.queryParameters,
      'Expires': expiryEpoch.toString(),
      'Signature': encodedSignature,
      'Key-Pair-Id': _cloudFrontKeyPairId!,
    };

    return resource.replace(queryParameters: params);
  }

  String _buildCloudFrontPolicy(Uri resource, int expiryEpoch) {
    final resourceValue = resource.toString();
    return '{"Statement":[{"Resource":"$resourceValue","Condition":{"DateLessThan":{"AWS:EpochTime":$expiryEpoch}}}]}';
  }

  Uint8List _cloudFrontSignPolicy(String policy) {
    final key = _cloudFrontPrivateKey ??= _parseCloudFrontPrivateKey(
      _cloudFrontPrivateKeyPem!,
    );
    final signer = Signer('SHA-1/RSA');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(key));
    final signature = signer.generateSignature(
      Uint8List.fromList(utf8.encode(policy)),
    ) as RSASignature;
    return signature.bytes;
  }

  RSAPrivateKey _parseCloudFrontPrivateKey(String pem) {
    final normalized = pem.replaceAll('\n', '\n');
    final stripped = normalized
        .replaceAll(RegExp(r'-----BEGIN ([A-Z ]*)-----'), '')
        .replaceAll(RegExp(r'-----END ([A-Z ]*)-----'), '')
        .replaceAll(RegExp(r'\s'), '');

    final derBytes = base64.decode(stripped);
    return _decodePrivateKeyFromDer(Uint8List.fromList(derBytes));
  }

  RSAPrivateKey _decodePrivateKeyFromDer(Uint8List bytes) {
    final parser = ASN1Parser(bytes);
    final topLevel = parser.nextObject() as ASN1Sequence;
    if (topLevel.elements.length == 3) {
      final privateKeyOctet = topLevel.elements[2] as ASN1OctetString;
      final innerParser = ASN1Parser(privateKeyOctet.valueBytes());
      final innerSeq = innerParser.nextObject() as ASN1Sequence;
      return _parsePkcs1PrivateKey(innerSeq);
    }
    return _parsePkcs1PrivateKey(topLevel);
  }

  RSAPrivateKey _parsePkcs1PrivateKey(ASN1Sequence sequence) {
    final modulus = (sequence.elements[1] as ASN1Integer).valueAsBigInteger;
    final privateExponent =
        (sequence.elements[3] as ASN1Integer).valueAsBigInteger;
    final p = (sequence.elements[4] as ASN1Integer).valueAsBigInteger;
    final q = (sequence.elements[5] as ASN1Integer).valueAsBigInteger;

    return RSAPrivateKey(modulus, privateExponent, p, q);
  }

  String _cloudFrontEncode(Uint8List input) {
    return base64
        .encode(input)
        .replaceAll('+', '-')
        .replaceAll('=', '_')
        .replaceAll('/', '~');
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
    Map<String, String>? headers,
    bool useAccelerate = false,
  }) async {
    final host = _endpointHost(useAccelerate: useAccelerate);
    final presigned = await _signer!.presign(
      AWSHttpRequest(
        method: method,
        uri: _objectUri(key, query, useAccelerate),
        headers: headers ?? {'host': host},
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

  Map<String, String>? _canonicalizeHeaders(
    Map<String, String>? headers, {
    required String host,
  }) {
    if (headers == null || headers.isEmpty) return {'host': host};
    final normalized = <String, String>{'host': host};
    headers.forEach((k, v) {
      final key = k.toLowerCase().trim();
      if (key.isEmpty) return;
      normalized[key] = v;
    });
    return normalized;
  }

  Future<http.Response> _sendSigned(
    AWSHttpRequest request, {
    List<int>? body,
  }) async {
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

    if (body != null && body.isNotEmpty) {
      httpRequest.bodyBytes = body;
    }

    final streamed = await _httpClient.send(httpRequest);
    return http.Response.fromStream(streamed);
  }

  String? _text(XmlElement element, String tag) {
    final found = element.getElement(tag);
    // ignore: deprecated_member_use
    return found?.text; // .text not actually deprecated?
  }
}

class MultipartUploadLookupResult {
  MultipartUploadLookupResult({required this.uploadId, this.cursor});

  final String uploadId;
  final String? cursor;

  bool get hasUploadId => uploadId.isNotEmpty;
}
