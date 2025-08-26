import 'package:sltt_core/src/services/uid_service.dart';

/// Simple in-memory clientId provider.
///
/// The clientId is generated once per process (lazy) using
/// `generateRandomChars(4)` and cached. Tests can override/reset it.
class ClientIdService {
  static String? _clientId;

  /// Returns the cached clientId or generates one on first access.
  static String get clientId => _clientId ??= generateRandomChars(4);

  /// Override the clientId (useful for deterministic tests).
  static set clientId(String v) => _clientId = v;

  /// Reset the cached value (test helper).
  static void reset([String? v]) => _clientId = v;
}
