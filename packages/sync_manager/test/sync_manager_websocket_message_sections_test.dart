import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

Map<String, dynamic> _projectStateJson({
  required String projectId,
  required String domainId,
}) {
  final now = DateTime.now().toUtc();
  final state = IsarProjectState(
    entityId: projectId,
    entityType: 'project',
    domainType: 'project',
    unknownJson: '{}',
    change_storedAt: now,
    change_storedAt_orig_: now,
    schemaVersion: 1,
    change_domainId: domainId,
    change_domainId_orig_: domainId,
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
  return state.toJson();
}

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
      'handleWebSocketSubscribeAckMessage persists root-domain states',
      () async {
        const domainType = 'project';
        const userId = 'user-123';
        const projectId = 'project-ack-1';
        syncManager.subscribedDomainTypeKeys.add(
          '$domainType|${WebsocketConstants.notifyTypeAddedMe}|$userId',
        );

        final message = {
          'action': WebsocketConstants.actionSubscribe,
          'status': 'ok',
          'domainType': domainType,
          'notifyType': WebsocketConstants.notifyTypeAddedMe,
          'userId': userId,
          'entityType': 'project',
          'states': {
            'items': [
              _projectStateJson(projectId: projectId, domainId: projectId),
            ],
            'count': 1,
          },
        };

        await syncManager.handleWebSocketSubscribeAckMessage(message);

        final persisted = await localStorage.getEntityState(
          domainType: domainType,
          domainId: projectId,
          entityType: 'project',
          entityId: projectId,
        );

        expect(
          persisted,
          isNotNull,
          reason: 'Root subscription acks should persist the new domain state.',
        );
      },
    );

    test(
      'handleWebSocketRootDomainTypeChangeMessage persists change updates',
      () async {
        const domainType = 'project';
        const userId = 'user-123';
        const projectId = 'project-change-1';
        syncManager.subscribedDomainTypeKeys.add(
          '$domainType|${WebsocketConstants.notifyTypeNewDomainId}|$userId',
        );

        final message = {
          'action': WebsocketConstants.actionChange,
          'notifyType': WebsocketConstants.notifyTypeNewDomainId,
          'domainType': domainType,
          'userId': userId,
          'entityType': 'project',
          'states': {
            'items': [
              _projectStateJson(projectId: projectId, domainId: projectId),
            ],
            'count': 1,
          },
        };

        await syncManager.handleWebSocketRootDomainTypeChangeMessage(message);

        final persisted = await localStorage.getEntityState(
          domainType: domainType,
          domainId: projectId,
          entityType: 'project',
          entityId: projectId,
        );

        expect(
          persisted,
          isNotNull,
          reason:
              'Root domain-type change events should process their state payloads.',
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
