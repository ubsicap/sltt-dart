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
        'headers': <String, String>{},
        'body': jsonEncode({
          'name': 'Jane Doe',
          'dateOfBirth': '1990-06-15',
          'email': 'jane@example.com',
          'password': 'secret123',
        }),
      }, router);

      expect(registerResponse['statusCode'], equals(200));
      expect(emailSender.codes['jane@example.com'], hasLength(1));

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
      expect(profileState, isA<DynamoEntityState>());
      expect(profileState?.toJson()['email'], equals('jane@example.com'));
    });

    test('resend invalidates previous code', () async {
      await authService.register(
        RegisterRequest(
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
        'headers': <String, String>{},
        'body': jsonEncode({'email': 'jane@example.com'}),
      }, router);
      expect(resendResponse['statusCode'], equals(200));
      final secondCode = emailSender.codes['jane@example.com']!.last;
      expect(secondCode, isNot(equals(firstCode)));

      final oldVerifyResponse = await server.handleApiGatewayEvent({
        'httpMethod': 'POST',
        'path': '/api/auth/verify-email',
        'headers': <String, String>{},
        'body': jsonEncode({'email': 'jane@example.com', 'code': firstCode}),
      }, router);
      expect(oldVerifyResponse['statusCode'], equals(400));
    });

    test('admin can create adhoc user', () async {
      final adminResponse = await authService.register(
        RegisterRequest(
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
