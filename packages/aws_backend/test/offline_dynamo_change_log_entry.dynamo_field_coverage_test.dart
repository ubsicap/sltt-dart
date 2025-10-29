import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  const knownDateTimeFields = {
    'changeAt',
    'cloudAt',
    'storedAt',
  };

  const knownDynamoChangeLogEntryFields = {
    'cid',
    'seq',
    'storageId',
    'domainType',
    'domainId',
    'entityType',
    'operation',
    'operationInfoJson',
    'stateChanged',
    'changeAt',
    'entityId',
    'dataJson',
    'dataSchemaRev',
    'cloudAt',
    'storedAt',
    'changeBy',
    'schemaVersion',
    'unknownJson',
  };

  /// Helper to verify all DateTime fields are UTC
  void expectAllDateTimeFieldsUtc(
    DynamoChangeLogEntry entry, {
    required DateTime expectedChangeAt,
    required DateTime? expectedCloudAt,
    required DateTime? expectedStoredAt,
    String context = '',
  }) {
    final prefix = context.isEmpty ? '' : '$context: ';

    // Test all DateTime fields are UTC
    expect(
      entry.changeAt,
      equals(expectedChangeAt.toUtc()),
      reason: '${prefix}changeAt should be UTC',
    );

    if (expectedCloudAt != null) {
      expect(
        entry.cloudAt,
        equals(expectedCloudAt.toUtc()),
        reason: '${prefix}cloudAt should be UTC',
      );
    }

    if (expectedStoredAt != null) {
      expect(
        entry.storedAt,
        equals(expectedStoredAt.toUtc()),
        reason: '${prefix}storedAt should be UTC',
      );
    }
  }

  group('offline - DynamoChangeLogEntry field coverage', () {
    test('verifies all expected fields with UTC DateTime conversion', () {
      // Create individual local (non-UTC) DateTimes for testing - each field gets unique value
      final localChangeAt = DateTime.now(); // Local time
      final localCloudAt = DateTime.now().subtract(const Duration(hours: 1));
      final localStoredAt = DateTime.now().subtract(
        const Duration(minutes: 30),
      );

      expect(
        localChangeAt.isUtc,
        isFalse,
        reason: 'Test DateTime should be local',
      );
      expect(
        localCloudAt.isUtc,
        isFalse,
        reason: 'Test DateTime should be local',
      );
      expect(
        localStoredAt.isUtc,
        isFalse,
        reason: 'Test DateTime should be local',
      );

      final cid = generateCid(
        entityType: EntityType.portion,
        userId: 'test-user-1',
      );

      // Create DynamoChangeLogEntry with all optional fields filled
      final entry = DynamoChangeLogEntry(
        cid: cid,
        seq: 12345,
        storageId: 'test-storage-1',
        domainType: 'project',
        domainId: 'test-domain-1',
        entityType: kEntityTypePortion,
        operation: 'update',
        operationInfoJson: '{"field":"data_name"}',
        stateChanged: true,
        changeAt: localChangeAt,
        entityId: 'test-entity-1',
        dataJson: '{"name":"Test Portion","rank":"100"}',
        dataSchemaRev: 5,
        cloudAt: localCloudAt,
        storedAt: localStoredAt,
        changeBy: 'test-user-1',
        schemaVersion: 1,
        unknownJson: '{}',
      );

      // Test that instance DateTime fields are UTC
      expectAllDateTimeFieldsUtc(
        entry,
        expectedChangeAt: localChangeAt,
        expectedCloudAt: localCloudAt,
        expectedStoredAt: localStoredAt,
        context: 'DynamoChangeLogEntry instance',
      );

      final processedDateTimeFields = <String>{};
      final processedAllFields = <String>{};

      // Use toJsonBase() to check for any missing fields
      final jsonBase = entry.toJsonBase();
      for (final kv in jsonBase.entries) {
        expect(
          kv.key,
          isIn(knownDynamoChangeLogEntryFields),
          reason:
              'Field ${kv.key} is not a known DynamoChangeLogEntry field. Update the expected value checks and knownDynamoChangeLogEntryFields accordingly.',
        );
        processedAllFields.add(kv.key);

        // Skip null values for optional fields
        if (kv.value == null) continue;

        if (kv.value is! String) continue;

        // Parse to see if it's a datetime field, if so make sure it's a known datetime field
        final maybeDateTime = DateTime.tryParse(kv.value);
        if (maybeDateTime != null) {
          processedDateTimeFields.add(kv.key);
          expect(kv.key, isIn(knownDateTimeFields));
          expect(
            maybeDateTime.isUtc,
            isTrue,
            reason:
                'Field ${kv.key} should be UTC DateTime string, got ${kv.value}',
          );
        }
      }

      // make sure all known datetime fields were processed
      expect(
        processedDateTimeFields,
        equals(knownDateTimeFields),
        reason: 'Not all known DateTime fields were processed.',
      );

      // make sure all known fields were processed
      expect(
        processedAllFields,
        equals(knownDynamoChangeLogEntryFields),
        reason:
            'Not all known DynamoChangeLogEntry fields were processed.',
      );
    });

    test('handles null optional DateTime fields', () {
      final localChangeAt = DateTime.now();

      final cid = generateCid(
        entityType: EntityType.portion,
        userId: 'test-user-2',
      );

      // Create DynamoChangeLogEntry with minimal fields (null optional DateTimes)
      final entry = DynamoChangeLogEntry(
        cid: cid,
        seq: 1,
        storageId: 'test-storage-2',
        domainType: 'project',
        domainId: 'test-domain-2',
        entityType: kEntityTypePortion,
        operation: 'create',
        stateChanged: true,
        changeAt: localChangeAt,
        entityId: 'test-entity-2',
        dataJson: '{"name":"New Portion"}',
        changeBy: 'test-user-2',
      );

      // Test that changeAt is UTC
      expect(
        entry.changeAt,
        equals(localChangeAt.toUtc()),
        reason: 'changeAt should be UTC',
      );

      // Test that optional DateTime fields are null
      expect(entry.cloudAt, isNull, reason: 'cloudAt should be null');
      expect(entry.storedAt, isNull, reason: 'storedAt should be null');

      // Verify JSON doesn't include null DateTime strings
      final json = entry.toJsonBase();
      expect(json['changeAt'], isA<String>());

      // cloudAt and storedAt may be null or absent
      if (json.containsKey('cloudAt')) {
        expect(json['cloudAt'], isNull);
      }
      if (json.containsKey('storedAt')) {
        expect(json['storedAt'], isNull);
      }
    });
  });
}
