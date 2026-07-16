import 'dart:convert';

import 'websocket_connections_repository.dart';
import 'websocket_management_client.dart';

/// Handles {"action":"subscribe","domainType":...,"domainId":...,"entityType":...}
/// entityType is optional; omitting it subscribes to all entity types on
/// that domain.
Future<Map<String, dynamic>> wsSubscribeHandler(
  Map<String, dynamic> event, {
  required WebsocketConnectionsRepository connections,
  required WebsocketManagementClient management,
}) async {
  final requestContext = (event['requestContext'] as Map)
      .cast<String, dynamic>();
  final connectionId = requestContext['connectionId'] as String;
  final body = jsonDecode(event['body'] as String? ?? '{}') as Map<String, dynamic>;

  final domainType = body['domainType'] as String?;
  final domainId = body['domainId'] as String?;
  final entityType = body['entityType'] as String?;

  if (domainType == null ||
      domainType.isEmpty ||
      domainId == null ||
      domainId.isEmpty) {
    await management.send(connectionId, {
      'action': 'subscribe',
      'status': 'error',
      'error': 'domainType and domainId are required',
    });
    return {'statusCode': 400};
  }

  await connections.putSubscription(
    connectionId: connectionId,
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
  );

  await management.send(connectionId, {
    'action': 'subscribe',
    'status': 'ok',
    'domainType': domainType,
    'domainId': domainId,
    'entityType': entityType,
  });

  return {'statusCode': 200};
}
