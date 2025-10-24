import 'dart:convert';

import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  group('TestEntityState _orig_ field behavior', () {
    test('preserves unknown fields with valid _orig_ values', () {
      final changeAtJson = DateTime.now().toIso8601String();
      final storedAtJson = DateTime.now().toIso8601String();

      final rawJson = {
        'entityId': 'test-1',
        'entityType': 'task',
        'domainType': 'project',
        'change_storedAt': storedAtJson,
        'change_domainId': 'd1',
        'change_changeAt': changeAtJson,
        'change_cid': 'cid-t1',
        'change_changeBy': 'u1',
        'data_nameLocal': 'Test Task',
        'data_nameLocal_dataSchemaRev_': 1,
        'data_nameLocal_changeAt_': changeAtJson,
        'data_nameLocal_cid_': 'cid-name',
        'data_nameLocal_changeBy_': 'u1',
        'data_parentId': 'parent',
        'data_parentId_dataSchemaRev_': 0,
        'data_parentId_changeAt_': changeAtJson,
        'data_parentId_cid_': 'cid-parent',
        'data_parentId_changeBy_': 'u1',
        'data_parentProp': 'pList',
        'data_parentProp_dataSchemaRev_': 0,
        'data_parentProp_changeAt_': changeAtJson,
        'data_parentProp_cid_': 'cid-parent',
        'data_parentProp_changeBy_': 'u1',
        // required orig_ fields set with same values
        'change_domainId_orig_': 'd1',
        'change_changeAt_orig_': changeAtJson,
        'change_cid_orig_': 'cid-t1',
        'change_changeBy_orig_': 'u1',
        // add an unexpected field
        'surprise': 'gotcha',
        'change_storedAt_orig_': storedAtJson,
      };

      final entity = TestEntityState.fromJson(rawJson);
      final unknown = jsonDecode(entity.unknownJson) as Map<String, dynamic>;
      expect(unknown['surprise'], equals('gotcha'));
      expect(entity.entityId, equals('test-1'));
    });

    test(
      'initializes _orig_ fields from current values when using empty/default values',
      () {
        final changeAtJson = DateTime.parse(
          '2024-01-01T10:00:00',
        ).toIso8601String();
        final changeAt = DateTime.parse(changeAtJson);
        final storedAtJson = DateTime.now().toIso8601String();

        final rawJson = {
          'entityId': 'test-new',
          'entityType': 'task',
          'domainType': 'project',
          'change_storedAt': storedAtJson,
          'change_domainId': 'd2',
          'change_changeAt': changeAtJson,
          'change_cid': 'cid-new',
          'change_changeBy': 'creator',
          'data_nameLocal': 'New Test Task',
          'data_nameLocal_dataSchemaRev_': 1,
          'data_nameLocal_changeAt_': changeAtJson,
          'data_nameLocal_cid_': 'cid-name-new',
          'data_nameLocal_changeBy_': 'creator',
          'data_parentId': 'parent',
          'data_parentId_dataSchemaRev_': 0,
          'data_parentId_changeAt_': changeAtJson,
          'data_parentId_cid_': 'cid-parent',
          'data_parentId_changeBy_': 'creator',
          'data_parentProp': 'pList',
          'data_parentProp_dataSchemaRev_': 0,
          'data_parentProp_changeAt_': changeAtJson,
          'data_parentProp_cid_': 'cid-parentprop-new',
          'data_parentProp_changeBy_': 'creator',
          // Note: using empty/default values to test that _orig_ fields get proper values
          'change_domainId_orig_': '',
          'change_changeAt_orig_': BaseEntityState.defaultOrigDateTime()
              .toIso8601String(),
          'change_cid_orig_': '',
          'change_changeBy_orig_': '',
          'change_storedAt_orig_': BaseEntityState.defaultOrigDateTime()
              .toIso8601String(),
          'surprise': 'new_entity',
        };

        final entity = TestEntityState.fromJson(rawJson);

        // Verify _orig_ fields are set from current values
        expect(entity.change_domainId_orig_, equals('d2'));
        expect(entity.change_changeAt_orig_, equals(changeAt.toUtc()));
        expect(entity.change_cid_orig_, equals('cid-new'));
        expect(entity.change_changeBy_orig_, equals('creator'));
        // change_storedAt_orig_ should be set from current values (no cloudAt provided)
        expect(entity.change_storedAt_orig_, isA<DateTime>());

        // make sure all _orig_ date times are in UTC
        final dateTimeOrigs = entity
            .toJson()
            .entries
            .where((e) => e.key.endsWith('_orig_'))
            .whereType<MapEntry<String, String>>()
            .map((e) => MapEntry(e.key, DateTime.parse(e.value)))
            .toList();

        for (final entry in dateTimeOrigs) {
          expect(
            entry.value.isUtc,
            isTrue,
            reason: '${entry.key} is not in UTC',
          );
        }

        // Verify unknown fields still work
        final unknown = jsonDecode(entity.unknownJson) as Map<String, dynamic>;
        expect(unknown['surprise'], equals('new_entity'));
      },
    );

    test('preserves non-empty _orig_ field values', () {
      final changeAtJson = DateTime.parse(
        '2024-02-01T10:00:00Z',
      ).toUtc().toIso8601String();
      final storedAtJson = DateTime.now().toUtc().toIso8601String();
      final rawJson = {
        'entityId': 'test-updated',
        'entityType': 'task',
        'domainType': 'project',
        'change_domainId': 'd3-current',
        'change_changeAt': changeAtJson,
        'change_cid': 'cid-current',
        'change_changeBy': 'updater',
        'data_nameLocal': 'Updated Test Task',
        'data_nameLocal_dataSchemaRev_': 2,
        'data_nameLocal_changeAt_': changeAtJson,
        'data_nameLocal_cid_': 'cid-name-current',
        'data_nameLocal_changeBy_': 'updater',
        'data_parentId': 'parent-current',
        'data_parentId_dataSchemaRev_': 0,
        'data_parentId_changeAt_': changeAtJson,
        'data_parentId_cid_': 'cid-parent-current',
        'data_parentId_changeBy_': 'updater',
        'data_parentProp': 'pList',
        'data_parentProp_dataSchemaRev_': 0,
        'data_parentProp_changeAt_': changeAtJson,
        'data_parentProp_cid_': 'cid-parent-current',
        'data_parentProp_changeBy_': 'updater',
        // Note: providing specific _orig_ values that should be preserved
        'change_domainId_orig_': 'd3-original',
        'change_changeAt_orig_': '2024-01-15T09:30:00Z',
        'change_cid_orig_': 'cid-original',
        'change_changeBy_orig_': 'creator',
        'change_storedAt': storedAtJson,
        'change_storedAt_orig_': '2024-01-01T09:30:00Z',
        'surprise': 'updated_entity',
      };

      final entity = TestEntityState.fromJson(rawJson);

      // Verify _orig_ fields preserve their provided values (not current values)
      expect(entity.change_domainId_orig_, equals('d3-original'));
      expect(
        entity.change_changeAt_orig_,
        equals(DateTime.parse('2024-01-15T09:30:00Z')),
      );
      expect(entity.change_cid_orig_, equals('cid-original'));
      expect(
        entity.change_storedAt_orig_,
        equals(DateTime.parse('2024-01-01T09:30:00Z')),
      );
      expect(entity.change_changeBy_orig_, equals('creator'));

      // Verify current values are different from _orig_ values
      expect(entity.change_domainId, equals('d3-current'));
      expect(
        entity.change_changeAt,
        equals(DateTime.parse('2024-02-01T10:00:00Z')),
      );
      expect(entity.change_cid, equals('cid-current'));
      expect(entity.change_changeBy, equals('updater'));

      // Verify unknown fields still work
      final unknown = jsonDecode(entity.unknownJson) as Map<String, dynamic>;
      expect(unknown['surprise'], equals('updated_entity'));
    });
  });
}
