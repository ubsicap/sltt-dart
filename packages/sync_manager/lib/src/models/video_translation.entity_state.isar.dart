// ignore_for_file: non_constant_identifier_names

import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

import 'package:sync_manager/sync_manager.dart';

part 'video_translation.entity_state.isar.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
@Collection()
class IsarVideoDataEntityState extends BaseEntityState {
  Id id;

  @override
  @Index(unique: true)
  final String entityId;

  final String data_name;
  final int? data_name_dataSchemaRev_;
  final DateTime data_name_changeAt_;
  final String? data_name_cid_;
  final String data_name_changeBy_;
  final DateTime? data_name_cloudAt_;

  final String data_storedFilename;
  final int? data_storedFilename_dataSchemaRev_;
  final DateTime data_storedFilename_changeAt_;
  final String? data_storedFilename_cid_;
  final String data_storedFilename_changeBy_;
  final DateTime? data_storedFilename_cloudAt_;

  final List<String> data_visibility;
  final int? data_visibility_dataSchemaRev_;
  final DateTime data_visibility_changeAt_;
  final String data_visibility_cid_;
  final String data_visibility_changeBy_;
  final DateTime? data_visibility_cloudAt_;

  IsarVideoDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypeVideo,
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
    required this.data_name,
    this.data_name_dataSchemaRev_,
    required DateTime data_name_changeAt_,
    this.data_name_cid_,
    required this.data_name_changeBy_,
    DateTime? data_name_cloudAt_,
    required this.data_storedFilename,
    this.data_storedFilename_dataSchemaRev_,
    required DateTime data_storedFilename_changeAt_,
    this.data_storedFilename_cid_,
    required this.data_storedFilename_changeBy_,
    DateTime? data_storedFilename_cloudAt_,
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
       data_storedFilename_changeAt_ = data_storedFilename_changeAt_.toUtc(),
       data_storedFilename_cloudAt_ = data_storedFilename_cloudAt_?.toUtc(),
       data_visibility_changeAt_ = data_visibility_changeAt_.toUtc(),
       data_visibility_cloudAt_ = data_visibility_cloudAt_?.toUtc();

  static IsarVideoDataEntityState fromJsonBase(Map<String, dynamic> json) =>
      _$IsarVideoDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_name', () => '');
    j.putIfAbsent('data_storedFilename', () => '');
    j.putIfAbsent('data_visibility', () => <String>[]);
    return j;
  }

  factory IsarVideoDataEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$IsarVideoDataEntityStateFromJson,
        json,
        _$IsarVideoDataEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$IsarVideoDataEntityStateToJson);

  @override
  Map<String, dynamic> toJsonBase() => _$IsarVideoDataEntityStateToJson(this);
}

void registerIsarVideoDataEntityStateStorageGroup(
  IsarEntityStateStorageRegistry registry,
  Isar isar,
) {
  registry.register(
    IsarEntityStateStorageGroup<IsarVideoDataEntityState>(
          entityType: EntityType.video,
          fromJson: IsarVideoDataEntityState.fromJson,
          put: (state) async => await isar.isarVideoDataEntityStates.put(
            state as IsarVideoDataEntityState,
          ),
          putAll: (states) async => await isar.isarVideoDataEntityStates.putAll(
            states.cast<IsarVideoDataEntityState>(),
          ),
          collection: (isar) => isar.isarVideoDataEntityStates,
          findByDomainAndEntity: (isar, projectId, entityId) => isar
              .isarVideoDataEntityStates
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
                var query = isar.isarVideoDataEntityStates
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
            final results = await isar.isarVideoDataEntityStates
                .getAllByEntityId(entityIds);
            return results.whereType<IsarVideoDataEntityState>().toList();
          },
          deleteByDomain: ({required domainId, required domainType}) async =>
              await isar.isarVideoDataEntityStates
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
                var query = isar.isarVideoDataEntityStates
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
