import 'dart:convert';

import 'package:test/test.dart';

import '../bin/websocket/websocket_connections_repository.dart';
import '../bin/websocket/websocket_management_client.dart';
import '../bin/websocket/ws_notify_handler.dart';

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

void main() {
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
                'domainType': 'project',
                'domainId': 'proj-2',
                'entityType': 'note',
                'data': {'name': 'note-updated'},
              }),
            },
          },
          {
            'Sns': {
              'Message': jsonEncode({
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
      'handles entityType null by delivering to wildcard and all exact subscribers',
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
                  'domainType': 'project',
                  'domainId': 'proj-1',
                  'data': {'name': 'domain-update'},
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
          containsAll(['conn-wildcard', 'conn-task', 'conn-note']),
        );
        expect(management.sentMessages.length, 3);
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

        expect(management.sentMessages, hasLength(1));
        expect(management.sentMessages[0]['connectionId'], 'conn-both');
      },
    );
  });
}
