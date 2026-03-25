import 'dart:async';
import 'dart:io';

import 'package:isar_community/isar.dart';

import 'models/entity_state_pagination_job.isar.dart';

class EntityStatePaginationJobPersistenceStore {
  EntityStatePaginationJobPersistenceStore({
    required this.workspacePrefix,
    this.databaseDirectory = './isar_db',
    this.databaseNamePrefix = 'entity_state_pagination_jobs',
  });

  final String workspacePrefix;
  final String databaseDirectory;
  final String databaseNamePrefix;

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

  Future<Isar> _openInternal() async {
    final existing = Isar.getInstance(databaseName);
    if (existing != null) {
      _ownsIsarInstance = false;
      return existing;
    }

    final dir = Directory(databaseDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final opened = await Isar.open(
      [EntityStatePaginationJobRecordSchema],
      directory: dir.path,
      name: databaseName,
    );
    _ownsIsarInstance = true;
    return opened;
  }

  Future<void> close() async {
    final isar = _isar;
    _isar = null;
    final shouldClose = _ownsIsarInstance;
    _ownsIsarInstance = false;
    if (isar != null && isar.isOpen && shouldClose) {
      await isar.close();
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
            status: entityStatePaginationJobStatusQueued,
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
      next.status = entityStatePaginationJobStatusQueued;
      next.startedAt = null;
      next.completedAt = null;
      next.lastError = null;

      await isar.entityStatePaginationJobRecords.put(next);
    });
  }

  Future<void> markActive(String jobKey) async {
    final isar = await _open();
    await isar.writeTxn(() async {
      final existing = await isar.entityStatePaginationJobRecords
          .where()
          .jobKeyEqualTo(jobKey)
          .findFirst();
      if (existing == null) return;
      existing.status = entityStatePaginationJobStatusActive;
      existing.startedAt = DateTime.now().toUtc();
      existing.completedAt = null;
      existing.lastError = null;
      await isar.entityStatePaginationJobRecords.put(existing);
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
      existing.cursor = cursor;
      existing.hasMore = hasMore;
      await isar.entityStatePaginationJobRecords.put(existing);
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
      await isar.entityStatePaginationJobRecords.put(existing);
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
      await isar.entityStatePaginationJobRecords.put(existing);
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

    final merged = <EntityStatePaginationJobRecord>[...queued, ...active];
    merged.sort((a, b) => a.enqueuedAt.compareTo(b.enqueuedAt));
    return merged;
  }

  Future<List<EntityStatePaginationJobRecord>> listAll() async {
    final isar = await _open();
    return isar.entityStatePaginationJobRecords.where().findAll();
  }

  Future<void> deleteAllJobs() async {
    final isar = await _open();
    await isar.writeTxn(() async {
      await isar.entityStatePaginationJobRecords.where().deleteAll();
    });
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
