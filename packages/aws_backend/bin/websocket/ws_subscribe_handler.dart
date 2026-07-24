import 'dart:convert';

import 'package:sltt_core/sltt_core.dart' show SlttLogger, WebsocketConstants;

import 'websocket_connections_repository.dart';
import 'websocket_keys.dart';
import 'websocket_management_client.dart';

/// Handles {"action":"subscribe","domainType":...,"domainId":...,"entityType":...}
/// entityType is required. Valid values are:
///   - "*" (wildcard for all entity types)
///   - "$" (latest-record sentinel)
///   - any value matching /^[a-z_]+$/
Future<Map<String, dynamic>> wsSubscribeHandler(
  Map<String, dynamic> event, {
  required WebsocketConnectionsRepository connections,
  required WebsocketManagementClient management,
  Future<Map<String, dynamic>?> Function({
    required String domainType,
    required String domainId,
  })?
  getDomainChangeStatus,
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

  bool isValidEntityType(String entityType) {
    return entityType == WebsocketKeys.wildcardEntityType ||
        entityType == WebsocketKeys.lastRecordEntityType ||
        RegExp(r'^[a-z_]+$').hasMatch(entityType);
  }

  if (domainType == null ||
      domainType.isEmpty ||
      domainId == null ||
      domainId.isEmpty ||
      entityType == null ||
      entityType.isEmpty ||
      !isValidEntityType(entityType)) {
    SlttLogger.logger.warning(
      'wsSubscribe: invalid request connectionId=$connectionId domainType=$domainType domainId=$domainId',
    );
    await management.send(connectionId, {
      'action': WebsocketConstants.actionSubscribe,
      'status': 'error',
      'error':
          r'domainType, domainId, and entityType are required. entityType must be "*", "$", or match /^[a-z_]+$/',
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

    Map<String, dynamic>? statusData;
    if (getDomainChangeStatus != null) {
      try {
        statusData = await getDomainChangeStatus(
          domainType: domainType,
          domainId: domainId,
        );
      } catch (error, stackTrace) {
        SlttLogger.logger.warning(
          'wsSubscribe: failed to fetch initial domain status '
          'for $domainType/$domainId',
          error,
          stackTrace,
        );
      }
    }

    final payload = {
      'action': WebsocketConstants.actionSubscribe,
      'status': 'ok',
      'domainType': domainType,
      'domainId': domainId,
      'entityType': entityType,
      'subscriptionKey': subscriptionKey,
      if (statusData != null) 'data': statusData,
    };

    await management.send(connectionId, payload);

    SlttLogger.logger.info(
      'wsSubscribe: saved subscription connectionId=$connectionId domainType=$domainType domainId=$domainId entityType=$entityType',
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
