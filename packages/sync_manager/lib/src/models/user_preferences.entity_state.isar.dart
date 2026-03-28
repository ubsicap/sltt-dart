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
  @Index(unique: false)
  final String entityId;

  @override
  @Index(composite: [CompositeIndex('entityId')], unique: true)
  @Index(
    composite: [CompositeIndex('data_parentId'), CompositeIndex('entityId')],
    unique: true,
  )
  String get change_domainId => super.change_domainId;

  final String data_uiLocale;
  final int? data_uiLocale_dataSchemaRev_;
  final DateTime data_uiLocale_changeAt_;
  final String? data_uiLocale_cid_;
  final String data_uiLocale_changeBy_;
  final DateTime? data_uiLocale_cloudAt_;

  IsarUserPreferencesDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypeUserPreferences,
    this.id = Isar.autoIncrement,
    required this.entityId,
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
    super.stateDataHash,
    super.stateDataHash_orig_,
    required this.data_uiLocale,
    this.data_uiLocale_dataSchemaRev_,
    required DateTime data_uiLocale_changeAt_,
    this.data_uiLocale_cid_,
    required this.data_uiLocale_changeBy_,
    DateTime? data_uiLocale_cloudAt_,
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
  }) : data_uiLocale_changeAt_ = data_uiLocale_changeAt_.toUtc(),
       data_uiLocale_cloudAt_ = data_uiLocale_cloudAt_?.toUtc();

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
          put: (state) async =>
              // ignore: experimental_member_use
              await isar.isarUserPreferencesDataEntityStates.putByIndex(
                r'change_domainId_entityId',
                state as IsarUserPreferencesDataEntityState,
              ),
          putAll: (states) async =>
              // ignore: experimental_member_use
              await isar.isarUserPreferencesDataEntityStates.putAllByIndex(
                r'change_domainId_entityId',
                states.cast<IsarUserPreferencesDataEntityState>(),
              ),
          collection: (isar) => isar.isarUserPreferencesDataEntityStates,
          findByDomainAndEntity: (isar, projectId, entityId) => isar
              .isarUserPreferencesDataEntityStates
              .where()
              .entityIdEqualTo(entityId)
              .filter()
              .change_domainIdEqualTo(projectId)
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
                if (parentId != null) {
                  var query = isar.isarUserPreferencesDataEntityStates
                      .where()
                      .change_domainIdData_parentIdEqualToAnyEntityId(
                        domainId,
                        parentId,
                      )
                      .filter()
                      .change_domainIdEqualTo(domainId);
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
                }

                var query = isar.isarUserPreferencesDataEntityStates
                    .where()
                    .change_domainIdEqualToAnyData_parentIdEntityId(domainId)
                    .filter()
                    .change_domainIdEqualTo(domainId);
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
          getAllByChange_domainIdEntityId:
              (isar, List<String> domainIds, List<String> entityIds) async {
                final results = await isar.isarUserPreferencesDataEntityStates
                    .getAllByChange_domainIdEntityId(domainIds, entityIds);
                return results
                    .whereType<IsarUserPreferencesDataEntityState>()
                    .toList();
              },
          deleteByDomain: ({required domainId, required domainType}) async =>
              await isar.isarUserPreferencesDataEntityStates
                  .where()
                  .change_domainIdEqualToAnyData_parentIdEntityId(domainId)
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
                var query = parentId != null
                    ? isar.isarUserPreferencesDataEntityStates
                          .where()
                          .change_domainIdData_parentIdEqualToAnyEntityId(
                            domainId,
                            parentId,
                          )
                          .filter()
                          .change_domainIdEqualTo(domainId)
                    : isar.isarUserPreferencesDataEntityStates
                          .where()
                          .change_domainIdEqualToAnyData_parentIdEntityId(
                            domainId,
                          )
                          .filter()
                          .change_domainIdEqualTo(domainId);
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
