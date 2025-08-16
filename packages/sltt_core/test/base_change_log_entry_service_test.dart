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
}
