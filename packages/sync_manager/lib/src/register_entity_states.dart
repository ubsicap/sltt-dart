import 'package:isar/isar.dart';
import 'package:sltt_core/sltt_core.dart';

import 'isar_entity_state_storage_group.dart';
import 'models/isar_document_state.dart';
import 'models/isar_project_state.dart';
import 'models/isar_task_state.dart';
import 'models/isar_team_state.dart';

/// Register all Isar entity state storage groups
void registerAllIsarEntityStateStorageGroups(Isar isar) {
  // Register project state
  registerIsarEntityStateStorageGroup(
    IsarEntityStateStorageGroup<IsarProjectState>(
      entityType: EntityType.project,
      fromJson: IsarProjectState.fromJson,
      put: (state) async =>
          await isar.isarProjectStates.put(state as IsarProjectState),
      schema: IsarProjectStateSchema,
    ),
  );

  // Register document state
  registerIsarEntityStateStorageGroup(
    IsarEntityStateStorageGroup<IsarDocumentState>(
      entityType: EntityType.document,
      fromJson: IsarDocumentState.fromJson,
      put: (state) async =>
          await isar.isarDocumentStates.put(state as IsarDocumentState),
      schema: IsarDocumentStateSchema,
    ),
  );

  // Register team state
  registerIsarEntityStateStorageGroup(
    IsarEntityStateStorageGroup<IsarTeamState>(
      entityType: EntityType.team,
      fromJson: IsarTeamState.fromJson,
      put: (state) async =>
          await isar.isarTeamStates.put(state as IsarTeamState),
      schema: IsarTeamStateSchema,
    ),
  );

  // Register task state
  registerIsarEntityStateStorageGroup(
    IsarEntityStateStorageGroup<IsarTaskState>(
      entityType: EntityType.task,
      fromJson: IsarTaskState.fromJson,
      put: (state) async =>
          await isar.isarTaskStates.put(state as IsarTaskState),
      schema: IsarTaskStateSchema,
    ),
  );
}
