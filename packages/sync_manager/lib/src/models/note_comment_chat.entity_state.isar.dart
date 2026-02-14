// ignore_for_file: non_constant_identifier_names

import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/sync_manager.dart';

part 'note_comment_chat.entity_state.isar.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
@Collection()
class IsarNoteCommentChatDataEntityState extends BaseEntityState {
  Id id;

  @override
  @Index(unique: true)
  final String entityId;

  final String data_text;
  final int? data_text_dataSchemaRev_;
  final DateTime data_text_changeAt_;
  final String? data_text_cid_;
  final String data_text_changeBy_;
  final DateTime? data_text_cloudAt_;

  final String? data_videoStoredFilename;
  final int? data_videoStoredFilename_dataSchemaRev_;
  final DateTime? data_videoStoredFilename_changeAt_;
  final String? data_videoStoredFilename_cid_;
  final String? data_videoStoredFilename_changeBy_;
  final DateTime? data_videoStoredFilename_cloudAt_;

  final int? data_videoDurationMs;
  final int? data_videoDurationMs_dataSchemaRev_;
  final DateTime? data_videoDurationMs_changeAt_;
  final String? data_videoDurationMs_cid_;
  final String? data_videoDurationMs_changeBy_;
  final DateTime? data_videoDurationMs_cloudAt_;

  final int data_dateMs;
  final int? data_dateMs_dataSchemaRev_;
  final DateTime data_dateMs_changeAt_;
  final String? data_dateMs_cid_;
  final String data_dateMs_changeBy_;
  final DateTime? data_dateMs_cloudAt_;

  final List<String>? data_visibleToUserIds;
  final int? data_visibleToUserIds_dataSchemaRev_;
  final DateTime? data_visibleToUserIds_changeAt_;
  final String? data_visibleToUserIds_cid_;
  final String? data_visibleToUserIds_changeBy_;
  final DateTime? data_visibleToUserIds_cloudAt_;

  final List<String> data_notifiedUserIds;
  final int? data_notifiedUserIds_dataSchemaRev_;
  final DateTime data_notifiedUserIds_changeAt_;
  final String data_notifiedUserIds_cid_;
  final String data_notifiedUserIds_changeBy_;
  final DateTime? data_notifiedUserIds_cloudAt_;

  IsarNoteCommentChatDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypeComment,
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
    required this.data_text,
    this.data_text_dataSchemaRev_,
    required DateTime data_text_changeAt_,
    this.data_text_cid_,
    required this.data_text_changeBy_,
    DateTime? data_text_cloudAt_,
    required this.data_videoStoredFilename,
    this.data_videoStoredFilename_dataSchemaRev_,
    DateTime? data_videoStoredFilename_changeAt_,
    this.data_videoStoredFilename_cid_,
    this.data_videoStoredFilename_changeBy_,
    DateTime? data_videoStoredFilename_cloudAt_,
    this.data_videoDurationMs,
    this.data_videoDurationMs_dataSchemaRev_,
    DateTime? data_videoDurationMs_changeAt_,
    this.data_videoDurationMs_cid_,
    this.data_videoDurationMs_changeBy_,
    DateTime? data_videoDurationMs_cloudAt_,
    required this.data_dateMs,
    this.data_dateMs_dataSchemaRev_,
    required DateTime data_dateMs_changeAt_,
    this.data_dateMs_cid_,
    required this.data_dateMs_changeBy_,
    DateTime? data_dateMs_cloudAt_,
    this.data_visibleToUserIds,
    this.data_visibleToUserIds_dataSchemaRev_,
    DateTime? data_visibleToUserIds_changeAt_,
    this.data_visibleToUserIds_cid_,
    this.data_visibleToUserIds_changeBy_,
    DateTime? data_visibleToUserIds_cloudAt_,
    required this.data_notifiedUserIds,
    this.data_notifiedUserIds_dataSchemaRev_,
    required DateTime data_notifiedUserIds_changeAt_,
    required this.data_notifiedUserIds_cid_,
    required this.data_notifiedUserIds_changeBy_,
    DateTime? data_notifiedUserIds_cloudAt_,
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
  }) : data_text_changeAt_ = data_text_changeAt_.toUtc(),
       data_text_cloudAt_ = data_text_cloudAt_?.toUtc(),
       data_videoStoredFilename_changeAt_ = data_videoStoredFilename_changeAt_
           ?.toUtc(),
       data_videoStoredFilename_cloudAt_ = data_videoStoredFilename_cloudAt_
           ?.toUtc(),
       data_videoDurationMs_changeAt_ = data_videoDurationMs_changeAt_?.toUtc(),
       data_videoDurationMs_cloudAt_ = data_videoDurationMs_cloudAt_?.toUtc(),
       data_dateMs_changeAt_ = data_dateMs_changeAt_.toUtc(),
       data_dateMs_cloudAt_ = data_dateMs_cloudAt_?.toUtc(),
       data_visibleToUserIds_changeAt_ = data_visibleToUserIds_changeAt_
           ?.toUtc(),
       data_visibleToUserIds_cloudAt_ = data_visibleToUserIds_cloudAt_?.toUtc(),
       data_notifiedUserIds_changeAt_ = data_notifiedUserIds_changeAt_.toUtc(),
       data_notifiedUserIds_cloudAt_ = data_notifiedUserIds_cloudAt_?.toUtc();

  static IsarNoteCommentChatDataEntityState fromJsonBase(
    Map<String, dynamic> json,
  ) => _$IsarNoteCommentChatDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_text', () => '');
    j.putIfAbsent('data_videoStoredFilename', () => '');
    j.putIfAbsent('data_videoDurationMs', () => 0);
    j.putIfAbsent('data_dateMs', () => 0);
    j.putIfAbsent('data_notifiedUserIds', () => <String>[]);
    return j;
  }

  factory IsarNoteCommentChatDataEntityState.fromJson(
    Map<String, dynamic> json,
  ) => deserializeWithUnknownFieldData(
    _$IsarNoteCommentChatDataEntityStateFromJson,
    json,
    _$IsarNoteCommentChatDataEntityStateToJson,
  );

  @override
  Map<String, dynamic> toJson() => serializeWithUnknownFieldData(
    this,
    _$IsarNoteCommentChatDataEntityStateToJson,
  );

  @override
  Map<String, dynamic> toJsonBase() =>
      _$IsarNoteCommentChatDataEntityStateToJson(this);
}

void registerIsarNoteCommentChatDataEntityStateStorageGroup(
  IsarEntityStateStorageRegistry registry,
  Isar isar,
) {
  registry.register(
    IsarEntityStateStorageGroup<IsarNoteCommentChatDataEntityState>(
          entityType: EntityType.comment,
          fromJson: IsarNoteCommentChatDataEntityState.fromJson,
          put: (state) async => await isar.isarNoteCommentChatDataEntityStates
              .put(state as IsarNoteCommentChatDataEntityState),
          putAll: (states) async => await isar
              .isarNoteCommentChatDataEntityStates
              .putAll(states.cast<IsarNoteCommentChatDataEntityState>()),
          collection: (isar) => isar.isarNoteCommentChatDataEntityStates,
          findByDomainAndEntity: (isar, projectId, entityId) => isar
              .isarNoteCommentChatDataEntityStates
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
                var query = isar.isarNoteCommentChatDataEntityStates
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
            final results = await isar.isarNoteCommentChatDataEntityStates
                .getAllByEntityId(entityIds);
            return results
                .whereType<IsarNoteCommentChatDataEntityState>()
                .toList();
          },
          deleteByDomain: ({required domainId, required domainType}) async =>
              await isar.isarNoteCommentChatDataEntityStates
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
                var query = isar.isarNoteCommentChatDataEntityStates
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
