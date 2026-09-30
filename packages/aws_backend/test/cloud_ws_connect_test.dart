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
  final wssUrl = Platform.environment['CLOUD_WSS_URL'] ?? kCloudDevWssUrl;

  Future<Map<String, dynamic>> registerAndLoginTestUser(String suffix) async {
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
    return {
      'accessToken': loginBody['accessToken'] as String,
      'userId': loginBody['userId'] as String,
    };
  }

  Future<Map<String, dynamic>> createRequestedProject({
    required String accessToken,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/project'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'name': name,
        'teamName': 'Test Team',
        'signLanguage': 'ASL',
      }),
    );
    expect(response.statusCode, equals(200));

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    expect(body['projectId'], isNotEmpty);
    expect(body['status'], equals('requested'));
    return body;
  }

  Future<Map<String, dynamic>> waitForMessage(
    List<Map<String, dynamic>> messages, {
    required String action,
    required String notifyType,
    bool Function(Map<String, dynamic> message)? predicate,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      for (final message in messages) {
        final matchesAction = message['action'] == action;
        final matchesNotifyType = message['notifyType'] == notifyType;
        final matchesPredicate = predicate == null || predicate(message);
        if (matchesAction && matchesNotifyType && matchesPredicate) {
          return message;
        }
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }

    fail('Timed out waiting for $action/$notifyType websocket message');
  }

  test(
    'cloud websocket connect and subscribe ack shape for domainChange and domainStats',
    () async {
      final suffix = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
      final login = await registerAndLoginTestUser(suffix);
      final token = login['accessToken'] as String;
      final userId = login['userId'] as String;

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

  test(
    'cloud websocket newDomainId subscription is acked and fires on project creation',
    () async {
      final suffix = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
      final login = await registerAndLoginTestUser(suffix);
      final token = login['accessToken'] as String;

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
          'notifyType': WebsocketConstants.newDomainId,
          'domainType': 'project',
          'entityType': 'project',
        }),
      );
      await Future.delayed(const Duration(seconds: 2));

      final subscribeAck = messages.firstWhere(
        (m) =>
            m['action'] == 'subscribe' &&
            m['status'] == 'ok' &&
            m['notifyType'] == WebsocketConstants.newDomainId,
        orElse: () => fail('Expected newDomainId subscribe ack'),
      );
      expect(subscribeAck['domainType'], equals('project'));
      expect(subscribeAck['domainId'], equals(''));
      expect(subscribeAck['entityType'], equals('project'));
      final newDomainIdStates = subscribeAck['states'];
      expect(newDomainIdStates, isA<Map<String, dynamic>>());
      final newDomainIdStatesMap = (newDomainIdStates as Map<String, dynamic>)
          .cast<String, dynamic>();
      final newDomainIdItems =
          newDomainIdStatesMap['items'] as List<dynamic>? ?? const [];
      expect(newDomainIdStatesMap['nextCursor'], isNull);
      expect(
        jsonEncode(newDomainIdStatesMap),
        jsonEncode(
          CrossDomainEntityStatesResponse(
            items: newDomainIdItems,
            nextCursor: null,
            count: newDomainIdItems.length,
          ).toJsonStable(),
        ),
        reason:
            'newDomainId subscription should return a stable cross-domain state envelope',
      );

      final project = await createRequestedProject(
        accessToken: token,
        name: '__test_ws_new_domain_id_$suffix',
      );
      final projectId = project['projectId'] as String;

      final changeEvent = await waitForMessage(
        messages,
        action: WebsocketConstants.actionChange,
        notifyType: WebsocketConstants.newDomainId,
        predicate: (message) =>
            (message['domainId'] as String?) == projectId &&
            (message['entityType'] as String?) == 'project',
      );
      expect(changeEvent['domainType'], equals('project'));
      expect(changeEvent['domainId'], equals(projectId));
      expect(changeEvent['entityType'], equals('project'));

      await webSocket.close(WebSocketStatus.normalClosure, 'test complete');
    },
    tags: ['internet', 'integration'],
    timeout: Timeout.none,
  );

  test(
    'cloud websocket addedMe subscription is acked and fires on new membership creation',
    () async {
      final suffix = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
      final login = await registerAndLoginTestUser(suffix);
      final token = login['accessToken'] as String;
      final userId = login['userId'] as String;

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
          'notifyType': WebsocketConstants.notifyTypeAddedMe,
          'domainType': 'membership',
          'entityType': 'member',
          'userId': userId,
        }),
      );
      await Future.delayed(const Duration(seconds: 2));

      final subscribeAck = messages.firstWhere(
        (m) =>
            m['action'] == 'subscribe' &&
            m['status'] == 'ok' &&
            m['notifyType'] == WebsocketConstants.notifyTypeAddedMe,
        orElse: () => fail('Expected addedMe subscribe ack'),
      );
      expect(subscribeAck['domainType'], equals('membership'));
      expect(subscribeAck['domainId'], equals(''));
      expect(subscribeAck['entityType'], equals('member'));
      final addedMeStates = subscribeAck['states'];
      expect(addedMeStates, isA<Map<String, dynamic>>());
      final addedMeStatesMap = (addedMeStates as Map<String, dynamic>)
          .cast<String, dynamic>();
      final addedMeItems =
          addedMeStatesMap['items'] as List<dynamic>? ?? const [];
      expect(addedMeStatesMap['nextCursor'], isNull);
      expect(
        jsonEncode(addedMeStatesMap),
        jsonEncode(
          CrossDomainEntityStatesResponse(
            items: addedMeItems,
            nextCursor: null,
            count: addedMeItems.length,
          ).toJsonStable(),
        ),
        reason:
            'addedMe subscription should return a stable cross-domain state envelope',
      );

      final project = await createRequestedProject(
        accessToken: token,
        name: '__test_ws_added_me_$suffix',
      );
      final projectId = project['projectId'] as String;

      final changeEvent = await waitForMessage(
        messages,
        action: WebsocketConstants.actionChange,
        notifyType: WebsocketConstants.notifyTypeAddedMe,
        predicate: (message) =>
            (message['domainId'] as String?) == projectId &&
            (message['entityType'] as String?) == 'member',
      );
      expect(changeEvent['domainType'], equals('membership'));
      expect(changeEvent['domainId'], equals(projectId));
      expect(changeEvent['entityType'], equals('member'));
      expect(changeEvent['change'], isA<Map<String, dynamic>>());

      await webSocket.close(WebSocketStatus.normalClosure, 'test complete');
    },
    tags: ['internet', 'integration'],
    timeout: Timeout.none,
  );
}
