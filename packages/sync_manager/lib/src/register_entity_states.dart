import 'package:isar/isar.dart';
import 'package:sltt_core/sltt_core.dart';

import 'isar_entity_state_storage_group.dart';
import 'models/isar_document_state.dart';
import 'models/isar_project_state.dart';
import 'models/isar_task_state.dart';
import 'models/isar_team_state.dart';

/// Register all Isar entity state storage groups
void registerAllIsarEntityStateStorageGroups(Isar isar) {
  registerIsarEntityStateStorageGroup(
    IsarEntityStateStorageGroup<IsarProjectState>(
      entityType: EntityType.project,
      fromJson: IsarProjectState.fromJson,
      put: (state) async =>
          await isar.isarProjectStates.put(state as IsarProjectState),
      schema: IsarProjectStateSchema,
      collection: (Isar db) => db.isarProjectStates,
      findByDomainAndEntity: (Isar db, String projectId, String entityId) => db
          .isarProjectStates
          .filter()
          .change_domainIdEqualTo(projectId)
          .and()
          .entityIdEqualTo(entityId)
          .findFirst(),
    ),
  );
  registerIsarEntityStateStorageGroup(
    IsarEntityStateStorageGroup<IsarDocumentState>(
      entityType: EntityType.document,
      fromJson: IsarDocumentState.fromJson,
      put: (state) async =>
          await isar.isarDocumentStates.put(state as IsarDocumentState),
      schema: IsarDocumentStateSchema,
      collection: (Isar db) => db.isarDocumentStates,
      findByDomainAndEntity: (Isar db, String projectId, String entityId) => db
          .isarDocumentStates
          .filter()
          .change_domainIdEqualTo(projectId)
          .and()
          .entityIdEqualTo(entityId)
          .findFirst(),
    ),
  );
  registerIsarEntityStateStorageGroup(
    IsarEntityStateStorageGroup<IsarTeamState>(
      entityType: EntityType.team,
      fromJson: IsarTeamState.fromJson,
      put: (state) async =>
          await isar.isarTeamStates.put(state as IsarTeamState),
      schema: IsarTeamStateSchema,
      collection: (Isar db) => db.isarTeamStates,
      findByDomainAndEntity: (Isar db, String projectId, String entityId) => db
          .isarTeamStates
          .filter()
          .change_domainIdEqualTo(projectId)
          .and()
          .entityIdEqualTo(entityId)
          .findFirst(),
    ),
  );
  registerIsarEntityStateStorageGroup(
    IsarEntityStateStorageGroup<IsarTaskState>(
      entityType: EntityType.task,
      fromJson: IsarTaskState.fromJson,
      put: (state) async =>
          await isar.isarTaskStates.put(state as IsarTaskState),
      schema: IsarTaskStateSchema,
      collection: (Isar db) => db.isarTaskStates,
      findByDomainAndEntity: (Isar db, String projectId, String entityId) => db
          .isarTaskStates
          .filter()
          .change_domainIdEqualTo(projectId)
          .and()
          .entityIdEqualTo(entityId)
          .findFirst(),
    ),
  );
}
