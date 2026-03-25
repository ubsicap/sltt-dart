import 'dart:async';

import 'package:dio/dio.dart';
import 'package:sltt_core/sltt_core.dart';

import 'entity_state_pagination_job_persistence_store.dart';
import 'models/entity_state_pagination_job.isar.dart';

const _defaultEntityStateRequestsConcurrency = 4;
const _defaultSingleRequestDebounceMs = 300;

class EntityStateFetchEvent {
  EntityStateFetchEvent({
    required this.requestKey,
    required this.jobKey,
    required this.domainType,
    required this.domainId,
    required this.entityType,
    this.entityId,
    this.parentId,
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.isCollectionRequest = false,
    this.isComplete = false,
    this.errorMessage = '',
  });

  final String requestKey;
  final String jobKey;
  final String domainType;
  final String domainId;
  final String entityType;
  final String? entityId;
  final String? parentId;
  final List<Map<String, dynamic>> items;
  final String? cursor;
  final bool hasMore;
  final bool isCollectionRequest;
  final bool isComplete;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
}

enum _EntityStateJobPriority { low, normal }

class _EntityStateJob {
  _EntityStateJob({
    required this.jobKey,
    required this.requestKey,
    required this.scopeKey,
    required this.domainType,
    required this.domainId,
    required this.entityType,
    required this.isCollection,
    required this.enqueuedAt,
    required this.priority,
    this.entityId,
    this.parentId,
    this.limit,
    this.cursor,
    this.singleRequestKeysByEntityId = const {},
  });

  final String jobKey;
  final String requestKey;
  final String scopeKey;
  final String domainType;
  final String domainId;
  final String entityType;
  final bool isCollection;
  final String? entityId;
  final String? parentId;
  final int? limit;
  String? cursor;
  bool hasMore = false;
  bool yieldRequested = false;
  final Map<String, String> singleRequestKeysByEntityId;
  final DateTime enqueuedAt;
  final _EntityStateJobPriority priority;
}

class _PendingSingleRequest {
  _PendingSingleRequest({required this.requestKey, required this.entityId});

  final String requestKey;
  final String entityId;
}

class _SingleEntityDebounceBucket {
  _SingleEntityDebounceBucket({required this.scopeKey, required this.parentId});

  final String scopeKey;
  final String? parentId;
  Timer? timer;
  final Map<String, _PendingSingleRequest> requestsByEntityId = {};
}

class EntityStatePaginationService {
  EntityStatePaginationService({
    required String baseUrl,
    this.maxConcurrentRequests = _defaultEntityStateRequestsConcurrency,
    this.singleRequestDebounce = const Duration(
      milliseconds: _defaultSingleRequestDebounceMs,
    ),
    this.workspacePrefix = '',
    this.persistJobs = true,
    this.persistenceDbDirectory = './isar_db',
    this.persistenceDbNamePrefix = 'entity_state_pagination_jobs',
    Dio? dio,
  }) : _baseUrl = baseUrl,
       _dio = dio ?? Dio() {
    _requestLimiter = RequestLimiter(maxConcurrentRequests);
    if (persistJobs) {
      _jobStore = EntityStatePaginationJobPersistenceStore(
        workspacePrefix: workspacePrefix,
        databaseDirectory: persistenceDbDirectory,
        databaseNamePrefix: persistenceDbNamePrefix,
      );
    }
  }

  final int maxConcurrentRequests;
  final Duration singleRequestDebounce;
  final String workspacePrefix;
  final bool persistJobs;
  final String persistenceDbDirectory;
  final String persistenceDbNamePrefix;
  final Dio _dio;
  late final RequestLimiter _requestLimiter;
  EntityStatePaginationJobPersistenceStore? _jobStore;
  final StreamController<EntityStateFetchEvent> _singleEntityEventsController =
      StreamController<EntityStateFetchEvent>.broadcast();
  final StreamController<EntityStateFetchEvent>
  _collectionEntityEventsController =
      StreamController<EntityStateFetchEvent>.broadcast();
  String _baseUrl;

