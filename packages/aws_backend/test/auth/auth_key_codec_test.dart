import 'package:aws_backend/src/auth/auth_key_codec.dart';
import 'package:aws_backend/src/auth/auth_models.dart';
import 'package:aws_backend/src/storage/value_codec.dart';
import 'package:test/test.dart';

void main() {
  group('Auth Key Codec', () {
    test('buildAuthUserPk encodes user id and round-trips parseAuthUserPk', () {
      final key = buildAuthUserPk('user_123');
      expect(key, equals('USER#@USERID#user_123'));
      expect(parseAuthUserPk(key), equals('user_123'));
    });

    test('buildAuthEmailLookupPk encodes @ in normalized email', () {
      final key = buildAuthEmailLookupPk('person@example.com');
      expect(
        key,
        equals('IDENTIFIER#EMAIL#@NORMALIZEDEMAIL#person%40example.com'),
      );
      expect(parseAuthEmailLookupPk(key), equals('person@example.com'));
    });

    test('buildAuthUsernameLookupPk round-trips normalized username', () {
      final key = buildAuthUsernameLookupPk('local.user');
      expect(key, equals('IDENTIFIER#USERNAME#@NORMALIZEDUSERNAME#local.user'));
      expect(parseAuthUsernameLookupPk(key), equals('local.user'));
    });

    test('buildAuthSessionSk round-trips session id', () {
      final key = buildAuthSessionSk('sess_abc');
      expect(key, equals('SESSION#@SESSIONID#sess_abc'));
      expect(parseAuthSessionSk(key), equals('sess_abc'));
    });

    test('buildAuthSessionTokenPk round-trips refresh token hash', () {
      const hash = 'sha256_refresh_token';
      final key = buildAuthSessionTokenPk(hash);
      expect(
        key,
        equals('SESSIONTOKEN#@REFRESHTOKENHASH#sha256_refresh_token'),
      );
      expect(parseAuthSessionTokenPk(key), equals(hash));
    });

    test('buildAuthPrincipalListingGsiSkPrefix and sk use encoded fields', () {
      final prefix = buildAuthPrincipalListingGsiSkPrefix(
        accountStatus: AuthAccountStatus.active,
        identityKind: AuthIdentityKind.usernamePassword,
      );

      expect(
        prefix,
        equals('@STATUS#active#@KIND#username_password#@ADHOC#1#'),
      );

      final sk = buildAuthPrincipalListingGsiSk(
        accountStatus: AuthAccountStatus.active,
        identityKind: AuthIdentityKind.usernamePassword,
        userId: 'user_123',
      );
      expect(
        sk,
        equals(
          '@STATUS#active#@KIND#username_password#@ADHOC#1#@USERID#user_123',
        ),
      );
      expect(sk.startsWith(prefix), isTrue);

      final parsed = parseAuthPrincipalListingGsiSk(sk);
      expect(parsed.accountStatus, equals('active'));
      expect(parsed.identityKind, equals('username_password'));
      expect(parsed.isAdHoc, isTrue);
      expect(parsed.userId, equals('user_123'));
    });

    test('buildAuthPrincipalListingGsiSk rejects unsafe sort-key values', () {
      expect(
        () => buildAuthPrincipalListingGsiSk(
          accountStatus: AuthAccountStatus.active,
          identityKind: AuthIdentityKind.usernamePassword,
          userId: 'bad#id',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('buildAuthEmailLookupPk encodes emails containing # and %', () {
      final key = buildAuthEmailLookupPk('user%name#example@domain.com');
      expect(
        key,
        equals(
          'IDENTIFIER#EMAIL#@NORMALIZEDEMAIL#user%25name%23example%40domain.com',
        ),
      );
      expect(
        parseAuthEmailLookupPk(key),
        equals('user%name#example@domain.com'),
      );
    });

    test('encodeKeyValue round-trips encoded auth key values', () {
      const value = 'person@example.com';
      expect(decodeKeyValue(encodeKeyValue(value)), equals(value));
      expect(encodeKeyValue(value), contains('%40'));
    });
  });
}
