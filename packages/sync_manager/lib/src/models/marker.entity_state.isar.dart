// using portion_translation.entity_state.isar.dart as an exemplar
// ignore_for_file: non_constant_identifier_names

import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/sync_manager.dart';

part 'marker.entity_state.isar.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
@Collection()
class IsarMarkerDataEntityState extends BaseEntityState {
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

  // data fields (mirror of MarkerData)
  final int data_colorValue;
  final int? data_colorValue_dataSchemaRev_;
  final DateTime data_colorValue_changeAt_;
  final String? data_colorValue_cid_;
  final String data_colorValue_changeBy_;
  final DateTime? data_colorValue_cloudAt_;

  final String data_shape;
  final int? data_shape_dataSchemaRev_;
  final DateTime data_shape_changeAt_;
  final String? data_shape_cid_;
  final String data_shape_changeBy_;
  final DateTime? data_shape_cloudAt_;

  final String data_description;
  final int? data_description_dataSchemaRev_;
  final DateTime data_description_changeAt_;
  final String? data_description_cid_;
  final String data_description_changeBy_;
  final DateTime? data_description_cloudAt_;
  final String? data_replacementId;
  final int? data_replacementId_dataSchemaRev_;
  final DateTime? data_replacementId_changeAt_;
  final String? data_replacementId_cid_;
  final String? data_replacementId_changeBy_;
  final DateTime? data_replacementId_cloudAt_;

  IsarMarkerDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypeMarker,
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
    required this.data_colorValue,
    this.data_colorValue_dataSchemaRev_,
    required DateTime data_colorValue_changeAt_,
    this.data_colorValue_cid_,
    required this.data_colorValue_changeBy_,
    DateTime? data_colorValue_cloudAt_,
    required this.data_shape,
    this.data_shape_dataSchemaRev_,
    required DateTime data_shape_changeAt_,
    this.data_shape_cid_,
    required this.data_shape_changeBy_,
    DateTime? data_shape_cloudAt_,
    required this.data_description,
    this.data_description_dataSchemaRev_,
    required DateTime data_description_changeAt_,
    this.data_description_cid_,
    required this.data_description_changeBy_,
    DateTime? data_description_cloudAt_,
    this.data_replacementId,
    this.data_replacementId_dataSchemaRev_,
    DateTime? data_replacementId_changeAt_,
    this.data_replacementId_cid_,
    this.data_replacementId_changeBy_,
    DateTime? data_replacementId_cloudAt_,
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
  }) : data_colorValue_changeAt_ = data_colorValue_changeAt_.toUtc(),
       data_colorValue_cloudAt_ = data_colorValue_cloudAt_?.toUtc(),
       data_shape_changeAt_ = data_shape_changeAt_.toUtc(),
       data_shape_cloudAt_ = data_shape_cloudAt_?.toUtc(),
       data_description_changeAt_ = data_description_changeAt_.toUtc(),
       data_description_cloudAt_ = data_description_cloudAt_?.toUtc(),
       data_replacementId_changeAt_ = data_replacementId_changeAt_?.toUtc(),
       data_replacementId_cloudAt_ = data_replacementId_cloudAt_?.toUtc();

  static IsarMarkerDataEntityState fromJsonBase(Map<String, dynamic> json) =>
      _$IsarMarkerDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_colorValue', () => 0);
    j.putIfAbsent('data_shape', () => '');
    j.putIfAbsent('data_description', () => '');
    return j;
  }

  factory IsarMarkerDataEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$IsarMarkerDataEntityStateFromJson,
        json,
        _$IsarMarkerDataEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$IsarMarkerDataEntityStateToJson);

  @override
  Map<String, dynamic> toJsonBase() => _$IsarMarkerDataEntityStateToJson(this);
}

void registerIsarMarkerDataEntityStateStorageGroup(
  IsarEntityStateStorageRegistry registry,
  Isar isar,
) {
  registry.register(
    IsarEntityStateStorageGroup<IsarMarkerDataEntityState>(
          entityType: EntityType.marker,
          fromJson: IsarMarkerDataEntityState.fromJson,
          put: (state) async =>
              // ignore: experimental_member_use
              await isar.isarMarkerDataEntityStates.putByIndex(
                r'change_domainId_entityId',
                state as IsarMarkerDataEntityState,
              ),
          putAll: (states) async =>
              // ignore: experimental_member_use
              await isar.isarMarkerDataEntityStates.putAllByIndex(
                r'change_domainId_entityId',
                states.cast<IsarMarkerDataEntityState>(),
              ),
          collection: (isar) => isar.isarMarkerDataEntityStates,
          findByDomainAndEntity: (isar, projectId, entityId) => isar
              .isarMarkerDataEntityStates
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
                  var query = isar.isarMarkerDataEntityStates
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

                var query = isar.isarMarkerDataEntityStates
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
                final results = await isar.isarMarkerDataEntityStates
                    .getAllByChange_domainIdEntityId(domainIds, entityIds);
                return results.whereType<IsarMarkerDataEntityState>().toList();
              },
          deleteByDomain: ({required domainId, required domainType}) async =>
              await isar.isarMarkerDataEntityStates
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
                    ? isar.isarMarkerDataEntityStates
                          .where()
                          .change_domainIdData_parentIdEqualToAnyEntityId(
                            domainId,
                            parentId,
                          )
                          .filter()
                          .change_domainIdEqualTo(domainId)
                    : isar.isarMarkerDataEntityStates
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
