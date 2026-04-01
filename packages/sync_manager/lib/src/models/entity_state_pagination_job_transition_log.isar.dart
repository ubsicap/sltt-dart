import 'package:isar_community/isar.dart';

part 'entity_state_pagination_job_transition_log.isar.g.dart';

const entityStatePaginationJobTransitionTypeStatus = 'status';
const entityStatePaginationJobTransitionTypeCursorUpdate = 'cursor_update';

/// Debug-only append-only history of pagination job changes.
@collection
class EntityStatePaginationJobTransitionLogRecord {
  EntityStatePaginationJobTransitionLogRecord({
    this.id = Isar.autoIncrement,
    this.jobRecordId,
    required this.jobKey,
    required this.scopeKey,
    required this.domainType,
    required this.domainId,
    required this.entityType,
    required this.isCollection,
    this.entityId,
    this.parentId,
    this.cursor,
    this.hasMore,
    required this.fromStatus,
    required this.toStatus,
    required this.transitionType,
    required this.transitionAt,
    this.message,
    this.detailsJson,
  });

  Id id;

  int? jobRecordId;

  @Index(composite: [CompositeIndex('transitionAt')])
  String jobKey;

  String scopeKey;
  String domainType;
  String domainId;
  String entityType;
  bool isCollection;
  String? entityId;
  String? parentId;
  String? cursor;
  bool? hasMore;

  @Index()
  String fromStatus;

  @Index()
  String toStatus;

  @Index()
  String transitionType;

  @Index()
  DateTime transitionAt;

  String? message;
  String? detailsJson;
}
