import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';
import 'package:syncable_entity_state_data/src/generator.dart';

void main() {
  test('generates *EntityState for annotated data class', () async {
    const src = r'''
      import 'package:syncable_entity_state_data/syncable_entity_state_data.dart';

      @SyncableEntityStateData(entityTypeOverride: 'task')
      class TaskData implements CoreSyncableEntityDataFields {
        @override
        final String parentId;
        @override
        final bool? deleted;
        @override
        final String? rank;
        final String nameLocal;
        const TaskData({
          required this.parentId,
          required this.nameLocal,
          this.rank,
          this.deleted,
        });
      }
    ''';

    final assets = {
      'syncable_entity_state_data|lib/task_data.dart': src,
    };

    final builder = syncableEntityStateDataBuilder(BuilderOptions(const {}));
    final reader = await PackageAssetReader.currentIsolate();
    final outputs = await testBuilder(
      builder,
      assets,
      reader: reader,
      generateFor: const {'syncable_entity_state_data|lib/task_data.dart'},
    );

    final generated =
        outputs['syncable_entity_state_data|lib/task_data.entity_state.dart'];
    expect(generated, isNotNull);
    expect(generated,
        contains('class TaskDataEntityState extends BaseEntityState'));
    expect(generated, contains("entityType: entityType ?? 'task'"));
    expect(generated, contains('fromJsonBase'));
    expect(generated, contains('toJsonBase'));
    expect(generated, contains('toJsonSafe'));
    expect(generated, contains('deserializeWithUnknownFieldData'));
    expect(generated, contains('serializeWithUnknownFieldData'));
  });
}
