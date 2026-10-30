import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sltt_core/sltt_core.dart';

typedef WebSocketMessageHandler = void Function(dynamic rawMessage);
typedef WebSocketDoneHandler = void Function();
typedef WebSocketErrorHandler =
    void Function(dynamic error, StackTrace stackTrace);
typedef WebSocketConnector =
    Future<WebSocket> Function(String url, {Map<String, dynamic>? headers});

/// Narrow connection contract used by [SyncManager]. Keeping orchestration
/// dependent on this interface allows deterministic fake connections in tests.
abstract interface class SyncManagerWebSocketConnection {
  bool get isOpen;
  bool get isConnecting;
  String? get authToken;

  Future<void> connect();
  Future<void> disconnect();
  void updateAuthToken(String authToken);
  void updateCloudWssUrl(String cloudWssUrl);
  void send(Map<String, dynamic> message);
  void subscribe(
    String domainType, {
    String domainId = '',
    required String notifyType,
    String entityType = WebsocketConstants.lastRecordEntityType,
    String? userId,
  });
}

typedef SyncManagerWebSocketClientFactory =
    SyncManagerWebSocketConnection Function({
      required String cloudWssUrl,
      String? authToken,
      WebSocketMessageHandler? onMessage,
      WebSocketDoneHandler? onDone,
      WebSocketErrorHandler? onError,
    });

class SyncManagerWebSocketClient implements SyncManagerWebSocketConnection {
  SyncManagerWebSocketClient({
    required String cloudWssUrl,
    String? authToken,
    this.onMessage,
    this.onDone,
    this.onError,
    WebSocketConnector? connector,
  }) : _cloudWssUrl = cloudWssUrl,
       _authToken = authToken,
       _connector = connector ?? WebSocket.connect;

  String _cloudWssUrl;
  String? _authToken;
  WebSocket? _webSocket;
  final WebSocketConnector _connector;
  bool _isConnecting = false;

  final WebSocketMessageHandler? onMessage;
  final WebSocketDoneHandler? onDone;
  final WebSocketErrorHandler? onError;

  @override
  bool get isOpen =>
      _webSocket != null && _webSocket!.readyState == WebSocket.open;
  @override
  bool get isConnecting => _isConnecting;
  bool get hasAuth => _authToken?.isNotEmpty == true;

  String get cloudWssUrl => _cloudWssUrl;
  @override
  String? get authToken => _authToken;

  @override
  void updateAuthToken(String authToken) {
    _authToken = authToken;
  }

  @override
  void updateCloudWssUrl(String cloudWssUrl) {
    _cloudWssUrl = cloudWssUrl;
  }

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 15)}) async {
    if (isOpen) return;
    if (_isConnecting) {
      throw StateError('Websocket connection is already in progress');
    }

    _isConnecting = true;
    WebSocket? socket;
    try {
      final headers = <String, String>{};
      if (hasAuth) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      final connectFuture = _connector(
        _cloudWssUrl,
        headers: headers.isEmpty ? null : headers,
      );
      try {
        socket = await connectFuture.timeout(timeout);
      } on TimeoutException {
        // WebSocket.connect itself is not cancellable. Close a socket if the
        // underlying handshake completes after our timeout has fired.
        unawaited(
          connectFuture.then<void>((lateSocket) async {
            await lateSocket.close(
              WebSocketStatus.goingAway,
              'connect_timed_out',
            );
          }, onError: (Object _) {}),
        );
        rethrow;
      }
      final connectedSocket = socket;
      _webSocket = connectedSocket;
      connectedSocket.pingInterval = const Duration(seconds: 20);
      connectedSocket.listen(
        onMessage,
        onDone: () {
          if (identical(_webSocket, connectedSocket)) _webSocket = null;
          onDone?.call();
        },
        onError: (error, stackTrace) {
          // Keep the stream alive long enough to receive onDone as well. The
          // manager's callback is guarded by client identity.
          onError?.call(error, stackTrace);
          unawaited(
            connectedSocket.close(WebSocketStatus.goingAway, 'stream_error'),
          );
        },
        cancelOnError: false,
      );
    } catch (_) {
      if (identical(_webSocket, socket)) _webSocket = null;
      try {
        await socket?.close(WebSocketStatus.goingAway, 'connect_failed');
      } catch (_) {
        // Ignore cleanup errors; preserve the original connect failure.
      }
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  @override
  Future<void> disconnect() async {
    final socket = _webSocket;
    _webSocket = null;
    try {
      await socket?.close(WebSocketStatus.normalClosure, 'client_shutdown');
    } catch (_) {
      // ignore
    }
  }

  @override
  void send(Map<String, dynamic> message) {
    if (!isOpen) {
      throw StateError('Websocket is not open');
    }
    _webSocket?.add(jsonEncode(message));
  }

  @override
  void subscribe(
    String domainType, {
    String domainId = '',
    required String notifyType,
    String entityType = WebsocketConstants.lastRecordEntityType,
    String? userId,
  }) {
    final payload = <String, dynamic>{
      'action': WebsocketConstants.actionSubscribe,
      'notifyType': notifyType,
      'domainType': domainType,
      'domainId': domainId,
      'entityType': entityType,
      if (userId != null && userId.isNotEmpty) 'userId': userId,
    };
    send(payload);
  }

  void unsubscribe(
    String domainType, {
    String domainId = '',
    required String notifyType,
    String entityType = WebsocketConstants.lastRecordEntityType,
    String? userId,
  }) {
    final payload = <String, dynamic>{
      'action': WebsocketConstants.actionUnsubscribe,
      'notifyType': notifyType,
      'domainType': domainType,
      'domainId': domainId,
      'entityType': entityType,
      if (userId != null && userId.isNotEmpty) 'userId': userId,
    };
    send(payload);
  }
}
