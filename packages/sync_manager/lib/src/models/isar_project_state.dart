import 'package:isar/isar.dart';
import 'package:sltt_core/sltt_core.dart';

part 'isar_project_state.g.dart';

/// Isar collection for project entity state storage
/// Uses composition instead of inheritance to avoid Isar limitations
@Collection()
class IsarProjectState {
  Id id = Isar.autoIncrement;

  /// Primary key - entityId with entity type abbreviation
  @Index(unique: true)
  late String entityId;

  /// Immutable - entity type enum (always 'project' for this collection)
  @Enumerated(EnumType.name)
  EntityType entityType = EntityType.project;

  /// Common entity state fields from BaseEntityState
  String? rank;
  bool deleted = false;
  String parentId = '';
  String projectId = '';
  DateTime? changeAt;
  String cid = '';
  DateTime? cloudAt;
  String changeBy = '';
  String origProjectId = '';
  DateTime? origChangeAt;
  String origChangeBy = '';
  String origCid = '';
  DateTime? origCloudAt;

  /// Change tracking for common fields
  DateTime? rankChangeAt;
  String rankCid = '';
  String rankChangeBy = '';
  DateTime? deletedChangeAt;
  String deletedCid = '';
  String deletedChangeBy = '';
  DateTime? parentIdChangeAt;
  String parentIdCid = '';
  String parentIdChangeBy = '';
  DateTime? projectIdChangeAt;
  String projectIdCid = '';
  String projectIdChangeBy = '';

  /// Project-specific fields with change tracking
  String name = '';
  DateTime? nameChangeAt;
  String nameCid = '';
  String nameChangeBy = '';

  String description = '';
  DateTime? descriptionChangeAt;
  String descriptionCid = '';
  String descriptionChangeBy = '';

  @Enumerated(EnumType.name)
  Status status = Status.draft;
  DateTime? statusChangeAt;
  String statusCid = '';
  String statusChangeBy = '';

  @Enumerated(EnumType.name)
  Priority priority = Priority.medium;
  DateTime? priorityChangeAt;
  String priorityCid = '';
  String priorityChangeBy = '';

  String leadId = '';
  DateTime? leadIdChangeAt;
  String leadIdCid = '';
  String leadIdChangeBy = '';

  DateTime? dueDate;
  DateTime? dueDateChangeAt;
  String dueDateCid = '';
  String dueDateChangeBy = '';

  String settings = '{}';
  DateTime? settingsChangeAt;
  String settingsCid = '';
  String settingsChangeBy = '';

  IsarProjectState();

