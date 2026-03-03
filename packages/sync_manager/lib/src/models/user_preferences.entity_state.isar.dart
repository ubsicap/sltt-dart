// ignore_for_file: non_constant_identifier_names

import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/sync_manager.dart';

part 'user_preferences.entity_state.isar.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
@Collection()
class IsarUserPreferencesDataEntityState extends BaseEntityState {
  Id id;

  @override
  @Index(unique: true)
  final String entityId;

  // TODO: add the actual data_{preference} fields here

  IsarUserPreferencesDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypeUserPreferences,
    this.id = Isar.autoIncrement,
    this.entityId = kEntityIdDefaultUserPreferences,
    required super.domainType,
    required super.change_domainId,
    required super.change_domainId_orig_,
    required super.change_changeAt,
    required super.change_changeAt_orig_,
    required super.change_storedAt,
    required super.change_storedAt_orig_,
    required super.change_cid,
    required super.change_cid_orig_,
    required super.change_changeBy,
    required super.change_changeBy_orig_,
    required super.data_parentId,
    required super.data_parentId_changeAt_,
    required super.data_parentId_cid_,
    required super.data_parentId_changeBy_,
    super.data_parentId_cloudAt_,
    super.data_parentId_dataSchemaRev_,
    required super.data_parentProp,
    required super.data_parentProp_changeAt_,
    required super.data_parentProp_cid_,
    required super.data_parentProp_changeBy_,
    required super.unknownJson,
    super.change_cloudAt,
    super.change_dataSchemaRev,
    super.data_deleted,
    super.data_deleted_changeAt_,
    super.data_deleted_changeBy_,
    super.data_deleted_cid_,
    super.data_deleted_cloudAt_,
    super.data_deleted_dataSchemaRev_,
    super.data_parentProp_cloudAt_,
    super.data_parentProp_dataSchemaRev_,
    super.data_rank,
    super.data_rank_changeAt_,
    super.data_rank_changeBy_,
    super.data_rank_cid_,
    super.data_rank_cloudAt_,
    super.data_rank_dataSchemaRev_,
  });

  static IsarUserPreferencesDataEntityState fromJsonBase(
    Map<String, dynamic> json,
  ) => _$IsarUserPreferencesDataEntityStateFromJson(json);

  factory IsarUserPreferencesDataEntityState.fromJson(
    Map<String, dynamic> json,
  ) => deserializeWithUnknownFieldData(
    _$IsarUserPreferencesDataEntityStateFromJson,
    json,
    _$IsarUserPreferencesDataEntityStateToJson,
  );

  @override
  Map<String, dynamic> toJson() => serializeWithUnknownFieldData(
    this,
    _$IsarUserPreferencesDataEntityStateToJson,
  );

  @override
  Map<String, dynamic> toJsonBase() =>
      _$IsarUserPreferencesDataEntityStateToJson(this);
}

void registerIsarUserPreferencesDataEntityStateStorageGroup(
  IsarEntityStateStorageRegistry registry,
  Isar isar,
) {
  registry.register(
    IsarEntityStateStorageGroup<IsarUserPreferencesDataEntityState>(
          entityType: EntityType.userPreferences,
          fromJson: IsarUserPreferencesDataEntityState.fromJson,
          put: (state) async => await isar.isarUserPreferencesDataEntityStates
              .put(state as IsarUserPreferencesDataEntityState),
          putAll: (states) async => await isar
              .isarUserPreferencesDataEntityStates
              .putAll(states.cast<IsarUserPreferencesDataEntityState>()),
          collection: (isar) => isar.isarUserPreferencesDataEntityStates,
          findByDomainAndEntity: (isar, projectId, entityId) => isar
              .isarUserPreferencesDataEntityStates
              .filter()
              .change_domainIdEqualTo(projectId)
              .and()
              .entityIdEqualTo(entityId)
              .findFirst(),
          findByDomainWithPagination:
              ({
                required String domainId,
                String? cursor,
                int? limit,
                String? parentId,
                String? parentProp,
                DateTime? storedAfter,
              }) async {
                var query = isar.isarUserPreferencesDataEntityStates
                    .filter()
                    .change_domainIdEqualTo(domainId);
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
                return await query
                    .sortByEntityId()
                    .limit(limit ?? 100)
                    .findAll();
              },
          getAllByEntityId: (isar, entityIds) async {
            final results = await isar.isarUserPreferencesDataEntityStates
                .getAllByEntityId(entityIds);
            return results
                .whereType<IsarUserPreferencesDataEntityState>()
                .toList();
          },
          deleteByDomain: ({required domainId, required domainType}) async =>
              await isar.isarUserPreferencesDataEntityStates
                  .filter()
                  .change_domainIdEqualTo(domainId)
                  .deleteAll(),
          lazyListenToEntityChanges:
              ({
                required String domainId,
                required String domainType,
                String? entityId,
                required String entityType,
                bool fireImmediately = false,
                required void Function() onChanged,
                String? parentId,
                String? parentProp,
              }) {
                var query = isar.isarUserPreferencesDataEntityStates
                    .filter()
                    .change_domainIdEqualTo(domainId);
                if (parentId != null) {
                  query = query.and().data_parentIdEqualTo(parentId);
                }
                if (parentProp != null) {
                  query = query.and().data_parentPropEqualTo(parentProp);
                }
                if (entityId != null) {
                  query = query.and().entityIdEqualTo(entityId);
                }
                return query.watchLazy(fireImmediately: fireImmediately).listen(
                  (_) {
                    onChanged();
                  },
                );
              },
        )
        as IsarEntityStateStorageGroup<BaseEntityState>,
  );
}
