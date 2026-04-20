import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class PasswordHashResult {
  const PasswordHashResult({
    required this.hash,
    required this.salt,
    required this.iterations,
  });

  final String hash;
  final String salt;
  final int iterations;
}

class PasswordHashService {
  PasswordHashService({this.iterations = 120000, Random? random})
    : _random = random ?? Random.secure();

  final int iterations;
  final Random _random;

  Future<PasswordHashResult> hashPassword(String password) async {
    final saltBytes = List<int>.generate(16, (_) => _random.nextInt(256));
    final hash = await _derive(password: password, saltBytes: saltBytes);
    return PasswordHashResult(
      hash: base64UrlEncode(hash.bytes),
      salt: base64UrlEncode(saltBytes),
      iterations: iterations,
    );
  }

  Future<bool> verifyPassword({
    required String password,
    required String expectedHash,
    required String salt,
    required int iterations,
  }) async {
    final saltBytes = base64Url.decode(base64Url.normalize(salt));
    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    final derived = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: saltBytes,
    );
    final actualHash = base64UrlEncode(await derived.extractBytes());
    return actualHash == expectedHash;
  }

  Future<SecretKeyData> _derive({
    required String password,
    required List<int> saltBytes,
  }) async {
    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    final derived = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: saltBytes,
    );
    return derived.extract();
  }
}
