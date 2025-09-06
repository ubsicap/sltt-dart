# syncable_entity_state_data

Annotation + generator for producing `*EntityState` classes implementing `BaseEntityState` from annotated data classes.

## Usage

1. Add dependency (local path in monorepo):

```yaml
dependencies:
  syncable_entity_state_data:
    path: ../syncable_entity_state_data
```

2. Annotate a data class:

```dart
import 'package:syncable_entity_state_data/syncable_entity_state_data.dart';

@SyncableEntityStateData(entityTypeOverride: 'task')
class TaskData implements CoreSyncableEntityDataFields {
  final String parentId;
  final String nameLocal;
  @override
  final String? rank;
  @override
  final bool? deleted;
  const TaskData({
    required this.parentId,
    required this.nameLocal,
    this.rank,
    this.deleted,
  });
}
```

3. Run build:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generates `task_data.entity_state.dart` containing `TaskDataEntityState` with:
- `change_*` fields from `BaseEntityState`
- `data_<field>` plus meta markers: `_dataSchemaRev_`, `_changeAt_`, `_cid_`, `_changeBy_`, `_cloudAt_`

## Notes / Next Steps
- Extend generator to include `_orig_` meta fields where needed.
- Add validation utilities + fromJson factory.
- Integrate with sync_manager pipelines.
