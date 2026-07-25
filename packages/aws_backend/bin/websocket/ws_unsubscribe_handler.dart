import 'dart:convert';

import 'package:sltt_core/sltt_core.dart' show WebsocketConstants;

import 'websocket_connections_repository.dart';
import 'websocket_management_client.dart';

/// Handles {"action":"unsubscribe","domainType":...,"domainId":...,"entityType":...}
/// Must match the same domainType/domainId/entityType (or lack thereof)
/// used when subscribing, since that's how the row's key is built.
Future<Map<String, dynamic>> wsUnsubscribeHandler(
  Map<String, dynamic> event, {
  required WebsocketConnectionsRepository connections,
  required WebsocketManagementClient management,
}) async {
  final requestContext = (event['requestContext'] as Map)
      .cast<String, dynamic>();
  final connectionId = requestContext['connectionId'] as String;
  final body =
      jsonDecode(event['body'] as String? ?? '{}') as Map<String, dynamic>;

  final domainType = body['domainType'] as String?;
  final domainId = body['domainId'] as String?;
  final entityType = body['entityType'] as String?;

  if (domainType == null ||
      domainType.isEmpty ||
      domainId == null ||
      domainId.isEmpty) {
    await management.send(connectionId, {
      'action': WebsocketConstants.actionUnsubscribe,
      'status': 'error',
      'error': 'domainType and domainId are required',
    });
    return {'statusCode': 400};
  }

  final notifyType = entityType == WebsocketConstants.notifyTypeDomainStats
      ? WebsocketConstants.notifyTypeDomainStats
      : WebsocketConstants.notifyTypeDomainChange;

  await connections.deleteSubscription(
    connectionId: connectionId,
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    notifyType: notifyType,
  );

  await management.send(connectionId, {
    'action': WebsocketConstants.actionUnsubscribe,
    'status': 'ok',
    'domainType': domainType,
    'domainId': domainId,
    'entityType': entityType,
  });

  return {'statusCode': 200};
}
