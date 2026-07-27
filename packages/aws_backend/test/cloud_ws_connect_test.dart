import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Uri.parse(
    Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl,
  );
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
    expect(loginBody['userId'], isNotEmpty);
    return loginBody['accessToken'] as String;
  }

  test(
    'cloud websocket connect and subscribe ack shape for domainChange and domainStats',
    () async {
      final suffix = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
      final token = await registerAndLoginTestUser(suffix);
      final userId = '__test_user_${suffix.toLowerCase()}';

      final messages = <Map<String, dynamic>>[];
      final webSocket = await WebSocket.connect(
        wssUrl,
        headers: {'Authorization': 'Bearer $token'},
      );
      webSocket.listen(
        (dynamic raw) {
          if (raw is String) {
            final payload = jsonDecode(raw) as Map<String, dynamic>;
            messages.add(payload);
          }
        },
        onError: (error, stackTrace) => fail('WebSocket error: $error'),
        cancelOnError: true,
      );

      webSocket.add(
        jsonEncode({
          'action': WebsocketConstants.actionSubscribe,
          'notifyType': WebsocketConstants.notifyTypeDomainChange,
          'domainType': 'user',
          'domainId': userId,
          'entityType': WebsocketConstants.lastRecordEntityType,
        }),
      );
      await Future.delayed(const Duration(seconds: 3));

      final changeAck = messages.firstWhere(
        (m) =>
            m['action'] == 'subscribe' &&
            m['status'] == 'ok' &&
            m['notifyType'] == WebsocketConstants.notifyTypeDomainChange,
        orElse: () => fail('Expected domainChange subscribe ack'),
      );

      expect(changeAck['domainType'], equals('user'));
      expect(changeAck['domainId'], equals(userId));
      expect(
        changeAck['entityType'],
        equals(WebsocketConstants.lastRecordEntityType),
      );
      expect(changeAck['stats'], isA<Map<String, dynamic>>());
      final changeStatsPayload = changeAck['stats'] as Map<String, dynamic>;
      expect(changeStatsPayload['domainType'], equals('user'));
      expect(changeStatsPayload['domainId'], equals(userId));
      expect(changeStatsPayload['userId'], equals(userId));
      expect(changeStatsPayload['changeStats'], isA<Map<String, dynamic>>());
      expect(
        changeStatsPayload['entityTypeStats'],
        isA<Map<String, dynamic>>(),
      );
      expect(
        changeStatsPayload['entityTypeCollections'],
        isA<Map<String, dynamic>>(),
      );
      expect(changeStatsPayload['timestamp'], isA<String>());
      expect(changeStatsPayload['storageType'], isA<String>());

      webSocket.add(
        jsonEncode({
          'action': WebsocketConstants.actionSubscribe,
          'notifyType': WebsocketConstants.notifyTypeDomainStats,
          'domainType': 'user',
          'domainId': userId,
          'entityType': WebsocketConstants.wildcardEntityType,
        }),
      );
      await Future.delayed(const Duration(seconds: 3));

      final statsAck = messages.firstWhere(
        (m) =>
            m['action'] == 'subscribe' &&
            m['status'] == 'ok' &&
            m['notifyType'] == WebsocketConstants.notifyTypeDomainStats,
        orElse: () => fail('Expected domainStats subscribe ack'),
      );

      expect(statsAck['domainType'], equals('user'));
      expect(statsAck['domainId'], equals(userId));
      expect(
        statsAck['entityType'],
        equals(WebsocketConstants.wildcardEntityType),
      );
      expect(statsAck['subscriptionKey'], isA<String>());
      expect(statsAck['stats'], isA<Map<String, dynamic>>());
      final statsPayload = statsAck['stats'] as Map<String, dynamic>;
      expect(statsPayload['domainType'], equals('user'));
      expect(statsPayload['domainId'], equals(userId));
      expect(statsPayload['userId'], equals(userId));
      expect(statsPayload['changeStats'], isA<Map<String, dynamic>>());
      expect(statsPayload['entityTypeStats'], isA<Map<String, dynamic>>());
      expect(
        statsPayload['entityTypeCollections'],
        isA<Map<String, dynamic>>(),
      );
      expect(statsPayload['timestamp'], isA<String>());
      expect(statsPayload['storageType'], isA<String>());

      await webSocket.close(WebSocketStatus.normalClosure, 'test complete');
    },
    tags: ['internet', 'integration'],
    timeout: Timeout.none,
  );
}
