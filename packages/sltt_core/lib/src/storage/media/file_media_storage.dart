import 'package:sltt_core/src/storage/media/base_media_storage.dart';

/// File-backed media storage placeholder (not yet implemented).
class FileMediaStorage extends BaseMediaStorage {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> close() async {}

  @override
  Future<MediaSignedUrlResponse> getSignedUrls(
    MediaSignedUrlRequest request,
  ) async {
    throw UnsupportedError(
      'FileMediaStorage does not implement getSignedUrls yet',
    );
  }

  @override
  Future<MediaListPartsResponse> listFileParts({
    required String remoteFileKey,
    String? uploadId,
    String? cursor,
  }) async {
    throw UnsupportedError(
      'FileMediaStorage does not implement listFileParts yet',
    );
  }

  @override
  Future<MediaCreateMultipartResponse> createMultipartUpload({
    required String remoteFileKey,
  }) async {
    throw UnsupportedError(
      'FileMediaStorage does not implement createMultipartUpload yet',
    );
  }

  @override
  Future<MediaCompleteMultipartResponse> completeMultipartUpload({
    required String remoteFileKey,
    required String uploadId,
    required List<MediaCompletedPart> parts,
  }) async {
    throw UnsupportedError(
      'FileMediaStorage does not implement completeMultipartUpload yet',
    );
  }
}
