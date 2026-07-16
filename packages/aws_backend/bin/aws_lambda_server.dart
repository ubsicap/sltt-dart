import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/aws_backend.dart';
import 'package:aws_common/aws_common.dart' show AWSCredentials;
import 'package:sltt_core/sltt_core.dart' show SlttLogger;

import 'websocket/websocket_connections_repository.dart';
import 'websocket/websocket_management_client.dart';
import 'websocket/ws_authorizer_handler.dart';
import 'websocket/ws_connect_handler.dart';
import 'websocket/ws_default_handler.dart';
import 'websocket/ws_disconnect_handler.dart';
import 'websocket/ws_notify_handler.dart';
import 'websocket/ws_subscribe_handler.dart';
import 'websocket/ws_unsubscribe_handler.dart';

// Must match the GSI name declared on WebsocketConnectionsTable in serverless.yml
const _websocketConnectionsGsi = 'gsi1-domain-subscriptions';

/// AWS Lambda handler for the SLTT backend.
///
/// Every function in serverless.yml points at the same `bootstrap` binary
/// (inherent to the `provided.al2` custom runtime - there's no per-function
/// handler string like Node has), so LAMBDA_ENTRYPOINT tells this single
/// entrypoint which logical function it's running as for this invocation.
/// Unset/"api" preserves the original REST behavior.
Future<Map<String, dynamic>> handler(Map<String, dynamic> event) async {
  final entrypoint = Platform.environment['LAMBDA_ENTRYPOINT'] ?? 'api';

  switch (entrypoint) {
    case 'wsAuthorizer':
      return _handleWsAuthorizer(event);
    case 'wsConnect':
      return _handleWsConnect(event);
    case 'wsDisconnect':
      return _handleWsDisconnect(event);
    case 'wsSubscribe':
      return _handleWsSubscribe(event);
    case 'wsUnsubscribe':
      return _handleWsUnsubscribe(event);
    case 'wsDefault':
      return _handleWsDefault(event);
    case 'wsNotify':
      return _handleWsNotify(event);
    default:
      return _handleApi(event);
  }
}

/// Original REST API Gateway handler, unchanged - uses AwsRestApiServer for
/// consistent routing/behavior with local development.
Future<Map<String, dynamic>> _handleApi(Map<String, dynamic> event) async {
  DynamoDBStorageService? storage;
  AwsMediaStorage? mediaStorage;
  BackendAuthService? authService;
  Map<String, dynamic>? response;
  final total = Stopwatch()..start();
  final requestSummary =
      '${event['httpMethod'] as String? ?? 'UNKNOWN'} ${event['path'] as String? ?? '/'}';

  try {
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

    final server = AwsRestApiServer(
      serverName: 'AWS Lambda API',
      storage: storage,
      mediaStorage: mediaStorage,
      authService: authService,
    );

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

// --- Websocket / SNS entrypoints -------------------------------------------
//
// Each of these builds only the services it needs (auth for the authorizer;
// the connections repo for connect/disconnect/subscribe/unsubscribe/notify;
// the management client - which can push to open sockets - for anything
// that acks or broadcasts) and tears them down in `finally`, matching the
// per-invocation construct/close pattern _handleApi already uses.

Future<Map<String, dynamic>> _handleWsAuthorizer(
  Map<String, dynamic> event,
) async {
  BackendAuthService? authService;
  try {
    final credentials = await AwsCredentialsService().getOrCreateCredentials();
    final storage = StorageFactory.createStorage(credentials: credentials);
    authService = BackendAuthServiceFactory.createFromEnvironment(
      credentials: credentials,
      appStorage: storage,
      environment: Platform.environment,
    );
    await authService?.initialize();
    return await wsAuthorizerHandler(event, authService: authService!);
  } finally {
    await authService?.close();
  }
}

Future<Map<String, dynamic>> _handleWsConnect(
  Map<String, dynamic> event,
) async {
  final connections = await _createConnectionsRepository();
  try {
    return await wsConnectHandler(event, connections: connections);
  } finally {
    await connections.close();
  }
}

Future<Map<String, dynamic>> _handleWsDisconnect(
  Map<String, dynamic> event,
) async {
  final connections = await _createConnectionsRepository();
  try {
    return await wsDisconnectHandler(event, connections: connections);
  } finally {
    await connections.close();
  }
}

Future<Map<String, dynamic>> _handleWsSubscribe(
  Map<String, dynamic> event,
) async {
  final connections = await _createConnectionsRepository();
  final management = await _createManagementClient(connections);
  try {
    return await wsSubscribeHandler(
      event,
      connections: connections,
      management: management,
    );
  } finally {
    await management.close();
    await connections.close();
  }
}

Future<Map<String, dynamic>> _handleWsUnsubscribe(
  Map<String, dynamic> event,
) async {
  final connections = await _createConnectionsRepository();
  final management = await _createManagementClient(connections);
  try {
    return await wsUnsubscribeHandler(
      event,
      connections: connections,
      management: management,
    );
  } finally {
    await management.close();
    await connections.close();
  }
}

Future<Map<String, dynamic>> _handleWsDefault(
  Map<String, dynamic> event,
) async {
  final connections = await _createConnectionsRepository();
  final management = await _createManagementClient(connections);
  try {
    return await wsDefaultHandler(event, management: management);
  } finally {
    await management.close();
    await connections.close();
  }
}

Future<Map<String, dynamic>> _handleWsNotify(
  Map<String, dynamic> event,
) async {
  final connections = await _createConnectionsRepository();
  final management = await _createManagementClient(connections);
  try {
    return await wsNotifyHandler(
      event,
      connections: connections,
      management: management,
    );
  } finally {
    await management.close();
    await connections.close();
  }
}

Future<WebsocketConnectionsRepository> _createConnectionsRepository() async {
  final credentials = await AwsCredentialsService().getOrCreateCredentials();
  final tableName = _requireEnv('WEBSOCKET_CONNECTIONS_TABLE');
  final region = _region();
  return WebsocketConnectionsRepository(
    tableName: tableName,
    gsiName: _websocketConnectionsGsi,
    region: region,
    credentials: credentials,
  );
}

Future<WebsocketManagementClient> _createManagementClient(
  WebsocketConnectionsRepository connections,
) async {
  final credentials = await AwsCredentialsService().getOrCreateCredentials();
  final endpointUrl = _requireEnv('WEBSOCKET_API_ENDPOINT');
  final region = _region();
  return WebsocketManagementClient(
    endpointUrl: endpointUrl,
    region: region,
    credentials: credentials,
    connections: connections,
  );
}

String _region() =>
    Platform.environment['AWS_REGION'] ??
    Platform.environment['AWS_DEFAULT_REGION'] ??
    'us-east-1';

String _requireEnv(String key) {
  final value = Platform.environment[key];
  if (value == null || value.isEmpty) {
    throw StateError('$key environment variable is required');
  }
  return value;
}

AwsMediaStorage _createMediaStorageFromEnv({
  required AWSCredentials credentials,
}) {
  final bucket = Platform.environment['MEDIA_BUCKET'];
  if (bucket == null || bucket.isEmpty) {
    throw StateError('MEDIA_BUCKET environment variable is required');
  }

  final region = _region();

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
