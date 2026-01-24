/// Exception thrown when AWS credential acquisition fails.
class AwsCredentialsException implements Exception {
  AwsCredentialsException(this.message, {this.statusCode = 401});

  final String message;
  final int statusCode;

  @override
  String toString() => 'AwsCredentialsException: $message';
}
