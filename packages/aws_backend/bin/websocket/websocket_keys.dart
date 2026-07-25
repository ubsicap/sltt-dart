/// Builds and parses composite keys for the websocket connections table.
///
/// Convention: "#" separates fields, "@FIELD" labels the value that follows,
/// so a row's meaning is readable straight off its key in the DynamoDB
/// console without knowing the schema by heart.
///
///   PK connectionId, SK "con"
///     -> connection metadata (see WebsocketConnectionsRepository.putConnection)
///   PK connectionId, SK "sub#@DOMAINTYPE#<domainType>#@DOMAINID#<domainId>#@ENTITYTYPE#<entityType|*>"
///     -> one subscription ("*" means "all entity types on this domain")
///   PK connectionId, SK "sub#@DOMAINTYPE#<domainType>#@DOMAINID#<domainId>#@ENTITYTYPE#<latest-record-sentinel>"
///     -> one subscription for the latest record in the domain group
///   GSI1PK "sub#@DOMAINTYPE#<domainType>#@DOMAINID#<domainId>" (entityType omitted)
///     -> lets wsNotify fetch every connection subscribed to a domain in one
///        query, then split matches by exact entityType vs "*" vs latest-record
///        sentinel in code.
library;

import 'package:sltt_core/sltt_core.dart' show WebsocketConstants;

class WebsocketKeys {
  WebsocketKeys._();

  static const String connectionSk = 'con';
  static const String wildcardEntityType =
      WebsocketConstants.wildcardEntityType;
  static const String lastRecordEntityType =
      WebsocketConstants.lastRecordEntityType;

  static String subscriptionSk({
    required String domainType,
    required String domainId,
    required String entityType,
    required String notifyType,
  }) =>
      'sub#@DOMAINTYPE#$domainType#@DOMAINID#$domainId#@ENTITYTYPE#$entityType#@NOTIFYTYPE#$notifyType';

  static String domainGsiPk({
    required String domainType,
    required String domainId,
  }) => 'sub#@DOMAINTYPE#$domainType#@DOMAINID#$domainId';

  /// Extracts the entityType label from a subscription SK, e.g.
  /// "sub#@DOMAINTYPE#project#@DOMAINID#proj_1#@ENTITYTYPE#task#@NOTIFYTYPE#domainChange" -> "task"
  static String entityTypeFromSubscriptionSk(String sk) {
    const marker = '#@ENTITYTYPE#';
    final index = sk.indexOf(marker);
    if (index == -1) {
      throw ArgumentError('Not a subscription sk: $sk');
    }
    final entityType = sk.substring(index + marker.length);
    final notifyMarker = '#@NOTIFYTYPE#';
    final notifyIndex = entityType.indexOf(notifyMarker);
    if (notifyIndex != -1) {
      return entityType.substring(0, notifyIndex);
    }
    return entityType;
  }

  /// Extracts the notifyType label from a subscription SK.
  static String notifyTypeFromSubscriptionSk(String sk) {
    const marker = '#@NOTIFYTYPE#';
    final index = sk.indexOf(marker);
    if (index == -1) {
      throw ArgumentError('Subscription sk missing notifyType: $sk');
    }
    return sk.substring(index + marker.length);
  }

  /// Normalizes a client-supplied entityType (which may be null/empty when
  /// the client wants "all entity types") into the stored wildcard sentinel.
  static String resolveEntityType(String? entityType) =>
      (entityType == null || entityType.isEmpty)
      ? wildcardEntityType
      : entityType;
}
