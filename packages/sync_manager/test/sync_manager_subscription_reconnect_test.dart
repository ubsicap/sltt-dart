import 'dart:async';

import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/sync_manager.dart';
import 'package:sync_manager/src/sync_manager_websocket_client.dart';
import 'package:test/test.dart';

void main() {
  group('SyncManager WebSocket subscription reconnect integration', () {
    late List<FakeWebSocketConnection> clients;
    late Completer<FakeWebSocketConnection> firstClientCreated;
    late Completer<FakeWebSocketConnection> secondClientCreated;
    late SyncManager manager;

    setUp(() {
      clients = <FakeWebSocketConnection>[];
      firstClientCreated = Completer<FakeWebSocketConnection>();
      secondClientCreated = Completer<FakeWebSocketConnection>();
      manager = SyncManager.withWebSocketClientFactory(
        reconnectDelay: (_) => Duration.zero,
        webSocketClientFactory:
            ({required cloudWssUrl, authToken, onMessage, onDone, onError}) {
              final client = FakeWebSocketConnection(
                cloudWssUrl: cloudWssUrl,
                authToken: authToken,
                onMessage: onMessage,
                onDone: onDone,
                onError: onError,
              );
              clients.add(client);
              if (clients.length == 1 && !firstClientCreated.isCompleted) {
                firstClientCreated.complete(client);
              }
              if (clients.length == 2 && !secondClientCreated.isCompleted) {
                secondClientCreated.complete(client);
              }
              return client;
            },
      );
    });

    tearDown(() async {
      await manager.close();
    });

    test('cloud availability must begin available', () async {
      expect(
        manager.cloudServiceStatus,
        CloudServiceStatus.available,
        reason: 'Cloud availability must begin available',
      );
    });

    test('replays desired subscriptions after disconnect and ignores stale ack', () async {
      manager.subscribeToDomain(
        notifyType: WebsocketConstants.notifyTypeDomainChange,
        domainType: 'user',
        domainId: 'user-123',
      );
      manager.updateAuthToken('test-token');
      final first = await firstClientCreated.future.timeout(
        const Duration(seconds: 1),
      );
      await first.connected.future.timeout(const Duration(seconds: 1));
      expect(
        manager.cloudServiceStatus,
        CloudServiceStatus.available,
        reason:
            'Cloud availability must become available only after the manager has a genuinely open WebSocket and has installed its listeners.',
      );
      await first.waitForMessageCount(WebsocketConstants.actionSubscribe, 1);

      expect(
        first.sentSubscriptions,
        hasLength(1),
        reason:
            'The initial connection must flush the desired subscription that was queued before authentication.',
      );
      expect(
        manager.pendingDomainChangeKeys,
        contains('user/user-123'),
        reason:
            'A sent subscribe must remain pending until its server acknowledgment arrives.',
      );
      expect(
        manager.subscribedDomainChangeKeys,
        isNot(contains('user/user-123')),
        reason:
            'Sending a subscribe frame must not be mistaken for server confirmation.',
      );

      first.serverSend(_subscribeAck());
      await Future<void>.delayed(Duration.zero);
      expect(
        manager.subscribedDomainChangeKeys,
        contains('user/user-123'),
        reason:
            'A successful acknowledgment on the first connection must confirm the desired subscription.',
      );

      first.serverDisconnect();
      expect(
        manager.cloudServiceStatus,
        CloudServiceStatus.unavailable,
        reason:
            'A WebSocket disconnect must immediately make cloud availability unavailable.',
      );
      expect(
        manager.subscribedDomainChangeKeys,
        isNot(contains('user/user-123')),
        reason:
            'Losing the first connection must invalidate its server-confirmed subscription state.',
      );
      expect(
        manager.pendingDomainChangeKeys,
        contains('user/user-123'),
        reason:
            'A desired subscription must return to pending state after connection loss.',
      );

      final second = await secondClientCreated.future.timeout(
        const Duration(seconds: 1),
      );
      await second.connected.future.timeout(const Duration(seconds: 1));
      await _waitForCloudServiceStatus(
        manager,
        CloudServiceStatus.available,
      );
      expect(
        manager.cloudServiceStatus,
        CloudServiceStatus.available,
        reason: 'A replacement open WebSocket must restore cloud availability.',
      );
      await second.waitForMessageCount(WebsocketConstants.actionSubscribe, 1);
      expect(
        second.sentSubscriptions,
        hasLength(1),
        reason:
            'The replacement connection must replay the desired subscription because the server may have discarded it.',
      );

      first.serverDisconnect();
      await Future<void>.delayed(Duration.zero);
      expect(
        manager.cloudServiceStatus,
        CloudServiceStatus.available,
        reason:
            'A stale disconnect callback from the superseded socket must not mark the current open WebSocket unavailable.',
      );
      expect(
        clients,
        hasLength(2),
        reason:
            'A duplicate done callback from a superseded client must not schedule another reconnect or replace the active connection.',
      );

      first.serverSend(_subscribeAck());
      await Future<void>.delayed(Duration.zero);
      expect(
        manager.pendingDomainChangeKeys,
        contains('user/user-123'),
        reason:
            'An acknowledgment delivered by a superseded connection must not confirm a subscription on the replacement connection.',
      );
      expect(
        manager.subscribedDomainChangeKeys,
        isNot(contains('user/user-123')),
        reason:
            'Stale callbacks from the old client must not mutate current connection state.',
      );

      second.serverSend(_subscribeAck());
      await Future<void>.delayed(Duration.zero);
      expect(
        manager.pendingDomainChangeKeys,
        isNot(contains('user/user-123')),
        reason:
            'The replacement connection acknowledgment must clear the pending subscribe state.',
      );
      expect(
        manager.subscribedDomainChangeKeys,
        contains('user/user-123'),
        reason:
            'Only the replacement connection acknowledgment may confirm the replayed subscription.',
      );
    });

    test('replays confirmed subscriptions after a socket error', () async {
      manager.subscribeToDomain(
        notifyType: WebsocketConstants.notifyTypeDomainChange,
        domainType: 'user',
        domainId: 'user-123',
      );
      manager.updateAuthToken('test-token');
      final first = await firstClientCreated.future.timeout(
        const Duration(seconds: 1),
      );
      await first.connected.future.timeout(const Duration(seconds: 1));
      await first.waitForMessageCount(WebsocketConstants.actionSubscribe, 1);
      first.serverSend(_subscribeAck());
      await Future<void>.delayed(Duration.zero);

      first.serverError(StateError('simulated socket failure'));

      expect(
        manager.cloudServiceStatus,
        CloudServiceStatus.unavailable,
        reason:
            'A WebSocket transport error must immediately mark the connection unavailable.',
      );
      expect(
        manager.pendingDomainChangeKeys,
        contains('user/user-123'),
        reason:
            'A socket error must invalidate the old connection confirmation and return the desired subscription to pending state.',
      );
      expect(
        manager.subscribedDomainChangeKeys,
        isNot(contains('user/user-123')),
        reason:
            'A subscription acknowledged on a failed connection must not remain confirmed.',
      );

      final second = await secondClientCreated.future.timeout(
        const Duration(seconds: 1),
      );
      await second.connected.future.timeout(const Duration(seconds: 1));
      await _waitForCloudServiceStatus(
        manager,
        CloudServiceStatus.available,
      );
      expect(
        manager.cloudServiceStatus,
        CloudServiceStatus.available,
        reason:
            'A successfully reopened WebSocket must restore availability after a transport error.',
      );
      await second.waitForMessageCount(WebsocketConstants.actionSubscribe, 1);
      expect(
        second.sentSubscriptions,
        hasLength(1),
        reason:
            'A replacement connection must replay subscriptions after an error callback just as it does after a normal socket close.',
      );
    });

    test('replays an unacknowledged unsubscribe after disconnect', () async {
      manager.subscribeToDomain(
        notifyType: WebsocketConstants.notifyTypeDomainChange,
        domainType: 'user',
        domainId: 'user-123',
      );
      manager.updateAuthToken('test-token');
      final first = await firstClientCreated.future.timeout(
        const Duration(seconds: 1),
      );
      await first.connected.future.timeout(const Duration(seconds: 1));
      await first.waitForMessageCount(WebsocketConstants.actionSubscribe, 1);
      first.serverSend(_subscribeAck());
      await Future<void>.delayed(Duration.zero);

      manager.unsubscribeFromDomain(
        notifyType: WebsocketConstants.notifyTypeDomainChange,
        domainType: 'user',
        domainId: 'user-123',
      );

      expect(
        first.sentUnsubscriptions,
        hasLength(1),
        reason:
            'Unsubscribing on an open connection must send one unsubscribe request.',
      );

      first.serverDisconnect();
      final second = await secondClientCreated.future.timeout(
        const Duration(seconds: 1),
      );
      await second.connected.future.timeout(const Duration(seconds: 1));
      await second.waitForMessageCount(WebsocketConstants.actionUnsubscribe, 1);

      expect(
        second.sentUnsubscriptions,
        hasLength(1),
        reason:
            'An unsubscribe without a successful acknowledgment must be replayed on the replacement connection.',
      );
      expect(
        second.sentUnsubscriptions.single['domainId'],
        'user-123',
        reason:
            'The replayed unsubscribe must retain the original subscription identity.',
      );

      second.serverSend(_unsubscribeAck());
      await Future<void>.delayed(Duration.zero);
      expect(
        second.isOpen,
        isFalse,
        reason:
            'After the final pending unsubscribe is acknowledged and no work remains, SyncManager should close the idle connection.',
      );
    });
  });
}