  bool _processingQueue = false;
  bool _enabled = false;
  bool _resumeRequested = false;

  final List<_EntityStateJob> _queueLifo = [];
  final Map<String, _EntityStateJob> _activeJobs = {};
  final Map<String, _SingleEntityDebounceBucket> _singleDebounceBuckets = {};

  int _mergedSingleBatchCount = 0;
  int _yieldedActiveJobCount = 0;
  int _ignoredDuplicateSingleRequestDuringActiveCount = 0;
  int _ignoredDuplicateCollectionRequestDuringActiveCount = 0;
  int _requeuedQueuedDuplicateSingleCount = 0;
  int _requeuedQueuedDuplicateCollectionCount = 0;

  int get mergedSingleBatchCount => _mergedSingleBatchCount;
  int get yieldedActiveJobCount => _yieldedActiveJobCount;
  int get ignoredDuplicateSingleRequestDuringActiveCount =>
      _ignoredDuplicateSingleRequestDuringActiveCount;
  int get ignoredDuplicateCollectionRequestDuringActiveCount =>
      _ignoredDuplicateCollectionRequestDuringActiveCount;
  int get requeuedQueuedDuplicateSingleCount =>
      _requeuedQueuedDuplicateSingleCount;
  int get requeuedQueuedDuplicateCollectionCount =>
      _requeuedQueuedDuplicateCollectionCount;
  Stream<EntityStateFetchEvent> get singleEntityEvents =>
      _singleEntityEventsController.stream;
  Stream<EntityStateFetchEvent> get collectionEntityEvents =>
      _collectionEntityEventsController.stream;

