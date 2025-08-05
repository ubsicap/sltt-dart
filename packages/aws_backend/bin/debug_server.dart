import 'dart:io';

import 'package:aws_backend/aws_backend.dart';

/// Debugger entrypoint for AWS backend that sets up environment variables
/// from serverless deployment and runs a local shelf server for debugging.
///
/// Usage:
///   dart run bin/debug_server.dart [--aws-profile profile-name] [--stage stage-name] [--port port-number]
///
/// This allows you to debug the AWS backend locally while connecting to the
/// real DynamoDB table in AWS, with all environment variables properly set.
Future<void> main(List<String> args) async {
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

  try {
    // Get configuration from environment variables (set by run_debug_server.sh)
    final useCloudStorage = Platform.environment['USE_CLOUD_STORAGE'] ?? 'true';
    final useLocalDynamoDB = useCloudStorage != 'true';

    // Create DynamoDB storage service
    final storageInstance = StorageFactory.createStorage(
      useLocalDynamoDB: useLocalDynamoDB,
    );

    print('🗄️  Configuration:');
    print('   Table: ${storageInstance.tableName}');
    print('   Region: ${storageInstance.region}');
    print('   USE_CLOUD_STORAGE: $useCloudStorage');
    print('   useLocalDynamoDB: ${storageInstance.useLocalDynamoDB}');

    print('🗄️  Connecting to DynamoDB...');

    // Initialize storage
    await storageInstance.initialize();
    print('✅ DynamoDB connection established');

    // Create server instance
    final serverInstance = AwsRestApiServer(
      serverName: 'Debug AWS Backend',
      storage: storageInstance,
    );

    print('🚀 Starting debug server...');
    // Use the server's start method to ensure middleware is applied
    await serverInstance.start(port: port);

    print('✅ Debug server running on http://localhost:$port');
    print('📡 Connected to AWS DynamoDB table: ${storageInstance.tableName}');
    print('🐛 Ready for VS Code debugging!');
    print('');
    print('Available endpoints:');
    print('   GET  /health                           - Health check');
    print('   GET  /api/help                         - API documentation');
    print('   POST /api/changes                      - Create changes');
    print('   GET  /api/projects                     - List all projects');
    print('   GET  /api/projects/{id}/changes        - Get project changes');
    print('   GET  /api/projects/{id}/stats          - Get project stats');
    print('');
    print('Press Ctrl+C to stop the server');

    // Handle shutdown gracefully
    ProcessSignal.sigint.watch().listen((signal) async {
      print('\n🛑 Shutting down debug server...');
      await serverInstance.stop();
      print('✅ Debug server stopped');
      exit(0);
    });

    // Keep the server running indefinitely
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
    }
  } catch (e, stackTrace) {
    print('❌ Error setting up debug environment: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
