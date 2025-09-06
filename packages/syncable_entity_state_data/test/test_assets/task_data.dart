import 'package:syncable_entity_state_data/syncable_entity_state_data.dart';

@SyncableEntityStateData(entityType: 'task')
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
