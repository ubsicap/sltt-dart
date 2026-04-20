import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'auth_models.dart';

class TokenService {
  TokenService({
    required String jwtSecret,
    Duration? accessTokenLifetime,
    Random? random,
  }) : _jwtSecret = jwtSecret,
       _accessTokenLifetime = accessTokenLifetime ?? const Duration(hours: 1),
       _random = random ?? Random.secure();

  final String _jwtSecret;
  final Duration _accessTokenLifetime;
  final Random _random;

  AuthTokenPair issueTokens({
    required AuthPrincipal principal,
    required String sessionId,
    DateTime? now,
  }) {
    final issuedAt = (now ?? DateTime.now()).toUtc();
    final expiresAt = issuedAt.add(_accessTokenLifetime);
    final jwt = JWT({
      'sub': principal.userId,
      'sid': sessionId,
      'adhoc': principal.isAdHoc,
      'verified': principal.emailVerified,
      'kind': principal.identityKind.value,
      'iat': issuedAt.millisecondsSinceEpoch ~/ 1000,
      'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
    });

    final accessToken = jwt.sign(
      SecretKey(_jwtSecret),
      algorithm: JWTAlgorithm.HS256,
    );
    final refreshBytes = List<int>.generate(32, (_) => _random.nextInt(256));
    final refreshToken = base64UrlEncode(refreshBytes);
    return AuthTokenPair(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  AuthenticatedSession verifyAccessToken(String token) {
    try {
      final verified = JWT.verify(token, SecretKey(_jwtSecret));
      final payload = verified.payload as Map<String, dynamic>;
      return AuthenticatedSession(
        userId: payload['sub'] as String? ?? '',
        sessionId: payload['sid'] as String? ?? '',
        isAdHoc: payload['adhoc'] as bool? ?? false,
        emailVerified: payload['verified'] as bool? ?? false,
      );
    } catch (_) {
      throw AuthException(
        'Invalid credentials',
        statusCode: 401,
        code: 'invalid_credentials',
      );
    }
  }

  String hashRefreshToken(String token) {
    return sha256.convert(utf8.encode(token)).toString();
  }
}
