import 'package:isar/isar.dart';
import 'package:sltt_core/sltt_core.dart';

part 'isar_document_state.g.dart';

/// Isar collection for document entity state storage
/// Uses composition instead of inheritance to avoid Isar limitations
@Collection()
class IsarDocumentState {
  Id id = Isar.autoIncrement;

  /// Primary key - entityId with entity type abbreviation
  @Index(unique: true)
  late String entityId;

  /// Immutable - entity type enum (always 'document' for this collection)
  @Enumerated(EnumType.name)
  EntityType entityType = EntityType.document;

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

  /// Document-specific fields with change tracking
  String title = '';
  DateTime? titleChangeAt;
  String titleCid = '';
  String titleChangeBy = '';

  String content = '';
  DateTime? contentChangeAt;
  String contentCid = '';
  String contentChangeBy = '';

  IsarDocumentState();

  /// Update document state from change log entry with conflict resolution
  void updateFromChangeLogEntry({
    required DateTime changeAt,
    required String cid,
    required String changeBy,
    DateTime? cloudAt,
    required Map<String, dynamic> data,
  }) {
    // Update common fields
    this.changeAt = changeAt;
    this.cid = cid;
    this.changeBy = changeBy;
    this.cloudAt = cloudAt;

    // Update document-specific fields with conflict resolution
    if (data.containsKey('title')) {
      _updateDocumentFieldIfNewer(
        'title',
        data['title']?.toString() ?? '',
        changeAt,
        cid,
        changeBy,
      );
    }

    if (data.containsKey('content')) {
      _updateDocumentFieldIfNewer(
        'content',
        data['content']?.toString() ?? '',
        changeAt,
        cid,
        changeBy,
      );
    }

    // Handle common BaseEntityState fields
    if (data.containsKey('rank')) {
      _updateDocumentFieldIfNewer(
        'rank',
        data['rank']?.toString(),
        changeAt,
        cid,
        changeBy,
      );
    }

    if (data.containsKey('parentId')) {
      _updateDocumentFieldIfNewer(
        'parentId',
        data['parentId']?.toString() ?? '',
        changeAt,
        cid,
        changeBy,
      );
    }

    if (data.containsKey('deleted')) {
      final isDeleted = data['deleted'] == true || data['deleted'] == 'true';
      if (deletedChangeAt == null || changeAt.isAfter(deletedChangeAt!)) {
        deleted = isDeleted;
        deletedChangeAt = changeAt;
        deletedCid = cid;
        deletedChangeBy = changeBy;
      }
    }
  }

  /// Helper method to update document fields with conflict resolution
  void _updateDocumentFieldIfNewer(
    String fieldName,
    dynamic value,
    DateTime changeAt,
    String cid,
    String changeBy,
  ) {
    switch (fieldName) {
      case 'title':
        if (titleChangeAt == null || changeAt.isAfter(titleChangeAt!)) {
          title = value?.toString() ?? '';
          titleChangeAt = changeAt;
          titleCid = cid;
          titleChangeBy = changeBy;
        }
        break;
      case 'content':
        if (contentChangeAt == null || changeAt.isAfter(contentChangeAt!)) {
          content = value?.toString() ?? '';
          contentChangeAt = changeAt;
          contentCid = cid;
          contentChangeBy = changeBy;
        }
        break;
      case 'rank':
        if (rankChangeAt == null || changeAt.isAfter(rankChangeAt!)) {
          rank = value?.toString();
          rankChangeAt = changeAt;
          rankCid = cid;
          rankChangeBy = changeBy;
        }
        break;
      case 'parentId':
        if (parentIdChangeAt == null || changeAt.isAfter(parentIdChangeAt!)) {
          parentId = value?.toString() ?? '';
          parentIdChangeAt = changeAt;
          parentIdCid = cid;
          parentIdChangeBy = changeBy;
        }
        break;
    }
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'title': title,
      'titleChangeAt': titleChangeAt?.toIso8601String(),
      'titleCid': titleCid,
      'titleChangeBy': titleChangeBy,
      'content': content,
      'contentChangeAt': contentChangeAt?.toIso8601String(),
      'contentCid': contentCid,
      'contentChangeBy': contentChangeBy,
    };
  }

  /// Create from JSON
  factory IsarDocumentState.fromJson(Map<String, dynamic> json) {
    final state = IsarDocumentState();
    state.id = json['id'] ?? Isar.autoIncrement;
    state.entityId = json['entityId'] ?? '';
    state.entityType = EntityType.document;
    state.rank = json['rank'];
    state.deleted = json['deleted'] ?? false;
    state.parentId = json['parentId'] ?? '';
    state.projectId = json['projectId'] ?? '';
    state.changeAt = json['changeAt'] != null
        ? DateTime.parse(json['changeAt'])
        : null;
    state.cid = json['cid'] ?? '';
    state.cloudAt = json['cloudAt'] != null
        ? DateTime.parse(json['cloudAt'])
        : null;
    state.changeBy = json['changeBy'] ?? '';
    state.origProjectId = json['origProjectId'] ?? '';
    state.origChangeAt = json['origChangeAt'] != null
        ? DateTime.parse(json['origChangeAt'])
        : null;
    state.origChangeBy = json['origChangeBy'] ?? '';
    state.origCid = json['origCid'] ?? '';
    state.origCloudAt = json['origCloudAt'] != null
        ? DateTime.parse(json['origCloudAt'])
        : null;
    state.title = json['title'] ?? '';
    state.titleChangeAt = json['titleChangeAt'] != null
        ? DateTime.parse(json['titleChangeAt'])
        : null;
    state.titleCid = json['titleCid'] ?? '';
    state.titleChangeBy = json['titleChangeBy'] ?? '';
    state.content = json['content'] ?? '';
    state.contentChangeAt = json['contentChangeAt'] != null
        ? DateTime.parse(json['contentChangeAt'])
        : null;
    state.contentCid = json['contentCid'] ?? '';
    state.contentChangeBy = json['contentChangeBy'] ?? '';
    return state;
  }

  @override
  String toString() {
    return 'IsarDocumentState(entityId: $entityId, title: $title, content: $content, deleted: $deleted)';
  }
}
