import 'dart:convert';

import 'package:sltt_core/sltt_core.dart' show SlttLogger;

import 'websocket_connections_repository.dart';
import 'websocket_keys.dart';
import 'websocket_management_client.dart';

const _kNotifyTypeDomainChange = 'domainChange';

class _WsNotifyRecord {
  const _WsNotifyRecord({
    required this.domainType,
    required this.domainId,
    required this.notifyType,
    required this.entityType,
    required this.data,
    required this.index,
  });

  final String domainType;
  final String domainId;
  final String notifyType;
  final String? entityType;
  final dynamic data;
  final int index;
}

/// SNS subscriber for DomainChangeTopic. Each SNS record's Message is the
/// JSON change event AwsRestApiServer publishes on a mutation, shaped like
/// {"notifyType":"domainChange", "domainType":..., "domainId":...,
///  "entityType":..., "data": {...}}.
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
  final parsedRecords = <_WsNotifyRecord>[];

  for (var index = 0; index < records.length; index++) {
    final record = records[index] as Map;
    final sns = record['Sns'] as Map;
    final message =
        jsonDecode(sns['Message'] as String) as Map<String, dynamic>;

    final notifyType = message['notifyType'] as String?;
    final domainType = message['domainType'] as String?;
    final domainId = message['domainId'] as String?;
    final entityType = message['entityType'] as String?; // may be absent

    if (domainType == null || domainId == null) {
      SlttLogger.logger.warning(
        'wsNotify: change event missing domainType/domainId: $message',
      );
      continue;
    }

    if (notifyType != _kNotifyTypeDomainChange) {
      SlttLogger.logger.warning(
        'wsNotify: unsupported notifyType "$notifyType"; only "$_kNotifyTypeDomainChange" is supported: $message',
      );
      continue;
    }

    parsedRecords.add(
      _WsNotifyRecord(
        domainType: domainType,
        domainId: domainId,
        notifyType: notifyType!,
        entityType: entityType,
        data: message['data'],
        index: index,
      ),
    );
  }

  if (parsedRecords.isEmpty) {
    return {'statusCode': 200};
  }

  final groupedRecords = <String, List<_WsNotifyRecord>>{};
  final groupEarliestIndex = <String, int>{};

  for (final record in parsedRecords) {
    final key = '${record.domainType}|${record.domainId}';
    groupedRecords.putIfAbsent(key, () => []).add(record);
    groupEarliestIndex[key] =
        groupEarliestIndex[key] == null ||
            record.index < groupEarliestIndex[key]!
        ? record.index
        : groupEarliestIndex[key]!;
  }

  final sortedGroupKeys = groupedRecords.keys.toList()
    ..sort((a, b) {
      return groupEarliestIndex[a]!.compareTo(groupEarliestIndex[b]!);
    });

  for (final groupKey in sortedGroupKeys) {
    final group = groupedRecords[groupKey]!;
    group.sort((a, b) {
      final aEntity = a.entityType ?? '';
      final bEntity = b.entityType ?? '';
      final entityComparison = aEntity.compareTo(bEntity);
      return entityComparison != 0
          ? entityComparison
          : a.index.compareTo(b.index);
    });

    final domainType = group.first.domainType;
    final domainId = group.first.domainId;

    final subscriberMatches = await connections.findSubscribersByDomain(
      domainType: domainType,
      domainId: domainId,
    );

    final wildcardConnections = <String>{};
    final exactConnections = <String, Set<String>>{};

    for (final subscription in subscriberMatches) {
      if (subscription.entityType == WebsocketKeys.wildcardEntityType) {
        wildcardConnections.add(subscription.connectionId);
      } else {
        exactConnections
            .putIfAbsent(subscription.entityType, () => <String>{})
            .add(subscription.connectionId);
      }
    }

    for (final record in group) {
      final alreadyNotified = <String>{};

      for (final connectionId in wildcardConnections) {
        await management.send(connectionId, {
          'action': 'change',
          'domainType': domainType,
          'domainId': domainId,
          if (record.entityType != null) 'entityType': record.entityType,
          'data': record.data,
        });
        alreadyNotified.add(connectionId);
      }

      if (record.entityType == null) {
        for (final connectionIds in exactConnections.values) {
          for (final connectionId in connectionIds) {
            if (!alreadyNotified.add(connectionId)) {
              continue;
            }

            await management.send(connectionId, {
              'action': 'change',
              'domainType': domainType,
              'domainId': domainId,
              'data': record.data,
            });
          }
        }
      } else {
        final exactMatchConnections =
            exactConnections[record.entityType!] ?? const <String>{};
        for (final connectionId in exactMatchConnections) {
          if (!alreadyNotified.add(connectionId)) {
            continue;
          }

          await management.send(connectionId, {
            'action': 'change',
            'domainType': domainType,
            'domainId': domainId,
            'entityType': record.entityType,
            'data': record.data,
          });
        }
      }
    }
  }

  return {'statusCode': 200};
}
