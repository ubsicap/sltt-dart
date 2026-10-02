import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  group('SyncManager websocket message sections', () {
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
      'handleWebSocketSubscribeAckMessage queues a root fetch for a top-level domainId',
      () async {
        const domainType = 'project';
        const userId = 'user-123';
        const projectId = 'project-ack-1';
        syncManager.entityStatePaginationService.stopProcessing();
        syncManager.subscribedDomainTypeKeys.add(
          '$domainType|${WebsocketConstants.notifyTypeAddedMe}|$userId',
        );

        final message = {
          'action': WebsocketConstants.actionSubscribe,
          'status': 'ok',
          'domainType': domainType,
          'domainId': projectId,
          'notifyType': WebsocketConstants.notifyTypeAddedMe,
          'userId': userId,
          'entityType': 'project',
        };

        final before = syncManager.getEntityStatePaginationJobQueueCounts();
        await syncManager.handleWebSocketSubscribeAckMessage(message);
        final after = syncManager.getEntityStatePaginationJobQueueCounts();

        expect(
          after.queuedSingle,
          greaterThan(before.queuedSingle),
          reason:
              'root subscription acks with a top-level domainId should enqueue a single root fetch.',
        );
      },
    );

    test(
      'handleWebSocketRootDomainTypeChangeMessage queues a root fetch using the message domainId',
      () async {
        const domainType = 'project';
        const userId = 'user-123';
        const projectId = 'project-change-1';
        syncManager.entityStatePaginationService.stopProcessing();
        syncManager.subscribedDomainTypeKeys.add(
          '$domainType|${WebsocketConstants.notifyTypeNewDomainId}|$userId',
        );

        final message = {
          'action': WebsocketConstants.actionChange,
          'notifyType': WebsocketConstants.notifyTypeNewDomainId,
          'domainType': domainType,
          'domainId': projectId,
          'userId': userId,
          'entityType': 'project',
        };

        final before = syncManager.getEntityStatePaginationJobQueueCounts();
        await syncManager.handleWebSocketRootDomainTypeChangeMessage(message);
        final after = syncManager.getEntityStatePaginationJobQueueCounts();

        expect(
          after.queuedSingle,
          greaterThan(before.queuedSingle),
          reason:
              'root domain-type change events should enqueue a single root fetch using the message domainId.',
        );
      },
    );

    test(
      'handleWebSocketDomainStatsChangeMessage emits a cloud stats update',
      () async {
        const domainType = 'project';
        const domainId = 'project-stats-1';
        const seq = 42;
        final observedAt = DateTime.now().toUtc();
        syncManager.subscribedDomainStatsKeys.add('$domainType/$domainId');

        final message = {
          'action': WebsocketConstants.actionChange,
          'notifyType': WebsocketConstants.notifyTypeDomainStats,
          'domainType': domainType,
          'domainId': domainId,
          'stats': {
            'domainId': domainId,
            'domainType': domainType,
            'changeStats': {
              'creates': 1,
              'updates': 0,
              'deletes': 0,
              'total': 1,
              'latestChangeAt': observedAt.toIso8601String(),
              'latestSeq': seq,
            },
            'entityTypeStats': {
              'entityTypes': {
                'project': {
                  'creates': 1,
                  'updates': 0,
                  'deletes': 0,
                  'total': 1,
                  'latestChangeAt': observedAt.toIso8601String(),
                  'latestSeq': seq,
                },
              },
              'totals': {
                'creates': 1,
                'updates': 0,
                'deletes': 0,
                'total': 1,
                'latestChangeAt': observedAt.toIso8601String(),
                'latestSeq': seq,
              },
            },
            'timestamp': observedAt.toIso8601String(),
            'storageType': 'cloud',
          },
        };

        final eventFuture = syncManager.cloudDomainStatsEvents.first;
        syncManager.handleWebSocketDomainStatsChangeMessage(message);

        final event = await eventFuture;
        expect(event.domainType, equals(domainType));
        expect(event.domainId, equals(domainId));
        expect(event.cloudStats.changeStats?.latestSeq, equals(seq));
      },
    );
  });
}
