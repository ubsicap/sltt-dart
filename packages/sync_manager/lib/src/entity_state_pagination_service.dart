import 'dart:async';

import 'package:dio/dio.dart';
import 'package:sltt_core/sltt_core.dart';

const _defaultEntityStateRequestsConcurrency = 4;
const _defaultSingleRequestDebounceMs = 300;

class EntityStateFetchEvent {
  EntityStateFetchEvent({
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
    required this.scopeKey,
    required this.domainType,
    required this.domainId,
    required this.entityType,
    required this.isCollection,
    required this.progressController,
    required this.enqueuedAt,
    required this.priority,
    this.entityId,
    this.parentId,
    this.limit = 100,
    this.cursor,
    this.fanOutControllers = const {},
  });

  final String jobKey;
  final String scopeKey;
  final String domainType;
  final String domainId;
  final String entityType;
  final bool isCollection;
  final String? entityId;
  final String? parentId;
  final int limit;
  String? cursor;
  bool hasMore = false;
  bool yieldRequested = false;
  final StreamController<EntityStateFetchEvent> progressController;
  final Map<String, StreamController<EntityStateFetchEvent>> fanOutControllers;
  final DateTime enqueuedAt;
  final _EntityStateJobPriority priority;

  Stream<EntityStateFetchEvent> get progressStream => progressController.stream;
}

class _SingleEntityDebounceBucket {
  _SingleEntityDebounceBucket({required this.scopeKey, required this.parentId});

  final String scopeKey;
  final String? parentId;
  Timer? timer;
  final Map<String, StreamController<EntityStateFetchEvent>> controllersById =
      {};
}

class EntityStatePaginationService {
  EntityStatePaginationService({
    required String baseUrl,
    this.maxConcurrentRequests = _defaultEntityStateRequestsConcurrency,
    this.singleRequestDebounce = const Duration(
      milliseconds: _defaultSingleRequestDebounceMs,
    ),
    Dio? dio,
  }) : _baseUrl = baseUrl,
       _dio = dio ?? Dio() {
    _requestLimiter = RequestLimiter(maxConcurrentRequests);
  }

  final int maxConcurrentRequests;
  final Duration singleRequestDebounce;
  final Dio _dio;
  late final RequestLimiter _requestLimiter;
  String _baseUrl;

  bool _processingQueue = false;
  bool _enabled = false;

  final List<_EntityStateJob> _queueLifo = [];
  final Map<String, _EntityStateJob> _activeJobs = {};
  final Map<String, _SingleEntityDebounceBucket> _singleDebounceBuckets = {};

  int _mergedSingleBatchCount = 0;
  int _yieldedActiveJobCount = 0;
  int _discardedActiveDuplicateSingleCount = 0;
  int _discardedActiveDuplicateCollectionCount = 0;
  int _requeuedQueuedDuplicateSingleCount = 0;
  int _requeuedQueuedDuplicateCollectionCount = 0;

  int get mergedSingleBatchCount => _mergedSingleBatchCount;
  int get yieldedActiveJobCount => _yieldedActiveJobCount;
  int get discardedActiveDuplicateSingleCount =>
      _discardedActiveDuplicateSingleCount;
  int get discardedActiveDuplicateCollectionCount =>
      _discardedActiveDuplicateCollectionCount;
  int get requeuedQueuedDuplicateSingleCount =>
      _requeuedQueuedDuplicateSingleCount;
  int get requeuedQueuedDuplicateCollectionCount =>
      _requeuedQueuedDuplicateCollectionCount;