Map<String, dynamic> _subscribeAck() => <String, dynamic>{
  'action': WebsocketConstants.actionSubscribe,
  'status': 'ok',
  'notifyType': WebsocketConstants.notifyTypeDomainChange,
  'domainType': 'user',
  'domainId': 'user-123',
  'entityType': WebsocketConstants.lastRecordEntityType,
};

Map<String, dynamic> _unsubscribeAck() => <String, dynamic>{
  'action': WebsocketConstants.actionUnsubscribe,
  'status': 'ok',
  'notifyType': WebsocketConstants.notifyTypeDomainChange,
  'domainType': 'user',
  'domainId': 'user-123',
  'entityType': WebsocketConstants.lastRecordEntityType,
};

Future<void> _waitForCloudServiceStatus(
  SyncManager manager,
  CloudServiceStatus expected,
) async {
  if (manager.cloudServiceStatus == expected) return;
  await manager.cloudServiceStatusEvents
      .firstWhere((status) => status == expected)
      .timeout(const Duration(seconds: 1));
}

/// Mock connection used by integration tests. It exercises SyncManager's real
/// callbacks, replay logic, and acknowledgment handling without network I/O.
class FakeWebSocketConnection implements SyncManagerWebSocketConnection {
  FakeWebSocketConnection({
    required this.cloudWssUrl,
    required this.authToken,
    this.onMessage,
    this.onDone,
    this.onError,
  });

