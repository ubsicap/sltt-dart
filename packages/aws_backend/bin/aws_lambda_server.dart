import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/aws_backend.dart';
import 'package:aws_backend/src/utils/media_environment.dart';
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
    Future<AWSCredentials> resolveLambdaCredentials([bool? useAssumeRole]) {
      return AwsCredentialsService().getOrCreateCredentials(
        useAssumeRole: useAssumeRole,
      );
    }

    storage = StorageFactory.createStorage(
      credentials: credentials,
      credentialsResolver: resolveLambdaCredentials,
    );
    mediaStorage = _createMediaStorageFromEnv(credentials: credentials);
    authService = BackendAuthServiceFactory.createFromEnvironment(
      credentials: credentials,
      appStorage: storage,
      environment: Platform.environment,
      credentialsResolver: resolveLambdaCredentials,
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
  final requestContext = (event['requestContext'] as Map?)
      ?.cast<String, dynamic>();
  final connectionId = requestContext?['connectionId'] as String?;
  SlttLogger.logger.info(
    '[Lambda] _handleWsConnect entry connectionId=$connectionId',
  );

  final connections = await _createConnectionsRepository();
  final management = await _createManagementClient(connections);
  try {
    return await wsConnectHandler(event, connections: connections);
  } catch (e, stackTrace) {
    SlttLogger.logger.severe(
      '[Lambda] _handleWsConnect failed connectionId=$connectionId',
      e,
      stackTrace,
    );
    return await _internalServerErrorResponse(
      handler: 'wsConnect',
      connectionId: connectionId,
      error: e,
      stackTrace: stackTrace,
      management: management,
    );
  } finally {
    await management.close();
    await connections.close();
  }
}

Future<Map<String, dynamic>> _handleWsDisconnect(
  Map<String, dynamic> event,
) async {
  final requestContext = (event['requestContext'] as Map?)
      ?.cast<String, dynamic>();
  final connectionId = requestContext?['connectionId'] as String?;
  SlttLogger.logger.info(
    '[Lambda] _handleWsDisconnect entry connectionId=$connectionId',
  );

  final connections = await _createConnectionsRepository();
  final management = await _createManagementClient(connections);
  try {
    return await wsDisconnectHandler(event, connections: connections);
  } catch (e, stackTrace) {
    SlttLogger.logger.severe(
      '[Lambda] _handleWsDisconnect failed connectionId=$connectionId',
      e,
      stackTrace,
    );
    return await _internalServerErrorResponse(
      handler: 'wsDisconnect',
      connectionId: connectionId,
      error: e,
      stackTrace: stackTrace,
      management: management,
    );
  } finally {
    await management.close();
    await connections.close();
  }
}

Future<Map<String, dynamic>> _handleWsSubscribe(
  Map<String, dynamic> event,
) async {
  final requestContext = (event['requestContext'] as Map?)
      ?.cast<String, dynamic>();
  final connectionId = requestContext?['connectionId'] as String?;
  final routeKey = requestContext?['routeKey'] as String?;
  SlttLogger.logger.info(
    '[Lambda] _handleWsSubscribe entry connectionId=$connectionId routeKey=$routeKey',
  );

  final connections = await _createConnectionsRepository();
  final management = await _createManagementClient(connections);
  final storage = StorageFactory.createStorage(
    credentials: _getExecutionRoleCredentials(),
  );
  try {
    await storage.initialize();

    return await wsSubscribeHandler(
      event,
      connections: connections,
      management: management,
      getDomainChangeStatus:
          ({required String domainType, required String domainId}) async {
            final changeStats = await storage.getChangeStats(
              domainType: domainType,
              domainId: domainId,
            );
            return {
              'lastDomainSeq': changeStats.totals.latestSeq,
              'lastDomainChangeAt': changeStats.totals.latestChangeAt,
            };
          },
    );
  } catch (e, stackTrace) {
    SlttLogger.logger.severe(
      '[Lambda] _handleWsSubscribe failed connectionId=$connectionId routeKey=$routeKey',
      e,
      stackTrace,
    );
    return await _internalServerErrorResponse(
      handler: 'wsSubscribe',
      connectionId: connectionId,
      routeKey: routeKey,
      error: e,
      stackTrace: stackTrace,
      management: management,
    );
  } finally {
    await management.close();
    await connections.close();
    await storage.close();
  }
}

