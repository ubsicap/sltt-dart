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

  if (userId == null) {
    // Shouldn't happen if wsAuthorizer is wired in serverless.yml, but fail
    // closed rather than recording an unattributed connection.
    SlttLogger.logger.severe(
      'wsConnect: missing userId in authorizer context for $connectionId',
    );
    return {'statusCode': 500};
  }

  await connections.putConnection(connectionId: connectionId, userId: userId);
  return {'statusCode': 200};
}
