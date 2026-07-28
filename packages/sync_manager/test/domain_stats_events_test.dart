import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/unknown_entity_state.isar.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  group('SyncManager domain stats events', () {
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
      'getSyncStatus emits cloudDomainStatsEvents for fetched cloud stats',
      () async {
        final domainType = 'project';
        final domainId = 'test-domain-1';
        final lastSeq = 123;
        final timestamp = DateTime.now().toUtc().toIso8601String();
        final statsPayload = {
          'domainId': domainId,
          'domainType': domainType,
          'changeStats': {
            'creates': 1,
            'updates': 0,
            'deletes': 0,
            'total': 1,
            'latestChangeAt': timestamp,
            'latestSeq': lastSeq,
          },
          'entityTypeStats': {
            'entityTypes': {
              'unknown': {
                'creates': 1,
                'updates': 0,
                'deletes': 0,
                'total': 1,
                'latestChangeAt': timestamp,
                'latestSeq': lastSeq,
              },
            },
            'totals': {
              'creates': 1,
              'updates': 0,
              'deletes': 0,
              'total': 1,
              'latestChangeAt': timestamp,
              'latestSeq': lastSeq,
            },
          },
          'timestamp': timestamp,
          'storageType': 'cloud',
        };

        Response handler(Request request) {
          if (request.method == 'GET' &&
              request.requestedUri.path == '/api/stats/projects/$domainId') {
            return Response.ok(
              jsonEncode(statsPayload),
              headers: {'content-type': 'application/json'},
            );
          }
          return Response.notFound('Not found');
        }

        final server = await shelf_io.serve(handler, '127.0.0.1', 0);
        syncManager.configureCloudUrl(
          'http://${server.address.host}:${server.port}',
        );

        final eventFuture = syncManager.cloudDomainStatsEvents.first;
        await syncManager.getSyncStatus(domainId, domainType: domainType);
        final event = await eventFuture;

        expect(event.domainType, equals(domainType));
        expect(event.domainId, equals(domainId));
        expect(event.cloudStats, isNotNull);
        expect(event.cloudStats.changeStats?.latestSeq, equals(lastSeq));
        expect(event.cloudStats.entityTypeStats?.totals.total, equals(1));

        await server.close(force: true);
      },
    );

    test(
      'storeFetchedEntityStates emits localDomainStatsEvents after persistence',
      () async {
        final domainType = 'project';
        final domainId = 'test-domain-2';
        final now = DateTime.now().toUtc();

        syncManager.subscribeToDomain(
          notifyType: WebsocketConstants.notifyTypeDomainStats,
          domainType: domainType,
          domainId: domainId,
        );

        final unknownState = IsarUnknownEntityState(
          entityId: 'entity-1',
          domainType: domainType,
          change_domainId: domainId,
          change_domainId_orig_: domainId,
          change_changeAt: now,
          change_changeAt_orig_: now,
          change_storedAt: now,
          change_storedAt_orig_: now,
          change_cid: 'cid-1',
          change_cid_orig_: 'cid-1',
          change_changeBy: 'test',
          change_changeBy_orig_: 'test',
          data_parentId: 'parent-1',
          data_parentId_changeAt_: now,
          data_parentId_cid_: 'cid-1',
          data_parentId_changeBy_: 'test',
          data_parentProp: 'prop-1',
          data_parentProp_changeAt_: now,
          data_parentProp_cid_: 'cid-1',
          data_parentProp_changeBy_: 'test',
          unknownJson: jsonEncode({'hello': 'world'}),
        );

        final eventFuture = syncManager.localDomainStatsEvents.first;
        await syncManager.storeFetchedEntityStates(
          domainType: domainType,
          domainId: domainId,
          entityType: EntityType.unknown.value,
          items: [unknownState.toJson()],
          storedAt: now,
        );

        final event = await eventFuture;
        expect(event.domainType, equals(domainType));
        expect(event.domainId, equals(domainId));
        expect(event.localStateStats, isNotNull);
        expect(event.localStateStats.totals.total, greaterThanOrEqualTo(1));
      },
    );

    test(
      'subscribeToDomain emits localDomainStatsEvents for newly subscribed domain stats',
      () async {
        final domainType = 'project';
        final domainId = 'test-domain-3';

        final eventFuture = syncManager.localDomainStatsEvents.first;
        syncManager.subscribeToDomain(
          notifyType: WebsocketConstants.notifyTypeDomainStats,
          domainType: domainType,
          domainId: domainId,
        );

        final event = await eventFuture;
        expect(event.domainType, equals(domainType));
        expect(event.domainId, equals(domainId));
        expect(event.localChangeStats, isNotNull);
        expect(event.localStateStats, isNotNull);
        expect(event.localCursorState, isNotNull);
      },
    );

    test(
      'subscribed localDomainStatsEvent reflects a locally stored change log entry',
      () async {
        final domainType = 'project';
        final domainId = 'test-domain-4';
        final now = DateTime.now().toUtc();

        final changeData = changePayload(
          projectId: domainId,
          entityType: 'project',
          entityId: 'entity-1',
          changeAt: now,
          data: {
            'nameLocal': 'Test Project',
            'parentId': 'root',
            'parentProp': 'pList',
          },
          operation: 'create',
        );

        final storageId = await localStorage.getStorageId();
        final storedAt = now.toIso8601String();
        final change = IsarChangeLogEntry.fromJson(changeData);
        final request = ChangeLogAndStateRequest(
          changeLogEntry: change,
          changeUpdates: {
            'seq': 1,
            'stateChanged': true,
            'storageId': storageId,
            'storedAt': storedAt,
          },
          operationCounts: OperationCounts(create: 1),
          entityState: null,
          stateUpdates: {
            'domainType': domainType,
            'entityId': change.entityId,
            'entityType': change.entityType,
            'change_domainId': domainId,
            'change_changeAt': now.toIso8601String(),
            'change_cid': change.cid,
            'change_changeBy': 'tester',
            'change_storedAt': storedAt,
            'change_storedAt_orig_': storedAt,
            'change_domainId_orig_': '',
            'change_changeAt_orig_': BaseEntityState.defaultOrigDateTime()
                .toIso8601String(),
            'change_cid_orig_': '',
            'change_changeBy_orig_': '',
            'data_nameLocal': 'Test Project',
            'data_parentId': 'root',
            'data_parentId_changeAt_': now.toIso8601String(),
            'data_parentId_cid_': change.cid,
            'data_parentId_changeBy_': 'tester',
            'data_parentProp': 'pList',
            'data_parentProp_dataSchemaRev_': 0,
            'data_parentProp_changeAt_': now.toIso8601String(),
            'data_parentProp_cid_': change.cid,
            'data_parentProp_changeBy_': 'tester',
            'unknownJson': '{}',
          },
        );

        await localStorage.updateChangeLogAndStates(
          domainType: domainType,
          requests: [request],
        );

        final eventFuture = syncManager.localDomainStatsEvents.first;
        syncManager.subscribeToDomain(
          notifyType: WebsocketConstants.notifyTypeDomainStats,
          domainType: domainType,
          domainId: domainId,
        );

        final event = await eventFuture;
        expect(event.domainType, equals(domainType));
        expect(event.domainId, equals(domainId));
        expect(event.localChangeStats.totals.total, equals(1));
        expect(event.localStateStats.totals.total, greaterThanOrEqualTo(1));
      },
    );

    test(
      'lazy subscription after existing local change log entries still emits domain stats',
      () async {
        final domainType = 'project';
        final domainId = 'test-domain-5';
        final now = DateTime.now().toUtc();

        final changeData = changePayload(
          projectId: domainId,
          entityType: 'project',
          entityId: 'entity-2',
          changeAt: now,
          data: {
            'nameLocal': 'Test Project 2',
            'parentId': 'root',
            'parentProp': 'pList',
          },
          operation: 'create',
        );

        final storageId = await localStorage.getStorageId();
        final storedAt = now.toIso8601String();
        final change = IsarChangeLogEntry.fromJson(changeData);
        final request = ChangeLogAndStateRequest(
          changeLogEntry: change,
          changeUpdates: {
            'seq': 1,
            'stateChanged': true,
            'storageId': storageId,
            'storedAt': storedAt,
          },
          operationCounts: OperationCounts(create: 1),
          entityState: null,
          stateUpdates: {
            'domainType': domainType,
            'entityId': change.entityId,
            'entityType': change.entityType,
            'change_domainId': domainId,
            'change_changeAt': now.toIso8601String(),
            'change_cid': change.cid,
            'change_changeBy': 'tester',
            'change_storedAt': storedAt,
            'change_storedAt_orig_': storedAt,
            'change_domainId_orig_': '',
            'change_changeAt_orig_': BaseEntityState.defaultOrigDateTime()
                .toIso8601String(),
            'change_cid_orig_': '',
            'change_changeBy_orig_': '',
            'data_nameLocal': 'Test Project 2',
            'data_parentId': 'root',
            'data_parentId_changeAt_': now.toIso8601String(),
            'data_parentId_cid_': change.cid,
            'data_parentId_changeBy_': 'tester',
            'data_parentProp': 'pList',
            'data_parentProp_dataSchemaRev_': 0,
            'data_parentProp_changeAt_': now.toIso8601String(),
            'data_parentProp_cid_': change.cid,
            'data_parentProp_changeBy_': 'tester',
            'unknownJson': '{}',
          },
        );

        await localStorage.updateChangeLogAndStates(
          domainType: domainType,
          requests: [request],
        );

        // Subscribe after the local change has already been persisted.
        final eventFuture = syncManager.localDomainStatsEvents.first;
        syncManager.subscribeToDomain(
          notifyType: WebsocketConstants.notifyTypeDomainStats,
          domainType: domainType,
          domainId: domainId,
        );

        final event = await eventFuture;
        expect(event.domainType, equals(domainType));
        expect(event.domainId, equals(domainId));
        expect(event.localChangeStats.totals.total, equals(1));
        expect(event.localStateStats.totals.total, greaterThanOrEqualTo(1));
      },
    );
  });
}

