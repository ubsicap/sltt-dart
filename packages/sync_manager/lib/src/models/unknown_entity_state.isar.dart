// using marker.entity_state.isar.dart as an exemplar
// ignore_for_file: non_constant_identifier_names

import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/sync_manager.dart';

part 'unknown_entity_state.isar.g.dart';

/// Isar collection for unknown/future entity state storage.
/// Acts as a forward-compatibility catch-all for entity types that are not
/// yet registered in this client. Preserves all base fields plus an optional
/// [data_name] field for basic identification.
@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
@Collection()
class IsarUnknownEntityState extends BaseEntityState {
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

  // Optional name field for future-proofed unknown entity types
  final String? data_name;
  final int? data_name_dataSchemaRev_;
  final DateTime? data_name_changeAt_;
  final String? data_name_cid_;
  final String? data_name_changeBy_;
  final DateTime? data_name_cloudAt_;

  IsarUnknownEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypeUnknown,
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
    this.data_name,
    this.data_name_dataSchemaRev_,
    DateTime? data_name_changeAt_,
    this.data_name_cid_,
    this.data_name_changeBy_,
    DateTime? data_name_cloudAt_,
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
  }) : data_name_changeAt_ = data_name_changeAt_?.toUtc(),
       data_name_cloudAt_ = data_name_cloudAt_?.toUtc();

  static IsarUnknownEntityState fromJsonBase(Map<String, dynamic> json) =>
      _$IsarUnknownEntityStateFromJson(json);

  factory IsarUnknownEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$IsarUnknownEntityStateFromJson,
        json,
        _$IsarUnknownEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$IsarUnknownEntityStateToJson);

  @override
  Map<String, dynamic> toJsonBase() => _$IsarUnknownEntityStateToJson(this);
}

void registerIsarUnknownEntityStateStorageGroup(
  IsarEntityStateStorageRegistry registry,
  Isar isar,
) {
  registry.register(
    IsarEntityStateStorageGroup<IsarUnknownEntityState>(
      entityType: EntityType.unknown,
      fromJson: IsarUnknownEntityState.fromJson,
      put: (state) async => await isar.isarUnknownEntityStates.put(
        state as IsarUnknownEntityState,
      ),
      putAll: (states) async => await isar.isarUnknownEntityStates.putAll(
        states.cast<IsarUnknownEntityState>(),
      ),
      collection: (isar) => isar.isarUnknownEntityStates,
      findByDomainAndEntity: (isar, domainId, entityId) => isar
          .isarUnknownEntityStates
          .where()
          .entityIdEqualTo(entityId)
          .filter()
          .change_domainIdEqualTo(domainId)
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
              var query = isar.isarUnknownEntityStates
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
              return await query.sortByEntityId().limit(limit ?? 100).findAll();
            }

            var query = isar.isarUnknownEntityStates
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
            return await query.sortByEntityId().limit(limit ?? 100).findAll();
          },
      getAllByChange_domainIdEntityId:
          (isar, List<String> domainIds, List<String> entityIds) async {
            final results = await isar.isarUnknownEntityStates
                .getAllByChange_domainIdEntityId(domainIds, entityIds);
            return results.whereType<IsarUnknownEntityState>().toList();
          },
      deleteByDomain: ({required domainId, required domainType}) async =>
          await isar.isarUnknownEntityStates
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
                ? isar.isarUnknownEntityStates
                      .where()
                      .change_domainIdData_parentIdEqualToAnyEntityId(
                        domainId,
                        parentId,
                      )
                      .filter()
                      .change_domainIdEqualTo(domainId)
                : isar.isarUnknownEntityStates
                      .where()
                      .change_domainIdEqualToAnyData_parentIdEntityId(domainId)
                      .filter()
                      .change_domainIdEqualTo(domainId);
            if (parentProp != null) {
              query = query.and().data_parentPropEqualTo(parentProp);
            }
            if (entityId != null) {
              query = query.and().entityIdEqualTo(entityId);
            }
            return query.watchLazy(fireImmediately: fireImmediately).listen((
              _,
            ) {
              onChanged();
            });
          },
    ),
  );
}
