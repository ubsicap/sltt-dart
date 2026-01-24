import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/aws_backend.dart';
import 'package:aws_common/aws_common.dart' show AWSCredentials;
import 'package:sltt_core/sltt_core.dart' show SlttLogger;

/// AWS Lambda handler for SLTT backend API.
///
/// This handler uses the proper AwsRestApiServer class to ensure
/// consistent routing and endpoint behavior with local development.
/// It can also be used by the local debugger when LOCAL_DEBUGGER=true.
Future<Map<String, dynamic>> handler(Map<String, dynamic> event) async {
  DynamoDBStorageService? storage;
  AwsMediaStorage? mediaStorage;

  try {
    // Get credentials first - may throw AwsCredentialsException
    final credentials = await AwsCredentialsService().getOrCreateCredentials();
    storage = StorageFactory.createStorage(credentials: credentials);
    mediaStorage = _createMediaStorageFromEnv(credentials: credentials);

    await storage.initialize();
    await mediaStorage.initialize();

    // Create AwsRestApiServer instance
    final server = AwsRestApiServer(
      serverName: 'AWS Lambda API',
      storage: storage,
      mediaStorage: mediaStorage,
    );

    // Get router and process the API Gateway event
    final router = server.getRouter();
    final response = await server.handleApiGatewayEvent(event, router);

    return response;
  } on AwsCredentialsException catch (e, stackTrace) {
    SlttLogger.logger.severe('Credentials error: $e', e, stackTrace);
    return {
      'statusCode': e.statusCode,
      'headers': {'Content-Type': 'application/json'},
      'body': jsonEncode({
        'error': 'Authentication failed',
        'message': e.message,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    };
  } catch (e, stackTrace) {
    SlttLogger.logger.severe('Handler error: $e', e, stackTrace);
    return {
      'statusCode': 500,
      'headers': {'Content-Type': 'application/json'},
      'body': jsonEncode({
        'error': 'Internal server error',
        'message': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      }),
    };
  } finally {
    await mediaStorage?.close();
    await storage?.close();
  }
}

AwsMediaStorage _createMediaStorageFromEnv({
  required AWSCredentials credentials,
}) {
  final bucket = Platform.environment['MEDIA_BUCKET'];
  if (bucket == null || bucket.isEmpty) {
    throw StateError('MEDIA_BUCKET environment variable is required');
  }

  final region =
      Platform.environment['AWS_REGION'] ??
      Platform.environment['AWS_DEFAULT_REGION'] ??
      'us-east-1';

  final cloudFrontDomain =
      Platform.environment['MEDIA_CLOUDFRONT_DOMAIN'] ??
      Platform.environment['CLOUDFRONT_DOMAIN'];
  final cloudFrontKeyPairId =
      Platform.environment['MEDIA_CLOUDFRONT_KEY_PAIR_ID'] ??
      Platform.environment['CLOUDFRONT_KEY_PAIR_ID'];
  final cloudFrontPrivateKey =
      Platform.environment['MEDIA_CLOUDFRONT_PRIVATE_KEY'] ??
      Platform.environment['CLOUDFRONT_PRIVATE_KEY'];

  return AwsMediaStorage(
    bucketName: bucket,
    region: region,
    credentials: credentials,
    cloudFrontDomain: cloudFrontDomain,
    cloudFrontKeyPairId: cloudFrontKeyPairId,
    cloudFrontPrivateKey: cloudFrontPrivateKey,
  );
}
