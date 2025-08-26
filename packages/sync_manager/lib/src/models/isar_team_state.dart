import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'isar_team_state.g.dart';

/// Isar collection for team entity state storage
/// Uses composition instead of inheritance to avoid Isar limitations
@Collection()
@JsonSerializable(includeIfNull: true, checked: true)
class IsarTeamState {
  Id id = Isar.autoIncrement;

  /// Primary key - entityId with entity type abbreviation
  @Index(unique: true)
  late String entityId;

  /// Immutable - entity type enum (always 'team' for this collection)
  @Enumerated(EnumType.name)
  EntityType entityType = EntityType.team;

  /// Common entity state fields from BaseEntityState (use same names as
  /// BaseEntityState so conversions and serialization line up)
  String? data_rank;

  /// Preserve unknown fields as compact JSON string (keeps parity with
  /// other Isar state models and `deserializeWithUnknownFieldData`).
  String unknownJson = '{}';
  bool? data_deleted = false;
  String data_parentId = '';
  int? data_parentId_dataSchemaRev_;
  DateTime data_parentId_changeAt_ = DateTime.fromMillisecondsSinceEpoch(0);
  String data_parentId_cid_ = '';
  String data_parentId_changeBy_ = '';
  DateTime? data_parentId_cloudAt_;

  DateTime? change_changeAt;
  String change_cid = '';
  DateTime? change_cloudAt;
  String change_changeBy = '';
  String origProjectId = '';
  DateTime? origChangeAt;
  String origChangeBy = '';
  String origCid = '';
  DateTime? origCloudAt;

  /// Change tracking for common fields
  DateTime? data_rank_changeAt_;
  String? data_rank_cid_ = '';
  String? data_rank_changeBy_ = '';
  DateTime? data_rank_cloudAt_;

  DateTime? data_deleted_changeAt_;
  String? data_deleted_cid_ = '';
  String? data_deleted_changeBy_ = '';
  DateTime? data_deleted_cloudAt_;

  DateTime? data_parentId_changeAt_;
  String data_parentId_cid = '';
  String data_parentId_changeBy = '';
  DateTime? data_parentId_cloudAt = null;

  DateTime? data_projectId_changeAt_;
  String data_projectId_cid_ = '';
  String data_projectId_changeBy_ = '';

  /// Team-specific fields with change tracking
  String name = '';
  DateTime? nameChangeAt;
  String nameCid = '';
  String nameChangeBy = '';

  String description = '';
  DateTime? descriptionChangeAt;
  String descriptionCid = '';
  String descriptionChangeBy = '';

  String leadId = '';
  DateTime? leadIdChangeAt;
  String leadIdCid = '';
  String leadIdChangeBy = '';

  String settings = '{}';
  DateTime? settingsChangeAt;
  String settingsCid = '';
  String settingsChangeBy = '';

  IsarTeamState();

  factory IsarTeamState.fromJson(Map<String, dynamic> json) =>
      deserializeWithUnknownFieldData(
        _$IsarTeamStateFromJson,
        json,
        _$IsarTeamStateToJson,
      );

  /// Factory method to create IsarTeamState from BaseEntityState
  factory IsarTeamState.fromBaseState(BaseEntityState base) {
    return IsarTeamState()
      ..entityId = base.entityId
      ..entityType = base.entityType
      ..rank = base.rank
      ..deleted = base.deleted
      ..parentId = base.parentId
      ..projectId = base.projectId
      ..changeAt = base.changeAt
      ..cid = base.cid
      ..cloudAt = base.cloudAt
      ..changeBy = base.changeBy
      ..origProjectId = base.origProjectId
      ..origChangeAt = base.origChangeAt
      ..origChangeBy = base.origChangeBy
      ..origCid = base.origCid
      ..origCloudAt = base.origCloudAt
      ..rankChangeAt = base.rankChangeAt
      ..rankCid = base.rankCid
      ..rankChangeBy = base.rankChangeBy
      ..deletedChangeAt = base.deletedChangeAt
      ..deletedCid = base.deletedCid
      ..deletedChangeBy = base.deletedChangeBy
      ..parentIdChangeAt = base.parentIdChangeAt
      ..parentIdCid = base.parentIdCid
      ..parentIdChangeBy = base.parentIdChangeBy
      ..projectIdChangeAt = base.projectIdChangeAt
      ..projectIdCid = base.projectIdCid
      ..projectIdChangeBy = base.projectIdChangeBy;
  }

  /// Factory method to create IsarTeamState from change log entry
  factory IsarTeamState.fromChangeLogEntry({
    required String entityId,
    required String projectId,
    required DateTime changeAt,
    required String cid,
    required String changeBy,
    DateTime? cloudAt,
    Map<String, dynamic> data = const {},
  }) {
    // Create base state first
    final baseState = BaseEntityState.fromChangeLogEntry(
      entityId: entityId,
      entityType: EntityType.team,
      projectId: projectId,
      changeAt: changeAt,
      cid: cid,
      changeBy: changeBy,
      cloudAt: cloudAt,
      data: data,
    );

    // Create Isar state from base state
    final isarState = IsarTeamState.fromBaseState(baseState);

    // Apply team-specific data
    if (data.containsKey('name')) {
      isarState.name = data['name']?.toString() ?? '';
      isarState.nameChangeAt = changeAt;
      isarState.nameCid = cid;
      isarState.nameChangeBy = changeBy;
    }

    if (data.containsKey('description')) {
      isarState.description = data['description']?.toString() ?? '';
      isarState.descriptionChangeAt = changeAt;
      isarState.descriptionCid = cid;
      isarState.descriptionChangeBy = changeBy;
    }

    if (data.containsKey('leadId')) {
      isarState.leadId = data['leadId']?.toString() ?? '';
      isarState.leadIdChangeAt = changeAt;
      isarState.leadIdCid = cid;
      isarState.leadIdChangeBy = changeBy;
    }

    if (data.containsKey('settings')) {
      isarState.settings = data['settings']?.toString() ?? '{}';
      isarState.settingsChangeAt = changeAt;
      isarState.settingsCid = cid;
      isarState.settingsChangeBy = changeBy;
    }

    return isarState;
  }

