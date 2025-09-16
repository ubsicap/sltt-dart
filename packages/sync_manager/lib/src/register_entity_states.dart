import 'package:isar/isar.dart';
import 'package:sltt_core/sltt_core.dart';

import 'isar_entity_state_storage_group.dart';
import 'models/isar_document_state.dart';
import 'models/isar_project_state.dart';
import 'models/isar_task_state.dart';
import 'models/isar_team_state.dart';

/// Schemas required by Isar initialization. Kept separate from registration
/// so calling code can open Isar with all necessary schemas before
/// registering storage groups.
final List<CollectionSchema> entityStateSchemas = [
  IsarProjectStateSchema,
  IsarDocumentStateSchema,
  IsarTeamStateSchema,
  IsarTaskStateSchema,
];

/// Register all Isar entity state storage groups
void registerAllIsarEntityStateStorageGroups(Isar isar) {
  registerIsarEntityStateStorageGroup(
    IsarEntityStateStorageGroup<IsarProjectState>(
      entityType: EntityType.project,
      fromJson: IsarProjectState.fromJson,
      put: (state) async =>
          await isar.isarProjectStates.put(state as IsarProjectState),
      collection: (Isar db) => db.isarProjectStates,
      findByDomainAndEntity: (Isar db, String projectId, String entityId) => db
          .isarProjectStates
          .filter()
          .change_domainIdEqualTo(projectId)
          .and()
          .entityIdEqualTo(entityId)
          .findFirst(),
      findByDomainWithPagination:
          (
            Isar db,
            String domainId, {
            String? cursor,
            int? limit,
            String? parentId,
            String? parentProp,
          }) async {
            var query = db.isarProjectStates.filter().change_domainIdEqualTo(
              domainId,
            );
            if (parentId != null) {
              query = query.and().data_parentIdEqualTo(parentId);
            }
            if (parentProp != null) {
              query = query.and().data_parentPropEqualTo(parentProp);
            }
            if (cursor != null) {
              query = query.and().entityIdGreaterThan(cursor);
            }
            return await query.sortByEntityId().limit(limit ?? 100).findAll();
          },
    ),
  );
  registerIsarEntityStateStorageGroup(
    IsarEntityStateStorageGroup<IsarDocumentState>(
      entityType: EntityType.document,
      fromJson: IsarDocumentState.fromJson,
      put: (state) async =>
          await isar.isarDocumentStates.put(state as IsarDocumentState),
      collection: (Isar db) => db.isarDocumentStates,
      findByDomainAndEntity: (Isar db, String projectId, String entityId) => db
          .isarDocumentStates
          .filter()
          .change_domainIdEqualTo(projectId)
          .and()
          .entityIdEqualTo(entityId)
          .findFirst(),
      findByDomainWithPagination:
          (
            Isar db,
            String domainId, {
            String? cursor,
            int? limit,
            String? parentId,
            String? parentProp,
          }) async {
            var query = db.isarDocumentStates.filter().change_domainIdEqualTo(
              domainId,
            );
            if (parentId != null) {
              query = query.and().data_parentIdEqualTo(parentId);
            }
            if (parentProp != null) {
              query = query.and().data_parentPropEqualTo(parentProp);
            }
            if (cursor != null) {
              query = query.and().entityIdGreaterThan(cursor);
            }
            return await query.sortByEntityId().limit(limit ?? 100).findAll();
          },
    ),
  );
  registerIsarEntityStateStorageGroup(
    IsarEntityStateStorageGroup<IsarTeamState>(
      entityType: EntityType.team,
      fromJson: IsarTeamState.fromJson,
      put: (state) async =>
          await isar.isarTeamStates.put(state as IsarTeamState),
      collection: (Isar db) => db.isarTeamStates,
      findByDomainAndEntity: (Isar db, String projectId, String entityId) => db
          .isarTeamStates
          .filter()
          .change_domainIdEqualTo(projectId)
          .and()
          .entityIdEqualTo(entityId)
          .findFirst(),
      findByDomainWithPagination:
          (
            Isar db,
            String domainId, {
            String? cursor,
            int? limit,
            String? parentId,
            String? parentProp,
          }) async {
            var query = db.isarTeamStates.filter().change_domainIdEqualTo(
              domainId,
            );
            if (parentId != null) {
              query = query.and().data_parentIdEqualTo(parentId);
            }
            if (parentProp != null) {
              query = query.and().data_parentPropEqualTo(parentProp);
            }
            if (cursor != null) {
              query = query.and().entityIdGreaterThan(cursor);
            }
            return await query.sortByEntityId().limit(limit ?? 100).findAll();
          },
    ),
  );
  registerIsarEntityStateStorageGroup(
    IsarEntityStateStorageGroup<IsarTaskState>(
      entityType: EntityType.task,
      fromJson: IsarTaskState.fromJson,
      put: (state) async =>
          await isar.isarTaskStates.put(state as IsarTaskState),
      collection: (Isar db) => db.isarTaskStates,
      findByDomainAndEntity: (Isar db, String projectId, String entityId) => db
          .isarTaskStates
          .filter()
          .change_domainIdEqualTo(projectId)
          .and()
          .entityIdEqualTo(entityId)
          .findFirst(),
      findByDomainWithPagination:
          (
            Isar db,
            String domainId, {
            String? cursor,
            int? limit,
            String? parentId,
            String? parentProp,
          }) async {
            var query = db.isarTaskStates.filter().change_domainIdEqualTo(
              domainId,
            );
            if (parentId != null) {
              query = query.and().data_parentIdEqualTo(parentId);
            }
            if (parentProp != null) {
              query = query.and().data_parentPropEqualTo(parentProp);
            }
            if (cursor != null) {
              query = query.and().entityIdGreaterThan(cursor);
            }
            return await query.sortByEntityId().limit(limit ?? 100).findAll();
          },
    ),
  );
}
