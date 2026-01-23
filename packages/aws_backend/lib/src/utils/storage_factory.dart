import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/aws_backend.dart';
import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;

/// Shared utility for creating DynamoDB storage service with consistent configuration
class StorageFactory {
  /// Create a DynamoDB storage service using environment variables
  static Future<DynamoDBStorageService> createStorage({
    bool useLocalDynamoDB = false,
  }) async {
    final tableName =
        Platform.environment['DYNAMODB_TABLE'] ?? 'sltt-changes-dev';
    final region =
        Platform.environment['DYNAMODB_REGION'] ??
        Platform.environment['AWS_REGION'] ??
        'us-east-1';

    // Default to cloud storage unless explicitly overridden
    final useLocal = useLocalDynamoDB;

    // Check for cross-account role assumption
    final assumeRoleArn = Platform.environment['SHARED_INFRA_ASSUME_ROLE_ARN'];
    AWSCredentials? crossAccountCredentials;

    if (assumeRoleArn != null && assumeRoleArn.isNotEmpty) {
      crossAccountCredentials = await _assumeRole(
        roleArn: assumeRoleArn,
        sessionName:
            Platform.environment['ASSUME_ROLE_SESSION_NAME'] ??
            'sltt-secondary-api',
        region: region,
      );
    }

    return DynamoDBStorageService(
      tableName: tableName,
      region: region,
      useLocalDynamoDB: useLocal,
      crossAccountCredentials: crossAccountCredentials,
    );
  }

  /// Assume a role and return temporary credentials
  static Future<AWSCredentials> _assumeRole({
    required String roleArn,
    required String sessionName,
    required String region,
  }) async {
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

      // Build STS AssumeRole request
      final uri = Uri.parse('https://sts.$region.amazonaws.com/');
      final body = {
        'Action': 'AssumeRole',
        'RoleArn': roleArn,
        'RoleSessionName': sessionName,
        'ExternalId': 'sltt-cross-account-access',
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

      // Parse XML response (simplified - look for credentials in XML)
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
}
