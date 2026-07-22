class DomainChangeData {
  DomainChangeData({
    required this.name,
    required this.lastDomainSeq,
    required this.lastDomainChangeAt,
  });

  final String name;
  final int lastDomainSeq;
  final DateTime lastDomainChangeAt;

  factory DomainChangeData.fromJson(Map<String, dynamic> json) {
    final lastDomainChangeAtValue = json['lastDomainChangeAt'];
    if (json['name'] == null ||
        json['lastDomainSeq'] == null ||
        lastDomainChangeAtValue == null) {
      throw const FormatException('Missing required domainChange data fields');
    }

    return DomainChangeData(
      name: json['name'] as String,
      lastDomainSeq: json['lastDomainSeq'] is int
          ? json['lastDomainSeq'] as int
          : int.parse(json['lastDomainSeq'].toString()),
      lastDomainChangeAt: lastDomainChangeAtValue is DateTime
          ? lastDomainChangeAtValue.toUtc()
          : DateTime.parse(lastDomainChangeAtValue as String).toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'lastDomainSeq': lastDomainSeq,
    'lastDomainChangeAt': lastDomainChangeAt.toUtc().toIso8601String(),
  };
}

class WsNotifyRecord {
  const WsNotifyRecord({
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
  final String entityType;
  final dynamic data;
  final int index;
}

const kNotifyTypeDomainChange = 'domainChange';

Map<String, dynamic> buildDomainChangeNotificationPayload({
  required String domainType,
  required String domainId,
  required DomainChangeData data,
  required String entityType,
  required String subscriptionKey,
}) {
  return {
    ...buildWsNotifyRecordMessage(
      domainType: domainType,
      domainId: domainId,
      data: data,
      entityType: entityType,
    ),
    'subscriptionKey': subscriptionKey,
  };
}

Map<String, dynamic> buildWsNotifyRecordMessage({
  required String domainType,
  required String domainId,
  required DomainChangeData data,
  required String entityType,
}) {
  return {
    'action': 'change',
    'notifyType': kNotifyTypeDomainChange,
    'domainType': domainType,
    'domainId': domainId,
    'entityType': entityType,
    'data': data.toJson(),
  };
}
