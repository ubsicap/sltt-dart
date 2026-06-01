import 'dart:convert';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;

import 'auth_models.dart';

/// Auth table key access map.
///
/// Base table uses `pk`/`sk` for point lookups and per-user queries. GSI1 is
/// used for principal listing, and TTL cleanup relies on `ttlEpochSeconds`
/// stored on challenge/session items.
///
/// sample_values:
///   userId: user_123
///   normalizedEmail: person@example.com
///   normalizedUsername: local.user
///   sessionId: sess_abc
///   refreshTokenHash: sha256_refresh_token
///
/// principal:
///   write_read:
///     operation: PutItem/GetItem in putPrincipal and getPrincipalByUserId
///     key_fields: [pk, sk]
///     keys:
///       pk: USER#user_123
///       sk: PRINCIPAL
///
/// email_lookup:
///   write_read:
///     operation: PutItem/GetItem in putEmailLookup and getPrincipalByEmail
///     key_fields: [pk, sk]
///     keys:
///       pk: IDENTIFIER#EMAIL#person@example.com
///       sk: LOOKUP
///
/// username_lookup:
///   write_read:
///     operation: PutItem/GetItem in putUsernameLookup and getPrincipalByUsername
///     key_fields: [pk, sk]
///     keys:
///       pk: IDENTIFIER#USERNAME#local.user
///       sk: LOOKUP
///
/// email_challenge:
///   write_read_delete:
///     operation: PutItem/GetItem/DeleteItem in put/get/deleteEmailChallenge
///     key_fields: [pk, sk]
///     notes: TTL is driven by ttlEpochSeconds on the item payload.
///     keys:
///       pk: USER#user_123
///       sk: CHALLENGE#EMAIL
///
/// session:
///   write_read:
///     operation: PutItem/GetItem/Query in putSession, getSessionById, revokeAllSessionsForUser
///     key_fields: [pk, sk]
///     notes: Query uses pk = USER#user_123 and begins_with(sk, SESSION#).
///     keys:
///       pk: USER#user_123
///       sk: SESSION#sess_abc
///
/// session_token_lookup:
///   write_read:
///     operation: PutItem/GetItem in putSession and getSessionByTokenHash
///     key_fields: [pk, sk]
///     notes: TTL is mirrored from the backing session item.
///     keys:
///       pk: SESSIONTOKEN#sha256_refresh_token
///       sk: LOOKUP
///
/// adhoc_listing:
///   write_query:
///     operation: PutItem in putPrincipal, Query in listAdHocPrincipals
///     key_fields: [gsi1pk, gsi1sk]
///     keys:
///       gsi1pk: principal
///       gsi1sk: STATUS#active#KIND#username_password#ADHOC#1#USER#user_123

abstract class AuthRecordStore {
  Future<void> initialize();
  Future<void> close();
  Future<AuthPrincipal?> getPrincipalByUserId(String userId);
  Future<AuthPrincipal?> getPrincipalByEmail(String normalizedEmail);
  Future<AuthPrincipal?> getPrincipalByUsername(String normalizedUsername);
  Future<void> putPrincipal(AuthPrincipal principal);
  Future<void> putEmailLookup(String normalizedEmail, String userId);
  Future<void> putUsernameLookup(String normalizedUsername, String userId);
  Future<AuthEmailChallenge?> getEmailChallenge(String userId);
  Future<void> putEmailChallenge(AuthEmailChallenge challenge);
  Future<void> deleteEmailChallenge(String userId);
  Future<void> putSession(AuthSessionRecord session);
  Future<AuthSessionRecord?> getSessionById(String userId, String sessionId);
  Future<AuthSessionRecord?> getSessionByTokenHash(String tokenHash);
  Future<void> revokeSession(
    String userId,
    String sessionId,
    DateTime revokedAt,
  );
  Future<void> revokeAllSessionsForUser(String userId, DateTime revokedAt);
  Future<List<AuthPrincipal>> listAdHocPrincipals();
}

