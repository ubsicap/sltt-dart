import 'package:aws_backend/src/auth/auth_models.dart';
import 'package:test/test.dart';

void main() {
  group('AuthPrincipal variants', () {
    test('fromJson returns EmailAuthPrincipal for email identities', () {
      final principal = AuthPrincipal.fromJson({
        'userId': 'user-1',
        'identityKind': 'email_password',
        'email': 'person@example.com',
        'normalizedEmail': 'person@example.com',
        'passwordHash': 'hash',
        'passwordSalt': 'salt',
        'passwordIterations': 120000,
        'accountStatus': 'pending_verification',
        'emailVerified': false,
        'isAdHoc': false,
        'displayName': 'Person',
        'assignedProjectIds': <String>[],
        'verificationVersion': 0,
        'createdAt': '2026-04-14T10:00:00.000Z',
        'updatedAt': '2026-04-14T10:00:00.000Z',
      });

      expect(principal, isA<EmailAuthPrincipal>());
      expect(principal.email, equals('person@example.com'));
      expect(principal.username, isNull);
      expect(principal.toJson()['identityKind'], equals('email_password'));
      expect(principal.toJson().containsKey('username'), isFalse);
    });

    test('fromJson returns UsernameAuthPrincipal for username identities', () {
      final principal = AuthPrincipal.fromJson({
        'userId': 'user-2',
        'identityKind': 'username_password',
        'username': 'local.user',
        'normalizedUsername': 'local.user',
        'passwordHash': 'hash',
        'passwordSalt': 'salt',
        'passwordIterations': 120000,
        'accountStatus': 'active',
        'emailVerified': true,
        'isAdHoc': true,
        'displayName': 'Local User',
        'assignedProjectIds': <String>['proj-a'],
        'verificationVersion': 0,
        'createdAt': '2026-04-14T10:00:00.000Z',
        'updatedAt': '2026-04-14T10:00:00.000Z',
      });

      expect(principal, isA<UsernameAuthPrincipal>());
      expect(principal.username, equals('local.user'));
      expect(principal.email, isNull);
      expect(principal.toJson()['identityKind'], equals('username_password'));
      expect(principal.toJson().containsKey('email'), isFalse);
    });

    test('copyWith preserves EmailAuthPrincipal subtype', () {
      final principal = EmailAuthPrincipal(
        userId: 'user-1',
        email: 'person@example.com',
        normalizedEmail: 'person@example.com',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        passwordIterations: 120000,
        accountStatus: AuthAccountStatus.pendingVerification,
        emailVerified: false,
        displayName: 'Person',
        assignedProjectIds: const <String>[],
        verificationVersion: 0,
        createdAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
        updatedAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
      );

      final updated = principal.copyWith(displayName: 'Updated Person');

      expect(updated, isA<EmailAuthPrincipal>());
      expect(updated.displayName, equals('Updated Person'));
      expect(updated.email, equals('person@example.com'));
    });

    test('copyWith preserves UsernameAuthPrincipal subtype', () {
      final principal = UsernameAuthPrincipal(
        userId: 'user-2',
        username: 'local.user',
        normalizedUsername: 'local.user',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        passwordIterations: 120000,
        accountStatus: AuthAccountStatus.active,
        emailVerified: true,
        displayName: 'Local User',
        assignedProjectIds: const <String>['proj-a'],
        verificationVersion: 0,
        createdAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
        updatedAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
      );

      final updated = principal.copyWith(
        assignedProjectIds: const <String>['proj-a', 'proj-b'],
      );

      expect(updated, isA<UsernameAuthPrincipal>());
      expect(updated.username, equals('local.user'));
      expect(
        updated.assignedProjectIds,
        equals(const <String>['proj-a', 'proj-b']),
      );
    });

    test('supports memberships map serialization and copyWith', () {
      final principal = UsernameAuthPrincipal(
        userId: 'user-3',
        username: 'map.user',
        normalizedUsername: 'map.user',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        passwordIterations: 120000,
        accountStatus: AuthAccountStatus.active,
        emailVerified: true,
        displayName: 'Map User',
        assignedProjectIds: const <String>['proj-a'],
        memberships: const <String, String>{'proj-a': 'translator'},
        verificationVersion: 0,
        createdAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
        updatedAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
      );

      final updated = principal.copyWith(
        memberships: const <String, String>{
          'proj-a': 'admin',
          'proj-b': 'translator',
        },
      );

      expect(updated.memberships?['proj-a'], equals('admin'));
      expect(updated.memberships?['proj-b'], equals('translator'));
      final roundTrip = AuthPrincipal.fromJson(updated.toJson());
      expect(roundTrip.memberships?['proj-a'], equals('admin'));
      expect(roundTrip.memberships?['proj-b'], equals('translator'));
    });

    test('rejects email identities with missing email fields', () {
      expect(
        () => EmailAuthPrincipal(
          userId: 'user-1',
          email: '',
          normalizedEmail: 'person@example.com',
          passwordHash: 'hash',
          passwordSalt: 'salt',
          passwordIterations: 120000,
          accountStatus: AuthAccountStatus.pendingVerification,
          emailVerified: false,
          displayName: 'Person',
          assignedProjectIds: const <String>[],
          verificationVersion: 0,
          createdAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
          updatedAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
        ),
        throwsArgumentError,
      );
    });

    test('rejects EmailAuthPrincipal with mismatched identityKind', () {
      expect(
        () => EmailAuthPrincipal(
          userId: 'user-1',
          identityKind: AuthIdentityKind.usernamePassword,
          email: 'person@example.com',
          normalizedEmail: 'person@example.com',
          passwordHash: 'hash',
          passwordSalt: 'salt',
          passwordIterations: 120000,
          accountStatus: AuthAccountStatus.pendingVerification,
          emailVerified: false,
          displayName: 'Person',
          assignedProjectIds: const <String>[],
          verificationVersion: 0,
          createdAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
          updatedAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
        ),
        throwsArgumentError,
      );
    });

    test('rejects username identities with missing username fields', () {
      expect(
        () => UsernameAuthPrincipal(
          userId: 'user-2',
          username: ' ',
          normalizedUsername: 'local.user',
          passwordHash: 'hash',
          passwordSalt: 'salt',
          passwordIterations: 120000,
          accountStatus: AuthAccountStatus.active,
          emailVerified: true,
          displayName: 'Local User',
          assignedProjectIds: const <String>['proj-a'],
          verificationVersion: 0,
          createdAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
          updatedAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
        ),
        throwsArgumentError,
      );
    });

    test('rejects UsernameAuthPrincipal with mismatched identityKind', () {
      expect(
        () => UsernameAuthPrincipal(
          userId: 'user-2',
          identityKind: AuthIdentityKind.emailPassword,
          username: 'local.user',
          normalizedUsername: 'local.user',
          passwordHash: 'hash',
          passwordSalt: 'salt',
          passwordIterations: 120000,
          accountStatus: AuthAccountStatus.active,
          emailVerified: true,
          displayName: 'Local User',
          assignedProjectIds: const <String>['proj-a'],
          verificationVersion: 0,
          createdAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
          updatedAt: DateTime.parse('2026-04-14T10:00:00.000Z'),
        ),
        throwsArgumentError,
      );
    });

    test('fromJson rejects email identities without email payload', () {
      expect(
        () => AuthPrincipal.fromJson({
          'userId': 'user-1',
          'identityKind': 'email_password',
          'passwordHash': 'hash',
          'passwordSalt': 'salt',
          'passwordIterations': 120000,
          'accountStatus': 'pending_verification',
          'emailVerified': false,
          'isAdHoc': false,
          'displayName': 'Person',
          'assignedProjectIds': <String>[],
          'verificationVersion': 0,
          'createdAt': '2026-04-14T10:00:00.000Z',
          'updatedAt': '2026-04-14T10:00:00.000Z',
        }),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('fromJson rejects username identities without username payload', () {
      expect(
        () => AuthPrincipal.fromJson({
          'userId': 'user-2',
          'identityKind': 'username_password',
          'passwordHash': 'hash',
          'passwordSalt': 'salt',
          'passwordIterations': 120000,
          'accountStatus': 'active',
          'emailVerified': true,
          'isAdHoc': true,
          'displayName': 'Local User',
          'assignedProjectIds': <String>['proj-a'],
          'verificationVersion': 0,
          'createdAt': '2026-04-14T10:00:00.000Z',
          'updatedAt': '2026-04-14T10:00:00.000Z',
        }),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('AuthEmailChallenge serialization', () {
    test('round-trips UTC timestamps and includes ttlEpochSeconds', () {
      final challenge = AuthEmailChallenge(
        userId: 'user-1',
        codeHash: 'hash',
        codeSalt: 'salt',
        hashIterations: 12345,
        expiresAt: DateTime.parse('2026-04-14T12:34:56Z'),
        createdAt: DateTime.parse('2026-04-14T11:22:33Z'),
        resendCount: 2,
        failedAttemptCount: 1,
        challengeVersion: 3,
      );

      final json = challenge.toJson();
      expect(
        json,
        containsPair(
          'ttlEpochSeconds',
          challenge.expiresAt.millisecondsSinceEpoch ~/ 1000,
        ),
      );

      final roundTrip = AuthEmailChallenge.fromJson(json);
      expect(roundTrip.userId, equals(challenge.userId));
      expect(roundTrip.expiresAt, equals(challenge.expiresAt));
      expect(roundTrip.createdAt, equals(challenge.createdAt));
      expect(
        roundTrip.failedAttemptCount,
        equals(challenge.failedAttemptCount),
      );
    });

    test('preserves fallback defaults for missing optional fields', () {
      final before = DateTime.now().toUtc();
      final challenge = AuthEmailChallenge.fromJson({'userId': 'user-1'});
      final after = DateTime.now().toUtc();

      expect(challenge.codeHash, isEmpty);
      expect(challenge.codeSalt, isEmpty);
      expect(challenge.hashIterations, equals(1));
      expect(challenge.resendCount, equals(0));
      expect(challenge.failedAttemptCount, equals(0));
      expect(challenge.challengeVersion, equals(0));
      expect(
        challenge.createdAt.isAfter(before) ||
            challenge.createdAt.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        challenge.createdAt.isBefore(after) ||
            challenge.createdAt.isAtSameMomentAs(after),
        isTrue,
      );
    });
  });

  group('AuthSessionRecord serialization', () {
    test('omits null revokedAt and includes ttlEpochSeconds', () {
      final session = AuthSessionRecord(
        userId: 'user-1',
        sessionId: 'session-1',
        refreshTokenHash: 'hash',
        createdAt: DateTime.parse('2026-04-14T11:22:33Z'),
        expiresAt: DateTime.parse('2026-04-15T11:22:33Z'),
      );

      final json = session.toJson();
      expect(json.containsKey('revokedAt'), isFalse);
      expect(
        json,
        containsPair(
          'ttlEpochSeconds',
          session.expiresAt.millisecondsSinceEpoch ~/ 1000,
        ),
      );

      final roundTrip = AuthSessionRecord.fromJson(json);
      expect(roundTrip.userId, equals(session.userId));
      expect(roundTrip.revokedAt, isNull);
      expect(roundTrip.expiresAt, equals(session.expiresAt));
    });
  });

  group('Request DTO serialization', () {
    test('LoginRequest reads identifier fallback from email or username', () {
      expect(
        LoginRequest.fromJson({
          'email': 'person@example.com',
          'password': 'pw',
        }).identifier,
        equals('person@example.com'),
      );
      expect(
        LoginRequest.fromJson({
          'username': 'local.user',
          'password': 'pw',
        }).identifier,
        equals('local.user'),
      );
    });

    test('CreateAdHocUserRequest filters non-string project ids', () {
      final request = CreateAdHocUserRequest.fromJson({
        'userId': 'user-1',
        'name': 'Name',
        'username': 'local.user',
        'password': 'pw',
        'projectIds': ['a', 1, 'b', null],
        'adminPassword': 'admin',
      });

      expect(request.projectIds, equals(const <String>['a', 'b']));
    });

    test('UpdateAdHocProjectsRequest defaults missing lists to empty', () {
      final request = UpdateAdHocProjectsRequest.fromJson({
        'adminPassword': 'admin',
      });

      expect(request.addProjectIds, isEmpty);
      expect(request.removeProjectIds, isEmpty);
      expect(request.adminPassword, equals('admin'));
    });

    test('UpdateUserMembershipsRequest normalizes map/list fields', () {
      final request = UpdateUserMembershipsRequest.fromJson({
        'memberAdditions': {
          ' project-1 ': ' admin ',
          'project-2': 'translator',
          'project-3': 1,
        },
        'memberRemovals': ['project-4', 3, null, ' project-5 '],
        'adminPassword': 'admin',
      });

      expect(
        request.memberAdditions,
        equals(const <String, String>{
          'project-1': 'admin',
          'project-2': 'translator',
        }),
      );
      expect(
        request.memberRemovals,
        equals(const <String>['project-4', ' project-5 ']),
      );
      expect(request.adminPassword, equals('admin'));
    });
  });

  group('Response DTO serialization', () {
    test('AuthTokenPair round-trips expiresAt in UTC', () {
      final pair = AuthTokenPair(
        accessToken: 'access',
        refreshToken: 'refresh',
        expiresAt: DateTime.parse('2026-04-14T16:00:00Z'),
      );

      final json = pair.toJson();
      final roundTrip = AuthTokenPair.fromJson(json);

      expect(roundTrip.accessToken, equals(pair.accessToken));
      expect(roundTrip.refreshToken, equals(pair.refreshToken));
      expect(roundTrip.expiresAt, equals(pair.expiresAt));
    });

    test('AuthStatusResponse omits null message', () {
      const response = AuthStatusResponse(status: 'sent');

      expect(response.toJson(), equals({'status': 'sent'}));
    });

    test('AdHocUserSummary filters null dateOfBirth from JSON output', () {
      const summary = AdHocUserSummary(
        userId: 'user-1',
        name: 'Name',
        username: 'local.user',
        dateOfBirth: null,
        projectIds: <String>['proj-a'],
        status: 'active',
      );

      expect(summary.toJson().containsKey('dateOfBirth'), isFalse);
    });

    test('AdHocUsersResponse round-trips nested items', () {
      const response = AdHocUsersResponse(
        items: <AdHocUserSummary>[
          AdHocUserSummary(
            userId: 'user-1',
            name: 'Name',
            username: 'local.user',
            dateOfBirth: '2000-01-01',
            projectIds: <String>['proj-a'],
            status: 'active',
          ),
        ],
      );

      final roundTrip = AdHocUsersResponse.fromJson(response.toJson());
      expect(roundTrip.items, hasLength(1));
      expect(roundTrip.items.single.username, equals('local.user'));
      expect(
        roundTrip.items.single.projectIds,
        equals(const <String>['proj-a']),
      );
    });

    test('AuthenticatedResponse keeps flattened token fields', () {
      final response = AuthenticatedResponse(
        status: 'authenticated',
        userId: 'user-1',
        accessToken: 'access',
        refreshToken: 'refresh',
        expiresAt: DateTime.parse('2026-04-14T16:00:00Z'),
      );

      expect(
        response.toJson(),
        equals({
          'status': 'authenticated',
          'userId': 'user-1',
          'accessToken': 'access',
          'refreshToken': 'refresh',
          'expiresAt': '2026-04-14T16:00:00.000Z',
        }),
      );
      expect(response.tokens.accessToken, equals('access'));
      expect(response.toAuthTokenPair().refreshToken, equals('refresh'));

      final roundTrip = AuthenticatedResponse.fromJson(response.toJson());
      expect(roundTrip.status, equals('authenticated'));
      expect(roundTrip.userId, equals('user-1'));
      expect(roundTrip.accessToken, equals('access'));
      expect(roundTrip.refreshToken, equals('refresh'));
      expect(
        roundTrip.expiresAt,
        equals(DateTime.parse('2026-04-14T16:00:00Z')),
      );
    });
  });
}
