import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sltt_core/sltt_core.dart';

typedef WebSocketMessageHandler = void Function(dynamic rawMessage);
typedef WebSocketDoneHandler = void Function();
typedef WebSocketErrorHandler =
    void Function(dynamic error, StackTrace stackTrace);

class SyncManagerWebSocketClient {
  SyncManagerWebSocketClient({
    required String cloudWssUrl,
    String? authToken,
    this.onMessage,
    this.onDone,
    this.onError,
  }) : _cloudWssUrl = cloudWssUrl,
       _authToken = authToken;

  String _cloudWssUrl;
  String? _authToken;
  WebSocket? _webSocket;
  bool _isConnecting = false;

  final WebSocketMessageHandler? onMessage;
  final WebSocketDoneHandler? onDone;
  final WebSocketErrorHandler? onError;

  bool get isOpen =>
      _webSocket != null && _webSocket!.readyState == WebSocket.open;
  bool get isConnecting => _isConnecting;
  bool get hasAuth => _authToken?.isNotEmpty == true;

  String get cloudWssUrl => _cloudWssUrl;
  String? get authToken => _authToken;

  void updateAuthToken(String authToken) {
    _authToken = authToken;
  }

  void updateCloudWssUrl(String cloudWssUrl) {
    _cloudWssUrl = cloudWssUrl;
  }

  Future<void> connect() async {
    if (isOpen || _isConnecting) {
      return;
    }
    _isConnecting = true;
    try {
      final headers = <String, String>{};
      if (hasAuth) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      _webSocket = await WebSocket.connect(
        _cloudWssUrl,
        headers: headers.isEmpty ? null : headers,
      );
      _webSocket?.pingInterval = const Duration(seconds: 20);
      _webSocket?.listen(
        onMessage,
        onDone: onDone,
        onError: (error, stackTrace) {
          onError?.call(error, stackTrace);
        },
        cancelOnError: true,
      );
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _webSocket?.close(WebSocketStatus.normalClosure, 'client_shutdown');
    } catch (_) {
      // ignore
    }
    _webSocket = null;
  }

  void send(Map<String, dynamic> message) {
    if (!isOpen) {
      throw StateError('Websocket is not open');
    }
    _webSocket?.add(jsonEncode(message));
  }

  void subscribe(
    String domainType,
    String domainId, {
    required String notifyType,
    String entityType = WebsocketConstants.lastRecordEntityType,
  }) {
    send({
      'action': WebsocketConstants.actionSubscribe,
      'notifyType': notifyType,
      'domainType': domainType,
      'domainId': domainId,
      'entityType': entityType,
    });
  }

  void unsubscribe(
    String domainType,
    String domainId, {
    required String notifyType,
    String entityType = WebsocketConstants.lastRecordEntityType,
  }) {
    send({
      'action': WebsocketConstants.actionUnsubscribe,
      'notifyType': notifyType,
      'domainType': domainType,
      'domainId': domainId,
      'entityType': entityType,
    });
  }
}
