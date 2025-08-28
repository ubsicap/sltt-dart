import 'dart:async';
import 'dart:core';

/// Test-time registry allowing another package to register an external
/// API base URL for network-style tests to consume.
///
/// Usage:
/// - Caller: registerExternalApiBaseUrl(Uri.parse('http://localhost:8081'))
/// - Consumer (tests): await waitForExternalApiBaseUrl(Duration(seconds:5))

final Completer<Uri> _externalApiBaseUrl = Completer<Uri>();

void registerExternalApiBaseUrl(Uri baseUrl) {
  if (!_externalApiBaseUrl.isCompleted) {
    _externalApiBaseUrl.complete(baseUrl);
  }
}

/// Wait for an external API base URL to be registered. Returns null on timeout.
Future<Uri?> waitForExternalApiBaseUrl(Duration timeout) async {
  try {
    return await _externalApiBaseUrl.future.timeout(timeout);
  } catch (_) {
    return null;
  }
}
