import 'dart:io';

import 'package:aws_backend/aws_backend.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

/// Create storage service with custom environment variables
DynamoDBStorageService createStorageWithConfig({
  required Map<String, String> envVars,
  required bool useLocalDynamoDB,
}) {
  final tableName = envVars['DYNAMODB_TABLE'] ?? 'sltt-backend-changes-dev';
  final region = envVars['DYNAMODB_REGION'] ?? 'us-east-1';
  
  return DynamoDBStorageService(
    tableName: tableName,
    region: region,
    useLocalDynamoDB: useLocalDynamoDB,
  );
}

/// Setup environment variables by running serverless info command
Future<Map<String, String>> setupEnvironmentFromServerless(
  String awsProfile,
  String stage,
) async {
  print('📋 Getting serverless deployment info...');

  try {
    // Run serverless info command to get environment details
    final result = await Process.run('npx', [
      'serverless',
      'info',
      '--stage',
      stage,
      '--aws-profile',
      awsProfile,
    ], workingDirectory: Directory.current.path);

    if (result.exitCode != 0) {
      print('❌ Failed to get serverless info:');
      print('stdout: ${result.stdout}');
      print('stderr: ${result.stderr}');
      throw Exception(
        'serverless info command failed with exit code ${result.exitCode}',
      );
    }

    // Parse the text output to extract environment variables
    // final output = result.stdout as String;
    print('✅ Serverless info retrieved successfully');
    
    // For now, return default environment variables
    // TODO: Parse the serverless info output to extract actual values
    final envVars = {
      'STAGE': stage,
      'DYNAMODB_TABLE': 'sltt-backend-changes-$stage',
      'DYNAMODB_REGION': 'us-east-1',
      'AWS_REGION': 'us-east-1',
      'LOCAL_DEBUGGER': 'true',
    };

    print('   Environment variables:');
    for (final entry in envVars.entries) {
      print('   ${entry.key}=${entry.value}');
    }

    return envVars;
  } catch (e) {
    print('⚠️  Warning: Could not get serverless info, using defaults: $e');
    // Set fallback environment variables
    final envVars = {
      'STAGE': stage,
      'DYNAMODB_TABLE': 'sltt-backend-changes-$stage',
      'DYNAMODB_REGION': 'us-east-1',
      'AWS_REGION': 'us-east-1',
      'LOCAL_DEBUGGER': 'true',
    };
    
    print('   Using fallback environment variables:');
    for (final entry in envVars.entries) {
      print('   ${entry.key}=${entry.value}');
    }
    
    return envVars;
  }
}

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
          i++; // Skip next argument
        }
        break;
      case '--stage':
        if (i + 1 < args.length) {
          stage = args[i + 1];
          i++; // Skip next argument
        }
        break;
      case '--port':
        if (i + 1 < args.length) {
          port = int.tryParse(args[i + 1]) ?? 8080;
          i++; // Skip next argument
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
1. Runs 'serverless info' to get deployment information
2. Sets up environment variables to match the deployed AWS environment
3. Starts a local shelf server that connects to the real DynamoDB table
4. Allows VS Code debugging while using real AWS resources
''');
        return;
    }
  }

  // Use default profile if not specified
  awsProfile ??= 'sltt-dart-dev';

  print('🔧 Setting up debug environment...');
  print('   AWS Profile: $awsProfile');
  print('   Stage: $stage');
  print('   Port: $port');

  try {
    // Get serverless deployment info and environment variables
    final envVars = await setupEnvironmentFromServerless(awsProfile, stage);

    // Set debug-specific environment variables
    envVars['LOCAL_DEBUGGER'] = 'true';
    // Only set USE_CLOUD_STORAGE if not already set from command line
    envVars['USE_CLOUD_STORAGE'] ??= 'true';

    // Determine useLocalDynamoDB from USE_CLOUD_STORAGE
    final useCloudStorage = envVars['USE_CLOUD_STORAGE'] ?? 'true';
    final useLocalDynamoDB = useCloudStorage != 'true';

    // Create DynamoDB storage service using our helper function
    final storageInstance = createStorageWithConfig(
      envVars: envVars,
      useLocalDynamoDB: useLocalDynamoDB,
    );

    print('🗄️  Connecting to DynamoDB...');
    print('   Table: ${envVars['DYNAMODB_TABLE']}');
    print('   Region: ${envVars['DYNAMODB_REGION']}');
    print('   USE_CLOUD_STORAGE: $useCloudStorage');
    print('   useLocalDynamoDB: $useLocalDynamoDB');

    // Initialize storage
    await storageInstance.initialize();
    print('✅ DynamoDB connection established');

    // Create server instance
    final serverInstance = AwsRestApiServer(
      serverName: 'Debug AWS Backend',
      storage: storageInstance,
    );

    // Get the router and start shelf server directly
    final router = serverInstance.getRouter();

    print('🚀 Starting debug server...');
    final shelfServer = await shelf_io.serve(
      router.call,
      InternetAddress.anyIPv4,
      port,
    );

    print('✅ Debug server running on http://localhost:$port');
    print(
      '📡 Connected to AWS DynamoDB table: ${envVars['DYNAMODB_TABLE']}',
    );
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
      await shelfServer.close();
      await storageInstance.close();
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
