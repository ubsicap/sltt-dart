import 'dart:collection';

/// The kind of remote subscription managed by [WebSocketSubscriptionRegistry].
enum WebSocketSubscriptionKind { domainChange, domainStats, domainType }

/// Tracks desired, pending, and server-confirmed WebSocket subscription state.
///
/// A confirmed subscription is scoped to the current WebSocket connection. Call
/// [onConnectionLost] when that connection ends so desired subscriptions become
/// pending again and can be replayed on the next connection.
class WebSocketSubscriptionRegistry {
  final Set<String> _pendingDomainChangeKeys = <String>{};
  final Set<String> _pendingDomainStatsKeys = <String>{};
  final Set<String> _pendingDomainTypeKeys = <String>{};
  final Set<String> _confirmedDomainChangeKeys = <String>{};
  final Set<String> _confirmedDomainStatsKeys = <String>{};
  final Set<String> _confirmedDomainTypeKeys = <String>{};
  final Map<String, Map<String, dynamic>> _pendingUnsubscriptions =
      <String, Map<String, dynamic>>{};

  Set<String> get pendingDomainChangeKeys =>
      UnmodifiableSetView(_pendingDomainChangeKeys);
  Set<String> get pendingDomainStatsKeys =>
      UnmodifiableSetView(_pendingDomainStatsKeys);
  Set<String> get pendingDomainTypeKeys =>
      UnmodifiableSetView(_pendingDomainTypeKeys);
  Set<String> get confirmedDomainChangeKeys =>
      UnmodifiableSetView(_confirmedDomainChangeKeys);
  Set<String> get confirmedDomainStatsKeys =>
      UnmodifiableSetView(_confirmedDomainStatsKeys);
  Set<String> get confirmedDomainTypeKeys =>
      UnmodifiableSetView(_confirmedDomainTypeKeys);
  Map<String, Map<String, dynamic>> get pendingUnsubscriptions =>
      UnmodifiableMapView(_pendingUnsubscriptions);

  Set<String> pendingKeys(WebSocketSubscriptionKind kind) {
    switch (kind) {
      case WebSocketSubscriptionKind.domainChange:
        return pendingDomainChangeKeys;
      case WebSocketSubscriptionKind.domainStats:
        return pendingDomainStatsKeys;
      case WebSocketSubscriptionKind.domainType:
        return pendingDomainTypeKeys;
    }
  }

  Set<String> confirmedKeys(WebSocketSubscriptionKind kind) {
    switch (kind) {
      case WebSocketSubscriptionKind.domainChange:
        return confirmedDomainChangeKeys;
      case WebSocketSubscriptionKind.domainStats:
        return confirmedDomainStatsKeys;
      case WebSocketSubscriptionKind.domainType:
        return confirmedDomainTypeKeys;
    }
  }

  /// Records that a subscription is desired. Returns true only for a new intent.
  bool requestSubscribe(WebSocketSubscriptionKind kind, String key) {
    if (confirmedKeys(kind).contains(key)) return false;
    return _mutablePendingKeys(kind).add(key);
  }

  /// Removes desired state locally. The caller is responsible for sending or
  /// queueing the corresponding server-side unsubscribe operation.
  bool requestUnsubscribe(WebSocketSubscriptionKind kind, String key) {
    final wasConfirmed = _mutableConfirmedKeys(kind).remove(key);
    final wasPending = _mutablePendingKeys(kind).remove(key);
    return wasConfirmed || wasPending;
  }

  /// Confirms a subscribe only if it is currently desired (pending or already
  /// confirmed). This prevents unsolicited/stale acknowledgments from creating
  /// subscriptions that the application no longer wants.
  bool acknowledgeSubscribe(WebSocketSubscriptionKind kind, String key) {
    final pending = _mutablePendingKeys(kind);
    final confirmed = _mutableConfirmedKeys(kind);
    if (!pending.remove(key) && !confirmed.contains(key)) return false;
    confirmed.add(key);
    return true;
  }

  /// On connection loss, server confirmation is invalidated but desired state
  /// is preserved for replay on the next connection.
  void onConnectionLost() {
    _pendingDomainChangeKeys.addAll(_confirmedDomainChangeKeys);
    _pendingDomainStatsKeys.addAll(_confirmedDomainStatsKeys);
    _pendingDomainTypeKeys.addAll(_confirmedDomainTypeKeys);
    _confirmedDomainChangeKeys.clear();
    _confirmedDomainStatsKeys.clear();
    _confirmedDomainTypeKeys.clear();
  }

  void queueUnsubscription(String identity, Map<String, dynamic> payload) {
    _pendingUnsubscriptions[identity] = Map<String, dynamic>.unmodifiable(payload);
  }

  Map<String, dynamic>? acknowledgeUnsubscription(String identity) =>
      _pendingUnsubscriptions.remove(identity);

  void removeUnsubscription(String identity) {
    _pendingUnsubscriptions.remove(identity);
  }

  bool get hasSubscriptions =>
      _pendingDomainChangeKeys.isNotEmpty ||
      _pendingDomainStatsKeys.isNotEmpty ||
      _pendingDomainTypeKeys.isNotEmpty ||
      _confirmedDomainChangeKeys.isNotEmpty ||
      _confirmedDomainStatsKeys.isNotEmpty ||
      _confirmedDomainTypeKeys.isNotEmpty;

  bool get hasPendingOperations =>
      _pendingDomainChangeKeys.isNotEmpty ||
      _pendingDomainStatsKeys.isNotEmpty ||
      _pendingDomainTypeKeys.isNotEmpty ||
      _pendingUnsubscriptions.isNotEmpty;

  bool get isEmpty => !hasSubscriptions && _pendingUnsubscriptions.isEmpty;

  Set<String> _mutablePendingKeys(WebSocketSubscriptionKind kind) {
    switch (kind) {
      case WebSocketSubscriptionKind.domainChange:
        return _pendingDomainChangeKeys;
      case WebSocketSubscriptionKind.domainStats:
        return _pendingDomainStatsKeys;
      case WebSocketSubscriptionKind.domainType:
        return _pendingDomainTypeKeys;
    }
  }

  Set<String> _mutableConfirmedKeys(WebSocketSubscriptionKind kind) {
    switch (kind) {
      case WebSocketSubscriptionKind.domainChange:
        return _confirmedDomainChangeKeys;
      case WebSocketSubscriptionKind.domainStats:
        return _confirmedDomainStatsKeys;
      case WebSocketSubscriptionKind.domainType:
        return _confirmedDomainTypeKeys;
    }
  }
}
