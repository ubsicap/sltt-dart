import 'dart:convert';

import 'package:aws_backend/aws_backend.dart';
import 'package:aws_backend/src/auth/auth_app_state_store.dart';
import 'package:aws_backend/src/auth/auth_email_sender.dart';
import 'package:aws_backend/src/auth/auth_record_store.dart';
import 'package:aws_backend/src/auth/password_hash_service.dart';
import 'package:aws_backend/src/auth/token_service.dart';
import 'package:aws_backend/src/models/dynamo_entity_state.dart';
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

    setUp(() async {
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
          jsonDecode(verifyResponse['body'] as String) as Map<String, dynamic>;
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
        entityId: 'default',
      );
      final userState = await storage.getEntityState(
        domainType: 'user',
        domainId: verifyBody['userId'] as String,
        entityType: kEntityTypeUser,
        entityId: verifyBody['userId'] as String,
      );
      expect(profileState, isA<DynamoEntityState>());
      expect(
        profileState?.toJson()['email'] ?? profileState?.toJson()['data_email'],
        equals('jane@example.com'),
      );
      expect(
        profileState?.toJson()['emailVerified'] ??
            profileState?.toJson()['data_emailVerified'],
        isTrue,
      );
      expect(userState, isNull);
    });

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
          jsonDecode(verifyResponse['body'] as String) as Map<String, dynamic>;
      final originalRefreshToken = verifyBody['refreshToken'] as String;

      final refreshResponse = await server.handleApiGatewayEvent({
        'httpMethod': 'POST',
        'path': '/api/auth/refresh',
        'headers': <String, String>{},
        'body': jsonEncode({'refreshToken': originalRefreshToken}),
      }, router);

      expect(refreshResponse['statusCode'], equals(200));
      final refreshBody =
          jsonDecode(refreshResponse['body'] as String) as Map<String, dynamic>;
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
          jsonDecode(resendResponse['body'] as String) as Map<String, dynamic>;
      expect(resendBody['status'], equals('sent'));
      expect(emailSender.codes.containsKey('missing@example.com'), isFalse);
    });

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
          'domainType': 'project',
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
          'data_parentProp': kEntityTypeMemberCollection,
          'data_parentProp_changeAt_': DateTime.now().toUtc().toIso8601String(),
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
          'username': 'local.user',
          'password': 'secret123',
          'projectIds': ['project-1'],
          'adminPassword': 'admin-pass',
        }),
      }, router);

      expect(createResponse['statusCode'], equals(201));
      final createBody =
          jsonDecode(createResponse['body'] as String) as Map<String, dynamic>;
      expect(createBody['username'], equals('local.user'));

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
            'domainType': 'project',
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
            'data_parentProp': kEntityTypeMemberCollection,
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
            'username': 'local.user',
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
        await AuthAppStateStore(storage: storage).applyProjectAssignmentChanges(
          principal: storedPrincipal.copyWith(
            assignedProjectIds: const <String>['project-1', 'project-2'],
          ),
          projectIdsToAdd: const <String>['project-2'],
          projectIdsToRemove: const <String>[],
          changeBy: adminUserId,
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
          domainType: 'project',
          domainId: 'project-1',
          entityType: kEntityTypeMember,
          entityId: 'adhoc-local-user',
        );
        final retainedMembership = await storage.getEntityState(
          domainType: 'project',
          domainId: 'project-2',
          entityType: kEntityTypeMember,
          entityId: 'adhoc-local-user',
        );

        expect(removedMembership?.toJson()['data_deleted'], isTrue);
        expect(retainedMembership?.toJson()['data_deleted'], isFalse);
      },
    );
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