  void updateBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
  }

  void startProcessing() {
    _enabled = true;
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
      for (final controller in bucket.controllersById.values) {
        if (!controller.isClosed) {
          controller.addError(StateError('Entity state queue disposed'));
          unawaited(controller.close());
        }
      }
    }
    _singleDebounceBuckets.clear();

    final seen = <StreamController<EntityStateFetchEvent>>{};
    void closeController(StreamController<EntityStateFetchEvent> controller) {
      if (seen.contains(controller)) return;
      seen.add(controller);
      if (!controller.isClosed) {
        controller.addError(StateError('Entity state queue disposed'));
        unawaited(controller.close());
      }
    }

    for (final active in _activeJobs.values) {
      closeController(active.progressController);
      for (final c in active.fanOutControllers.values) {
        closeController(c);
      }
    }
    for (final queued in _queueLifo) {
      closeController(queued.progressController);
      for (final c in queued.fanOutControllers.values) {
        closeController(c);
      }
    }
    _activeJobs.clear();
    _queueLifo.clear();
  }

  Stream<EntityStateFetchEvent> enqueueJobFetchEntityState({
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
      _discardedActiveDuplicateSingleCount++;
      return existingSingleActive.progressStream;
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
      _processQueue();
      return queued.progressStream;
    }

    final bucket = _singleDebounceBuckets.putIfAbsent(
      scopeKey,
      () => _SingleEntityDebounceBucket(scopeKey: scopeKey, parentId: parentId),
    );

    final existingController = bucket.controllersById[entityId];
    if (existingController != null && !existingController.isClosed) {
      return existingController.stream;
    }

    final controller = StreamController<EntityStateFetchEvent>.broadcast();
    bucket.controllersById[entityId] = controller;

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
    return controller.stream;
  }

  Stream<EntityStateFetchEvent> enqueueJobFetchEntityStateCollection({
    required String domainType,
    required String domainId,
    required String entityType,
    String? parentId,
    int limit = 100,
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
      _processQueue();
      return queued.progressStream;
    }

    final key = _collectionJobKey(
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      parentId: parentId,
    );
    final active = _activeJobs[key];
    if (active != null) {
      _discardedActiveDuplicateCollectionCount++;
      return active.progressStream;
    }

    final controller = StreamController<EntityStateFetchEvent>.broadcast();
    final job = _EntityStateJob(
      jobKey: key,
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
      progressController: controller,
      enqueuedAt: DateTime.now().toUtc(),
      priority: _EntityStateJobPriority.normal,
      limit: limit,
      cursor: cursor,
    );

    _queueLifo.add(job);
    _processQueue();
    return controller.stream;
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
    if (bucket == null || bucket.controllersById.isEmpty) return;
    bucket.timer?.cancel();

    final ids = bucket.controllersById.keys.toList();
    if (ids.length == 1) {
      final entityId = ids.first;
      final controller = bucket.controllersById[entityId]!;
      final job = _EntityStateJob(
        jobKey: _singleJobKey(
          domainType: domainType,
          domainId: domainId,
          entityType: entityType,
          entityId: entityId,
          parentId: parentId,
        ),
        scopeKey: scopeKey,
        domainType: domainType,
        domainId: domainId,
        entityType: entityType,
        isCollection: false,
        entityId: entityId,
        parentId: parentId,
        progressController: controller,
        enqueuedAt: DateTime.now().toUtc(),
        priority: _EntityStateJobPriority.normal,
      );
      _queueLifo.add(job);
    } else {
      _mergedSingleBatchCount++;
      final batchController =
          StreamController<EntityStateFetchEvent>.broadcast();
      final job = _EntityStateJob(
        jobKey: _collectionJobKey(
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
        progressController: batchController,
        enqueuedAt: DateTime.now().toUtc(),
        priority: _EntityStateJobPriority.normal,
        fanOutControllers:
            Map<String, StreamController<EntityStateFetchEvent>>.from(
              bucket.controllersById,
            ),
      );
      _queueLifo.add(job);
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

    _emitProgress(
      job,
      EntityStateFetchEvent(
        domainType: job.domainType,
        domainId: job.domainId,
        entityType: job.entityType,
        entityId: job.entityId,
        parentId: job.parentId,
        items: items,
        hasMore: false,
        isCollectionRequest: false,
      ),
    );
    _complete(job);
  }

  Future<void> _runCollectionJob(_EntityStateJob job) async {
    var cursor = job.cursor;
    final pendingIds = job.fanOutControllers.keys.toSet();

    while (_enabled) {
      final response = await _fetchCollectionPage(job, cursor: cursor);
      final items = response.items;
      final nextCursor = response.cursor;
      final hasMore = response.hasMore;

      job.hasMore = hasMore;

      _emitProgress(
        job,
        EntityStateFetchEvent(
          domainType: job.domainType,
          domainId: job.domainId,
          entityType: job.entityType,
          parentId: job.parentId,
          items: items,
          cursor: nextCursor,
          hasMore: hasMore,
          isCollectionRequest: true,
        ),
      );

      if (job.fanOutControllers.isNotEmpty) {
        for (final item in items) {
          final id = _extractEntityId(item);
          if (id == null) continue;
          final controller = job.fanOutControllers[id];
          if (controller == null || controller.isClosed) continue;
          controller.add(
            EntityStateFetchEvent(
              domainType: job.domainType,
              domainId: job.domainId,
              entityType: job.entityType,
              entityId: id,
              parentId: job.parentId,
              items: [item],
              cursor: nextCursor,
              hasMore: hasMore,
              isCollectionRequest: true,
            ),
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
          scopeKey: job.scopeKey,
          domainType: job.domainType,
          domainId: job.domainId,
          entityType: job.entityType,
          isCollection: true,
          parentId: job.parentId,
          progressController: job.progressController,
          enqueuedAt: job.enqueuedAt,
          priority: _EntityStateJobPriority.low,
          limit: job.limit,
          cursor: nextCursor,
          fanOutControllers: job.fanOutControllers,
        );
        _enqueueLowPriority(continuation);
        return;
      }

      cursor = nextCursor;
    }

    if (cursor != null && cursor.isNotEmpty) {
      final continuation = _EntityStateJob(
        jobKey: job.jobKey,
        scopeKey: job.scopeKey,
        domainType: job.domainType,
        domainId: job.domainId,
        entityType: job.entityType,
        isCollection: true,
        parentId: job.parentId,
        progressController: job.progressController,
        enqueuedAt: job.enqueuedAt,
        priority: _EntityStateJobPriority.low,
        limit: job.limit,
        cursor: cursor,
        fanOutControllers: job.fanOutControllers,
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
    if (job.priority == _EntityStateJobPriority.low) {
      _queueLifo.insert(0, job);
    } else {
      _queueLifo.add(job);
    }
    _processQueue();
  }

  void _emitProgress(_EntityStateJob job, EntityStateFetchEvent event) {
    if (!job.progressController.isClosed) {
      job.progressController.add(event);
    }
  }

  void _complete(_EntityStateJob job) {
    if (!job.progressController.isClosed) {
      job.progressController.add(
        EntityStateFetchEvent(
          domainType: job.domainType,
          domainId: job.domainId,
          entityType: job.entityType,
          entityId: job.entityId,
          parentId: job.parentId,
          isCollectionRequest: job.isCollection,
          isComplete: true,
        ),
      );
      unawaited(job.progressController.close());
    }

    for (final entry in job.fanOutControllers.entries) {
      final controller = entry.value;
      if (controller.isClosed) continue;
      controller.add(
        EntityStateFetchEvent(
          domainType: job.domainType,
          domainId: job.domainId,
          entityType: job.entityType,
          entityId: entry.key,
          parentId: job.parentId,
          isCollectionRequest: true,
          isComplete: true,
        ),
      );
      unawaited(controller.close());
    }
  }

  void _emitError(_EntityStateJob job, String errorMessage) {
    if (!job.progressController.isClosed) {
      job.progressController.add(
        EntityStateFetchEvent(
          domainType: job.domainType,
          domainId: job.domainId,
          entityType: job.entityType,
          entityId: job.entityId,
          parentId: job.parentId,
          isCollectionRequest: job.isCollection,
          errorMessage: errorMessage,
        ),
      );
      unawaited(job.progressController.close());
    }

    for (final entry in job.fanOutControllers.entries) {
      final controller = entry.value;
      if (controller.isClosed) continue;
      controller.add(
        EntityStateFetchEvent(
          domainType: job.domainType,
          domainId: job.domainId,
          entityType: job.entityType,
          entityId: entry.key,
          parentId: job.parentId,
          isCollectionRequest: true,
          errorMessage: errorMessage,
        ),
      );
      unawaited(controller.close());
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
