import 'package:sltt_core/sltt_core.dart' show WebsocketConstants;

class WsNotifyRecord {
  const WsNotifyRecord({
    required this.domainType,
    required this.domainId,
    required this.notifyType,
    required this.entityType,
    required this.change,
    required this.index,
  });

  final String domainType;
  final String domainId;
  final String notifyType;
  final String entityType;
  final Map<String, dynamic> change;
  final int index;
}

const kNotifyTypeDomainChange = WebsocketConstants.notifyTypeDomainChange;
const kNotifyTypeDomainStats = WebsocketConstants.notifyTypeDomainStats;

Map<String, dynamic> buildDomainChangeNotificationPayload({
  required String domainType,
  required String domainId,
  required Map<String, dynamic> change,
  required String entityType,
  required String subscriptionKey,
}) {
  return {
    ...buildWsNotifyRecordMessage(
      domainType: domainType,
      domainId: domainId,
      change: change,
      entityType: entityType,
    ),
    'subscriptionKey': subscriptionKey,
  };
}

Map<String, dynamic> buildDomainStatsNotificationPayload({
  required String domainType,
  required String domainId,
  required Map<String, dynamic> stats,
  required String subscriptionKey,
}) {
  return {
    ...buildWsNotifyStatsMessage(
      domainType: domainType,
      domainId: domainId,
      stats: stats,
    ),
    'subscriptionKey': subscriptionKey,
  };
}

Map<String, dynamic> buildWsNotifyRecordMessage({
  required String domainType,
  required String domainId,
  required Map<String, dynamic> change,
  required String entityType,
}) {
  return {
    'action': WebsocketConstants.actionChange,
    'notifyType': kNotifyTypeDomainChange,
    'domainType': domainType,
    'domainId': domainId,
    'entityType': entityType,
    'change': change,
  };
}

Map<String, dynamic> buildWsNotifyStatsMessage({
  required String domainType,
  required String domainId,
  required Map<String, dynamic> stats,
}) {
  return {
    'action': WebsocketConstants.actionChange,
    'notifyType': kNotifyTypeDomainStats,
    'domainType': domainType,
    'domainId': domainId,
    'entityType': kNotifyTypeDomainStats,
    'stats': stats,
  };
}
