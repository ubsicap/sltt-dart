import 'package:aws_backend/src/utils/media_environment.dart';
import 'package:test/test.dart';

void main() {
  group('getMediaBucketRegion', () {
    test('uses MEDIA_BUCKET_REGION when set', () {
      final region = getMediaBucketRegion({
        'MEDIA_BUCKET_REGION': 'eu-west-1',
        'AWS_REGION': 'us-east-1',
      });

      expect(region, equals('eu-west-1'));
    });

    test('falls back to AWS_REGION when MEDIA_BUCKET_REGION is unset', () {
      final region = getMediaBucketRegion({'AWS_REGION': 'us-west-2'});

      expect(region, equals('us-west-2'));
    });

    test(
      'falls back to AWS_DEFAULT_REGION when MEDIA_BUCKET_REGION and AWS_REGION are unset',
      () {
        final region = getMediaBucketRegion({
          'AWS_DEFAULT_REGION': 'ap-southeast-2',
        });

        expect(region, equals('ap-southeast-2'));
      },
    );

    test('returns us-east-1 when no region env vars are set', () {
      final region = getMediaBucketRegion(<String, String>{});

      expect(region, equals('us-east-1'));
    });
  });
}