Map<String, dynamic> changePayload({
  required String projectId,
  required String entityType,
  required String entityId,
  required DateTime changeAt,
  String storageId = '',
  Map<String, dynamic> data = const <String, dynamic>{},
  String operation = 'update',
  bool addDefaultParentId = true,
  int? seq,
}) {
  final adjustedData = Map<String, dynamic>.from(data);

  if (operation != 'delete') {
    final hasParentKey = adjustedData.containsKey('parentId');
    final parentVal = adjustedData['parentId'];
    if (addDefaultParentId && (!hasParentKey || parentVal == null)) {
      adjustedData['parentId'] = 'root';
    }

    final hasParentProp = adjustedData.containsKey('parentProp');
    final parentPropVal = adjustedData['parentProp'];
    if (!hasParentProp || parentPropVal == null) {
      adjustedData['parentProp'] = 'pList';
    }
  }

  if (operation != 'delete' &&
      entityType == 'task' &&
      !adjustedData.containsKey('nameLocal')) {
    adjustedData['nameLocal'] = 'Test $entityId';
  }

  return {
    'domainId': projectId,
    'domainType': 'project',
    'entityType': entityType,
    'entityId': entityId,
    'changeBy': 'tester',
    'changeAt': changeAt.toIso8601String(),
    'cid': generateCid(
      entityType: EntityType.tryFromString(entityType) ?? EntityType.unknown,
    ),
    'storageId': storageId,
    'operation': operation,
    'operationInfoJson': '{}',
    'stateChanged': false,
    'unknownJson': '{}',
    'dataJson': jsonEncode(adjustedData),
    if (seq != null) 'seq': seq,
  };
}
