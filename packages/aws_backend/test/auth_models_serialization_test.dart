import 'package:aws_backend/src/auth/auth_models.dart';
import 'package:test/test.dart';

void main() {
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