  final String cloudWssUrl;
  @override
  String? authToken;
  final WebSocketMessageHandler? onMessage;
  final WebSocketDoneHandler? onDone;
  final WebSocketErrorHandler? onError;
  final Completer<void> connected = Completer<void>();
  final List<Map<String, dynamic>> sentMessages = <Map<String, dynamic>>[];
  final List<_SentMessageWaiter> _sentMessageWaiters = <_SentMessageWaiter>[];
  bool _isOpen = false;

  @override
  bool get isOpen => _isOpen;

  @override
  bool get isConnecting => false;

  List<Map<String, dynamic>> get sentSubscriptions => sentMessages
      .where(
        (message) => message['action'] == WebsocketConstants.actionSubscribe,
      )
      .toList(growable: false);

  List<Map<String, dynamic>> get sentUnsubscriptions => sentMessages
      .where(
        (message) => message['action'] == WebsocketConstants.actionUnsubscribe,
      )
      .toList(growable: false);

  /// Waits until SyncManager has actually flushed a frame after connecting.
  /// The [connected] completer only signals transport-open; it intentionally
  /// does not imply that SyncManager's post-connect flush has run.
  Future<void> waitForMessageCount(String action, int count) async {
    if (_messageCount(action) >= count) return;

    final waiter = _SentMessageWaiter(action: action, count: count);
    _sentMessageWaiters.add(waiter);
    try {
      await waiter.completer.future.timeout(const Duration(seconds: 1));
    } finally {
      _sentMessageWaiters.remove(waiter);
    }
  }

  int _messageCount(String action) =>
      sentMessages.where((message) => message['action'] == action).length;

  @override
  Future<void> connect() async {
    _isOpen = true;
    if (!connected.isCompleted) connected.complete();
  }

  @override
  Future<void> disconnect() async {
    _isOpen = false;
  }

  @override
  void updateAuthToken(String authToken) {
    this.authToken = authToken;
  }

  @override
  void updateCloudWssUrl(String cloudWssUrl) {}

  @override
  void send(Map<String, dynamic> message) {
    if (!_isOpen) throw StateError('Fake WebSocket is not open');
    sentMessages.add(Map<String, dynamic>.from(message));
    for (final waiter in _sentMessageWaiters.toList()) {
      if (_messageCount(waiter.action) >= waiter.count &&
          !waiter.completer.isCompleted) {
        waiter.completer.complete();
      }
    }
  }

  @override
  void subscribe(
    String domainType, {
    String domainId = '',
    required String notifyType,
    String entityType = WebsocketConstants.lastRecordEntityType,
    String? userId,
  }) {
    send(<String, dynamic>{
      'action': WebsocketConstants.actionSubscribe,
      'notifyType': notifyType,
      'domainType': domainType,
      'domainId': domainId,
      'entityType': entityType,
      if (userId != null && userId.isNotEmpty) 'userId': userId,
    });
  }

  void serverSend(Map<String, dynamic> message) {
    onMessage?.call(message);
  }

  void serverDisconnect() {
    _isOpen = false;
    onDone?.call();
  }

  void serverError(Object error) {
    _isOpen = false;
    // This is a synthetic transport error, not an exception thrown by the test.
    // An empty stack keeps the expected SyncManager warning from looking like
    // an uncaught test failure in the test output.
    onError?.call(error, StackTrace.empty);
  }
}

/// A deterministic signal for frames emitted after the fake transport opens.
class _SentMessageWaiter {
  _SentMessageWaiter({required this.action, required this.count});

  final String action;
  final int count;
  final Completer<void> completer = Completer<void>();
}
