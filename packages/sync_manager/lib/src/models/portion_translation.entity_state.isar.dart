// ignore_for_file: non_constant_identifier_names

import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';
// note: we intentionally extend BaseEntityState directly for Isar storage
import 'package:sync_manager/sync_manager.dart';

part 'portion_translation.entity_state.isar.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
@Collection()
class IsarPortionDataEntityState extends BaseEntityState {
  Id id;

  @override
  @Index(unique: false)
  final String entityId;

  // data fields (mirror of PortionDataEntityState)
  final String data_name;
  final int? data_name_dataSchemaRev_;
  final DateTime data_name_changeAt_;
  @override
  @Index(composite: [CompositeIndex('entityId')], unique: true)
  @Index(
    composite: [CompositeIndex('data_parentId'), CompositeIndex('entityId')],
    unique: true,
  )
  String get change_domainId => super.change_domainId;
  final String? data_name_cid_;
  final String data_name_changeBy_;
  final DateTime? data_name_cloudAt_;
  final List<String> data_visibility;
  final int? data_visibility_dataSchemaRev_;
  final DateTime data_visibility_changeAt_;
  final String data_visibility_cid_;
  final String data_visibility_changeBy_;
  final DateTime? data_visibility_cloudAt_;

  IsarPortionDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypePortion,
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
    required this.data_name,
    this.data_name_dataSchemaRev_,
    required DateTime data_name_changeAt_,
    this.data_name_cid_,
    required this.data_name_changeBy_,
    DateTime? data_name_cloudAt_,
    required this.data_visibility,
    this.data_visibility_dataSchemaRev_,
    required DateTime data_visibility_changeAt_,
    required this.data_visibility_cid_,
    required this.data_visibility_changeBy_,
    DateTime? data_visibility_cloudAt_,
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
  }) : data_name_changeAt_ = data_name_changeAt_.toUtc(),
       data_name_cloudAt_ = data_name_cloudAt_?.toUtc(),
       data_visibility_changeAt_ = data_visibility_changeAt_.toUtc(),
       data_visibility_cloudAt_ = data_visibility_cloudAt_?.toUtc();

  static IsarPortionDataEntityState fromJsonBase(Map<String, dynamic> json) =>
      _$IsarPortionDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_name', () => '');
    j.putIfAbsent('data_visibility', () => <String>[]);
    j.putIfAbsent('data_type', () => '');
    j.putIfAbsent('data_difficulty', () => '');
    return j;
  }

  factory IsarPortionDataEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$IsarPortionDataEntityStateFromJson,
        json,
        _$IsarPortionDataEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$IsarPortionDataEntityStateToJson);

  @override
  Map<String, dynamic> toJsonBase() => _$IsarPortionDataEntityStateToJson(this);
}

void registerIsarPortionDataEntityStateStorageGroup(
  IsarEntityStateStorageRegistry registry,
  Isar isar,
) {
  registry.register(
    IsarEntityStateStorageGroup<IsarPortionDataEntityState>(
          entityType: EntityType.portion,
          fromJson: IsarPortionDataEntityState.fromJson,
          put: (state) async => await isar.isarPortionDataEntityStates.put(
            state as IsarPortionDataEntityState,
          ),
          putAll: (states) async => await isar.isarPortionDataEntityStates
              .putAll(states.cast<IsarPortionDataEntityState>()),
          collection: (isar) => isar.isarPortionDataEntityStates,
          findByDomainAndEntity: (isar, projectId, entityId) => isar
              .isarPortionDataEntityStates
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
                  var query = isar.isarPortionDataEntityStates
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

                var query = isar.isarPortionDataEntityStates
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
                final results = await isar.isarPortionDataEntityStates
                    .getAllByChange_domainIdEntityId(domainIds, entityIds);
                return results.whereType<IsarPortionDataEntityState>().toList();
              },
          deleteByDomain: ({required domainId, required domainType}) async =>
              await isar.isarPortionDataEntityStates
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
                    ? isar.isarPortionDataEntityStates
                          .where()
                          .change_domainIdData_parentIdEqualToAnyEntityId(
                            domainId,
                            parentId,
                          )
                          .filter()
                          .change_domainIdEqualTo(domainId)
                    : isar.isarPortionDataEntityStates
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
