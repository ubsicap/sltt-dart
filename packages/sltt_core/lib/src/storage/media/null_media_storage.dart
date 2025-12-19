import 'package:sltt_core/src/storage/media/base_media_storage.dart';

/// Placeholder media storage that marks operations as unsupported.
class NullMediaStorage extends BaseMediaStorage {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> close() async {}

  @override
  Future<MediaSignedUrlResponse> getSignedUrls(
    MediaSignedUrlRequest request,
  ) async {
    throw UnsupportedError('Media storage is not configured');
  }

  @override
  Future<MediaListPartsResponse> listFileParts({
    required String remoteFileKey,
    String? uploadId,
    String? cursor,
  }) async {
    throw UnsupportedError('Media storage is not configured');
  }

  @override
  Future<MediaCreateMultipartResponse> createMultipartUpload({
    required String remoteFileKey,
  }) async {
    throw UnsupportedError('Media storage is not configured');
  }
}
