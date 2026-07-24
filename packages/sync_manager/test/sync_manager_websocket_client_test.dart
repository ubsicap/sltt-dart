import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/sync_manager_websocket_client.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudPrdApiUrl;
  final wssUrl = Platform.environment['CLOUD_WSS_URL'] ?? kCloudPrdWssUrl;

  Future<String> registerAndLoginTestUser(String suffix) async {
    final email = 'cloud-test-user-$suffix@example.com';
    final name = 'Test User $suffix';
    final password = 'secret123';

    final registerResponse = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': 'ignored-test-id',
        'name': name,
        'dateOfBirth': '1990-01-01',
        'email': email,
        'password': password,
      }),
    );
    expect(registerResponse.statusCode, equals(200));
    final registerBody =
        jsonDecode(registerResponse.body) as Map<String, dynamic>;
    expect(
      registerBody['status'],
      anyOf(equals('verified'), equals('authenticated')),
    );

    final loginResponse = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': email, 'password': password}),
    );
    expect(loginResponse.statusCode, equals(200));
    final loginBody = jsonDecode(loginResponse.body) as Map<String, dynamic>;
    expect(loginBody['accessToken'], isNotEmpty);
    return loginBody['accessToken'] as String;
  }

  test(
    'websocket client connect/disconnect and subscribe/unsubscribe',
    () async {
      final suffix = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
      final token = await registerAndLoginTestUser(suffix);
      final userId = '__test_user_${suffix.toLowerCase()}';

      final messages = <Map<String, dynamic>>[];
      void onMessage(dynamic raw) {
        if (raw is String) {
          final payload = jsonDecode(raw) as Map<String, dynamic>;
          messages.add(payload);
        }
      }

      final client = SyncManagerWebSocketClient(
        cloudWssUrl: wssUrl,
        authToken: token,
        onMessage: onMessage,
        onDone: () => print('ws done'),
        onError: (error, stackTrace) => fail('WebSocket error: $error'),
      );

      await client.connect();
      expect(client.isOpen, isTrue);

      client.subscribe('user', userId);
      await Future.delayed(const Duration(seconds: 3));

      expect(
        messages,
        anyElement(
          predicate<Map<String, dynamic>>(
            (m) => m['action'] == 'subscribe' && m['status'] == 'ok',
          ),
        ),
      );

      client.unsubscribe('user', userId);
      await Future.delayed(const Duration(seconds: 3));

      expect(
        messages,
        anyElement(
          predicate<Map<String, dynamic>>(
            (m) => m['action'] == 'unsubscribe' && m['status'] == 'ok',
          ),
        ),
      );

      await client.disconnect();
      expect(client.isOpen, isFalse);
    },
    tags: ['internet', 'integration'],
  );
}
