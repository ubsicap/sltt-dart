import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/entity_state_pagination_job.isar.dart';
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

    test(
      'addedMe root notify change messages resolve the current JWT subject without a userId arg',
      () async {
        const userId = 'user-42';
        final jwt =
            'eyJhbGciOiJub25lIn0.${base64Url.encode(utf8.encode('{"sub":"$userId"}'))}.signature';
        syncManager.updateAuthToken(jwt);

        final before = syncManager.getEntityStatePaginationJobQueueCounts();
        await syncManager.processCrossDomainWsMessage(
          domainType: kDomainMembership,
          notifyType: WebsocketConstants.notifyTypeAddedMe,
          actionType: WebsocketConstants.actionChange,
          entityType: kEntityTypeMember,
          domainId: 'project-membership-root-1',
        );
        final after = syncManager.getEntityStatePaginationJobQueueCounts();

        expect(
          after.queuedSingle,
          greaterThan(before.queuedSingle),
          reason:
              'AddedMe membership change notifications should enqueue a root member fetch using the JWT subject when no userId param is supplied.',
        );
      },
    );

    test(
      'addedMe subscribe acks include the current JWT subject in the queued member fetch target',
      () async {
        const userId = 'user-42';
        final jwt =
            'eyJhbGciOiJub25lIn0.${base64Url.encode(utf8.encode('{"sub":"$userId"}'))}.signature';
        syncManager.updateAuthToken(jwt);

        await syncManager.processCrossDomainWsMessage(
          domainType: kDomainMembership,
          notifyType: WebsocketConstants.notifyTypeAddedMe,
          actionType: WebsocketConstants.actionSubscribe,
          entityType: kEntityTypeMember,
        );

        final queuedJobs = await syncManager.entityStatePaginationService
            .debugListPersistedJobs();
        expect(
          queuedJobs,
          anyElement(
            isA<EntityStatePaginationJobRecord>()
                .having(
                  (job) => job.domainType,
                  'domainType',
                  kDomainMembership,
                )
                .having(
                  (job) => job.entityType,
                  'entityType',
                  kEntityTypeMember,
                )
                .having((job) => job.entityId, 'entityId', userId)
                .having((job) => job.isCollection, 'isCollection', isTrue),
          ),
          reason:
              'AddedMe subscribe acknowledgements should queue a member-specific cross-domain fetch keyed to the current user.',
        );
      },
    );

    test(
      'membership root notify change messages use the userId as the member fetch target',
      () async {
        const userId = 'user-42';
        final jwt =
            'eyJhbGciOiJub25lIn0.${base64Url.encode(utf8.encode('{"sub":"$userId"}'))}.signature';
        syncManager.updateAuthToken(jwt);

        final before = syncManager.getEntityStatePaginationJobQueueCounts();
        await syncManager.processCrossDomainWsMessage(
          domainType: kDomainMembership,
          notifyType: WebsocketConstants.notifyTypeDomainChange,
          actionType: WebsocketConstants.actionChange,
          entityType: kEntityTypeMember,
          domainId: 'project-membership-root-1',
        );
        final after = syncManager.getEntityStatePaginationJobQueueCounts();

        expect(
          after.queuedSingle,
          greaterThan(before.queuedSingle),
          reason:
              'membership change notifications should enqueue a single fetch for the member userId even when the domainId remains the project id.',
        );

        final queuedJobs = await syncManager.entityStatePaginationService
            .debugListPersistedJobs();
        expect(
          queuedJobs,
          anyElement(
            isA<EntityStatePaginationJobRecord>()
                .having(
                  (job) => job.domainType,
                  'domainType',
                  kDomainMembership,
                )
                .having(
                  (job) => job.entityType,
                  'entityType',
                  kEntityTypeMember,
                )
                .having((job) => job.entityId, 'entityId', userId)
                .having(
                  (job) => job.domainId,
                  'domainId',
                  'project-membership-root-1',
                ),
          ),
          reason:
              'membership root fetches must use the member userId as the entityId while keeping the project id as the domainId.',
        );
      },
    );

    test(
      'close waits for queued pagination work before shutting down Isar storage',
      () async {
        syncManager.entityStatePaginationService.stopProcessing();

        await syncManager.processCrossDomainWsMessage(
          domainType: 'project',
          notifyType: WebsocketConstants.notifyTypeNewDomainId,
          actionType: WebsocketConstants.actionChange,
          entityType: 'project',
          domainId: 'project-root-change-close-1',
        );

        await syncManager.close();
      },
    );
  });
}
