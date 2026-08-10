import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:sltt_core/sltt_core.dart' show SlttLogger;

import 'models/entity_state_pagination_job.isar.dart';
import 'models/entity_state_pagination_job_transition_log.isar.dart';

class EntityStatePaginationJobPersistenceStore {
  EntityStatePaginationJobPersistenceStore({
    required this.workspacePrefix,
    this.databaseDirectory = './isar_db',
    this.databaseNamePrefix = 'entity_state_pagination_jobs',
    this.inspector = true,
  });

  final String workspacePrefix;
  final String databaseDirectory;
  final String databaseNamePrefix;
  final bool inspector;

  Isar? _isar;
  Future<Isar>? _opening;
  bool _ownsIsarInstance = false;

  String get databaseName => buildDatabaseName(
    databaseNamePrefix: databaseNamePrefix,
    workspacePrefix: workspacePrefix,
  );

  static String buildDatabaseName({
    required String databaseNamePrefix,
    required String workspacePrefix,
  }) {
    final normalizedPrefix = _normalizeWorkspacePrefix(workspacePrefix);
    return '${databaseNamePrefix}_$normalizedPrefix';
  }

  static String _normalizeWorkspacePrefix(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return 'default';
    }
    final safe = trimmed.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final compact = safe.replaceAll(RegExp(r'_+'), '_');
    if (compact.isEmpty) {
      return 'default';
    }
    return compact.length > 80 ? compact.substring(0, 80) : compact;
  }

  Future<Isar> _open() async {
    final existing = _isar;
    if (existing != null) return existing;

    final inProgress = _opening;
    if (inProgress != null) {
      return inProgress;
    }

    final openFuture = _openInternal();
    _opening = openFuture;
    try {
      final opened = await openFuture;
      _isar = opened;
      return opened;
    } finally {
      _opening = null;
    }
  }

  Future<void> ensureOpen() async {
    await _open();
  }

  Future<Isar> _openInternal() async {
    final existing = Isar.getInstance(databaseName);
    if (existing != null) {
      _ownsIsarInstance = false;
      SlttLogger.logger.info(
        '[EntityStatePaginationJobStore] Attached existing Isar instance '
        'name=$databaseName dir=$databaseDirectory inspector=$inspector',
      );
      return existing;
    }

    final dir = Directory(databaseDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final opened = await Isar.open(
      [
        EntityStatePaginationJobRecordSchema,
        EntityStatePaginationJobTransitionLogRecordSchema,
      ],
      directory: dir.path,
      name: databaseName,
      inspector: inspector,
    );
    _ownsIsarInstance = true;
    SlttLogger.logger.info(
      '[EntityStatePaginationJobStore] Opened Isar db '
      'path=${dir.path}/$databaseName.isar inspector=$inspector',
    );
    return opened;
  }

  Future<void> close() async {
    final inProgress = _opening;
    if (inProgress != null) {
      try {
        await inProgress;
      } catch (_) {
        // If opening failed, there is no instance to close.
      }
    }

    final isar = _isar;
    _isar = null;
    final shouldClose = _ownsIsarInstance;
    _ownsIsarInstance = false;
    if (isar != null && isar.isOpen && shouldClose) {
      await isar.close();
      SlttLogger.logger.info(
        '[EntityStatePaginationJobStore] Closed Isar db '
        'path=$databaseDirectory/$databaseName.isar',
      );
    }
  }

  Future<void> upsertQueuedJob({
    required String jobKey,
    required String scopeKey,
    required String domainType,
    required String domainId,
    required String entityType,
    required bool isCollection,
    required String priority,
    required DateTime enqueuedAt,
    String? entityId,
    String? parentId,
    int? limit,
    String? cursor,
    bool? hasMore,
  }) async {
    final isar = await _open();
    final nextEnqueuedAt = enqueuedAt.toUtc();
    await isar.writeTxn(() async {
      final existing = await isar.entityStatePaginationJobRecords
          .where()
          .jobKeyEqualTo(jobKey)
          .findFirst();
      final isStaleQueuedWrite =
          existing != null &&
          existing.startedAt != null &&
          !nextEnqueuedAt.isAfter(existing.enqueuedAt);
      if (isStaleQueuedWrite) {
        return;
      }

      final next =
          existing ??
          EntityStatePaginationJobRecord(
            jobKey: jobKey,
            scopeKey: scopeKey,
            domainType: domainType,
            domainId: domainId,
            entityType: entityType,
            isCollection: isCollection,
            status: entityStatePaginationJobStatusQueued,
            priority: priority,
            enqueuedAt: nextEnqueuedAt,
            entityId: entityId,
            parentId: parentId,
            limit: limit,
            cursor: cursor,
            hasMore: hasMore,
          );

      next.scopeKey = scopeKey;
      next.domainType = domainType;
      next.domainId = domainId;
      next.entityType = entityType;
      next.isCollection = isCollection;
      next.entityId = entityId;
      next.parentId = parentId;
      next.limit = limit;
      next.cursor = cursor;
      next.hasMore = hasMore;
      next.priority = priority;
      next.enqueuedAt = nextEnqueuedAt;
      next.status = entityStatePaginationJobStatusQueued;
      next.startedAt = null;
      next.fetchedAt = null;
      next.storedAt = null;
      next.completedAt = null;
      next.lastError = null;
      next.storageError = null;

      await isar.entityStatePaginationJobRecords.put(next);
      SlttLogger.logger.info(
        '[EntityStateQueue] Persisting queued job: ${next.jobKey} (priority=${next.priority}, isCollection=${next.isCollection}):\n${jsonEncode({'jobKey': next.jobKey, 'scopeKey': next.scopeKey, 'domainType': next.domainType, 'domainId': next.domainId, 'entityType': next.entityType, 'isCollection': next.isCollection, 'entityId': next.entityId, 'parentId': next.parentId, 'limit': next.limit, 'cursor': next.cursor, 'hasMore': next.hasMore, 'priority': next.priority, 'enqueuedAt': next.enqueuedAt.toIso8601String()})}',
      );
      await _appendTransitionLog(
        isar: isar,
        jobRecord: next,
        fromStatus: existing?.status ?? entityStatePaginationJobStatusQueued,
        toStatus: entityStatePaginationJobStatusQueued,
        transitionType: entityStatePaginationJobTransitionTypeStatus,
      );
    });
  }

  Future<void> upsertActiveJob({
    required String jobKey,
    required String scopeKey,
    required String domainType,
    required String domainId,
    required String entityType,
    required bool isCollection,
    required String priority,
    required DateTime enqueuedAt,
    String? entityId,
    String? parentId,
    int? limit,
    String? cursor,
    bool? hasMore,
  }) async {
    final isar = await _open();
    await isar.writeTxn(() async {
      final existing = await isar.entityStatePaginationJobRecords
          .where()
          .jobKeyEqualTo(jobKey)
          .findFirst();
      final next =
          existing ??
          EntityStatePaginationJobRecord(
            jobKey: jobKey,
            scopeKey: scopeKey,
            domainType: domainType,
            domainId: domainId,
            entityType: entityType,
            isCollection: isCollection,
            status: entityStatePaginationJobStatusActive,
            priority: priority,
            enqueuedAt: enqueuedAt.toUtc(),
            entityId: entityId,
            parentId: parentId,
            limit: limit,
            cursor: cursor,
            hasMore: hasMore,
          );

      next.scopeKey = scopeKey;
      next.domainType = domainType;
      next.domainId = domainId;
      next.entityType = entityType;
      next.isCollection = isCollection;
      next.entityId = entityId;
      next.parentId = parentId;
      next.limit = limit;
      next.cursor = cursor;
      next.hasMore = hasMore;
      next.priority = priority;
      next.enqueuedAt = enqueuedAt.toUtc();
      next.status = entityStatePaginationJobStatusActive;
      next.startedAt = DateTime.now().toUtc();
      next.fetchedAt = null;
      next.storedAt = null;
      next.completedAt = null;
      next.lastError = null;
      next.storageError = null;
      await isar.entityStatePaginationJobRecords.put(next);
      await _appendTransitionLog(
        isar: isar,
        jobRecord: next,
        fromStatus: existing?.status ?? entityStatePaginationJobStatusQueued,
        toStatus: entityStatePaginationJobStatusActive,
        transitionType: entityStatePaginationJobTransitionTypeStatus,
      );
    });
  }

  Future<void> markFetched(String jobKey) async {
    final isar = await _open();
    await isar.writeTxn(() async {
      final existing = await isar.entityStatePaginationJobRecords
          .where()
          .jobKeyEqualTo(jobKey)
          .findFirst();
      if (existing == null) return;
      existing.status = entityStatePaginationJobStatusFetched;
      existing.fetchedAt = DateTime.now().toUtc();
      existing.lastError = null;
      existing.storageError = null;
      await isar.entityStatePaginationJobRecords.put(existing);
      await _appendTransitionLog(
        isar: isar,
        jobRecord: existing,
        fromStatus: entityStatePaginationJobStatusActive,
        toStatus: entityStatePaginationJobStatusFetched,
        transitionType: entityStatePaginationJobTransitionTypeStatus,
      );
    });
  }

  Future<void> markStored(String jobKey) async {
    final isar = await _open();
    await isar.writeTxn(() async {
      final existing = await isar.entityStatePaginationJobRecords
          .where()
          .jobKeyEqualTo(jobKey)
          .findFirst();
      if (existing == null) return;
      existing.status = entityStatePaginationJobStatusActive;
      existing.storedAt = DateTime.now().toUtc();
      existing.completedAt = null;
      existing.lastError = null;
      existing.storageError = null;
      await isar.entityStatePaginationJobRecords.put(existing);
      await _appendTransitionLog(
        isar: isar,
        jobRecord: existing,
        fromStatus: entityStatePaginationJobStatusFetched,
        toStatus: entityStatePaginationJobStatusActive,
        transitionType: entityStatePaginationJobTransitionTypeStatus,
      );
    });
  }

  Future<void> updateCursor({
    required String jobKey,
    required String? cursor,
    required bool hasMore,
  }) async {
    final isar = await _open();
    await isar.writeTxn(() async {
      final existing = await isar.entityStatePaginationJobRecords
          .where()
          .jobKeyEqualTo(jobKey)
          .findFirst();
      if (existing == null) return;
      final oldCursor = existing.cursor;
      final oldHasMore = existing.hasMore;
      existing.cursor = cursor;
      existing.hasMore = hasMore;
      await isar.entityStatePaginationJobRecords.put(existing);
      await _appendTransitionLog(
        isar: isar,
        jobRecord: existing,
        fromStatus: existing.status,
        toStatus: existing.status,
        transitionType: entityStatePaginationJobTransitionTypeCursorUpdate,
        detailsJson: jsonEncode({
          'oldCursor': oldCursor,
          'newCursor': cursor,
          'oldHasMore': oldHasMore,
          'newHasMore': hasMore,
        }),
      );
    });
  }

  Future<void> markCompleted(String jobKey) async {
    final isar = await _open();
    await isar.writeTxn(() async {
      final existing = await isar.entityStatePaginationJobRecords
          .where()
          .jobKeyEqualTo(jobKey)
          .findFirst();
      if (existing == null) return;
      existing.status = entityStatePaginationJobStatusCompleted;
      existing.completedAt = DateTime.now().toUtc();
      existing.lastError = null;
      existing.storageError = null;
      await isar.entityStatePaginationJobRecords.put(existing);
      await _appendTransitionLog(
        isar: isar,
        jobRecord: existing,
        fromStatus: entityStatePaginationJobStatusActive,
        toStatus: entityStatePaginationJobStatusCompleted,
        transitionType: entityStatePaginationJobTransitionTypeStatus,
      );
    });
  }

  Future<void> markFailed(String jobKey, String errorMessage) async {
    final isar = await _open();
    await isar.writeTxn(() async {
      final existing = await isar.entityStatePaginationJobRecords
          .where()
          .jobKeyEqualTo(jobKey)
          .findFirst();
      if (existing == null) return;
      existing.status = entityStatePaginationJobStatusFailed;
      existing.completedAt = DateTime.now().toUtc();
      existing.lastError = errorMessage;
      existing.storageError = null;
      await isar.entityStatePaginationJobRecords.put(existing);
      await _appendTransitionLog(
        isar: isar,
        jobRecord: existing,
        fromStatus: entityStatePaginationJobStatusActive,
        toStatus: entityStatePaginationJobStatusFailed,
        transitionType: entityStatePaginationJobTransitionTypeStatus,
        message: errorMessage,
      );
    });
  }

  Future<void> markStorageFailed(String jobKey, String errorMessage) async {
    final isar = await _open();
    await isar.writeTxn(() async {
      final existing = await isar.entityStatePaginationJobRecords
          .where()
          .jobKeyEqualTo(jobKey)
          .findFirst();
      if (existing == null) return;
      existing.status = entityStatePaginationJobStatusStorageFailed;
      existing.completedAt = DateTime.now().toUtc();
      existing.lastError = errorMessage;
      existing.storageError = errorMessage;
      await isar.entityStatePaginationJobRecords.put(existing);
      await _appendTransitionLog(
        isar: isar,
        jobRecord: existing,
        fromStatus: entityStatePaginationJobStatusFetched,
        toStatus: entityStatePaginationJobStatusStorageFailed,
        transitionType: entityStatePaginationJobTransitionTypeStatus,
        message: errorMessage,
      );
    });
  }

  Future<List<EntityStatePaginationJobRecord>> loadResumableJobs() async {
    final isar = await _open();
    final queued = await isar.entityStatePaginationJobRecords
        .filter()
        .statusEqualTo(entityStatePaginationJobStatusQueued)
        .sortByEnqueuedAt()
        .findAll();
    final active = await isar.entityStatePaginationJobRecords
        .filter()
        .statusEqualTo(entityStatePaginationJobStatusActive)
        .sortByEnqueuedAt()
        .findAll();
    final fetched = await isar.entityStatePaginationJobRecords
        .filter()
        .statusEqualTo(entityStatePaginationJobStatusFetched)
        .sortByEnqueuedAt()
        .findAll();
    final storageFailed = await isar.entityStatePaginationJobRecords
        .filter()
        .statusEqualTo(entityStatePaginationJobStatusStorageFailed)
        .sortByEnqueuedAt()
        .findAll();

    final merged = <EntityStatePaginationJobRecord>[
      ...queued,
      ...active,
      ...fetched,
      ...storageFailed,
    ];
    merged.sort((a, b) => a.enqueuedAt.compareTo(b.enqueuedAt));
    return merged;
  }

  Future<List<EntityStatePaginationJobRecord>> listAll() async {
    final isar = await _open();
    return isar.entityStatePaginationJobRecords.where().findAll();
  }

  Future<List<EntityStatePaginationJobTransitionLogRecord>> listTransitions({
    String? jobKey,
    int limit = 200,
  }) async {
    final isar = await _open();
    if (jobKey == null || jobKey.isEmpty) {
      return isar.entityStatePaginationJobTransitionLogRecords
          .where()
          .sortByTransitionAtDesc()
          .limit(limit)
          .findAll();
    }
    return isar.entityStatePaginationJobTransitionLogRecords
        .filter()
        .jobKeyEqualTo(jobKey)
        .sortByTransitionAtDesc()
        .limit(limit)
        .findAll();
  }

  Future<void> deleteAllJobs() async {
    final isar = await _open();
    await isar.writeTxn(() async {
      await isar.entityStatePaginationJobRecords.where().deleteAll();
      await isar.entityStatePaginationJobTransitionLogRecords
          .where()
          .deleteAll();
    });
  }

  Future<void> _appendTransitionLog({
    required Isar isar,
    required EntityStatePaginationJobRecord jobRecord,
    required String fromStatus,
    required String toStatus,
    required String transitionType,
    String? message,
    String? detailsJson,
  }) async {
    try {
      await isar.entityStatePaginationJobTransitionLogRecords.put(
        EntityStatePaginationJobTransitionLogRecord(
          jobRecordId: jobRecord.id,
          jobKey: jobRecord.jobKey,
          scopeKey: jobRecord.scopeKey,
          domainType: jobRecord.domainType,
          domainId: jobRecord.domainId,
          entityType: jobRecord.entityType,
          isCollection: jobRecord.isCollection,
          entityId: jobRecord.entityId,
          parentId: jobRecord.parentId,
          cursor: jobRecord.cursor,
          hasMore: jobRecord.hasMore,
          fromStatus: fromStatus,
          toStatus: toStatus,
          transitionType: transitionType,
          transitionAt: DateTime.now().toUtc(),
          message: message,
          detailsJson: detailsJson,
        ),
      );
    } catch (e, st) {
      // Debug log writes must not block primary job persistence.
      SlttLogger.logger.warning(
        '[EntityStatePaginationJobStore] Failed to append transition log '
        'for job ${jobRecord.jobKey}: $e',
      );
      SlttLogger.logger.fine(
        '[EntityStatePaginationJobStore] Transition log stack trace: $st',
      );
    }
  }

  static Future<void> deleteDatabaseFilesForWorkspacePrefix({
    required String workspacePrefix,
    String databaseDirectory = './isar_db',
    String databaseNamePrefix = 'entity_state_pagination_jobs',
  }) async {
    final dbName = buildDatabaseName(
      databaseNamePrefix: databaseNamePrefix,
      workspacePrefix: workspacePrefix,
    );
    await _deleteDatabaseFiles(
      databaseName: dbName,
      dbDirectory: databaseDirectory,
    );
  }

  static Future<void> _deleteDatabaseFiles({
    required String databaseName,
    required String dbDirectory,
  }) async {
    final dbPath = '$dbDirectory/$databaseName';
    final files = <String>['$dbPath.isar', '$dbPath.isar-lck', dbPath];

    for (final filePath in files) {
      await _deletePathWithRetries(filePath);
    }
  }

  static Future<void> _deletePathWithRetries(String filePath) async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (true) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          return;
        }

        final dir = Directory(filePath);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
        return;
      } on FileSystemException {
        if (DateTime.now().isAfter(deadline)) {
          rethrow;
        }
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    }
  }
}
