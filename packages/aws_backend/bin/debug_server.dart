import 'dart:io';

import 'package:aws_backend/aws_backend.dart';
import 'package:aws_backend/src/utils/media_environment.dart';
import 'package:aws_common/aws_common.dart' show AWSCredentials;
import 'package:sltt_core/sltt_core.dart';

/// Debugger entrypoint for AWS backend that sets up environment variables
/// from serverless deployment and runs a local shelf server for debugging.
///
/// Usage:
///   dart run bin/debug_server.dart [--aws-profile profile-name] [--stage stage-name] [--port port-number]
///
/// This allows you to debug the AWS backend locally while connecting to the
/// real DynamoDB table in AWS, with all environment variables properly set.
Future<void> main(List<String> args) async {
  // Enable debug logging for the debug server
  SlttLogger.init(level: SlttLogLevel.fine);

  // Parse command line arguments
  String? awsProfile;
  String stage = 'dev';
  int port = 8080;

  for (int i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--aws-profile':
        if (i + 1 < args.length) {
          awsProfile = args[i + 1];
          i++;
        }
        break;
      case '--stage':
        if (i + 1 < args.length) {
          stage = args[i + 1];
          i++;
        }
        break;
      case '--port':
        if (i + 1 < args.length) {
          port = int.tryParse(args[i + 1]) ?? 8080;
          i++;
        }
        break;
      case '--help':
        print('''
Debug Server for AWS Backend

Usage: dart run bin/debug_server.dart [options]

Options:
  --aws-profile <profile>  AWS profile to use (default: sltt-dart-dev)
  --stage <stage>          Deployment stage (default: dev)
  --port <port>           Local server port (default: 8080)
  --help                  Show this help message

This tool:
1. Connects to the real DynamoDB table using AWS credentials from environment
2. Starts a local shelf server that uses the same logic as AWS Lambda
3. Allows VS Code debugging while using real AWS resources

Note: For automatic credential setup, use the run_debug_server.sh script instead.
''');
        return;
    }
  }

  awsProfile ??= 'sltt-dart-dev';

  print('🔧 Setting up debug environment...');
  print('   AWS Profile: $awsProfile');
  print('   Stage: $stage');
  print('   Port: $port');

  final gitHealthEnvironment = await _resolveGitHealthEnvironment();

  // Get configuration from environment variables (set by run_debug_server.sh)
  final useCloudStorage = Platform.environment['USE_CLOUD_STORAGE'] ?? 'true';
  final useLocalDynamoDB = useCloudStorage != 'true';

  DynamoDBStorageService? storage;
  AwsMediaStorage? mediaStorage;

  try {
    final credentialsService = AwsCredentialsService();

    Future<AWSCredentials> resolveCredentials([bool? useAssumeRole]) {
      return credentialsService.getOrCreateCredentials(
        useAssumeRole: useAssumeRole,
      );
    }

    // Get credentials first - may throw AwsCredentialsException
    final credentials = await credentialsService.getOrCreateCredentials();
    storage = StorageFactory.createStorage(
      credentials: credentials,
      useLocalDynamoDB: useLocalDynamoDB,
      credentialsResolver: resolveCredentials,
    );

    final mediaBucket = Platform.environment['MEDIA_BUCKET'];
    final mediaRegion = getMediaBucketRegion(Platform.environment);
    final cloudFrontDomain = Platform.environment['MEDIA_CLOUDFRONT_DOMAIN'];
    final cloudFrontKeyPairId =
        Platform.environment['MEDIA_CLOUDFRONT_KEY_PAIR_ID'];
    final cloudFrontPrivateKey =
        Platform.environment['MEDIA_CLOUDFRONT_PRIVATE_KEY'];
    final authTable = Platform.environment['AUTH_TABLE'];
    final authTableArn = Platform.environment['AUTH_TABLE_ARN'];
    final authJwtSecret = Platform.environment['AUTH_JWT_SECRET'];
    final authAccessTokenTtlMinutes =
        Platform.environment['AUTH_ACCESS_TOKEN_TTL_MINUTES'];
    final authRefreshTokenTtlDays =
        Platform.environment['AUTH_REFRESH_TOKEN_TTL_DAYS'];
    final authEmailMode = Platform.environment['AUTH_EMAIL_MODE'];
    final authSesFromEmail = Platform.environment['AUTH_SES_FROM_EMAIL'];
    final authVerificationCodeSecret =
        Platform.environment['AUTH_VERIFICATION_CODE_SECRET'];

    mediaStorage = AwsMediaStorage(
      bucketName: mediaBucket ?? '',
      region: mediaRegion,
      credentials: credentials,
      cloudFrontDomain: cloudFrontDomain,
      cloudFrontKeyPairId: cloudFrontKeyPairId,
      cloudFrontPrivateKey: cloudFrontPrivateKey,
    );

    if (mediaBucket == null || mediaBucket.isEmpty) {
      throw StateError('MEDIA_BUCKET environment variable is required');
    }

    print('🗄️  Configuration:');
    print('   Table: ${storage.tableName}');
    print('   Region: ${storage.region}');
    print('   USE_CLOUD_STORAGE: $useCloudStorage');
    print('   useLocalDynamoDB: ${storage.useLocalDynamoDB}');
    print('   MEDIA_BUCKET: $mediaBucket');
    print(
      '   MEDIA_BUCKET_REGION: ${Platform.environment['MEDIA_BUCKET_REGION'] ?? '(unset)'}',
    );
    print('   CLOUDFRONT_DOMAIN: $cloudFrontDomain');
    print('   CLOUDFRONT_KEY_PAIR_ID: $cloudFrontKeyPairId');
    print('   AUTH_TABLE: $authTable');
    print('   AUTH_TABLE_ARN: $authTableArn');
    print('   AUTH_ACCESS_TOKEN_TTL_MINUTES: $authAccessTokenTtlMinutes');
    print('   AUTH_REFRESH_TOKEN_TTL_DAYS: $authRefreshTokenTtlDays');
    print('   AUTH_EMAIL_MODE: $authEmailMode');
    print('   AUTH_SES_FROM_EMAIL: $authSesFromEmail');
    print(
      '   AUTH_JWT_SECRET: ${authJwtSecret == null || authJwtSecret.isEmpty ? '(missing)' : '(set)'}',
    );
    print(
      '   AUTH_VERIFICATION_CODE_SECRET: ${authVerificationCodeSecret == null || authVerificationCodeSecret.isEmpty ? '(missing)' : '(set)'}',
    );
    if (gitHealthEnvironment.containsKey('GIT_SHORT_CHANGESET')) {
      print(
        '   GIT_SHORT_CHANGESET: ${gitHealthEnvironment['GIT_SHORT_CHANGESET']}',
      );
    }
    if (gitHealthEnvironment.containsKey('GIT_DIRTY_FLAG')) {
      print('   GIT_DIRTY_FLAG: ${gitHealthEnvironment['GIT_DIRTY_FLAG']}');
    }

    print('🗄️  Connecting to DynamoDB...');

    // Initialize storage
    await storage.initialize();
    await mediaStorage.initialize();
    print('✅ DynamoDB connection established');

    // Create server instance
    final authService = BackendAuthServiceFactory.createFromEnvironment(
      credentials: credentials,
      appStorage: storage,
      environment: Platform.environment,
      credentialsResolver: resolveCredentials,
    );
    await authService?.initialize();
    if (authService == null) {
      print(
        '⚠️  Auth service is disabled. Set AUTH_TABLE and AUTH_JWT_SECRET to exercise auth routes locally.',
      );
    }
    final serverInstance = AwsRestApiServer(
      serverName: 'Debug AWS Backend',
      storage: storage,
      mediaStorage: mediaStorage,
      healthEnvironmentOverrides: gitHealthEnvironment,
      authService: authService,
    );

    print('🚀 Starting debug server...');
    // Use the server's start method to ensure middleware is applied
    await serverInstance.start(port: port);

    print('✅ Debug server running on http://localhost:$port');
    print('📡 Connected to AWS DynamoDB table: ${storage.tableName}');
    print('🐛 Ready for VS Code debugging!');
    print('');
    print('Available endpoints:');
    print('   GET  /health                            - Health check');
    print('   GET  /api/help                          - API documentation');
    print('   POST /api/changes                       - Create changes');
    print('   GET  /api/ids/projects                  - List all projects');
    print('   GET  /api/changes/projects/{id}         - Get project changes');
    print('   GET  /api/state/projects/{id}/portions  - Get entity states');
    if (authService != null) {
      print(
        '   POST /api/auth/register                 - Start self-registration',
      );
      print('   POST /api/auth/verify-email             - Verify email code');
      print(
        '   POST /api/auth/login                    - Login with email or username',
      );
      print('   GET  /api/admin/adhoc-users             - List AdHoc users');
    }
    print('');
    print('Press Ctrl+C to stop the server');

    // Handle shutdown gracefully
    ProcessSignal.sigint.watch().listen((signal) async {
      print('\n🛑 Shutting down debug server...');
      await serverInstance.stop();
      await authService?.close();
      print('✅ Debug server stopped');
      exit(0);
    });

    // Keep the server running indefinitely
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
    }
  } on AwsCredentialsException catch (e, stackTrace) {
    print('❌ Credentials error: $e');
    print('Stack trace: $stackTrace');
    await mediaStorage?.close();
    await storage?.close();
    exit(1);
  } catch (e, stackTrace) {
    print('❌ Error setting up debug environment: $e');
    print('Stack trace: $stackTrace');
    await mediaStorage?.close();
    await storage?.close();
    exit(1);
  }
}

Future<Map<String, String>> _resolveGitHealthEnvironment() async {
  final gitEnvironment = <String, String>{};

  try {
    final shortShaResult = await Process.run('git', [
      'rev-parse',
      '--short',
      'HEAD',
    ]);
    if (shortShaResult.exitCode == 0) {
      final shortSha = (shortShaResult.stdout as String).trim();
      if (shortSha.isNotEmpty) {
        gitEnvironment['GIT_SHORT_CHANGESET'] = shortSha;
      }
    }

    final statusResult = await Process.run('git', ['status', '--porcelain']);
    if (statusResult.exitCode == 0) {
      final isDirty = (statusResult.stdout as String).trim().isNotEmpty;
      gitEnvironment['GIT_DIRTY_FLAG'] = isDirty ? 'true' : 'false';
    }
  } catch (_) {
    // Keep debug startup resilient when git is unavailable.
  }

  return gitEnvironment;
}
