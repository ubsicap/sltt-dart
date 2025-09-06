// No imports required currently.

/// Annotation used on a data class to generate a corresponding `*EntityState`
/// implementation that extends/implements `BaseEntityState`.
///
/// Example:
/// ```dart
/// @SyncableEntityStateData(entityType: 'task')
/// class TaskData implements CoreSyncableEntityDataFields {
///   final String parentId;
///   final String nameLocal;
///   final String? rank; // optional
///   final bool? deleted; // optional
///   const TaskData({required this.parentId, required this.nameLocal, this.rank, this.deleted});
/// }
/// ```
/// This will generate a `TaskDataEntityState` with fields:
/// - change_* for change log metadata (mirroring ChangeLogEntry fields)
/// - data_<field> plus data_<field>_<meta>_ markers and data_<field>_orig_
///
/// Additional meta markers (per BaseEntityState conventions):
/// - `<field>_changeAt_`, `<field>_cid_`, `<field>_changeBy_`, `<field>_cloudAt_`
/// - `<field>_dataSchemaRev_` where applicable
/// Used to mark a data class for which an `*EntityState` companion
/// should be generated.
class SyncableEntityStateData {
  final String? entityTypeOverride;

  /// If true (default) treat data fields as required when generating toJsonSafe().
  final bool jsonRequired;

  /// If true (default) include nulls in normal toJson().
  final bool includeIfNull;

  /// If true (default) validate data field types against a conservative Isar-compatible set.
  final bool enforceIsarCompatibility;
  const SyncableEntityStateData({
    this.entityTypeOverride,
    this.jsonRequired = true,
    this.includeIfNull = true,
    this.enforceIsarCompatibility = true,
  });
}

/// Core interface required for annotated data classes.
/// The generator will assume these fields exist (directly or via getters).
abstract class CoreSyncableEntityDataFields {
  String get parentId;
  bool? get deleted; // nullable for soft-delete semantics
  String? get rank; // padded rank string, nullable if not ranked yet
}
