import 'dart:convert';

import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/isar_document_state.dart';
import 'package:sync_manager/src/models/isar_project_state.dart';
import 'package:sync_manager/src/models/isar_team_state.dart';
import 'package:test/test.dart';

void main() {
  test('IsarProjectState.fromJson preserves unknown fields', () {
    final rawJson = {
      'id': 1,
      'entityId': 'proj-1',
      'entityType': 'project',
      'domainType': 'project',
      'schemaVersion': 1,
      'change_domainId': 'd1',
      'change_changeAt': DateTime.now().toIso8601String(),
      'change_cid': 'cid-p1',
      'change_changeBy': 'u1',
      'data_parentId': 'parent',
      'data_parentId_dataSchemaRev_': 0,
      'data_parentId_changeAt_': DateTime.now().toIso8601String(),
      'data_parentId_cid_': 'cid-parent',
      'data_parentId_changeBy_': 'u1',
      'data_parentProp': 'pList',
      'data_parentProp_dataSchemaRev_': 0,
      'data_parentProp_changeAt_': DateTime.now().toIso8601String(),
      'data_parentProp_cid_': 'cid-parent',
      'data_parentProp_changeBy_': 'u1',
      // required orig_ fields set by generator; include minimal defaults
      'change_domainId_orig_': 'd1',
      'change_changeAt_orig_': DateTime.now().toIso8601String(),
      'change_cid_orig_': 'cid-p1',
      'change_changeBy_orig_': 'u1',
      // add an unexpected field
      'surprise': 'gotcha',
    };

    final p = IsarProjectState.fromJson(rawJson);
    final unknown = jsonDecode(p.unknownJson) as Map<String, dynamic>;
    expect(unknown['surprise'], equals('gotcha'));
    expect(p.entityId, equals('proj-1'));
  });

  test('IsarTeamState.fromJson preserves unknown fields', () {
    final rawJson = {
      'id': 2,
      'entityId': 'team-1',
      'entityType': 'team',
      'domainType': 'project',
      'schemaVersion': 1,
      'change_domainId': 'd1',
      'change_changeAt': DateTime.now().toIso8601String(),
      'change_cid': 'cid-t1',
      'change_changeBy': 'u2',
      'data_rank': '0',
      'data_parentId': '',
      'data_parentId_dataSchemaRev_': 0,
      'data_parentId_changeAt_': DateTime.now().toIso8601String(),
      'data_parentId_cid_': 'cid-p',
      'data_parentId_changeBy_': 'u2',
      'data_parentProp': 'pList',
      'data_parentProp_dataSchemaRev_': 0,
      'data_parentProp_changeAt_': DateTime.now().toIso8601String(),
      'data_parentProp_cid_': 'cid-p',
      'data_parentProp_changeBy_': 'u2',
      // required orig_ fields
      'change_domainId_orig_': 'd1',
      'change_changeAt_orig_': DateTime.now().toIso8601String(),
      'change_cid_orig_': 'cid-t1',
      'change_changeBy_orig_': 'u2',
      // required non-nullable team-specific fields
      'name': 'Team Name',
      'nameChangeAt': DateTime.now().toIso8601String(),
      'nameCid': 'cid-name',
      'nameChangeBy': 'u2',
      'description': 'desc',
      'descriptionChangeAt': DateTime.now().toIso8601String(),
      'descriptionCid': 'cid-desc',
      'descriptionChangeBy': 'u2',
      'leadId': 'lead-1',
      'leadIdChangeAt': DateTime.now().toIso8601String(),
      'leadIdCid': 'cid-lead',
      'leadIdChangeBy': 'u2',
      'settings': '{}',
      'settingsChangeAt': DateTime.now().toIso8601String(),
      'settingsCid': 'cid-settings',
      'settingsChangeBy': 'u2',
      'surprise_team': 'wow',
    };

    final t = IsarTeamState.fromJson(rawJson);
    final unknown = jsonDecode(t.unknownJson) as Map<String, dynamic>;
    expect(unknown['surprise_team'], equals('wow'));
    expect(t.entityId, equals('team-1'));
  });

  test('IsarDocumentState.fromJson preserves unknown fields', () {
    final rawJson = {
      'id': 3,
      'entityId': 'doc-1',
      'entityType': 'document',
      'domainType': 'project',
      'schemaVersion': 1,
      'change_domainId': 'd1',
      'change_changeAt': DateTime.now().toIso8601String(),
      'change_cid': 'cid-d1',
      'change_changeBy': 'u3',
      'data_title': 'Title',
      'data_contentLength': 123,
      'data_parentId': '',
      'data_parentId_dataSchemaRev_': 0,
      'data_parentId_changeAt_': DateTime.now().toIso8601String(),
      'data_parentId_cid_': 'cid-p',
      'data_parentId_changeBy_': 'u3',
      'data_parentProp': 'pList',
      'data_parentProp_dataSchemaRev_': 0,
      'data_parentProp_changeAt_': DateTime.now().toIso8601String(),
      'data_parentProp_cid_': 'cid-p',
      'data_parentProp_changeBy_': 'u3',
      // required orig_ fields
      'change_domainId_orig_': 'd1',
      'change_changeAt_orig_': DateTime.now().toIso8601String(),
      'change_cid_orig_': 'cid-d1',
      'change_changeBy_orig_': 'u3',
      'extra_doc': 'yep',
    };

    final d = IsarDocumentState.fromJson(rawJson);
    final unknown = jsonDecode(d.unknownJson) as Map<String, dynamic>;
    expect(unknown['extra_doc'], equals('yep'));
    expect(d.entityId, equals('doc-1'));
  });

  test(
    'IsarProjectState initializes _orig_ fields from current values when missing',
    () {
      final rawJson = {
        'id': 4,
        'entityId': 'proj-new',
        'entityType': 'project',
        'domainType': 'project',
        'schemaVersion': 1,
        'change_domainId': 'd2',
        'change_changeAt': '2024-01-01T10:00:00Z',
        'change_cid': 'cid-new',
        'change_changeBy': 'creator',
        'data_parentId': 'parent',
        'data_parentId_dataSchemaRev_': 0,
        'data_parentId_changeAt_': '2024-01-01T10:00:00Z',
        'data_parentId_cid_': 'cid-parent',
        'data_parentId_changeBy_': 'creator',
        'data_parentProp': 'pList',
        'data_parentProp_dataSchemaRev_': 0,
        'data_parentProp_changeAt_': '2024-01-01T10:00:00Z',
        'data_parentProp_cid_': 'cid-parent',
        'data_parentProp_changeBy_': 'creator',
        // Note: using empty/default values to test that _orig_ fields get proper values
        'change_domainId_orig_': '',
        'change_changeAt_orig_': BaseEntityState.defaultOrigDateTime()
            .toIso8601String(),
        'change_cid_orig_': '',
        'change_changeBy_orig_': '',
        'surprise': 'new_entity',
      };

      final p = IsarProjectState.fromJson(rawJson);

      // Verify _orig_ fields are set from current values
      expect(p.change_domainId_orig_, equals('d2'));
      expect(
        p.change_changeAt_orig_,
        equals(DateTime.parse('2024-01-01T10:00:00Z')),
      );
      expect(p.change_cid_orig_, equals('cid-new'));
      expect(p.change_changeBy_orig_, equals('creator'));

      // Verify unknown fields still work
      final unknown = jsonDecode(p.unknownJson) as Map<String, dynamic>;
      expect(unknown['surprise'], equals('new_entity'));
    },
  );

  test('IsarProjectState preserves non-empty _orig_ field values', () {
    final rawJson = {
      'id': 5,
      'entityId': 'proj-updated',
      'entityType': 'project',
      'domainType': 'project',
      'schemaVersion': 1,
      'change_domainId': 'd3-current',
      'change_changeAt': '2024-02-01T10:00:00Z',
      'change_cid': 'cid-current',
      'change_changeBy': 'updater',
      'data_parentId': 'parent-current',
      'data_parentId_dataSchemaRev_': 0,
      'data_parentId_changeAt_': '2024-02-01T10:00:00Z',
      'data_parentId_cid_': 'cid-parent-current',
      'data_parentId_changeBy_': 'updater',
      'data_parentProp': 'pList',
      'data_parentProp_dataSchemaRev_': 0,
      'data_parentProp_changeAt_': '2024-02-01T10:00:00Z',
      'data_parentProp_cid_': 'cid-parent-current',
      'data_parentProp_changeBy_': 'updater',
      // Note: providing specific _orig_ values that should be preserved
      'change_domainId_orig_': 'd3-original',
      'change_changeAt_orig_': '2024-01-15T09:30:00Z',
      'change_cid_orig_': 'cid-original',
      'change_changeBy_orig_': 'creator',
      'surprise': 'updated_entity',
    };

    final p = IsarProjectState.fromJson(rawJson);

    // Verify _orig_ fields preserve their provided values (not current values)
    expect(p.change_domainId_orig_, equals('d3-original'));
    expect(
      p.change_changeAt_orig_,
      equals(DateTime.parse('2024-01-15T09:30:00Z')),
    );
    expect(p.change_cid_orig_, equals('cid-original'));
    expect(p.change_changeBy_orig_, equals('creator'));

    // Verify current values are different from _orig_ values
    expect(p.change_domainId, equals('d3-current'));
    expect(p.change_changeAt, equals(DateTime.parse('2024-02-01T10:00:00Z')));
    expect(p.change_cid, equals('cid-current'));
    expect(p.change_changeBy, equals('updater'));

    // Verify unknown fields still work
    final unknown = jsonDecode(p.unknownJson) as Map<String, dynamic>;
    expect(unknown['surprise'], equals('updated_entity'));
  });
}