  /// Factory method to create IsarProjectState from BaseEntityState
  factory IsarProjectState.fromBaseState(BaseEntityState base) {
    return IsarProjectState()
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

  /// Factory method to create IsarProjectState from change log entry
  factory IsarProjectState.fromChangeLogEntry({
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
      entityType: EntityType.project,
      projectId: projectId,
      changeAt: changeAt,
      cid: cid,
      changeBy: changeBy,
      cloudAt: cloudAt,
      data: data,
    );

    // Create Isar state from base state
    final isarState = IsarProjectState.fromBaseState(baseState);

    // Apply project-specific data
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

    if (data.containsKey('status')) {
      final statusStr = data['status']?.toString() ?? 'draft';
      isarState.status = Status.values.firstWhere(
        (s) => s.value == statusStr,
        orElse: () => Status.draft,
      );
      isarState.statusChangeAt = changeAt;
      isarState.statusCid = cid;
      isarState.statusChangeBy = changeBy;
    }

    if (data.containsKey('priority')) {
      final priorityStr = data['priority']?.toString() ?? 'medium';
      isarState.priority = Priority.values.firstWhere(
        (p) => p.value == priorityStr,
        orElse: () => Priority.medium,
      );
      isarState.priorityChangeAt = changeAt;
      isarState.priorityCid = cid;
      isarState.priorityChangeBy = changeBy;
    }

    if (data.containsKey('leadId')) {
      isarState.leadId = data['leadId']?.toString() ?? '';
      isarState.leadIdChangeAt = changeAt;
      isarState.leadIdCid = cid;
      isarState.leadIdChangeBy = changeBy;
    }

    if (data.containsKey('dueDate')) {
      final dueDateStr = data['dueDate']?.toString();
      if (dueDateStr != null && dueDateStr.isNotEmpty) {
        isarState.dueDate = DateTime.tryParse(dueDateStr);
      }
      isarState.dueDateChangeAt = changeAt;
      isarState.dueDateCid = cid;
      isarState.dueDateChangeBy = changeBy;
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
    final base = BaseEntityState()
      ..id = id
      ..entityId = entityId
      ..entityType = entityType
      ..rank = rank
      ..deleted = deleted
      ..parentId = parentId
      ..projectId = projectId
      ..changeAt = changeAt
      ..cid = cid
      ..cloudAt = cloudAt
      ..changeBy = changeBy
      ..origProjectId = origProjectId
      ..origChangeAt = origChangeAt
      ..origChangeBy = origChangeBy
      ..origCid = origCid
      ..origCloudAt = origCloudAt
      ..rankChangeAt = rankChangeAt
      ..rankCid = rankCid
      ..rankChangeBy = rankChangeBy
      ..deletedChangeAt = deletedChangeAt
      ..deletedCid = deletedCid
      ..deletedChangeBy = deletedChangeBy
      ..parentIdChangeAt = parentIdChangeAt
      ..parentIdCid = parentIdCid
      ..parentIdChangeBy = parentIdChangeBy
      ..projectIdChangeAt = projectIdChangeAt
      ..projectIdCid = projectIdCid
      ..projectIdChangeBy = projectIdChangeBy;

    return base;
  }

  /// Update project state from change log entry with conflict resolution
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
    // NOTE: Don't overwrite changeBy - keep the original parameter value for project-specific updates
    // changeBy = baseState.changeBy;  // <- This was causing the bug
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

    // Update project-specific fields with conflict resolution
    if (data.containsKey('name')) {
      _updateProjectFieldIfNewer(
        'name',
        data['name']?.toString() ?? '',
        changeAt,
        cid,
        changeBy,
      );
    }
    if (data.containsKey('description')) {
      _updateProjectFieldIfNewer(
        'description',
        data['description']?.toString() ?? '',
        changeAt,
        cid,
        changeBy,
      );
    }
    if (data.containsKey('status')) {
      _updateProjectFieldIfNewer(
        'status',
        data['status']?.toString() ?? 'draft',
        changeAt,
        cid,
        changeBy,
      );
    }
    if (data.containsKey('priority')) {
      _updateProjectFieldIfNewer(
        'priority',
        data['priority']?.toString() ?? 'medium',
        changeAt,
        cid,
        changeBy,
      );
    }
    if (data.containsKey('leadId')) {
      _updateProjectFieldIfNewer(
        'leadId',
        data['leadId']?.toString() ?? '',
        changeAt,
        cid,
        changeBy,
      );
    }
    if (data.containsKey('dueDate')) {
      _updateProjectFieldIfNewer(
        'dueDate',
        data['dueDate']?.toString() ?? '',
        changeAt,
        cid,
        changeBy,
      );
    }
    if (data.containsKey('settings')) {
      _updateProjectFieldIfNewer(
        'settings',
        data['settings']?.toString() ?? '{}',
        changeAt,
        cid,
        changeBy,
      );
    }
  }

  /// Update a project-specific field only if the change is newer
  void _updateProjectFieldIfNewer(
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
      case 'status':
        currentChangeAt = statusChangeAt;
        break;
      case 'priority':
        currentChangeAt = priorityChangeAt;
        break;
      case 'leadId':
        currentChangeAt = leadIdChangeAt;
        break;
      case 'dueDate':
        currentChangeAt = dueDateChangeAt;
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
        case 'status':
          status = Status.values.firstWhere(
            (s) => s.value == value,
            orElse: () => Status.draft,
          );
          statusChangeAt = changeAt;
          statusCid = cid;
          statusChangeBy = changeBy;
          break;
        case 'priority':
          priority = Priority.values.firstWhere(
            (p) => p.value == value,
            orElse: () => Priority.medium,
          );
          priorityChangeAt = changeAt;
          priorityCid = cid;
          priorityChangeBy = changeBy;
          break;
        case 'leadId':
          leadId = value;
          leadIdChangeAt = changeAt;
          leadIdCid = cid;
          leadIdChangeBy = changeBy;
          break;
        case 'dueDate':
          if (value.isNotEmpty) {
            dueDate = DateTime.tryParse(value);
          } else {
            dueDate = null;
          }
          dueDateChangeAt = changeAt;
          dueDateCid = cid;
          dueDateChangeBy = changeBy;
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
      'name': name,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'leadId': leadId,
      'dueDate': dueDate?.toIso8601String(),
      'settings': settings,
    };
  }
}
