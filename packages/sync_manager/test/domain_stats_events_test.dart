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
  });
}
