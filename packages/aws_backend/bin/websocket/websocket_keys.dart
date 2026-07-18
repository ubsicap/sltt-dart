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
class WebsocketKeys {
  WebsocketKeys._();

  static const String connectionSk = 'con';
  static const String wildcardEntityType = '*';
  static const String lastRecordEntityType = r'$';

  static String subscriptionSk({
    required String domainType,
    required String domainId,
    required String entityType,
  }) =>
      'sub#@DOMAINTYPE#$domainType#@DOMAINID#$domainId#@ENTITYTYPE#$entityType';

  static String domainGsiPk({
    required String domainType,
    required String domainId,
  }) => 'sub#@DOMAINTYPE#$domainType#@DOMAINID#$domainId';

  /// Extracts the entityType label from a subscription SK, e.g.
  /// "sub#@DOMAINTYPE#project#@DOMAINID#proj_1#@ENTITYTYPE#task" -> "task"
  static String entityTypeFromSubscriptionSk(String sk) {
    const marker = '#@ENTITYTYPE#';
    final index = sk.indexOf(marker);
    if (index == -1) {
      throw ArgumentError('Not a subscription sk: $sk');
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
