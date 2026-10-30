import 'package:sync_manager/src/websocket_subscription_registry.dart';
import 'package:test/test.dart';

void main() {
  group('WebSocketSubscriptionRegistry connection lifecycle', () {
    late WebSocketSubscriptionRegistry registry;

    setUp(() {
      registry = WebSocketSubscriptionRegistry();
    });

    test('tracks a new subscription as pending until acknowledged', () {
      const key = 'user/domain-1';

      expect(
        registry.requestSubscribe(WebSocketSubscriptionKind.domainChange, key),
        isTrue,
        reason: 'A previously unknown subscription must create desired pending state.',
      );
      expect(
        registry.pendingDomainChangeKeys,
        contains(key),
        reason: 'A requested subscription must remain pending until the server confirms it.',
      );
      expect(
        registry.confirmedDomainChangeKeys,
        isNot(contains(key)),
        reason: 'Sending a subscribe request alone must not be treated as server confirmation.',
      );

      expect(
        registry.acknowledgeSubscribe(WebSocketSubscriptionKind.domainChange, key),
        isTrue,
        reason: 'A successful acknowledgment for a desired subscription must be accepted.',
      );
      expect(
        registry.pendingDomainChangeKeys,
        isNot(contains(key)),
        reason: 'A successful acknowledgment must remove the subscription from pending state.',
      );
      expect(
        registry.confirmedDomainChangeKeys,
        contains(key),
        reason: 'A successful acknowledgment must move the subscription into confirmed state.',
      );
    });

    test('moves every confirmed subscription category back to pending on loss', () {
      const changeKey = 'user/domain-change';
      const statsKey = 'user/domain-stats';
      const typeKey = 'workspace|newDomainId|';

      registry.requestSubscribe(WebSocketSubscriptionKind.domainChange, changeKey);
      registry.requestSubscribe(WebSocketSubscriptionKind.domainStats, statsKey);
      registry.requestSubscribe(WebSocketSubscriptionKind.domainType, typeKey);
      registry.acknowledgeSubscribe(WebSocketSubscriptionKind.domainChange, changeKey);
      registry.acknowledgeSubscribe(WebSocketSubscriptionKind.domainStats, statsKey);
      registry.acknowledgeSubscribe(WebSocketSubscriptionKind.domainType, typeKey);

      registry.onConnectionLost();

      expect(
        registry.confirmedDomainChangeKeys,
        isEmpty,
        reason: 'A domain-change subscription cannot remain confirmed after its WebSocket connection is lost.',
      );
      expect(
        registry.confirmedDomainStatsKeys,
        isEmpty,
        reason: 'A domain-stats subscription cannot remain confirmed after its WebSocket connection is lost.',
      );
      expect(
        registry.confirmedDomainTypeKeys,
        isEmpty,
        reason: 'A domain-type subscription cannot remain confirmed after its WebSocket connection is lost.',
      );
      expect(
        registry.pendingDomainChangeKeys,
        contains(changeKey),
        reason: 'The desired domain-change subscription must be queued for replay after reconnect.',
      );
      expect(
        registry.pendingDomainStatsKeys,
        contains(statsKey),
        reason: 'The desired domain-stats subscription must be queued for replay after reconnect.',
      );
      expect(
        registry.pendingDomainTypeKeys,
        contains(typeKey),
        reason: 'The desired domain-type subscription must be queued for replay after reconnect.',
      );
    });

    test('replayed subscription becomes confirmed only after new acknowledgment', () {
      const key = 'user/domain-replayed';
      registry.requestSubscribe(WebSocketSubscriptionKind.domainStats, key);
      registry.acknowledgeSubscribe(WebSocketSubscriptionKind.domainStats, key);
      registry.onConnectionLost();

      expect(
        registry.confirmedDomainStatsKeys,
        isEmpty,
        reason: 'The previous connection acknowledgment must be invalidated on disconnect.',
      );
      expect(
        registry.pendingDomainStatsKeys,
        contains(key),
        reason: 'The desired subscription must remain available for replay on the replacement connection.',
      );

      registry.acknowledgeSubscribe(WebSocketSubscriptionKind.domainStats, key);
      expect(
        registry.confirmedDomainStatsKeys,
        contains(key),
        reason: 'The replacement connection acknowledgment must restore confirmed state.',
      );
    });

    test('ignores a subscribe acknowledgment after desired state was removed', () {
      const key = 'user/domain-unsubscribed';
      registry.requestSubscribe(WebSocketSubscriptionKind.domainChange, key);
      registry.requestUnsubscribe(WebSocketSubscriptionKind.domainChange, key);

      expect(
        registry.acknowledgeSubscribe(WebSocketSubscriptionKind.domainChange, key),
        isFalse,
        reason: 'A late subscribe acknowledgment must not resurrect a subscription that is no longer desired.',
      );
      expect(
        registry.confirmedDomainChangeKeys,
        isNot(contains(key)),
        reason: 'A removed desired subscription must not enter confirmed state from a stale acknowledgment.',
      );
      expect(
        registry.pendingDomainChangeKeys,
        isNot(contains(key)),
        reason: 'Unsubscribing must remove the key from the pending subscribe queue.',
      );
    });

    test('retains unsubscribe intent until its acknowledgment', () {
      const identity = 'domainStats|user|domain-1|*|';
      final payload = <String, dynamic>{
        'action': 'unsubscribe',
        'notifyType': 'domainStats',
        'domainType': 'user',
        'domainId': 'domain-1',
        'entityType': '*',
      };
      registry.queueUnsubscription(identity, payload);

      expect(
        registry.pendingUnsubscriptions.keys,
        contains(identity),
        reason: 'An unsubscribe request must remain pending until the server confirms removal.',
      );
      expect(
        registry.acknowledgeUnsubscription(identity),
        isNotNull,
        reason: 'A matching successful unsubscribe acknowledgment must clear the pending operation.',
      );
      expect(
        registry.pendingUnsubscriptions.keys,
        isNot(contains(identity)),
        reason: 'An acknowledged unsubscribe must no longer be queued for replay.',
      );
    });

    test('exposes immutable state snapshots', () {
      registry.requestSubscribe(WebSocketSubscriptionKind.domainChange, 'user/domain-1');

      expect(
        () => registry.pendingDomainChangeKeys.add('user/illegal-mutation'),
        throwsUnsupportedError,
        reason: 'Callers must not mutate registry state outside its lifecycle methods.',
      );
    });
  });
}
