import 'package:json_annotation/json_annotation.dart';
import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  group('JsonSerializable checked: true', () {
    test('throws CheckedFromJsonException on invalid field type', () {
      final String changeAtJson = DateTime.now().toUtc().toIso8601String();
      final storedAtJson = DateTime.now().toUtc().toIso8601String();

      // Provide an invalid type for a required string field to trigger checked error
      final badJson = <String, dynamic>{
        'entityId': 'e1',
        'entityType': 'task',
        'domainType': 'project',
        'change_storedAt': storedAtJson,
        'change_storedAt_orig_': storedAtJson,
        'change_domainId': 'p1',
        'change_domainId_orig_': 'p1',
        'change_changeAt': changeAtJson,
        'change_changeAt_orig_': changeAtJson,
        'change_cid': 'c1',
        'change_cid_orig_': 'c1',
        'change_changeBy': 'u1',
        'change_changeBy_orig_':
            '', // Empty string inherits from change_changeBy
        'data_nameLocal': 'Test Task',
        'data_nameLocal_dataSchemaRev_': 1,
        'data_nameLocal_changeAt_': changeAtJson,
        'data_nameLocal_cid_': 'c1',
        'data_nameLocal_changeBy_': 'u1',
        // parentId is a String in the model but we pass a number to cause type error
        'data_parentId': 123,
        'data_parentId_dataSchemaRev': 1,
        'data_parentId_changeAt_': changeAtJson,
        'data_parentId_cid_': 'c1',
        'data_parentId_changeBy_': 'u1',
        'unknown': <String, dynamic>{},
      };

      expect(
        () => TestEntityState.fromJson(badJson),
        // Style 1: type + having for content
        throwsA(
          isA<CheckedFromJsonException>()
              .having((e) => e.key, 'key', 'data_parentId')
              .having(
                (e) => e.message ?? '',
                'message',
                contains(
                  'type \'int\' is not a subtype of type \'String\' in type cast',
                ),
              ),
        ),
      );
    });

    test('throws when a non-nullable field is null', () {
      final storedAt = DateTime.now().toUtc();
      final badJson = <String, dynamic>{
        'entityId': 'e1',
        'entityType': 'task',
        'domainType': 'project',
        'change_storedAt': storedAt.toIso8601String(),
        'change_storedAt_orig_': storedAt.toIso8601String(),
        'change_domainId': 'p1',
        'change_domainId_orig_': 'p1',
        'change_changeAt': DateTime.now().toIso8601String(),
        'change_changeAt_orig_': DateTime.now().toIso8601String(),
        'change_cid': 'c1',
        'change_cid_orig_': 'c1',
        'change_changeBy': 'u1',
        'change_changeBy_orig_':
            '', // Empty string inherits from change_changeBy
        'data_nameLocal': 'Test Task',
        'data_nameLocal_dataSchemaRev_': 1,
        'data_nameLocal_changeAt_': DateTime.now().toIso8601String(),
        'data_nameLocal_cid_': 'c1',
        'data_nameLocal_changeBy_': 'u1',
        'data_parentId': null, // null for non-nullable
        'data_parentId_dataSchemaRev': 1,
        'data_parentId_changeAt_': DateTime.now().toIso8601String(),
        'data_parentId_cid_': 'c1',
        'data_parentId_changeBy_': 'u1',
        'unknown': <String, dynamic>{},
      };

      expect(
        () => TestEntityState.fromJson(badJson),
        // Style 1 again with explicit key and message contains 'null'
        throwsA(
          isA<CheckedFromJsonException>()
              .having((e) => e.key, 'key', 'data_parentId')
              .having(
                (e) => e.message ?? '',
                'message',
                contains(
                  'type \'Null\' is not a subtype of type \'String\' in type cast',
                ),
              ),
        ),
      );
    });

    test('throws when an expected field is missing', () {
      final changeAtJson = DateTime.now().toUtc().toIso8601String();
      final storedAtJson = DateTime.now().toUtc().toIso8601String();

      final badJson = <String, dynamic>{
        'entityId': 'e1',
        'entityType': 'task',
        'domainType': 'project',
        'change_storedAt': storedAtJson,
        'change_storedAt_orig_': storedAtJson,
        'change_domainId': 'p1',
        'change_domainId_orig_': 'p1',
        'change_changeAt': changeAtJson,
        'change_changeAt_orig_': changeAtJson,
        'change_cid': 'c1',
        'change_cid_orig_': 'c1',
        'change_changeBy': 'u1',
        'change_changeBy_orig_':
            '', // Empty string inherits from change_changeBy
        'data_nameLocal': 'Test Task',
        'data_nameLocal_dataSchemaRev_': 1,
        'data_nameLocal_changeAt_': changeAtJson,
        'data_nameLocal_cid_': 'c1',
        'data_nameLocal_changeBy_': 'u1',
        // 'data_parentId' intentionally omitted
        'data_parentId_dataSchemaRev': 1,
        'data_parentId_changeAt_': changeAtJson,
        'data_parentId_cid_': 'c1',
        'data_parentId_changeBy_': 'u1',
        'unknown': <String, dynamic>{},
      };

      // Style 2: predicate matcher
      expect(
        () => TestEntityState.fromJson(badJson),
        throwsA(
          isA<CheckedFromJsonException>()
              .having((e) => e.key, 'key', 'data_parentId')
              .having(
                (e) => e.message ?? '',
                'message',
                contains(
                  'type \'Null\' is not a subtype of type \'String\' in type cast',
                ),
              ),
        ),
      );
    });
  });
}
