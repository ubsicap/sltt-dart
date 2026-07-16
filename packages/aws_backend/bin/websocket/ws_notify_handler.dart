import 'dart:convert';

import 'package:sltt_core/sltt_core.dart' show SlttLogger;

import 'websocket_connections_repository.dart';
import 'websocket_management_client.dart';

/// SNS subscriber for DomainChangeTopic. Each SNS record's Message is the
/// JSON change event AwsRestApiServer publishes on a mutation, shaped like
/// {"domainType":..., "domainId":..., "entityType":..., "data": {...}}.
///
/// One message here can match many connections with different
/// subscriptions (some subscribed to a specific entityType, some to "*"),
/// so this handler does its own per-connection entityType filtering rather
/// than relying solely on SNS message attributes / subscription filters.
Future<Map<String, dynamic>> wsNotifyHandler(
  Map<String, dynamic> event, {
  required WebsocketConnectionsRepository connections,
  required WebsocketManagementClient management,
}) async {
  final records = (event['Records'] as List?) ?? const [];

  for (final record in records) {
    final sns = (record as Map)['Sns'] as Map;
    final message = jsonDecode(sns['Message'] as String) as Map<String, dynamic>;

    final domainType = message['domainType'] as String?;
    final domainId = message['domainId'] as String?;
    final entityType = message['entityType'] as String?; // may be absent

    if (domainType == null || domainId == null) {
      SlttLogger.logger.warning(
        'wsNotify: change event missing domainType/domainId: $message',
      );
      continue;
    }

    final subscriberConnectionIds = await connections.findSubscribers(
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
    );

    for (final connectionId in subscriberConnectionIds) {
      await management.send(connectionId, {
        'action': 'change',
        'domainType': domainType,
        'domainId': domainId,
        if (entityType != null) 'entityType': entityType,
        'data': message['data'],
      });
    }
  }

  return {'statusCode': 200};
}
