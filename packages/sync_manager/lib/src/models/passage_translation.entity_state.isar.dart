// using portion_translation.entity_state.isar.dart as an exemplar
// do the same for passage_translation.dart as it does for portion_translation.dart
// ignore_for_file: non_constant_identifier_names

import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/sync_manager.dart';

part 'passage_translation.entity_state.isar.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
@Collection()
class IsarPassageDataEntityState extends BaseEntityState {
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

  // data fields (mirror of PassageTranslationData)
  final String data_name;
  final int? data_name_dataSchemaRev_;
  final DateTime data_name_changeAt_;
  final String? data_name_cid_;
  final String data_name_changeBy_;
  final DateTime? data_name_cloudAt_;

  final List<String> data_visibility;
  final int? data_visibility_dataSchemaRev_;
  final DateTime data_visibility_changeAt_;
  final String data_visibility_cid_;
  final String data_visibility_changeBy_;
  final DateTime? data_visibility_cloudAt_;

  final String data_type;
  final int? data_type_dataSchemaRev_;
  final DateTime data_type_changeAt_;
  final String data_type_cid_;
  final String data_type_changeBy_;
  final DateTime? data_type_cloudAt_;

  final String data_difficulty;
  final int? data_difficulty_dataSchemaRev_;
  final DateTime data_difficulty_changeAt_;
  final String data_difficulty_cid_;
  final String data_difficulty_changeBy_;
  final DateTime? data_difficulty_cloudAt_;

  final List<String> data_references;
  final int? data_references_dataSchemaRev_;
  final DateTime data_references_changeAt_;
  final String data_references_cid_;
  final String data_references_changeBy_;
  final DateTime? data_references_cloudAt_;

  final List<String> data_tags;
  final int? data_tags_dataSchemaRev_;
  final DateTime data_tags_changeAt_;
  final String data_tags_cid_;
  final String data_tags_changeBy_;
  final DateTime? data_tags_cloudAt_;

  final bool data_includeInStatistics;
  final int? data_includeInStatistics_dataSchemaRev_;
  final DateTime data_includeInStatistics_changeAt_;
  final String data_includeInStatistics_cid_;
  final String data_includeInStatistics_changeBy_;
  final DateTime? data_includeInStatistics_cloudAt_;

  IsarPassageDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypePassage,
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
    required this.data_type,
    this.data_type_dataSchemaRev_,
    required DateTime data_type_changeAt_,
    required this.data_type_cid_,
    required this.data_type_changeBy_,
    DateTime? data_type_cloudAt_,
    required this.data_difficulty,
    this.data_difficulty_dataSchemaRev_,
    required DateTime data_difficulty_changeAt_,
    required this.data_difficulty_cid_,
    required this.data_difficulty_changeBy_,
    DateTime? data_difficulty_cloudAt_,
    required this.data_references,
    this.data_references_dataSchemaRev_,
    required DateTime data_references_changeAt_,
    required this.data_references_cid_,
    required this.data_references_changeBy_,
    DateTime? data_references_cloudAt_,
    required this.data_tags,
    this.data_tags_dataSchemaRev_,
    required DateTime data_tags_changeAt_,
    required this.data_tags_cid_,
    required this.data_tags_changeBy_,
    DateTime? data_tags_cloudAt_,

    required this.data_includeInStatistics,
    this.data_includeInStatistics_dataSchemaRev_,
    required DateTime data_includeInStatistics_changeAt_,
    required this.data_includeInStatistics_cid_,
    required this.data_includeInStatistics_changeBy_,
    DateTime? data_includeInStatistics_cloudAt_,

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
       data_visibility_cloudAt_ = data_visibility_cloudAt_?.toUtc(),
       data_type_changeAt_ = data_type_changeAt_.toUtc(),
       data_type_cloudAt_ = data_type_cloudAt_?.toUtc(),
       data_difficulty_changeAt_ = data_difficulty_changeAt_.toUtc(),
       data_difficulty_cloudAt_ = data_difficulty_cloudAt_?.toUtc(),
       data_references_changeAt_ = data_references_changeAt_.toUtc(),
       data_references_cloudAt_ = data_references_cloudAt_?.toUtc(),
       data_tags_changeAt_ = data_tags_changeAt_.toUtc(),
       data_tags_cloudAt_ = data_tags_cloudAt_?.toUtc(),
       data_includeInStatistics_changeAt_ = data_includeInStatistics_changeAt_
           .toUtc(),
       data_includeInStatistics_cloudAt_ = data_includeInStatistics_cloudAt_
           ?.toUtc();

  static IsarPassageDataEntityState fromJsonBase(Map<String, dynamic> json) =>
      _$IsarPassageDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_name', () => '');
    j.putIfAbsent('data_visibility', () => '');
    return j;
  }

  factory IsarPassageDataEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$IsarPassageDataEntityStateFromJson,
        json,
        _$IsarPassageDataEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$IsarPassageDataEntityStateToJson);

  @override
  Map<String, dynamic> toJsonBase() => _$IsarPassageDataEntityStateToJson(this);
}

void registerIsarPassageDataEntityStateStorageGroup(
  IsarEntityStateStorageRegistry registry,
  Isar isar,
) {
  registry.register(
    IsarEntityStateStorageGroup<IsarPassageDataEntityState>(
          entityType: EntityType.passage,
          fromJson: IsarPassageDataEntityState.fromJson,
          put: (state) async =>
              // ignore: experimental_member_use
              await isar.isarPassageDataEntityStates.putByIndex(
                r'change_domainId_entityId',
                state as IsarPassageDataEntityState,
              ),
          putAll: (states) async =>
              // ignore: experimental_member_use
              await isar.isarPassageDataEntityStates.putAllByIndex(
                r'change_domainId_entityId',
                states.cast<IsarPassageDataEntityState>(),
              ),
          collection: (isar) => isar.isarPassageDataEntityStates,
          findByDomainAndEntity: (isar, projectId, entityId) => isar
              .isarPassageDataEntityStates
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
                  var query = isar.isarPassageDataEntityStates
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

                var query = isar.isarPassageDataEntityStates
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
                final results = await isar.isarPassageDataEntityStates
                    .getAllByChange_domainIdEntityId(domainIds, entityIds);
                return results.whereType<IsarPassageDataEntityState>().toList();
              },
          deleteByDomain: ({required domainId, required domainType}) async =>
              await isar.isarPassageDataEntityStates
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
                    ? isar.isarPassageDataEntityStates
                          .where()
                          .change_domainIdData_parentIdEqualToAnyEntityId(
                            domainId,
                            parentId,
                          )
                          .filter()
                          .change_domainIdEqualTo(domainId)
                    : isar.isarPassageDataEntityStates
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
