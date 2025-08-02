import 'entity_type.dart';

/// Base class for entity state storage with common metadata
/// This provides the core state schema common across all entity types
/// Backend-agnostic - no database-specific dependencies
class BaseEntityState {
  /// Database ID (implementation-specific)
  int? id;

  /// Primary key - entityId with entity type abbreviation
  late String entityId;

  /// Immutable - entity type enum
  late EntityType entityType;

  /// Mutable fields with conflict resolution support
  String? rank; // Used to sort in parent

  bool deleted = false; // Deletion status

  String parentId = ''; // Points to parent entity

  String projectId = ''; // Current project ID

  DateTime? changeAt; // Latest change timestamp

  String cid = ''; // Latest change ID

  DateTime? cloudAt; // Latest cloud timestamp

  String changeBy = ''; // Latest change author

  /// Original (first) values for tracking entity creation
  String origProjectId = ''; // Original project ID

  DateTime? origChangeAt; // First change timestamp

  String origChangeBy = ''; // First change author

  String origCid = ''; // First change ID

  DateTime? origCloudAt; // First cloud timestamp

  /// Change tracking fields for conflict resolution
  /// Each mutable field has corresponding changeAt, cid, and changeBy fields

  // rank field tracking
  DateTime? rankChangeAt;
  String rankCid = '';
  String rankChangeBy = '';

  // deleted field tracking
  DateTime? deletedChangeAt;
  String deletedCid = '';
  String deletedChangeBy = '';

  // parentId field tracking
  DateTime? parentIdChangeAt;
  String parentIdCid = '';
  String parentIdChangeBy = '';

  // projectId field tracking
  DateTime? projectIdChangeAt;
  String projectIdCid = '';
  String projectIdChangeBy = '';

  BaseEntityState();

  /// Factory method to create BaseEntityState from change log entry
  factory BaseEntityState.fromChangeLogEntry({
    required String entityId,
    required EntityType entityType,
    required String projectId,
    required DateTime changeAt,
    required String cid,
    required String changeBy,
    DateTime? cloudAt,
    Map<String, dynamic> data = const {},
  }) {
    final state = BaseEntityState()
      ..entityId = entityId
      ..entityType = entityType
      ..projectId = projectId
      ..changeAt = changeAt
      ..cid = cid
      ..changeBy = changeBy
      ..cloudAt = cloudAt
      ..origProjectId = projectId
      ..origChangeAt = changeAt
      ..origChangeBy = changeBy
      ..origCid = cid
      ..origCloudAt = cloudAt;

    // Set initial change tracking for all fields
    state
      ..projectIdChangeAt = changeAt
      ..projectIdCid = cid
      ..projectIdChangeBy = changeBy;

    // Apply data from change log entry
    if (data.containsKey('rank')) {
      state.rank = data['rank']?.toString();
      state.rankChangeAt = changeAt;
      state.rankCid = cid;
      state.rankChangeBy = changeBy;
    }

    if (data.containsKey('deleted')) {
      state.deleted = data['deleted'] == true;
      state.deletedChangeAt = changeAt;
      state.deletedCid = cid;
      state.deletedChangeBy = changeBy;
    }

    if (data.containsKey('parentId')) {
      state.parentId = data['parentId']?.toString() ?? '';
      state.parentIdChangeAt = changeAt;
      state.parentIdCid = cid;
      state.parentIdChangeBy = changeBy;
    }

    return state;
  }

  /// Update state from change log entry with conflict resolution
  void updateFromChangeLogEntry({
    required DateTime changeAt,
    required String cid,
    required String changeBy,
    DateTime? cloudAt,
    required Map<String, dynamic> data,
  }) {
    // Update latest change metadata
    if (this.changeAt == null || changeAt.isAfter(this.changeAt!)) {
      this.changeAt = changeAt;
      this.cid = cid;
      this.changeBy = changeBy;
      this.cloudAt = cloudAt;
    }

    // Update individual fields with conflict resolution
    _updateFieldIfNewer(
      'rank',
      data['rank']?.toString(),
      changeAt,
      cid,
      changeBy,
    );
    _updateFieldIfNewer(
      'deleted',
      data['deleted'] == true,
      changeAt,
      cid,
      changeBy,
    );
    _updateFieldIfNewer(
      'parentId',
      data['parentId']?.toString() ?? '',
      changeAt,
      cid,
      changeBy,
    );
    _updateFieldIfNewer(
      'projectId',
      data['projectId']?.toString() ?? projectId,
      changeAt,
      cid,
      changeBy,
    );
  }

  /// Update a field only if the change is newer than the current field's change
  void _updateFieldIfNewer(
    String fieldName,
    dynamic value,
    DateTime changeAt,
    String cid,
    String changeBy,
  ) {
    DateTime? currentChangeAt;
    switch (fieldName) {
      case 'rank':
        currentChangeAt = rankChangeAt;
        break;
      case 'deleted':
        currentChangeAt = deletedChangeAt;
        break;
      case 'parentId':
        currentChangeAt = parentIdChangeAt;
        break;
      case 'projectId':
        currentChangeAt = projectIdChangeAt;
        break;
    }

    if (currentChangeAt == null || changeAt.isAfter(currentChangeAt)) {
      switch (fieldName) {
        case 'rank':
          rank = value?.toString();
          rankChangeAt = changeAt;
          rankCid = cid;
          rankChangeBy = changeBy;
          break;
        case 'deleted':
          deleted = value == true;
          deletedChangeAt = changeAt;
          deletedCid = cid;
          deletedChangeBy = changeBy;
          break;
        case 'parentId':
          parentId = value?.toString() ?? '';
          parentIdChangeAt = changeAt;
          parentIdCid = cid;
          parentIdChangeBy = changeBy;
          break;
        case 'projectId':
          projectId = value?.toString() ?? projectId;
          projectIdChangeAt = changeAt;
          projectIdCid = cid;
          projectIdChangeBy = changeBy;
          break;
      }
    }
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'entityId': entityId,
      'entityType': entityType.value,
      'rank': rank,
      'deleted': deleted,
      'parentId': parentId,
      'projectId': projectId,
      'changeAt': changeAt?.toIso8601String(),
      'cid': cid,
      'cloudAt': cloudAt?.toIso8601String(),
      'changeBy': changeBy,
      'origProjectId': origProjectId,
      'origChangeAt': origChangeAt?.toIso8601String(),
      'origChangeBy': origChangeBy,
      'origCid': origCid,
      'origCloudAt': origCloudAt?.toIso8601String(),
    };
  }
}