Future<Map<String, dynamic>> _handleWsUnsubscribe(
  Map<String, dynamic> event,
) async {
  final requestContext = (event['requestContext'] as Map?)
      ?.cast<String, dynamic>();
  final connectionId = requestContext?['connectionId'] as String?;
  final routeKey = requestContext?['routeKey'] as String?;
  SlttLogger.logger.info(
    '[Lambda] _handleWsUnsubscribe entry connectionId=$connectionId routeKey=$routeKey',
  );

  final connections = await _createConnectionsRepository();
  final management = await _createManagementClient(connections);
  try {
    return await wsUnsubscribeHandler(
      event,
      connections: connections,
      management: management,
    );
  } catch (e, stackTrace) {
    SlttLogger.logger.severe(
      '[Lambda] _handleWsUnsubscribe failed connectionId=$connectionId routeKey=$routeKey',
      e,
      stackTrace,
    );
    return await _internalServerErrorResponse(
      handler: 'wsUnsubscribe',
      connectionId: connectionId,
      routeKey: routeKey,
      error: e,
      stackTrace: stackTrace,
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
  final requestContext = (event['requestContext'] as Map?)
      ?.cast<String, dynamic>();
  final connectionId = requestContext?['connectionId'] as String?;
  final routeKey = requestContext?['routeKey'] as String?;
  SlttLogger.logger.info(
    '[Lambda] _handleWsDefault entry connectionId=$connectionId routeKey=$routeKey',
  );

  final connections = await _createConnectionsRepository();
  final management = await _createManagementClient(connections);
  try {
    return await wsDefaultHandler(event, management: management);
  } catch (e, stackTrace) {
    SlttLogger.logger.severe(
      '[Lambda] _handleWsDefault failed connectionId=$connectionId routeKey=$routeKey',
      e,
      stackTrace,
    );
    return await _internalServerErrorResponse(
      handler: 'wsDefault',
      connectionId: connectionId,
      routeKey: routeKey,
      error: e,
      stackTrace: stackTrace,
      management: management,
    );
  } finally {
    await management.close();
    await connections.close();
  }
}

Future<Map<String, dynamic>> _handleWsNotify(Map<String, dynamic> event) async {
  final requestContext = (event['requestContext'] as Map?)
      ?.cast<String, dynamic>();
  final connectionId = requestContext?['connectionId'] as String?;
  final routeKey = requestContext?['routeKey'] as String?;
  SlttLogger.logger.info(
    '[Lambda] _handleWsNotify entry connectionId=$connectionId routeKey=$routeKey',
  );

  final connections = await _createConnectionsRepository();
  final management = await _createManagementClient(connections);
  try {
    return await wsNotifyHandler(
      event,
      connections: connections,
      management: management,
    );
  } catch (e, stackTrace) {
    SlttLogger.logger.severe(
      '[Lambda] _handleWsNotify failed connectionId=$connectionId routeKey=$routeKey',
      e,
      stackTrace,
    );
    return await _internalServerErrorResponse(
      handler: 'wsNotify',
      connectionId: connectionId,
      routeKey: routeKey,
      error: e,
      stackTrace: stackTrace,
      management: management,
    );
  } finally {
    await management.close();
    await connections.close();
  }
}

Future<WebsocketConnectionsRepository> _createConnectionsRepository() async {
  final credentials = _getExecutionRoleCredentials();
  final tableName = _requireEnv('WEBSOCKET_CONNECTIONS_TABLE');
  final region = _region();
  return WebsocketConnectionsRepository(
    tableName: tableName,
    gsiName: _websocketConnectionsGsi,
    region: region,
    credentials: credentials,
  );
}

AWSCredentials _getExecutionRoleCredentials() {
  final accessKey = Platform.environment['AWS_ACCESS_KEY_ID'];
  final secretKey = Platform.environment['AWS_SECRET_ACCESS_KEY'];
  final sessionToken = Platform.environment['AWS_SESSION_TOKEN'];

  if (accessKey == null || secretKey == null) {
    throw StateError(
      'AWS execution role credentials are not available in the environment',
    );
  }

  return AWSCredentials(accessKey, secretKey, sessionToken);
}

Future<WebsocketManagementClient> _createManagementClient(
  WebsocketConnectionsRepository connections,
) async {
  final credentials = _getExecutionRoleCredentials();
  final endpointUrl = _requireEnv('WEBSOCKET_API_ENDPOINT');
  final region = _region();

  SlttLogger.logger.info(
    '[Lambda] creating WebsocketManagementClient endpoint=$endpointUrl region=$region sessionTokenPresent=${credentials.sessionToken != null}',
  );

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

Future<Map<String, dynamic>> _internalServerErrorResponse({
  required String handler,
  String? connectionId,
  String? routeKey,
  Object? error,
  StackTrace? stackTrace,
  WebsocketManagementClient? management,
}) async {
  if (management != null && connectionId != null) {
    final websocketBody = <String, dynamic>{
      'action': 'serverError',
      'handler': handler,
      if (routeKey != null) 'routeKey': routeKey,
      'timestamp': DateTime.now().toIso8601String(),
      'message': 'Internal server error',
      if (error != null) 'error': error.toString(),
      if (Platform.environment['SLTT_DEBUG'] == 'true' && stackTrace != null)
        'stack': stackTrace.toString(),
    };
    try {
      await management.send(connectionId, websocketBody);
    } catch (sendError, sendStack) {
      SlttLogger.logger.warning(
        '[Lambda] failed to send websocket error feedback connectionId=$connectionId handler=$handler routeKey=$routeKey',
        sendError,
        sendStack,
      );
    }
  }

  final body = <String, dynamic>{
    'error': 'Internal server error',
    'handler': handler,
    if (connectionId != null) 'connectionId': connectionId,
    if (routeKey != null) 'routeKey': routeKey,
  };
  if (Platform.environment['SLTT_DEBUG'] == 'true') {
    body['detail'] = error?.toString();
  }

  return {
    'statusCode': 500,
    'headers': {'Content-Type': 'application/json'},
    'body': jsonEncode(body),
  };
}

AwsMediaStorage _createMediaStorageFromEnv({
  required AWSCredentials credentials,
}) {
  final bucket = Platform.environment['MEDIA_BUCKET'];
  if (bucket == null || bucket.isEmpty) {
    throw StateError('MEDIA_BUCKET environment variable is required');
  }

  final region = getMediaBucketRegion(Platform.environment);

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
