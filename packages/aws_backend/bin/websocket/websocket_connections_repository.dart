// Uses the AWS backend's existing DynamoDB HTTP request signing helpers
// rather than introducing a new `aws_dynamodb_api` dependency.
import 'dart:convert';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;

import 'websocket_keys.dart';

class WebsocketConnectionsRepository {
  WebsocketConnectionsRepository({
    required String tableName,
    required String gsiName,
    required String region,
    required AWSCredentials credentials,
    this.useLocalDynamoDB = false,
    this.localEndpoint,
    http.Client? httpClient,
  }) : _tableName = tableName,
       _gsiName = gsiName,
       _region = region,
       _credentials = credentials,
       _httpClient = httpClient ?? http.Client();

  final String _tableName;
  final String _gsiName;
  final String _region;
  final AWSCredentials _credentials;
  final bool useLocalDynamoDB;
  final String? localEndpoint;
  final http.Client _httpClient;

  Uri get _endpointUri {
    if (useLocalDynamoDB) {
      return Uri.parse(localEndpoint ?? 'http://localhost:8000');
    }
    return Uri.parse('https://dynamodb.$_region.amazonaws.com');
  }

  // Connections/subscriptions are re-established on every reconnect, so a
  // generous TTL just guards against rows orphaned by a missed $disconnect
  // (e.g. Lambda crash) rather than being load-bearing for correctness.
  static const _rowTtl = Duration(hours: 12);

  static String _expiresAtValue() =>
      '${DateTime.now().toUtc().add(_rowTtl).millisecondsSinceEpoch ~/ 1000}';

  Future<void> putConnection({
    required String connectionId,
    required String userId,
  }) async {
    await _dynamoRequest('PutItem', {
      'TableName': _tableName,
      'Item': {
        'connectionId': _attributeValueS(connectionId),
        'sk': _attributeValueS(WebsocketKeys.connectionSk),
        'userId': _attributeValueS(userId),
        'connectedAt': _attributeValueS(
          DateTime.now().toUtc().toIso8601String(),
        ),
        'expiresAt': _attributeValueN(_expiresAtValue()),
      },
    });
  }

  Future<void> putSubscription({
    required String connectionId,
    required String domainType,
    required String domainId,
    String? entityType,
  }) async {
    final resolvedEntityType = WebsocketKeys.resolveEntityType(entityType);
    await _dynamoRequest('PutItem', {
      'TableName': _tableName,
      'Item': {
        'connectionId': _attributeValueS(connectionId),
        'sk': _attributeValueS(
          WebsocketKeys.subscriptionSk(
            domainType: domainType,
            domainId: domainId,
            entityType: resolvedEntityType,
          ),
        ),
        'gsi1pk': _attributeValueS(
          WebsocketKeys.domainGsiPk(domainType: domainType, domainId: domainId),
        ),
        'domainType': _attributeValueS(domainType),
        'domainId': _attributeValueS(domainId),
        'entityType': _attributeValueS(resolvedEntityType),
        'expiresAt': _attributeValueN(_expiresAtValue()),
      },
    });
  }

  Future<void> deleteSubscription({
    required String connectionId,
    required String domainType,
    required String domainId,
    String? entityType,
  }) async {
    final resolvedEntityType = WebsocketKeys.resolveEntityType(entityType);
    await _dynamoRequest('DeleteItem', {
      'TableName': _tableName,
      'Key': {
        'connectionId': _attributeValueS(connectionId),
        'sk': _attributeValueS(
          WebsocketKeys.subscriptionSk(
            domainType: domainType,
            domainId: domainId,
            entityType: resolvedEntityType,
          ),
        ),
      },
    });
  }

  /// Deletes the connection's own row plus every subscription row under it.
  Future<void> deleteConnectionAndSubscriptions(String connectionId) async {
    final result = await _dynamoRequest('Query', {
      'TableName': _tableName,
      'KeyConditionExpression': 'connectionId = :cid',
      'ExpressionAttributeValues': {':cid': _attributeValueS(connectionId)},
    });

    final items =
        (result['Items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        const [];
    if (items.isEmpty) return;

    await _dynamoRequest('BatchWriteItem', {
      'RequestItems': {
        _tableName: [
          for (final item in items)
            {
              'DeleteRequest': {
                'Key': {
                  'connectionId': item['connectionId']!,
                  'sk': item['sk']!,
                },
              },
            },
        ],
      },
    });
  }

  /// Returns every connectionId subscribed to domainType+domainId, whether
  /// via an exact entityType match or a "*" (all entity types) subscription.
  Future<List<String>> findSubscribers({
    required String domainType,
    required String domainId,
    String? entityType,
  }) async {
    final result = await _dynamoRequest('Query', {
      'TableName': _tableName,
      'IndexName': _gsiName,
      'KeyConditionExpression': 'gsi1pk = :pk',
      'ExpressionAttributeValues': {
        ':pk': _attributeValueS(
          WebsocketKeys.domainGsiPk(domainType: domainType, domainId: domainId),
        ),
      },
    });

    final matches = <String>{};
    final items =
        (result['Items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        const [];
    for (final item in items) {
      final sk = (item['sk'] as Map<String, dynamic>?)?['S'] as String?;
      final connectionId =
          (item['connectionId'] as Map<String, dynamic>?)?['S'] as String?;
      if (sk == null || connectionId == null) continue;

      final subscribedEntityType = WebsocketKeys.entityTypeFromSubscriptionSk(
        sk,
      );
      final isMatch =
          subscribedEntityType == WebsocketKeys.wildcardEntityType ||
          entityType == null ||
          subscribedEntityType == entityType;
      if (isMatch) matches.add(connectionId);
    }
    return matches.toList();
  }

  Future<void> close() async {
    _httpClient.close();
  }

  Future<Map<String, dynamic>> _dynamoRequest(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    final body = jsonEncode(payload);
    final uri = _endpointUri;

    if (useLocalDynamoDB) {
      final headers = <String, String>{
        'Content-Type': 'application/x-amz-json-1.0',
        'X-Amz-Target': 'DynamoDB_20120810.$operation',
      };
      final response = await _httpClient.post(
        uri,
        headers: headers,
        body: body,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final encodedBody = utf8.encode(body);
    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(_credentials),
    );
    final signedRequest = await signer.sign(
      AWSHttpRequest(
        method: AWSHttpMethod.post,
        uri: uri,
        headers: {
          'Content-Type': 'application/x-amz-json-1.0',
          'X-Amz-Target': 'DynamoDB_20120810.$operation',
          'host': uri.host,
        },
        body: encodedBody,
      ),
      credentialScope: AWSCredentialScope(
        region: _region,
        service: AWSService.dynamoDb,
      ),
    );

    final request = http.Request('POST', signedRequest.uri)
      ..headers.addAll(signedRequest.headers)
      ..bodyBytes = encodedBody;

    final streamed = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamed);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Map<String, dynamic> _attributeValueS(String value) => {'S': value};

  static Map<String, dynamic> _attributeValueN(String value) => {'N': value};
}
