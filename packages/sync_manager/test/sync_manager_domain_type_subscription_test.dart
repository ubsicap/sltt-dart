import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/sync_manager_websocket_client.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  group('SyncManager domain type subscriptions', () {
    late SyncManager syncManager;
    late LocalStorageService localStorage;

    setUp(() async {
      syncManager = SyncManager.instance;
      localStorage = LocalStorageService.instance;

      await localStorage.initialize();
      await localStorage.deleteDatabase();
      await localStorage.initialize();
      await syncManager.initialize(localStorage: localStorage);
    });

    tearDown(() async {
      await syncManager.close();
      await localStorage.deleteDatabase();
    });

    test(
      'subscribeToDomainType sends a root subscription without a domainId',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final payloadCompleter = Completer<Map<String, dynamic>>();

        server.listen((HttpRequest request) async {
          final socket = await WebSocketTransformer.upgrade(request);
          socket.listen(
            (dynamic raw) {
              if (raw is! String) return;
              final payload = jsonDecode(raw) as Map<String, dynamic>;
              if (!payloadCompleter.isCompleted) {
                payloadCompleter.complete(payload.cast<String, dynamic>());
              }
            },
            onDone: () async {
              await server.close();
            },
          );
        });

        final client = SyncManagerWebSocketClient(
          cloudWssUrl: 'ws://127.0.0.1:${server.port}',
          authToken: 'token-123',
        );

        await client.connect();
        client.subscribe(
          'project',
          notifyType: WebsocketConstants.notifyTypeNewDomainId,
          entityType: 'project',
        );

        final payload = await payloadCompleter.future.timeout(
          const Duration(seconds: 5),
        );

        expect(payload['domainType'], equals('project'));
        expect(
          payload['notifyType'],
          equals(WebsocketConstants.notifyTypeNewDomainId),
        );
        expect(payload['entityType'], equals('project'));
        expect(payload.containsKey('domainId'), isTrue);
        expect(payload['domainId'], isEmpty);

        await client.disconnect();
        await server.close();
      },
    );

    test(
      'processCrossDomainWsMessage queues the initial collection fetch without persisting states',
      () async {
        syncManager.entityStatePaginationService.stopProcessing();

        await syncManager.processCrossDomainWsMessage(
          domainType: 'project',
          notifyType: WebsocketConstants.notifyTypeNewDomainId,
          actionType: WebsocketConstants.actionSubscribe,
          entityType: 'project',
        );

        final persisted = await localStorage.getEntityState(
          domainType: 'project',
          domainId: '',
          entityType: 'project',
          entityId: 'project-root-subscription-1',
        );

        expect(
          persisted,
          isNull,
          reason:
              'Root subscription acks should not persist raw states directly.',
        );
        expect(
          syncManager.getEntityStatePaginationJobQueueCounts().queuedCollection,
          greaterThanOrEqualTo(1),
          reason:
              'Root subscription acks should enqueue the initial cross-domain collection fetch.',
        );
      },
    );

    test(
      'root notify change messages with domainId enqueue a single root-state fetch',
      () async {
        syncManager.entityStatePaginationService.stopProcessing();

        final countsBefore = syncManager
            .getEntityStatePaginationJobQueueCounts();
        await syncManager.processCrossDomainWsMessage(
          domainType: 'project',
          notifyType: WebsocketConstants.notifyTypeNewDomainId,
          actionType: WebsocketConstants.actionChange,
          entityType: 'project',
          domainId: 'project-root-change-1',
        );

        final countsAfter = syncManager
            .getEntityStatePaginationJobQueueCounts();

        expect(
          countsAfter.queuedSingle,
          greaterThan(countsBefore.queuedSingle),
          reason:
              'root notify change events should enqueue a single root entity fetch when a domainId is present.',
        );
        expect(
          countsAfter.queuedCollection,
          equals(countsBefore.queuedCollection),
          reason:
              'domain-scoped root change events should not fall back to the collection fetch path.',
        );
      },
    );
  });
}