class InMemoryAuthRecordStore implements AuthRecordStore {
  final Map<String, AuthPrincipal> _principals = {};
  final Map<String, String> _emailLookup = {};
  final Map<String, String> _usernameLookup = {};
  final Map<String, AuthEmailChallenge> _challenges = {};
  final Map<String, AuthSessionRecord> _sessions = {};
  final Map<String, ({String userId, String sessionId})> _tokenLookups = {};

  @override
  Future<void> initialize() async {}

  @override
  Future<void> close() async {}

  @override
  Future<AuthPrincipal?> getPrincipalByUserId(String userId) async {
    return _principals[userId];
  }

  @override
  Future<AuthPrincipal?> getPrincipalByEmail(String normalizedEmail) async {
    final userId = _emailLookup[normalizedEmail];
    return userId == null ? null : _principals[userId];
  }

  @override
  Future<AuthPrincipal?> getPrincipalByUsername(
    String normalizedUsername,
  ) async {
    final userId = _usernameLookup[normalizedUsername];
    return userId == null ? null : _principals[userId];
  }

  @override
  Future<void> putPrincipal(AuthPrincipal principal) async {
    _principals[principal.userId] = principal;
  }

  @override
  Future<void> putEmailLookup(String normalizedEmail, String userId) async {
    _emailLookup[normalizedEmail] = userId;
  }

  @override
  Future<void> putUsernameLookup(
    String normalizedUsername,
    String userId,
  ) async {
    _usernameLookup[normalizedUsername] = userId;
  }

  @override
  Future<AuthEmailChallenge?> getEmailChallenge(String userId) async {
    return _challenges[userId];
  }

  @override
  Future<void> putEmailChallenge(AuthEmailChallenge challenge) async {
    _challenges[challenge.userId] = challenge;
  }

  @override
  Future<void> deleteEmailChallenge(String userId) async {
    _challenges.remove(userId);
  }

  @override
  Future<void> putSession(AuthSessionRecord session) async {
    _sessions['${session.userId}|${session.sessionId}'] = session;
    _tokenLookups[session.refreshTokenHash] = (
      userId: session.userId,
      sessionId: session.sessionId,
    );
  }

  @override
  Future<AuthSessionRecord?> getSessionById(
    String userId,
    String sessionId,
  ) async {
    return _sessions['$userId|$sessionId'];
  }

  @override
  Future<AuthSessionRecord?> getSessionByTokenHash(String tokenHash) async {
    final lookup = _tokenLookups[tokenHash];
    if (lookup == null) return null;
    return _sessions['${lookup.userId}|${lookup.sessionId}'];
  }

  @override
  Future<void> revokeSession(
    String userId,
    String sessionId,
    DateTime revokedAt,
  ) async {
    final key = '$userId|$sessionId';
    final session = _sessions[key];
    if (session != null) {
      _sessions[key] = session.copyWith(revokedAt: revokedAt.toUtc());
    }
  }

  @override
  Future<void> revokeAllSessionsForUser(
    String userId,
    DateTime revokedAt,
  ) async {
    final keys = _sessions.keys
        .where((key) => key.startsWith('$userId|'))
        .toList(growable: false);
    for (final key in keys) {
      _sessions[key] = _sessions[key]!.copyWith(revokedAt: revokedAt.toUtc());
    }
  }

  @override
  Future<List<AuthPrincipal>> listAdHocPrincipals() async {
    return _principals.values
        .where((principal) => principal.isAdHoc && !principal.isDeleted)
        .toList(growable: false);
  }
}

class DynamoAuthRecordStore implements AuthRecordStore {
  DynamoAuthRecordStore({
    required this.tableName,
    required this.credentials,
    this.region = 'us-east-1',
    this.useLocalDynamoDB = false,
    this.localEndpoint,
    Future<AWSCredentials> Function()? credentialsResolver,
    http.Client? httpClient,
  }) : _credentialsResolver = credentialsResolver,
       _httpClient = httpClient ?? http.Client();

