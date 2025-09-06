import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('generated entity state file has expected constructs (pre-built)', () {
    final generated =
        File('test/test_assets/task_data.entity_state.dart').readAsStringSync();
    expect(generated, isNotNull);
    expect(
      generated,
      contains('class TaskDataEntityState extends BaseEntityState'),
    );
    expect(generated, contains("entityType: entityType ?? 'task'"));
    expect(generated, contains('fromJsonBase'));
    expect(generated, contains('toJsonBase'));
    expect(generated, contains('toJsonSafe'));
    expect(generated, contains('deserializeWithUnknownFieldData'));
    expect(generated, contains('serializeWithUnknownFieldData'));
    // all data class fields accessible as data_*, custom field declared
    expect(generated, contains('data_nameLocal'));
    // core field super params present
    expect(generated, contains('required super.data_parentId_changeAt_'));
    // toData mapper
    expect(generated, contains('toData()'));
  });
}
