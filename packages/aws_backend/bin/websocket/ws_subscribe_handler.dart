import 'dart:convert';

import 'package:sltt_core/sltt_core.dart'
    show
        DomainStatsResponse,
        EntityTypeStats,
        EntityTypeSummary,
        SlttLogger,
        WebsocketConstants;

import 'root_entity_subscription_utils.dart';
import 'websocket_connections_repository.dart';
import 'websocket_keys.dart';
import 'websocket_management_client.dart';

/// Handles {"action":"subscribe","domainType":...,"domainId":...,"entityType":...,"notifyType":...}
/// Root-entity subscriptions such as "addedMe" and "newDomainId" do not require
/// a domainId; domain-scoped "domainChange" and "domainStats" subscriptions still do.
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
  Future<List<Map<String, dynamic>>> Function({
    required String domainType,
    String? entityIdPrefix,
    String? userId,
    Set<String>? projectionFields,
  })?
  getRootEntityStates,
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
  final userId = body['userId'] as String?;
  final ackFields = body['ackFields'];
  final projectionFields = () {
    if (ackFields == null) {
      return null;
    }
    if (ackFields is String) {
      return ackFields
          .split(',')
          .map((field) => field.trim())
          .where((field) => field.isNotEmpty)
          .toSet();
    }
    if (ackFields is Iterable) {
      return ackFields
          .map((field) => field.toString().trim())
          .where((field) => field.isNotEmpty)
          .toSet();
    }
    return null;
  }();
  final effectiveDomainId = domainId ?? '';

  bool isValidEntityType(String entityType) {
    return entityType == WebsocketKeys.wildcardEntityType ||
        entityType == WebsocketKeys.lastRecordEntityType ||
        RegExp(r'^[a-z_]+$').hasMatch(entityType);
  }

  final isStatsSubscription =
      notifyType == WebsocketConstants.notifyTypeDomainStats;
  final isChangeSubscription =
      notifyType == WebsocketConstants.notifyTypeDomainChange;
  final isAddedMeSubscription =
      notifyType == WebsocketConstants.notifyTypeAddedMe;
  final isNewDomainIdSubscription =
      notifyType == WebsocketConstants.newDomainId;
  final isRootEntitySubscription =
      isAddedMeSubscription || isNewDomainIdSubscription;
  final isDomainScopedSubscription =
      isChangeSubscription || isStatsSubscription;

  final isValidRootEntityRequest =
      domainType != null &&
      entityType != null &&
      ((isAddedMeSubscription &&
              isValidRootEntitySubscriptionRequest(
                domainType: domainType,
                entityType: entityType,
                notifyType: WebsocketConstants.notifyTypeAddedMe,
                userId: userId,
              )) ||
          (isNewDomainIdSubscription &&
              isValidRootEntitySubscriptionRequest(
                domainType: domainType,
                entityType: entityType,
                notifyType: WebsocketConstants.newDomainId,
              )));

  if (domainType == null ||
      domainType.isEmpty ||
      notifyType == null ||
      notifyType.isEmpty ||
      !(isChangeSubscription ||
          isStatsSubscription ||
          isAddedMeSubscription ||
          isNewDomainIdSubscription) ||
      entityType == null ||
      entityType.isEmpty ||
      (isChangeSubscription && !isValidEntityType(entityType)) ||
      (isStatsSubscription && entityType != WebsocketKeys.wildcardEntityType) ||
      (isDomainScopedSubscription && (domainId == null || domainId.isEmpty)) ||
      (isRootEntitySubscription && !isValidRootEntityRequest) ||
      (!isRootEntitySubscription &&
          !isValidRootEntityRequest &&
          !isDomainScopedSubscription)) {
    SlttLogger.logger.warning(
      'wsSubscribe: invalid request connectionId=$connectionId domainType=$domainType domainId=$domainId notifyType=$notifyType entityType=$entityType',
    );
    await management.send(connectionId, {
      'action': WebsocketConstants.actionSubscribe,
      'status': 'error',
      'error':
          r'domainType, domainId, notifyType, and entityType are required. notifyType must be "domainChange", "domainStats", "addedMe", or "newDomainId". entityType must be "*", "$", or match /^[a-z_]+$/ for domainChange, and "*" for domainStats, or use the root-entity contract for addedMe/newDomainId.',
    });
    return {'statusCode': 400};
  }

  try {
    final resolvedEntityType = isStatsSubscription
        ? WebsocketKeys.wildcardEntityType
        : WebsocketKeys.resolveEntityType(entityType);
    final subscriptionKey = isAddedMeSubscription
        ? WebsocketKeys.addedMeSubscriptionSk(userId: userId ?? '')
        : isNewDomainIdSubscription
        ? WebsocketKeys.newDomainIdSubscriptionSk(
            domainType: domainType,
            entityType: resolvedEntityType,
          )
        : WebsocketKeys.subscriptionSk(
            domainType: domainType,
            domainId: effectiveDomainId,
            entityType: resolvedEntityType,
            notifyType: notifyType,
          );

    await connections.putSubscription(
      connectionId: connectionId,
      domainType: domainType,
      domainId: effectiveDomainId,
      entityType: entityType,
      notifyType: notifyType,
      userId: userId,
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
        domainId: effectiveDomainId,
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
        isIncremental: false,
      ).toJson();
    }

    if (getDomainChangeStatus != null && isDomainScopedSubscription) {
      try {
        final fetchedStatusData = await getDomainChangeStatus(
          domainType: domainType,
          domainId: effectiveDomainId,
          entityType: entityType,
        );
        if (fetchedStatusData != null) {
          statusData = {
            ...fetchedStatusData,
            'isIncremental': fetchedStatusData['isIncremental'] ?? false,
          };
        }
      } catch (error, stackTrace) {
        SlttLogger.logger.warning(
          'wsSubscribe: failed to fetch initial domain status '
          'for $domainType/$effectiveDomainId',
          error,
          stackTrace,
        );
      }
    }

    final payload = <String, dynamic>{
      'action': WebsocketConstants.actionSubscribe,
      'status': 'ok',
      'notifyType': notifyType,
      'domainType': domainType,
      'domainId': effectiveDomainId,
      'entityType': entityType,
      'subscriptionKey': subscriptionKey,
    };
    if (isAddedMeSubscription || isNewDomainIdSubscription) {
      payload['states'] = <Map<String, dynamic>>[];
      if (getRootEntityStates != null) {
        try {
          final states = await getRootEntityStates(
            domainType: domainType,
            entityIdPrefix: isAddedMeSubscription ? userId ?? '' : null,
            userId: userId,
            projectionFields: projectionFields,
          );
          payload['states'] = states;
        } catch (error, stackTrace) {
          SlttLogger.logger.warning(
            'wsSubscribe: failed to fetch root entity states for $domainType/$notifyType',
            error,
            stackTrace,
          );
        }
      }
    }
    if (isChangeSubscription || isStatsSubscription) {
      payload['stats'] = statusData;
    }

    await management.send(connectionId, payload);

    SlttLogger.logger.info(
      'wsSubscribe: saved subscription connectionId=$connectionId domainType=$domainType domainId=$effectiveDomainId entityType=$entityType',
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