  /// Convert to BaseEntityState for backend-agnostic operations
  BaseEntityState toBaseState() {
    final base =
        BaseEntityState(
            entityId: entityId,
            entityType: entityType.value,
            change_domainId: projectId,
            change_changeAt:
                change_changeAt ?? DateTime.fromMillisecondsSinceEpoch(0),
            change_cid: change_cid,
            data_parentId: data_parentId,
            data_parentId_changeAt_:
                data_parentId_changeAt_ ??
                DateTime.fromMillisecondsSinceEpoch(0),
            data_parentId_cid_: data_parentId_cid_,
            data_parentId_changeBy_: data_parentId_changeBy_,
          )
          ..unknownJson = unknownJson
          ..schemaVersion = null
          ..change_cloudAt = change_cloudAt
          ..change_changeBy = change_changeBy
          ..change_dataSchemaRev = null
          ..data_rank = data_rank
          ..data_rank_changeAt_ = data_rank_changeAt_
          ..data_rank_cid_ = data_rank_cid_
          ..data_rank_changeBy_ = data_rank_changeBy_
          ..data_deleted = data_deleted
          ..data_deleted_changeAt_ = data_deleted_changeAt_
          ..data_deleted_cid_ = data_deleted_cid_
          ..data_deleted_changeBy_ = data_deleted_changeBy_
          ..data_deleted_cloudAt_ = data_deleted_cloudAt_;

    return base;
  }

  /// Update team state from change log entry with conflict resolution
  void updateFromChangeLogEntry({
    required DateTime changeAt,
    required String cid,
    required String changeBy,
    DateTime? cloudAt,
    required Map<String, dynamic> data,
  }) {
    // Update common fields using base state logic
    final baseState = toBaseState();
    baseState.updateFromChangeLogEntry(
      changeAt: changeAt,
      cid: cid,
      changeBy: changeBy,
      cloudAt: cloudAt,
      data: data,
    );

    // Copy updated base state fields back
    rank = baseState.rank;
    deleted = baseState.deleted;
    parentId = baseState.parentId;
    projectId = baseState.projectId;
    this.changeAt = baseState.changeAt;
    cid = baseState.cid;
    cloudAt = baseState.cloudAt;
    changeBy = baseState.changeBy;
    rankChangeAt = baseState.rankChangeAt;
    rankCid = baseState.rankCid;
    rankChangeBy = baseState.rankChangeBy;
    deletedChangeAt = baseState.deletedChangeAt;
    deletedCid = baseState.deletedCid;
    deletedChangeBy = baseState.deletedChangeBy;
    parentIdChangeAt = baseState.parentIdChangeAt;
    parentIdCid = baseState.parentIdCid;
    parentIdChangeBy = baseState.parentIdChangeBy;
    projectIdChangeAt = baseState.projectIdChangeAt;
    projectIdCid = baseState.projectIdCid;
    projectIdChangeBy = baseState.projectIdChangeBy;

    // Update team-specific fields with conflict resolution
    if (data.containsKey('name')) {
      _updateTeamFieldIfNewer(
        'name',
        data['name']?.toString() ?? '',
        changeAt,
        cid,
        changeBy,
      );
    }
    if (data.containsKey('description')) {
      _updateTeamFieldIfNewer(
        'description',
        data['description']?.toString() ?? '',
        changeAt,
        cid,
        changeBy,
      );
    }
    if (data.containsKey('leadId')) {
      _updateTeamFieldIfNewer(
        'leadId',
        data['leadId']?.toString() ?? '',
        changeAt,
        cid,
        changeBy,
      );
    }
    if (data.containsKey('settings')) {
      _updateTeamFieldIfNewer(
        'settings',
        data['settings']?.toString() ?? '{}',
        changeAt,
        cid,
        changeBy,
      );
    }
  }

  /// Update a team-specific field only if the change is newer
  void _updateTeamFieldIfNewer(
    String fieldName,
    String value,
    DateTime changeAt,
    String cid,
    String changeBy,
  ) {
    DateTime? currentChangeAt;
    switch (fieldName) {
      case 'name':
        currentChangeAt = nameChangeAt;
        break;
      case 'description':
        currentChangeAt = descriptionChangeAt;
        break;
      case 'leadId':
        currentChangeAt = leadIdChangeAt;
        break;
      case 'settings':
        currentChangeAt = settingsChangeAt;
        break;
    }

    if (currentChangeAt == null || changeAt.isAfter(currentChangeAt)) {
      switch (fieldName) {
        case 'name':
          name = value;
          nameChangeAt = changeAt;
          nameCid = cid;
          nameChangeBy = changeBy;
          break;
        case 'description':
          description = value;
          descriptionChangeAt = changeAt;
          descriptionCid = cid;
          descriptionChangeBy = changeBy;
          break;
        case 'leadId':
          leadId = value;
          leadIdChangeAt = changeAt;
          leadIdCid = cid;
          leadIdChangeBy = changeBy;
          break;
        case 'settings':
          settings = value;
          settingsChangeAt = changeAt;
          settingsCid = cid;
          settingsChangeBy = changeBy;
          break;
      }
    }
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return serializeWithUnknownFieldData(this, _$IsarTeamStateToJson);
  }
}
