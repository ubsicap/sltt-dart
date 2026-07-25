import 'dart:convert';

import 'package:sltt_core/sltt_core.dart' show WebsocketConstants;

import 'websocket_connections_repository.dart';
import 'websocket_keys.dart';
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
  final notifyType = body['notifyType'] as String?;

  bool isValidEntityType(String entityType) {
    return entityType == WebsocketKeys.wildcardEntityType ||
        entityType == WebsocketKeys.lastRecordEntityType ||
        RegExp(r'^[a-z_]+$').hasMatch(entityType);
  }

  final isStatsSubscription =
      notifyType == WebsocketConstants.notifyTypeDomainStats;
  final isChangeSubscription =
      notifyType == WebsocketConstants.notifyTypeDomainChange;

  if (domainType == null ||
      domainType.isEmpty ||
      domainId == null ||
      domainId.isEmpty ||
      notifyType == null ||
      notifyType.isEmpty ||
      !(isChangeSubscription || isStatsSubscription) ||
      entityType == null ||
      entityType.isEmpty ||
      (isChangeSubscription && !isValidEntityType(entityType)) ||
      (isStatsSubscription && entityType != WebsocketKeys.wildcardEntityType)) {
    await management.send(connectionId, {
      'action': WebsocketConstants.actionUnsubscribe,
      'status': 'error',
      'error':
          'domainType, domainId, notifyType, and entityType are required. notifyType must be "domainChange" or "domainStats". entityType must be "*", "\$", or match /^[a-z_]+\$/ for domainChange, and "*" for domainStats.',
    });
    return {'statusCode': 400};
  }

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
    'notifyType': notifyType,
    'domainType': domainType,
    'domainId': domainId,
    'entityType': entityType ?? WebsocketKeys.wildcardEntityType,
  });

  return {'statusCode': 200};
}
