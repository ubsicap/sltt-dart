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
      'processCrossDomainSubscriptionAck stores states and enqueues the next collection page',
      () async {
        final now = DateTime.now().toUtc();
        final projectId = 'project-root-subscription-1';
        final state = IsarProjectState(
          entityId: projectId,
          entityType: 'project',
          domainType: 'project',
          unknownJson: '{}',
          change_storedAt: now,
          change_storedAt_orig_: now,
          schemaVersion: 1,
          change_domainId: projectId,
          change_domainId_orig_: projectId,
          change_changeAt: now,
          change_changeAt_orig_: now,
          change_cid: 'cid-1',
          change_cid_orig_: 'cid-1',
          change_cloudAt: now,
          change_changeBy: 'tester',
          change_changeBy_orig_: 'tester',
          data_nameLocal: 'Project Root',
          data_nameLocal_dataSchemaRev_: 1,
          data_nameLocal_changeAt_: now,
          data_nameLocal_cid_: 'cid-name',
          data_nameLocal_changeBy_: 'tester',
          data_nameLocal_cloudAt_: now,
          data_rank: '1',
          data_rank_dataSchemaRev_: 1,
          data_rank_changeAt_: now,
          data_rank_cid_: 'cid-rank',
          data_rank_changeBy_: 'tester',
          data_rank_cloudAt_: now,
          data_deleted: false,
          data_deleted_dataSchemaRev_: 1,
          data_deleted_changeAt_: now,
          data_deleted_cid_: 'cid-deleted',
          data_deleted_changeBy_: 'tester',
          data_deleted_cloudAt_: now,
          data_parentId: 'root',
          data_parentId_dataSchemaRev_: 1,
          data_parentId_changeAt_: now,
          data_parentId_cid_: 'cid-parent',
          data_parentId_changeBy_: 'tester',
          data_parentId_cloudAt_: now,
          data_parentProp: 'pList',
          data_parentProp_dataSchemaRev_: 1,
          data_parentProp_changeAt_: now,
          data_parentProp_cid_: 'cid-parent-prop',
          data_parentProp_changeBy_: 'tester',
          data_parentProp_cloudAt_: now,
          stateDataHash: 'hash-1',
          stateDataHash_orig_: 'hash-1',
        );

        syncManager.entityStatePaginationService.stopProcessing();

        await syncManager.processCrossDomainSubscriptionAck(
          domainType: 'project',
          notifyType: WebsocketConstants.notifyTypeNewDomainId,
          states: {
            'items': [state.toJson()],
            'nextCursor': 'cursor-123',
            'count': 1,
          },
        );

        final persisted = await localStorage.getEntityState(
          domainType: 'project',
          domainId: projectId,
          entityType: 'project',
          entityId: projectId,
        );

        expect(
          persisted,
          isNotNull,
          reason: 'Cross-domain subscription acks should persist states.',
        );
        expect(
          syncManager.getEntityStatePaginationJobQueueCounts().queuedCollection,
          greaterThanOrEqualTo(1),
          reason:
              'A nextCursor should schedule a follow-up cross-domain collection fetch.',
        );
      },
    );
  });
}
