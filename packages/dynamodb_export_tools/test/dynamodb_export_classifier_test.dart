import 'package:dynamodb_export_tools/dynamodb_export_tools.dart';
import 'package:test/test.dart';

void main() {
  const classifier = DynamoExportClassifier();

  group('DynamoExportClassifier', () {
    test('routes change log items to change_log_entries table', () {
      final result = classifier.classifyCompositeKeys(
        pk: r'$sltt#change#domainType_project#domainId_abc123#entityType_portion#entityId_entity1',
        sk: r'$changes#change#cid_1234567890',
      );

      expect(result.family, DynamoExportItemFamily.changeLog);
      expect(
        result.logicalTableName,
        DynamoExportClassifier.changeLogTableName,
      );
      expect(result.usesRawFallback, isFalse);
      expect(result.domainType, 'project');
      expect(result.domainId, 'abc123');
      expect(result.entityType, 'portion');
      expect(result.entityId, 'entity1');
    });

    test('routes entity state items dynamically by entityType', () {
      final result = classifier.classifyCompositeKeys(
        pk: r'$sltt#state#domainType_project#domainId_abc123#entityType_note',
        sk: r'$states#state#entityId_entity1',
        gsi2pk:
            r'$sltt#state#domainType_project#domainId_abc123#entityType_note#parentId_parent1',
        gsi2sk: 'parentProp_tasks#changeAt_orig__2023-01-01T00:00:00Z',
      );

      expect(result.family, DynamoExportItemFamily.entityState);
      expect(result.logicalTableName, 'entity_state__note');
      expect(result.usesRawFallback, isFalse);
      expect(result.parentId, 'parent1');
      expect(result.parentProp, 'tasks');
      expect(result.changeAtOrig, '2023-01-01T00:00:00Z');
    });

    test('routes entity state items dynamically by entityType - old rank sk', () {
      final result = classifier.classifyCompositeKeys(
        pk: r'$sltt#state#domainType_project#domainId_abc123#entityType_note',
        sk: r'$states#state#entityId_entity1',
        gsi2pk:
            r'$sltt#state#domainType_project#domainId_abc123#entityType_note#parentId_parent1',
        gsi2sk: 'parentProp_tasks#rank_001',
      );

      expect(result.family, DynamoExportItemFamily.entityState);
      expect(result.logicalTableName, 'entity_state__note');
      expect(result.usesRawFallback, isFalse);
      expect(result.parentId, 'parent1');
      expect(result.parentProp, 'tasks');
      expect(result.rank, '001');
    });

    test('new entity_state entityTypes do not require explicit allowlists', () {
      final result = classifier.classifyCompositeKeys(
        pk: r'$sltt#state#domainType_project#domainId_abc123#entityType_glossary_entry',
        sk: r'$states#state#entityId_entity1',
      );

      expect(result.family, DynamoExportItemFamily.entityState);
      expect(result.logicalTableName, 'entity_state__glossary_entry');
      expect(result.isSupported, isTrue);
      expect(result.usesRawFallback, isFalse);
    });

    test('classifier coverage canary covers current documented key families', () {
      final samples = [
        classifier.classifyCompositeKeys(
          pk: r'$sltt#change#domainType_project#domainId_abc123#entityType_portion#entityId_entity1',
          sk: r'$changes#change#cid_1234567890',
        ),
        classifier.classifyCompositeKeys(
          pk: r'$sltt#state#domainType_project#domainId_abc123#entityType_portion',
          sk: r'$states#state#entityId_entity1',
        ),
        classifier.classifyCompositeKeys(
          pk: r'$sltt#etsc#domainType_project#domainId_abc123',
          sk: r'$etsc#etsc#entityType_portion',
        ),
        classifier.classifyCompositeKeys(
          pk: r'$sltt#etss#domainType_project#domainId_abc123',
          sk: r'$etss#etss#entityType_portion',
        ),
        classifier.classifyCompositeKeys(
          pk: r'$sltt#seq#domainType_project#domainId_abc123',
          sk: r'$seq#counter',
        ),
        classifier.classifyCompositeKeys(
          pk: r'$sltt#storage#singleton',
          sk: r'$storage#state',
        ),
      ];

      expect(samples.map((sample) => sample.family).toSet(), {
        DynamoExportItemFamily.changeLog,
        DynamoExportItemFamily.entityState,
        DynamoExportItemFamily.entityTypeSyncStateChangeLog,
        DynamoExportItemFamily.entityTypeSyncStateEntityState,
        DynamoExportItemFamily.sequenceCounter,
        DynamoExportItemFamily.storageState,
      });
      for (final sample in samples) {
        expect(sample.logicalTableName, isNotEmpty);
      }
    });

    test(
      'unknown-pattern canary falls back loudly instead of silently routing',
      () {
        final result = classifier.classifyCompositeKeys(
          pk: r'$sltt#mystery#domainType_project#domainId_abc123',
          sk: r'$mystery#thing',
        );

        expect(result.family, DynamoExportItemFamily.unknown);
        expect(
          result.logicalTableName,
          DynamoExportClassifier.rawItemsTableName,
        );
        expect(result.usesRawFallback, isTrue);
        expect(result.isSupported, isFalse);
        expect(
          result.unsupportedReason,
          contains('Unsupported composite key pattern'),
        );
      },
    );

    test('missing entityType in entity_state keys triggers fallback', () {
      final result = classifier.classifyCompositeKeys(
        pk: r'$sltt#state#domainType_project#domainId_abc123',
        sk: r'$states#state#entityId_entity1',
      );

      expect(result.family, DynamoExportItemFamily.entityState);
      expect(result.usesRawFallback, isTrue);
      expect(result.isSupported, isFalse);
      expect(result.unsupportedReason, contains('missing entityType'));
    });
  });
}
