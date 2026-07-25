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
