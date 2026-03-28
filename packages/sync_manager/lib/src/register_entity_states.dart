import 'package:isar_community/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/unknown_entity_state.isar.dart'
    show registerIsarUnknownEntityStateStorageGroup;
import 'package:sync_manager/src/models/user_preferences.entity_state.isar.dart'
    show
        registerIsarUserPreferencesDataEntityStateStorageGroup,
        IsarUserPreferencesDataEntityStateSchema;

import 'isar_entity_state_storage_group.dart';
import 'models/isar_document_state.dart';
import 'models/isar_project_state.dart';
import 'models/isar_task_state.dart';

/// Schemas required by Isar initialization. Kept separate from registration
/// so calling code can open Isar with all necessary schemas before
/// registering storage groups.
final List<CollectionSchema> entityStateSchemas = [
  IsarUserPreferencesDataEntityStateSchema,
  IsarProjectStateSchema,
  IsarDocumentStateSchema,
  IsarTaskStateSchema,
];

/// Register all Isar entity state storage groups
void registerAllIsarEntityStateStorageGroups(
  IsarEntityStateStorageRegistry registry,
  Isar isar,
) {
  registerIsarUnknownEntityStateStorageGroup(registry, isar);
  registerIsarUserPreferencesDataEntityStateStorageGroup(registry, isar);
  registry.register(
    IsarEntityStateStorageGroup<IsarProjectState>(
      entityType: EntityType.project,
      fromJson: IsarProjectState.fromJson,
      put: (state) async =>
          // ignore: experimental_member_use
          await isar.isarProjectStates.putByIndex(
            r'change_domainId_entityId',
            state as IsarProjectState,
          ),
      putAll: (states) async =>
          // ignore: experimental_member_use
          await isar.isarProjectStates.putAllByIndex(
            r'change_domainId_entityId',
            states.cast<IsarProjectState>(),
          ),
      collection: (Isar db) => db.isarProjectStates,
      findByDomainAndEntity: (Isar db, String projectId, String entityId) => db
          .isarProjectStates
          .filter()
          .change_domainIdEqualTo(projectId)
          .and()
          .entityIdEqualTo(entityId)
          .findFirst(),
      getAllByChange_domainIdEntityId:
          (Isar db, List<String> domainIds, List<String> entityIds) async {
            final results = await db.isarProjectStates
                .getAllByChange_domainIdEntityId(domainIds, entityIds);
            return results.whereType<IsarProjectState>().toList();
          },
      findByDomainWithPagination:
          ({
            required String domainId,
            String? cursor,
            int? limit,
            String? parentId,
            String? parentProp,
            DateTime? storedAfter,
          }) async {
            var query = isar.isarProjectStates.filter().change_domainIdEqualTo(
              domainId,
            );
            if (parentId != null) {
              query = query.and().data_parentIdEqualTo(parentId);
            }
            if (parentProp != null) {
              query = query.and().data_parentPropEqualTo(parentProp);
            }
            if (storedAfter != null) {
              query = query.and().change_storedAtGreaterThan(storedAfter);
            }
            if (cursor != null) {
              query = query.and().entityIdGreaterThan(cursor);
            }
            return await query.sortByEntityId().limit(limit ?? 100).findAll();
          },
      deleteByDomain: ({required domainId, required domainType}) async =>
          await isar.isarProjectStates
              .filter()
              .change_domainIdEqualTo(domainId)
              .deleteAll(),
    ),
  );
  registry.register(
    IsarEntityStateStorageGroup<IsarDocumentState>(
      entityType: EntityType.document,
      fromJson: IsarDocumentState.fromJson,
      put: (state) async =>
          // ignore: experimental_member_use
          await isar.isarDocumentStates.putByIndex(
            r'change_domainId_entityId',
            state as IsarDocumentState,
          ),
      putAll: (states) async =>
          // ignore: experimental_member_use
          await isar.isarDocumentStates.putAllByIndex(
            r'change_domainId_entityId',
            states.cast<IsarDocumentState>(),
          ),
      collection: (Isar db) => db.isarDocumentStates,
      findByDomainAndEntity: (Isar db, String projectId, String entityId) => db
          .isarDocumentStates
          .filter()
          .change_domainIdEqualTo(projectId)
          .and()
          .entityIdEqualTo(entityId)
          .findFirst(),
      getAllByChange_domainIdEntityId:
          (Isar db, List<String> domainIds, List<String> entityIds) async {
            final results = await db.isarDocumentStates
                .getAllByChange_domainIdEntityId(domainIds, entityIds);
            return results.whereType<IsarDocumentState>().toList();
          },
      findByDomainWithPagination:
          ({
            required String domainId,
            String? cursor,
            int? limit,
            String? parentId,
            String? parentProp,
            DateTime? storedAfter,
          }) async {
            var query = isar.isarDocumentStates.filter().change_domainIdEqualTo(
              domainId,
            );
            if (parentId != null) {
              query = query.and().data_parentIdEqualTo(parentId);
            }
            if (parentProp != null) {
              query = query.and().data_parentPropEqualTo(parentProp);
            }
            if (storedAfter != null) {
              query = query.and().change_storedAtGreaterThan(storedAfter);
            }
            if (cursor != null) {
              query = query.and().entityIdGreaterThan(cursor);
            }
            return await query.sortByEntityId().limit(limit ?? 100).findAll();
          },
      deleteByDomain: ({required domainId, required domainType}) async =>
          await isar.isarDocumentStates
              .filter()
              .change_domainIdEqualTo(domainId)
              .deleteAll(),
    ),
  );
  registry.register(
    IsarEntityStateStorageGroup<IsarTaskState>(
      entityType: EntityType.task,
      fromJson: IsarTaskState.fromJson,
      put: (state) async =>
          // ignore: experimental_member_use
          await isar.isarTaskStates.putByIndex(
            r'change_domainId_entityId',
            state as IsarTaskState,
          ),
      putAll: (states) async =>
          // ignore: experimental_member_use
          await isar.isarTaskStates.putAllByIndex(
            r'change_domainId_entityId',
            states.cast<IsarTaskState>(),
          ),
      collection: (Isar db) => db.isarTaskStates,
      findByDomainAndEntity: (Isar db, String projectId, String entityId) => db
          .isarTaskStates
          .filter()
          .change_domainIdEqualTo(projectId)
          .and()
          .entityIdEqualTo(entityId)
          .findFirst(),
      getAllByChange_domainIdEntityId:
          (Isar db, List<String> domainIds, List<String> entityIds) async {
            final results = await db.isarTaskStates
                .getAllByChange_domainIdEntityId(domainIds, entityIds);
            return results.whereType<IsarTaskState>().toList();
          },
      findByDomainWithPagination:
          ({
            required String domainId,
            String? cursor,
            int? limit,
            String? parentId,
            String? parentProp,
            DateTime? storedAfter,
          }) async {
            var query = isar.isarTaskStates.filter().change_domainIdEqualTo(
              domainId,
            );
            if (parentId != null) {
              query = query.and().data_parentIdEqualTo(parentId);
            }
            if (parentProp != null) {
              query = query.and().data_parentPropEqualTo(parentProp);
            }
            if (storedAfter != null) {
              query = query.and().change_storedAtGreaterThan(storedAfter);
            }
            if (cursor != null) {
              query = query.and().entityIdGreaterThan(cursor);
            }
            return await query.sortByEntityId().limit(limit ?? 100).findAll();
          },
      deleteByDomain: ({required domainId, required domainType}) async =>
          await isar.isarTaskStates
              .filter()
              .change_domainIdEqualTo(domainId)
              .deleteAll(),
    ),
  );
}
