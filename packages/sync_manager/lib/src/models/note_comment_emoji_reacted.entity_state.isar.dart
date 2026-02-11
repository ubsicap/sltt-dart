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

  final String data_emoji;
  final int? data_emoji_dataSchemaRev_;
  final DateTime data_emoji_changeAt_;
  final String? data_emoji_cid_;
  final String data_emoji_changeBy_;
  final DateTime? data_emoji_cloudAt_;

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
       data_emoji_cloudAt_ = data_emoji_cloudAt_?.toUtc();

  static IsarNoteCommentEmojiReactedDataEntityState fromJsonBase(
    Map<String, dynamic> json,
  ) => _$IsarNoteCommentEmojiReactedDataEntityStateFromJson(json);

  Map<String, dynamic> toJsonSafe() {
    final j = toJson();
    j.putIfAbsent('data_emoji', () => '');
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
                var query = isar.isarNoteCommentEmojiReactedDataEntityStates
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
            final results = await isar
                .isarNoteCommentEmojiReactedDataEntityStates
                .getAllByEntityId(entityIds);
            return results
                .whereType<IsarNoteCommentEmojiReactedDataEntityState>()
                .toList();
          },
          deleteByDomain: ({required domainId, required domainType}) async =>
              await isar.isarNoteCommentEmojiReactedDataEntityStates
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
                var query = isar.isarNoteCommentEmojiReactedDataEntityStates
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
