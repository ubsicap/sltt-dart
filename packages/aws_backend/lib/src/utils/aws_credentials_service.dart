import 'dart:convert';
import 'dart:io';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;

import 'aws_credentials_exception.dart';

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
  /// performs STS AssumeRole and returns temporary credentials, cached
  /// until close to expiration (to avoid an STS round-trip per request).
  ///
  /// FIXED: 7/17/2026: See Claude https://claude.ai/share/b8dc5340-56d8-427c-8e93-8a467ef7dc6e
  ///
  /// Otherwise, returns credentials read directly from the AWS environment
  /// variables *on every call*. Those are NOT long-lived IAM user keys in
  /// a Lambda context - they're the execution role's temporary STS
  /// credentials, which AWS rotates in place roughly hourly without any
  /// signal exposed to this process other than the env vars themselves
  /// simply changing. Caching them (as this used to do, treating them as
  /// "never expiring") meant a warm container would keep signing requests
  /// with a stale, already-rotated session indefinitely - which surfaces
  /// as a 403 "signature does not match" from API Gateway/etc, not a
  /// cleaner expired-token error, since the cached triplet is internally
  /// consistent, just no longer valid. Re-reading env vars is a pure
  /// in-memory operation, so there's no cost to doing it every time.
  Future<AWSCredentials> getOrCreateCredentials() async {
    final assumeRoleArn = Platform.environment['SHARED_INFRA_ASSUME_ROLE_ARN'];
    final usingAssumeRole = assumeRoleArn?.isNotEmpty == true;

    if (!usingAssumeRole) {
      return _getEnvironmentCredentials();
    }

    if (_isCached() && _isNotExpired()) {
      return _cached!;
    }
    return _refreshCredentials(assumeRoleArn: assumeRoleArn!);
  }

  /// Force refresh of credentials (useful for testing or explicit refresh).
  /// Only meaningful for the assume-role path; environment credentials are
  /// always read fresh and never cached.
  Future<AWSCredentials> refreshCredentials() async {
    final assumeRoleArn = Platform.environment['SHARED_INFRA_ASSUME_ROLE_ARN'];
    if (assumeRoleArn?.isNotEmpty == true) {
      return _refreshCredentials(assumeRoleArn: assumeRoleArn!);
    }
    return _getEnvironmentCredentials();
  }

  Future<AWSCredentials> _refreshCredentials({
    required String assumeRoleArn,
  }) async {
    final result = await _assumeRole(roleArn: assumeRoleArn);
    _cached = result.credentials;
    _expiresAt = result.expiration;
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
      throw AwsCredentialsException(
        'AWS credentials not available in environment (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY required)',
      );
    }

    return AWSCredentials(accessKey, secretKey, sessionToken);
  }

  /// Assume a cross-account role and return temporary credentials together
  /// with their actual STS-reported expiration.
  Future<({AWSCredentials credentials, DateTime? expiration})> _assumeRole({
    required String roleArn,
  }) async {
    final accessKey = Platform.environment['AWS_ACCESS_KEY_ID'];
    final secretKey = Platform.environment['AWS_SECRET_ACCESS_KEY'];
    final sessionToken = Platform.environment['AWS_SESSION_TOKEN'];

    if (accessKey == null || secretKey == null) {
      throw AwsCredentialsException(
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
        throw AwsCredentialsException(
          'STS AssumeRole failed: ${response.statusCode} ${response.body}',
          statusCode: 403,
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
      final expirationMatch = RegExp(
        r'<Expiration>([^<]+)</Expiration>',
      ).firstMatch(responseBody);

      if (accessKeyIdMatch == null ||
          secretAccessKeyMatch == null ||
          sessionTokenMatch == null) {
        throw AwsCredentialsException(
          'Failed to parse AssumeRole response',
          statusCode: 500,
        );
      }

      // Prefer the expiration STS actually returns; only fall back to
      // guessing DurationSeconds if the field is somehow missing/unparseable,
      // and log loudly if so - a wrong guess here silently recreates the
      // same class of bug this fix is for.
      DateTime? expiration;
      if (expirationMatch != null) {
        expiration = DateTime.tryParse(expirationMatch.group(1)!);
      }
      if (expiration == null) {
        print(
          '[AwsCredentialsService] WARNING: could not parse <Expiration> '
          'from STS AssumeRole response; falling back to an assumed '
          '1-hour expiry from now. Response body: $responseBody',
        );
        expiration = DateTime.now().toUtc().add(const Duration(hours: 1));
      }

      return (
        credentials: AWSCredentials(
          accessKeyIdMatch.group(1)!,
          secretAccessKeyMatch.group(1)!,
          sessionTokenMatch.group(1)!,
        ),
        expiration: expiration,
      );
    } finally {
      client.close();
    }
  }
}
