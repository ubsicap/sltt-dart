import 'dart:convert';

import 'package:aws_backend/src/websocket/domain_change_payload.dart'
    show WsNotifyRecord, buildDomainChangeNotificationPayload;
import 'package:sltt_core/sltt_core.dart' show SlttLogger, WebsocketConstants;

import 'websocket_connections_repository.dart';
import 'websocket_keys.dart';
import 'websocket_management_client.dart';

/// SNS subscriber for DomainChangeTopic. Each SNS record's Message is the
/// JSON change event AwsRestApiServer publishes on a mutation, shaped like
/// {"notifyType":"domainChange", "domainType":..., "domainId":...,
///  "entityType":..., "change": {...}}.
///
/// One message here can match many connections with different
/// subscriptions (some subscribed to a specific entityType, some to "*"),
/// so this handler does its own per-connection entityType filtering rather
/// than relying solely on SNS message attributes / subscription filters.
List<List<WsNotifyRecord>> groupAndSortDomainChangeRecords(
  List<WsNotifyRecord> records,
) {
  final groupedRecords = <String, List<WsNotifyRecord>>{};
  final groupLatestIndex = <String, int>{};

  for (final record in records) {
    final key = '${record.domainType}|${record.domainId}';
    groupedRecords.putIfAbsent(key, () => []).add(record);
    groupLatestIndex[key] =
        groupLatestIndex[key] == null || record.index > groupLatestIndex[key]!
        ? record.index
        : groupLatestIndex[key]!;
  }

  final sortedGroupKeys = groupedRecords.keys.toList()
    ..sort((a, b) => groupLatestIndex[a]!.compareTo(groupLatestIndex[b]!));

  return sortedGroupKeys
      .map((groupKey) {
        final group = groupedRecords[groupKey]!;
        group.sort((a, b) => a.index.compareTo(b.index));
        return group;
      })
      .toList(growable: false);
}

Future<Map<String, dynamic>> wsNotifyHandler(
  Map<String, dynamic> event, {
  required WebsocketConnectionsRepository connections,
  required WebsocketManagementClient management,
}) async {
  final records = (event['Records'] as List?) ?? const [];
  final parsedRecords = <WsNotifyRecord>[];

  for (var index = 0; index < records.length; index++) {
    final record = records[index] as Map;
    final sns = record['Sns'] as Map;
    final message =
        jsonDecode(sns['Message'] as String) as Map<String, dynamic>;

    final notifyType = message['notifyType'] as String;
    final domainType = message['domainType'] as String;
    final domainId = message['domainId'] as String;
    final entityType = message['entityType'] as String;

    if (notifyType != WebsocketConstants.notifyTypeDomainChange) {
      SlttLogger.logger.warning(
        'wsNotify: unsupported notifyType "$notifyType"; only "${WebsocketConstants.notifyTypeDomainChange}" is supported: $message',
      );
      continue;
    }

    final rawChange = message['change'];
    if (rawChange is! Map) {
      SlttLogger.logger.warning(
        'wsNotify: domainChange message missing change payload: $message',
      );
      continue;
    }

    final change = Map<String, dynamic>.from(rawChange);

    parsedRecords.add(
      WsNotifyRecord(
        domainType: domainType,
        domainId: domainId,
        notifyType: notifyType,
        entityType: entityType,
        change: change,
        index: index,
      ),
    );
  }

  if (parsedRecords.isEmpty) {
    return {'statusCode': 200};
  }

  final sortedGroups = groupAndSortDomainChangeRecords(parsedRecords);

  for (final group in sortedGroups) {
    final domainType = group.first.domainType;
    final domainId = group.first.domainId;

    final subscriberMatches = await connections.findSubscribersByDomain(
      domainType: domainType,
      domainId: domainId,
    );

    final wildcardConnections = <String>{};
    final exactConnections = <String, Set<String>>{};
    final lastRecordConnections = <String>{};

    for (final subscription in subscriberMatches) {
      if (subscription.entityType == WebsocketKeys.wildcardEntityType) {
        wildcardConnections.add(subscription.connectionId);
      } else if (subscription.entityType ==
          WebsocketKeys.lastRecordEntityType) {
        lastRecordConnections.add(subscription.connectionId);
      } else {
        exactConnections
            .putIfAbsent(subscription.entityType, () => <String>{})
            .add(subscription.connectionId);
      }
    }

    final latestGroupRecord = group.reduce((value, record) {
      return record.index > value.index ? record : value;
    });

    for (final record in group) {
      final alreadyNotified = <String>{};

      if (record.entityType != WebsocketKeys.lastRecordEntityType) {
        final wildcardSubscriptionKey = WebsocketKeys.subscriptionSk(
          domainType: domainType,
          domainId: domainId,
          entityType: WebsocketKeys.wildcardEntityType,
        );

        for (final connectionId in wildcardConnections) {
          await _sendDomainChangeNotification(
            management: management,
            connectionId: connectionId,
            domainType: domainType,
            domainId: domainId,
            entityType: record.entityType,
            subscriptionKey: wildcardSubscriptionKey,
            change: record.change,
          );
          alreadyNotified.add(connectionId);
        }

        final exactMatchConnections =
            exactConnections[record.entityType] ?? const <String>{};
        final exactSubscriptionKey = WebsocketKeys.subscriptionSk(
          domainType: domainType,
          domainId: domainId,
          entityType: record.entityType,
        );
        for (final connectionId in exactMatchConnections) {
          if (!alreadyNotified.add(connectionId)) {
            continue;
          }

          await _sendDomainChangeNotification(
            management: management,
            connectionId: connectionId,
            domainType: domainType,
            domainId: domainId,
            entityType: record.entityType,
            subscriptionKey: exactSubscriptionKey,
            change: record.change,
          );
        }
      }

      if (record.index == latestGroupRecord.index) {
        final lastRecordSubscriptionKey = WebsocketKeys.subscriptionSk(
          domainType: domainType,
          domainId: domainId,
          entityType: WebsocketKeys.lastRecordEntityType,
        );

        for (final connectionId in lastRecordConnections) {
          if (!alreadyNotified.add(connectionId)) {
            continue;
          }

          await _sendDomainChangeNotification(
            management: management,
            connectionId: connectionId,
            domainType: domainType,
            domainId: domainId,
            entityType: record.entityType,
            subscriptionKey: lastRecordSubscriptionKey,
            change: record.change,
          );
        }
      }
    }
  }

  return {'statusCode': 200};
}

Future<void> _sendDomainChangeNotification({
  required WebsocketManagementClient management,
  required String connectionId,
  required String domainType,
  required String domainId,
  required Map<String, dynamic> change,
  required String entityType,
  required String subscriptionKey,
}) async {
  await management.send(
    connectionId,
    buildDomainChangeNotificationPayload(
      domainType: domainType,
      domainId: domainId,
      change: change,
      entityType: entityType,
      subscriptionKey: subscriptionKey,
    ),
  );
}
