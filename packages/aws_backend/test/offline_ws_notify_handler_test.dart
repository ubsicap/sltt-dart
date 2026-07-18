import 'dart:convert';

import 'package:aws_backend/src/websocket/domain_change_payload.dart'
    show
        DomainChangeData,
        WsNotifyRecord,
        kNotifyTypeDomainChange,
        buildDomainChangeNotificationPayload;
import 'package:test/test.dart';

import '../bin/websocket/websocket_connections_repository.dart';
import '../bin/websocket/websocket_management_client.dart';
import '../bin/websocket/ws_notify_handler.dart';

void main() {
  group('wsNotifyHandler helpers', () {
    test(
      'groupAndSortDomainChangeRecords sorts domain groups by latest record index ascending',
      () {
        final records = [
          WsNotifyRecord(
            domainType: 'project',
            domainId: 'proj-1',
            notifyType: kNotifyTypeDomainChange,
            entityType: 'task',
            data: DomainChangeData(
              name: 'task-update',
              lastDomainSeq: 1,
              lastDomainChangeAt: DateTime.parse('2026-07-17T00:00:00.000Z'),
            ),
            index: 1,
          ),
          WsNotifyRecord(
            domainType: 'project',
            domainId: 'proj-1',
            notifyType: kNotifyTypeDomainChange,
            entityType: 'task',
            data: DomainChangeData(
              name: 'task-later',
              lastDomainSeq: 2,
              lastDomainChangeAt: DateTime.parse('2026-07-17T00:00:01.000Z'),
            ),
            index: 3,
          ),
          WsNotifyRecord(
            domainType: 'project',
            domainId: 'proj-2',
            notifyType: kNotifyTypeDomainChange,
            entityType: 'note',
            data: DomainChangeData(
              name: 'note-update',
              lastDomainSeq: 1,
              lastDomainChangeAt: DateTime.parse('2026-07-17T00:00:00.000Z'),
            ),
            index: 2,
          ),
          WsNotifyRecord(
            domainType: 'project',
            domainId: 'proj-2',
            notifyType: kNotifyTypeDomainChange,
            entityType: 'note',
            data: DomainChangeData(
              name: 'note-later',
              lastDomainSeq: 2,
              lastDomainChangeAt: DateTime.parse('2026-07-17T00:00:01.000Z'),
            ),
            index: 5,
          ),
        ];

        final sortedGroups = groupAndSortDomainChangeRecords(records);

        expect(sortedGroups, hasLength(2));
        expect(sortedGroups[0].first.domainId, 'proj-1');
        expect(sortedGroups[0].last.index, 3);
        expect(sortedGroups[1].first.domainId, 'proj-2');
        expect(sortedGroups[1].last.index, 5);
      },
    );

    test(
      'collapseDomainChangeRecordsToLatestPerEntityType keeps only the latest record for each entityType',
      () {
        final group = [
          WsNotifyRecord(
            domainType: 'project',
            domainId: 'proj-1',
            notifyType: kNotifyTypeDomainChange,
            entityType: null,
            data: DomainChangeData(
              name: 'domain-update-1',
              lastDomainSeq: 1,
              lastDomainChangeAt: DateTime.parse('2026-07-17T00:00:00.000Z'),
            ),
            index: 1,
          ),
          WsNotifyRecord(
            domainType: 'project',
            domainId: 'proj-1',
            notifyType: kNotifyTypeDomainChange,
            entityType: null,
            data: DomainChangeData(
              name: 'domain-update-2',
              lastDomainSeq: 2,
              lastDomainChangeAt: DateTime.parse('2026-07-17T00:00:01.000Z'),
            ),
            index: 3,
          ),
          WsNotifyRecord(
            domainType: 'project',
            domainId: 'proj-1',
            notifyType: kNotifyTypeDomainChange,
            entityType: 'task',
            data: DomainChangeData(
              name: 'task-update-1',
              lastDomainSeq: 1,
              lastDomainChangeAt: DateTime.parse('2026-07-17T00:00:00.000Z'),
            ),
            index: 2,
          ),
          WsNotifyRecord(
            domainType: 'project',
            domainId: 'proj-1',
            notifyType: kNotifyTypeDomainChange,
            entityType: 'task',
            data: DomainChangeData(
              name: 'task-update-2',
              lastDomainSeq: 2,
              lastDomainChangeAt: DateTime.parse('2026-07-17T00:00:01.000Z'),
            ),
            index: 4,
          ),
        ];

        final latestRecords = collapseDomainChangeRecordsToLatestPerEntityType(
          group,
        );

        expect(latestRecords, hasLength(2));
        expect(latestRecords[0].entityType, isNull);
        expect(latestRecords[0].data.name, 'domain-update-2');
        expect(latestRecords[1].entityType, 'task');
        expect(latestRecords[1].data.name, 'task-update-2');
      },
    );

    test(
      'buildDomainChangeNotificationPayload includes required fields and optional entityType',
      () {
        final payload = buildDomainChangeNotificationPayload(
          domainType: 'project',
          domainId: 'proj-1',
          data: DomainChangeData(
            name: 'domain-update',
            lastDomainSeq: 1,
            lastDomainChangeAt: DateTime.parse('2026-07-17T00:00:00.000Z'),
          ),
          entityType: 'task',
        );

        expect(payload, {
          'action': 'change',
          'notifyType': kNotifyTypeDomainChange,
          'domainType': 'project',
          'domainId': 'proj-1',
          'entityType': 'task',
          'data': {
            'name': 'domain-update',
            'lastDomainSeq': 1,
            'lastDomainChangeAt': '2026-07-17T00:00:00.000Z',
          },
        });
      },
    );
  });

  group('wsNotifyHandler', () {
    test('groups records by domain and sorts by earliest group', () async {
      final connections = _FakeConnectionsRepository();
      final management = _FakeManagementClient(connections: connections);

      connections.subscriptionsByDomain['project|proj-1'] = [
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-wildcard-1',
          entityType: '*',
        ),
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-task-1',
          entityType: 'task',
        ),
      ];
      connections.subscriptionsByDomain['project|proj-2'] = [
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-wildcard-2',
          entityType: '*',
        ),
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-note-1',
          entityType: 'note',
        ),
      ];

      final event = {
        'Records': [
          {
            'Sns': {
              'Message': jsonEncode({
                'notifyType': kNotifyTypeDomainChange,
                'domainType': 'project',
                'domainId': 'proj-2',
                'entityType': 'note',
                'data': DomainChangeData(
                  name: 'note-updated',
                  lastDomainSeq: 2,
                  lastDomainChangeAt: DateTime.parse(
                    '2026-07-17T00:00:00.000Z',
                  ),
                ).toJson(),
              }),
            },
          },
          {
            'Sns': {
              'Message': jsonEncode({
                'notifyType': kNotifyTypeDomainChange,
                'domainType': 'project',
                'domainId': 'proj-1',
                'entityType': 'task',
                'data': DomainChangeData(
                  name: 'task-updated',
                  lastDomainSeq: 1,
                  lastDomainChangeAt: DateTime.parse(
                    '2026-07-17T00:00:00.000Z',
                  ),
                ).toJson(),
              }),
            },
          },
        ],
      };

      await wsNotifyHandler(
        event,
        connections: connections,
        management: management,
      );

      expect(connections.queries, hasLength(2));
      expect(connections.queries[0], {
        'domainType': 'project',
        'domainId': 'proj-2',
      });
      expect(connections.queries[1], {
        'domainType': 'project',
        'domainId': 'proj-1',
      });

      expect(management.sentMessages, hasLength(4));
      expect(management.sentMessages[0]['connectionId'], 'conn-wildcard-2');
      expect(management.sentMessages[1]['connectionId'], 'conn-note-1');
      expect(management.sentMessages[2]['connectionId'], 'conn-wildcard-1');
      expect(management.sentMessages[3]['connectionId'], 'conn-task-1');
    });

    test(
      'handles entityType null by delivering only to wildcard subscribers',
      () async {
        final connections = _FakeConnectionsRepository();
        final management = _FakeManagementClient(connections: connections);

        connections.subscriptionsByDomain['project|proj-1'] = [
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-wildcard',
            entityType: '*',
          ),
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-task',
            entityType: 'task',
          ),
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-note',
            entityType: 'note',
          ),
        ];

        final event = {
          'Records': [
            {
              'Sns': {
                'Message': jsonEncode({
                  'notifyType': kNotifyTypeDomainChange,
                  'domainType': 'project',
                  'domainId': 'proj-1',
                  'data': DomainChangeData(
                    name: 'domain-update',
                    lastDomainSeq: 1,
                    lastDomainChangeAt: DateTime.parse(
                      '2026-07-17T00:00:00.000Z',
                    ),
                  ).toJson(),
                }),
              },
            },
          ],
        };

        await wsNotifyHandler(
          event,
          connections: connections,
          management: management,
        );

        expect(connections.queries, hasLength(1));
        expect(
          management.sentMessages.map((e) => e['connectionId']),
          equals(['conn-wildcard']),
        );
        expect(management.sentMessages.length, 1);
      },
    );

    test(
      'deduplicates wildcard and exact matches for the same connection',
      () async {
        final connections = _FakeConnectionsRepository();
        final management = _FakeManagementClient(connections: connections);

        connections.subscriptionsByDomain['project|proj-1'] = [
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-both',
            entityType: '*',
          ),
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-both',
            entityType: 'task',
          ),
        ];

        final event = {
          'Records': [
            {
              'Sns': {
                'Message': jsonEncode({
                  'notifyType': kNotifyTypeDomainChange,
                  'domainType': 'project',
                  'domainId': 'proj-1',
                  'entityType': 'task',
                  'data': DomainChangeData(
                    name: 'task-updated',
                    lastDomainSeq: 1,
                    lastDomainChangeAt: DateTime.parse(
                      '2026-07-17T00:00:00.000Z',
                    ),
                  ).toJson(),
                }),
              },
            },
          ],
        };

        await wsNotifyHandler(
          event,
          connections: connections,
          management: management,
        );

        expect(management.sentMessages, hasLength(1));
        expect(management.sentMessages[0]['connectionId'], 'conn-both');
      },
    );

    test(
      'delivers the latest group record to last-record subscribers',
      () async {
        final connections = _FakeConnectionsRepository();
        final management = _FakeManagementClient(connections: connections);

        connections.subscriptionsByDomain['project|proj-1'] = [
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-wildcard',
            entityType: '*',
          ),
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-task',
            entityType: 'task',
          ),
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-last-record',
            entityType: r'$',
          ),
        ];

        final event = {
          'Records': [
            {
              'Sns': {
                'Message': jsonEncode({
                  'notifyType': kNotifyTypeDomainChange,
                  'domainType': 'project',
                  'domainId': 'proj-1',
                  'entityType': 'task',
                  'data': DomainChangeData(
                    name: 'task-update',
                    lastDomainSeq: 1,
                    lastDomainChangeAt: DateTime.parse(
                      '2026-07-17T00:00:00.000Z',
                    ),
                  ).toJson(),
                }),
              },
            },
            {
              'Sns': {
                'Message': jsonEncode({
                  'notifyType': kNotifyTypeDomainChange,
                  'domainType': 'project',
                  'domainId': 'proj-1',
                  'entityType': 'note',
                  'data': DomainChangeData(
                    name: 'note-update',
                    lastDomainSeq: 2,
                    lastDomainChangeAt: DateTime.parse(
                      '2026-07-17T00:00:01.000Z',
                    ),
                  ).toJson(),
                }),
              },
            },
          ],
        };

        await wsNotifyHandler(
          event,
          connections: connections,
          management: management,
        );

        expect(management.sentMessages, hasLength(4));
        expect(
          management.sentMessages.map((msg) => msg['connectionId']),
          containsAll(['conn-wildcard', 'conn-task', 'conn-last-record']),
        );

        final lastRecordMessages = management.sentMessages
            .where((msg) => msg['connectionId'] == 'conn-last-record')
            .toList();
        expect(lastRecordMessages, hasLength(1));
        expect(lastRecordMessages[0]['payload']['data']['name'], 'note-update');
      },
    );

    test('sends only the latest domainChange data per entityType', () async {
      final connections = _FakeConnectionsRepository();
      final management = _FakeManagementClient(connections: connections);

      connections.subscriptionsByDomain['project|proj-1'] = [
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-wildcard',
          entityType: '*',
        ),
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-note',
          entityType: 'note',
        ),
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-task',
          entityType: 'task',
        ),
      ];

      final event = {
        'Records': [
          {
            'Sns': {
              'Message': jsonEncode({
                'notifyType': kNotifyTypeDomainChange,
                'domainType': 'project',
                'domainId': 'proj-1',
                'data': DomainChangeData(
                  name: 'domain-old',
                  lastDomainSeq: 1,
                  lastDomainChangeAt: DateTime.parse(
                    '2026-07-17T00:00:00.000Z',
                  ),
                ).toJson(),
              }),
            },
          },
          {
            'Sns': {
              'Message': jsonEncode({
                'notifyType': kNotifyTypeDomainChange,
                'domainType': 'project',
                'domainId': 'proj-1',
                'entityType': 'note',
                'data': DomainChangeData(
                  name: 'note-old',
                  lastDomainSeq: 1,
                  lastDomainChangeAt: DateTime.parse(
                    '2026-07-17T00:00:00.000Z',
                  ),
                ).toJson(),
              }),
            },
          },
          {
            'Sns': {
              'Message': jsonEncode({
                'notifyType': kNotifyTypeDomainChange,
                'domainType': 'project',
                'domainId': 'proj-1',
                'entityType': 'task',
                'data': DomainChangeData(
                  name: 'task-only',
                  lastDomainSeq: 1,
                  lastDomainChangeAt: DateTime.parse(
                    '2026-07-17T00:00:00.000Z',
                  ),
                ).toJson(),
              }),
            },
          },
          {
            'Sns': {
              'Message': jsonEncode({
                'notifyType': kNotifyTypeDomainChange,
                'domainType': 'project',
                'domainId': 'proj-1',
                'entityType': 'note',
                'data': DomainChangeData(
                  name: 'note-latest',
                  lastDomainSeq: 2,
                  lastDomainChangeAt: DateTime.parse(
                    '2026-07-17T00:00:01.000Z',
                  ),
                ).toJson(),
              }),
            },
          },
          {
            'Sns': {
              'Message': jsonEncode({
                'notifyType': kNotifyTypeDomainChange,
                'domainType': 'project',
                'domainId': 'proj-1',
                'data': DomainChangeData(
                  name: 'domain-latest',
                  lastDomainSeq: 2,
                  lastDomainChangeAt: DateTime.parse(
                    '2026-07-17T00:00:01.000Z',
                  ),
                ).toJson(),
              }),
            },
          },
        ],
      };

      await wsNotifyHandler(
        event,
        connections: connections,
        management: management,
      );

      final wildcardMessages = management.sentMessages
          .where((msg) => msg['connectionId'] == 'conn-wildcard')
          .toList();
      expect(wildcardMessages.length, 3);
      expect(
        wildcardMessages.map((msg) => msg['payload']['data']['name']),
        containsAll(['domain-latest', 'note-latest', 'task-only']),
      );
      expect(
        wildcardMessages.map((msg) => msg['payload']['data']['name']),
        isNot(contains('domain-old')),
      );
      expect(
        wildcardMessages.map((msg) => msg['payload']['data']['name']),
        isNot(contains('note-old')),
      );

      final noteMessages = management.sentMessages
          .where((msg) => msg['connectionId'] == 'conn-note')
          .toList();
      expect(noteMessages, hasLength(1));
      expect(
        noteMessages.map((msg) => msg['payload']['data']['name']),
        containsAll(['note-latest']),
      );
      expect(
        noteMessages.map((msg) => msg['payload']['data']['name']),
        isNot(contains('domain-latest')),
      );

      final taskMessages = management.sentMessages
          .where((msg) => msg['connectionId'] == 'conn-task')
          .toList();
      expect(taskMessages, hasLength(1));
      expect(
        taskMessages.map((msg) => msg['payload']['data']['name']),
        containsAll(['task-only']),
      );
      expect(
        taskMessages.map((msg) => msg['payload']['data']['name']),
        isNot(contains('domain-latest')),
      );
    });

    test('ignores unsupported notifyType values', () async {
      final connections = _FakeConnectionsRepository();
      final management = _FakeManagementClient(connections: connections);

      connections.subscriptionsByDomain['project|proj-1'] = [
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-wildcard',
          entityType: '*',
        ),
      ];

      final event = {
        'Records': [
          {
            'Sns': {
              'Message': jsonEncode({
                'notifyType': 'unknownType',
                'domainType': 'project',
                'domainId': 'proj-1',
                'entityType': 'task',
                'data': {'name': 'task-updated'},
              }),
            },
          },
        ],
      };

      await wsNotifyHandler(
        event,
        connections: connections,
        management: management,
      );

      expect(connections.queries, isEmpty);
      expect(management.sentMessages, isEmpty);
    });
  });
}

