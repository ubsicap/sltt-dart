import 'dart:convert';

import 'package:sltt_core/sltt_core.dart'
    show
        DomainStatsResponse,
        EntityTypeStats,
        EntityTypeSummary,
        SlttLogger,
        WebsocketConstants;

import 'websocket_connections_repository.dart';
import 'websocket_keys.dart';
import 'websocket_management_client.dart';

/// Handles {"action":"subscribe","domainType":...,"domainId":...,"entityType":...,"notifyType":...}
/// notifyType is required and must be either "domainChange" or "domainStats".
/// entityType is required for domainChange subscriptions and must be:
///   - "*" (wildcard for all entity types)
///   - "$" (latest-record sentinel)
///   - any value matching /^[a-z_]+$/
/// For domainStats subscriptions, entityType must be "*".
Future<Map<String, dynamic>> wsSubscribeHandler(
  Map<String, dynamic> event, {
  required WebsocketConnectionsRepository connections,
  required WebsocketManagementClient management,
  Future<Map<String, dynamic>?> Function({
    required String domainType,
    required String domainId,
    required String entityType,
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
    SlttLogger.logger.warning(
      'wsSubscribe: invalid request connectionId=$connectionId domainType=$domainType domainId=$domainId notifyType=$notifyType entityType=$entityType',
    );
    await management.send(connectionId, {
      'action': WebsocketConstants.actionSubscribe,
      'status': 'error',
      'error':
          r'domainType, domainId, notifyType, and entityType are required. notifyType must be "domainChange" or "domainStats". entityType must be "*", "$", or match /^[a-z_]+$/ for domainChange, and "*" for domainStats.',
    });
    return {'statusCode': 400};
  }

  try {
    final resolvedEntityType = isStatsSubscription
        ? WebsocketKeys.wildcardEntityType
        : WebsocketKeys.resolveEntityType(entityType);
    final subscriptionKey = WebsocketKeys.subscriptionSk(
      domainType: domainType,
      domainId: domainId,
      entityType: resolvedEntityType,
      notifyType: notifyType,
    );

    await connections.putSubscription(
      connectionId: connectionId,
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      notifyType: notifyType,
    );

    final defaultLatestChangeAt = DateTime.fromMillisecondsSinceEpoch(
      0,
    ).toUtc().toIso8601String();
    Map<String, dynamic> statusData = {
      'lastDomainSeq': 0,
      'lastDomainChangeAt': defaultLatestChangeAt,
    };
    if (notifyType == WebsocketConstants.notifyTypeDomainStats) {
      statusData = DomainStatsResponse(
        domainId: domainId,
        domainType: domainType,
        changeStats: EntityTypeSummary(
          creates: 0,
          updates: 0,
          deletes: 0,
          total: 0,
          latestChangeAt: defaultLatestChangeAt,
          latestSeq: -1,
        ),
        entityTypeStats: EntityTypeStats(
          entityTypes: {},
          totals: EntityTypeSummary(
            creates: 0,
            updates: 0,
            deletes: 0,
            total: 0,
            latestChangeAt: defaultLatestChangeAt,
            latestSeq: -1,
          ),
        ),
        entityTypeCollections: {},
        timestamp: defaultLatestChangeAt,
        storageType: 'unknown',
      ).toJson();
    }

    if (getDomainChangeStatus != null) {
      try {
        final fetchedStatusData = await getDomainChangeStatus(
          domainType: domainType,
          domainId: domainId,
          entityType: entityType,
        );
        if (fetchedStatusData != null) {
          statusData = fetchedStatusData;
        }
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
      'notifyType': notifyType,
      'domainType': domainType,
      'domainId': domainId,
      'entityType': entityType,
      'subscriptionKey': subscriptionKey,
      'stats': statusData,
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
