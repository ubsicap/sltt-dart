import 'package:aws_backend/src/auth/auth_models.dart';
import 'package:aws_backend/src/storage/key_codec.dart';
import 'package:aws_backend/src/storage/value_codec.dart';

String buildAuthUserPk(String userId) {
  return buildKey([KeyLabel('USER'), KeyField('USERID', userId)]);
}

String buildAuthPrincipalSk() {
  return buildKey([KeyLabel('PRINCIPAL')]);
}

String buildAuthLookupSk() {
  return buildKey([KeyLabel('LOOKUP')]);
}

String buildAuthEmailLookupPk(String normalizedEmail) {
  return buildKey([
    KeyLabel('IDENTIFIER'),
    KeyLabel('EMAIL'),
    KeyField('NORMALIZEDEMAIL', normalizedEmail),
  ]);
}

String buildAuthUsernameLookupPk(String normalizedUsername) {
  return buildKey([
    KeyLabel('IDENTIFIER'),
    KeyLabel('USERNAME'),
    KeyField('NORMALIZEDUSERNAME', normalizedUsername),
  ]);
}

String buildAuthEmailChallengeSk() {
  return buildKey([KeyLabel('CHALLENGE'), KeyLabel('EMAIL')]);
}

String buildAuthSessionSk(String sessionId) {
  return buildKey([KeyLabel('SESSION'), KeyField('SESSIONID', sessionId)]);
}

String buildAuthSessionTokenPk(String tokenHash) {
  return buildKey([
    KeyLabel('SESSIONTOKEN'),
    KeyField('REFRESHTOKENHASH', tokenHash),
  ]);
}

String buildAuthPrincipalListingGsiPk() {
  return buildKey([KeyLabel('PRINCIPAL')]);
}

String _adHocBitFromIdentityKind(AuthIdentityKind identityKind) {
  return identityKind == AuthIdentityKind.usernamePassword ? '1' : '0';
}

String buildAuthPrincipalListingGsiSkPrefix({
  required AuthAccountStatus accountStatus,
  required AuthIdentityKind identityKind,
}) {
  assertSafeSortKeyValue(accountStatus.value);
  assertSafeSortKeyValue(identityKind.value);
  final adHocBit = _adHocBitFromIdentityKind(identityKind);
  return '${buildKey([KeyField('STATUS', accountStatus.value), KeyField('KIND', identityKind.value), KeyField('ADHOC', adHocBit)])}#';
}

String buildAuthPrincipalListingGsiSk({
  required AuthAccountStatus accountStatus,
  required AuthIdentityKind identityKind,
  required String userId,
}) {
  assertSafeSortKeyValue(accountStatus.value);
  assertSafeSortKeyValue(identityKind.value);
  assertSafeSortKeyValue(userId);
  final adHocBit = _adHocBitFromIdentityKind(identityKind);
  return buildKey([
    KeyField('STATUS', accountStatus.value),
    KeyField('KIND', identityKind.value),
    KeyField('ADHOC', adHocBit),
    KeyField('USERID', userId),
  ]);
}

String parseAuthUserPk(String pk) {
  final segments = parseKey(pk);
  if (segments.length != 2 ||
      segments[0] is! KeyLabel ||
      (segments[0] as KeyLabel).value != 'USER' ||
      segments[1] is! KeyField ||
      (segments[1] as KeyField).name != 'USERID') {
    throw FormatException('Invalid auth user pk: $pk');
  }
  return (segments[1] as KeyField).value;
}

String parseAuthEmailLookupPk(String pk) {
  final segments = parseKey(pk);
  if (segments.length != 3 ||
      segments[0] is! KeyLabel ||
      (segments[0] as KeyLabel).value != 'IDENTIFIER' ||
      segments[1] is! KeyLabel ||
      (segments[1] as KeyLabel).value != 'EMAIL' ||
      segments[2] is! KeyField ||
      (segments[2] as KeyField).name != 'NORMALIZEDEMAIL') {
    throw FormatException('Invalid auth email lookup pk: $pk');
  }
  return (segments[2] as KeyField).value;
}

String parseAuthUsernameLookupPk(String pk) {
  final segments = parseKey(pk);
  if (segments.length != 3 ||
      segments[0] is! KeyLabel ||
      (segments[0] as KeyLabel).value != 'IDENTIFIER' ||
      segments[1] is! KeyLabel ||
      (segments[1] as KeyLabel).value != 'USERNAME' ||
      segments[2] is! KeyField ||
      (segments[2] as KeyField).name != 'NORMALIZEDUSERNAME') {
    throw FormatException('Invalid auth username lookup pk: $pk');
  }
  return (segments[2] as KeyField).value;
}

String parseAuthSessionSk(String sk) {
  final segments = parseKey(sk);
  if (segments.length != 2 ||
      segments[0] is! KeyLabel ||
      (segments[0] as KeyLabel).value != 'SESSION' ||
      segments[1] is! KeyField ||
      (segments[1] as KeyField).name != 'SESSIONID') {
    throw FormatException('Invalid auth session sk: $sk');
  }
  return (segments[1] as KeyField).value;
}

String parseAuthSessionTokenPk(String pk) {
  final segments = parseKey(pk);
  if (segments.length != 2 ||
      segments[0] is! KeyLabel ||
      (segments[0] as KeyLabel).value != 'SESSIONTOKEN' ||
      segments[1] is! KeyField ||
      (segments[1] as KeyField).name != 'REFRESHTOKENHASH') {
    throw FormatException('Invalid auth session token pk: $pk');
  }
  return (segments[1] as KeyField).value;
}

class AuthPrincipalListingGsiSkParts {
  final String accountStatus;
  final String identityKind;
  final bool isAdHoc;
  final String userId;

  const AuthPrincipalListingGsiSkParts({
    required this.accountStatus,
    required this.identityKind,
    required this.isAdHoc,
    required this.userId,
  });
}

AuthPrincipalListingGsiSkParts parseAuthPrincipalListingGsiSk(String sk) {
  final segments = parseKey(sk);
  if (segments.length != 4 ||
      segments[0] is! KeyField ||
      (segments[0] as KeyField).name != 'STATUS' ||
      segments[1] is! KeyField ||
      (segments[1] as KeyField).name != 'KIND' ||
      segments[2] is! KeyField ||
      (segments[2] as KeyField).name != 'ADHOC' ||
      segments[3] is! KeyField ||
      (segments[3] as KeyField).name != 'USERID') {
    throw FormatException('Invalid auth principal listing gsi1sk: $sk');
  }

  final status = (segments[0] as KeyField).value;
  final kind = (segments[1] as KeyField).value;
  final adHocValue = (segments[2] as KeyField).value;
  if (adHocValue != '0' && adHocValue != '1') {
    throw FormatException('Invalid auth principal listing gsi1sk: $sk');
  }
  return AuthPrincipalListingGsiSkParts(
    accountStatus: status,
    identityKind: kind,
    isAdHoc: adHocValue == '1',
    userId: (segments[3] as KeyField).value,
  );
}