  void updateBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
  }

  void startProcessing() {
    _enabled = true;
    if (!_resumeRequested) {
      _resumeRequested = true;
      unawaited(resumePersistedJobs());
    }
    _processQueue();
  }

  void stopProcessing() {
    _enabled = false;
  }

  void resumeProcessing() => startProcessing();

  void dispose() {
    _enabled = false;
    for (final bucket in _singleDebounceBuckets.values) {
      bucket.timer?.cancel();
    }
    _singleDebounceBuckets.clear();
    _activeJobs.clear();
    _queueLifo.clear();

    if (!_singleEntityEventsController.isClosed) {
      _singleEntityEventsController.addError(
        StateError('Entity state queue disposed'),
      );
      unawaited(_singleEntityEventsController.close());
    }
    if (!_collectionEntityEventsController.isClosed) {
      _collectionEntityEventsController.addError(
        StateError('Entity state queue disposed'),
      );
      unawaited(_collectionEntityEventsController.close());
    }

    final store = _jobStore;
    _jobStore = null;
    if (store != null) {
      unawaited(store.close());
    }
  }

  Future<int> resumePersistedJobs() async {
    final store = _jobStore;
    if (store == null) return 0;

    final records = await store.loadResumableJobs();
    var resumedCount = 0;

    for (final record in records) {
      final alreadyActive = _activeJobs.containsKey(record.jobKey);
      final alreadyQueued = _queueLifo.any(
        (job) => job.jobKey == record.jobKey,
      );
      if (alreadyActive || alreadyQueued) {
        continue;
      }

      final job = _jobFromRecord(record);
      _enqueueByPriority(job);
      resumedCount++;
    }

    if (resumedCount > 0) {
      SlttLogger.logger.info(
        '[EntityStateQueue] Resumed $resumedCount persisted job(s) for workspace prefix: $workspacePrefix',
      );
      _processQueue();
    }

    return resumedCount;
  }

  Future<List<Map<String, dynamic>>> debugListPersistedJobs() async {
    final store = _jobStore;
    if (store == null) return const [];
    final records = await store.listAll();
    records.sort((a, b) => a.enqueuedAt.compareTo(b.enqueuedAt));
    return records
        .map(
          (record) => {
            'jobKey': record.jobKey,
            'scopeKey': record.scopeKey,
            'domainType': record.domainType,
            'domainId': record.domainId,
            'entityType': record.entityType,
            'isCollection': record.isCollection,
            'entityId': record.entityId,
            'parentId': record.parentId,
            'limit': record.limit,
            'cursor': record.cursor,
            'hasMore': record.hasMore,
            'status': record.status,
            'priority': record.priority,
            'enqueuedAt': record.enqueuedAt.toIso8601String(),
            'startedAt': record.startedAt?.toIso8601String(),
            'completedAt': record.completedAt?.toIso8601String(),
            'lastError': record.lastError,
          },
        )
        .toList();
  }

  static Future<void> deletePersistedJobsForWorkspacePrefix({
    required String workspacePrefix,
    String databaseDirectory = './isar_db',
    String databaseNamePrefix = 'entity_state_pagination_jobs',
  }) {
    return EntityStatePaginationJobPersistenceStore.deleteDatabaseFilesForWorkspacePrefix(
      workspacePrefix: workspacePrefix,
      databaseDirectory: databaseDirectory,
      databaseNamePrefix: databaseNamePrefix,
    );
  }

  String enqueueJobFetchEntityState({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
    String? parentId,
  }) {
    final scopeKey = _scopeKey(
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      parentId: parentId,
    );

    final activeCollectionForScope = _activeJobs.values.any(
      (job) => job.isCollection && job.scopeKey == scopeKey,
    );
    if (!activeCollectionForScope) {
      _requestActivePagersToYield();
    }

    final existingSingleActive =
        _activeJobs[_singleJobKey(
          domainType: domainType,
          domainId: domainId,
          entityType: entityType,
          entityId: entityId,
          parentId: parentId,
        )];
    if (existingSingleActive != null) {
      _ignoredDuplicateSingleRequestDuringActiveCount++;
      return existingSingleActive.requestKey;
    }

    final existingSingleInQueueIndex = _queueLifo.indexWhere((job) {
      return !job.isCollection &&
          job.domainType == domainType &&
          job.domainId == domainId &&
          job.entityType == entityType &&
          job.parentId == parentId &&
          job.entityId == entityId;
    });
    if (existingSingleInQueueIndex != -1) {
      final queued = _queueLifo.removeAt(existingSingleInQueueIndex);
      _queueLifo.add(queued);
      _requeuedQueuedDuplicateSingleCount++;
      _persistQueuedJob(queued);
      _processQueue();
      return queued.requestKey;
    }

    final bucket = _singleDebounceBuckets.putIfAbsent(
      scopeKey,
      () => _SingleEntityDebounceBucket(scopeKey: scopeKey, parentId: parentId),
    );

    final existingRequest = bucket.requestsByEntityId[entityId];
    if (existingRequest != null) {
      return existingRequest.requestKey;
    }

    final requestKey = _singleJobKey(
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      entityId: entityId,
      parentId: parentId,
    );
    bucket.requestsByEntityId[entityId] = _PendingSingleRequest(
      requestKey: requestKey,
      entityId: entityId,
    );

    bucket.timer?.cancel();
    bucket.timer = Timer(singleRequestDebounce, () {
      _flushSingleEntityBucket(
        domainType: domainType,
        domainId: domainId,
        entityType: entityType,
        parentId: parentId,
      );
    });

    _processQueue();
    return requestKey;
  }

  String enqueueJobFetchEntityStateCollection({
    required String domainType,
    required String domainId,
    required String entityType,
    String? parentId,
    int? limit,
    String? cursor,
  }) {
    final existingIndex = _queueLifo.indexWhere((job) {
      return job.isCollection &&
          job.domainType == domainType &&
          job.domainId == domainId &&
          job.entityType == entityType &&
          job.parentId == parentId;
    });
    if (existingIndex != -1) {
      final queued = _queueLifo.removeAt(existingIndex);
      _queueLifo.add(queued);
      _requeuedQueuedDuplicateCollectionCount++;
      _persistQueuedJob(queued);
      _processQueue();
      return queued.requestKey;
    }

    final key = _collectionJobKey(
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      parentId: parentId,
    );
    final active = _activeJobs[key];
    if (active != null) {
      _ignoredDuplicateCollectionRequestDuringActiveCount++;
      return active.requestKey;
    }

    final job = _EntityStateJob(
      jobKey: key,
      requestKey: key,
      scopeKey: _scopeKey(
        domainType: domainType,
        domainId: domainId,
        entityType: entityType,
        parentId: parentId,
      ),
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      isCollection: true,
      parentId: parentId,
      enqueuedAt: DateTime.now().toUtc(),
      priority: _EntityStateJobPriority.normal,
      limit: limit,
      cursor: cursor,
    );

    _queueLifo.add(job);
    _persistQueuedJob(job);
    _processQueue();
    return job.requestKey;
  }

  void _flushSingleEntityBucket({
    required String domainType,
    required String domainId,
    required String entityType,
    String? parentId,
  }) {
    final scopeKey = _scopeKey(
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      parentId: parentId,
    );
    final bucket = _singleDebounceBuckets.remove(scopeKey);
    if (bucket == null || bucket.requestsByEntityId.isEmpty) return;
    bucket.timer?.cancel();

    final ids = bucket.requestsByEntityId.keys.toList();
    if (ids.length == 1) {
      final entityId = ids.first;
      final pendingRequest = bucket.requestsByEntityId[entityId]!;
      final job = _EntityStateJob(
        jobKey: pendingRequest.requestKey,
        requestKey: pendingRequest.requestKey,
        scopeKey: scopeKey,
        domainType: domainType,
        domainId: domainId,
        entityType: entityType,
        isCollection: false,
        entityId: entityId,
        parentId: parentId,
        enqueuedAt: DateTime.now().toUtc(),
        priority: _EntityStateJobPriority.normal,
      );
      _queueLifo.add(job);
      _persistQueuedJob(job);
    } else {
      _mergedSingleBatchCount++;
      final job = _EntityStateJob(
        jobKey: _collectionJobKey(
          domainType: domainType,
          domainId: domainId,
          entityType: entityType,
          parentId: parentId,
        ),
        requestKey: _collectionJobKey(
          domainType: domainType,
          domainId: domainId,
          entityType: entityType,
          parentId: parentId,
        ),
        scopeKey: scopeKey,
        domainType: domainType,
        domainId: domainId,
        entityType: entityType,
        isCollection: true,
        parentId: parentId,
        enqueuedAt: DateTime.now().toUtc(),
        priority: _EntityStateJobPriority.normal,
        singleRequestKeysByEntityId: {
          for (final entry in bucket.requestsByEntityId.entries)
            entry.key: entry.value.requestKey,
        },
      );
      _queueLifo.add(job);
      _persistQueuedJob(job);
    }

    _processQueue();
  }

  void _requestActivePagersToYield() {
    for (final job in _activeJobs.values) {
      if (job.isCollection && job.hasMore) {
        job.yieldRequested = true;
      }
    }
  }

  void _processQueue() {
    if (_processingQueue || !_enabled) return;
    _processingQueue = true;

    Future<void>.microtask(() async {
      try {
        while (_enabled && _queueLifo.isNotEmpty) {
          await _requestLimiter.acquire();

          if (!_enabled) {
            _requestLimiter.release();
            break;
          }

          final nextJob = _queueLifo.removeLast();
          _activeJobs[nextJob.jobKey] = nextJob;
          _persistJobActive(nextJob.jobKey);

          unawaited(
            _runJob(nextJob).whenComplete(() {
              _activeJobs.remove(nextJob.jobKey);
              _requestLimiter.release();
              _processQueue();
            }),
          );
        }
      } finally {
        _processingQueue = false;
      }
    });
  }

  Future<void> _runJob(_EntityStateJob job) async {
    try {
      if (job.isCollection) {
        await _runCollectionJob(job);
      } else {
        await _runSingleJob(job);
      }
    } catch (e, st) {
      SlttLogger.logger.severe('[EntityStateQueue] Job failed: $e', e, st);
      _emitError(job, e.toString());
    }
  }

  Future<void> _runSingleJob(_EntityStateJob job) async {
    final entityCollection = _resolveEntityCollection(job.entityType);
    final domainCollection = _resolveDomainCollection(job.domainType);

    final encodedDomainId = Uri.encodeComponent(job.domainId);
    final encodedEntityId = Uri.encodeComponent(job.entityId ?? '');
    final url =
        '$_baseUrl/api/state/$domainCollection/$encodedDomainId/$entityCollection/$encodedEntityId';

    final response = await _dio.get(url);
    final body = (response.data as Map).cast<String, dynamic>();
    final state = body['state'];

    final items = <Map<String, dynamic>>[];
    if (state is Map) {
      items.add(state.cast<String, dynamic>());
    }

    _emitSingleEvent(job, items: items, hasMore: false);
    _complete(job);
  }

  Future<void> _runCollectionJob(_EntityStateJob job) async {
    var cursor = job.cursor;
    final pendingIds = job.singleRequestKeysByEntityId.keys.toSet();

    while (_enabled) {
      final response = await _fetchCollectionPage(job, cursor: cursor);
      final items = response.items;
      final nextCursor = response.cursor;
      final hasMore = response.hasMore;

      job.hasMore = hasMore;
      job.cursor = nextCursor;
      _persistJobCursor(job);

      _emitCollectionEvent(
        job,
        items: items,
        cursor: nextCursor,
        hasMore: hasMore,
      );

      if (job.singleRequestKeysByEntityId.isNotEmpty) {
        for (final item in items) {
          final id = _extractEntityId(item);
          if (id == null) continue;
          final requestKey = job.singleRequestKeysByEntityId[id];
          if (requestKey == null) continue;
          _emitSingleEvent(
            job,
            requestKey: requestKey,
            entityId: id,
            items: [item],
            cursor: nextCursor,
            hasMore: hasMore,
          );
          pendingIds.remove(id);
        }

        if (pendingIds.isEmpty) {
          _complete(job);
          return;
        }
      }

      if (!hasMore || nextCursor == null || nextCursor.isEmpty) {
        _complete(job);
        return;
      }

      if (job.yieldRequested) {
        _yieldedActiveJobCount++;
        final continuation = _EntityStateJob(
          jobKey: job.jobKey,
          requestKey: job.requestKey,
          scopeKey: job.scopeKey,
          domainType: job.domainType,
          domainId: job.domainId,
          entityType: job.entityType,
          isCollection: true,
          parentId: job.parentId,
          enqueuedAt: job.enqueuedAt,
          priority: _EntityStateJobPriority.low,
          limit: job.limit,
          cursor: nextCursor,
          singleRequestKeysByEntityId: job.singleRequestKeysByEntityId,
        );
        _enqueueLowPriority(continuation);
        return;
      }

      cursor = nextCursor;
    }

    if (cursor != null && cursor.isNotEmpty) {
      final continuation = _EntityStateJob(
        jobKey: job.jobKey,
        requestKey: job.requestKey,
        scopeKey: job.scopeKey,
        domainType: job.domainType,
        domainId: job.domainId,
        entityType: job.entityType,
        isCollection: true,
        parentId: job.parentId,
        enqueuedAt: job.enqueuedAt,
        priority: _EntityStateJobPriority.low,
        limit: job.limit,
        cursor: cursor,
        singleRequestKeysByEntityId: job.singleRequestKeysByEntityId,
      );
      _enqueueLowPriority(continuation);
    }
  }

  Future<_CollectionPageResponse> _fetchCollectionPage(
    _EntityStateJob job, {
    String? cursor,
  }) async {
    final entityCollection = _resolveEntityCollection(job.entityType);
    final domainCollection = _resolveDomainCollection(job.domainType);
    final encodedDomainId = Uri.encodeComponent(job.domainId);

    final url =
        '$_baseUrl/api/state/$domainCollection/$encodedDomainId/$entityCollection';

    final query = <String, dynamic>{'limit': job.limit};
    if (cursor != null && cursor.isNotEmpty) {
      query['cursor'] = cursor;
    }
    if (job.parentId != null && job.parentId!.isNotEmpty) {
      query['parentId'] = job.parentId;
    }

    final response = await _dio.get(url, queryParameters: query);
    final body = (response.data as Map).cast<String, dynamic>();
    final dynamic itemsRaw = body['items'];
    final items = itemsRaw is List
        ? itemsRaw
              .whereType<Map>()
              .map((entry) => entry.cast<String, dynamic>())
              .toList()
        : <Map<String, dynamic>>[];

    final nextCursor = body['cursor']?.toString();
    final hasMore = body['hasMore'] == true;
    return _CollectionPageResponse(
      items: items,
      cursor: nextCursor,
      hasMore: hasMore,
    );
  }

  void _enqueueLowPriority(_EntityStateJob job) {
    _enqueueByPriority(job);
    _persistQueuedJob(job);
    _processQueue();
  }

  void _enqueueByPriority(_EntityStateJob job) {
    if (job.priority == _EntityStateJobPriority.low) {
      _queueLifo.insert(0, job);
      return;
    }
    _queueLifo.add(job);
  }

  void _complete(_EntityStateJob job) {
    _persistJobCompleted(job.jobKey);

    if (job.isCollection) {
      _emitCollectionEvent(job, isComplete: true);
    } else {
      _emitSingleEvent(job, isComplete: true);
    }

    for (final entry in job.singleRequestKeysByEntityId.entries) {
      _emitSingleEvent(
        job,
        requestKey: entry.value,
        entityId: entry.key,
        isComplete: true,
      );
    }
  }

  void _emitError(_EntityStateJob job, String errorMessage) {
    _persistJobFailed(job.jobKey, errorMessage);

    if (job.isCollection) {
      _emitCollectionEvent(job, errorMessage: errorMessage);
    } else {
      _emitSingleEvent(job, errorMessage: errorMessage);
    }

    for (final entry in job.singleRequestKeysByEntityId.entries) {
      _emitSingleEvent(
        job,
        requestKey: entry.value,
        entityId: entry.key,
        errorMessage: errorMessage,
      );
    }
  }

  String _resolveDomainCollection(String domainType) {
    final collection = getCollectionByDomain(domainType);
    if (collection == null || collection.isEmpty) {
      throw ArgumentError('Unknown domainType for state queue: $domainType');
    }
    return collection;
  }

  String _resolveEntityCollection(String entityType) {
    final collection = getCollectionByEntity(entityType);
    if (collection == null || collection.isEmpty) {
      throw ArgumentError('Unknown entityType for state queue: $entityType');
    }
    return collection;
  }

  String _scopeKey({
    required String domainType,
    required String domainId,
    required String entityType,
    String? parentId,
  }) {
    return '$domainType|$domainId|$entityType|parent:${parentId ?? ''}';
  }

  String _collectionJobKey({
    required String domainType,
    required String domainId,
    required String entityType,
    String? parentId,
  }) {
    return '${_scopeKey(domainType: domainType, domainId: domainId, entityType: entityType, parentId: parentId)}|collection';
  }

  String _singleJobKey({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
    String? parentId,
  }) {
    return '${_scopeKey(domainType: domainType, domainId: domainId, entityType: entityType, parentId: parentId)}|single|$entityId';
  }

  String? _extractEntityId(Map<String, dynamic> item) {
    final raw = item['entityId'] ?? item['id'];
    if (raw == null) return null;
    final str = raw.toString().trim();
    return str.isEmpty ? null : str;
  }

  _EntityStateJob _jobFromRecord(EntityStatePaginationJobRecord record) {
    return _EntityStateJob(
      jobKey: record.jobKey,
      requestKey: record.jobKey,
      scopeKey: record.scopeKey,
      domainType: record.domainType,
      domainId: record.domainId,
      entityType: record.entityType,
      isCollection: record.isCollection,
      entityId: record.entityId,
      parentId: record.parentId,
      limit: record.limit,
      cursor: record.cursor,
      enqueuedAt: record.enqueuedAt,
      priority: _priorityFromStored(record.priority),
    )..hasMore = record.hasMore ?? false;
  }

  void _emitSingleEvent(
    _EntityStateJob job, {
    String? requestKey,
    String? entityId,
    List<Map<String, dynamic>> items = const [],
    String? cursor,
    bool hasMore = false,
    bool isComplete = false,
    String errorMessage = '',
  }) {
    if (_singleEntityEventsController.isClosed) return;
    _singleEntityEventsController.add(
      EntityStateFetchEvent(
        requestKey: requestKey ?? job.requestKey,
        jobKey: job.jobKey,
        domainType: job.domainType,
        domainId: job.domainId,
        entityType: job.entityType,
        entityId: entityId ?? job.entityId,
        parentId: job.parentId,
        items: items,
        cursor: cursor,
        hasMore: hasMore,
        isCollectionRequest: false,
        isComplete: isComplete,
        errorMessage: errorMessage,
      ),
    );
  }

  void _emitCollectionEvent(
    _EntityStateJob job, {
    List<Map<String, dynamic>> items = const [],
    String? cursor,
    bool hasMore = false,
    bool isComplete = false,
    String errorMessage = '',
  }) {
    if (_collectionEntityEventsController.isClosed) return;
    _collectionEntityEventsController.add(
      EntityStateFetchEvent(
        requestKey: job.requestKey,
        jobKey: job.jobKey,
        domainType: job.domainType,
        domainId: job.domainId,
        entityType: job.entityType,
        entityId: job.entityId,
        parentId: job.parentId,
        items: items,
        cursor: cursor,
        hasMore: hasMore,
        isCollectionRequest: true,
        isComplete: isComplete,
        errorMessage: errorMessage,
      ),
    );
  }

  _EntityStateJobPriority _priorityFromStored(String value) {
    return value == _EntityStateJobPriority.low.name
        ? _EntityStateJobPriority.low
        : _EntityStateJobPriority.normal;
  }

  void _persistQueuedJob(_EntityStateJob job) {
    final store = _jobStore;
    if (store == null) return;
    unawaited(
      store.upsertQueuedJob(
        jobKey: job.jobKey,
        scopeKey: job.scopeKey,
        domainType: job.domainType,
        domainId: job.domainId,
        entityType: job.entityType,
        isCollection: job.isCollection,
        priority: job.priority.name,
        enqueuedAt: job.enqueuedAt,
        entityId: job.entityId,
        parentId: job.parentId,
        limit: job.limit,
        cursor: job.cursor,
        hasMore: job.hasMore,
      ),
    );
  }

  void _persistJobActive(String jobKey) {
    final store = _jobStore;
    if (store == null) return;
    unawaited(store.markActive(jobKey));
  }

  void _persistJobCursor(_EntityStateJob job) {
    final store = _jobStore;
    if (store == null) return;
    unawaited(
      store.updateCursor(
        jobKey: job.jobKey,
        cursor: job.cursor,
        hasMore: job.hasMore,
      ),
    );
  }

  void _persistJobCompleted(String jobKey) {
    final store = _jobStore;
    if (store == null) return;
    unawaited(store.markCompleted(jobKey));
  }

  void _persistJobFailed(String jobKey, String errorMessage) {
    final store = _jobStore;
    if (store == null) return;
    unawaited(store.markFailed(jobKey, errorMessage));
  }
}

class _CollectionPageResponse {
  _CollectionPageResponse({
    required this.items,
    required this.cursor,
    required this.hasMore,
  });

  final List<Map<String, dynamic>> items;
  final String? cursor;
  final bool hasMore;
}
