import 'dart:async';
import 'dart:convert';

import 'package:aws_backend/aws_backend.dart';
import 'package:aws_backend/src/auth/auth_app_state_store.dart';
import 'package:aws_backend/src/auth/auth_email_sender.dart';
import 'package:aws_backend/src/auth/auth_record_store.dart';
import 'package:aws_backend/src/auth/password_hash_service.dart';
import 'package:aws_backend/src/auth/token_service.dart';
import 'package:aws_backend/src/models/dynamo_entity_state.dart';
import 'package:logging/logging.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'helpers/fake_storage.dart';

void main() {
  group('offline auth api', () {
    late FakeDynamoDBStorageService storage;
    late InMemoryAuthRecordStore recordStore;
    late _CapturingEmailSender emailSender;
    late BackendAuthService authService;
    late AwsRestApiServer server;
    late Router router;
    late List<LogRecord> logRecords;
    late StreamSubscription<LogRecord> logSubscription;

    Map<String, dynamic> responseBody(Map<String, dynamic> response) {
      return jsonDecode(response['body'] as String) as Map<String, dynamic>;
    }

    Map<String, dynamic> authEventPayload(String event) {
      final record = logRecords.lastWhere(
        (record) => record.message.contains('"event":"$event"'),
      );
      return jsonDecode(record.message.substring(record.message.indexOf('{')))
          as Map<String, dynamic>;
    }

    setUp(() async {
      SlttLogger.setLevel(SlttLogLevel.info);
      logRecords = <LogRecord>[];
      logSubscription = Logger.root.onRecord.listen(logRecords.add);
      storage = FakeDynamoDBStorageService();
      recordStore = InMemoryAuthRecordStore();
      emailSender = _CapturingEmailSender();
      authService = BackendAuthService(
        recordStore: recordStore,
        appStateStore: AuthAppStateStore(storage: storage),
        passwordHashService: PasswordHashService(iterations: 1000),
        tokenService: TokenService(jwtSecret: 'test-secret'),
        emailSender: emailSender,
        verificationCodeSecret: 'test-secret',
      );
      await authService.initialize();
      server = AwsRestApiServer(
        serverName: 'TestServer',
        storage: storage,
        authService: authService,
      );
      router = server.getRouter();
    });

    group('logout flow', () {
      test('logout succeeds with bearer and refreshToken', () async {
        final registerResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/register',
          'headers': <String, String>{},
          'body': jsonEncode({
            'userId': 'logout-user',
            'name': 'Logout User',
            'dateOfBirth': '1990-01-01',
            'email': 'logout@example.com',
            'password': 'secret123',
          }),
        }, router);
        expect(registerResponse['statusCode'], equals(200));

        final verifyResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/verify-email',
          'headers': <String, String>{},
          'body': jsonEncode({
            'email': 'logout@example.com',
            'code': emailSender.codes['logout@example.com']!.last,
          }),
        }, router);
        expect(verifyResponse['statusCode'], equals(200));
        final verifyBody =
            jsonDecode(verifyResponse['body'] as String)
                as Map<String, dynamic>;

        final logoutResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/logout',
          'headers': <String, String>{
            'authorization': 'Bearer ${verifyBody['accessToken']}',
          },
          'body': jsonEncode({'refreshToken': verifyBody['refreshToken']}),
        }, router);

        expect(logoutResponse['statusCode'], equals(200));
        expect(responseBody(logoutResponse)['status'], equals('logged_out'));
      });

      test('logout without authorization header returns 401', () async {
        final response = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/logout',
          'headers': <String, String>{},
          'body': jsonEncode({}),
        }, router);
        expect(response['statusCode'], equals(401));
      });

      test('logout with malformed authorization returns 401', () async {
        final response = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/logout',
          'headers': <String, String>{'authorization': 'InvalidToken'},
          'body': jsonEncode({}),
        }, router);
        expect(response['statusCode'], equals(401));
      });

      test(
        'GET /api/cross-domain/project/states/project requires authorization',
        () async {
          final response = await server.handleApiGatewayEvent({
            'httpMethod': 'GET',
            'path': '/api/cross-domain/project/states/project',
            'headers': <String, String>{},
          }, router);

          expect(response['statusCode'], equals(401));
        },
      );

      test(
        'GET /api/cross-domain/project/states/project returns only authorized projects',
        () async {
          const userId = 'project-user-1';
          final registerResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{},
            'body': jsonEncode({
              'userId': userId,
              'name': 'Project User',
              'dateOfBirth': '1990-01-01',
              'email': 'project-user@example.com',
              'password': 'secret123',
            }),
          }, router);
          expect(registerResponse['statusCode'], equals(200));

          final verifyResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/verify-email',
            'headers': <String, String>{},
            'body': jsonEncode({
              'email': 'project-user@example.com',
              'code': emailSender.codes['project-user@example.com']!.last,
            }),
          }, router);
          expect(verifyResponse['statusCode'], equals(200));
          final verifyBody =
              jsonDecode(verifyResponse['body'] as String)
                  as Map<String, dynamic>;
          final accessToken = verifyBody['accessToken'] as String;

          final iso = DateTime.now().toUtc().toIso8601String();
          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': userId,
              'entityType': kEntityTypeMember,
              'domainType': kDomainMembership,
              'unknownJson': '{}',
              'change_domainId': 'project-1',
              'change_domainId_orig_': 'project-1',
              'change_changeAt': iso,
              'change_changeAt_orig_': iso,
              'change_cid': 'member-1',
              'change_cid_orig_': 'member-1',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': iso,
              'change_storedAt_orig_': iso,
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': iso,
              'data_parentId_cid_': 'member-1',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionMembership,
              'data_parentProp_changeAt_': iso,
              'data_parentProp_cid_': 'member-1',
              'data_parentProp_changeBy_': 'seed',
              'data_role': 'admin',
              'data_isAdHoc': false,
              'data_name': 'Project User',
              'data_email': 'project-user@example.com',
            }),
          );

          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': 'project-1',
              'entityType': kEntityTypeProject,
              'domainType': kDomainProject,
              'unknownJson': '{}',
              'change_domainId': 'project-1',
              'change_domainId_orig_': 'project-1',
              'change_changeAt': iso,
              'change_changeAt_orig_': iso,
              'change_cid': 'project-1-cid',
              'change_cid_orig_': 'project-1-cid',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': iso,
              'change_storedAt_orig_': iso,
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': iso,
              'data_parentId_cid_': 'project-1-cid',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionProject,
              'data_parentProp_changeAt_': iso,
              'data_parentProp_cid_': 'project-1-cid',
              'data_parentProp_changeBy_': 'seed',
              'data_name': 'Authorized Project',
            }),
          );

          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': 'project-unauthorized',
              'entityType': kEntityTypeProject,
              'domainType': kDomainProject,
              'unknownJson': '{}',
              'change_domainId': 'project-unauthorized',
              'change_domainId_orig_': 'project-unauthorized',
              'change_changeAt': iso,
              'change_changeAt_orig_': iso,
              'change_cid': 'project-unauthorized-cid',
              'change_cid_orig_': 'project-unauthorized-cid',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': iso,
              'change_storedAt_orig_': iso,
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': iso,
              'data_parentId_cid_': 'project-unauthorized-cid',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionProject,
              'data_parentProp_changeAt_': iso,
              'data_parentProp_cid_': 'project-unauthorized-cid',
              'data_parentProp_changeBy_': 'seed',
              'data_name': 'Unauthorized Project',
            }),
          );

          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': 'self-project-user',
              'entityType': kEntityTypeMember,
              'domainType': kDomainMembership,
              'unknownJson': '{}',
              'change_domainId': 'self-project',
              'change_domainId_orig_': 'self-project',
              'change_changeAt': iso,
              'change_changeAt_orig_': iso,
              'change_cid': 'self-member',
              'change_cid_orig_': 'self-member',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': iso,
              'change_storedAt_orig_': iso,
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': iso,
              'data_parentId_cid_': 'self-member',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionMembership,
              'data_parentProp_changeAt_': iso,
              'data_parentProp_cid_': 'self-member',
              'data_parentProp_changeBy_': 'seed',
              'data_role': 'admin',
              'data_isAdHoc': false,
              'data_name': 'Project User',
              'data_email': 'project-user@example.com',
            }),
          );

          final projectResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'GET',
            'path': '/api/cross-domain/project/states/project',
            'headers': <String, String>{'authorization': 'Bearer $accessToken'},
          }, router);

          expect(projectResponse['statusCode'], equals(200));
          final projectBody =
              jsonDecode(projectResponse['body'] as String)
                  as Map<String, dynamic>;
          expect(projectBody['count'], equals(1));
          final items = (projectBody['items'] as List<dynamic>);
          expect(items, hasLength(1));
          expect(items.first['entityId'], equals('project-1'));
          expect(items.first['change_domainId'], equals('project-1'));
        },
      );

      test(
        'GET /api/cross-domain/team/states/team requires authorization',
        () async {
          final response = await server.handleApiGatewayEvent({
            'httpMethod': 'GET',
            'path': '/api/cross-domain/team/states/team',
            'headers': <String, String>{},
          }, router);

          expect(response['statusCode'], equals(401));
        },
      );

      test(
        'GET /api/cross-domain/team/states/team returns only authorized teams',
        () async {
          const userId = 'team-user-1';
          final registerResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{},
            'body': jsonEncode({
              'userId': userId,
              'name': 'Team User',
              'dateOfBirth': '1990-01-01',
              'email': 'team-user@example.com',
              'password': 'secret123',
            }),
          }, router);
          expect(registerResponse['statusCode'], equals(200));

          final verifyResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/verify-email',
            'headers': <String, String>{},
            'body': jsonEncode({
              'email': 'team-user@example.com',
              'code': emailSender.codes['team-user@example.com']!.last,
            }),
          }, router);
          expect(verifyResponse['statusCode'], equals(200));
          final verifyBody =
              jsonDecode(verifyResponse['body'] as String)
                  as Map<String, dynamic>;
          final accessToken = verifyBody['accessToken'] as String;

          final iso = DateTime.now().toUtc().toIso8601String();
          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': userId,
              'entityType': kEntityTypeMember,
              'domainType': kDomainMembership,
              'unknownJson': '{}',
              'change_domainId': 'project-1',
              'change_domainId_orig_': 'project-1',
              'change_changeAt': iso,
              'change_changeAt_orig_': iso,
              'change_cid': 'member-1',
              'change_cid_orig_': 'member-1',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': iso,
              'change_storedAt_orig_': iso,
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': iso,
              'data_parentId_cid_': 'member-1',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionMembership,
              'data_parentProp_changeAt_': iso,
              'data_parentProp_cid_': 'member-1',
              'data_parentProp_changeBy_': 'seed',
              'data_role': 'admin',
              'data_isAdHoc': false,
              'data_name': 'Team User',
              'data_email': 'team-user@example.com',
            }),
          );

          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': 'project-1',
              'entityType': kEntityTypeProject,
              'domainType': kDomainProject,
              'unknownJson': '{}',
              'change_domainId': 'project-1',
              'change_domainId_orig_': 'project-1',
              'change_changeAt': iso,
              'change_changeAt_orig_': iso,
              'change_cid': 'project-1-cid',
              'change_cid_orig_': 'project-1-cid',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': iso,
              'change_storedAt_orig_': iso,
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': iso,
              'data_parentId_cid_': 'project-1-cid',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionProject,
              'data_parentProp_changeAt_': iso,
              'data_parentProp_cid_': 'project-1-cid',
              'data_parentProp_changeBy_': 'seed',
              'data_name': 'Authorized Project',
              'data_teamId': 'team-1',
            }),
          );

          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': 'project-unauthorized',
              'entityType': kEntityTypeProject,
              'domainType': kDomainProject,
              'unknownJson': '{}',
              'change_domainId': 'project-unauthorized',
              'change_domainId_orig_': 'project-unauthorized',
              'change_changeAt': iso,
              'change_changeAt_orig_': iso,
              'change_cid': 'project-unauthorized-cid',
              'change_cid_orig_': 'project-unauthorized-cid',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': iso,
              'change_storedAt_orig_': iso,
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': iso,
              'data_parentId_cid_': 'project-unauthorized-cid',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionProject,
              'data_parentProp_changeAt_': iso,
              'data_parentProp_cid_': 'project-unauthorized-cid',
              'data_parentProp_changeBy_': 'seed',
              'data_name': 'Unauthorized Project',
              'data_teamId': 'team-unauthorized',
            }),
          );

          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': 'team-1',
              'entityType': kEntityTypeTeam,
              'domainType': kDomainTeam,
              'unknownJson': '{}',
              'change_domainId': 'team-1',
              'change_domainId_orig_': 'team-1',
              'change_changeAt': iso,
              'change_changeAt_orig_': iso,
              'change_cid': 'team-1-cid',
              'change_cid_orig_': 'team-1-cid',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': iso,
              'change_storedAt_orig_': iso,
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': iso,
              'data_parentId_cid_': 'team-1-cid',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionTeam,
              'data_parentProp_changeAt_': iso,
              'data_parentProp_cid_': 'team-1-cid',
              'data_parentProp_changeBy_': 'seed',
              'data_name': 'Authorized Team',
            }),
          );

          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': 'team-unauthorized',
              'entityType': kEntityTypeTeam,
              'domainType': kDomainTeam,
              'unknownJson': '{}',
              'change_domainId': 'team-unauthorized',
              'change_domainId_orig_': 'team-unauthorized',
              'change_changeAt': iso,
              'change_changeAt_orig_': iso,
              'change_cid': 'team-unauthorized-cid',
              'change_cid_orig_': 'team-unauthorized-cid',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': iso,
              'change_storedAt_orig_': iso,
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': iso,
              'data_parentId_cid_': 'team-unauthorized-cid',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionTeam,
              'data_parentProp_changeAt_': iso,
              'data_parentProp_cid_': 'team-unauthorized-cid',
              'data_parentProp_changeBy_': 'seed',
              'data_name': 'Unauthorized Team',
            }),
          );

          final teamResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'GET',
            'path': '/api/cross-domain/team/states/team',
            'headers': <String, String>{'authorization': 'Bearer $accessToken'},
          }, router);

          expect(teamResponse['statusCode'], equals(200));
          final teamBody =
              jsonDecode(teamResponse['body'] as String)
                  as Map<String, dynamic>;
          expect(teamBody['count'], equals(1));
          final items = (teamBody['items'] as List<dynamic>);
          expect(items, hasLength(1));
          expect(items.first['entityId'], equals('team-1'));
          expect(items.first['change_domainId'], equals('team-1'));
        },
      );

      test('logout revokes provided refresh token', () async {
        final registerResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/register',
          'headers': <String, String>{},
          'body': jsonEncode({
            'userId': 'logout-revoke-user',
            'name': 'Logout Revoke',
            'dateOfBirth': '1990-01-02',
            'email': 'logout-revoke@example.com',
            'password': 'secret123',
          }),
        }, router);
        expect(registerResponse['statusCode'], equals(200));

        final verifyResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/verify-email',
          'headers': <String, String>{},
          'body': jsonEncode({
            'email': 'logout-revoke@example.com',
            'code': emailSender.codes['logout-revoke@example.com']!.last,
          }),
        }, router);
        expect(verifyResponse['statusCode'], equals(200));
        final verifyBody =
            jsonDecode(verifyResponse['body'] as String)
                as Map<String, dynamic>;

        final logoutResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/logout',
          'headers': <String, String>{
            'authorization': 'Bearer ${verifyBody['accessToken']}',
          },
          'body': jsonEncode({'refreshToken': verifyBody['refreshToken']}),
        }, router);

        expect(logoutResponse['statusCode'], equals(200));

        final refreshRetry = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/refresh',
          'headers': <String, String>{},
          'body': jsonEncode({'refreshToken': verifyBody['refreshToken']}),
        }, router);

        expect(refreshRetry['statusCode'], equals(401));
      });
    });

    tearDown(() async {
      await logSubscription.cancel();
      SlttLogger.setLevel(SlttLogLevel.warning);
    });

    group('self-registration flow', () {
      test('register then verify then login', () async {
        final registerResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/register',
          'headers': <String, String>{'x-forwarded-for': '203.0.113.10'},
          'body': jsonEncode({
            'userId': 'user-jane',
            'name': 'Jane Doe',
            'dateOfBirth': '1990-06-15',
            'email': 'jane@example.com',
            'password': 'secret123',
          }),
        }, router);

        expect(registerResponse['statusCode'], equals(200));
        expect(emailSender.codes['jane@example.com'], hasLength(1));
        final registeredPrincipal = await recordStore.getPrincipalByUserId(
          'user-jane',
        );
        expect(
          registeredPrincipal?.registrationOutcome_orig_,
          equals('register_new'),
        );
        expect(
          registeredPrincipal?.registrationOutcome_last_,
          equals('register_new'),
        );
        expect(
          registeredPrincipal?.registrationSourceIp_orig_,
          equals('203.0.113.10'),
        );
        expect(
          registeredPrincipal?.registrationSourceIp_last_,
          equals('203.0.113.10'),
        );

        final verifyResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/verify-email',
          'headers': <String, String>{},
          'body': jsonEncode({
            'email': 'jane@example.com',
            'code': emailSender.codes['jane@example.com']!.single,
          }),
        }, router);

        expect(verifyResponse['statusCode'], equals(200));
        final verifyBody =
            jsonDecode(verifyResponse['body'] as String)
                as Map<String, dynamic>;
        expect(verifyBody['status'], equals('verified'));
        expect(verifyBody['accessToken'], isNotEmpty);
        expect(verifyBody['refreshToken'], isNotEmpty);

        final loginResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/login',
          'headers': <String, String>{},
          'body': jsonEncode({
            'identifier': 'jane@example.com',
            'password': 'secret123',
          }),
        }, router);

        expect(loginResponse['statusCode'], equals(200));
        final loginBody =
            jsonDecode(loginResponse['body'] as String) as Map<String, dynamic>;
        expect(loginBody['status'], equals('authenticated'));

        final profileState = await storage.getEntityState(
          domainType: 'user',
          domainId: verifyBody['userId'] as String,
          entityType: kEntityTypeUserProfile,
          entityId: verifyBody['userId'] as String,
        );
        expect(profileState, isA<DynamoEntityState>());
        expect(
          profileState?.toJson()['email'] ??
              profileState?.toJson()['data_email'],
          equals('jane@example.com'),
        );
        expect(
          profileState?.toJson()['emailVerified'] ??
              profileState?.toJson()['data_emailVerified'],
          isTrue,
        );
      });

      test('register special test user bypasses email verification', () async {
        final registerResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/register',
          'headers': <String, String>{},
          'body': jsonEncode({
            'userId': 'ignored-test-id',
            'name': 'Test User Alice',
            'dateOfBirth': '1990-06-15',
            'email': 'alice@example.com',
            'password': 'secret123',
          }),
        }, router);

        expect(registerResponse['statusCode'], equals(200));
        final body = responseBody(registerResponse);
        expect(body['status'], equals('verified'));
        expect(emailSender.codes.containsKey('alice@example.com'), isFalse);

        final principal = await recordStore.getPrincipalByUserId(
          '__test_user_alice',
        );
        expect(principal, isNotNull);
        expect(principal?.emailVerified, isTrue);
        expect(principal?.accountStatus, equals(AuthAccountStatus.active));
        expect(principal?.displayName, equals('Test User Alice'));
      });

      test('test user can login and logout successfully', () async {
        final registerResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/register',
          'headers': <String, String>{},
          'body': jsonEncode({
            'userId': 'ignored-test-id',
            'name': 'Test User Bob',
            'dateOfBirth': '1990-06-15',
            'email': 'bob@example.com',
            'password': 'secret123',
          }),
        }, router);

        expect(registerResponse['statusCode'], equals(200));
        final registerBody = responseBody(registerResponse);
        expect(registerBody['status'], equals('verified'));

        final loginResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/login',
          'headers': <String, String>{},
          'body': jsonEncode({
            'identifier': 'bob@example.com',
            'password': 'secret123',
          }),
        }, router);

        expect(loginResponse['statusCode'], equals(200));
        final loginBody = responseBody(loginResponse);
        expect(loginBody['status'], equals('authenticated'));
        expect(loginBody['accessToken'], isNotEmpty);
        expect(loginBody['refreshToken'], isNotEmpty);

        final logoutResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/logout',
          'headers': <String, String>{
            'authorization': 'Bearer ${loginBody['accessToken']}',
          },
          'body': jsonEncode({'refreshToken': loginBody['refreshToken']}),
        }, router);

        expect(logoutResponse['statusCode'], equals(200));
        final logoutBody = responseBody(logoutResponse);
        expect(logoutBody['status'], equals('logged_out'));

        final refreshRetry = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/refresh',
          'headers': <String, String>{},
          'body': jsonEncode({'refreshToken': loginBody['refreshToken']}),
        }, router);

        expect(refreshRetry['statusCode'], equals(401));
      });

      test(
        'POST /api/project creates requested project and assigns current user as admin',
        () async {
          final registerResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{},
            'body': jsonEncode({
              'userId': 'project-creator',
              'name': 'Project Creator',
              'dateOfBirth': '1990-01-01',
              'email': 'creator@example.com',
              'password': 'secret123',
            }),
          }, router);
          expect(registerResponse['statusCode'], equals(200));

          final verifyResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/verify-email',
            'headers': <String, String>{},
            'body': jsonEncode({
              'email': 'creator@example.com',
              'code': emailSender.codes['creator@example.com']!.single,
            }),
          }, router);
          expect(verifyResponse['statusCode'], equals(200));
          final verifyBody =
              jsonDecode(verifyResponse['body'] as String)
                  as Map<String, dynamic>;
          final accessToken = verifyBody['accessToken'] as String;

          final createResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/project',
            'headers': <String, String>{'authorization': 'Bearer $accessToken'},
            'body': jsonEncode({
              'publicId': 'project-creator-id',
              'teamName': 'Creator Team',
              'signLanguage': 'ASL',
            }),
          }, router);

          expect(createResponse['statusCode'], equals(200));
          final createBody =
              jsonDecode(createResponse['body'] as String)
                  as Map<String, dynamic>;
          expect(createBody['projectId'], isNotEmpty);
          expect(createBody['status'], equals('requested'));
          expect(createBody['publicId'], equals('project-creator-id'));
          expect(createBody['teamName'], equals('Creator Team'));
          expect(createBody['signLanguage'], equals('ASL'));

          final projectId = createBody['projectId'] as String;
          final principal = await recordStore.getPrincipalByUserId(
            'project-creator',
          );
          expect(principal, isNotNull);
          expect(principal?.assignedProjectIds, contains(projectId));
          expect(
            principal?.memberships?[projectId],
            equals(MemberType.admin.name),
          );

          final membershipState = await storage.getEntityState(
            domainType: kDomainMembership,
            domainId: projectId,
            entityType: kEntityTypeMember,
            entityId: 'project-creator',
          );
          expect(membershipState, isNotNull);
          expect(
            membershipState?.toJson()['role'] ??
                membershipState?.toJson()['data_role'],
            equals(MemberType.admin.name),
          );
        },
      );

      test(
        'PUT /api/admin/project/{projectId} updates permitted project fields',
        () async {
          final registerResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{},
            'body': jsonEncode({
              'userId': 'project-updater',
              'name': 'Project Updater',
              'dateOfBirth': '1990-01-01',
              'email': 'updater@example.com',
              'password': 'secret123',
            }),
          }, router);
          expect(registerResponse['statusCode'], equals(200));

          final verifyResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/verify-email',
            'headers': <String, String>{},
            'body': jsonEncode({
              'email': 'updater@example.com',
              'code': emailSender.codes['updater@example.com']!.single,
            }),
          }, router);
          expect(verifyResponse['statusCode'], equals(200));
          final verifyBody =
              jsonDecode(verifyResponse['body'] as String)
                  as Map<String, dynamic>;
          final accessToken = verifyBody['accessToken'] as String;

          final createResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/project',
            'headers': <String, String>{'authorization': 'Bearer $accessToken'},
            'body': jsonEncode({
              'publicId': 'project-updater-id',
              'teamName': 'Updater Team',
              'signLanguage': 'BSL',
            }),
          }, router);
          expect(createResponse['statusCode'], equals(200));
          final createBody =
              jsonDecode(createResponse['body'] as String)
                  as Map<String, dynamic>;
          final projectId = createBody['projectId'] as String;

          final updateResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'PUT',
            'path': '/api/admin/project/$projectId',
            'headers': <String, String>{'authorization': 'Bearer $accessToken'},
            'body': jsonEncode({
              'teamName': 'Updated Team Name',
              'signLanguage': 'ASL',
              'status': 'active',
            }),
          }, router);
          expect(updateResponse['statusCode'], equals(200));
          final updateBody =
              jsonDecode(updateResponse['body'] as String)
                  as Map<String, dynamic>;
          expect(updateBody['projectId'], equals(projectId));
          expect(updateBody['updated'], isTrue);

          final projectState = await storage.getEntityState(
            domainType: kDomainProject,
            domainId: projectId,
            entityType: kEntityTypeProject,
            entityId: projectId,
          );
          expect(projectState, isNotNull);
          expect(
            projectState?.toJson()['data_teamName'] ??
                projectState?.toJson()['teamName'],
            equals('Updated Team Name'),
          );
          expect(
            projectState?.toJson()['data_status'] ??
                projectState?.toJson()['status'],
            equals('active'),
          );
        },
      );

      test(
        'PUT /api/super/admin/project/{projectId} updates required super fields',
        () async {
          final registerResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{},
            'body': jsonEncode({
              'userId': 'super-project-updater',
              'name': 'Super Updater',
              'dateOfBirth': '1990-01-01',
              'email': 'super-updater@example.com',
              'password': 'secret123',
            }),
          }, router);
          expect(registerResponse['statusCode'], equals(200));

          final verifyResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/verify-email',
            'headers': <String, String>{},
            'body': jsonEncode({
              'email': 'super-updater@example.com',
              'code': emailSender.codes['super-updater@example.com']!.single,
            }),
          }, router);
          expect(verifyResponse['statusCode'], equals(200));
          final verifyBody =
              jsonDecode(verifyResponse['body'] as String)
                  as Map<String, dynamic>;
          final accessToken = verifyBody['accessToken'] as String;

          final createResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/project',
            'headers': <String, String>{'authorization': 'Bearer $accessToken'},
            'body': jsonEncode({
              'publicId': 'super-project-id',
              'teamName': 'Super Team',
              'signLanguage': 'ASL',
            }),
          }, router);
          expect(createResponse['statusCode'], equals(200));
          final createBody =
              jsonDecode(createResponse['body'] as String)
                  as Map<String, dynamic>;
          final projectId = createBody['projectId'] as String;

          final superUpdateResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'PUT',
            'path': '/api/super/admin/project/$projectId',
            'headers': <String, String>{'authorization': 'Bearer $accessToken'},
            'body': jsonEncode({
              'publicId': 'super-project-id',
              'teamName': 'Super Team Updated',
              'teamId': '',
              'name': '',
              'signLanguage': 'ASL',
              'status': 'approved',
              'deleted': false,
            }),
          }, router);
          expect(superUpdateResponse['statusCode'], equals(200));
          final superUpdateBody =
              jsonDecode(superUpdateResponse['body'] as String)
                  as Map<String, dynamic>;
          expect(superUpdateBody['projectId'], equals(projectId));
          expect(superUpdateBody['publicId'], equals('super-project-id'));
          expect(superUpdateBody['teamName'], equals('Super Team Updated'));
          expect(superUpdateBody['status'], equals('approved'));
          expect(superUpdateBody['deleted'], isFalse);
        },
      );

      test(
        'DELETE /api/super/admin/project/{projectId} soft deletes the project',
        () async {
          final registerResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{},
            'body': jsonEncode({
              'userId': 'project-deleter',
              'name': 'Project Deleter',
              'dateOfBirth': '1990-01-01',
              'email': 'deleter@example.com',
              'password': 'secret123',
            }),
          }, router);
          expect(registerResponse['statusCode'], equals(200));

          final verifyResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/verify-email',
            'headers': <String, String>{},
            'body': jsonEncode({
              'email': 'deleter@example.com',
              'code': emailSender.codes['deleter@example.com']!.single,
            }),
          }, router);
          expect(verifyResponse['statusCode'], equals(200));
          final verifyBody =
              jsonDecode(verifyResponse['body'] as String)
                  as Map<String, dynamic>;
          final accessToken = verifyBody['accessToken'] as String;

          final createResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/project',
            'headers': <String, String>{'authorization': 'Bearer $accessToken'},
            'body': jsonEncode({
              'publicId': 'deleter-project-id',
              'teamName': 'Deleter Team',
              'signLanguage': 'ASL',
            }),
          }, router);
          expect(createResponse['statusCode'], equals(200));
          final createBody =
              jsonDecode(createResponse['body'] as String)
                  as Map<String, dynamic>;
          final projectId = createBody['projectId'] as String;

          final deleteResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'DELETE',
            'path': '/api/super/admin/project/$projectId',
            'headers': <String, String>{'authorization': 'Bearer $accessToken'},
          }, router);
          expect(deleteResponse['statusCode'], equals(200));
          final deleteBody =
              jsonDecode(deleteResponse['body'] as String)
                  as Map<String, dynamic>;
          expect(deleteBody['projectId'], equals(projectId));
          expect(deleteBody['deleted'], isTrue);

          final projectState = await storage.getEntityState(
            domainType: kDomainProject,
            domainId: projectId,
            entityType: kEntityTypeProject,
            entityId: projectId,
          );
          expect(projectState, isNotNull);
          expect(
            projectState?.toJson()['data_deleted'] ??
                projectState?.toJson()['deleted'],
            isTrue,
          );
        },
      );

      test('refresh rotates refresh token and invalidates old token', () async {
        final registerResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/register',
          'headers': <String, String>{},
          'body': jsonEncode({
            'userId': 'user-jane',
            'name': 'Jane Doe',
            'dateOfBirth': '1990-06-15',
            'email': 'jane@example.com',
            'password': 'secret123',
          }),
        }, router);

        expect(registerResponse['statusCode'], equals(200));

        final verifyResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/verify-email',
          'headers': <String, String>{},
          'body': jsonEncode({
            'email': 'jane@example.com',
            'code': emailSender.codes['jane@example.com']!.single,
          }),
        }, router);

        expect(verifyResponse['statusCode'], equals(200));
        final verifyBody =
            jsonDecode(verifyResponse['body'] as String)
                as Map<String, dynamic>;
        final originalRefreshToken = verifyBody['refreshToken'] as String;

        final refreshResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/refresh',
          'headers': <String, String>{},
          'body': jsonEncode({'refreshToken': originalRefreshToken}),
        }, router);

        expect(refreshResponse['statusCode'], equals(200));
        final refreshBody =
            jsonDecode(refreshResponse['body'] as String)
                as Map<String, dynamic>;
        final rotatedRefreshToken = refreshBody['refreshToken'] as String;
        expect(rotatedRefreshToken, isNot(equals(originalRefreshToken)));

        final oldRefreshRetry = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/refresh',
          'headers': <String, String>{},
          'body': jsonEncode({'refreshToken': originalRefreshToken}),
        }, router);

        expect(oldRefreshRetry['statusCode'], equals(401));

        final newRefreshRetry = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/refresh',
          'headers': <String, String>{},
          'body': jsonEncode({'refreshToken': rotatedRefreshToken}),
        }, router);

        expect(newRefreshRetry['statusCode'], equals(200));
      });

      test('resend invalidates previous code', () async {
        await authService.register(
          RegisterRequest(
            userId: 'user-jane',
            name: 'Jane Doe',
            dateOfBirth: '1990-06-15',
            email: 'jane@example.com',
            password: 'secret123',
          ),
        );
        final firstCode = emailSender.codes['jane@example.com']!.last;

        final resendResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/resend-verification-code',
          'headers': <String, String>{'x-forwarded-for': '203.0.113.20'},
          'body': jsonEncode({'email': 'jane@example.com'}),
        }, router);
        expect(resendResponse['statusCode'], equals(200));
        final secondCode = emailSender.codes['jane@example.com']!.last;
        expect(secondCode, isNot(equals(firstCode)));
        final challenge = await recordStore.getEmailChallenge('user-jane');
        expect(challenge?.resendCount, equals(1));

        final oldVerifyResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/verify-email',
          'headers': <String, String>{},
          'body': jsonEncode({'email': 'jane@example.com', 'code': firstCode}),
        }, router);
        expect(oldVerifyResponse['statusCode'], equals(400));
      });

      test(
        'verify invalidates challenge after max failed code attempts and resend issues a new challenge',
        () async {
          await authService.register(
            RegisterRequest(
              userId: 'user-jane',
              name: 'Jane Doe',
              dateOfBirth: '1990-06-15',
              email: 'jane@example.com',
              password: 'secret123',
            ),
          );

          final firstCode = emailSender.codes['jane@example.com']!.single;

          for (var attempt = 0; attempt < 5; attempt++) {
            final invalidVerifyResponse = await server.handleApiGatewayEvent({
              'httpMethod': 'POST',
              'path': '/api/auth/verify-email',
              'headers': <String, String>{},
              'body': jsonEncode({
                'email': 'jane@example.com',
                'code': '000000',
              }),
            }, router);
            expect(invalidVerifyResponse['statusCode'], equals(400));
          }

          final challengeAfterFailures = await recordStore.getEmailChallenge(
            'user-jane',
          );
          expect(challengeAfterFailures, isNull);

          final resendResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/resend-verification-code',
            'headers': <String, String>{},
            'body': jsonEncode({'email': 'jane@example.com'}),
          }, router);
          expect(resendResponse['statusCode'], equals(200));

          final allCodes = emailSender.codes['jane@example.com']!;
          expect(allCodes, hasLength(2));
          final secondCode = allCodes.last;
          expect(secondCode, isNot(equals(firstCode)));

          final verifyWithNewCode = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/verify-email',
            'headers': <String, String>{},
            'body': jsonEncode({
              'email': 'jane@example.com',
              'code': secondCode,
            }),
          }, router);
          expect(verifyWithNewCode['statusCode'], equals(200));
        },
      );

      test('register clamps verification emails after three sends', () async {
        for (var attempt = 0; attempt < 4; attempt++) {
          final response = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{
              'x-forwarded-for': '203.0.113.${50 + attempt}',
            },
            'body': jsonEncode({
              'userId': 'user-jane',
              'name': 'Jane Doe',
              'dateOfBirth': '1990-06-15',
              'email': 'jane@example.com',
              'password': 'secret123',
            }),
          }, router);

          expect(response['statusCode'], equals(200));
        }

        expect(emailSender.codes['jane@example.com'], hasLength(3));
        final challenge = await recordStore.getEmailChallenge('user-jane');
        expect(challenge?.resendCount, equals(2));

        final principal = await recordStore.getPrincipalByUserId('user-jane');
        expect(
          principal?.registrationOutcome_last_,
          equals('register_existing_pending_same_user'),
        );
        expect(principal?.registrationSourceIp_last_, equals('203.0.113.53'));
      });

      test('resend clamps verification emails after three sends', () async {
        final registerResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/register',
          'headers': <String, String>{'x-forwarded-for': '203.0.113.60'},
          'body': jsonEncode({
            'userId': 'user-jane',
            'name': 'Jane Doe',
            'dateOfBirth': '1990-06-15',
            'email': 'jane@example.com',
            'password': 'secret123',
          }),
        }, router);

        expect(registerResponse['statusCode'], equals(200));

        for (var attempt = 0; attempt < 3; attempt++) {
          final resendResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/resend-verification-code',
            'headers': <String, String>{
              'x-forwarded-for': '203.0.113.${61 + attempt}',
            },
            'body': jsonEncode({'email': 'jane@example.com'}),
          }, router);

          expect(resendResponse['statusCode'], equals(200));
        }

        expect(emailSender.codes['jane@example.com'], hasLength(3));
        final challenge = await recordStore.getEmailChallenge('user-jane');
        expect(challenge?.resendCount, equals(2));
      });

      test(
        'register stays neutral when email belongs to another userId',
        () async {
          final firstRegister = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{'x-forwarded-for': '203.0.113.30'},
            'body': jsonEncode({
              'userId': 'user-jane',
              'name': 'Jane Doe',
              'dateOfBirth': '1990-06-15',
              'email': 'jane@example.com',
              'password': 'secret123',
            }),
          }, router);

          expect(firstRegister['statusCode'], equals(200));
          expect(emailSender.codes['jane@example.com'], hasLength(1));

          final secondRegister = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{'x-forwarded-for': '203.0.113.31'},
            'body': jsonEncode({
              'userId': 'different-user',
              'name': 'Jane Clone',
              'dateOfBirth': '1991-06-15',
              'email': 'jane@example.com',
              'password': 'secret456',
            }),
          }, router);

          expect(secondRegister['statusCode'], equals(200));
          final secondBody =
              jsonDecode(secondRegister['body'] as String)
                  as Map<String, dynamic>;
          expect(secondBody['status'], equals('pending_verification'));
          expect(
            await recordStore.getPrincipalByUserId('different-user'),
            isNull,
          );
          expect(emailSender.codes['jane@example.com'], hasLength(1));
          final principal = await recordStore.getPrincipalByUserId('user-jane');
          expect(
            principal?.registrationOutcome_last_,
            equals('register_existing_email_different_user'),
          );
          expect(principal?.registrationSourceIp_last_, equals('203.0.113.31'));
        },
      );

      test(
        'register reclaims stale pending email for a different userId',
        () async {
          final firstRegister = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{'x-forwarded-for': '203.0.113.32'},
            'body': jsonEncode({
              'userId': 'user-jane',
              'name': 'Jane Doe',
              'dateOfBirth': '1990-06-15',
              'email': 'jane@example.com',
              'password': 'secret123',
            }),
          }, router);

          expect(firstRegister['statusCode'], equals(200));
          expect(emailSender.codes['jane@example.com'], hasLength(1));

          final firstChallenge = await recordStore.getEmailChallenge(
            'user-jane',
          );
          expect(firstChallenge, isNotNull);
          await recordStore.putEmailChallenge(
            firstChallenge!.copyWith(
              expiresAt: DateTime.now().toUtc().subtract(
                const Duration(minutes: 1),
              ),
            ),
          );

          final secondRegister = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{'x-forwarded-for': '203.0.113.33'},
            'body': jsonEncode({
              'userId': 'different-user',
              'name': 'Jane Reclaim',
              'dateOfBirth': '1991-06-15',
              'email': 'jane@example.com',
              'password': 'secret456',
            }),
          }, router);

          expect(secondRegister['statusCode'], equals(200));
          final secondBody =
              jsonDecode(secondRegister['body'] as String)
                  as Map<String, dynamic>;
          expect(secondBody['status'], equals('pending_verification'));

          final reclaimedPrincipal = await recordStore.getPrincipalByUserId(
            'different-user',
          );
          expect(reclaimedPrincipal, isNotNull);
          expect(reclaimedPrincipal?.email, equals('jane@example.com'));
          expect(
            reclaimedPrincipal?.registrationOutcome_last_,
            equals('register_reclaimed_stale_pending_email_different_user'),
          );
          expect(
            reclaimedPrincipal?.registrationSourceIp_last_,
            equals('203.0.113.33'),
          );
          expect(emailSender.codes['jane@example.com'], hasLength(2));

          final stalePrincipal = await recordStore.getPrincipalByUserId(
            'user-jane',
          );
          expect(stalePrincipal, isNotNull);
          expect(stalePrincipal?.emailVerified, isFalse);
        },
      );

      test(
        'register stays neutral when userId belongs to another email',
        () async {
          final firstRegister = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{'x-forwarded-for': '203.0.113.40'},
            'body': jsonEncode({
              'userId': 'user-jane',
              'name': 'Jane Doe',
              'dateOfBirth': '1990-06-15',
              'email': 'jane@example.com',
              'password': 'secret123',
            }),
          }, router);

          expect(firstRegister['statusCode'], equals(200));

          final secondRegister = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{'x-forwarded-for': '203.0.113.41'},
            'body': jsonEncode({
              'userId': 'user-jane',
              'name': 'Jane Doe',
              'dateOfBirth': '1990-06-15',
              'email': 'other@example.com',
              'password': 'secret456',
            }),
          }, router);

          expect(secondRegister['statusCode'], equals(200));
          final secondBody =
              jsonDecode(secondRegister['body'] as String)
                  as Map<String, dynamic>;
          expect(secondBody['status'], equals('pending_verification'));
          expect(emailSender.codes.containsKey('other@example.com'), isFalse);

          final principal = await recordStore.getPrincipalByUserId('user-jane');
          expect(principal?.email, equals('jane@example.com'));
          expect(principal?.normalizedEmail, equals('jane@example.com'));
          expect(
            principal?.registrationOutcome_last_,
            equals('register_existing_user_different_email'),
          );
          expect(principal?.registrationSourceIp_last_, equals('203.0.113.41'));
        },
      );

      test('resend stays neutral when email does not exist', () async {
        final resendResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/resend-verification-code',
          'headers': <String, String>{},
          'body': jsonEncode({'email': 'missing@example.com'}),
        }, router);

        expect(resendResponse['statusCode'], equals(200));
        final resendBody =
            jsonDecode(resendResponse['body'] as String)
                as Map<String, dynamic>;
        expect(resendBody['status'], equals('sent'));
        expect(emailSender.codes.containsKey('missing@example.com'), isFalse);
      });

      test(
        'verify logs challenge_not_found when challenge is missing',
        () async {
          await authService.register(
            RegisterRequest(
              userId: 'user-jane',
              name: 'Jane Doe',
              dateOfBirth: '1990-06-15',
              email: 'jane@example.com',
              password: 'secret123',
            ),
          );

          await recordStore.deleteEmailChallenge('user-jane');

          final verifyResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/verify-email',
            'headers': <String, String>{'x-forwarded-for': '203.0.113.80'},
            'body': jsonEncode({
              'email': 'jane@example.com',
              'code': emailSender.codes['jane@example.com']!.single,
            }),
          }, router);

          expect(verifyResponse['statusCode'], equals(400));
          expect(
            responseBody(verifyResponse)['code'],
            equals('invalid_or_expired_code'),
          );

          final event = authEventPayload('verify_invalid_code');
          expect(event['detail'], equals('challenge_not_found'));
        },
      );

      test('verify logs challenge_expired when challenge is expired', () async {
        await authService.register(
          RegisterRequest(
            userId: 'user-jane',
            name: 'Jane Doe',
            dateOfBirth: '1990-06-15',
            email: 'jane@example.com',
            password: 'secret123',
          ),
        );

        final challenge = await recordStore.getEmailChallenge('user-jane');
        expect(challenge, isNotNull);
        await recordStore.putEmailChallenge(
          challenge!.copyWith(
            expiresAt: DateTime.now().toUtc().subtract(
              const Duration(minutes: 1),
            ),
          ),
        );

        final verifyResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/verify-email',
          'headers': <String, String>{'x-forwarded-for': '203.0.113.81'},
          'body': jsonEncode({
            'email': 'jane@example.com',
            'code': emailSender.codes['jane@example.com']!.single,
          }),
        }, router);

        expect(verifyResponse['statusCode'], equals(400));
        expect(
          responseBody(verifyResponse)['code'],
          equals('invalid_or_expired_code'),
        );

        final event = authEventPayload('verify_invalid_code');
        expect(event['detail'], equals('challenge_expired'));
      });

      test(
        'register returns validation details and logs invalid request',
        () async {
          final response = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{'x-forwarded-for': '203.0.113.70'},
            'body': jsonEncode({
              'name': 'Jane Doe',
              'dateOfBirth': '1990-06-15',
              'email': 'jane@example.com',
              'password': 'secret123',
            }),
          }, router);

          expect(response['statusCode'], equals(400));
          expect(
            responseBody(response),
            equals({
              'error': 'Unable to complete this action',
              'code': 'invalid_request',
              'details': {'userId': 'required'},
            }),
          );

          final event = authEventPayload('register_invalid_request');
          expect(event['detail'], equals('invalid_fields'));
          expect(event['validationDetails'], equals({'userId': 'required'}));
        },
      );

      test('register validates full field rules with shared codes', () async {
        final response = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/auth/register',
          'headers': <String, String>{'x-forwarded-for': '203.0.113.82'},
          'body': jsonEncode({
            'userId': 'user-jane',
            'name': 'J',
            'dateOfBirth': 'not-a-date',
            'email': 'not-an-email',
            'password': '1234567',
          }),
        }, router);

        expect(response['statusCode'], equals(400));
        expect(
          responseBody(response),
          equals({
            'error': 'Unable to complete this action',
            'code': 'invalid_request',
            'details': {
              'name': 'min_length',
              'email': 'invalid_email_format',
              'dateOfBirth': 'invalid_date_format',
              'password': 'password_too_weak',
            },
          }),
        );

        final event = authEventPayload('register_invalid_request');
        expect(event['detail'], equals('invalid_fields'));
        expect(
          event['validationDetails'],
          equals({
            'name': 'min_length',
            'email': 'invalid_email_format',
            'dateOfBirth': 'invalid_date_format',
            'password': 'password_too_weak',
          }),
        );
      });

      test(
        'register rejects leading and trailing whitespace in strict mode',
        () async {
          final response = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/register',
            'headers': <String, String>{'x-forwarded-for': '203.0.113.83'},
            'body': jsonEncode({
              'userId': ' user-jane',
              'name': 'Jane Doe ',
              'dateOfBirth': '1990-06-15',
              'email': 'jane@example.com ',
              'password': 'secret123',
            }),
          }, router);

          expect(response['statusCode'], equals(400));
          expect(
            responseBody(response),
            equals({
              'error': 'Unable to complete this action',
              'code': 'invalid_request',
              'details': {
                'userId': 'leading_or_trailing_whitespace',
                'name': 'leading_or_trailing_whitespace',
                'email': 'leading_or_trailing_whitespace',
              },
            }),
          );

          final event = authEventPayload('register_invalid_request');
          expect(event['detail'], equals('invalid_fields'));
          expect(
            event['validationDetails'],
            equals({
              'userId': 'leading_or_trailing_whitespace',
              'name': 'leading_or_trailing_whitespace',
              'email': 'leading_or_trailing_whitespace',
            }),
          );
        },
      );

      test(
        'verify returns validation details and logs invalid request',
        () async {
          final response = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/verify-email',
            'headers': <String, String>{'x-forwarded-for': '203.0.113.71'},
            'body': jsonEncode({'email': 'jane@example.com'}),
          }, router);

          expect(response['statusCode'], equals(400));
          expect(
            responseBody(response),
            equals({
              'error': 'Unable to complete this action',
              'code': 'invalid_request',
              'details': {'code': 'required'},
            }),
          );

          final event = authEventPayload('verify_invalid_request');
          expect(event['detail'], equals('missing_required_fields'));
          expect(event['validationDetails'], equals({'code': 'required'}));
        },
      );

      test(
        'resend returns validation details and logs invalid request',
        () async {
          final response = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/resend-verification-code',
            'headers': <String, String>{'x-forwarded-for': '203.0.113.72'},
            'body': jsonEncode({}),
          }, router);

          expect(response['statusCode'], equals(400));
          expect(
            responseBody(response),
            equals({
              'error': 'Unable to complete this action',
              'code': 'invalid_request',
              'details': {'email': 'required'},
            }),
          );

          final event = authEventPayload('resend_invalid_request');
          expect(event['detail'], equals('missing_required_fields'));
          expect(event['validationDetails'], equals({'email': 'required'}));
        },
      );

      test(
        'login returns validation details and logs invalid request',
        () async {
          final response = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/login',
            'headers': <String, String>{'x-forwarded-for': '203.0.113.73'},
            'body': jsonEncode({'identifier': 'jane@example.com'}),
          }, router);

          expect(response['statusCode'], equals(400));
          expect(
            responseBody(response),
            equals({
              'error': 'Unable to complete this action',
              'code': 'invalid_request',
              'details': {'password': 'required'},
            }),
          );

          final event = authEventPayload('login_invalid_request');
          expect(event['detail'], equals('missing_required_fields'));
          expect(event['validationDetails'], equals({'password': 'required'}));
        },
      );

      test(
        'refresh returns validation details and logs invalid request',
        () async {
          final response = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/auth/refresh',
            'headers': <String, String>{'x-forwarded-for': '203.0.113.74'},
            'body': jsonEncode({}),
          }, router);

          expect(response['statusCode'], equals(400));
          expect(
            responseBody(response),
            equals({
              'error': 'Unable to complete this action',
              'code': 'invalid_request',
              'details': {'refreshToken': 'required'},
            }),
          );

          final event = authEventPayload('refresh_invalid_request');
          expect(event['detail'], equals('missing_required_fields'));
          expect(
            event['validationDetails'],
            equals({'refreshToken': 'required'}),
          );
        },
      );
    });

    group('admin-adhoc-user-registration', () {
      test('admin can create adhoc user', () async {
        final adminResponse = await authService.register(
          RegisterRequest(
            userId: 'admin-user',
            name: 'Admin User',
            dateOfBirth: '1980-01-01',
            email: 'admin@example.com',
            password: 'admin-pass',
          ),
        );
        expect(adminResponse.status, equals('pending_verification'));
        final adminVerify = await authService.verifyEmail(
          VerifyEmailRequest(
            email: 'admin@example.com',
            code: emailSender.codes['admin@example.com']!.last,
          ),
        );
        final adminUserId = adminVerify.userId;

        await storage.testStoreState(
          entityState: DynamoEntityState.fromJson({
            'entityId': adminUserId,
            'entityType': kEntityTypeMember,
            'domainType': kDomainMembership,
            'unknownJson': '{}',
            'change_domainId': 'project-1',
            'change_domainId_orig_': 'project-1',
            'change_changeAt': DateTime.now().toUtc().toIso8601String(),
            'change_changeAt_orig_': DateTime.now().toUtc().toIso8601String(),
            'change_cid': 'admin-member',
            'change_cid_orig_': 'admin-member',
            'change_changeBy': 'seed',
            'change_changeBy_orig_': 'seed',
            'change_storedAt': DateTime.now().toUtc().toIso8601String(),
            'change_storedAt_orig_': DateTime.now().toUtc().toIso8601String(),
            'data_parentId': kDomainEntityRootParentId,
            'data_parentId_changeAt_': DateTime.now().toUtc().toIso8601String(),
            'data_parentId_cid_': 'admin-member',
            'data_parentId_changeBy_': 'seed',
            'data_parentProp': kCollectionMembership,
            'data_parentProp_changeAt_': DateTime.now()
                .toUtc()
                .toIso8601String(),
            'data_parentProp_cid_': 'admin-member',
            'data_parentProp_changeBy_': 'seed',
            'role': 'admin',
            'userId': adminUserId,
          }),
        );

        final createResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/admin/adhoc-users',
          'headers': <String, String>{
            'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
          },
          'body': jsonEncode({
            'userId': 'adhoc-local-user',
            'name': 'Local User',
            'username': 'localuser123',
            'password': 'secret123',
            'projectIds': ['project-1'],
            'adminPassword': 'admin-pass',
          }),
        }, router);

        expect(createResponse['statusCode'], equals(201));
        final createBody =
            jsonDecode(createResponse['body'] as String)
                as Map<String, dynamic>;
        expect(createBody['username'], equals('localuser123'));

        final listResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'GET',
          'path': '/api/admin/adhoc-users',
          'headers': <String, String>{
            'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
          },
        }, router);
        expect(listResponse['statusCode'], equals(200));
        final listBody =
            jsonDecode(listResponse['body'] as String) as Map<String, dynamic>;
        expect((listBody['items'] as List<dynamic>).length, equals(1));
      });

      test(
        'GET /api/super/admin/adhoc-users returns all adhoc users',
        () async {
          final adminResponse = await authService.register(
            RegisterRequest(
              userId: 'admin-user',
              name: 'Admin User',
              dateOfBirth: '1980-01-01',
              email: 'admin@example.com',
              password: 'admin-pass',
            ),
          );
          expect(adminResponse.status, equals('pending_verification'));
          final adminVerify = await authService.verifyEmail(
            VerifyEmailRequest(
              email: 'admin@example.com',
              code: emailSender.codes['admin@example.com']!.last,
            ),
          );
          final adminUserId = adminVerify.userId;

          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': adminUserId,
              'entityType': kEntityTypeMember,
              'domainType': kDomainMembership,
              'unknownJson': '{}',
              'change_domainId': 'project-1',
              'change_domainId_orig_': 'project-1',
              'change_changeAt': DateTime.now().toUtc().toIso8601String(),
              'change_changeAt_orig_': DateTime.now().toUtc().toIso8601String(),
              'change_cid': 'admin-member',
              'change_cid_orig_': 'admin-member',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': DateTime.now().toUtc().toIso8601String(),
              'change_storedAt_orig_': DateTime.now().toUtc().toIso8601String(),
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': DateTime.now()
                  .toUtc()
                  .toIso8601String(),
              'data_parentId_cid_': 'admin-member',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionMembership,
              'data_parentProp_changeAt_': DateTime.now()
                  .toUtc()
                  .toIso8601String(),
              'data_parentProp_cid_': 'admin-member',
              'data_parentProp_changeBy_': 'seed',
              'role': 'admin',
              'userId': adminUserId,
            }),
          );

          final now = DateTime.now().toUtc();
          await recordStore.putPrincipal(
            UsernameAuthPrincipal(
              userId: 'adhoc-secondary-user',
              username: 'adhocsecondary',
              normalizedUsername: 'adhocsecondary',
              passwordHash: 'hash',
              passwordSalt: 'salt',
              passwordIterations: 1000,
              accountStatus: AuthAccountStatus.active,
              emailVerified: true,
              isAdHoc: true,
              displayName: 'Adhoc Secondary',
              assignedProjectIds: const <String>['project-2'],
              verificationVersion: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );

          final createResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/admin/adhoc-users',
            'headers': <String, String>{
              'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
            },
            'body': jsonEncode({
              'userId': 'adhoc-local-user',
              'name': 'Local User',
              'username': 'localuser123',
              'password': 'secret123',
              'projectIds': ['project-1'],
              'adminPassword': 'admin-pass',
            }),
          }, router);
          expect(createResponse['statusCode'], equals(201));

          final adminListResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'GET',
            'path': '/api/admin/adhoc-users',
            'headers': <String, String>{
              'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
            },
          }, router);
          expect(adminListResponse['statusCode'], equals(200));
          final adminListBody =
              jsonDecode(adminListResponse['body'] as String)
                  as Map<String, dynamic>;
          expect((adminListBody['items'] as List<dynamic>).length, equals(1));

          final superListResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'GET',
            'path': '/api/super/admin/adhoc-users',
            'headers': <String, String>{
              'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
            },
          }, router);
          expect(superListResponse['statusCode'], equals(200));
          final superListBody =
              jsonDecode(superListResponse['body'] as String)
                  as Map<String, dynamic>;
          expect((superListBody['items'] as List<dynamic>).length, equals(2));
        },
      );

      test(
        'POST /api/admin/adhoc-users/<userId>/reset-password updates password',
        () async {
          final adminResponse = await authService.register(
            RegisterRequest(
              userId: 'admin-user',
              name: 'Admin User',
              dateOfBirth: '1980-01-01',
              email: 'admin@example.com',
              password: 'admin-pass',
            ),
          );
          expect(adminResponse.status, equals('pending_verification'));
          final adminVerify = await authService.verifyEmail(
            VerifyEmailRequest(
              email: 'admin@example.com',
              code: emailSender.codes['admin@example.com']!.last,
            ),
          );
          final adminUserId = adminVerify.userId;

          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': adminUserId,
              'entityType': kEntityTypeMember,
              'domainType': kDomainMembership,
              'unknownJson': '{}',
              'change_domainId': 'project-1',
              'change_domainId_orig_': 'project-1',
              'change_changeAt': DateTime.now().toUtc().toIso8601String(),
              'change_changeAt_orig_': DateTime.now().toUtc().toIso8601String(),
              'change_cid': 'admin-member',
              'change_cid_orig_': 'admin-member',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': DateTime.now().toUtc().toIso8601String(),
              'change_storedAt_orig_': DateTime.now().toUtc().toIso8601String(),
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': DateTime.now()
                  .toUtc()
                  .toIso8601String(),
              'data_parentId_cid_': 'admin-member',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionMembership,
              'data_parentProp_changeAt_': DateTime.now()
                  .toUtc()
                  .toIso8601String(),
              'data_parentProp_cid_': 'admin-member',
              'data_parentProp_changeBy_': 'seed',
              'role': 'admin',
              'userId': adminUserId,
            }),
          );

          final createResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/admin/adhoc-users',
            'headers': <String, String>{
              'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
            },
            'body': jsonEncode({
              'userId': 'adhoc-local-user',
              'name': 'Local User',
              'username': 'localuser123',
              'password': 'secret123',
              'projectIds': ['project-1'],
              'adminPassword': 'admin-pass',
            }),
          }, router);
          expect(createResponse['statusCode'], equals(201));

          final beforePrincipal = await recordStore.getPrincipalByUserId(
            'adhoc-local-user',
          );
          expect(beforePrincipal, isNotNull);
          final beforeHash = beforePrincipal!.passwordHash;

          final resetResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/admin/adhoc-users/adhoc-local-user/reset-password',
            'headers': <String, String>{
              'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
            },
            'body': jsonEncode({
              'adminPassword': 'admin-pass',
              'newPassword': 'new-secret-123',
            }),
          }, router);
          expect(resetResponse['statusCode'], equals(200));
          final resetBody =
              jsonDecode(resetResponse['body'] as String)
                  as Map<String, dynamic>;
          expect(resetBody['status'], equals('password_updated'));

          final afterPrincipal = await recordStore.getPrincipalByUserId(
            'adhoc-local-user',
          );
          expect(afterPrincipal, isNotNull);
          expect(afterPrincipal!.passwordHash, isNot(equals(beforeHash)));
        },
      );

      test('rejects adhoc creation with admin project role', () async {
        final adminResponse = await authService.register(
          RegisterRequest(
            userId: 'admin-user',
            name: 'Admin User',
            dateOfBirth: '1980-01-01',
            email: 'admin@example.com',
            password: 'admin-pass',
          ),
        );
        expect(adminResponse.status, equals('pending_verification'));
        final adminVerify = await authService.verifyEmail(
          VerifyEmailRequest(
            email: 'admin@example.com',
            code: emailSender.codes['admin@example.com']!.last,
          ),
        );
        final adminUserId = adminVerify.userId;

        await storage.testStoreState(
          entityState: DynamoEntityState.fromJson({
            'entityId': adminUserId,
            'entityType': kEntityTypeMember,
            'domainType': kDomainMembership,
            'unknownJson': '{}',
            'change_domainId': 'project-1',
            'change_domainId_orig_': 'project-1',
            'change_changeAt': DateTime.now().toUtc().toIso8601String(),
            'change_changeAt_orig_': DateTime.now().toUtc().toIso8601String(),
            'change_cid': 'admin-member',
            'change_cid_orig_': 'admin-member',
            'change_changeBy': 'seed',
            'change_changeBy_orig_': 'seed',
            'change_storedAt': DateTime.now().toUtc().toIso8601String(),
            'change_storedAt_orig_': DateTime.now().toUtc().toIso8601String(),
            'data_parentId': kDomainEntityRootParentId,
            'data_parentId_changeAt_': DateTime.now().toUtc().toIso8601String(),
            'data_parentId_cid_': 'admin-member',
            'data_parentId_changeBy_': 'seed',
            'data_parentProp': kCollectionMembership,
            'data_parentProp_changeAt_': DateTime.now()
                .toUtc()
                .toIso8601String(),
            'data_parentProp_cid_': 'admin-member',
            'data_parentProp_changeBy_': 'seed',
            'role': 'admin',
            'userId': adminUserId,
          }),
        );

        final createResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/admin/adhoc-users',
          'headers': <String, String>{
            'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
          },
          'body': jsonEncode({
            'userId': 'adhoc-admin-role-user',
            'name': 'Admin Role User',
            'username': 'adminroleuser123',
            'password': 'secret123',
            'projectIds': ['project-1'],
            'projectRoles': {'project-1': MemberType.admin.name},
            'adminPassword': 'admin-pass',
          }),
        }, router);

        expect(createResponse['statusCode'], equals(400));
        final body =
            jsonDecode(createResponse['body'] as String)
                as Map<String, dynamic>;
        expect(body['code'], equals('invalid_request'));
      });

      test('rejects adhoc username with punctuation', () async {
        final adminResponse = await authService.register(
          RegisterRequest(
            userId: 'admin-user',
            name: 'Admin User',
            dateOfBirth: '1980-01-01',
            email: 'admin@example.com',
            password: 'admin-pass',
          ),
        );
        expect(adminResponse.status, equals('pending_verification'));
        final adminVerify = await authService.verifyEmail(
          VerifyEmailRequest(
            email: 'admin@example.com',
            code: emailSender.codes['admin@example.com']!.last,
          ),
        );
        final adminUserId = adminVerify.userId;

        await storage.testStoreState(
          entityState: DynamoEntityState.fromJson({
            'entityId': adminUserId,
            'entityType': kEntityTypeMember,
            'domainType': kDomainMembership,
            'unknownJson': '{}',
            'change_domainId': 'project-1',
            'change_domainId_orig_': 'project-1',
            'change_changeAt': DateTime.now().toUtc().toIso8601String(),
            'change_changeAt_orig_': DateTime.now().toUtc().toIso8601String(),
            'change_cid': 'admin-member',
            'change_cid_orig_': 'admin-member',
            'change_changeBy': 'seed',
            'change_changeBy_orig_': 'seed',
            'change_storedAt': DateTime.now().toUtc().toIso8601String(),
            'change_storedAt_orig_': DateTime.now().toUtc().toIso8601String(),
            'data_parentId': kDomainEntityRootParentId,
            'data_parentId_changeAt_': DateTime.now().toUtc().toIso8601String(),
            'data_parentId_cid_': 'admin-member',
            'data_parentId_changeBy_': 'seed',
            'data_parentProp': kCollectionMembership,
            'data_parentProp_changeAt_': DateTime.now()
                .toUtc()
                .toIso8601String(),
            'data_parentProp_cid_': 'admin-member',
            'data_parentProp_changeBy_': 'seed',
            'role': 'admin',
            'userId': adminUserId,
          }),
        );

        final createResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/admin/adhoc-users',
          'headers': <String, String>{
            'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
          },
          'body': jsonEncode({
            'userId': 'adhoc-local-user',
            'name': 'Local User',
            'username': 'local.user123',
            'password': 'secret123',
            'projectIds': ['project-1'],
            'adminPassword': 'admin-pass',
          }),
        }, router);

        expect(createResponse['statusCode'], equals(400));
        final body =
            jsonDecode(createResponse['body'] as String)
                as Map<String, dynamic>;
        expect(body['code'], equals('invalid_request'));
        expect(
          body['details'],
          equals({
            RegistrationValidationField.username:
                RegistrationValidationErrorCode.invalidUsernameFormat,
          }),
        );
      });

      test(
        'resend throws when email lookup resolves to username principal',
        () async {
          final now = DateTime.now().toUtc();
          await recordStore.putPrincipal(
            UsernameAuthPrincipal(
              userId: 'broken-user',
              username: 'broken.user',
              normalizedUsername: 'broken.user',
              passwordHash: 'hash',
              passwordSalt: 'salt',
              passwordIterations: 1000,
              accountStatus: AuthAccountStatus.pendingVerification,
              emailVerified: false,
              isAdHoc: false,
              displayName: 'Broken User',
              assignedProjectIds: const <String>[],
              verificationVersion: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
          await recordStore.putEmailLookup('broken@example.com', 'broken-user');

          expect(
            () => authService.resendVerificationCode(
              ResendVerificationCodeRequest(email: 'broken@example.com'),
            ),
            throwsA(isA<StateError>()),
          );
        },
      );

      test(
        'list ignores email principals incorrectly flagged as adhoc',
        () async {
          final adminHash = await PasswordHashService(
            iterations: 1000,
          ).hashPassword('admin-pass');
          final now = DateTime.now().toUtc();
          await recordStore.putPrincipal(
            EmailAuthPrincipal(
              userId: 'admin-user',
              email: 'admin@example.com',
              normalizedEmail: 'admin@example.com',
              passwordHash: adminHash.hash,
              passwordSalt: adminHash.salt,
              passwordIterations: adminHash.iterations,
              accountStatus: AuthAccountStatus.active,
              emailVerified: true,
              isAdHoc: false,
              displayName: 'Admin User',
              assignedProjectIds: const <String>[],
              verificationVersion: 0,
              createdAt: now,
              updatedAt: now,
              verifiedAt: now,
            ),
          );
          await recordStore.putPrincipal(
            EmailAuthPrincipal(
              userId: 'broken-adhoc',
              email: 'broken-adhoc@example.com',
              normalizedEmail: 'broken-adhoc@example.com',
              passwordHash: 'hash',
              passwordSalt: 'salt',
              passwordIterations: 1000,
              accountStatus: AuthAccountStatus.active,
              emailVerified: true,
              isAdHoc: true,
              displayName: 'Broken Adhoc',
              assignedProjectIds: const <String>['project-1'],
              verificationVersion: 0,
              createdAt: now,
              updatedAt: now,
              verifiedAt: now,
            ),
          );

          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': 'admin-user',
              'entityType': kEntityTypeMember,
              'domainType': kDomainMembership,
              'unknownJson': '{}',
              'change_domainId': 'project-1',
              'change_domainId_orig_': 'project-1',
              'change_changeAt': now.toIso8601String(),
              'change_changeAt_orig_': now.toIso8601String(),
              'change_cid': 'admin-member',
              'change_cid_orig_': 'admin-member',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': now.toIso8601String(),
              'change_storedAt_orig_': now.toIso8601String(),
              'data_parentId': '',
              'data_parentId_changeAt_': now.toIso8601String(),
              'data_parentId_cid_': 'admin-member',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionMembership,
              'data_parentProp_changeAt_': now.toIso8601String(),
              'data_parentProp_cid_': 'admin-member',
              'data_parentProp_changeBy_': 'seed',
              'role': 'admin',
              'userId': 'admin-user',
            }),
          );

          final response = await authService.listAdHocUsers(
            session: const AuthenticatedSession(
              userId: 'admin-user',
              sessionId: 'session-1',
              isAdHoc: false,
              emailVerified: true,
            ),
          );

          expect(response.items, isEmpty);
        },
      );

      test(
        'update adhoc projects rejects email principal incorrectly flagged as adhoc',
        () async {
          final adminHash = await PasswordHashService(
            iterations: 1000,
          ).hashPassword('admin-pass');
          final now = DateTime.now().toUtc();
          await recordStore.putPrincipal(
            EmailAuthPrincipal(
              userId: 'admin-user',
              email: 'admin@example.com',
              normalizedEmail: 'admin@example.com',
              passwordHash: adminHash.hash,
              passwordSalt: adminHash.salt,
              passwordIterations: adminHash.iterations,
              accountStatus: AuthAccountStatus.active,
              emailVerified: true,
              isAdHoc: false,
              displayName: 'Admin User',
              assignedProjectIds: const <String>[],
              verificationVersion: 0,
              createdAt: now,
              updatedAt: now,
              verifiedAt: now,
            ),
          );
          await recordStore.putPrincipal(
            EmailAuthPrincipal(
              userId: 'broken-adhoc',
              email: 'broken-adhoc@example.com',
              normalizedEmail: 'broken-adhoc@example.com',
              passwordHash: 'hash',
              passwordSalt: 'salt',
              passwordIterations: 1000,
              accountStatus: AuthAccountStatus.active,
              emailVerified: true,
              isAdHoc: true,
              displayName: 'Broken Adhoc',
              assignedProjectIds: const <String>['project-1'],
              verificationVersion: 0,
              createdAt: now,
              updatedAt: now,
              verifiedAt: now,
            ),
          );

          expect(
            () => authService.updateAdHocProjects(
              session: const AuthenticatedSession(
                userId: 'admin-user',
                sessionId: 'session-1',
                isAdHoc: false,
                emailVerified: true,
              ),
              userId: 'broken-adhoc',
              request: UpdateAdHocProjectsRequest(
                addProjectIds: const <String>['project-1'],
                removeProjectIds: const <String>[],
                adminPassword: 'admin-pass',
              ),
            ),
            throwsA(
              isA<AuthException>().having(
                (error) => error.code,
                'code',
                'unable_to_complete_action',
              ),
            ),
          );
        },
      );

      test(
        'project updates only remove explicitly requested memberships',
        () async {
          final adminResponse = await authService.register(
            RegisterRequest(
              userId: 'admin-user',
              name: 'Admin User',
              dateOfBirth: '1980-01-01',
              email: 'admin@example.com',
              password: 'admin-pass',
            ),
          );
          expect(adminResponse.status, equals('pending_verification'));
          final adminVerify = await authService.verifyEmail(
            VerifyEmailRequest(
              email: 'admin@example.com',
              code: emailSender.codes['admin@example.com']!.last,
            ),
          );
          final adminUserId = adminVerify.userId;

          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': adminUserId,
              'entityType': kEntityTypeMember,
              'domainType': kDomainMembership,
              'unknownJson': '{}',
              'change_domainId': 'project-1',
              'change_domainId_orig_': 'project-1',
              'change_changeAt': DateTime.now().toUtc().toIso8601String(),
              'change_changeAt_orig_': DateTime.now().toUtc().toIso8601String(),
              'change_cid': 'admin-member',
              'change_cid_orig_': 'admin-member',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': DateTime.now().toUtc().toIso8601String(),
              'change_storedAt_orig_': DateTime.now().toUtc().toIso8601String(),
              'data_parentId': '',
              'data_parentId_changeAt_': DateTime.now()
                  .toUtc()
                  .toIso8601String(),
              'data_parentId_cid_': 'admin-member',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionMembership,
              'data_parentProp_changeAt_': DateTime.now()
                  .toUtc()
                  .toIso8601String(),
              'data_parentProp_cid_': 'admin-member',
              'data_parentProp_changeBy_': 'seed',
              'role': 'admin',
              'userId': adminUserId,
            }),
          );

          final createResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/admin/adhoc-users',
            'headers': <String, String>{
              'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
            },
            'body': jsonEncode({
              'userId': 'adhoc-local-user',
              'name': 'Local User',
              'username': 'localuser123',
              'password': 'secret123',
              'projectIds': ['project-1'],
              'adminPassword': 'admin-pass',
            }),
          }, router);
          expect(createResponse['statusCode'], equals(201));

          final storedPrincipal = await recordStore.getPrincipalByUserId(
            'adhoc-local-user',
          );
          await recordStore.putPrincipal(
            storedPrincipal!.copyWith(
              assignedProjectIds: const <String>['project-1', 'project-2'],
            ),
          );
          await AuthAppStateStore(
            storage: storage,
          ).applyProjectAssignmentChanges(
            principal: storedPrincipal.copyWith(
              assignedProjectIds: const <String>['project-1', 'project-2'],
            ),
            projectIdsToAdd: const <String>['project-2'],
            projectIdsToRemove: const <String>[],
            changeBy: adminUserId,
            projectRoles: <String, String>{
              'project-2': MemberType.translator.name,
            },
          );

          final updateResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'PUT',
            'path': '/api/admin/adhoc-users/adhoc-local-user/projects',
            'headers': <String, String>{
              'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
            },
            'body': jsonEncode({
              'removeProjectIds': ['project-1'],
              'adminPassword': 'admin-pass',
            }),
          }, router);

          expect(updateResponse['statusCode'], equals(200));
          final updatedPrincipal = await recordStore.getPrincipalByUserId(
            'adhoc-local-user',
          );
          expect(updatedPrincipal?.assignedProjectIds, equals(['project-2']));

          final removedMembership = await storage.getEntityState(
            domainType: kDomainMembership,
            domainId: 'project-1',
            entityType: kEntityTypeMember,
            entityId: 'adhoc-local-user',
          );
          final retainedMembership = await storage.getEntityState(
            domainType: kDomainMembership,
            domainId: 'project-2',
            entityType: kEntityTypeMember,
            entityId: 'adhoc-local-user',
          );

          expect(removedMembership?.toJson()['data_deleted'], isTrue);
          expect(retainedMembership?.toJson()['data_deleted'], isFalse);
        },
      );

      test('admin can delete adhoc user from sole admin project', () async {
        final adminResponse = await authService.register(
          RegisterRequest(
            userId: 'admin-user',
            name: 'Admin User',
            dateOfBirth: '1980-01-01',
            email: 'admin@example.com',
            password: 'admin-pass',
          ),
        );
        expect(adminResponse.status, equals('pending_verification'));
        final adminVerify = await authService.verifyEmail(
          VerifyEmailRequest(
            email: 'admin@example.com',
            code: emailSender.codes['admin@example.com']!.last,
          ),
        );
        final adminUserId = adminVerify.userId;

        await storage.testStoreState(
          entityState: DynamoEntityState.fromJson({
            'entityId': adminUserId,
            'entityType': kEntityTypeMember,
            'domainType': kDomainMembership,
            'unknownJson': '{}',
            'change_domainId': 'project-1',
            'change_domainId_orig_': 'project-1',
            'change_changeAt': DateTime.now().toUtc().toIso8601String(),
            'change_changeAt_orig_': DateTime.now().toUtc().toIso8601String(),
            'change_cid': 'admin-member',
            'change_cid_orig_': 'admin-member',
            'change_changeBy': 'seed',
            'change_changeBy_orig_': 'seed',
            'change_storedAt': DateTime.now().toUtc().toIso8601String(),
            'change_storedAt_orig_': DateTime.now().toUtc().toIso8601String(),
            'data_parentId': '',
            'data_parentId_changeAt_': DateTime.now().toUtc().toIso8601String(),
            'data_parentId_cid_': 'admin-member',
            'data_parentId_changeBy_': 'seed',
            'data_parentProp': kCollectionMembership,
            'data_parentProp_changeAt_': DateTime.now()
                .toUtc()
                .toIso8601String(),
            'data_parentProp_cid_': 'admin-member',
            'data_parentProp_changeBy_': 'seed',
            'role': 'admin',
            'userId': adminUserId,
          }),
        );

        final createResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/admin/adhoc-users',
          'headers': <String, String>{
            'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
          },
          'body': jsonEncode({
            'userId': 'adhoc-local-user',
            'name': 'Local User',
            'username': 'localuser123',
            'password': 'secret123',
            'projectIds': ['project-1'],
            'adminPassword': 'admin-pass',
          }),
        }, router);
        expect(createResponse['statusCode'], equals(201));

        final deleteResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'DELETE',
          'path': '/api/admin/adhoc-users/adhoc-local-user',
          'headers': <String, String>{
            'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
          },
          'body': jsonEncode({'adminPassword': 'admin-pass'}),
        }, router);
        expect(deleteResponse['statusCode'], equals(200));

        final deletedPrincipal = await recordStore.getPrincipalByUserId(
          'adhoc-local-user',
        );
        expect(deletedPrincipal, isNotNull);
        expect(deletedPrincipal!.isDeleted, isTrue);
      });

      test(
        'project role-only updates also update membership state role',
        () async {
          final adminResponse = await authService.register(
            RegisterRequest(
              userId: 'admin-user-role-sync',
              name: 'Admin User',
              dateOfBirth: '1980-01-01',
              email: 'admin.role.sync@example.com',
              password: 'admin-pass',
            ),
          );
          expect(adminResponse.status, equals('pending_verification'));
          final adminVerify = await authService.verifyEmail(
            VerifyEmailRequest(
              email: 'admin.role.sync@example.com',
              code: emailSender.codes['admin.role.sync@example.com']!.last,
            ),
          );
          final adminUserId = adminVerify.userId;

          final now = DateTime.now().toUtc().toIso8601String();
          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': adminUserId,
              'entityType': kEntityTypeMember,
              'domainType': kDomainMembership,
              'unknownJson': '{}',
              'change_domainId': 'project-1',
              'change_domainId_orig_': 'project-1',
              'change_changeAt': now,
              'change_changeAt_orig_': now,
              'change_cid': 'admin-member-role-sync',
              'change_cid_orig_': 'admin-member-role-sync',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': now,
              'change_storedAt_orig_': now,
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': now,
              'data_parentId_cid_': 'admin-member-role-sync',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionMembership,
              'data_parentProp_changeAt_': now,
              'data_parentProp_cid_': 'admin-member-role-sync',
              'data_parentProp_changeBy_': 'seed',
              'role': 'admin',
              'userId': adminUserId,
            }),
          );

          final createResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'POST',
            'path': '/api/admin/adhoc-users',
            'headers': <String, String>{
              'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
            },
            'body': jsonEncode({
              'userId': 'adhoc-role-sync-user',
              'name': 'Role Sync User',
              'username': 'rolesync123',
              'password': 'secret123',
              'projectIds': ['project-1'],
              'adminPassword': 'admin-pass',
            }),
          }, router);
          expect(createResponse['statusCode'], equals(201));

          final updateResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'PUT',
            'path': '/api/admin/adhoc-users/adhoc-role-sync-user/projects',
            'headers': <String, String>{
              'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
            },
            'body': jsonEncode({
              'projectRoles': {'project-1': MemberType.consultant.name},
              'adminPassword': 'admin-pass',
            }),
          }, router);

          expect(updateResponse['statusCode'], equals(200));
          final updateBody =
              jsonDecode(updateResponse['body'] as String)
                  as Map<String, dynamic>;
          expect(
            (updateBody['projectRoles'] as Map<String, dynamic>)['project-1'],
            equals(MemberType.consultant.name),
          );

          final membershipState = await storage.getEntityState(
            domainType: kDomainMembership,
            domainId: 'project-1',
            entityType: kEntityTypeMember,
            entityId: 'adhoc-role-sync-user',
          );
          expect(membershipState, isNotNull);
          final membershipJson = membershipState!.toJson();
          expect(membershipJson['data_deleted'], isFalse);
          expect(
            membershipJson['data_role'],
            equals(MemberType.consultant.name),
          );
        },
      );

      test('rejects adhoc project role update to admin', () async {
        final adminResponse = await authService.register(
          RegisterRequest(
            userId: 'admin-user-role-reject',
            name: 'Admin User',
            dateOfBirth: '1980-01-01',
            email: 'admin.role.reject@example.com',
            password: 'admin-pass',
          ),
        );
        expect(adminResponse.status, equals('pending_verification'));
        final adminVerify = await authService.verifyEmail(
          VerifyEmailRequest(
            email: 'admin.role.reject@example.com',
            code: emailSender.codes['admin.role.reject@example.com']!.last,
          ),
        );

        await storage.testStoreState(
          entityState: DynamoEntityState.fromJson({
            'entityId': adminVerify.userId,
            'entityType': kEntityTypeMember,
            'domainType': kDomainMembership,
            'unknownJson': '{}',
            'change_domainId': 'project-1',
            'change_domainId_orig_': 'project-1',
            'change_changeAt': DateTime.now().toUtc().toIso8601String(),
            'change_changeAt_orig_': DateTime.now().toUtc().toIso8601String(),
            'change_cid': 'admin-member-reject',
            'change_cid_orig_': 'admin-member-reject',
            'change_changeBy': 'seed',
            'change_changeBy_orig_': 'seed',
            'change_storedAt': DateTime.now().toUtc().toIso8601String(),
            'change_storedAt_orig_': DateTime.now().toUtc().toIso8601String(),
            'data_parentId': kDomainEntityRootParentId,
            'data_parentId_changeAt_': DateTime.now().toUtc().toIso8601String(),
            'data_parentId_cid_': 'admin-member-reject',
            'data_parentId_changeBy_': 'seed',
            'data_parentProp': kCollectionMembership,
            'data_parentProp_changeAt_': DateTime.now()
                .toUtc()
                .toIso8601String(),
            'data_parentProp_cid_': 'admin-member-reject',
            'data_parentProp_changeBy_': 'seed',
            'role': 'admin',
            'userId': adminVerify.userId,
          }),
        );

        final createResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/admin/adhoc-users',
          'headers': <String, String>{
            'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
          },
          'body': jsonEncode({
            'userId': 'adhoc-update-role-reject',
            'name': 'Reject Update User',
            'username': 'rejectupdate123',
            'password': 'secret123',
            'projectIds': ['project-1'],
            'adminPassword': 'admin-pass',
          }),
        }, router);
        expect(createResponse['statusCode'], equals(201));

        final updateResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'PUT',
          'path': '/api/admin/adhoc-users/adhoc-update-role-reject/projects',
          'headers': <String, String>{
            'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
          },
          'body': jsonEncode({
            'projectRoles': {'project-1': MemberType.admin.name},
            'adminPassword': 'admin-pass',
          }),
        }, router);

        expect(updateResponse['statusCode'], equals(400));
        final updateBody =
            jsonDecode(updateResponse['body'] as String)
                as Map<String, dynamic>;
        expect(updateBody['code'], equals('invalid_request'));
      });

      test(
        'admin can update generic user memberships without overwriting untouched memberships',
        () async {
          final adminResponse = await authService.register(
            RegisterRequest(
              userId: 'admin-user-generic-1',
              name: 'Admin User',
              dateOfBirth: '1980-01-01',
              email: 'admin.generic1@example.com',
              password: 'admin-pass',
            ),
          );
          expect(adminResponse.status, equals('pending_verification'));
          final adminVerify = await authService.verifyEmail(
            VerifyEmailRequest(
              email: 'admin.generic1@example.com',
              code: emailSender.codes['admin.generic1@example.com']!.last,
            ),
          );
          final adminUserId = adminVerify.userId;

          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': adminUserId,
              'entityType': kEntityTypeMember,
              'domainType': kDomainMembership,
              'unknownJson': '{}',
              'change_domainId': 'project-1',
              'change_domainId_orig_': 'project-1',
              'change_changeAt': DateTime.now().toUtc().toIso8601String(),
              'change_changeAt_orig_': DateTime.now().toUtc().toIso8601String(),
              'change_cid': 'admin-member-generic-1',
              'change_cid_orig_': 'admin-member-generic-1',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': DateTime.now().toUtc().toIso8601String(),
              'change_storedAt_orig_': DateTime.now().toUtc().toIso8601String(),
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': DateTime.now()
                  .toUtc()
                  .toIso8601String(),
              'data_parentId_cid_': 'admin-member-generic-1',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionMembership,
              'data_parentProp_changeAt_': DateTime.now()
                  .toUtc()
                  .toIso8601String(),
              'data_parentProp_cid_': 'admin-member-generic-1',
              'data_parentProp_changeBy_': 'seed',
              'role': 'admin',
              'userId': adminUserId,
            }),
          );

          final userRegister = await authService.register(
            RegisterRequest(
              userId: 'regular-user-generic-1',
              name: 'Regular User',
              dateOfBirth: '1991-02-02',
              email: 'regular.generic1@example.com',
              password: 'user-pass-1',
            ),
          );
          expect(userRegister.status, equals('pending_verification'));
          await authService.verifyEmail(
            VerifyEmailRequest(
              email: 'regular.generic1@example.com',
              code: emailSender.codes['regular.generic1@example.com']!.last,
            ),
          );

          final existing = await recordStore.getPrincipalByUserId(
            'regular-user-generic-1',
          );
          expect(existing, isNotNull);
          await recordStore.putPrincipal(
            existing!.copyWith(
              assignedProjectIds: const <String>['project-1', 'project-2'],
              memberships: const <String, String>{
                'project-1': 'translator',
                'project-2': 'observer',
              },
            ),
          );

          final updateResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'PUT',
            'path': '/api/admin/user/regular-user-generic-1/memberships',
            'headers': <String, String>{
              'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
            },
            'body': jsonEncode({
              'memberAdditions': {'project-1': 'admin'},
              'memberRemovals': <String>[],
              'adminPassword': 'admin-pass',
            }),
          }, router);

          expect(updateResponse['statusCode'], equals(200));
          final updated = await recordStore.getPrincipalByUserId(
            'regular-user-generic-1',
          );
          expect(updated, isNotNull);
          expect(
            updated!.assignedProjectIds.toSet(),
            equals(const <String>{'project-1', 'project-2'}),
          );
          expect(updated.memberships?['project-1'], equals('admin'));
          expect(updated.memberships?['project-2'], equals('observer'));
        },
      );

      test(
        'generic membership updates reject disallowed member type names',
        () async {
          final adminResponse = await authService.register(
            RegisterRequest(
              userId: 'admin-user-generic-4',
              name: 'Admin User',
              dateOfBirth: '1980-01-01',
              email: 'admin.generic4@example.com',
              password: 'admin-pass',
            ),
          );
          expect(adminResponse.status, equals('pending_verification'));
          final adminVerify = await authService.verifyEmail(
            VerifyEmailRequest(
              email: 'admin.generic4@example.com',
              code: emailSender.codes['admin.generic4@example.com']!.last,
            ),
          );

          final userRegister = await authService.register(
            RegisterRequest(
              userId: 'regular-user-generic-4',
              name: 'Regular User',
              dateOfBirth: '1991-02-02',
              email: 'regular.generic4@example.com',
              password: 'user-pass-4',
            ),
          );
          expect(userRegister.status, equals('pending_verification'));
          await authService.verifyEmail(
            VerifyEmailRequest(
              email: 'regular.generic4@example.com',
              code: emailSender.codes['regular.generic4@example.com']!.last,
            ),
          );

          final updateResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'PUT',
            'path': '/api/admin/user/regular-user-generic-4/memberships',
            'headers': <String, String>{
              'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
            },
            'body': jsonEncode({
              'memberAdditions': {'project-1': 'system'},
              'memberRemovals': <String>[],
              'adminPassword': 'admin-pass',
            }),
          }, router);

          expect(updateResponse['statusCode'], equals(400));
          expect(
            responseBody(updateResponse)['code'],
            equals('invalid_request'),
          );
        },
      );

      test(
        'generic membership updates reject projects outside admin scope',
        () async {
          final adminResponse = await authService.register(
            RegisterRequest(
              userId: 'admin-user-generic-2',
              name: 'Admin User',
              dateOfBirth: '1980-01-01',
              email: 'admin.generic2@example.com',
              password: 'admin-pass',
            ),
          );
          expect(adminResponse.status, equals('pending_verification'));
          final adminVerify = await authService.verifyEmail(
            VerifyEmailRequest(
              email: 'admin.generic2@example.com',
              code: emailSender.codes['admin.generic2@example.com']!.last,
            ),
          );
          final adminUserId = adminVerify.userId;

          await storage.testStoreState(
            entityState: DynamoEntityState.fromJson({
              'entityId': adminUserId,
              'entityType': kEntityTypeMember,
              'domainType': kDomainMembership,
              'unknownJson': '{}',
              'change_domainId': 'project-1',
              'change_domainId_orig_': 'project-1',
              'change_changeAt': DateTime.now().toUtc().toIso8601String(),
              'change_changeAt_orig_': DateTime.now().toUtc().toIso8601String(),
              'change_cid': 'admin-member-generic-2',
              'change_cid_orig_': 'admin-member-generic-2',
              'change_changeBy': 'seed',
              'change_changeBy_orig_': 'seed',
              'change_storedAt': DateTime.now().toUtc().toIso8601String(),
              'change_storedAt_orig_': DateTime.now().toUtc().toIso8601String(),
              'data_parentId': kDomainEntityRootParentId,
              'data_parentId_changeAt_': DateTime.now()
                  .toUtc()
                  .toIso8601String(),
              'data_parentId_cid_': 'admin-member-generic-2',
              'data_parentId_changeBy_': 'seed',
              'data_parentProp': kCollectionMembership,
              'data_parentProp_changeAt_': DateTime.now()
                  .toUtc()
                  .toIso8601String(),
              'data_parentProp_cid_': 'admin-member-generic-2',
              'data_parentProp_changeBy_': 'seed',
              'role': 'admin',
              'userId': adminUserId,
            }),
          );

          final userRegister = await authService.register(
            RegisterRequest(
              userId: 'regular-user-generic-2',
              name: 'Regular User',
              dateOfBirth: '1991-02-02',
              email: 'regular.generic2@example.com',
              password: 'user-pass-2',
            ),
          );
          expect(userRegister.status, equals('pending_verification'));
          await authService.verifyEmail(
            VerifyEmailRequest(
              email: 'regular.generic2@example.com',
              code: emailSender.codes['regular.generic2@example.com']!.last,
            ),
          );

          final updateResponse = await server.handleApiGatewayEvent({
            'httpMethod': 'PUT',
            'path': '/api/admin/user/regular-user-generic-2/memberships',
            'headers': <String, String>{
              'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
            },
            'body': jsonEncode({
              'memberAdditions': {'project-2': 'translator'},
              'memberRemovals': <String>[],
              'adminPassword': 'admin-pass',
            }),
          }, router);

          expect(updateResponse['statusCode'], equals(403));
          expect(
            responseBody(updateResponse)['code'],
            equals('insufficient_permissions'),
          );
        },
      );

      test('generic membership updates return 404 for unknown users', () async {
        final adminResponse = await authService.register(
          RegisterRequest(
            userId: 'admin-user-generic-3',
            name: 'Admin User',
            dateOfBirth: '1980-01-01',
            email: 'admin.generic3@example.com',
            password: 'admin-pass',
          ),
        );
        expect(adminResponse.status, equals('pending_verification'));
        final adminVerify = await authService.verifyEmail(
          VerifyEmailRequest(
            email: 'admin.generic3@example.com',
            code: emailSender.codes['admin.generic3@example.com']!.last,
          ),
        );
        final adminUserId = adminVerify.userId;

        await storage.testStoreState(
          entityState: DynamoEntityState.fromJson({
            'entityId': adminUserId,
            'entityType': kEntityTypeMember,
            'domainType': kDomainMembership,
            'unknownJson': '{}',
            'change_domainId': 'project-1',
            'change_domainId_orig_': 'project-1',
            'change_changeAt': DateTime.now().toUtc().toIso8601String(),
            'change_changeAt_orig_': DateTime.now().toUtc().toIso8601String(),
            'change_cid': 'admin-member-generic-3',
            'change_cid_orig_': 'admin-member-generic-3',
            'change_changeBy': 'seed',
            'change_changeBy_orig_': 'seed',
            'change_storedAt': DateTime.now().toUtc().toIso8601String(),
            'change_storedAt_orig_': DateTime.now().toUtc().toIso8601String(),
            'data_parentId': kDomainEntityRootParentId,
            'data_parentId_changeAt_': DateTime.now().toUtc().toIso8601String(),
            'data_parentId_cid_': 'admin-member-generic-3',
            'data_parentId_changeBy_': 'seed',
            'data_parentProp': kCollectionMembership,
            'data_parentProp_changeAt_': DateTime.now()
                .toUtc()
                .toIso8601String(),
            'data_parentProp_cid_': 'admin-member-generic-3',
            'data_parentProp_changeBy_': 'seed',
            'role': 'admin',
            'userId': adminUserId,
          }),
        );

        final updateResponse = await server.handleApiGatewayEvent({
          'httpMethod': 'PUT',
          'path': '/api/admin/user/unknown-user/memberships',
          'headers': <String, String>{
            'authorization': 'Bearer ${adminVerify.tokens.accessToken}',
          },
          'body': jsonEncode({
            'memberAdditions': {'project-1': 'translator'},
            'memberRemovals': <String>[],
            'adminPassword': 'admin-pass',
          }),
        }, router);

        expect(updateResponse['statusCode'], equals(404));
        expect(
          responseBody(updateResponse)['code'],
          equals('unable_to_complete_action'),
        );
      });
    });
  });
}

class _CapturingEmailSender implements AuthEmailSender {
  final Map<String, List<String>> codes = {};

  @override
  Future<void> sendVerificationCode({
    required String toEmail,
    required String code,
    required DateTime expiresAt,
  }) async {
    codes.putIfAbsent(toEmail, () => <String>[]).add(code);
  }
}
