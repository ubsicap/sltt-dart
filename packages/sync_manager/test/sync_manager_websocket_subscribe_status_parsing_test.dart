import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  group('SyncManager websocket subscribe status parsing', () {
    test('parses lastDomainSeq from lastDomainSeq field', () {
      final payload = {'lastDomainSeq': 5};

      final seq = parseRemoteLastDomainSeqFromStatusPayload(payload);

      expect(seq, equals(5));
    });

    test('parses lastDomainSeq from latestSeq fallback', () {
      final payload = {'latestSeq': 8};

      final seq = parseRemoteLastDomainSeqFromStatusPayload(payload);

      expect(seq, equals(8));
    });

    test('parses lastDomainSeq from changeStats.totals.latestSeq fallback', () {
      final payload = {
        'changeStats': {
          'totals': {'latestSeq': 12},
        },
      };

      final seq = parseRemoteLastDomainSeqFromStatusPayload(payload);

      expect(seq, equals(12));
    });

    test('parses lastDomainChangeAt from lastDomainChangeAt', () {
      final payload = {'lastDomainChangeAt': '2026-07-25T18:10:01.636321Z'};

      final parsed = parseRemoteLastDomainChangeAtFromStatusPayload(payload);

      expect(parsed, isNotNull);
      expect(
        parsed!.toUtc().toIso8601String(),
        equals('2026-07-25T18:10:01.636321Z'),
      );
    });

    test('parses lastDomainChangeAt from timestamp fallback', () {
      final payload = {'timestamp': '2026-07-25T18:10:01.636321Z'};

      final parsed = parseRemoteLastDomainChangeAtFromStatusPayload(payload);

      expect(parsed, isNotNull);
      expect(
        parsed!.toUtc().toIso8601String(),
        equals('2026-07-25T18:10:01.636321Z'),
      );
    });
  });
}
