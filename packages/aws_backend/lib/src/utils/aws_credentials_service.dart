import 'dart:convert';
import 'dart:io';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;

/// Centralized service for acquiring and caching AWS credentials.
///
/// Handles both environment credentials and cross-account STS AssumeRole.
/// Automatically refreshes expired credentials before they're used.
class AwsCredentialsService {
  static final AwsCredentialsService _instance = AwsCredentialsService._();

  AWSCredentials? _cached;
  DateTime? _expiresAt;

  factory AwsCredentialsService() => _instance;
  AwsCredentialsService._();

  /// Get current or cached credentials, refreshing if expired.
  ///
  /// If [SHARED_INFRA_ASSUME_ROLE_ARN] environment variable is set,
  /// performs STS AssumeRole and returns temporary credentials.
  /// Otherwise returns credentials from AWS environment variables.
  ///
  /// Cached credentials are automatically refreshed if within 5 minutes of expiration.
  Future<AWSCredentials> getOrCreateCredentials() async {
    if (_isCached() && _isNotExpired()) {
      return _cached!;
    }
    return _refreshCredentials();
  }

  /// Force refresh of credentials (useful for testing or explicit refresh).
  Future<AWSCredentials> refreshCredentials() => _refreshCredentials();

  Future<AWSCredentials> _refreshCredentials() async {
    final assumeRoleArn = Platform.environment['SHARED_INFRA_ASSUME_ROLE_ARN'];
    if (assumeRoleArn?.isNotEmpty == true) {
      _cached = await _assumeRole(roleArn: assumeRoleArn!);
      _expiresAt = _parseExpiration();
    } else {
      _cached = _getEnvironmentCredentials();
      _expiresAt = null; // environment credentials don't expire
    }
    return _cached!;
  }

  bool _isCached() => _cached != null;

  /// Check if cached credentials are still valid (with 5-minute buffer for safety)
  bool _isNotExpired() {
    if (_expiresAt == null) return true;
    final expirationBuffer = DateTime.now().add(const Duration(minutes: 5));
    return expirationBuffer.isBefore(_expiresAt!);
  }

  /// Get credentials from AWS environment variables
  AWSCredentials _getEnvironmentCredentials() {
    final accessKey = Platform.environment['AWS_ACCESS_KEY_ID'];
    final secretKey = Platform.environment['AWS_SECRET_ACCESS_KEY'];
    final sessionToken = Platform.environment['AWS_SESSION_TOKEN'];

    if (accessKey == null || secretKey == null) {
      throw Exception('AWS credentials not available in environment');
    }

    return AWSCredentials(accessKey, secretKey, sessionToken);
  }

  /// Assume a cross-account role and return temporary credentials
  Future<AWSCredentials> _assumeRole({required String roleArn}) async {
    final accessKey = Platform.environment['AWS_ACCESS_KEY_ID'];
    final secretKey = Platform.environment['AWS_SECRET_ACCESS_KEY'];
    final sessionToken = Platform.environment['AWS_SESSION_TOKEN'];

    if (accessKey == null || secretKey == null) {
      throw Exception(
        'AWS credentials not available in environment for role assumption',
      );
    }

    final client = http.Client();
    try {
      final credentials = AWSCredentials(accessKey, secretKey, sessionToken);
      final signer = AWSSigV4Signer(
        credentialsProvider: AWSCredentialsProvider(credentials),
      );

      final region =
          Platform.environment['AWS_REGION'] ??
          Platform.environment['AWS_DEFAULT_REGION'] ??
          'us-east-1';

      final sessionName =
          Platform.environment['ASSUME_ROLE_SESSION_NAME'] ??
          'sltt-secondary-api';
      final externalId =
          Platform.environment['ASSUME_ROLE_EXTERNAL_ID'] ??
          'sltt-cross-account-access';

      // Build STS AssumeRole request
      final uri = Uri.parse('https://sts.$region.amazonaws.com/');
      final body = {
        'Action': 'AssumeRole',
        'RoleArn': roleArn,
        'RoleSessionName': sessionName,
        'ExternalId': externalId,
        'DurationSeconds': '3600', // 1 hour
        'Version': '2011-06-15',
      };

      final encodedBody = body.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
      final bodyBytes = utf8.encode(encodedBody);

      final signedRequest = await signer.sign(
        AWSHttpRequest(
          method: AWSHttpMethod.post,
          uri: uri,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'host': uri.host,
          },
          body: bodyBytes,
        ),
        credentialScope: AWSCredentialScope(
          region: region,
          service: AWSService.sts,
        ),
      );

      final request = http.Request('POST', signedRequest.uri);
      request.headers.addAll(signedRequest.headers);
      request.bodyBytes = bodyBytes;

      final streamed = await client.send(request);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw Exception(
          'STS AssumeRole failed: ${response.statusCode} ${response.body}',
        );
      }

      // Parse XML response
      final responseBody = response.body;
      final accessKeyIdMatch = RegExp(
        r'<AccessKeyId>([^<]+)</AccessKeyId>',
      ).firstMatch(responseBody);
      final secretAccessKeyMatch = RegExp(
        r'<SecretAccessKey>([^<]+)</SecretAccessKey>',
      ).firstMatch(responseBody);
      final sessionTokenMatch = RegExp(
        r'<SessionToken>([^<]+)</SessionToken>',
      ).firstMatch(responseBody);

      if (accessKeyIdMatch == null ||
          secretAccessKeyMatch == null ||
          sessionTokenMatch == null) {
        throw Exception('Failed to parse AssumeRole response');
      }

      return AWSCredentials(
        accessKeyIdMatch.group(1)!,
        secretAccessKeyMatch.group(1)!,
        sessionTokenMatch.group(1)!,
      );
    } finally {
      client.close();
    }
  }

  /// Extract expiration time from cached AssumeRole response (if available).
  /// Returns null if expiration cannot be determined.
  DateTime? _parseExpiration() {
    // In a real implementation, you'd parse the Expiration field from the STS response
    // For now, assume 1 hour (3600 seconds) as specified in DurationSeconds above
    return DateTime.now().add(const Duration(hours: 1));
  }
}