  final String tableName;
  final String region;
  final bool useLocalDynamoDB;
  final String? localEndpoint;
  final AWSCredentials credentials;
  final Future<AWSCredentials> Function()? _credentialsResolver;
  final http.Client _httpClient;

  bool _initialized = false;
  late String _endpoint;
  late Map<String, String> _baseHeaders;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    if (useLocalDynamoDB) {
      _endpoint = localEndpoint ?? 'http://localhost:8000';
      _baseHeaders = <String, String>{
        'Content-Type': 'application/x-amz-json-1.0',
        'Authorization':
            'AWS4-HMAC-SHA256 Credential=fake/20230101/$region/dynamodb/aws4_request, SignedHeaders=host;x-amz-date, Signature=fake',
        'X-Amz-Target': 'DynamoDB_20120810',
      };
    } else {
      _endpoint = 'https://dynamodb.$region.amazonaws.com';
      _baseHeaders = <String, String>{
        'Content-Type': 'application/x-amz-json-1.0',
        'X-Amz-Target': 'DynamoDB_20120810',
      };
    }

    _initialized = true;
    if (useLocalDynamoDB) {
      await createTableIfNotExists();
    }
  }

  @override
  Future<void> close() async {
    _initialized = false;
    _httpClient.close();
  }

  @override
  Future<AuthPrincipal?> getPrincipalByUserId(String userId) async {
    final item = await _getItem(pk: _userPk(userId), sk: _principalSk());
    return item == null ? null : AuthPrincipal.fromJson(item);
  }

  @override
  Future<AuthPrincipal?> getPrincipalByEmail(String normalizedEmail) async {
    final lookup = await _getItem(
      pk: _emailLookupPk(normalizedEmail),
      sk: _lookupSk(),
    );
    final userId = lookup?['userId'] as String?;
    return userId == null ? null : getPrincipalByUserId(userId);
  }

  @override
  Future<AuthPrincipal?> getPrincipalByUsername(
    String normalizedUsername,
  ) async {
    final lookup = await _getItem(
      pk: _usernameLookupPk(normalizedUsername),
      sk: _lookupSk(),
    );
    final userId = lookup?['userId'] as String?;
    return userId == null ? null : getPrincipalByUserId(userId);
  }

  @override
  Future<void> putPrincipal(AuthPrincipal principal) async {
    await _putItem(
      pk: _userPk(principal.userId),
      sk: _principalSk(),
      payload: {
        'itemType': 'principal',
        'gsi1pk': _principalListingGsiPk(),
        'gsi1sk': _principalListingGsiSk(
          accountStatus: principal.accountStatus,
          identityKind: principal.identityKind,
          isAdHoc: principal.isAdHoc,
          userId: principal.userId,
        ),
        ...principal.toJson(),
      },
    );
  }

  @override
  Future<void> putEmailLookup(String normalizedEmail, String userId) async {
    await _putItem(
      pk: _emailLookupPk(normalizedEmail),
      sk: _lookupSk(),
      payload: {
        'itemType': 'lookup',
        'lookupType': 'email',
        'normalizedEmail': normalizedEmail,
        'userId': userId,
      },
    );
  }

  @override
  Future<void> putUsernameLookup(
    String normalizedUsername,
    String userId,
  ) async {
    await _putItem(
      pk: _usernameLookupPk(normalizedUsername),
      sk: _lookupSk(),
      payload: {
        'itemType': 'lookup',
        'lookupType': 'username',
        'normalizedUsername': normalizedUsername,
        'userId': userId,
      },
    );
  }

  @override
  Future<AuthEmailChallenge?> getEmailChallenge(String userId) async {
    final item = await _getItem(pk: _userPk(userId), sk: _emailChallengeSk());
    return item == null ? null : AuthEmailChallenge.fromJson(item);
  }

  @override
  Future<void> putEmailChallenge(AuthEmailChallenge challenge) async {
    await _putItem(
      pk: _userPk(challenge.userId),
      sk: _emailChallengeSk(),
      payload: {'itemType': 'emailChallenge', ...challenge.toJson()},
    );
  }

  @override
  Future<void> deleteEmailChallenge(String userId) async {
    await _deleteItem(pk: _userPk(userId), sk: _emailChallengeSk());
  }

  @override
  Future<void> putSession(AuthSessionRecord session) async {
    await _putItem(
      pk: _userPk(session.userId),
      sk: _sessionSk(session.sessionId),
      payload: {'itemType': 'session', ...session.toJson()},
    );
    await _putItem(
      pk: _sessionTokenPk(session.refreshTokenHash),
      sk: _lookupSk(),
      payload: {
        'itemType': 'sessionLookup',
        'userId': session.userId,
        'sessionId': session.sessionId,
        'refreshTokenHash': session.refreshTokenHash,
        'ttlEpochSeconds': session.ttlEpochSeconds,
      },
    );
  }

  @override
  Future<AuthSessionRecord?> getSessionById(
    String userId,
    String sessionId,
  ) async {
    final item = await _getItem(pk: _userPk(userId), sk: _sessionSk(sessionId));
    return item == null ? null : AuthSessionRecord.fromJson(item);
  }

  @override
  Future<AuthSessionRecord?> getSessionByTokenHash(String tokenHash) async {
    final lookup = await _getItem(
      pk: _sessionTokenPk(tokenHash),
      sk: _lookupSk(),
    );
    final userId = lookup?['userId'] as String?;
    final sessionId = lookup?['sessionId'] as String?;
    if (userId == null || sessionId == null) {
      return null;
    }
    return getSessionById(userId, sessionId);
  }

  @override
  Future<void> revokeSession(
    String userId,
    String sessionId,
    DateTime revokedAt,
  ) async {
    final session = await getSessionById(userId, sessionId);
    if (session == null) {
      return;
    }
    await putSession(session.copyWith(revokedAt: revokedAt.toUtc()));
  }

  @override
  Future<void> revokeAllSessionsForUser(
    String userId,
    DateTime revokedAt,
  ) async {
    final items = await _queryUserItems(userId, skPrefix: 'SESSION#');
    for (final item in items) {
      final session = AuthSessionRecord.fromJson(item);
      await putSession(session.copyWith(revokedAt: revokedAt.toUtc()));
    }
  }

  @override
  Future<List<AuthPrincipal>> listAdHocPrincipals() async {
    final results = <String, Map<String, dynamic>>{};
    for (final status in _nonDeletedStatuses) {
      for (final kind in AuthIdentityKind.values) {
        final items = await _queryPrincipalsByPrefix(
          accountStatus: status,
          identityKind: kind,
          isAdHoc: true,
        );
        for (final item in items) {
          final userId = item['userId'] as String?;
          if (userId == null || userId.isEmpty) {
            continue;
          }
          results[userId] = item;
        }
      }
    }
    return results.values
        .map(AuthPrincipal.fromJson)
        .where((principal) => principal.isAdHoc && !principal.isDeleted)
        .toList(growable: false);
  }

  Future<void> createTableIfNotExists() async {
    final describe = await _dynamoRequest('DescribeTable', {
      'TableName': tableName,
    });
    if (describe.statusCode == 200) return;
    final response = await _dynamoRequest('CreateTable', {
      'TableName': tableName,
      'KeySchema': [
        {'AttributeName': 'pk', 'KeyType': 'HASH'},
        {'AttributeName': 'sk', 'KeyType': 'RANGE'},
      ],
      'AttributeDefinitions': [
        {'AttributeName': 'pk', 'AttributeType': 'S'},
        {'AttributeName': 'sk', 'AttributeType': 'S'},
        {'AttributeName': 'gsi1pk', 'AttributeType': 'S'},
        {'AttributeName': 'gsi1sk', 'AttributeType': 'S'},
      ],
      'GlobalSecondaryIndexes': [
        {
          'IndexName': _principalListingIndexName,
          'KeySchema': [
            {'AttributeName': 'gsi1pk', 'KeyType': 'HASH'},
            {'AttributeName': 'gsi1sk', 'KeyType': 'RANGE'},
          ],
          'Projection': {'ProjectionType': 'ALL'},
        },
      ],
      'BillingMode': 'PAY_PER_REQUEST',
      'TimeToLiveSpecification': {
        'AttributeName': 'ttlEpochSeconds',
        'Enabled': true,
      },
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to create auth table: ${response.body}');
    }
  }

  Future<Map<String, dynamic>?> _getItem({
    required String pk,
    required String sk,
  }) async {
    await initialize();
    final response = await _dynamoRequest('GetItem', {
      'TableName': tableName,
      'Key': {
        'pk': {'S': pk},
        'sk': {'S': sk},
      },
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to get auth item: ${response.body}');
    }
    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final item = body['Item'] as Map<String, dynamic>?;
    return item == null ? null : _decodeItem(item);
  }

  Future<void> _putItem({
    required String pk,
    required String sk,
    required Map<String, dynamic> payload,
  }) async {
    await initialize();
    final response = await _dynamoRequest('PutItem', {
      'TableName': tableName,
      'Item': {
        'pk': {'S': pk},
        'sk': {'S': sk},
        ..._encodeJson(payload),
      },
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to put auth item: ${response.body}');
    }
  }

  Future<void> _deleteItem({required String pk, required String sk}) async {
    await initialize();
    final response = await _dynamoRequest('DeleteItem', {
      'TableName': tableName,
      'Key': {
        'pk': {'S': pk},
        'sk': {'S': sk},
      },
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to delete auth item: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> _queryUserItems(
    String userId, {
    String? skPrefix,
  }) async {
    await initialize();
    final attributeValues = <String, dynamic>{
      ':pk': {'S': _userPk(userId)},
    };
    var keyCondition = 'pk = :pk';
    if (skPrefix != null && skPrefix.isNotEmpty) {
      attributeValues[':skPrefix'] = {'S': skPrefix};
      keyCondition = '$keyCondition AND begins_with(sk, :skPrefix)';
    }
    final response = await _dynamoRequest('Query', {
      'TableName': tableName,
      'KeyConditionExpression': keyCondition,
      'ExpressionAttributeValues': attributeValues,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to query auth items: ${response.body}');
    }
    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final items = body['Items'] as List<dynamic>? ?? const <dynamic>[];
    return items
        .whereType<Map<String, dynamic>>()
        .map(_decodeItem)
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _queryPrincipalsByPrefix({
    required AuthAccountStatus accountStatus,
    required AuthIdentityKind identityKind,
    required bool isAdHoc,
  }) async {
    await initialize();
    final gsi1skPrefix = _principalListingGsiSkPrefix(
      accountStatus: accountStatus,
      identityKind: identityKind,
      isAdHoc: isAdHoc,
    );
    final response = await _dynamoRequest('Query', {
      'TableName': tableName,
      'IndexName': _principalListingIndexName,
      'KeyConditionExpression':
          'gsi1pk = :gsi1pk AND begins_with(gsi1sk, :gsi1skPrefix)',
      'ExpressionAttributeValues': {
        ':gsi1pk': {'S': _principalListingGsiPk()},
        ':gsi1skPrefix': {'S': gsi1skPrefix},
      },
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to query auth principals: ${response.body}');
    }
    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final items = body['Items'] as List<dynamic>? ?? const <dynamic>[];
    return items
        .whereType<Map<String, dynamic>>()
        .map(_decodeItem)
        .toList(growable: false);
  }

  Future<http.Response> _dynamoRequest(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    if (!_initialized) {
      await initialize();
    }
    final uri = Uri.parse(_endpoint);
    final body = jsonEncode(payload);

    if (useLocalDynamoDB) {
      final headers = Map<String, String>.from(_baseHeaders)
        ..['X-Amz-Target'] = 'DynamoDB_20120810.$operation';
      return _httpClient.post(uri, headers: headers, body: body);
    }

    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(
        await (_credentialsResolver?.call() ??
            Future<AWSCredentials>.value(credentials)),
      ),
    );
    final encodedBody = utf8.encode(body);
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
        region: region,
        service: AWSService.dynamoDb,
      ),
    );
    final request = http.Request('POST', signedRequest.uri);
    request.headers.addAll(signedRequest.headers);
    request.bodyBytes = encodedBody;
    final streamed = await _httpClient.send(request);
    return http.Response.fromStream(streamed);
  }

  Map<String, dynamic> _encodeJson(Map<String, dynamic> json) {
    final result = <String, dynamic>{};
    for (final entry in json.entries) {
      result[entry.key] = _encodeValue(entry.value);
    }
    return result;
  }

  Map<String, dynamic> _decodeItem(Map<String, dynamic> item) {
    final result = <String, dynamic>{};
    for (final entry in item.entries) {
      if (entry.key == 'pk' || entry.key == 'sk') {
        continue;
      }
      result[entry.key] = _decodeValue(entry.value);
    }
    return result;
  }

  dynamic _encodeValue(dynamic value) {
    if (value == null) return {'NULL': true};
    if (value is String) return {'S': value};
    if (value is num) return {'N': value.toString()};
    if (value is bool) return {'BOOL': value};
    if (value is DateTime) return {'S': value.toUtc().toIso8601String()};
    if (value is List) {
      return {'L': value.map(_encodeValue).toList(growable: false)};
    }
    if (value is Map<String, dynamic>) {
      return {'M': value.map((key, item) => MapEntry(key, _encodeValue(item)))};
    }
    return {'S': value.toString()};
  }

  dynamic _decodeValue(dynamic attr) {
    if (attr is Map<String, dynamic>) {
      if (attr.containsKey('S')) return attr['S'];
      if (attr.containsKey('N')) {
        final value = attr['N'] as String;
        return num.tryParse(value) ?? value;
      }
      if (attr.containsKey('BOOL')) return attr['BOOL'];
      if (attr.containsKey('NULL')) return null;
      if (attr.containsKey('L')) {
        return (attr['L'] as List<dynamic>)
            .map(_decodeValue)
            .toList(growable: false);
      }
      if (attr.containsKey('M')) {
        final map = attr['M'] as Map<String, dynamic>;
        return map.map((key, value) => MapEntry(key, _decodeValue(value)));
      }
    }
    return attr;
  }

  String _userPk(String userId) => 'USER#$userId';
  String _principalSk() => 'PRINCIPAL';
  String _lookupSk() => 'LOOKUP';
  String _emailLookupPk(String normalizedEmail) =>
      'IDENTIFIER#EMAIL#$normalizedEmail';
  String _usernameLookupPk(String normalizedUsername) =>
      'IDENTIFIER#USERNAME#$normalizedUsername';
  String _emailChallengeSk() => 'CHALLENGE#EMAIL';
  String _sessionSk(String sessionId) => 'SESSION#$sessionId';
  String _sessionTokenPk(String tokenHash) => 'SESSIONTOKEN#$tokenHash';
  static const String _principalListingIndexName = 'GSI1';
  static const List<AuthAccountStatus> _nonDeletedStatuses =
      <AuthAccountStatus>[
        AuthAccountStatus.pendingVerification,
        AuthAccountStatus.active,
      ];
  String _principalListingGsiPk() => 'principal';
  String _principalListingGsiSkPrefix({
    required AuthAccountStatus accountStatus,
    required AuthIdentityKind identityKind,
    required bool isAdHoc,
  }) {
    final adHocBit = isAdHoc ? '1' : '0';
    return 'STATUS#${accountStatus.value}#KIND#${identityKind.value}#ADHOC#$adHocBit#USER#';
  }

  String _principalListingGsiSk({
    required AuthAccountStatus accountStatus,
    required AuthIdentityKind identityKind,
    required bool isAdHoc,
    required String userId,
  }) {
    final prefix = _principalListingGsiSkPrefix(
      accountStatus: accountStatus,
      identityKind: identityKind,
      isAdHoc: isAdHoc,
    );
    return '$prefix$userId';
  }
}
