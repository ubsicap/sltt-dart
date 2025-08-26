import 'dart:convert';

import 'package:sync_manager/src/models/isar_change_log_entry.dart';
import 'package:test/test.dart';

void main() {
  test('IsarChangeLogEntry serialization round-trip preserves fields', () {
    final entry = IsarChangeLogEntry(
      domainId: 'd1',
      entityType: 'project',
      operation: 'update',
      changeAt: DateTime.parse('2020-01-01T00:00:00Z'),
      entityId: 'e1',
      dataJson: jsonEncode({'a': 1}),
      cloudAt: DateTime.parse('2020-01-01T00:00:00Z'),
      changeBy: 'u1',
      cid: 'cid1',
      storageId: 'local',
      domainType: 'project',
      stateChanged: true,
      operationInfoJson: jsonEncode({'prev': 'x'}),
      unknownJson: jsonEncode({'hidden': 'secret'}),
    );

    final asJson = entry.toJson();
    expect(asJson['entityId'], equals('e1'));
    expect(asJson['cid'], equals('cid1'));
    expect(asJson['dataJson'], isA<String>());
    expect(asJson['operationInfoJson'], isA<String>());
    expect(asJson['unknownJson'], isA<String>());

    final recovered = IsarChangeLogEntry.fromJson(asJson);
    expect(recovered.entityId, equals('e1'));
    expect(recovered.cid, equals('cid1'));
    expect(recovered.getData(), equals({'a': 1}));
    expect(recovered.getOperationInfo(), equals({'prev': 'x'}));
    expect(jsonDecode(recovered.unknownJson), equals({'hidden': 'secret'}));
  });

  test(
    'IsarChangeLogEntry.fromJson preserves unknown fields into unknownJson',
    () {
      final rawJson = {
        'entityId': 'e2',
        'storageId': 'local',
        'entityType': 'brandNewType',
        'domainId': 'd1',
        'domainType': 'project',
        'seq': 0,
        'changeAt': DateTime.now().toIso8601String(),
        'cid': 'cid2',
        'changeBy': 'u2',
        'dataJson': '{}',
        'operation': 'create',
        'operationInfoJson': '{}',
        'stateChanged': true,
        // an unexpected field that should be captured in unknownJson
        'extraField': 'surprise',
      };

      final recovered = IsarChangeLogEntry.fromJson(rawJson);

      // unknownJson should include the extraField
      final unknown = jsonDecode(recovered.unknownJson) as Map<String, dynamic>;
      expect(unknown['extraField'], equals('surprise'));
    },
  );
}
