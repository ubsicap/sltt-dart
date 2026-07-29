import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/entity_state_job_queue_counts.dart';
import 'package:sync_manager/src/models/cursor_sync_state.dart';
import 'package:sync_manager/src/models/domain_stats_update.dart';
import 'package:sync_manager/src/models/isar_change_log_entry.dart';
import 'package:sync_manager/src/models/isar_entity_type_sync_state.dart';

import 'entity_state_pagination_service.dart';
import 'entity_state_pagination_service_config.dart';
import 'isar_storage_service.dart';
import 'sync_manager_websocket_client.dart';

class SyncManager {
  static SyncManager? _instance;
  static SyncManager get instance => _instance ??= SyncManager._();

  SyncManager._();

  final Dio _dio = Dio();
  late final IsarStorageService _localStorage;
  bool _ownsLocalStorage = true;

  // API endpoints - defaults to AWS dev cloud, can be overridden for testing
  String _cloudStorageUrl =
      Platform.environment['CLOUD_BASE_URL'] ?? kCloudPrdApiUrl;
  String _cloudWssUrl =
      Platform.environment['CLOUD_WSS_URL'] ?? kCloudPrdWssUrl;

  bool _initialized = false;

  // Debounced sync state
  Timer? _syncDebounceTimer;
  StreamSubscription<void>? _changeLogSubscription;
  StreamSubscription<EntityStateFetchEvent>? _singleEntityStateSubscription;
  StreamSubscription<EntityStateFetchEvent>? _collectionEntityStateSubscription;
  final Map<String, StreamSubscription<List<IsarChangeLogEntry>>>
  _localDomainChangeLogSubscriptions = {};
  final Map<String, StreamSubscription<List<IsarEntityTypeSyncState>>>
  _localDomainStateSubscriptions = {};
  final Map<String, StreamSubscription<List<CursorSyncState>>>
  _localDomainCursorSyncStateSubscriptions = {};
  final Map<String, Timer> _localDomainStatsDebounceTimers = {};
  Duration localDomainStatsDebounceDuration = const Duration(milliseconds: 500);
  bool _autoOutsyncEnabled = false;
  bool _autoDownsyncEnabled = false;
  final Set<String> _subscribedDomainChangeKeys = <String>{};
  final Set<String> _subscribedDomainStatsKeys = <String>{};
  final Map<String, int> _remoteLastDomainSeqByDomain = {};
  final Map<String, DateTime> _remoteLastDomainChangeAtByDomain = {};
  final Map<String, DomainStatsResponse> _cachedCloudDomainStatsByDomain = {};
  final StreamController<CloudDomainStatsUpdate>
  _cloudDomainStatsEventsController =
      StreamController<CloudDomainStatsUpdate>.broadcast();
  final StreamController<LocalDomainStatsUpdate>
  _localDomainStatsEventsController =
      StreamController<LocalDomainStatsUpdate>.broadcast();
  String? _authToken;
  SyncManagerWebSocketClient? _webSocketClient;
  bool _isWebSocketConnecting = false;
  int _webSocketReconnectAttempts = 0;
  Timer? _webSocketReconnectTimer;
  bool _downsyncInFlight = false;

  // Public getters for testing
  bool get autoOutsyncEnabled => _autoOutsyncEnabled;
  bool get autoDownsyncEnabled => _autoDownsyncEnabled;
  StreamSubscription<void>? get changeLogSubscription => _changeLogSubscription;
  Set<String> get subscribedDomainChangeKeys => _subscribedDomainChangeKeys;
  Set<String> get subscribedDomainStatsKeys => _subscribedDomainStatsKeys;
  Stream<CloudDomainStatsUpdate> get cloudDomainStatsEvents =>
      _cloudDomainStatsEventsController.stream;
  Stream<LocalDomainStatsUpdate> get localDomainStatsEvents =>
      _localDomainStatsEventsController.stream;
  EntityStatePaginationService? _entityStatePaginationService;
  Stream<EntityStateFetchEvent> get singleEntityStateEvents =>
      entityStatePaginationService.singleEntityEvents;
  Stream<EntityStateFetchEvent> get collectionEntityStateEvents =>
      entityStatePaginationService.collectionEntityEvents;
  EntityStatePaginationServiceConfig _entityStatePaginationServiceConfig =
      const EntityStatePaginationServiceConfig();

  EntityStatePaginationService _createEntityStatePaginationService() {
    final config = _entityStatePaginationServiceConfig;
    return EntityStatePaginationService(
      baseUrl: _cloudStorageUrl,
      maxConcurrentRequests: config.maxConcurrentRequests,
      singleRequestDebounce: config.singleRequestDebounce,
      workspacePrefix: config.workspacePrefix,
      persistJobs: config.persistJobs,
      persistenceDbDirectory: config.persistenceDbDirectory,
      persistenceDbNamePrefix: config.persistenceDbNamePrefix,
      persistenceInspector: config.persistenceInspector,
      onStoreFetchedItems: storeFetchedEntityStates,
    );
  }

  EntityStatePaginationService get entityStatePaginationService {
    _entityStatePaginationService ??= _createEntityStatePaginationService()
      ..startProcessing();
    if (_initialized) {
      _ensureEntityStateEventSubscriptions();
    }
    return _entityStatePaginationService!;
  }

  Stream<EntityStateJobQueueCounts>
  get entityStatePaginationJobQueueCountEvents =>
      entityStatePaginationService.queueCountEvents;

  /// Configure the cloud storage URL (useful for testing with localhost)
  void configureCloudUrl(String cloudUrl) {
    _cloudStorageUrl = cloudUrl;
    _entityStatePaginationService?.updateBaseUrl(cloudUrl);
    SlttLogger.logger.info(
      '[SyncManager] Cloud URL configured to: $_cloudStorageUrl',
    );
  }

  /// Configure the cloud websocket URL used for remote domain-change subscriptions.
  void configureCloudWssUrl(String cloudWssUrl) {
    _cloudWssUrl = cloudWssUrl;
    _webSocketClient?.updateCloudWssUrl(cloudWssUrl);
    SlttLogger.logger.info(
      '[SyncManager] Cloud WSS URL configured to: $_cloudWssUrl',
    );
  }

  String enqueueJobFetchEntityState({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
    String? parentId,
  }) {
    return entityStatePaginationService.enqueueJobFetchEntityState(
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      entityId: entityId,
      parentId: parentId,
    );
  }

  String enqueueJobFetchEntityStateCollection({
    required String domainType,
    required String domainId,
    required String entityType,
    String? parentId,
    int limit = 100,
    String? cursor,
  }) {
    return entityStatePaginationService.enqueueJobFetchEntityStateCollection(
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      parentId: parentId,
      limit: limit,
      cursor: cursor,
    );
  }

  void startEntityStatePaginationService() {
    entityStatePaginationService.startProcessing();
  }

  void stopEntityStatePaginationService() {
    _entityStatePaginationService?.stopProcessing();
  }

  EntityStateJobQueueCounts getEntityStatePaginationJobQueueCounts() {
    final service = _entityStatePaginationService;
    if (service == null) {
      return const EntityStateJobQueueCounts(
        queuedSingle: 0,
        queuedCollection: 0,
        queuedTotal: 0,
        activeSingle: 0,
        activeCollection: 0,
        activeTotal: 0,
        enabled: false,
      );
    }

    return service.currentQueueCounts;
  }

  Map<String, dynamic> getEntityStatePaginationDebugInfo() {
    final service = _entityStatePaginationService;
    return {
      'cloudUrl': _cloudStorageUrl,
      'serviceInitialized': service != null,
      'queueCounts': getEntityStatePaginationJobQueueCounts().toJson(),
      'persistence':
          service?.debugPersistenceInfo() ??
          {'persistJobs': false, 'openInCurrentIsolate': false},
    };
  }

  Future<void> initialize({
    IsarStorageService? localStorage,
    bool closeStorageOnDispose = true,
    EntityStatePaginationService? entityStatePaginationService,
    EntityStatePaginationServiceConfig entityStatePaginationServiceConfig =
        const EntityStatePaginationServiceConfig(),
  }) async {
    if (_initialized) return;

    _entityStatePaginationServiceConfig = entityStatePaginationServiceConfig;
    _entityStatePaginationService = entityStatePaginationService;
    if (_entityStatePaginationService != null) {
      _entityStatePaginationService!.updateBaseUrl(_cloudStorageUrl);
      _entityStatePaginationService!.setStoreFetchedItemsCallback(
        storeFetchedEntityStates,
      );
      // Pre-load persisted jobs so queue counts are visible immediately, even
      // before the user triggers processing. Must happen before startProcessing
      // so the _resumeRequested guard prevents a redundant DB load.
      await _entityStatePaginationService!.initialize();
      if (entityStatePaginationServiceConfig.startProcessingOnInitialize &&
          !_entityStatePaginationService!.isProcessingEnabled) {
        _entityStatePaginationService!.startProcessing();
      }
    }

    _localStorage = localStorage ?? LocalStorageService.instance;
    _ownsLocalStorage = closeStorageOnDispose || localStorage == null;
    if (localStorage == null) {
      await _localStorage.initialize();
    }

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 300);
    _dio.options.sendTimeout = const Duration(seconds: 300);

    _ensureEntityStateEventSubscriptions();

