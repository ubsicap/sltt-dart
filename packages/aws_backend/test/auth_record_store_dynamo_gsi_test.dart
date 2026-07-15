import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/src/auth/auth_models.dart';
import 'package:aws_backend/src/auth/auth_record_store.dart';
import 'package:aws_common/aws_common.dart';
import 'package:test/test.dart';

void main() {
  group('DynamoAuthRecordStore GSI1', () {
    late HttpServer server;
    late Future<_DynamoReply> Function(
      String operation,
      Map<String, dynamic> payload,
    )
    handler;

    setUp(() async {
      handler = (_, __) async => const _DynamoReply(statusCode: 500, body: {});
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        final raw = await utf8.decoder.bind(request).join();
        final payload = raw.isEmpty
            ? <String, dynamic>{}
            : Map<String, dynamic>.from(
                jsonDecode(raw) as Map<String, dynamic>,
              );
        final target = request.headers.value('x-amz-target') ?? '';
        final operation = target.contains('.')
            ? target.substring(target.lastIndexOf('.') + 1)
            : target;
        final reply = await handler(operation, payload);

        request.response.statusCode = reply.statusCode;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(reply.body));
        await request.response.close();
      });
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test('createTableIfNotExists requests GSI1 schema', () async {
      Map<String, dynamic>? createPayload;
      handler = (operation, payload) async {
        if (operation == 'DescribeTable') {
          return const _DynamoReply(
            statusCode: 400,
            body: {'__type': 'ResourceNotFoundException'},
          );
        }
        if (operation == 'CreateTable') {
          createPayload = payload;
          return const _DynamoReply(
            statusCode: 200,
            body: {'TableDescription': {}},
          );
        }
        return const _DynamoReply(statusCode: 500, body: {});
      };

      final store = DynamoAuthRecordStore(
        tableName: 'test-auth-table',
        credentials: const AWSCredentials('key', 'secret'),
        useLocalDynamoDB: true,
        localEndpoint: 'http://${server.address.address}:${server.port}',
      );
      await store.initialize();

      final attributeDefinitions = List<Map<String, dynamic>>.from(
        createPayload?['AttributeDefinitions'] as List<dynamic>? ??
            const <dynamic>[],
      );
      final globalSecondaryIndexes = List<Map<String, dynamic>>.from(
        createPayload?['GlobalSecondaryIndexes'] as List<dynamic>? ??
            const <dynamic>[],
      );

      expect(
        attributeDefinitions.any(
          (entry) =>
              entry['AttributeName'] == 'gsi1pk' &&
              entry['AttributeType'] == 'S',
        ),
        isTrue,
      );
      expect(
        attributeDefinitions.any(
          (entry) =>
              entry['AttributeName'] == 'gsi1sk' &&
              entry['AttributeType'] == 'S',
        ),
        isTrue,
      );
      expect(globalSecondaryIndexes, hasLength(1));
      expect(globalSecondaryIndexes.single['IndexName'], equals('GSI1'));

      await store.close();
    });

    test('putPrincipal writes composite gsi1sk', () async {
      Map<String, dynamic>? putItemPayload;
      handler = (operation, payload) async {
        if (operation == 'DescribeTable') {
          return const _DynamoReply(statusCode: 200, body: {'Table': {}});
        }
        if (operation == 'PutItem') {
          putItemPayload = payload;
          return const _DynamoReply(statusCode: 200, body: {});
        }
        return const _DynamoReply(statusCode: 500, body: {});
      };

      final store = DynamoAuthRecordStore(
        tableName: 'test-auth-table',
        credentials: const AWSCredentials('key', 'secret'),
        useLocalDynamoDB: true,
        localEndpoint: 'http://${server.address.address}:${server.port}',
      );
      await store.initialize();

      final principal = _usernamePrincipal(
        userId: 'user_123',
        accountStatus: AuthAccountStatus.active,
        identityKind: AuthIdentityKind.usernamePassword,
        isAdHoc: true,
      );

      await store.putPrincipal(principal);

      final item = Map<String, dynamic>.from(
        putItemPayload?['Item'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      );
      expect(item['gsi1pk'], equals({'S': 'PRINCIPAL'}));
      expect(
        item['gsi1sk'],
        equals({
          'S':
              '@STATUS#active#@KIND#username_password#@ADHOC#1#@USERID#user_123',
        }),
      );

      await store.close();
    });

    test(
      'listAdHocPrincipals uses expected status and identity query prefixes',
      () async {
        final queriedPrefixes = <String>[];
        final expectedHitPrefix =
            '@STATUS#active#@KIND#username_password#@ADHOC#1#';
        final adhocPrincipal = _usernamePrincipal(
          userId: 'adhoc-user-1',
          accountStatus: AuthAccountStatus.active,
          identityKind: AuthIdentityKind.usernamePassword,
          isAdHoc: true,
        );

        handler = (operation, payload) async {
          if (operation == 'DescribeTable') {
            return const _DynamoReply(statusCode: 200, body: {'Table': {}});
          }
          if (operation == 'Query') {
            final values = Map<String, dynamic>.from(
              payload['ExpressionAttributeValues'] as Map<String, dynamic>? ??
                  const <String, dynamic>{},
            );
            final prefix =
                ((values[':gsi1skPrefix'] as Map<String, dynamic>?)?['S']
                    as String?) ??
                '';
            queriedPrefixes.add(prefix);

            if (prefix == expectedHitPrefix) {
              final itemJson = <String, dynamic>{
                'itemType': 'principal',
                'gsi1pk': 'PRINCIPAL',
                'gsi1sk': '$expectedHitPrefix@USERID#${adhocPrincipal.userId}',
                ...adhocPrincipal.toJson(),
              };
              return _DynamoReply(
                statusCode: 200,
                body: {
                  'Items': <Map<String, dynamic>>[_encodeItem(itemJson)],
                },
              );
            }

            return const _DynamoReply(
              statusCode: 200,
              body: {'Items': <dynamic>[]},
            );
          }
          return const _DynamoReply(statusCode: 500, body: {});
        };

        final store = DynamoAuthRecordStore(
          tableName: 'test-auth-table',
          credentials: const AWSCredentials('key', 'secret'),
          useLocalDynamoDB: true,
          localEndpoint: 'http://${server.address.address}:${server.port}',
        );
        await store.initialize();

        final principals = await store.listAdHocPrincipals();
        final principalUserIds = principals
            .map((principal) => principal.userId)
            .toList(growable: false);

        expect(principalUserIds, equals(<String>['adhoc-user-1']));
        expect(
          queriedPrefixes,
          containsAll(<String>[
            '@STATUS#pending_verification#@KIND#email_password#@ADHOC#1#',
            '@STATUS#pending_verification#@KIND#username_password#@ADHOC#1#',
            '@STATUS#active#@KIND#email_password#@ADHOC#1#',
            '@STATUS#active#@KIND#username_password#@ADHOC#1#',
          ]),
        );

        await store.close();
      },
    );
  });
}

