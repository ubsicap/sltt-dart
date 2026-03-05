// ignore_for_file: non_constant_identifier_names

import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/sync_manager.dart';

part 'note_comment_emoji_reacted.entity_state.isar.g.dart';

@JsonSerializable(checked: true, includeIfNull: true, explicitToJson: true)
@Collection()
class IsarNoteCommentEmojiReactedDataEntityState extends BaseEntityState {
  Id id;

  @override
  @Index(unique: true)
  final String entityId;

  @override
  @Index(
    composite: [CompositeIndex('data_parentId'), CompositeIndex('entityId')],
  )
  String get change_domainId => super.change_domainId;

  final String data_emoji;
  final int? data_emoji_dataSchemaRev_;
  final DateTime data_emoji_changeAt_;
  final String? data_emoji_cid_;
  final String data_emoji_changeBy_;
  final DateTime? data_emoji_cloudAt_;

  final String data_commentId;
  final int? data_commentId_dataSchemaRev_;
  final DateTime data_commentId_changeAt_;
  final String? data_commentId_cid_;
  final String data_commentId_changeBy_;
  final DateTime? data_commentId_cloudAt_;

  final String data_noteId;
  final int? data_noteId_dataSchemaRev_;
  final DateTime data_noteId_changeAt_;
  final String? data_noteId_cid_;
  final String data_noteId_changeBy_;
  final DateTime? data_noteId_cloudAt_;

  IsarNoteCommentEmojiReactedDataEntityState({
    super.schemaVersion,
    super.entityType = kEntityTypeCommentReaction,
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
    required this.data_emoji,
    this.data_emoji_dataSchemaRev_,
    required DateTime data_emoji_changeAt_,
    this.data_emoji_cid_,
    required this.data_emoji_changeBy_,
    DateTime? data_emoji_cloudAt_,
    required this.data_commentId,
    this.data_commentId_dataSchemaRev_,
    required DateTime data_commentId_changeAt_,
    this.data_commentId_cid_,
    required this.data_commentId_changeBy_,
    DateTime? data_commentId_cloudAt_,
    required this.data_noteId,
    this.data_noteId_dataSchemaRev_,
    required DateTime data_noteId_changeAt_,
    this.data_noteId_cid_,
    required this.data_noteId_changeBy_,
    DateTime? data_noteId_cloudAt_,
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
  }) : data_emoji_changeAt_ = data_emoji_changeAt_.toUtc(),
       data_emoji_cloudAt_ = data_emoji_cloudAt_?.toUtc(),
       data_commentId_changeAt_ = data_commentId_changeAt_.toUtc(),
       data_commentId_cloudAt_ = data_commentId_cloudAt_?.toUtc(),
       data_noteId_changeAt_ = data_noteId_changeAt_.toUtc(),
       data_noteId_cloudAt_ = data_noteId_cloudAt_?.toUtc();

  static IsarNoteCommentEmojiReactedDataEntityState fromJsonBase(
    Map<String, dynamic> json,
  ) => _$IsarNoteCommentEmojiReactedDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_emoji', () => '');
    j.putIfAbsent('data_commentId', () => '');
    j.putIfAbsent('data_noteId', () => '');
    return j;
  }

  factory IsarNoteCommentEmojiReactedDataEntityState.fromJson(
    Map<String, dynamic> json,
  ) => deserializeWithUnknownFieldData(
    _$IsarNoteCommentEmojiReactedDataEntityStateFromJson,
    json,
    _$IsarNoteCommentEmojiReactedDataEntityStateToJson,
  );

  @override
  Map<String, dynamic> toJson() => serializeWithUnknownFieldData(
    this,
    _$IsarNoteCommentEmojiReactedDataEntityStateToJson,
  );

  @override
  Map<String, dynamic> toJsonBase() =>
      _$IsarNoteCommentEmojiReactedDataEntityStateToJson(this);
}

void registerIsarNoteCommentEmojiReactedDataEntityStateStorageGroup(
  IsarEntityStateStorageRegistry registry,
  Isar isar,
) {
  registry.register(
    IsarEntityStateStorageGroup<IsarNoteCommentEmojiReactedDataEntityState>(
          entityType: EntityType.commentReaction,
          fromJson: IsarNoteCommentEmojiReactedDataEntityState.fromJson,
          put: (state) async => await isar
              .isarNoteCommentEmojiReactedDataEntityStates
              .put(state as IsarNoteCommentEmojiReactedDataEntityState),
          putAll: (states) async =>
              await isar.isarNoteCommentEmojiReactedDataEntityStates.putAll(
                states.cast<IsarNoteCommentEmojiReactedDataEntityState>(),
              ),
          collection: (isar) =>
              isar.isarNoteCommentEmojiReactedDataEntityStates,
          findByDomainAndEntity: (isar, projectId, entityId) => isar
              .isarNoteCommentEmojiReactedDataEntityStates
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
                  var query = isar.isarNoteCommentEmojiReactedDataEntityStates
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

                var query = isar.isarNoteCommentEmojiReactedDataEntityStates
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
          getAllByEntityId: (isar, entityIds) async {
            final results = await isar
                .isarNoteCommentEmojiReactedDataEntityStates
                .getAllByEntityId(entityIds);
            return results
                .whereType<IsarNoteCommentEmojiReactedDataEntityState>()
                .toList();
          },
          deleteByDomain: ({required domainId, required domainType}) async =>
              await isar.isarNoteCommentEmojiReactedDataEntityStates
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
                    ? isar.isarNoteCommentEmojiReactedDataEntityStates
                          .where()
                          .change_domainIdData_parentIdEqualToAnyEntityId(
                            domainId,
                            parentId,
                          )
                          .filter()
                          .change_domainIdEqualTo(domainId)
                    : isar.isarNoteCommentEmojiReactedDataEntityStates
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
