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
  BackendAuthService? authService;
  Map<String, dynamic>? response;
  final total = Stopwatch()..start();
  final requestSummary =
      '${event['httpMethod'] as String? ?? 'UNKNOWN'} ${event['path'] as String? ?? '/'}';

  try {
    // Get credentials first - may throw AwsCredentialsException
    var stage = Stopwatch()..start();
    final credentials = await AwsCredentialsService().getOrCreateCredentials();
    SlttLogger.logger.info(
      '[LambdaTiming] stage=getCredentials elapsedMs=${stage.elapsedMilliseconds} request="$requestSummary"',
    );

    stage = Stopwatch()..start();
    storage = StorageFactory.createStorage(credentials: credentials);
    mediaStorage = _createMediaStorageFromEnv(credentials: credentials);
    authService = BackendAuthServiceFactory.createFromEnvironment(
      credentials: credentials,
      appStorage: storage,
      environment: Platform.environment,
    );
    SlttLogger.logger.info(
      '[LambdaTiming] stage=createServices elapsedMs=${stage.elapsedMilliseconds} request="$requestSummary" authEnabled=${authService != null}',
    );

    stage = Stopwatch()..start();
    await storage.initialize();
    await mediaStorage.initialize();
    await authService?.initialize();
    SlttLogger.logger.info(
      '[LambdaTiming] stage=initializeServices elapsedMs=${stage.elapsedMilliseconds} request="$requestSummary"',
    );

    // Create AwsRestApiServer instance
    final server = AwsRestApiServer(
      serverName: 'AWS Lambda API',
      storage: storage,
      mediaStorage: mediaStorage,
      authService: authService,
    );

    // Get router and process the API Gateway event
    final router = server.getRouter();
    stage = Stopwatch()..start();
    response = await server.handleApiGatewayEvent(event, router);
    SlttLogger.logger.info(
      '[LambdaTiming] stage=handleApiGatewayEvent elapsedMs=${stage.elapsedMilliseconds} request="$requestSummary" statusCode=${response['statusCode']}',
    );

    return response;
  } on AwsCredentialsException catch (e, stackTrace) {
    SlttLogger.logger.severe('Credentials error: $e', e, stackTrace);
    response = {
      'statusCode': e.statusCode,
      'headers': {'Content-Type': 'application/json'},
      'body': jsonEncode({
        'error': 'Authentication failed',
        'message': e.message,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    };
    return response;
  } catch (e, stackTrace) {
    SlttLogger.logger.severe('Handler error: $e', e, stackTrace);
    response = {
      'statusCode': 500,
      'headers': {'Content-Type': 'application/json'},
      'body': jsonEncode({
        'error': 'Internal server error',
        'message': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      }),
    };
    return response;
  } finally {
    final cleanup = Stopwatch()..start();
    await authService?.close();
    await mediaStorage?.close();
    await storage?.close();
    SlttLogger.logger.info(
      '[LambdaTiming] stage=cleanup elapsedMs=${cleanup.elapsedMilliseconds} request="$requestSummary"',
    );
    SlttLogger.logger.info(
      '[LambdaTiming] stage=total elapsedMs=${total.elapsedMilliseconds} request="$requestSummary" statusCode=${response?['statusCode'] ?? 'unknown'}',
    );
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
