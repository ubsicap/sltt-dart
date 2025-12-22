import 'dart:async';

/// Request to generate signed URLs for media operations.
class MediaSignedUrlRequest {
  MediaSignedUrlRequest({
    required this.remoteFileKey,
    required this.clientMethods,
    this.partNumber,
    this.uploadId,
  });

  final String remoteFileKey;
  final Set<String> clientMethods;
  final int? partNumber;
  final String? uploadId;
}

/// Single signed URL payload for a specific remote file key and method.
class MediaSignedUrlEntry {
  MediaSignedUrlEntry({
    required this.remoteFileKey,
    this.headObjectUrl,
    this.getObjectUrl,
    this.uploadPartUrl,
    this.partNumber,
    this.uploadId,
    this.expiresAt,
  });

  final String remoteFileKey;
  final Uri? headObjectUrl;
  final Uri? getObjectUrl;
  final Uri? uploadPartUrl;
  final int? partNumber;
  final String? uploadId;
  final DateTime? expiresAt;

  Map<String, dynamic> toJson() {
    return {
      'remoteFileKey': remoteFileKey,
      if (headObjectUrl != null) 'head_object': headObjectUrl.toString(),
      if (getObjectUrl != null) 'get_object': getObjectUrl.toString(),
      if (uploadPartUrl != null) 'upload_part': uploadPartUrl.toString(),
      if (partNumber != null) 'partNumber': partNumber,
      if (uploadId != null) 'uploadId': uploadId,
      if (expiresAt != null) 'expiresAt': expiresAt!.toUtc().toIso8601String(),
    };
  }
}

/// Signed URL response wrapper.
class MediaSignedUrlResponse {
  MediaSignedUrlResponse({required this.urls});

  final List<MediaSignedUrlEntry> urls;

  Map<String, dynamic> toJson() => {
    'urls': urls.map((u) => u.toJson()).toList(),
  };
}

/// Representation of a single uploaded part (compatible with S3 ListParts).
class MediaPartSummary {
  MediaPartSummary({
    required this.partNumber,
    required this.size,
    this.eTag,
    this.lastModified,
  });

  final int partNumber;
  final int size;
  final String? eTag;
  final DateTime? lastModified;

  Map<String, dynamic> toJson() => {
    'PartNumber': partNumber,
    'Size': size,
    if (eTag != null) 'ETag': eTag,
    if (lastModified != null)
      'LastModified': lastModified!.toUtc().toIso8601String(),
  };
}

/// Part descriptor used when completing a multipart upload.
class MediaCompletedPart {
  MediaCompletedPart({required this.partNumber, required this.eTag});

  final int partNumber;
  final String eTag;

  Map<String, dynamic> toJson() => {'PartNumber': partNumber, 'ETag': eTag};
}

/// List parts response aligned with S3 ListParts output, plus optional cursor for pagination.
class MediaListPartsResponse {
  MediaListPartsResponse({
    required this.remoteFileKey,
    required this.uploadId,
    required this.parts,
    this.bucket,
    this.partNumberMarker,
    this.nextPartNumberMarker,
    this.maxParts,
    this.isTruncated = false,
    this.cursor,
  });

  final String remoteFileKey;
  final String uploadId;
  final List<MediaPartSummary> parts;
  final String? bucket;
  final int? partNumberMarker;
  final int? nextPartNumberMarker;
  final int? maxParts;
  final bool isTruncated;
  final String? cursor;

  Map<String, dynamic> toJson() => {
    if (bucket != null) 'Bucket': bucket,
    'Key': remoteFileKey,
    'UploadId': uploadId,
    if (partNumberMarker != null) 'PartNumberMarker': partNumberMarker,
    if (nextPartNumberMarker != null)
      'NextPartNumberMarker': nextPartNumberMarker,
    if (maxParts != null) 'MaxParts': maxParts,
    'IsTruncated': isTruncated,
    'Parts': parts.map((p) => p.toJson()).toList(),
    if (cursor != null) 'Cursor': cursor,
  };
}

/// Response for /multipart-create upload.
class MediaCreateMultipartResponse {
  MediaCreateMultipartResponse({
    required this.remoteFileKey,
    required this.uploadId,
    this.bucket,
  });

  final String remoteFileKey;
  final String uploadId;
  final String? bucket;

  Map<String, dynamic> toJson() => {
    'remoteFileKey': remoteFileKey,
    'uploadId': uploadId,
    if (bucket != null) 'bucket': bucket,
  };
}

/// Response for completing a multipart upload.
class MediaCompleteMultipartResponse {
  MediaCompleteMultipartResponse({
    required this.remoteFileKey,
    required this.uploadId,
    this.bucket,
    this.location,
    this.eTag,
  });

  final String remoteFileKey;
  final String uploadId;
  final String? bucket;
  final String? location;
  final String? eTag;

  Map<String, dynamic> toJson() => {
    'remoteFileKey': remoteFileKey,
    'uploadId': uploadId,
    if (bucket != null) 'bucket': bucket,
    if (location != null) 'location': location,
    if (eTag != null) 'eTag': eTag,
  };
}

/// Base contract for media storage backends (e.g., S3, file, memory).
abstract class BaseMediaStorage {
  Future<void> initialize();

  Future<void> close();

  /// Return signed URLs for requested operations (e.g., head_object, upload_part).
  Future<MediaSignedUrlResponse> getSignedUrls(MediaSignedUrlRequest request);

  /// List uploaded parts for a multipart upload, optionally using a pagination cursor.
  Future<MediaListPartsResponse> listFileParts({
    required String remoteFileKey,
    String? uploadId,
    String? cursor,
  });

  /// Create a multipart upload for the provided remote file key.
  Future<MediaCreateMultipartResponse> createMultipartUpload({
    required String remoteFileKey,
  });

  /// Complete a multipart upload for the provided remote file key.
  Future<MediaCompleteMultipartResponse> completeMultipartUpload({
    required String remoteFileKey,
    required String uploadId,
    required List<MediaCompletedPart> parts,
  });
}
