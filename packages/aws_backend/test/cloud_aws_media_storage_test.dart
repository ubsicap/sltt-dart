import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

String _buildRemoteFileKey(String testName) {
  final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
  return '__test/cloud_aws_media_storage_test/$testName-$timestamp.bin';
}

Future<Uri> _getUploadPartUrl(
  Uri baseUrl,
  String remoteFileKey,
  String uploadId,
  int partNumber,
  String contentMd5,
) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/media/get-urls'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'remoteFileKey': remoteFileKey,
      'clientMethods': ['upload_part'],
      'uploadId': uploadId,
      'partNumber': partNumber,
      'headers': {'content-md5': contentMd5},
    }),
  );

  expect(
    response.statusCode,
    equals(200),
    reason: 'Failed to get upload part URL: ${response.body}',
  );

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  final urls = (body['urls'] as List<dynamic>?) ?? [];
  final uploadUrl =
      urls.cast<Map<String, dynamic>>().firstWhere(
            (item) => item.containsKey('upload_part'),
            orElse: () => throw StateError('upload_part URL missing'),
          )['upload_part']
          as String;

  return Uri.parse(uploadUrl);
}

Future<String> _uploadPart(Uri uploadUrl, List<int> bytes) async {
  final md5Digest = md5.convert(bytes);
  final contentMd5 = base64.encode(md5Digest.bytes);

  final response = await http.put(
    uploadUrl,
    headers: {
      'Content-Type': 'application/octet-stream',
      'Content-MD5': contentMd5,
    },
    body: bytes,
  );

  expect(
    response.statusCode,
    anyOf([200, 201]),
    reason: 'Failed to upload part: ${response.statusCode} ${response.body}',
  );

  final eTag = response.headers['etag'];
  expect(eTag, isNotNull, reason: 'Expected ETag header after upload');
  return eTag!.replaceAll('"', '');
}

void main() {
  final baseUrl = Uri.parse(
    Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl,
  );

  group('cloud - /api/media multipart', () {
    test(
      'POST /api/media/multipart-create and multipart-complete returns success',
      () async {
        final timestamp = DateTime.now().toIso8601String();
        final remoteFileKey = _buildRemoteFileKey(
          '__test/cloud_aws_media_storage_test/create-and-complete.$timestamp',
        );

        final createResponse = await http.post(
          Uri.parse('$baseUrl/api/media/multipart-create'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'remoteFileKey': remoteFileKey}),
        );

        expect(
          createResponse.statusCode,
          equals(200),
          reason: 'Failed to create multipart upload: ${createResponse.body}',
        );
        final createBody =
            jsonDecode(createResponse.body) as Map<String, dynamic>;
        expect(createBody['remoteFileKey'], equals(remoteFileKey));
        expect(
          createBody['uploadId'],
          isA<String>().having(
            (v) => v.isNotEmpty,
            'uploadId not empty',
            isTrue,
          ),
        );
        expect(
          createBody['bucket'],
          isA<String>().having((v) => v.isNotEmpty, 'bucket not empty', isTrue),
        );

        final uploadId = createBody['uploadId'] as String;
        final contentBytes = utf8.encode('test-content');
        final contentMd5 = base64.encode(md5.convert(contentBytes).bytes);
        final uploadUrl = await _getUploadPartUrl(
          baseUrl,
          remoteFileKey,
          uploadId,
          1,
          contentMd5,
        );
        final eTag = await _uploadPart(uploadUrl, contentBytes);

        final completeResponse = await http.post(
          Uri.parse('$baseUrl/api/media/multipart-complete'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'remoteFileKey': remoteFileKey,
            'uploadId': uploadId,
            'parts': [
              {'partNumber': 1, 'eTag': eTag},
            ],
          }),
        );

        expect(
          completeResponse.statusCode,
          equals(200),
          reason:
              'Failed to complete multipart upload: ${completeResponse.body}',
        );
        final completeBody =
            jsonDecode(completeResponse.body) as Map<String, dynamic>;
        expect(completeBody['remoteFileKey'], equals(remoteFileKey));
        expect(completeBody['uploadId'], equals(uploadId));
        expect(completeBody['bucket'], equals(createBody['bucket']));
        expect(completeBody['location'], isA<String>());
        expect(completeBody['eTag'], isA<String>());
      },
      tags: ['internet', 'integration'],
      timeout: Timeout.none,
    );

    test(
      'POST /api/media/multipart-complete twice for same remote path fails on second completion',
      () async {
        final timestamp = DateTime.now().toIso8601String();
        final remoteFileKey = _buildRemoteFileKey(
          '__test/cloud_aws_media_storage_test/complete-twice.$timestamp',
        );

        final firstCreateResponse = await http.post(
          Uri.parse('$baseUrl/api/media/multipart-create'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'remoteFileKey': remoteFileKey}),
        );
        expect(
          firstCreateResponse.statusCode,
          equals(200),
          reason:
              'Failed to create first multipart upload: ${firstCreateResponse.body}',
        );
        final firstCreateBody =
            jsonDecode(firstCreateResponse.body) as Map<String, dynamic>;
        final firstUploadId = firstCreateBody['uploadId'] as String;

        final firstContentBytes = utf8.encode('first-content');
        final firstContentMd5 = base64.encode(
          md5.convert(firstContentBytes).bytes,
        );
        final firstUploadUrl = await _getUploadPartUrl(
          baseUrl,
          remoteFileKey,
          firstUploadId,
          1,
          firstContentMd5,
        );
        final firstPartTag = await _uploadPart(
          firstUploadUrl,
          firstContentBytes,
        );

        final firstCompleteResponse = await http.post(
          Uri.parse('$baseUrl/api/media/multipart-complete'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'remoteFileKey': remoteFileKey,
            'uploadId': firstUploadId,
            'parts': [
              {'partNumber': 1, 'eTag': firstPartTag},
            ],
          }),
        );
        expect(
          firstCompleteResponse.statusCode,
          equals(200),
          reason:
              'Failed to complete first multipart upload: ${firstCompleteResponse.body}',
        );

        final secondCreateResponse = await http.post(
          Uri.parse('$baseUrl/api/media/multipart-create'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'remoteFileKey': remoteFileKey}),
        );
        expect(
          secondCreateResponse.statusCode,
          equals(200),
          reason:
              'Failed to create second multipart upload: ${secondCreateResponse.body}',
        );
        final secondCreateBody =
            jsonDecode(secondCreateResponse.body) as Map<String, dynamic>;
        final secondUploadId = secondCreateBody['uploadId'] as String;

        final secondContentBytes = utf8.encode('second-content');
        final secondContentMd5 = base64.encode(
          md5.convert(secondContentBytes).bytes,
        );
        final secondUploadUrl = await _getUploadPartUrl(
          baseUrl,
          remoteFileKey,
          secondUploadId,
          1,
          secondContentMd5,
        );
        final secondPartTag = await _uploadPart(
          secondUploadUrl,
          secondContentBytes,
        );

        final secondCompleteResponse = await http.post(
          Uri.parse('$baseUrl/api/media/multipart-complete'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'remoteFileKey': remoteFileKey,
            'uploadId': secondUploadId,
            'parts': [
              {'partNumber': 1, 'eTag': secondPartTag},
            ],
          }),
        );

        expect(
          secondCompleteResponse.statusCode,
          anyOf([412, 409]),
          reason:
              'Second complete for same remote file key should fail due to existing object or conflict, got ${secondCompleteResponse.statusCode} with body ${secondCompleteResponse.body}',
        );
      },
      tags: ['internet', 'integration'],
      timeout: Timeout.none,
    );
  });
}
