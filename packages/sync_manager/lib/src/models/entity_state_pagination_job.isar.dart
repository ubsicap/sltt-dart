import 'package:isar_community/isar.dart';

part 'entity_state_pagination_job.isar.g.dart';

const entityStatePaginationJobStatusQueued = 'queued';
const entityStatePaginationJobStatusActive = 'active';
const entityStatePaginationJobStatusFetched = 'fetched';
const entityStatePaginationJobStatusCompleted = 'completed';
const entityStatePaginationJobStatusFailed = 'failed';
const entityStatePaginationJobStatusStorageFailed = 'storage_failed';

@collection
class EntityStatePaginationJobRecord {
  EntityStatePaginationJobRecord({
    this.id = Isar.autoIncrement,
    required this.jobKey,
    required this.scopeKey,
    required this.domainType,
    required this.domainId,
    required this.entityType,
    required this.isCollection,
    required this.status,
    required this.priority,
    required this.enqueuedAt,
    this.entityId,
    this.parentId,
    this.limit,
    this.cursor,
    this.startedAt,
    this.fetchedAt,
    this.storedAt,
    this.completedAt,
    this.lastError,
    this.storageError,
    this.hasMore,
  });

  Id id;

  @Index(unique: true, replace: true)
  String jobKey;

  @Index()
  String scopeKey;

  String domainType;
  String domainId;
  String entityType;

  bool isCollection;
  String? entityId;
  String? parentId;
  int? limit;
  String? cursor;
  bool? hasMore;

  @Index()
  String status;

  String priority;

  @Index()
  DateTime enqueuedAt;

  DateTime? startedAt;
  DateTime? fetchedAt;
  DateTime? storedAt;
  DateTime? completedAt;
  String? lastError;
  String? storageError;
}
