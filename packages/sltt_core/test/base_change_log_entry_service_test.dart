import 'package:sltt_core/src/services/base_change_log_entry_service.dart';
import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  test('deserializeChangeLogEntrySafely handles unknown entityType', () {
    final rawJson = {
      'entityId': 'e1',
      'storageId': 'local',
      'entityType': 'brandNewType', // unknown to this client
      'domainId': 'd1',
      'domainType': 'project',
      'changeAt': DateTime.now().toIso8601String(),
      'cid': 'cid1',
      'changeBy': 'u1',
      'data': <String, dynamic>{},
      'operation': 'update',
      'operationInfo': <String, dynamic>{},
      'stateChanged': true,
      'unknown': <String, dynamic>{},
    };

    final result = deserializeChangeLogEntrySafely<TestChangeLogEntry>(
      fromJson: (m) => TestChangeLogEntry.fromJson(m),
      json: rawJson,
      baseToJson: (v) => v.toJson(),
      toSafeJson: (orig) => {
        // default safe shape the concrete model can parse
        ...orig,
        'entityType': 'unknown',
        'operation': 'hold',
        'operationInfo': {
          ...(orig['operationInfo'] as Map<String, dynamic>? ?? {}),
          'hold': 'entityType',
          'entityType': orig['entityType'],
        },
        'data': (orig['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
        'unknown':
            (orig['unknown'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      },
    );

    // After deserialization, operation should be 'hold'
    expect(result.operation, equals('hold'));
    // entityType should be EntityType.unknown
    expect(result.entityType.toString().contains('unknown'), isTrue);
    // operationInfo should contain the raw entityType value
    expect(result.getOperationInfo()['hold'], equals('entityType'));
    expect(result.getOperationInfo()['entityType'], equals('brandNewType'));
  });

  test('deserializeChangeLogEntrySafely recovers from factory error', () {
    final rawJson = {
      'storageId': 'local',
      'entityId': 'e1',
      'entityType': 'task',
      'domainId': 'd1',
      'domainType': 'project',
      'changeAt': DateTime.now().toIso8601String(),
      'cid': 'cid-err',
      'changeBy': 'u1',
      'data': <String, dynamic>{},
      'operation': 'update',
      'operationInfo': <String, dynamic>{},
      'stateChanged': true,
      'unknown': <String, dynamic>{},
    };

    // Create a fromJson that throws only for the original incoming JSON
    // (operation == 'update') to simulate a broken/deserialization error.
    // The factory should succeed when given the recovered/safe JSON so the
    // second deserialization attempt doesn't throw.
    T throwingFactory<T>(Map<String, dynamic> m) {
      if ((m['operation'] as String?) != 'error') {
        throw StateError('boom');
      }
      // Delegate to the real TestChangeLogEntry.fromJson for the recovered JSON
      return TestChangeLogEntry.fromJson(m) as T;
    }

    final result = deserializeChangeLogEntrySafely<TestChangeLogEntry>(
      fromJson: (m) => throwingFactory<TestChangeLogEntry>(m),
      json: rawJson,
      baseToJson: (v) => v.toJson(),
      toSafeJson: (orig) => {
        ...orig,
        'entityType': 'unknown',
        'operation': 'error',
        'operationInfo': {
          ...(orig['operationInfo'] as Map<String, dynamic>? ?? {}),
        },
        'data': (orig['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
        'unknown':
            (orig['unknown'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      },
    );

    expect(result.operation, equals('error'));
    expect(result.getOperationInfo(), isA<Map<String, dynamic>>());
    expect(result.getOperationInfo()['error'], isA<String>());
    expect(result.getOperationInfo()['errorStack'], isA<String>());
    expect(result.getOperationInfo()['json'], isA<Map<String, dynamic>>());
  });
}
