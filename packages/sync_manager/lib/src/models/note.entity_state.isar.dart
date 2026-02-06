// using portion_translation.entity_state.isar.dart as an exemplar
// ignore_for_file: non_constant_identifier_names

import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/sync_manager.dart';

part 'note.entity_state.isar.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
@Collection()
class IsarNoteDataEntityState extends BaseEntityState {
  Id id;

  @override
  @Index(unique: true)
  final String entityId;

  // data fields (mirror of NoteData)
  final String data_title;
  final int? data_title_dataSchemaRev_;
  final DateTime data_title_changeAt_;
  final String? data_title_cid_;
  final String data_title_changeBy_;
  final DateTime? data_title_cloudAt_;

  final String? data_videoCommentId;
  final int? data_videoCommentId_dataSchemaRev_;
  final DateTime? data_videoCommentId_changeAt_;
  final String? data_videoCommentId_cid_;
  final String? data_videoCommentId_changeBy_;
  final DateTime? data_videoCommentId_cloudAt_;

  final String? data_textComment;
  final int? data_textComment_dataSchemaRev_;
  final DateTime? data_textComment_changeAt_;
  final String? data_textComment_cid_;
  final String? data_textComment_changeBy_;
  final DateTime? data_textComment_cloudAt_;

  final String? data_videoCommentStoredFilename;
  final int? data_videoCommentStoredFilename_dataSchemaRev_;
  final DateTime? data_videoCommentStoredFilename_changeAt_;
  final String? data_videoCommentStoredFilename_cid_;
  final String? data_videoCommentStoredFilename_changeBy_;
  final DateTime? data_videoCommentStoredFilename_cloudAt_;

  final int? data_videoCommentDurationMs;
  final int? data_videoCommentDurationMs_dataSchemaRev_;
  final DateTime? data_videoCommentDurationMs_changeAt_;
  final String? data_videoCommentDurationMs_cid_;
  final String? data_videoCommentDurationMs_changeBy_;
  final DateTime? data_videoCommentDurationMs_cloudAt_;

  final String data_markerId;
  final int? data_markerId_dataSchemaRev_;
  final DateTime data_markerId_changeAt_;
  final String? data_markerId_cid_;
  final String data_markerId_changeBy_;
  final DateTime? data_markerId_cloudAt_;

  final int data_positionMs;
  final int? data_positionMs_dataSchemaRev_;
  final DateTime data_positionMs_changeAt_;
  final String? data_positionMs_cid_;
  final String data_positionMs_changeBy_;
  final DateTime? data_positionMs_cloudAt_;

  final String data_resolution;
  final int? data_resolution_dataSchemaRev_;
  final DateTime data_resolution_changeAt_;
  final String? data_resolution_cid_;
  final String data_resolution_changeBy_;
  final DateTime? data_resolution_cloudAt_;

  IsarNoteDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypeNote,
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
    required this.data_title,
    this.data_title_dataSchemaRev_,
    required DateTime data_title_changeAt_,
    this.data_title_cid_,
    required this.data_title_changeBy_,
    DateTime? data_title_cloudAt_,
    this.data_videoCommentId,
    this.data_videoCommentId_dataSchemaRev_,
    DateTime? data_videoCommentId_changeAt_,
    this.data_videoCommentId_cid_,
    this.data_videoCommentId_changeBy_,
    DateTime? data_videoCommentId_cloudAt_,
    this.data_videoCommentStoredFilename,
    this.data_videoCommentStoredFilename_dataSchemaRev_,
    DateTime? data_videoCommentStoredFilename_changeAt_,
    this.data_videoCommentStoredFilename_cid_,
    this.data_videoCommentStoredFilename_changeBy_,
    DateTime? data_videoCommentStoredFilename_cloudAt_,
    this.data_videoCommentDurationMs,
    this.data_videoCommentDurationMs_dataSchemaRev_,
    DateTime? data_videoCommentDurationMs_changeAt_,
    this.data_videoCommentDurationMs_cid_,
    this.data_videoCommentDurationMs_changeBy_,
    DateTime? data_videoCommentDurationMs_cloudAt_,
    this.data_textComment,
    this.data_textComment_dataSchemaRev_,
    DateTime? data_textComment_changeAt_,
    this.data_textComment_cid_,
    this.data_textComment_changeBy_,
    DateTime? data_textComment_cloudAt_,
    required this.data_markerId,
    this.data_markerId_dataSchemaRev_,
    required DateTime data_markerId_changeAt_,
    this.data_markerId_cid_,
    required this.data_markerId_changeBy_,
    DateTime? data_markerId_cloudAt_,
    required this.data_positionMs,
    this.data_positionMs_dataSchemaRev_,
    required DateTime data_positionMs_changeAt_,
    this.data_positionMs_cid_,
    required this.data_positionMs_changeBy_,
    DateTime? data_positionMs_cloudAt_,
    required this.data_resolution,
    this.data_resolution_dataSchemaRev_,
    required DateTime data_resolution_changeAt_,
    this.data_resolution_cid_,
    required this.data_resolution_changeBy_,
    DateTime? data_resolution_cloudAt_,
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
  }) : data_title_changeAt_ = data_title_changeAt_.toUtc(),
       data_title_cloudAt_ = data_title_cloudAt_?.toUtc(),
       data_videoCommentId_changeAt_ = data_videoCommentId_changeAt_?.toUtc(),
       data_videoCommentId_cloudAt_ = data_videoCommentId_cloudAt_?.toUtc(),
       data_videoCommentStoredFilename_changeAt_ =
           data_videoCommentStoredFilename_changeAt_?.toUtc(),
       data_videoCommentStoredFilename_cloudAt_ =
           data_videoCommentStoredFilename_cloudAt_?.toUtc(),
       data_videoCommentDurationMs_changeAt_ =
           data_videoCommentDurationMs_changeAt_?.toUtc(),
       data_videoCommentDurationMs_cloudAt_ =
           data_videoCommentDurationMs_cloudAt_?.toUtc(),
       data_textComment_changeAt_ = data_textComment_changeAt_?.toUtc(),
       data_textComment_cloudAt_ = data_textComment_cloudAt_?.toUtc(),
       data_markerId_changeAt_ = data_markerId_changeAt_.toUtc(),
       data_markerId_cloudAt_ = data_markerId_cloudAt_?.toUtc(),
       data_positionMs_changeAt_ = data_positionMs_changeAt_.toUtc(),
       data_positionMs_cloudAt_ = data_positionMs_cloudAt_?.toUtc(),
       data_resolution_changeAt_ = data_resolution_changeAt_.toUtc(),
       data_resolution_cloudAt_ = data_resolution_cloudAt_?.toUtc();

  static IsarNoteDataEntityState fromJsonBase(Map<String, dynamic> json) =>
      _$IsarNoteDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_title', () => '');
    j.putIfAbsent('data_markerId', () => '');
    j.putIfAbsent('data_positionMs', () => 0);
    j.putIfAbsent('data_resolution', () => '');
    return j;
  }

  factory IsarNoteDataEntityState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$IsarNoteDataEntityStateFromJson,
        json,
        _$IsarNoteDataEntityStateToJson,
      );

  @override
  Map<String, dynamic> toJson() =>
      serializeWithUnknownFieldData(this, _$IsarNoteDataEntityStateToJson);

  @override
  Map<String, dynamic> toJsonBase() => _$IsarNoteDataEntityStateToJson(this);
}

void registerIsarNoteDataEntityStateStorageGroup(
  IsarEntityStateStorageRegistry registry,
  Isar isar,
) {
  registry.register(
    IsarEntityStateStorageGroup<IsarNoteDataEntityState>(
          entityType: EntityType.note,
          fromJson: IsarNoteDataEntityState.fromJson,
          put: (state) async => await isar.isarNoteDataEntityStates.put(
            state as IsarNoteDataEntityState,
          ),
          putAll: (states) async => await isar.isarNoteDataEntityStates.putAll(
            states.cast<IsarNoteDataEntityState>(),
          ),
          collection: (isar) => isar.isarNoteDataEntityStates,
          findByDomainAndEntity: (isar, projectId, entityId) => isar
              .isarNoteDataEntityStates
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
                var query = isar.isarNoteDataEntityStates
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
            final results = await isar.isarNoteDataEntityStates
                .getAllByEntityId(entityIds);
            return results.whereType<IsarNoteDataEntityState>().toList();
          },
          deleteByDomain: ({required domainId, required domainType}) async =>
              await isar.isarNoteDataEntityStates
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
                var query = isar.isarNoteDataEntityStates
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
