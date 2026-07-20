import 'dart:convert';

import 'package:sltt_core/sltt_core.dart' show SlttLogger;

import 'websocket_connections_repository.dart';
import 'websocket_keys.dart';
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
  final body =
      jsonDecode(event['body'] as String? ?? '{}') as Map<String, dynamic>;

  SlttLogger.logger.info(
    'wsSubscribe: entry connectionId=$connectionId body=$body',
  );

  final domainType = body['domainType'] as String?;
  final domainId = body['domainId'] as String?;
  final entityType = body['entityType'] as String?;

  if (domainType == null ||
      domainType.isEmpty ||
      domainId == null ||
      domainId.isEmpty) {
    SlttLogger.logger.warning(
      'wsSubscribe: invalid request connectionId=$connectionId domainType=$domainType domainId=$domainId',
    );
    await management.send(connectionId, {
      'action': 'subscribe',
      'status': 'error',
      'error': 'domainType and domainId are required',
    });
    return {'statusCode': 400};
  }

  try {
    final resolvedEntityType = WebsocketKeys.resolveEntityType(entityType);
    final subscriptionKey = WebsocketKeys.subscriptionSk(
      domainType: domainType,
      domainId: domainId,
      entityType: resolvedEntityType,
    );

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
      if (entityType != null) 'entityType': entityType,
      'subscriptionKey': subscriptionKey,
    });

    SlttLogger.logger.info(
      'wsSubscribe: saved subscription connectionId=$connectionId domainType=$domainType domainId=$domainId entityType=${entityType ?? '*'}',
    );

    return {'statusCode': 200};
  } catch (e, stackTrace) {
    SlttLogger.logger.severe(
      'wsSubscribe: failed connectionId=$connectionId body=$body',
      e,
      stackTrace,
    );
    rethrow;
  }
}
