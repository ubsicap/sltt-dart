import 'package:sltt_core/sltt_core.dart' show SlttLogger;

import 'websocket_connections_repository.dart';

Future<Map<String, dynamic>> wsConnectHandler(
  Map<String, dynamic> event, {
  required WebsocketConnectionsRepository connections,
}) async {
  final requestContext = (event['requestContext'] as Map)
      .cast<String, dynamic>();
  final connectionId = requestContext['connectionId'] as String;
  final authorizerContext = (requestContext['authorizer'] as Map?)
      ?.cast<String, dynamic>();
  final userId = authorizerContext?['userId'] as String?;
  final isTestToken = _coerceBool(authorizerContext?['isTestToken']);

  SlttLogger.logger.info(
    'wsConnect: entry connectionId=$connectionId isTestToken=$isTestToken',
  );

  if (userId == null) {
    // Shouldn't happen if wsAuthorizer is wired in serverless.yml, but fail
    // closed rather than recording an unattributed connection.
    SlttLogger.logger.severe(
      'wsConnect: missing userId in authorizer context for $connectionId',
    );
    return {'statusCode': 500};
  }

  await connections.putConnection(
    connectionId: connectionId,
    userId: userId,
    isTestToken: isTestToken,
  );
  SlttLogger.logger.info(
    'wsConnect: saved connection $connectionId userId=$userId isTestToken=$isTestToken',
  );
  return {'statusCode': 200};
}

bool _coerceBool(Object? value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}
