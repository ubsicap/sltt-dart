import 'package:sltt_core/src/models/base_change_log_entry_service.dart';
import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  test('deserializeChangeLogEntrySafely handles unknown entityType', () {
    final rawJson = {
      'entityId': 'e1',
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
      (m) => TestChangeLogEntry.fromJson(m),
      rawJson,
      (v) => v.toJson(),
    );

    // After deserialization, operation should be unknownEntityType
    expect(result.operation, equals('unknownEntityType'));
    // entityType should be EntityType.unknown
    expect(result.entityType.toString().contains('unknown'), isTrue);
    // operationInfo should contain the raw entityType value
    expect(result.operationInfo['entityType'], equals('brandNewType'));
  });

  test('deserializeChangeLogEntrySafely recovers from factory error', () {
    final rawJson = {
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
      (m) => throwingFactory<TestChangeLogEntry>(m),
      rawJson,
      (v) => v.toJson(),
    );

    expect(result.operation, equals('error'));
    expect(result.operationInfo, isA<Map<String, dynamic>>());
    expect(result.operationInfo['error'], isA<String>());
    expect(result.operationInfo['errorStack'], isA<String>());
    expect(result.operationInfo['json'], isA<Map<String, dynamic>>());
  });
}