class _DynamoReply {
  const _DynamoReply({required this.statusCode, required this.body});

  final int statusCode;
  final Map<String, dynamic> body;
}

UsernameAuthPrincipal _usernamePrincipal({
  required String userId,
  required AuthAccountStatus accountStatus,
  required AuthIdentityKind identityKind,
  required bool isAdHoc,
}) {
  final now = DateTime.utc(2026, 1, 1, 12);
  return UsernameAuthPrincipal(
    userId: userId,
    identityKind: identityKind,
    username: 'local_user_$userId',
    normalizedUsername: 'local_user_$userId',
    passwordHash: 'hash',
    passwordSalt: 'salt',
    passwordIterations: 1000,
    accountStatus: accountStatus,
    emailVerified: true,
    isAdHoc: isAdHoc,
    displayName: 'Display $userId',
    assignedProjectIds: const <String>['project-a'],
    memberships: const <String, String>{'project-a': 'translator'},
    verificationVersion: 0,
    createdAt: now,
    updatedAt: now,
    verifiedAt: now,
  );
}

Map<String, dynamic> _encodeItem(Map<String, dynamic> json) {
  final result = <String, dynamic>{};
  for (final entry in json.entries) {
    result[entry.key] = _encodeValue(entry.value);
  }
  return result;
}

dynamic _encodeValue(dynamic value) {
  if (value == null) return <String, dynamic>{'NULL': true};
  if (value is String) return <String, dynamic>{'S': value};
  if (value is num) return <String, dynamic>{'N': value.toString()};
  if (value is bool) return <String, dynamic>{'BOOL': value};
  if (value is List) {
    return <String, dynamic>{
      'L': value.map(_encodeValue).toList(growable: false),
    };
  }
  if (value is Map<String, dynamic>) {
    return <String, dynamic>{
      'M': value.map((key, item) => MapEntry(key, _encodeValue(item))),
    };
  }
  return <String, dynamic>{'S': value.toString()};
}
