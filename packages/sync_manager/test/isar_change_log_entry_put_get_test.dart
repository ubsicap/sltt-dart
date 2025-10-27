import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/isar_change_log_entry.dart';
import 'package:test/test.dart';

const knownDateTimeFields = {'changeAt', 'storedAt', 'cloudAt'};
const knownChangeLogEntryFields = {
  'seq',
  'changeAt',
  'storedAt',
  'cloudAt',
  'changeBy',
  'cid',
  'dataJson',
  'domainId',
  'domainType',
  'entityId',
  'entityType',
  'operation',
  'operationInfoJson',
  'schemaVersion',
  'stateChanged',
  'storageId',
  'unknownJson',
  'dataSchemaRev',
};

void main() {
  late Isar isar;
  const testDbName = 'isar_change_log_entry_put_get_test';
  const testDbPath = './isar_db';

  setUp(() async {
    // Delete database if it exists
    final dir = Directory(testDbPath);
    if (dir.existsSync()) {
      final dbFile = File('$testDbPath/$testDbName.isar');
      if (dbFile.existsSync()) {
        dbFile.deleteSync();
      }
      final lockFile = File('$testDbPath/$testDbName.isar.lock');
      if (lockFile.existsSync()) {
        lockFile.deleteSync();
      }
    }

    // Create Isar instance with IsarChangeLogEntry schema
    isar = await Isar.open(
      [IsarChangeLogEntrySchema],
      directory: testDbPath,
      name: testDbName,
    );
  });

  group('IsarChangeLogEntry DateTime UTC Conversion', () {
    test('stores and retrieves with all DateTime fields converted to UTC', () async {
      // Create local (non-UTC) DateTimes for testing
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

      // Create IsarChangeLogEntry with all optional fields filled
      final entry = IsarChangeLogEntry(
        cid: generateCid(entityType: EntityType.project),
        domainId: 'test-domain-1',
        domainType: 'project',
        entityType: 'project',
        entityId: 'test-entity-1',
        operation: 'create',
        changeAt: localChangeAt,
        changeBy: 'test-user',
        storageId: 'local-storage',
        dataJson:
            '{"nameLocal": "Test Project", "parentId": "root", "parentProp": "pList"}',
        stateChanged: true,
        // Optional fields
        cloudAt: localCloudAt,
        storedAt: localStoredAt,
        operationInfoJson: '{"source": "test"}',
        unknownJson: '{}',
        dataSchemaRev: 1,
        schemaVersion: 2,
      );

      // Test that instance DateTime fields are UTC before storing
      expect(
        entry.changeAt,
        equals(localChangeAt.toUtc()),
        reason: 'changeAt should be UTC',
      );
      expect(
        entry.cloudAt,
        equals(localCloudAt.toUtc()),
        reason: 'cloudAt should be UTC',
      );
      expect(
        entry.storedAt,
        equals(localStoredAt.toUtc()),
        reason: 'storedAt should be UTC',
      );

      // Store to database
      await isar.writeTxn(() async {
        await isar.isarChangeLogEntrys.put(entry);
      });

      // Retrieve from database
      final retrieved = await isar.isarChangeLogEntrys
          .filter()
          .cidEqualTo(entry.cid)
          .findFirst();

      expect(
        retrieved,
        isNotNull,
        reason: 'Entry should be retrieved from database',
      );

      // Test all retrieved DateTime fields are UTC
      expect(
        retrieved!.changeAt,
        equals(localChangeAt.toUtc()),
        reason: 'Retrieved changeAt should be UTC',
      );
      expect(
        retrieved.cloudAt,
        equals(localCloudAt.toUtc()),
        reason: 'Retrieved cloudAt should be UTC',
      );
      expect(
        retrieved.storedAt,
        equals(localStoredAt.toUtc()),
        reason: 'Retrieved storedAt should be UTC',
      );

      // Test that re-serialized toJson() has all UTC DateTime strings
      final jsonAfterRetrieve = retrieved.toJson();

      // expected value checks
      expect(retrieved.cid, equals(entry.cid));
      expect(retrieved.domainId, equals(entry.domainId));
      expect(retrieved.domainType, equals(entry.domainType));
      expect(retrieved.entityType, equals(entry.entityType));
      expect(retrieved.entityId, equals(entry.entityId));
      expect(retrieved.operation, equals(entry.operation));
      expect(retrieved.changeBy, equals(entry.changeBy));
      expect(retrieved.storageId, equals(entry.storageId));
      expect(retrieved.dataJson, equals(entry.dataJson));
      expect(retrieved.stateChanged, equals(entry.stateChanged));
      expect(retrieved.operationInfoJson, equals(entry.operationInfoJson));
      expect(retrieved.unknownJson, equals(entry.unknownJson));
      expect(retrieved.dataSchemaRev, equals(entry.dataSchemaRev));
      expect(retrieved.schemaVersion, equals(entry.schemaVersion));

      final processedDateTimeFields = <String>{};
      final processedAllFields = <String>{};

      // Use toJsonBase() to check for any missing fields
      final jsonBase = entry.toJsonBase();
      for (final entry in jsonBase.entries) {
        expect(
          entry.value,
          isNotNull,
          reason:
              'Field ${entry.key} should not be null. If it is a DateTime, please test that has been converted to utc below',
        );
        expect(
          entry.key,
          isIn(knownChangeLogEntryFields),
          reason:
              'Field ${entry.key} is not a known ChangeLogEntry field. Update the expected value checks and knownChangeLogEntryFields accordingly.',
        );
        expect(
          entry.value,
          equals(jsonAfterRetrieve[entry.key]),
          reason:
              'Field ${entry.key} does not match after retrieval from database.',
        );
        processedAllFields.add(entry.key);
        if (entry.value is! String) continue;
        // parse to see if it's a datetime field, if so make sure it's a known datetime field
        final maybeDateTime = DateTime.tryParse(entry.value);
        if (maybeDateTime != null) {
          processedDateTimeFields.add(entry.key);
          expect(entry.key, isIn(knownDateTimeFields));
          expect(
            maybeDateTime.isUtc,
            isTrue,
            reason:
                'Field ${entry.key} should be UTC DateTime string, got ${entry.value}',
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
        equals(knownChangeLogEntryFields),
        reason: 'Not all known ChangeLogEntry fields were processed.',
      );
    });
  });
}
