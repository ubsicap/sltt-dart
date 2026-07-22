String getMediaBucketRegion([Map<String, String>? environment]) {
  final env = environment ?? const <String, String>{};
  return env['MEDIA_BUCKET_REGION'] ??
      env['AWS_REGION'] ??
      env['AWS_DEFAULT_REGION'] ??
      'us-east-1';
}
