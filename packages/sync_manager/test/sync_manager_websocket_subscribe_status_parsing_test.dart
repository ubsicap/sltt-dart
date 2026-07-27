import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  group('SyncManager websocket subscribe status parsing', () {
    test('domain stats ack payload can be parsed by DomainStatsResponse', () {
      final payload = {
        'domainId': 'user/2026-0721-171722-672-05qv-nEg9-user',
        'domainType': 'user',
        'changeStats': {
          'creates': 1,
          'updates': 0,
          'deletes': 0,
          'total': 1,
          'latestChangeAt': '2026-07-25T18:10:01.636321Z',
          'latestSeq': 1,
        },
        'entityTypeStats': {
          'entityTypes': {
            'user_profile': {
              'creates': 1,
              'updates': 0,
              'deletes': 0,
              'total': 1,
              'latestChangeAt': '2026-07-25T18:10:01.636321Z',
              'latestSeq': 1,
            },
          },
          'totals': {
            'creates': 1,
            'updates': 0,
            'deletes': 0,
            'total': 1,
            'latestChangeAt': '2026-07-25T18:10:01.636321Z',
            'latestSeq': 1,
          },
        },
        'timestamp': '2026-07-25T18:10:01.636321Z',
        'storageType': 'cloud',
      };

      final parsed = DomainStatsResponse.fromJson(payload);
      expect(parsed.domainId, equals(payload['domainId']));
      expect(parsed.domainType, equals(payload['domainType']));
      expect(parsed.changeStats?.latestSeq, equals(1));
      expect(parsed.entityTypeStats?.totals.latestSeq, equals(1));
      expect(parsed.timestamp, equals(payload['timestamp']));
      expect(parsed.storageType, equals(payload['storageType']));
    });

    test('domain stats ack payload can be parsed by DomainStatsResponse', () {
      final payload = {
        'domainId': 'user/2026-0721-171722-672-05qv-nEg9-user',
        'domainType': 'user',
        'changeStats': {
          'creates': 1,
          'updates': 0,
          'deletes': 0,
          'total': 1,
          'latestChangeAt': '2026-07-25T18:10:01.636321Z',
          'latestSeq': 1,
        },
        'entityTypeStats': {
          'entityTypes': {
            'user_profile': {
              'creates': 1,
              'updates': 0,
              'deletes': 0,
              'total': 1,
              'latestChangeAt': '2026-07-25T18:10:01.636321Z',
              'latestSeq': 1,
            },
          },
          'totals': {
            'creates': 1,
            'updates': 0,
            'deletes': 0,
            'total': 1,
            'latestChangeAt': '2026-07-25T18:10:01.636321Z',
            'latestSeq': 1,
          },
        },
        'timestamp': '2026-07-25T18:10:01.636321Z',
        'storageType': 'cloud',
      };

      final parsed = DomainStatsResponse.fromJson(payload);
      expect(parsed.domainId, equals(payload['domainId']));
      expect(parsed.domainType, equals(payload['domainType']));
      expect(parsed.changeStats?.latestSeq, equals(1));
      expect(parsed.entityTypeStats?.totals.latestSeq, equals(1));
      expect(parsed.timestamp, equals(payload['timestamp']));
      expect(parsed.storageType, equals(payload['storageType']));
    });

    // No legacy parse helper tests remain; websocket ack parsing is now
    // validated through strict DomainStatsResponse deserialization.
  });
}
