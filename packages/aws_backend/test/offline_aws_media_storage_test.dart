import 'package:aws_backend/src/storage/media/aws_media_storage.dart';
import 'package:aws_common/aws_common.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  group('AwsMediaStorage', () {
    const bucketName = 'test-bucket';
    const region = 'us-east-1';

    test('completeMultipartUpload sends If-None-Match header', () async {
      late http.Request receivedRequest;
      final client = MockClient((request) async {
        receivedRequest = request;
        return http.Response(
          '''<?xml version="1.0" encoding="UTF-8"?>
<CompleteMultipartUploadResult>
  <Location>https://$bucketName.s3.$region.amazonaws.com/test-key</Location>
  <Bucket>$bucketName</Bucket>
  <Key>test-key</Key>
  <ETag>"etag-value"</ETag>
</CompleteMultipartUploadResult>''',
          200,
          headers: {'content-type': 'application/xml'},
        );
      });

      final storage = AwsMediaStorage(
        bucketName: bucketName,
        region: region,
        credentials: const AWSCredentials('AKIA', 'SECRET'),
        httpClient: client,
      );

      final response = await storage.completeMultipartUpload(
        remoteFileKey: 'test-key',
        uploadId: 'upload-1',
        parts: [MediaCompletedPart(partNumber: 1, eTag: 'etag-value')],
      );

      expect(receivedRequest.headers['if-none-match'], equals('*'));
      expect(response.remoteFileKey, equals('test-key'));
      expect(response.uploadId, equals('upload-1'));
      expect(response.bucket, equals(bucketName));
      expect(response.eTag, equals('etag-value'));
    });

    test(
      'completeMultipartUpload throws object already exists on 412',
      () async {
        final client = MockClient((request) async {
          return http.Response('Precondition Failed', 412);
        });

        final storage = AwsMediaStorage(
          bucketName: bucketName,
          region: region,
          credentials: const AWSCredentials('AKIA', 'SECRET'),
          httpClient: client,
        );

        expect(
          () => storage.completeMultipartUpload(
            remoteFileKey: 'test-key',
            uploadId: 'upload-1',
            parts: [MediaCompletedPart(partNumber: 1, eTag: 'etag-value')],
          ),
          throwsA(isA<AwsMediaStorageObjectAlreadyExistsException>()),
        );
      },
    );

    test('completeMultipartUpload throws concurrent conflict on 409', () async {
      final client = MockClient((request) async {
        return http.Response('Conflict', 409);
      });

      final storage = AwsMediaStorage(
        bucketName: bucketName,
        region: region,
        credentials: const AWSCredentials('AKIA', 'SECRET'),
        httpClient: client,
      );

      expect(
        () => storage.completeMultipartUpload(
          remoteFileKey: 'test-key',
          uploadId: 'upload-1',
          parts: [MediaCompletedPart(partNumber: 1, eTag: 'etag-value')],
        ),
        throwsA(isA<AwsMediaStorageConcurrentUploadConflictException>()),
      );
    });
  });
}
