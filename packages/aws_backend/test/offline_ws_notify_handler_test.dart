import 'dart:convert';

import 'package:aws_backend/src/websocket/domain_change_payload.dart'
    show
        WsNotifyRecord,
        kNotifyTypeDomainChange,
        kNotifyTypeDomainStats,
        buildDomainChangeNotificationPayload,
        buildDomainStatsNotificationPayload,
        buildWsNotifyRecordMessage;
import 'package:sltt_core/sltt_core.dart' show WebsocketConstants;
import 'package:test/test.dart';

import '../bin/websocket/websocket_connections_repository.dart';
import '../bin/websocket/websocket_keys.dart';
import '../bin/websocket/websocket_management_client.dart';
import '../bin/websocket/ws_notify_handler.dart';
import '../bin/websocket/ws_subscribe_handler.dart';

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
            change: _change(name: 'task-update', seq: 1),
            index: 1,
          ),
          WsNotifyRecord(
            domainType: 'project',
            domainId: 'proj-1',
            notifyType: kNotifyTypeDomainChange,
            entityType: 'task',
            change: _change(
              name: 'task-later',
              seq: 2,
              changeAt: '2026-07-17T00:00:01.000Z',
            ),
            index: 3,
          ),
          WsNotifyRecord(
            domainType: 'project',
            domainId: 'proj-2',
            notifyType: kNotifyTypeDomainChange,
            entityType: 'note',
            change: _change(name: 'note-update', seq: 1),
            index: 2,
          ),
          WsNotifyRecord(
            domainType: 'project',
            domainId: 'proj-2',
            notifyType: kNotifyTypeDomainChange,
            entityType: 'note',
            change: _change(
              name: 'note-later',
              seq: 2,
              changeAt: '2026-07-17T00:00:01.000Z',
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

    test('buildDomainChangeNotificationPayload includes required fields', () {
      final payload = buildDomainChangeNotificationPayload(
        domainType: 'project',
        domainId: 'proj-1',
        change: _change(name: 'domain-update', seq: 1),
        subscriptionKey: WebsocketKeys.subscriptionSk(
          domainType: 'project',
          domainId: 'proj-1',
          entityType: 'task',
          notifyType: kNotifyTypeDomainChange,
        ),
        entityType: 'task',
      );

      expect(payload, {
        'action': 'change',
        'notifyType': kNotifyTypeDomainChange,
        'domainType': 'project',
        'domainId': 'proj-1',
        'entityType': 'task',
        'subscriptionKey': WebsocketKeys.subscriptionSk(
          domainType: 'project',
          domainId: 'proj-1',
          entityType: 'task',
          notifyType: kNotifyTypeDomainChange,
        ),
        'change': _change(name: 'domain-update', seq: 1),
      });
    });
  });

  group('wsNotifyHandler', () {
    test('groups records by domain and sorts by earliest group', () async {
      final connections = _FakeConnectionsRepository();
      final management = _FakeManagementClient(connections: connections);

      connections.subscriptionsByDomain['project|proj-1'] = [
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-wildcard-1',
          entityType: WebsocketKeys.wildcardEntityType,
          notifyType: kNotifyTypeDomainChange,
        ),
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-task-1',
          entityType: 'task',
          notifyType: kNotifyTypeDomainChange,
        ),
      ];
      connections.subscriptionsByDomain['project|proj-2'] = [
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-wildcard-2',
          entityType: WebsocketKeys.wildcardEntityType,
          notifyType: kNotifyTypeDomainChange,
        ),
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-note-1',
          entityType: 'note',
          notifyType: kNotifyTypeDomainChange,
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
                'change': _change(name: 'note-updated', seq: 2),
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
                'change': _change(name: 'task-updated', seq: 1),
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
        'notifyType': WebsocketConstants.notifyTypeDomainChange,
      });
      expect(connections.queries[1], {
        'domainType': 'project',
        'domainId': 'proj-1',
        'notifyType': WebsocketConstants.notifyTypeDomainChange,
      });

      expect(management.sentMessages, hasLength(4));
      expect(management.sentMessages[0]['connectionId'], 'conn-wildcard-2');
      expect(
        management.sentMessages[0]['payload']['subscriptionKey'],
        WebsocketKeys.subscriptionSk(
          domainType: 'project',
          domainId: 'proj-2',
          entityType: WebsocketKeys.wildcardEntityType,
          notifyType: kNotifyTypeDomainChange,
        ),
      );
      expect(management.sentMessages[1]['connectionId'], 'conn-note-1');
      expect(
        management.sentMessages[1]['payload']['subscriptionKey'],
        WebsocketKeys.subscriptionSk(
          domainType: 'project',
          domainId: 'proj-2',
          entityType: 'note',
          notifyType: kNotifyTypeDomainChange,
        ),
      );
      expect(management.sentMessages[2]['connectionId'], 'conn-wildcard-1');
      expect(
        management.sentMessages[2]['payload']['subscriptionKey'],
        WebsocketKeys.subscriptionSk(
          domainType: 'project',
          domainId: 'proj-1',
          entityType: WebsocketKeys.wildcardEntityType,
          notifyType: kNotifyTypeDomainChange,
        ),
      );
      expect(management.sentMessages[3]['connectionId'], 'conn-task-1');
      expect(
        management.sentMessages[3]['payload']['subscriptionKey'],
        WebsocketKeys.subscriptionSk(
          domainType: 'project',
          domainId: 'proj-1',
          entityType: 'task',
          notifyType: kNotifyTypeDomainChange,
        ),
      );
    });

    test(
      'handles entityType wildcard by delivering only to wildcard subscribers',
      () async {
        final connections = _FakeConnectionsRepository();
        final management = _FakeManagementClient(connections: connections);

        connections.subscriptionsByDomain['project|proj-1'] = [
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-wildcard',
            entityType: WebsocketKeys.wildcardEntityType,
            notifyType: kNotifyTypeDomainChange,
          ),
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-task',
            entityType: 'task',
            notifyType: kNotifyTypeDomainChange,
          ),
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-note',
            entityType: 'note',
            notifyType: kNotifyTypeDomainChange,
          ),
        ];

        final event = {
          'Records': [
            {
              'Sns': {
                'Message': jsonEncode(
                  buildWsNotifyRecordMessage(
                    domainType: 'project',
                    domainId: 'proj-1',
                    entityType: WebsocketKeys.wildcardEntityType,
                    change: _change(name: 'domain-update', seq: 1),
                  ),
                ),
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
            entityType: WebsocketKeys.wildcardEntityType,
            notifyType: kNotifyTypeDomainChange,
          ),
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-both',
            entityType: 'task',
            notifyType: kNotifyTypeDomainChange,
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
                  'change': _change(name: 'task-updated', seq: 1),
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
        expect(
          management.sentMessages[0]['payload']['subscriptionKey'],
          WebsocketKeys.subscriptionSk(
            domainType: 'project',
            domainId: 'proj-1',
            entityType: WebsocketKeys.wildcardEntityType,
            notifyType: kNotifyTypeDomainChange,
          ),
        );
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
            entityType: WebsocketKeys.wildcardEntityType,
            notifyType: kNotifyTypeDomainChange,
          ),
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-task',
            entityType: 'task',
            notifyType: kNotifyTypeDomainChange,
          ),
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-last-record',
            entityType: WebsocketKeys.lastRecordEntityType,
            notifyType: kNotifyTypeDomainChange,
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
                  'change': _change(name: 'task-update', seq: 1),
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
                  'change': _change(
                    name: 'note-update',
                    seq: 2,
                    changeAt: '2026-07-17T00:00:01.000Z',
                  ),
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
        expect(
          _changeName(lastRecordMessages[0]['payload']['change'] as Map),
          'note-update',
        );
        expect(
          lastRecordMessages[0]['payload']['subscriptionKey'],
          WebsocketKeys.subscriptionSk(
            domainType: 'project',
            domainId: 'proj-1',
            entityType: WebsocketKeys.lastRecordEntityType,
            notifyType: kNotifyTypeDomainChange,
          ),
        );
      },
    );

    test(
      'sends every domainChange record to wildcard and exact matches',
      () async {
        final connections = _FakeConnectionsRepository();
        final management = _FakeManagementClient(connections: connections);

        connections.subscriptionsByDomain['project|proj-1'] = [
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-wildcard',
            entityType: WebsocketKeys.wildcardEntityType,
            notifyType: kNotifyTypeDomainChange,
          ),
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-note',
            entityType: 'note',
            notifyType: kNotifyTypeDomainChange,
          ),
          const WebsocketSubscriptionMatch(
            connectionId: 'conn-task',
            entityType: 'task',
            notifyType: kNotifyTypeDomainChange,
          ),
        ];

        final event = {
          'Records': [
            {
              'Sns': {
                'Message': jsonEncode({
                  ...buildWsNotifyRecordMessage(
                    domainType: 'project',
                    domainId: 'proj-1',
                    change: _change(name: 'domain-old', seq: 1),
                    entityType: WebsocketKeys.lastRecordEntityType,
                  ),
                }),
              },
            },
            {
              'Sns': {
                'Message': jsonEncode({
                  ...buildWsNotifyRecordMessage(
                    domainType: 'project',
                    domainId: 'proj-1',
                    change: _change(name: 'note-old', seq: 1),
                    entityType: 'note',
                  ),
                }),
              },
            },
            {
              'Sns': {
                'Message': jsonEncode({
                  ...buildWsNotifyRecordMessage(
                    domainType: 'project',
                    domainId: 'proj-1',
                    change: _change(name: 'task-only', seq: 1),
                    entityType: 'task',
                  ),
                }),
              },
            },
            {
              'Sns': {
                'Message': jsonEncode({
                  ...buildWsNotifyRecordMessage(
                    domainType: 'project',
                    domainId: 'proj-1',
                    change: _change(
                      name: 'note-latest',
                      seq: 2,
                      changeAt: '2026-07-17T00:00:01.000Z',
                    ),
                    entityType: 'note',
                  ),
                }),
              },
            },
            {
              'Sns': {
                'Message': jsonEncode({
                  ...buildWsNotifyRecordMessage(
                    domainType: 'project',
                    domainId: 'proj-1',
                    change: _change(
                      name: 'domain-latest',
                      seq: 2,
                      changeAt: '2026-07-17T00:00:01.000Z',
                    ),
                    entityType: 'domain',
                  ),
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
        expect(wildcardMessages, hasLength(4));
        expect(
          wildcardMessages.map(
            (msg) => _payloadChangeName(msg['payload'] as Map),
          ),
          equals(['note-old', 'task-only', 'note-latest', 'domain-latest']),
        );

        final noteMessages = management.sentMessages
            .where((msg) => msg['connectionId'] == 'conn-note')
            .toList();
        expect(noteMessages, hasLength(2));
        expect(
          noteMessages.map((msg) => _payloadChangeName(msg['payload'] as Map)),
          equals(['note-old', 'note-latest']),
        );

        final taskMessages = management.sentMessages
            .where((msg) => msg['connectionId'] == 'conn-task')
            .toList();
        expect(taskMessages, hasLength(1));
        expect(
          taskMessages.map((msg) => _payloadChangeName(msg['payload'] as Map)),
          equals(['task-only']),
        );
      },
    );

    test('ignores unsupported notifyType values', () async {
      final connections = _FakeConnectionsRepository();
      final management = _FakeManagementClient(connections: connections);

      connections.subscriptionsByDomain['project|proj-1'] = [
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-wildcard',
          entityType: WebsocketKeys.wildcardEntityType,
          notifyType: kNotifyTypeDomainChange,
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
                'change': _change(name: 'task-updated', seq: 1),
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

    test('delivers domainStats messages only to stats subscribers', () async {
      final connections = _FakeConnectionsRepository();
      final management = _FakeManagementClient(connections: connections);

      connections.subscriptionsByDomain['project|proj-1'] = [
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-stats-1',
          entityType: WebsocketKeys.wildcardEntityType,
          notifyType: kNotifyTypeDomainStats,
        ),
        const WebsocketSubscriptionMatch(
          connectionId: 'conn-task-1',
          entityType: 'task',
          notifyType: kNotifyTypeDomainChange,
        ),
      ];

      final event = {
        'Records': [
          {
            'Sns': {
              'Message': jsonEncode(
                buildDomainStatsNotificationPayload(
                  domainType: 'project',
                  domainId: 'proj-1',
                  stats: {
                    'changeStats': {'total': 3},
                  },
                  subscriptionKey: '',
                ),
              ),
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
      expect(connections.queries[0], {
        'domainType': 'project',
        'domainId': 'proj-1',
        'notifyType': WebsocketConstants.notifyTypeDomainStats,
      });
      expect(management.sentMessages, hasLength(1));
      expect(management.sentMessages[0]['connectionId'], 'conn-stats-1');
      expect(management.sentMessages[0]['payload'], {
        'action': 'change',
        'notifyType': kNotifyTypeDomainStats,
        'domainType': 'project',
        'domainId': 'proj-1',
        'entityType': kNotifyTypeDomainStats,
        'stats': {
          'changeStats': {'total': 3},
        },
        'subscriptionKey': WebsocketKeys.subscriptionSk(
          domainType: 'project',
          domainId: 'proj-1',
          entityType: WebsocketKeys.wildcardEntityType,
          notifyType: kNotifyTypeDomainStats,
        ),
      });
    });
  });

  group('wsSubscribeHandler', () {
    test('rejects missing entityType', () async {
      final connections = _FakeConnectionsRepository();
      final management = _FakeManagementClient(connections: connections);

      final event = {
        'requestContext': {'connectionId': 'conn-sub-1'},
        'body': jsonEncode({'domainType': 'project', 'domainId': 'proj-1'}),
      };

      final response = await wsSubscribeHandler(
        event,
        connections: connections,
        management: management,
      );

      expect(response['statusCode'], 400);
      expect(management.sentMessages, hasLength(1));
      expect(management.sentMessages[0]['payload']['status'], 'error');
      expect(
        management.sentMessages[0]['payload']['error'] as String,
        contains('entityType'),
      );
      expect(connections.subscriptions, isEmpty);
    });

    test('rejects invalid entityType values', () async {
      final connections = _FakeConnectionsRepository();
      final management = _FakeManagementClient(connections: connections);

      final event = {
        'requestContext': {'connectionId': 'conn-sub-2'},
        'body': jsonEncode({
          'domainType': 'project',
          'domainId': 'proj-1',
          'entityType': 'Task-1',
        }),
      };

      final response = await wsSubscribeHandler(
        event,
        connections: connections,
        management: management,
      );

      expect(response['statusCode'], 400);
      expect(management.sentMessages, hasLength(1));
      expect(management.sentMessages[0]['payload']['status'], 'error');
      expect(
        management.sentMessages[0]['payload']['error'] as String,
        contains(r'match /^[a-z_]+$/'),
      );
      expect(connections.subscriptions, isEmpty);
    });

    test('accepts wildcard entityType', () async {
      final connections = _FakeConnectionsRepository();
      final management = _FakeManagementClient(connections: connections);

      final event = {
        'requestContext': {'connectionId': 'conn-sub-3'},
        'body': jsonEncode({
          'domainType': 'project',
          'domainId': 'proj-1',
          'entityType': WebsocketKeys.wildcardEntityType,
        }),
      };

      await wsSubscribeHandler(
        event,
        connections: connections,
        management: management,
      );

      expect(connections.subscriptions, hasLength(1));
      expect(
        connections.subscriptions[0]['entityType'],
        WebsocketKeys.wildcardEntityType,
      );
      expect(management.sentMessages[0]['payload'], {
        'action': 'subscribe',
        'status': 'ok',
        'domainType': 'project',
        'domainId': 'proj-1',
        'entityType': WebsocketKeys.wildcardEntityType,
        'subscriptionKey': WebsocketKeys.subscriptionSk(
          domainType: 'project',
          domainId: 'proj-1',
          entityType: WebsocketKeys.wildcardEntityType,
          notifyType: kNotifyTypeDomainChange,
        ),
      });
    });

    test('accepts last-record entityType', () async {
      final connections = _FakeConnectionsRepository();
      final management = _FakeManagementClient(connections: connections);

      final event = {
        'requestContext': {'connectionId': 'conn-sub-4'},
        'body': jsonEncode({
          'domainType': 'project',
          'domainId': 'proj-1',
          'entityType': WebsocketKeys.lastRecordEntityType,
        }),
      };

      await wsSubscribeHandler(
        event,
        connections: connections,
        management: management,
      );

      expect(connections.subscriptions, hasLength(1));
      expect(
        connections.subscriptions[0]['entityType'],
        WebsocketKeys.lastRecordEntityType,
      );
      expect(management.sentMessages[0]['payload'], {
        'action': 'subscribe',
        'status': 'ok',
        'domainType': 'project',
        'domainId': 'proj-1',
        'entityType': WebsocketKeys.lastRecordEntityType,
        'subscriptionKey': WebsocketKeys.subscriptionSk(
          domainType: 'project',
          domainId: 'proj-1',
          entityType: WebsocketKeys.lastRecordEntityType,
          notifyType: kNotifyTypeDomainChange,
        ),
      });
    });

    test('accepts standard entityType values', () async {
      final connections = _FakeConnectionsRepository();
      final management = _FakeManagementClient(connections: connections);

      final event = {
        'requestContext': {'connectionId': 'conn-sub-5'},
        'body': jsonEncode({
          'domainType': 'project',
          'domainId': 'proj-1',
          'entityType': 'task',
        }),
      };

      await wsSubscribeHandler(
        event,
        connections: connections,
        management: management,
      );

      expect(connections.subscriptions, hasLength(1));
      expect(connections.subscriptions[0]['entityType'], 'task');
      expect(management.sentMessages[0]['payload'], {
        'action': 'subscribe',
        'status': 'ok',
        'domainType': 'project',
        'domainId': 'proj-1',
        'entityType': 'task',
        'subscriptionKey': WebsocketKeys.subscriptionSk(
          domainType: 'project',
          domainId: 'proj-1',
          entityType: 'task',
          notifyType: kNotifyTypeDomainChange,
        ),
      });
    });

    test(
      'accepts domainStats entityType and stores wildcard subscription',
      () async {
        final connections = _FakeConnectionsRepository();
        final management = _FakeManagementClient(connections: connections);

        final event = {
          'requestContext': {'connectionId': 'conn-sub-6'},
          'body': jsonEncode({
            'domainType': 'project',
            'domainId': 'proj-1',
            'entityType': WebsocketConstants.notifyTypeDomainStats,
          }),
        };

        await wsSubscribeHandler(
          event,
          connections: connections,
          management: management,
        );

        expect(connections.subscriptions, hasLength(1));
        expect(
          connections.subscriptions[0]['entityType'],
          WebsocketKeys.wildcardEntityType,
        );
        expect(
          connections.subscriptions[0]['notifyType'],
          WebsocketConstants.notifyTypeDomainStats,
        );
        expect(management.sentMessages[0]['payload'], {
          'action': 'subscribe',
          'status': 'ok',
          'domainType': 'project',
          'domainId': 'proj-1',
          'entityType': WebsocketConstants.notifyTypeDomainStats,
          'subscriptionKey': WebsocketKeys.subscriptionSk(
            domainType: 'project',
            domainId: 'proj-1',
            entityType: WebsocketKeys.wildcardEntityType,
            notifyType: kNotifyTypeDomainStats,
          ),
        });
      },
    );
  });
}

Map<String, dynamic> _change({
  required String name,
  required int seq,
  String changeAt = '2026-07-17T00:00:00.000Z',
}) {
  return {
    'seq': seq,
    'cid': 'cid-$seq',
    'changeAt': changeAt,
    'dataJson': jsonEncode({'name': name}),
  };
}

String _changeName(Map change) {
  final json = change['dataJson']?.toString();
  if (json == null || json.isEmpty) {
    return '';
  }

  final decoded = jsonDecode(json);
  if (decoded is! Map) {
    return '';
  }

  return decoded['name']?.toString() ?? '';
}

String _payloadChangeName(Map payload) {
  final change = payload['change'];
  if (change is! Map) {
    return '';
  }

  return _changeName(change);
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
  final List<Map<String, dynamic>> subscriptions = [];

  @override
  Future<List<WebsocketSubscriptionMatch>> findSubscribersByDomain({
    required String domainType,
    required String domainId,
    String? notifyType,
  }) async {
    queries.add({
      'domainType': domainType,
      'domainId': domainId,
      'notifyType': notifyType,
    });
    final subscriptions = subscriptionsByDomain['$domainType|$domainId'] ?? [];
    if (notifyType == null) return subscriptions;
    return subscriptions
        .where((s) => s.notifyType == notifyType)
        .toList(growable: false);
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
    required String notifyType,
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
    required String notifyType,
  }) async {
    final storedEntityType =
        notifyType == WebsocketConstants.notifyTypeDomainStats
        ? WebsocketKeys.wildcardEntityType
        : entityType;

    subscriptions.add({
      'connectionId': connectionId,
      'domainType': domainType,
      'domainId': domainId,
      'entityType': storedEntityType,
      'notifyType': notifyType,
    });
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