    _initialized = true;
    SlttLogger.logger.info(
      '[SyncManager] Initialized with cloud URL: $_cloudStorageUrl',
    );
  }

  /// Enable automatic sync when change log entries are modified
  /// Sync is debounced to trigger 500ms after the last change
  void enableAutoOutsync({String? domainType, String? domainId}) {
    if (_autoOutsyncEnabled) {
      SlttLogger.logger.info('[SyncManager] Auto-sync already enabled');
      return;
    }

    _autoOutsyncEnabled = true;
    SlttLogger.logger.info('[SyncManager] Enabling auto-sync with debouncing');

    _changeLogSubscription = _localStorage.lazyListenToChangeLogEntryChanges(
      domainType: domainType,
      domainId: domainId,
      onChanged: _onChangeLogChanged,
      fireImmediately: false,
    );
  }

  /// Disable automatic sync
  void disableAutoOutsync() {
    if (!_autoOutsyncEnabled) return;

    _autoOutsyncEnabled = false;
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = null;
    _changeLogSubscription?.cancel();
    _changeLogSubscription = null;

    SlttLogger.logger.info('[SyncManager] Auto-sync disabled');
  }

  /// Enable automatic downsync from cloud when remote domain changes arrive.
  ///
  /// This is gated by incoming websocket/domain-change events and local cursor
  /// bookkeeping inside the sync isolate.
  void enableAutoDownsync() {
    if (_autoDownsyncEnabled) {
      SlttLogger.logger.info('[SyncManager] Auto-downsync already enabled');
      return;
    }

    _autoDownsyncEnabled = true;
    SlttLogger.logger.info('[SyncManager] Auto-downsync enabled');
    _ensureActiveDomainChangeSubscriptions();
    _ensureWebSocketConnected();
    unawaited(_processPendingSubscribedDomainChanges());
  }

  /// Disable automatic downsync.
  void disableAutoDownsync() {
    if (!_autoDownsyncEnabled) return;

    _autoDownsyncEnabled = false;
    SlttLogger.logger.info('[SyncManager] Auto-downsync disabled');
    if (_subscribedDomainChangeKeys.isEmpty &&
        _subscribedDomainStatsKeys.isEmpty) {
      _disconnectWebSocket();
    }
  }

  /// Subscribe to remote domain notifications for the given domain.
  void subscribeToDomain({
    required String notifyType,
    required String domainType,
    required String domainId,
  }) {
    final key = _domainChangeKey(domainType: domainType, domainId: domainId);
    if (notifyType == WebsocketConstants.notifyTypeDomainStats) {
      if (_subscribedDomainStatsKeys.add(key)) {
        SlttLogger.logger.info(
          '[SyncManager] Subscribed to domain stats: $key',
        );
        _trySendDomainStatsSubscription(
          domainType: domainType,
          domainId: domainId,
        );
        _subscribeToLocalDomainStats(domainType, domainId);
      }
      return;
    }

    if (notifyType == WebsocketConstants.notifyTypeDomainChange) {
      if (_subscribedDomainChangeKeys.add(key)) {
        SlttLogger.logger.info(
          '[SyncManager] Subscribed to domain changes: $key',
        );
        _trySendDomainChangeSubscription(
          domainType: domainType,
          domainId: domainId,
        );
      }
      return;
    }

    SlttLogger.logger.warning(
      '[SyncManager] Unsupported notifyType for subscribeToDomain: $notifyType',
    );
  }

  /// Unsubscribe from remote domain notifications for the given domain.
  void unsubscribeFromDomain({
    required String notifyType,
    required String domainType,
    required String domainId,
  }) {
    final key = _domainChangeKey(domainType: domainType, domainId: domainId);
    if (notifyType == WebsocketConstants.notifyTypeDomainStats) {
      if (_subscribedDomainStatsKeys.remove(key)) {
        SlttLogger.logger.info(
          '[SyncManager] Unsubscribed from domain stats: $key',
        );
        _trySendDomainStatsUnsubscription(
          domainType: domainType,
          domainId: domainId,
        );
        _unsubscribeFromLocalDomainStats(domainType, domainId);
      }
    } else if (notifyType == WebsocketConstants.notifyTypeDomainChange) {
      if (_subscribedDomainChangeKeys.remove(key)) {
        SlttLogger.logger.info(
          '[SyncManager] Unsubscribed from domain changes: $key',
        );
        _remoteLastDomainSeqByDomain.remove(key);
        _trySendDomainChangeUnsubscription(
          domainType: domainType,
          domainId: domainId,
        );
      }
    } else {
      SlttLogger.logger.warning(
        '[SyncManager] Unsupported notifyType for unsubscribeFromDomain: $notifyType',
      );
    }

    if (_subscribedDomainChangeKeys.isEmpty &&
        _subscribedDomainStatsKeys.isEmpty) {
      _disconnectWebSocket();
    }
  }

  void _ensureActiveDomainChangeSubscriptions() {
    if (!_autoDownsyncEnabled || _subscribedDomainChangeKeys.isEmpty) {
      return;
    }

    SlttLogger.logger.info(
      '[SyncManager] Auto-downsync enabled for '
      '${_subscribedDomainChangeKeys.length} domain(s); '
      'remote-domain subscription management should be active.',
    );
  }

  Future<void> _processPendingSubscribedDomainChanges() async {
    if (!_autoDownsyncEnabled || _subscribedDomainChangeKeys.isEmpty) {
      return;
    }

    for (final key in _subscribedDomainChangeKeys) {
      if (!_autoDownsyncEnabled) {
        return;
      }

      final parts = key.split('/');
      if (parts.length != 2) {
        continue;
      }
      final domainType = parts[0];
      final domainId = parts[1];
      final lastDomainSeq = _remoteLastDomainSeqByDomain[key] ?? 0;
      if (lastDomainSeq <= 0) {
        continue;
      }

      final syncState = await _localStorage.getCursorSyncState(domainId);
      final localSeq = syncState?.seq ?? 0;
      if (lastDomainSeq <= localSeq) {
        continue;
      }

      await _handleDomainChange(domainType, domainId, lastDomainSeq);
    }
  }

  /// Update the token used by background websocket subscriptions.
  ///
  /// Token refresh remains in the main isolate; the sync isolate only stores
  /// the most recent access token for outbound websocket auth headers.
  void updateAuthToken(String token) {
    final hadToken = _hasWebSocketAuth;
    _authToken = token;
    SlttLogger.logger.info('[SyncManager] Auth token updated in sync isolate');
    if (!hadToken && _hasWebSocketAuth) {
      _ensureWebSocketConnected();
    }
  }

  String _domainChangeKey({
    required String domainType,
    required String domainId,
  }) {
    return '$domainType/$domainId';
  }

  void _trySendDomainChangeSubscription({
    required String domainType,
    required String domainId,
  }) {
    if (_isWebSocketOpen) {
      _webSocketClient?.subscribe(
        domainType,
        domainId,
        notifyType: WebsocketConstants.notifyTypeDomainChange,
      );
      SlttLogger.logger.info(
        '[SyncManager] Sent websocket subscribe for $domainType/$domainId',
      );
      return;
    }

    SlttLogger.logger.info(
      '[SyncManager] Websocket not connected; queuing subscribe for '
      '$domainType/$domainId',
    );
    _ensureWebSocketConnected();
  }

  void _trySendDomainStatsSubscription({
    required String domainType,
    required String domainId,
  }) {
    if (_isWebSocketOpen) {
      final payload = {
        'action': WebsocketConstants.actionSubscribe,
        'notifyType': WebsocketConstants.notifyTypeDomainStats,
        'domainType': domainType,
        'domainId': domainId,
        'entityType': WebsocketConstants.wildcardEntityType,
      };
      _webSocketClient?.send(payload);
      SlttLogger.logger.info(
        '[SyncManager] Sent websocket stats subscribe for $domainType/$domainId payload=$payload',
      );
      return;
    }

    SlttLogger.logger.info(
      '[SyncManager] Websocket not connected; queuing stats subscribe for '
      '$domainType/$domainId',
    );
    _ensureWebSocketConnected();
  }

  void _trySendDomainChangeUnsubscription({
    required String domainType,
    required String domainId,
  }) {
    if (_isWebSocketOpen) {
      _webSocketClient?.unsubscribe(
        domainType,
        domainId,
        notifyType: WebsocketConstants.notifyTypeDomainChange,
      );
      SlttLogger.logger.info(
        '[SyncManager] Sent websocket unsubscribe for $domainType/$domainId',
      );
    } else {
      SlttLogger.logger.info(
        '[SyncManager] Websocket not connected; queued unsubscribe for '
        '$domainType/$domainId',
      );
    }

    if (_subscribedDomainChangeKeys.isEmpty) {
      _disconnectWebSocket();
    }
  }

  void _trySendDomainStatsUnsubscription({
    required String domainType,
    required String domainId,
  }) {
    if (_isWebSocketOpen) {
      _webSocketClient?.unsubscribe(
        domainType,
        domainId,
        notifyType: WebsocketConstants.notifyTypeDomainStats,
      );
      SlttLogger.logger.info(
        '[SyncManager] Sent websocket stats unsubscribe for $domainType/$domainId',
      );
    } else {
      SlttLogger.logger.info(
        '[SyncManager] Websocket not connected; queued stats unsubscribe for '
        '$domainType/$domainId',
      );
    }
  }

  bool get _isWebSocketOpen => _webSocketClient?.isOpen == true;

  bool get _hasWebSocketAuth => _authToken?.isNotEmpty == true;

  void _ensureWebSocketConnected() {
    if (_isWebSocketOpen || _isWebSocketConnecting) {
      return;
    }
    if (!_autoDownsyncEnabled &&
        _subscribedDomainChangeKeys.isEmpty &&
        _subscribedDomainStatsKeys.isEmpty) {
      return;
    }
    if (!_hasWebSocketAuth) {
      SlttLogger.logger.info(
        '[SyncManager] Websocket connect deferred until auth token is available',
      );
      return;
    }
    _webSocketReconnectTimer?.cancel();
    _webSocketReconnectTimer = null;
    unawaited(_connectWebSocket());
  }

  Future<void> _connectWebSocket() async {
    _isWebSocketConnecting = true;
    try {
      _webSocketClient ??= SyncManagerWebSocketClient(
        cloudWssUrl: _cloudWssUrl,
        authToken: _authToken,
        onMessage: _handleWebSocketMessage,
        onDone: _onWebSocketDone,
        onError: _onWebSocketError,
      );
      if (_webSocketClient!.authToken != _authToken) {
        _webSocketClient!.updateAuthToken(_authToken ?? '');
      }
      final authTokenInfo = _authToken?.isNotEmpty == true
          ? 'present len=${_authToken!.length}'
          : 'absent';
      SlttLogger.logger.info(
        '[SyncManager] Connecting websocket to: $_cloudWssUrl auth=$authTokenInfo',
      );
      await _webSocketClient!.connect();
      _webSocketReconnectAttempts = 0;
      SlttLogger.logger.info('[SyncManager] Websocket connected');
      _sendPendingDomainChangeSubscriptions();
    } catch (e, stackTrace) {
      SlttLogger.logger.warning(
        '[SyncManager] Websocket connect failed: $e',
        e,
        stackTrace,
      );
      _scheduleWebSocketReconnect();
    } finally {
      _isWebSocketConnecting = false;
    }
  }

  void _scheduleWebSocketReconnect() {
    if (!_autoDownsyncEnabled &&
        _subscribedDomainChangeKeys.isEmpty &&
        _subscribedDomainStatsKeys.isEmpty) {
      return;
    }
    _webSocketReconnectTimer?.cancel();
    _webSocketReconnectAttempts += 1;
    final delaySeconds = _webSocketReconnectAttempts > 6
        ? 30
        : 2 << (_webSocketReconnectAttempts - 1);
    _webSocketReconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (_autoDownsyncEnabled ||
          _subscribedDomainChangeKeys.isNotEmpty ||
          _subscribedDomainStatsKeys.isNotEmpty) {
        unawaited(_connectWebSocket());
      }
    });
    SlttLogger.logger.info(
      '[SyncManager] Scheduled websocket reconnect in $delaySeconds seconds',
    );
  }

  Future<void> _disconnectWebSocket() async {
    _webSocketReconnectTimer?.cancel();
    _webSocketReconnectTimer = null;
    await _webSocketClient?.disconnect();
    _webSocketClient = null;
  }

  void _onWebSocketDone() {
    SlttLogger.logger.info('[SyncManager] Websocket connection closed');
    _webSocketClient = null;
    if (_autoDownsyncEnabled ||
        _subscribedDomainChangeKeys.isNotEmpty ||
        _subscribedDomainStatsKeys.isNotEmpty) {
      _scheduleWebSocketReconnect();
    }
  }

  void _onWebSocketError(dynamic error, StackTrace stackTrace) {
    SlttLogger.logger.warning(
      '[SyncManager] Websocket error: $error',
      error,
      stackTrace,
    );
    _webSocketClient = null;
    if (_autoDownsyncEnabled ||
        _subscribedDomainChangeKeys.isNotEmpty ||
        _subscribedDomainStatsKeys.isNotEmpty) {
      _scheduleWebSocketReconnect();
    }
  }

  void _sendPendingDomainChangeSubscriptions() {
    if (_subscribedDomainChangeKeys.isEmpty &&
        _subscribedDomainStatsKeys.isEmpty) {
      SlttLogger.logger.info(
        '[SyncManager] No pending websocket domain subscriptions to flush',
      );
      return;
    }
    final totalPending =
        _subscribedDomainChangeKeys.length + _subscribedDomainStatsKeys.length;
    SlttLogger.logger.info(
      '[SyncManager] Flushing $totalPending pending websocket domain subscriptions: '
      '${_subscribedDomainChangeKeys.join(', ')}${_subscribedDomainChangeKeys.isNotEmpty && _subscribedDomainStatsKeys.isNotEmpty ? ', ' : ''}${_subscribedDomainStatsKeys.join(', ')}',
    );
    for (final key in _subscribedDomainChangeKeys) {
      final parts = key.split('/');
      if (parts.length != 2) {
        SlttLogger.logger.warning(
          '[SyncManager] Ignoring malformed pending domain subscription key: $key',
        );
        continue;
      }
      _webSocketClient?.subscribe(
        parts[0],
        parts[1],
        notifyType: WebsocketConstants.notifyTypeDomainChange,
      );
      SlttLogger.logger.info(
        '[SyncManager] Sent queued websocket subscribe for ${parts[0]}/${parts[1]}',
      );
    }
    for (final key in _subscribedDomainStatsKeys) {
      final parts = key.split('/');
      if (parts.length != 2) {
        SlttLogger.logger.warning(
          '[SyncManager] Ignoring malformed pending domain stats subscription key: $key',
        );
        continue;
      }
      _webSocketClient?.subscribe(
        parts[0],
        parts[1],
        notifyType: WebsocketConstants.notifyTypeDomainStats,
        entityType: WebsocketConstants.wildcardEntityType,
      );
      SlttLogger.logger.info(
        '[SyncManager] Sent queued websocket stats subscribe for ${parts[0]}/${parts[1]}',
      );
    }
  }

  void _handleWebSocketMessage(dynamic rawMessage) {
    try {
      final message = rawMessage is String
          ? jsonDecode(rawMessage) as Map<String, dynamic>
          : rawMessage as Map<String, dynamic>;
      final action = message['action'] as String?;
      if (action == WebsocketConstants.actionSubscribe) {
        final status = message['status'] as String?;
        SlttLogger.logger.info(
          '[SyncManager] Received websocket subscribe ack message=$message',
        );
        if (status != 'ok') {
          SlttLogger.logger.warning(
            '[SyncManager] Websocket subscribe ack failed: status=$status, message=$message',
          );
          return;
        }
        final domainType = message['domainType'] as String?;
        final domainId = message['domainId'] as String?;
        final notifyType = message['notifyType'] as String?;
        if (domainType == null || domainId == null || notifyType == null) {
          SlttLogger.logger.warning(
            '[SyncManager] Websocket subscribe ack missing required fields: $message',
          );
          return;
        }
        final data = message['stats'] as Map<String, dynamic>?;
        if (data == null) {
          SlttLogger.logger.info(
            '[SyncManager] Websocket subscribe ack for $domainType/$domainId received without status data; waiting for change events.',
          );
          return;
        }

        DomainStatsResponse stats;
        try {
          stats = DomainStatsResponse.fromJson(data);
        } catch (error, stackTrace) {
          SlttLogger.logger.warning(
            '[SyncManager] Websocket subscribe ack statistics payload failed to parse as DomainStatsResponse: $error',
          );
          SlttLogger.logger.fine(() {
            return '[SyncManager] payload=$data stackTrace=$stackTrace';
          });
          return;
        }

        final lastDomainSeq = _remoteLastDomainSeqFromDomainStats(stats);
        final lastDomainChangeAt = _remoteLastDomainChangeAtFromDomainStats(
          stats,
        );
        SlttLogger.logger.info(
          '[SyncManager] Websocket subscribe ack for $domainType/$domainId ($notifyType): '
          'lastDomainSeq=$lastDomainSeq, lastDomainChangeAt=$lastDomainChangeAt',
        );

        final key = _domainChangeKey(
          domainType: domainType,
          domainId: domainId,
        );
        if (notifyType == WebsocketConstants.notifyTypeDomainStats) {
          if (!_subscribedDomainStatsKeys.contains(key)) {
            SlttLogger.logger.info(
              '[SyncManager] Ignoring stats subscribe ack for $domainType/$domainId because the key is not actively subscribed.',
            );
            return;
          }

          final previousSeq = _remoteLastDomainSeqByDomain[key] ?? 0;
          if (lastDomainSeq > previousSeq) {
            _remoteLastDomainSeqByDomain[key] = lastDomainSeq;
          }
          if (lastDomainChangeAt != null) {
            _remoteLastDomainChangeAtByDomain[key] = lastDomainChangeAt;
          }

          final mergedStats = _mergeCloudDomainStats(
            domainType: domainType,
            domainId: domainId,
            stats: DomainStatsResponse.fromJson(
              Map<String, dynamic>.from(data),
            ),
          );
          _cloudDomainStatsEventsController.add(
            CloudDomainStatsUpdate(
              domainType: domainType,
              domainId: domainId,
              cloudStats: mergedStats,
              observedAt: DateTime.now().toUtc(),
            ),
          );
          return;
        }

        if (!_subscribedDomainChangeKeys.contains(key)) {
          SlttLogger.logger.info(
            '[SyncManager] Ignoring subscribe ack for $domainType/$domainId because the key is not actively subscribed.',
          );
          return;
        }

        if (lastDomainSeq <= 0) {
          SlttLogger.logger.info(
            '[SyncManager] Websocket subscribe ack for $domainType/$domainId had no remote seq; no downsync will be triggered until a change event arrives.',
          );
          return;
        }

        final previousSeq = _remoteLastDomainSeqByDomain[key] ?? 0;
        if (lastDomainSeq <= previousSeq) {
          return;
        }
        _remoteLastDomainSeqByDomain[key] = lastDomainSeq;
        if (lastDomainChangeAt != null) {
          _remoteLastDomainChangeAtByDomain[key] = lastDomainChangeAt;
        }
        if (!_autoDownsyncEnabled) {
          SlttLogger.logger.info(
            '[SyncManager] Subscribe ack for $domainType/$domainId stored remote status; auto-downsync is disabled, so download is deferred until enabled.',
          );
          return;
        }
        unawaited(_handleDomainChange(domainType, domainId, lastDomainSeq));
        return;
      }

      if (action != WebsocketConstants.actionChange) {
        return;
      }
      final notifyType = message['notifyType'] as String?;
      if (notifyType == WebsocketConstants.notifyTypeDomainStats) {
        final domainType = message['domainType'] as String?;
        final domainId = message['domainId'] as String?;
        final rawStats = message['stats'];
        if (domainType == null || domainId == null || rawStats is! Map) {
          return;
        }

        final statsMap = Map<String, dynamic>.from(rawStats);
        DomainStatsResponse stats;
        try {
          stats = DomainStatsResponse.fromJson(statsMap);
        } catch (error, stackTrace) {
          SlttLogger.logger.warning(
            '[SyncManager] Websocket domainStats message payload failed to parse as DomainStatsResponse: $error',
          );
          SlttLogger.logger.fine(() {
            return '[SyncManager] payload=$statsMap stackTrace=$stackTrace';
          });
          return;
        }

        final lastDomainSeq = _remoteLastDomainSeqFromDomainStats(stats);
        final lastDomainChangeAt = _remoteLastDomainChangeAtFromDomainStats(
          stats,
        );

        final key = _domainChangeKey(
          domainType: domainType,
          domainId: domainId,
        );
        if (!_subscribedDomainStatsKeys.contains(key)) {
          return;
        }
        final previousSeq = _remoteLastDomainSeqByDomain[key] ?? 0;
        if (lastDomainSeq > previousSeq) {
          _remoteLastDomainSeqByDomain[key] = lastDomainSeq;
        }
        if (lastDomainChangeAt != null) {
          _remoteLastDomainChangeAtByDomain[key] = lastDomainChangeAt;
        }
        final mergedStats = _mergeCloudDomainStats(
          domainType: domainType,
          domainId: domainId,
          stats: stats,
        );
        _cloudDomainStatsEventsController.add(
          CloudDomainStatsUpdate(
            domainType: domainType,
            domainId: domainId,
            cloudStats: mergedStats,
            observedAt: DateTime.now().toUtc(),
          ),
        );
        return;
      }
      if (notifyType != WebsocketConstants.notifyTypeDomainChange) {
        return;
      }
      final domainType = message['domainType'] as String?;
      final domainId = message['domainId'] as String?;
      final rawChange = message['change'];
      if (domainType == null || domainId == null || rawChange is! Map) {
        return;
      }
      final change = Map<String, dynamic>.from(rawChange);
      final lastDomainSeq = change['seq'] is int
          ? change['seq'] as int
          : int.tryParse(change['seq']?.toString() ?? '') ?? 0;
      if (lastDomainSeq <= 0) {
        return;
      }
      final lastDomainChangeAtRaw = change['changeAt'];
      DateTime? lastDomainChangeAt;
      if (lastDomainChangeAtRaw is String) {
        lastDomainChangeAt = DateTime.tryParse(lastDomainChangeAtRaw)?.toUtc();
      } else if (lastDomainChangeAtRaw is DateTime) {
        lastDomainChangeAt = lastDomainChangeAtRaw.toUtc();
      }

      final key = _domainChangeKey(domainType: domainType, domainId: domainId);
      if (!_subscribedDomainChangeKeys.contains(key)) {
        return;
      }
      final previousSeq = _remoteLastDomainSeqByDomain[key] ?? 0;
      if (lastDomainSeq <= previousSeq) {
        return;
      }
      _remoteLastDomainSeqByDomain[key] = lastDomainSeq;
      if (lastDomainChangeAt != null) {
        _remoteLastDomainChangeAtByDomain[key] = lastDomainChangeAt;
      }
      if (!_autoDownsyncEnabled) {
        return;
      }
      unawaited(_handleDomainChange(domainType, domainId, lastDomainSeq));
    } catch (error, stackTrace) {
      SlttLogger.logger.warning(
        '[SyncManager] Failed to process websocket message: $error',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _handleDomainChange(
    String domainType,
    String domainId,
    int lastDomainSeq,
  ) async {
    if (_downsyncInFlight) {
      SlttLogger.logger.info(
        '[SyncManager] Downsync already in flight; skipping domain change for '
        '$domainType/$domainId',
      );
      return;
    }

    final syncState = await _localStorage.getCursorSyncState(domainId);
    final localSeq = syncState?.seq ?? 0;
    if (lastDomainSeq <= localSeq) {
      SlttLogger.logger.info(
        '[SyncManager] Local seq already up to date for $domainType/$domainId: '
        'local=$localSeq remote=$lastDomainSeq',
      );
      return;
    }

    _downsyncInFlight = true;
    try {
      SlttLogger.logger.info(
        '[SyncManager] Downsyncing $domainType/$domainId due to websocket change event',
      );
      await downsyncFromCloud(domainIds: [domainId], domainType: domainType);
    } catch (error, stackTrace) {
      SlttLogger.logger.warning(
        '[SyncManager] Domain change downsync failed for $domainType/$domainId: $error',
        error,
        stackTrace,
      );
    } finally {
      _downsyncInFlight = false;
    }
  }

  /// Called when change log entries are modified
  void _onChangeLogChanged() {
    // Cancel existing timer if it's running
    _syncDebounceTimer?.cancel();

    // Start a new timer for 500ms
    _syncDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      SlttLogger.logger.info('[SyncManager] Triggering debounced full sync');
      _performDebouncedOutsync();
    });
  }

  /// Perform the actual outsync (called after debounce period)
  void _performDebouncedOutsync() async {
    try {
      await outsyncToCloud();
      SlttLogger.logger.info(
        '[SyncManager] Debounced outsync completed successfully',
      );
    } catch (e, stackTrace) {
      SlttLogger.logger.severe(
        '[SyncManager] Debounced outsync failed: $e',
        e,
        stackTrace,
      );
    }
  }

  Map<String, String?> _handleError(
    String context,
    dynamic e,
    StackTrace stackTrace,
  ) {
    dynamic response;
    try {
      response = (e as dynamic).response;
    } catch (_) {
      response = null;
    }
    if (response != null) {
      SlttLogger.logger.severe(
        '[SyncManager] [$context] [Error ${response.statusCode} (${response.statusMessage})] Error details: $response',
      );
    } else {
      SlttLogger.logger.severe(
        '[SyncManager] [$context] Error details: ${e.toString()}',
      );
    }
    SlttLogger.logger.severe(
      '[SyncManager] [$context] Stack trace: $stackTrace',
    );

    return {
      'error': response?.toString() ?? e.toString(),
      'errorStackTrace': stackTrace.toString(),
    };
  }

  String _entityStateKey({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
  }) {
    return '$domainType/$domainId/$entityType/$entityId';
  }

  String? _extractIncomingStateDataHashWarning(
    Map<String, dynamic> incomingChange,
  ) {
    final operationInfoRaw = incomingChange['operationInfoJson'];
    if (operationInfoRaw == null) {
      return null;
    }

    try {
      dynamic operationInfo;
      if (operationInfoRaw is String && operationInfoRaw.isNotEmpty) {
        operationInfo = jsonDecode(operationInfoRaw);
      } else if (operationInfoRaw is Map) {
        operationInfo = operationInfoRaw;
      }
      if (operationInfo is! Map) {
        return null;
      }

      final warnings = operationInfo['warnings'];
      if (warnings is! Map) {
        return null;
      }

      return warnings['stateDataHash']?.toString();
    } catch (_) {
      return null;
    }
  }

  // Get all projects that have changes to sync

  // Outsync changes from outsyncs to cloud storage
  Future<OutsyncResult> outsyncToCloud({
    List<String>? domainIds,
    String domainType = 'project',
  }) async {
    late final List<IsarChangeLogEntry> changesToSync;
    try {
      SlttLogger.logger.info('[SyncManager] Starting outsync to cloud...');

      // Get changes for sync
      changesToSync = await _localStorage.getChangesForSync(
        domainIds: domainIds,
        limit:
            120 /* 10x (average 4Kb per item) batch writes 12 changes + 12 state updates (25 per-batch write limit) */,
      );

      if (changesToSync.isEmpty) {
        SlttLogger.logger.fine('[SyncManager] No changes to outsync');
        return OutsyncResult(
          success: true,
          changesRequested: changesToSync,
          changeSummary: null,
          deletedLocalChanges: [],
          message: 'No changes to sync',
        );
      }

      SlttLogger.logger.info(
        '[SyncManager] Found ${changesToSync.length} changes to outsync',
      );

      // Send changes to cloud storage using typed API model
      final srcStorageId = await _localStorage.getStorageId();
      final req = CreateChangesRequest(
        changes: changesToSync,
        srcStorageType: 'local',
        srcStorageId: srcStorageId,
        storageMode: 'sync',
        includeChangeUpdates: true,
        includeStateUpdates: true,
      );

      final response = await _dio.post(
        '$_cloudStorageUrl/api/changes',
        data: req.toJson(),
      );

      if (response.statusCode == 200) {
        final summary = ChangeProcessingSummary.fromJson(response.data);
        final cidsSynced = summary.processed;

        if (cidsSynced.isNotEmpty) {
          // Immediately delete the outsynced changes to clean up local storage
          SlttLogger.logger.info(
            '[SyncManager] Successfully outsynced ${cidsSynced.length} changes to cloud',
          );
          SlttLogger.logger.fine(
            '[SyncManager] Deleting outsynced changes from local storage...',
          );

          final deletedCount = await _localStorage.deleteChanges(cidsSynced);
          SlttLogger.logger.info(
            '[SyncManager] Deleted $deletedCount outsynced changes from local storage',
          );

          return OutsyncResult(
            success: true,
            message: 'Successfully outsynced ${cidsSynced.length} changes',
            changesRequested: changesToSync,
            changeSummary: summary,
            deletedLocalChanges: cidsSynced,
          );
        } else {
          // Handle partial failure

          final message =
              '[SyncManager] ### Partial outsync: nothing processed!';
          final error =
              '$message, errors: ${const JsonEncoder.withIndent('  ').convert(summary.errors)}';
          SlttLogger.logger.severe(error);
          return OutsyncResult(
            success: false,
            message: message,
            changesRequested: changesToSync,
            changeSummary: summary,
            deletedLocalChanges: [],
            error: error,
            errorStackTrace: null,
          );
        }
      } else {
        final errorBody = response.data;
        throw Exception(
          'Outsync failed with status: ${response.statusCode}, body: $errorBody',
        );
      }
    } catch (e, stackTrace) {
      final handled = _handleError('OutsyncToCloud', e, stackTrace);
      return OutsyncResult(
        success: false,
        changeSummary: null,
        changesRequested: changesToSync,
        deletedLocalChanges: [],
        message: 'Outsync failed: $e',
        error: handled['error'],
        errorStackTrace: handled['errorStackTrace'],
      );
    }
  }

  // Downsync changes from cloud storage to local state
  Future<DownsyncResult> downsyncFromCloud({
    List<String>? domainIds,
    String domainType = 'project',
    Function? onProgress,
  }) async {
    ProjectCursorChanges projectCursorChanges = {};
    StorageSummaries storageSummaries = {};
    final finalStateHashesByKey = <String, _StateHashSnapshot>{};
    final queuedEntityStateFetchKeys = <String>{};
    final warningBasedRefetchKeys = <String>{};
    try {
      SlttLogger.logger.info('[SyncManager] Starting downsync from cloud...');

      if (domainIds != null && domainIds.isNotEmpty) {
        SlttLogger.logger.fine(
          '[SyncManager] Downsync limited to specified domainIds: $domainIds',
        );
      } else {
        SlttLogger.logger.info(
          '[SyncManager] Downsyncing all domains of type: $domainType',
        );

        final collection = getCollectionByDomain(domainType);
        if (collection == null) {
          throw ArgumentError('Unknown domainType: $domainType');
        }

        // First, get all domain ids from the cloud storage (authoritative source)
        final response = await _dio.get(
          '$_cloudStorageUrl/api/ids/$collection',
        );
        if (response.statusCode != 200) {
          throw Exception(
            'Failed to get $collection ids from cloud: ${response.statusCode}',
          );
        }

        final responseData = response.data as Map<String, dynamic>;
        final ids = (responseData['items'] as List<dynamic>).cast<String>();
        SlttLogger.logger.info(
          '[SyncManager] Found ${ids.length} $collection ids: $ids',
        );

        if (ids.isEmpty) {
          SlttLogger.logger.info(
            '[SyncManager] No $collection found in cloud to downsync',
          );
          return DownsyncResult(
            success: true,
            projectCursorChanges: {},
            storageSummaries: {},
            message: 'No $collection found in cloud to downsync',
            error: null,
            errorStackTrace: null,
          );
        }
        domainIds = ids.toList();
      }

      // For each project, downsync its changes with cursor-based pagination
      final collection = getCollectionByDomain(domainType) ?? 'projects';
      for (final domainId in domainIds) {
        SlttLogger.logger.info(
          '[SyncManager] Downsyncing $domainType: $domainId',
        );

        // Get the last sync state for this specific project
        final syncState = await _localStorage.getCursorSyncState(domainId);
        int lastSeq = syncState?.seq ?? 0;
        String cid = syncState?.cid ?? '';
        DateTime changeAt =
            syncState?.changeAt ??
            DateTime.fromMillisecondsSinceEpoch(0).toUtc();
        SlttLogger.logger.fine('[SyncManager] Starting from seq: $lastSeq');

        String? cursor = lastSeq.toString();
        int totalChangesForProject = 0;
        int highestSeqForProject =
            lastSeq; // Track highest sequence for this project
        String srcStorageId = '**TBD**';
        String srcStorageType = '**TBD**';

        bool hasMore = false;
        // Continue fetching with cursor until no more changes
        do {
          final encodedDomainId = Uri.encodeComponent(domainId);
          // router.get('/api/changes/<domainCollection>/<domainId>', _handleGetChanges);
          final url =
              '$_cloudStorageUrl/api/changes/$collection/$encodedDomainId?cursor=$cursor';

          final response = await _dio.get(url);
          final changesResponseData = response.data as Map<String, dynamic>;

          hasMore = changesResponseData['hasMore'] as bool;
          if (response.statusCode == 200) {
            srcStorageId = changesResponseData['storageId'];
            srcStorageType = changesResponseData['storageType'];
            // TODO Deserialize response data
            final changesBatch =
                changesResponseData['changes'] as List<dynamic>;
            final nextCursor =
                changesResponseData['cursor'] as int? ?? highestSeqForProject;
            highestSeqForProject = nextCursor;
            /*
               final responseData = <String, dynamic>{
                'storageId': storageId,
                'storageType': storageType,
                'changes': changes.map((c) => c.toJson()).toList(),
                'count': changes.length,
                'timestamp': DateTime.now().toIso8601String(),
              };
            */

            if (changesBatch.isEmpty) {
              SlttLogger.logger.fine(
                '[SyncManager] No more changes for $domainType $domainId',
              );
              if (lastSeq < highestSeqForProject) {
                // Update sync state even if no changes were returned
                await _localStorage.upsertCursorSyncState(
                  domainType: domainType,
                  domainId: domainId,
                  srcStorageType: srcStorageType,
                  srcStorageId: srcStorageId,
                  seq: highestSeqForProject,
                  cid: cid,
                  changeAt: changeAt,
                );
                SlttLogger.logger.fine(
                  '[SyncManager] Updated sync state for $domainType $domainId: lastSeq=$highestSeqForProject',
                );
              }
              break;
            }

            // Apply changes directly to state storage without storing in downsyncs
            final incomingChanges = changesBatch
                .cast<Map<String, dynamic>>()
                .toList();
            final changesToApply = incomingChanges
                .where((change) => change['stateChanged'] == true)
                .toList();
            final changesStateFalse = incomingChanges
                .where((change) => change['stateChanged'] != true)
                .toList();
            projectCursorChanges['$domainId/$cursor'] = incomingChanges;
            _updateCloudStateDataHashes(
              incomingChanges: incomingChanges,
              finalStateHashesByKey: finalStateHashesByKey,
              domainTypeContext: domainType,
              domainIdContext: domainId,
            );
            _updateStateChangedFalseStateDataHashes(
              changesStateFalse: changesStateFalse,
              finalStateHashesByKey: finalStateHashesByKey,
              warningBasedRefetchKeys: warningBasedRefetchKeys,
              domainTypeContext: domainType,
              domainIdContext: domainId,
            );

            // Apply only stateChanged=true changes to avoid sync pre-validation
            // rejection for stateChanged=false entries.
            final results = changesToApply.isEmpty
                ? const ChangeProcessingResult(resultsSummary: null)
                : await ChangeProcessingService.storeChanges(
                    storageMode: 'sync',
                    changes: changesToApply,
                    srcStorageType: srcStorageType,
                    srcStorageId: srcStorageId,
                    storage: _localStorage,
                    includeChangeUpdates: true,
                    includeStateUpdates: true,
                  );

            // TODO: how to handle more gracefully so we don't get stuck?
            if (results.isError) {
              final error =
                  'Downsync processing error for $domainType $domainId: '
                  '${results.errorMessage}'
                  '${const JsonEncoder.withIndent('  ').convert(results.resultsSummary?.toJson())}';
              SlttLogger.logger.severe(error);
              return DownsyncResult(
                success: false,
                projectCursorChanges: projectCursorChanges,
                storageSummaries: storageSummaries,
                message: 'Downsync processing error for $domainType $domainId',
                error: error,
                errorStackTrace: null,
              );
            }

            storageSummaries['$domainId/$cursor'] = results.resultsSummary;
            _updateLocalStateDataHashes(
              stateUpdates: results.resultsSummary?.stateUpdates ?? const [],
              finalStateHashesByKey: finalStateHashesByKey,
              domainTypeContext: domainType,
              domainIdContext: domainId,
            );

            totalChangesForProject += incomingChanges.length;

            SlttLogger.logger.info(
              '[SyncManager] Downloaded ${incomingChanges.length} changes for $domainType $domainId (batch); applied ${changesToApply.length}',
            );

            // Update sync state for this project if we processed any changes
            if (totalChangesForProject > 0) {
              await _localStorage.upsertCursorSyncState(
                domainType: domainType,
                domainId: domainId,
                srcStorageType: srcStorageType,
                srcStorageId: srcStorageId,
                seq: highestSeqForProject,
                cid: cid,
                changeAt: changeAt,
              );
              SlttLogger.logger.fine(
                '[SyncManager] Updated sync state for $domainType $domainId: lastSeq=$highestSeqForProject',
              );
            }

            onProgress?.call(
              domainId,
              totalChangesForProject + incomingChanges.length,
            );

            // Update cursor for next iteration
            cursor = nextCursor.toString();
          } else {
            SlttLogger.logger.warning(
              '[SyncManager] Failed to downsync $domainType $domainId: ${response.statusCode}',
            );
            break; // Exit cursor loop for this project
          }
        } while (hasMore);
        SlttLogger.logger.info(
          '[SyncManager] Completed downsyncing $domainType $domainId: $totalChangesForProject total changes',
        );
      }
      final totalDownloadedCount = projectCursorChanges.values
          .expand((changes) => changes)
          .length;
      SlttLogger.logger.info(
        '[SyncManager] Downsync completed. Total changes: $totalDownloadedCount',
      );

      final mismatchCount = await _queueMismatchedEntityStateRefetches(
        finalStateHashesByKey: finalStateHashesByKey,
        queuedEntityStateFetchKeys: queuedEntityStateFetchKeys,
      );
      final warningRefetchCount = await _queueWarningBasedEntityStateRefetches(
        warningBasedRefetchKeys: warningBasedRefetchKeys,
        finalStateHashesByKey: finalStateHashesByKey,
        queuedEntityStateFetchKeys: queuedEntityStateFetchKeys,
      );

      if (mismatchCount > 0) {
        SlttLogger.logger.warning(
          '[SyncManager] Downsync hash reconciliation found $mismatchCount mismatched entity state hash(es); queued targeted state refetch.',
        );
      }
      if (warningRefetchCount > 0) {
        SlttLogger.logger.warning(
          '[SyncManager] Downsync warning-based reconciliation queued $warningRefetchCount targeted state refetch(es).',
        );
      }

      return DownsyncResult(
        success: true,
        projectCursorChanges: projectCursorChanges,
        storageSummaries: storageSummaries,
        message:
            'Successfully downsynced $totalDownloadedCount changes from ${domainIds.length} $domainType(s)',
        error: null,
        errorStackTrace: null,
      );
    } catch (e, stackTrace) {
      final handled = _handleError('DownsyncFromCloud', e, stackTrace);
      return DownsyncResult(
        success: false,
        projectCursorChanges: projectCursorChanges,
        storageSummaries: storageSummaries,
        message: 'Downsync failed: $e',
        error: handled['error'],
        errorStackTrace: handled['errorStackTrace'],
      );
    }
  }

  // Perform full sync: outsync first, then downsync
  Future<FullSyncResult> performFullSync({
    List<String>? domainIds,
    String domainType = 'project',
  }) async {
    SlttLogger.logger.info('[SyncManager] Starting full sync...');

    // Step 1: Outsync to cloud (deletes local changes immediately)
    final outsyncResult = await outsyncToCloud(
      domainIds: domainIds,
      domainType: domainType,
    );

    // Step 2: Downsync from cloud
    final downsyncResult = await downsyncFromCloud(
      domainIds: domainIds,
      domainType: domainType,
    );

    // Use the already computed deleted local sequences from outsync result
    final finalOutsyncResult = OutsyncResult(
      success: outsyncResult.success,
      changesRequested: outsyncResult.changesRequested,
      changeSummary: outsyncResult.changeSummary,
      deletedLocalChanges: outsyncResult.deletedLocalChanges,
      message: outsyncResult.message,
      error: outsyncResult.error,
      errorStackTrace: outsyncResult.errorStackTrace,
    );

    return FullSyncResult(
      outsyncResult: finalOutsyncResult,
      downsyncResult: downsyncResult,
      success: outsyncResult.success && downsyncResult.success,
    );
  }

  Future<List<String>> getSyncedDomainIds({
    String domainType = 'project',
  }) async {
    final ids = await _localStorage.getAllDomainIds(domainType: domainType);
    return ids;
  }

  // Backwards-compatible wrapper
  Future<List<String>> getSyncedProjects() async =>
      getSyncedDomainIds(domainType: 'project');

  // Check sync status and statistics
  Future<SyncStatus> getSyncStatus(
    String domainId, {
    String domainType = 'project',
    bool skipCloudStats = false,
  }) async {
    try {
      final localChangeStats = await _localStorage.getChangeStats(
        domainType: domainType,
        domainId: domainId,
      );

      final localStateStats = await _localStorage.getStateStats(
        domainType: domainType,
        domainId: domainId,
      );

      final localCursorState = await _localStorage.getCursorSyncState(domainId);

      EntityTypeSummary? cloudChangeStats;
      EntityTypeStats? cloudStateStats;
      if (!skipCloudStats) {
        try {
          final collection = getCollectionByDomain(domainType) ?? 'projects';
          final response = await _dio.get(
            '$_cloudStorageUrl/api/stats/$collection/$domainId',
          );
          if (response.statusCode == 200) {
            final stats = response.data as Map<String, dynamic>;
            final ps = DomainStatsResponse.fromJson(stats);
            cloudStateStats = ps.entityTypeStats;
            cloudChangeStats = ps.changeStats;

            final key = _domainChangeKey(
              domainType: domainType,
              domainId: domainId,
            );
            final lastDomainSeq = _remoteLastDomainSeqFromDomainStats(ps);
            final lastDomainChangeAt = _remoteLastDomainChangeAtFromDomainStats(
              ps,
            );
            if (lastDomainSeq > (_remoteLastDomainSeqByDomain[key] ?? 0)) {
              _remoteLastDomainSeqByDomain[key] = lastDomainSeq;
            }
            if (lastDomainChangeAt != null) {
              _remoteLastDomainChangeAtByDomain[key] = lastDomainChangeAt;
            }

            final comprehensiveStats = _mergeCloudDomainStats(
              domainType: domainType,
              domainId: domainId,
              stats: ps,
              treatAsFullSnapshot: true,
            );
            _cloudDomainStatsEventsController.add(
              CloudDomainStatsUpdate(
                domainType: domainType,
                domainId: domainId,
                cloudStats: comprehensiveStats,
                observedAt: DateTime.now().toUtc(),
              ),
            );
          }
        } catch (e) {
          SlttLogger.logger.warning(
            '[SyncManager] Could not fetch cloud storage stats: $e',
          );
        }
      }

      final key = _domainChangeKey(domainType: domainType, domainId: domainId);
      return SyncStatus(
        localChangeStats: localChangeStats,
        localStateStats: localStateStats,
        localCursorState: localCursorState,
        cloudChangeStats: cloudChangeStats,
        cloudStateStats: cloudStateStats,
        remoteLastDomainSeq: _remoteLastDomainSeqByDomain[key],
        remoteLastDomainChangeAt: _remoteLastDomainChangeAtByDomain[key],
      );
    } catch (e) {
      SlttLogger.logger.severe('[SyncManager] Failed to get sync status: $e');
      return SyncStatus(
        localChangeStats: null,
        localStateStats: null,
        localCursorState: null,
        cloudChangeStats: null,
        cloudStateStats: null,
        remoteLastDomainSeq: null,
        remoteLastDomainChangeAt: null,
      );
    }
  }

  /// Clear all sync states (useful for testing)
  Future<void> clearAllSyncStates() async {
    await _localStorage.clearAllCursorSyncStates();
  }

  Future<Map<String, int>?> _fetchLatestSeqByEntityTypeFromCloudStats({
    required String domainType,
    required String domainId,
  }) async {
    try {
      final collection = getCollectionByDomain(domainType);
      if (collection == null || collection.isEmpty) {
        return null;
      }

      final response = await _dio.get(
        '$_cloudStorageUrl/api/stats/$collection/$domainId',
      );
      if (response.statusCode != 200) {
        return null;
      }

      final stats = response.data as Map<String, dynamic>;
      final parsed = DomainStatsResponse.fromJson(stats);
      final out = <String, int>{};
      final entityTypeStats = parsed.entityTypeStats;
      if (entityTypeStats == null) {
        return out;
      }

      entityTypeStats.entityTypes.forEach((entityType, summary) {
        if (summary.latestSeq >= 0) {
          out[entityType] = summary.latestSeq;
        }
      });

      return out;
    } catch (e) {
      SlttLogger.logger.warning(
        '[SyncManager] Failed to fetch latest seq via /api/stats for $domainType $domainId: $e',
      );
      return null;
    }
  }

  Future<void> storeFetchedEntityStates({
    required String domainType,
    required String domainId,
    required String entityType,
    required List<Map<String, dynamic>> items,
    required DateTime storedAt,
  }) async {
    if (items.isEmpty) return;

    final states = <BaseEntityState>[];
    for (final item in items) {
      final state = _localStorage.createEntityStateFromJson(
        entityType: entityType,
        json: item,
      );
      states.add(state);
    }

    if (states.isEmpty) return;

    final mismatchedContextCount = states
        .where(
          (state) =>
              state.domainType != domainType ||
              state.change_domainId != domainId,
        )
        .length;
    if (mismatchedContextCount > 0) {
      SlttLogger.logger.warning(
        '[SyncManager] storeFetchedEntityStates received '
        '$mismatchedContextCount state(s) outside callback context '
        '($entityType/$domainType/$domainId).',
      );
    }

    final grouped =
        <(String domainType, String domainId), List<BaseEntityState>>{};
    for (final state in states) {
      final key = (state.domainType, state.change_domainId);
      grouped.putIfAbsent(key, () => <BaseEntityState>[]).add(state);
    }

    for (final entry in grouped.entries) {
      final domainType = entry.key.$1;
      final domainId = entry.key.$2;
      final latestSeqByEntityType =
          await _fetchLatestSeqByEntityTypeFromCloudStats(
            domainType: domainType,
            domainId: domainId,
          );

      await _localStorage.batchPutEntityStates(
        states: entry.value,
        storedAt: storedAt,
        latestSeqByEntityType: latestSeqByEntityType,
      );
    }
  }

  Future<void> close() async {
    if (_initialized) {
      // Clean up auto-sync resources
      disableAutoOutsync();
      await _singleEntityStateSubscription?.cancel();
      _singleEntityStateSubscription = null;
      await _collectionEntityStateSubscription?.cancel();
      _collectionEntityStateSubscription = null;

      for (final subscription in _localDomainChangeLogSubscriptions.values) {
        await subscription.cancel();
      }
      for (final subscription in _localDomainStateSubscriptions.values) {
        await subscription.cancel();
      }
      for (final subscription
          in _localDomainCursorSyncStateSubscriptions.values) {
        await subscription.cancel();
      }
      _localDomainChangeLogSubscriptions.clear();
      _localDomainStateSubscriptions.clear();
      _localDomainCursorSyncStateSubscriptions.clear();

      for (final timer in _localDomainStatsDebounceTimers.values) {
        timer.cancel();
      }
      _localDomainStatsDebounceTimers.clear();

      await _entityStatePaginationService?.dispose();
      _entityStatePaginationService = null;

      if (_ownsLocalStorage) {
        await _localStorage.close();
      }
      _initialized = false;
      _instance = null;
      SlttLogger.logger.info('[SyncManager] Closed');
    }
  }

  void _ensureEntityStateEventSubscriptions() {
    final service = _entityStatePaginationService;
    if (service == null) {
      return;
    }

    _singleEntityStateSubscription ??= service.singleEntityEvents.listen(
      (event) => unawaited(_handleFetchedEntityStateEvent(event)),
      onError: (error, stackTrace) {
        SlttLogger.logger.warning(
          '[SyncManager] Error from single entity-state stream: $error',
        );
      },
    );

    _collectionEntityStateSubscription ??= service.collectionEntityEvents
        .listen(
          (event) => unawaited(_handleFetchedEntityStateEvent(event)),
          onError: (error, stackTrace) {
            SlttLogger.logger.warning(
              '[SyncManager] Error from collection entity-state stream: $error',
            );
          },
        );
  }

  void _subscribeToLocalDomainStats(String domainType, String domainId) {
    final key = _domainChangeKey(domainType: domainType, domainId: domainId);
    if (_localDomainChangeLogSubscriptions.containsKey(key) ||
        _localDomainStateSubscriptions.containsKey(key) ||
        _localDomainCursorSyncStateSubscriptions.containsKey(key)) {
      return;
    }

    final changeLogSub = _localStorage.listenToChangeLogEntryChanges(
      domainType: domainType,
      domainId: domainId,
      fireImmediately: true,
      onChanged: (entries) {
        unawaited(_scheduleLocalDomainStatsUpdate(domainType, domainId));
      },
    );

    final stateSub = _localStorage.listenToEntityTypeSyncStateChanges(
      domainType: domainType,
      domainId: domainId,
      fireImmediately: true,
      onChanged: (entries) {
        unawaited(_scheduleLocalDomainStatsUpdate(domainType, domainId));
      },
    );

    final cursorStateSub = _localStorage.listenToCursorSyncStateChanges(
      domainId: domainId,
      fireImmediately: true,
      onChanged: (entries) {
        unawaited(_scheduleLocalDomainStatsUpdate(domainType, domainId));
      },
    );

    _localDomainChangeLogSubscriptions[key] = changeLogSub;
    _localDomainStateSubscriptions[key] = stateSub;
    _localDomainCursorSyncStateSubscriptions[key] = cursorStateSub;
    SlttLogger.logger.info(
      '[SyncManager] Subscribed to local domain stats watchers for $key',
    );
  }

  void _unsubscribeFromLocalDomainStats(String domainType, String domainId) {
    final key = _domainChangeKey(domainType: domainType, domainId: domainId);
    _localDomainChangeLogSubscriptions[key]?.cancel();
    _localDomainStateSubscriptions[key]?.cancel();
    _localDomainCursorSyncStateSubscriptions[key]?.cancel();
    _localDomainStatsDebounceTimers[key]?.cancel();
    _localDomainChangeLogSubscriptions.remove(key);
    _localDomainStateSubscriptions.remove(key);
    _localDomainCursorSyncStateSubscriptions.remove(key);
    _localDomainStatsDebounceTimers.remove(key);
    SlttLogger.logger.info(
      '[SyncManager] Unsubscribed from local domain stats watchers for $key',
    );
  }

  Future<void> _scheduleLocalDomainStatsUpdate(
    String domainType,
    String domainId,
  ) async {
    final key = _domainChangeKey(domainType: domainType, domainId: domainId);
    _localDomainStatsDebounceTimers[key]?.cancel();
    _localDomainStatsDebounceTimers[key] = Timer(
      localDomainStatsDebounceDuration,
      () => unawaited(_emitLocalDomainStatsUpdate(domainType, domainId)),
    );
  }

  Future<void> _emitLocalDomainStatsUpdate(
    String domainType,
    String domainId,
  ) async {
    try {
      final update = await _buildLocalDomainStatsUpdate(
        domainType: domainType,
        domainId: domainId,
      );
      SlttLogger.logger.info(
        '[SyncManager] Emitting LocalDomainStatsUpdate for $domainType/$domainId: '
        'localChangeTotal=${update.localChangeStats.totals.total}, '
        'localStateTotal=${update.localStateStats.totals.total}, '
        'cursorSeq=${update.localCursorState?.seq ?? -1}',
      );
      _localDomainStatsEventsController.add(update);
    } catch (error, stackTrace) {
      SlttLogger.logger.warning(
        '[SyncManager] Failed to emit local stats update for $domainType/$domainId: $error',
        error,
        stackTrace,
      );
    }
  }

  Future<LocalDomainStatsUpdate> _buildLocalDomainStatsUpdate({
    required String domainType,
    required String domainId,
  }) async {
    final localChangeStats = await _localStorage.getChangeStats(
      domainType: domainType,
      domainId: domainId,
    );
    final localStateStats = await _localStorage.getStateStats(
      domainType: domainType,
      domainId: domainId,
    );
    final localCursorState = await _localStorage.getCursorSyncState(domainId);

    final effectiveCursorState =
        localCursorState ??
        CursorSyncState(
          domainType: domainType,
          domainId: domainId,
          storageId: await _localStorage.getStorageId(),
          storageType: _localStorage.getStorageType(),
          cid: '',
          changeAt: DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
          seq: 0,
          storedAt: DateTime.now().toUtc(),
        );

    return LocalDomainStatsUpdate(
      domainType: domainType,
      domainId: domainId,
      localChangeStats: localChangeStats,
      localStateStats: localStateStats,
      localCursorState: effectiveCursorState,
      observedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> _handleFetchedEntityStateEvent(
    EntityStateFetchEvent event,
  ) async {
    if (event.hasError) {
      return;
    }

    // Progress-only hook: storage is handled directly by
    // EntityStatePaginationService via onStoreFetchedItems callback.
    SlttLogger.logger.fine(
      '[SyncManager] Entity-state progress event '
      '(${event.entityType}/${event.domainType}/${event.domainId}) '
      'items=${event.items.length} hasMore=${event.hasMore} complete=${event.isComplete}',
    );
  }

  DomainStatsResponse _mergeCloudDomainStats({
    required String domainType,
    required String domainId,
    required DomainStatsResponse stats,
    bool treatAsFullSnapshot = false,
  }) {
    final key = _domainChangeKey(domainType: domainType, domainId: domainId);
    if (treatAsFullSnapshot) {
      _cachedCloudDomainStatsByDomain[key] = stats;
      return stats;
    }

    final previous = _cachedCloudDomainStatsByDomain[key];
    if (previous == null) {
      _cachedCloudDomainStatsByDomain[key] = stats;
      return stats;
    }

    final mergedChangeStats = stats.changeStats ?? previous.changeStats;
    final mergedStateStats = _mergeEntityTypeStats(
      previous.entityTypeStats,
      stats.entityTypeStats,
    );
    final mergedCollections =
        stats.entityTypeCollections ?? previous.entityTypeCollections;
    final mergedTimestamp = stats.timestamp ?? previous.timestamp;
    final mergedStorageType = stats.storageType ?? previous.storageType;

    final merged = DomainStatsResponse(
      domainId: domainId,
      domainType: domainType,
      changeStats: mergedChangeStats,
      entityTypeStats: mergedStateStats,
      entityTypeCollections: mergedCollections,
      timestamp: mergedTimestamp,
      storageType: mergedStorageType,
    );

    _cachedCloudDomainStatsByDomain[key] = merged;
    return merged;
  }

  EntityTypeStats? _mergeEntityTypeStats(
    EntityTypeStats? previous,
    EntityTypeStats? incoming,
  ) {
    if (previous == null) return incoming;
    if (incoming == null) return previous;

    final mergedEntityTypes = <String, EntityTypeSummary>{}
      ..addAll(previous.entityTypes);
    mergedEntityTypes.addAll(incoming.entityTypes);

    return EntityTypeStats(
      entityTypes: mergedEntityTypes,
      totals: incoming.totals,
    );
  }

  void _updateCloudStateDataHashes({
    required List<Map<String, dynamic>> incomingChanges,
    required Map<String, _StateHashSnapshot> finalStateHashesByKey,
    required String domainTypeContext,
    required String domainIdContext,
  }) {
    for (final incomingChange in incomingChanges) {
      final cloudStateDataHash = incomingChange['stateDataHash']?.toString();
      final updateKeys = _extractUpdateKeysFromChange(
        incomingChange,
        domainTypeContext: domainTypeContext,
        domainIdContext: domainIdContext,
        reason: 'malformed incoming change during downsync hash reconciliation',
      );
      if (updateKeys == null) continue;

      final updateDomainType = updateKeys['domainType']!;
      final updateDomainId = updateKeys['domainId']!;
      final updateEntityType = updateKeys['entityType']!;
      final updateEntityId = updateKeys['entityId']!;

      final key = _entityStateKey(
        domainType: updateDomainType,
        domainId: updateDomainId,
        entityType: updateEntityType,
        entityId: updateEntityId,
      );

      final previous = finalStateHashesByKey[key];
      finalStateHashesByKey[key] = _StateHashSnapshot(
        domainType: updateDomainType,
        domainId: updateDomainId,
        entityType: updateEntityType,
        entityId: updateEntityId,
        parentId: incomingChange['parentId']?.toString() ?? previous?.parentId,
        cloudStateDataHash: cloudStateDataHash ?? previous?.cloudStateDataHash,
        localStateDataHash: previous?.localStateDataHash,
      );
    }
  }

  void _updateLocalStateDataHashes({
    required List<Map<String, dynamic>> stateUpdates,
    required Map<String, _StateHashSnapshot> finalStateHashesByKey,
    required String domainTypeContext,
    required String domainIdContext,
  }) {
    for (final stateUpdate in stateUpdates) {
      final updateKeys = _extractUpdateKeysFromChange(
        stateUpdate,
        domainTypeContext: domainTypeContext,
        domainIdContext: domainIdContext,
        reason: 'malformed state update during downsync',
      );
      if (updateKeys == null) continue;

      final updateDomainType = updateKeys['domainType']!;
      final updateDomainId = updateKeys['domainId']!;
      final updateEntityType = updateKeys['entityType']!;
      final updateEntityId = updateKeys['entityId']!;

      final key = _entityStateKey(
        domainType: updateDomainType,
        domainId: updateDomainId,
        entityType: updateEntityType,
        entityId: updateEntityId,
      );
      final previous = finalStateHashesByKey[key];
      finalStateHashesByKey[key] = _StateHashSnapshot(
        domainType: updateDomainType,
        domainId: updateDomainId,
        entityType: updateEntityType,
        entityId: updateEntityId,
        parentId: stateUpdate['parentId']?.toString() ?? previous?.parentId,
        cloudStateDataHash: previous?.cloudStateDataHash,
        localStateDataHash: stateUpdate['stateDataHash']?.toString(),
      );
    }
  }

  void _updateStateChangedFalseStateDataHashes({
    required List<Map<String, dynamic>> changesStateFalse,
    required Map<String, _StateHashSnapshot> finalStateHashesByKey,
    required Set<String> warningBasedRefetchKeys,
    required String domainTypeContext,
    required String domainIdContext,
  }) {
    for (final incomingChange in changesStateFalse) {
      final warningStateDataHash = _extractIncomingStateDataHashWarning(
        incomingChange,
      );
      if (warningStateDataHash == null || warningStateDataHash.isEmpty) {
        continue;
      }

      final updateKeys = _extractUpdateKeysFromChange(
        incomingChange,
        domainTypeContext: domainTypeContext,
        domainIdContext: domainIdContext,
        reason:
            'malformed stateChanged=false change during warning-based reconciliation',
      );
      if (updateKeys == null) continue;

      final updateDomainType = updateKeys['domainType']!;
      final updateDomainId = updateKeys['domainId']!;
      final updateEntityType = updateKeys['entityType']!;
      final updateEntityId = updateKeys['entityId']!;

      final key = _entityStateKey(
        domainType: updateDomainType,
        domainId: updateDomainId,
        entityType: updateEntityType,
        entityId: updateEntityId,
      );
      warningBasedRefetchKeys.add(key);
      final previous = finalStateHashesByKey[key];

      finalStateHashesByKey[key] = _StateHashSnapshot(
        domainType: updateDomainType,
        domainId: updateDomainId,
        entityType: updateEntityType,
        entityId: updateEntityId,
        parentId: incomingChange['parentId']?.toString() ?? previous?.parentId,
        cloudStateDataHash:
            previous?.cloudStateDataHash ??
            incomingChange['stateDataHash']?.toString(),
        // For warning-based stateChanged=false changes, always carry forward
        // the warning hash so mismatch detection can enqueue a refetch.
        localStateDataHash: warningStateDataHash,
      );
    }
  }

  Future<int> _queueMismatchedEntityStateRefetches({
    required Map<String, _StateHashSnapshot> finalStateHashesByKey,
    required Set<String> queuedEntityStateFetchKeys,
  }) async {
    var mismatchCount = 0;
    for (final snapshot in finalStateHashesByKey.values) {
      final cloudStateDataHash = snapshot.cloudStateDataHash;
      final localStateDataHash = snapshot.localStateDataHash;
      if (cloudStateDataHash != null &&
          localStateDataHash != null &&
          localStateDataHash != cloudStateDataHash) {
        mismatchCount++;
        final key = _entityStateKey(
          domainType: snapshot.domainType,
          domainId: snapshot.domainId,
          entityType: snapshot.entityType,
          entityId: snapshot.entityId,
        );
        if (queuedEntityStateFetchKeys.add(key)) {
          await _logLocalEntityStateForEnqueue(
            domainType: snapshot.domainType,
            domainId: snapshot.domainId,
            entityType: snapshot.entityType,
            entityId: snapshot.entityId,
            parentId: snapshot.parentId,
            snapshot: snapshot,
          );
          enqueueJobFetchEntityState(
            domainType: snapshot.domainType,
            domainId: snapshot.domainId,
            entityType: snapshot.entityType,
            entityId: snapshot.entityId,
            parentId: snapshot.parentId,
          );
        }
      }
    }

    return mismatchCount;
  }

  Future<int> _queueWarningBasedEntityStateRefetches({
    required Set<String> warningBasedRefetchKeys,
    required Map<String, _StateHashSnapshot> finalStateHashesByKey,
    required Set<String> queuedEntityStateFetchKeys,
  }) async {
    var warningRefetchCount = 0;
    for (final key in warningBasedRefetchKeys) {
      final snapshot = finalStateHashesByKey[key];
      if (snapshot == null) continue;
      if (!queuedEntityStateFetchKeys.add(key)) continue;
      warningRefetchCount++;
      await _logLocalEntityStateForEnqueue(
        domainType: snapshot.domainType,
        domainId: snapshot.domainId,
        entityType: snapshot.entityType,
        entityId: snapshot.entityId,
        parentId: snapshot.parentId,
        snapshot: snapshot,
      );
      enqueueJobFetchEntityState(
        domainType: snapshot.domainType,
        domainId: snapshot.domainId,
        entityType: snapshot.entityType,
        entityId: snapshot.entityId,
        parentId: snapshot.parentId,
      );
    }
    return warningRefetchCount;
  }

  /// extra debugging logs to audit enqueued entity state refetches
  Future<void> _logLocalEntityStateForEnqueue({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
    String? parentId,
    _StateHashSnapshot? snapshot,
  }) async {
    try {
      final localState = await _localStorage.getEntityState(
        domainType: domainType,
        domainId: domainId,
        entityType: entityType,
        entityId: entityId,
      );
      if (localState == null) {
        SlttLogger.logger.info(
          '[SyncManager] Enqueuing entity state download for '
          '$domainType/$domainId/$entityType/$entityId parentId=${parentId ?? 'none'}; '
          'local state not found. snapshot=${snapshot?.toString() ?? 'none'}',
        );
        return;
      }

      final localStateJson = stableStringify(localState.toJson());
      final localStatePretty = const JsonEncoder.withIndent(
        '  ',
      ).convert(jsonDecode(localStateJson));
      SlttLogger.logger.info(
        '[SyncManager] Enqueuing entity state download for '
        '$domainType/$domainId/$entityType/$entityId parentId=${parentId ?? 'none'}; '
        'snapshot=${snapshot?.toString() ?? 'none'} local state: $localStatePretty',
      );
    } catch (e, stackTrace) {
      SlttLogger.logger.warning(
        '[SyncManager] Failed to read local entity state before enqueuing download '
        'for $domainType/$domainId/$entityType/$entityId: $e',
        e,
        stackTrace,
      );
    }
  }

  Map<String, String>? _extractUpdateKeysFromChange(
    Map<String, dynamic> change, {
    required String domainTypeContext,
    required String domainIdContext,
    required String reason,
  }) {
    final updateDomainType = change['domainType']?.toString();
    final updateDomainId = change['domainId']?.toString();
    final updateEntityType = change['entityType']?.toString();
    final updateEntityId = change['entityId']?.toString();
    if (updateDomainType == null ||
        updateDomainId == null ||
        updateEntityType == null ||
        updateEntityId == null) {
      SlttLogger.logger.warning(
        '[SyncManager] Skipping $reason for $domainTypeContext $domainIdContext: $change',
      );
      return null;
    }
    return {
      'domainType': updateDomainType,
      'domainId': updateDomainId,
      'entityType': updateEntityType,
      'entityId': updateEntityId,
    };
  }
}

class _StateHashSnapshot {
  final String domainType;
  final String domainId;
  final String entityType;
  final String entityId;
  final String? parentId;
  final String? cloudStateDataHash;
  final String? localStateDataHash;

  const _StateHashSnapshot({
    required this.domainType,
    required this.domainId,
    required this.entityType,
    required this.entityId,
    required this.parentId,
    required this.cloudStateDataHash,
    required this.localStateDataHash,
  });

  @override
  String toString() {
    return 'StateHashSnapshot('
        'domainType=$domainType, '
        'domainId=$domainId, '
        'entityType=$entityType, '
        'entityId=$entityId, '
        'parentId=${parentId ?? 'none'}, '
        'cloudStateDataHash=${cloudStateDataHash ?? 'null'}, '
        'localStateDataHash=${localStateDataHash ?? 'null'}'
        ')';
  }
}

// Result classes
class OutsyncResult {
  final bool success;
  final List<IsarChangeLogEntry> changesRequested;
  ChangeProcessingSummary? changeSummary;
  final List<String> deletedLocalChanges;
  final String message;
  final String? error; // Optional error for debugging
  final String? errorStackTrace;

  OutsyncResult({
    required this.success,
    required this.changesRequested,
    required this.changeSummary,
    required this.deletedLocalChanges,
    required this.message,
    this.error,
    this.errorStackTrace,
  });

  Map<String, dynamic> toJson() => {
    'success': success,
    'changeSummary': changeSummary?.toJson(),
    'message': message,
  };
}

typedef ProjectCursorChanges = Map<String, List<Map<String, dynamic>>>;
typedef StorageSummaries = Map<String, ChangeProcessingSummary?>;

class DownsyncResult {
  final bool success;
  final String message;

  /// list of each batch of changes downloaded per cursor request (keyed by $projectId/$cursor)
  final ProjectCursorChanges projectCursorChanges;

  /// list of processing summaries per cursor request (keyed by $projectId/$cursor)
  final StorageSummaries storageSummaries;

  /// Optional error details (populated when success == false)
  final String? error;
  final String? errorStackTrace;

  DownsyncResult({
    required this.success,
    required this.message,
    required this.projectCursorChanges,
    required this.storageSummaries,
    this.error,
    this.errorStackTrace,
  });

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'projectCursorChanges': projectCursorChanges,
    'storageSummaries': storageSummaries,
    'error': error,
    'errorStackTrace': errorStackTrace,
  };
}

class FullSyncResult {
  final OutsyncResult outsyncResult;
  final DownsyncResult downsyncResult;
  final bool success;

  FullSyncResult({
    required this.outsyncResult,
    required this.downsyncResult,
    required this.success,
  });

  Map<String, dynamic> toJson() => {
    'outsyncResult': outsyncResult.toJson(),
    'downsyncResult': downsyncResult.toJson(),
    'success': success,
  };
}

class SyncStatus {
  final EntityTypeStats? localChangeStats;
  final EntityTypeStats? localStateStats;
  final CursorSyncState? localCursorState;
  final EntityTypeSummary? cloudChangeStats;
  final EntityTypeStats? cloudStateStats;
  final int? remoteLastDomainSeq;
  final DateTime? remoteLastDomainChangeAt;

  SyncStatus({
    required this.localChangeStats,
    required this.localStateStats,
    required this.localCursorState,
    required this.cloudChangeStats,
    required this.cloudStateStats,
    required this.remoteLastDomainSeq,
    required this.remoteLastDomainChangeAt,
  });

  factory SyncStatus.fromJson(Map<String, dynamic> json) => SyncStatus(
    localChangeStats: json['localChangeStats'] != null
        ? EntityTypeStats.fromJson(
            Map<String, dynamic>.from(json['localChangeStats']),
          )
        : null,
    localStateStats: json['localStateStats'] != null
        ? EntityTypeStats.fromJson(
            Map<String, dynamic>.from(json['localStateStats']),
          )
        : null,
    localCursorState: json['localCursorState'] != null
        ? CursorSyncState.fromJson(
            Map<String, dynamic>.from(json['localCursorState']),
          )
        : null,
    cloudChangeStats: json['cloudChangeStats'] != null
        ? EntityTypeSummary.fromJson(
            Map<String, dynamic>.from(json['cloudChangeStats']),
          )
        : null,
    cloudStateStats: json['cloudStateStats'] != null
        ? EntityTypeStats.fromJson(
            Map<String, dynamic>.from(json['cloudStateStats']),
          )
        : null,
    remoteLastDomainSeq: json['remoteLastDomainSeq'] is int
        ? json['remoteLastDomainSeq'] as int
        : int.tryParse(json['remoteLastDomainSeq']?.toString() ?? ''),
    remoteLastDomainChangeAt: json['remoteLastDomainChangeAt'] == null
        ? null
        : DateTime.parse(json['remoteLastDomainChangeAt'] as String).toUtc(),
  );

  Map<String, dynamic> toJson() => {
    'localChangeStats': localChangeStats?.toJson(),
    'localStateStats': localStateStats?.toJson(),
    'localCursorState': localCursorState?.toJson(),
    'cloudChangeStats': cloudChangeStats?.toJson(),
    'cloudStateStats': cloudStateStats?.toJson(),
    'remoteLastDomainSeq': remoteLastDomainSeq,
    'remoteLastDomainChangeAt': remoteLastDomainChangeAt
        ?.toUtc()
        .toIso8601String(),
  };
}

int _remoteLastDomainSeqFromDomainStats(DomainStatsResponse stats) {
  if (stats.changeStats != null && stats.changeStats!.latestSeq > 0) {
    return stats.changeStats!.latestSeq;
  }
  if (stats.entityTypeStats != null &&
      stats.entityTypeStats!.totals.latestSeq > 0) {
    return stats.entityTypeStats!.totals.latestSeq;
  }
  return 0;
}

DateTime? _remoteLastDomainChangeAtFromDomainStats(DomainStatsResponse stats) {
  if (stats.timestamp == null) {
    return null;
  }

  try {
    return DateTime.parse(stats.timestamp!).toUtc();
  } catch (_) {
    return null;
  }
}