class _FakeConnectionsRepository implements WebsocketConnectionsRepository {
  _FakeConnectionsRepository();

  @override
  final bool useLocalDynamoDB = false;
  @override
  final String? localEndpoint = null;

  final List<Map<String, dynamic>> queries = [];
  final Map<String, List<WebsocketSubscriptionMatch>> subscriptionsByDomain =
      {};

  @override
  Future<List<WebsocketSubscriptionMatch>> findSubscribersByDomain({
    required String domainType,
    required String domainId,
  }) async {
    queries.add({'domainType': domainType, 'domainId': domainId});
    return subscriptionsByDomain['$domainType|$domainId'] ?? [];
  }

  @override
  Future<List<String>> findSubscribers({
    required String domainType,
    required String domainId,
    String? entityType,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> deleteConnectionAndSubscriptions(String connectionId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSubscription({
    required String connectionId,
    required String domainType,
    required String domainId,
    String? entityType,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> putConnection({
    required String connectionId,
    required String userId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> putSubscription({
    required String connectionId,
    required String domainType,
    required String domainId,
    String? entityType,
  }) {
    throw UnimplementedError();
  }
}

class _FakeManagementClient implements WebsocketManagementClient {
  _FakeManagementClient({required this.connections});

  @override
  final WebsocketConnectionsRepository connections;

  final List<Map<String, dynamic>> sentMessages = [];

  @override
  Future<void> send(String connectionId, Map<String, dynamic> payload) async {
    sentMessages.add({'connectionId': connectionId, 'payload': payload});
  }

  @override
  Future<void> close() async {}
}
