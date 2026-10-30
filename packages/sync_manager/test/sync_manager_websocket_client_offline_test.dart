import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sync_manager/src/sync_manager_websocket_client.dart';
import 'package:test/test.dart';

void main() {
  group('SyncManagerWebSocketClient', () {
    late FakeWebSocket socket;
    late SyncManagerWebSocketClient client;

    setUp(() {
      socket = FakeWebSocket();
      client = SyncManagerWebSocketClient(
        cloudWssUrl: 'wss://unit.test/ws',
        authToken: 'test-token',
        connector: (url, {headers}) async {
          expect(url, 'wss://unit.test/ws');
          expect(headers?['Authorization'], 'Bearer test-token');
          return socket;
        },
      );
    });

    test('connects and reports an open socket', () async {
      await client.connect();

      expect(client.isOpen, isTrue);
      expect(client.isConnecting, isFalse);
      expect(socket.pingInterval, const Duration(seconds: 20));
    });

    test('subscribe sends a correctly scoped request', () async {
      await client.connect();

      client.subscribe(
        'user',
        domainId: 'user-123',
        notifyType: 'domainStats',
        entityType: '*',
        userId: 'user-123',
      );

      expect(socket.sentMessages, hasLength(1));
      expect(jsonDecode(socket.sentMessages.single), {
        'action': 'subscribe',
        'notifyType': 'domainStats',
        'domainType': 'user',
        'domainId': 'user-123',
        'entityType': '*',
        'userId': 'user-123',
      });
    });

    test('unsubscribe sends a correctly scoped request', () async {
      await client.connect();

      client.unsubscribe(
        'user',
        domainId: 'user-123',
        notifyType: 'domainStats',
        entityType: '*',
      );

      expect(socket.sentMessages, hasLength(1));
      expect(jsonDecode(socket.sentMessages.single), {
        'action': 'unsubscribe',
        'notifyType': 'domainStats',
        'domainType': 'user',
        'domainId': 'user-123',
        'entityType': '*',
      });
    });

    test('does not silently buffer sends while disconnected', () {
      expect(
        () => client.subscribe('user', notifyType: 'domainStats'),
        throwsStateError,
      );
      expect(
        () => client.unsubscribe('user', notifyType: 'domainStats'),
        throwsStateError,
      );
      expect(socket.sentMessages, isEmpty);
    });

    test('disconnect closes the socket and clears open state', () async {
      await client.connect();

      await client.disconnect();

      expect(socket.closeCalls, 1);
      expect(client.isOpen, isFalse);
    });

    test('forwards server acknowledgments to the message handler', () async {
      final received = <dynamic>[];
      final messageReceived = Completer<void>();
      final ackClient = SyncManagerWebSocketClient(
        cloudWssUrl: 'wss://unit.test/ws',
        connector: (url, {headers}) async => socket,
        onMessage: (message) {
          received.add(message);
          if (!messageReceived.isCompleted) messageReceived.complete();
        },
      );
      await ackClient.connect();
      final ack = {
        'action': 'unsubscribe',
        'status': 'ok',
        'notifyType': 'domainStats',
        'domainType': 'user',
        'domainId': 'user-123',
        'entityType': '*',
      };

      socket.serverSend(jsonEncode(ack));
      await messageReceived.future.timeout(const Duration(seconds: 1));

      expect(received, [jsonEncode(ack)]);
      await ackClient.disconnect();
    });
  });
}

/// A deterministic WebSocket test double. It models only the WebSocket
/// behavior consumed by SyncManagerWebSocketClient.
class FakeWebSocket implements WebSocket {
  final StreamController<dynamic> _incoming = StreamController<dynamic>();
  final List<String> sentMessages = <String>[];
  int _readyState = WebSocket.connecting;
  int closeCalls = 0;
  @override
  Duration? pingInterval;

  FakeWebSocket() {
    _readyState = WebSocket.open;
  }

  @override
  int get readyState => _readyState;

  @override
  void add(Object? data) {
    sentMessages.add(data.toString());
  }

  @override
  Future<void> close([int? code, String? reason]) async {
    closeCalls++;
    _readyState = WebSocket.closed;
    if (!_incoming.isClosed) await _incoming.close();
  }

  void serverSend(dynamic message) => _incoming.add(message);

  @override
  StreamSubscription<dynamic> listen(
    void Function(dynamic event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => _incoming.stream.listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
