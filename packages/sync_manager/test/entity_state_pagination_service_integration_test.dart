import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart' show Isar;
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/test_helpers/isar_change_log_serializer.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

const _testSpecificPersistencePrefix =
    '__test_specific_prefix_entity_state_pagination_integration';

void main() {
  SlttLogger.init();

  group('[isar] EntityStatePaginationService integration (Isar cloud)', () {
    late String cloudBaseUrl;

    setUpAll(() async {
      await _initializeIsarCoreForTests();
      registerIsarChangeLogSerializableGroup();
    });

    setUp(() async {
      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: _testSpecificPersistencePrefix,
      );

      final local = LocalStorageService.instance;
      await local.deleteDatabase();
      await local.initialize();

      final cloudStorage = CloudStorageService.instance;
      await cloudStorage.deleteDatabase();
      await cloudStorage.initialize();

      await MultiServerLauncher.instance.startServer(
        StorageType.cloud,
        kCloudStoragePort,
        storage: cloudStorage,
      );

      final addresses = MultiServerLauncher.instance.getServerAddresses();
      cloudBaseUrl = addresses['cloud']!;
    });

    tearDownAll(() async {
      await MultiServerLauncher.instance.stopServer(StorageType.cloud);
    });

    test(
      '[isar] debounced single requests merge into collection request',
      () async {
        await _testDebouncedSingleAggregation(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: 'isar-cloud-storage',
          srcStorageType: 'cloud',
          useCloudDb: false,
        );
      },
    );

    test(
      '[isar] debounced single requests with different parentId do not merge',
      () async {
        await _testDebouncedSingleAggregationByParentId(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: 'isar-cloud-storage',
          srcStorageType: 'cloud',
          useCloudDb: false,
        );
      },
    );

    test('[isar] collection requests include parentId filter', () async {
      await _testCollectionParentIdFilter(
        cloudBaseUrl: cloudBaseUrl,
        srcStorageId: 'isar-cloud-storage',
        srcStorageType: 'cloud',
        useCloudDb: false,
      );
    });

    test(
      '[isar] cursor pagination yields to incoming single requests',
      () async {
        await _testPaginationYieldBehavior(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: 'isar-cloud-storage',
          srcStorageType: 'cloud',
          useCloudDb: false,
        );
      },
    );

    test(
      '[isar] duplicate single enqueue: reuse active stream, bump queued priority',
      () async {
        await _testDuplicateSingleEnqueueBehavior(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: 'isar-cloud-storage',
          srcStorageType: 'cloud',
          useCloudDb: false,
        );
      },
    );

    test(
      '[isar] duplicate collection enqueue: reuse active stream, bump queued priority',
      () async {
        await _testDuplicateCollectionEnqueueBehavior(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: 'isar-cloud-storage',
          srcStorageType: 'cloud',
          useCloudDb: false,
        );
      },
    );
  });

  group('[aws_backend] EntityStatePaginationService integration', () {
    late String cloudBaseUrl;

    setUpAll(() async {});

    setUp(() async {
      await EntityStatePaginationService.deletePersistedJobsForWorkspacePrefix(
        workspacePrefix: _testSpecificPersistencePrefix,
      );

      final local = LocalStorageService.instance;
      await local.deleteDatabase();
      await local.initialize();
      cloudBaseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
    });

    test(
      '[aws_backend] debounced single requests merge into collection request',
      () async {
        await _testDebouncedSingleAggregation(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: 'aws-cloud-storage',
          srcStorageType: 'cloud',
          useCloudDb: true,
        );
      },
    );

    test(
      '[aws_backend] cursor pagination yields to incoming single requests',
      () async {
        await _testPaginationYieldBehavior(
          cloudBaseUrl: cloudBaseUrl,
          srcStorageId: 'aws-cloud-storage',
          srcStorageType: 'cloud',
          useCloudDb: true,
        );
      },
    );
  });
}

Future<void> _testDebouncedSingleAggregation({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  required bool useCloudDb,
}) async {
  const domainType = kDomainProject;
  const entityType = kEntityTypeTask;
  const domainId = '__test_state_queue_debounce';

  if (useCloudDb) {
    await _resetDomainId(cloudBaseUrl, domainId);
  }

  final marker1 = generateCid(entityType: EntityType.task, userId: 't1');
  final marker2 = generateCid(entityType: EntityType.task, userId: 't2');
  final marker3 = generateCid(entityType: EntityType.task, userId: 't3');
  const parentId = 'parent-merge';

  final now = DateTime.now().toUtc();
  await _saveCloudEntityChange(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageId: srcStorageId,
    srcStorageType: srcStorageType,
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    entityId: marker1,
    changeAt: now,
    data: {'nameLocal': 'task-1', 'rank': '1', 'parentId': parentId},
  );
  await _saveCloudEntityChange(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageId: srcStorageId,
    srcStorageType: srcStorageType,
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    entityId: marker2,
    changeAt: now.add(const Duration(milliseconds: 1)),
    data: {'nameLocal': 'task-2', 'rank': '2', 'parentId': parentId},
  );
  await _saveCloudEntityChange(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageId: srcStorageId,
    srcStorageType: srcStorageType,
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    entityId: marker3,
    changeAt: now.add(const Duration(milliseconds: 2)),
    data: {'nameLocal': 'task-3', 'rank': '3', 'parentId': parentId},
  );

  final service = EntityStatePaginationService(
    baseUrl: cloudBaseUrl,
    singleRequestDebounce: const Duration(milliseconds: 300),
    maxConcurrentRequests: 4,
    workspacePrefix: _testSpecificPersistencePrefix,
  );

  final eventsForFirst = <EntityStateFetchEvent>[];
  final eventsForSecond = <EntityStateFetchEvent>[];

  final firstDone = Completer<void>();
  final secondDone = Completer<void>();

  final requestKey1 = service.enqueueJobFetchEntityState(
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    entityId: marker1,
    parentId: parentId,
  );
  final requestKey2 = service.enqueueJobFetchEntityState(
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    entityId: marker2,
    parentId: parentId,
  );

  final sub1 = _listenForSingleRequest(service, requestKey1, (event) {
    eventsForFirst.add(event);
    if (event.isComplete && !firstDone.isCompleted) {
      firstDone.complete();
    }
  });

  final sub2 = _listenForSingleRequest(service, requestKey2, (event) {
    eventsForSecond.add(event);
    if (event.isComplete && !secondDone.isCompleted) {
      secondDone.complete();
    }
  });

  service.startProcessing();

  await Future.wait([
    firstDone.future.timeout(const Duration(seconds: 30)),
    secondDone.future.timeout(const Duration(seconds: 30)),
  ]);

  await sub1.cancel();
  await sub2.cancel();

  expect(
    service.mergedSingleBatchCount,
    greaterThanOrEqualTo(1),
    reason:
        'Expected debounced single entity requests for the same scope to be merged into a collection request.',
  );

  expect(
    _containsEntity(eventsForFirst, marker1),
    isTrue,
    reason: 'Expected first single stream to receive its requested entity.',
  );
  expect(
    _containsEntity(eventsForSecond, marker2),
    isTrue,
    reason: 'Expected second single stream to receive its requested entity.',
  );

  service.dispose();
}

Future<void> _testDebouncedSingleAggregationByParentId({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  required bool useCloudDb,
}) async {
  const domainType = kDomainProject;
  const entityType = kEntityTypeTask;
  const domainId = '__test_state_queue_debounce_parent';
  const parentIdA = 'parent-A';
  const parentIdB = 'parent-B';

  if (useCloudDb) {
    await _resetDomainId(cloudBaseUrl, domainId);
  }

  final markerA = generateCid(entityType: EntityType.task, userId: 'pa');
  final markerB = generateCid(entityType: EntityType.task, userId: 'pb');
  final now = DateTime.now().toUtc();

  await _saveCloudEntityChange(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageId: srcStorageId,
    srcStorageType: srcStorageType,
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    entityId: markerA,
    changeAt: now,
    data: {'nameLocal': 'task-parent-A', 'rank': '1', 'parentId': parentIdA},
  );
  await _saveCloudEntityChange(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageId: srcStorageId,
    srcStorageType: srcStorageType,
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    entityId: markerB,
    changeAt: now.add(const Duration(milliseconds: 1)),
    data: {'nameLocal': 'task-parent-B', 'rank': '2', 'parentId': parentIdB},
  );

  final service = EntityStatePaginationService(
    baseUrl: cloudBaseUrl,
    singleRequestDebounce: const Duration(milliseconds: 300),
    maxConcurrentRequests: 4,
    workspacePrefix: _testSpecificPersistencePrefix,
  );

  final firstDone = Completer<void>();
  final secondDone = Completer<void>();

  final requestKeyA = service.enqueueJobFetchEntityState(
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    entityId: markerA,
    parentId: parentIdA,
  );
  final requestKeyB = service.enqueueJobFetchEntityState(
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    entityId: markerB,
    parentId: parentIdB,
  );

  final sub1 = _listenForSingleRequest(service, requestKeyA, (event) {
    if (event.isComplete && !firstDone.isCompleted) {
      firstDone.complete();
    }
  });

  final sub2 = _listenForSingleRequest(service, requestKeyB, (event) {
    if (event.isComplete && !secondDone.isCompleted) {
      secondDone.complete();
    }
  });

  service.startProcessing();

  await Future.wait([
    firstDone.future.timeout(const Duration(seconds: 30)),
    secondDone.future.timeout(const Duration(seconds: 30)),
  ]);

  await sub1.cancel();
  await sub2.cancel();

  expect(
    service.mergedSingleBatchCount,
    equals(0),
    reason:
        'Single requests with different parentId should not be merged into a collection request.',
  );

  service.dispose();
}

Future<void> _testCollectionParentIdFilter({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  required bool useCloudDb,
}) async {
  const domainType = kDomainProject;
  const entityType = kEntityTypeTask;
  const domainId = '__test_state_collection_parent_filter';
  const targetParentId = 'parent-filter-target';
  const otherParentId = 'parent-filter-other';

  if (useCloudDb) {
    await _resetDomainId(cloudBaseUrl, domainId);
  }

  final now = DateTime.now().toUtc();
  final targetEntityIds = <String>[];
  for (var i = 0; i < 3; i++) {
    final id = generateCid(entityType: EntityType.task, userId: 'pt$i');
    targetEntityIds.add(id);
    await _saveCloudEntityChange(
      cloudBaseUrl: cloudBaseUrl,
      srcStorageId: srcStorageId,
      srcStorageType: srcStorageType,
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      entityId: id,
      changeAt: now.add(Duration(milliseconds: i)),
      data: {
        'nameLocal': 'target-$i',
        'rank': '$i',
        'parentId': targetParentId,
      },
    );
  }

  for (var i = 0; i < 2; i++) {
    final id = generateCid(entityType: EntityType.task, userId: 'po$i');
    await _saveCloudEntityChange(
      cloudBaseUrl: cloudBaseUrl,
      srcStorageId: srcStorageId,
      srcStorageType: srcStorageType,
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      entityId: id,
      changeAt: now.add(Duration(milliseconds: 10 + i)),
      data: {'nameLocal': 'other-$i', 'rank': '$i', 'parentId': otherParentId},
    );
  }

  final service = EntityStatePaginationService(
    baseUrl: cloudBaseUrl,
    maxConcurrentRequests: 4,
    workspacePrefix: _testSpecificPersistencePrefix,
  );

  final done = Completer<void>();
  final receivedIds = <String>{};

  final requestKey = service.enqueueJobFetchEntityStateCollection(
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    parentId: targetParentId,
    limit: 2,
  );

  final sub = _listenForCollectionRequest(service, requestKey, (event) {
    for (final item in event.items) {
      final id = item['entityId']?.toString() ?? item['id']?.toString();
      if (id != null && id.isNotEmpty) {
        receivedIds.add(id);
      }
    }

    if (event.isComplete && !done.isCompleted) {
      done.complete();
    }
  });

  service.startProcessing();

  await done.future.timeout(const Duration(seconds: 30));
  await sub.cancel();

  expect(
    receivedIds,
    equals(targetEntityIds.toSet()),
    reason:
        'Collection request with parentId should return all entities for that parentId.',
  );

  service.dispose();
}

Future<void> _testPaginationYieldBehavior({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  required bool useCloudDb,
}) async {
  const domainType = kDomainProject;
  const domainId = '__test_state_queue_yield';

  if (useCloudDb) {
    await _resetDomainId(cloudBaseUrl, domainId);
  }

  final markerIds = List.generate(
    4,
    (i) => generateCid(entityType: EntityType.task, userId: 'ym$i'),
  );
  final projectId = domainId;

  final now = DateTime.now().toUtc();
  for (var i = 0; i < markerIds.length; i++) {
    await _saveCloudEntityChange(
      cloudBaseUrl: cloudBaseUrl,
      srcStorageId: srcStorageId,
      srcStorageType: srcStorageType,
      domainType: domainType,
      domainId: domainId,
      entityType: kEntityTypeTask,
      entityId: markerIds[i],
      changeAt: now.add(Duration(milliseconds: i)),
      data: {'nameLocal': 'task-$i', 'rank': '$i'},
    );
  }

  await _saveCloudEntityChange(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageId: srcStorageId,
    srcStorageType: srcStorageType,
    domainType: domainType,
    domainId: domainId,
    entityType: kEntityTypeProject,
    entityId: projectId,
    changeAt: now.add(const Duration(seconds: 1)),
    data: {'nameLocal': 'project-priority', 'rank': '100'},
  );

  final service = EntityStatePaginationService(
    baseUrl: cloudBaseUrl,
    maxConcurrentRequests: 4,
    workspacePrefix: _testSpecificPersistencePrefix,
  );

  final collectionEvents = <EntityStateFetchEvent>[];
  final collectionDone = Completer<void>();
  final singleDone = Completer<void>();

  var requestedSingleDuringCollection = false;

  final collectionRequestKey = service.enqueueJobFetchEntityStateCollection(
    domainType: domainType,
    domainId: domainId,
    entityType: kEntityTypeTask,
    limit: 1,
  );

  StreamSubscription<EntityStateFetchEvent>? prioritizedSingleSub;

  late final StreamSubscription<EntityStateFetchEvent> collectionSub;
  collectionSub = _listenForCollectionRequest(service, collectionRequestKey, (
    event,
  ) {
    collectionEvents.add(event);

    if (!requestedSingleDuringCollection &&
        !event.isComplete &&
        event.items.isNotEmpty) {
      requestedSingleDuringCollection = true;
      final singleRequestKey = service.enqueueJobFetchEntityState(
        domainType: domainType,
        domainId: domainId,
        entityType: kEntityTypeProject,
        entityId: projectId,
      );
      prioritizedSingleSub = _listenForSingleRequest(
        service,
        singleRequestKey,
        (singleEvent) {
          if (singleEvent.isComplete && !singleDone.isCompleted) {
            singleDone.complete();
          }
        },
      );
    }

    if (event.isComplete && !collectionDone.isCompleted) {
      collectionDone.complete();
    }
  });

  service.startProcessing();

  await Future.wait([
    collectionDone.future.timeout(const Duration(seconds: 30)),
    singleDone.future.timeout(const Duration(seconds: 30)),
  ]);

  await collectionSub.cancel();
  await prioritizedSingleSub?.cancel();

  final pageEvents = collectionEvents.where((e) => !e.isComplete).toList();
  expect(
    pageEvents.length,
    greaterThanOrEqualTo(2),
    reason: 'Expected cursor recursion to fetch multiple pages.',
  );

  expect(
    service.yieldedActiveJobCount,
    greaterThanOrEqualTo(1),
    reason:
        'Expected active collection pager to yield when a new single request arrives.',
  );

  expect(
    requestedSingleDuringCollection,
    isTrue,
    reason:
        'Expected to enqueue a prioritized single request while collection pagination was active.',
  );

  service.dispose();
}

Future<void> _testDuplicateSingleEnqueueBehavior({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  required bool useCloudDb,
}) async {
  const domainType = kDomainProject;
  const entityType = kEntityTypeProject;
  const domainIdA = '__test_state_dup_single_A';
  const domainIdB = '__test_state_dup_single_B';

  if (useCloudDb) {
    await _resetDomainId(cloudBaseUrl, domainIdA);
    await _resetDomainId(cloudBaseUrl, domainIdB);
  }

  final now = DateTime.now().toUtc();
  await _saveCloudEntityChange(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageId: srcStorageId,
    srcStorageType: srcStorageType,
    domainType: domainType,
    domainId: domainIdA,
    entityType: entityType,
    entityId: domainIdA,
    changeAt: now,
    data: {'nameLocal': 'A', 'rank': '1'},
  );
  await _saveCloudEntityChange(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageId: srcStorageId,
    srcStorageType: srcStorageType,
    domainType: domainType,
    domainId: domainIdB,
    entityType: entityType,
    entityId: domainIdB,
    changeAt: now.add(const Duration(milliseconds: 1)),
    data: {'nameLocal': 'B', 'rank': '2'},
  );

  final delayedDio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          handler.next(options);
        },
      ),
    );

  final service = EntityStatePaginationService(
    baseUrl: cloudBaseUrl,
    maxConcurrentRequests: 1,
    singleRequestDebounce: const Duration(milliseconds: 1),
    dio: delayedDio,
    workspacePrefix: _testSpecificPersistencePrefix,
  );

  final completionOrder = <String>[];
  final doneA = Completer<void>();
  final doneB = Completer<void>();

  final requestKeyA = service.enqueueJobFetchEntityState(
    domainType: domainType,
    domainId: domainIdA,
    entityType: entityType,
    entityId: domainIdA,
  );
  final requestKeyB = service.enqueueJobFetchEntityState(
    domainType: domainType,
    domainId: domainIdB,
    entityType: entityType,
    entityId: domainIdB,
  );
  await Future<void>.delayed(const Duration(milliseconds: 20));
  service.enqueueJobFetchEntityState(
    domainType: domainType,
    domainId: domainIdA,
    entityType: entityType,
    entityId: domainIdA,
  );

  final subA = _listenForSingleRequest(service, requestKeyA, (event) {
    if (event.isComplete && !doneA.isCompleted) {
      completionOrder.add(domainIdA);
      doneA.complete();
    }
  });
  final subB = _listenForSingleRequest(service, requestKeyB, (event) {
    if (event.isComplete && !doneB.isCompleted) {
      completionOrder.add(domainIdB);
      doneB.complete();
    }
  });

  service.startProcessing();

  await Future.wait([
    doneA.future.timeout(const Duration(seconds: 30)),
    doneB.future.timeout(const Duration(seconds: 30)),
  ]);

  expect(
    completionOrder.first,
    equals(domainIdA),
    reason: 'Re-enqueued older single job should be bumped to top of LIFO.',
  );
  expect(
    service.requeuedQueuedDuplicateSingleCount,
    greaterThanOrEqualTo(1),
    reason:
        'Queued duplicate single should be re-enqueued instead of duplicated.',
  );

  const domainIdC = '__test_state_dup_single_C';
  await _saveCloudEntityChange(
    cloudBaseUrl: cloudBaseUrl,
    srcStorageId: srcStorageId,
    srcStorageType: srcStorageType,
    domainType: domainType,
    domainId: domainIdC,
    entityType: entityType,
    entityId: domainIdC,
    changeAt: now.add(const Duration(seconds: 1)),
    data: {'nameLocal': 'C', 'rank': '3'},
  );

  final activeSingleDone = Completer<void>();
  final activeSingleRequestKey = service.enqueueJobFetchEntityState(
    domainType: domainType,
    domainId: domainIdC,
    entityType: entityType,
    entityId: domainIdC,
  );
  final activeSub = _listenForSingleRequest(service, activeSingleRequestKey, (
    event,
  ) {
    if (event.isComplete && !activeSingleDone.isCompleted) {
      activeSingleDone.complete();
    }
  });

  await Future<void>.delayed(const Duration(milliseconds: 20));
  service.enqueueJobFetchEntityState(
    domainType: domainType,
    domainId: domainIdC,
    entityType: entityType,
    entityId: domainIdC,
  );
  await activeSingleDone.future.timeout(const Duration(seconds: 30));
  expect(
    service.ignoredDuplicateSingleRequestDuringActiveCount,
    greaterThanOrEqualTo(1),
    reason:
        'Duplicate single request during active should be ignored, reusing the active stream.',
  );

  await activeSub.cancel();
  await subA.cancel();
  await subB.cancel();
  service.dispose();
}

Future<void> _testDuplicateCollectionEnqueueBehavior({
  required String cloudBaseUrl,
  required String srcStorageId,
  required String srcStorageType,
  required bool useCloudDb,
}) async {
  const domainType = kDomainProject;
  const entityType = kEntityTypeTask;
  const domainIdA = '__test_state_dup_collection_A';
  const domainIdB = '__test_state_dup_collection_B';

  if (useCloudDb) {
    await _resetDomainId(cloudBaseUrl, domainIdA);
    await _resetDomainId(cloudBaseUrl, domainIdB);
  }

  final now = DateTime.now().toUtc();
  for (var i = 0; i < 3; i++) {
    await _saveCloudEntityChange(
      cloudBaseUrl: cloudBaseUrl,
      srcStorageId: srcStorageId,
      srcStorageType: srcStorageType,
      domainType: domainType,
      domainId: domainIdA,
      entityType: entityType,
      entityId: 'A_task_$i',
      changeAt: now.add(Duration(milliseconds: i)),
      data: {'nameLocal': 'A-$i', 'rank': '$i'},
    );
    await _saveCloudEntityChange(
      cloudBaseUrl: cloudBaseUrl,
      srcStorageId: srcStorageId,
      srcStorageType: srcStorageType,
      domainType: domainType,
      domainId: domainIdB,
      entityType: entityType,
      entityId: 'B_task_$i',
      changeAt: now.add(Duration(milliseconds: 10 + i)),
      data: {'nameLocal': 'B-$i', 'rank': '$i'},
    );
  }

  final service = EntityStatePaginationService(
    baseUrl: cloudBaseUrl,
    maxConcurrentRequests: 1,
    workspacePrefix: _testSpecificPersistencePrefix,
  );

  final firstPageDomains = <String>[];
  final doneA = Completer<void>();
  final doneB = Completer<void>();

  final requestKeyA = service.enqueueJobFetchEntityStateCollection(
    domainType: domainType,
    domainId: domainIdA,
    entityType: entityType,
    limit: 1,
  );
  final requestKeyB = service.enqueueJobFetchEntityStateCollection(
    domainType: domainType,
    domainId: domainIdB,
    entityType: entityType,
    limit: 1,
  );
  await Future<void>.delayed(const Duration(milliseconds: 20));
  service.enqueueJobFetchEntityStateCollection(
    domainType: domainType,
    domainId: domainIdA,
    entityType: entityType,
    limit: 1,
  );

  expect(
    service.requeuedQueuedDuplicateCollectionCount,
    greaterThanOrEqualTo(1),
    reason:
        'Queued duplicate collection should be re-enqueued and preserve pagination state.',
  );

  var activeDuplicateCollectionTriggered = false;

  final subA = _listenForCollectionRequest(service, requestKeyA, (event) {
    if (!event.isComplete &&
        event.items.isNotEmpty &&
        !firstPageDomains.contains(domainIdA)) {
      firstPageDomains.add(domainIdA);
    }
    if (!event.isComplete &&
        event.hasMore &&
        !activeDuplicateCollectionTriggered) {
      activeDuplicateCollectionTriggered = true;
      service.enqueueJobFetchEntityStateCollection(
        domainType: domainType,
        domainId: domainIdA,
        entityType: entityType,
        limit: 1,
      );
    }
    if (event.isComplete && !doneA.isCompleted) {
      doneA.complete();
    }
  });

  final subB = _listenForCollectionRequest(service, requestKeyB, (event) {
    if (!event.isComplete &&
        event.items.isNotEmpty &&
        !firstPageDomains.contains(domainIdB)) {
      firstPageDomains.add(domainIdB);
    }
    if (event.isComplete && !doneB.isCompleted) {
      doneB.complete();
    }
  });

  service.startProcessing();

  await Future.wait([
    doneA.future.timeout(const Duration(seconds: 30)),
    doneB.future.timeout(const Duration(seconds: 30)),
  ]);

  expect(
    firstPageDomains.first,
    equals(domainIdA),
    reason:
        'Re-enqueued older collection job should be bumped to top of LIFO before other queued collections.',
  );
  expect(
    service.ignoredDuplicateCollectionRequestDuringActiveCount,
    greaterThanOrEqualTo(1),
    reason:
        'Duplicate collection request during active should be ignored instead of creating a second in-flight job.',
  );

  await subA.cancel();
  await subB.cancel();
  service.dispose();
}

bool _containsEntity(List<EntityStateFetchEvent> events, String entityId) {
  for (final event in events) {
    for (final item in event.items) {
      final id = item['entityId']?.toString() ?? item['id']?.toString();
      if (id == entityId) {
        return true;
      }
    }
  }
  return false;
}

StreamSubscription<EntityStateFetchEvent> _listenForSingleRequest(
  EntityStatePaginationService service,
  String requestKey,
  void Function(EntityStateFetchEvent event) onData,
) {
  return service.singleEntityEvents
      .where((event) => event.requestKey == requestKey)
      .listen(onData);
}

StreamSubscription<EntityStateFetchEvent> _listenForCollectionRequest(
  EntityStatePaginationService service,
  String requestKey,
  void Function(EntityStateFetchEvent event) onData,
) {
  return service.collectionEntityEvents
      .where((event) => event.requestKey == requestKey)
      .listen(onData);
}

Future<void> _saveCloudEntityChange({
  required String cloudBaseUrl,
  required String srcStorageType,
  required String srcStorageId,
  required String domainType,
  required String domainId,
  required String entityType,
  required String entityId,
  required DateTime changeAt,
  required Map<String, dynamic> data,
}) async {
  final mergedData = <String, dynamic>{...data};
  // BaseDataFields requires parentId + parentProp for all entity payloads.
  if ((mergedData['parentId']?.toString().trim().isEmpty ?? true)) {
    mergedData['parentId'] = domainId;
  }
  if ((mergedData['parentProp']?.toString().trim().isEmpty ?? true)) {
    mergedData['parentProp'] =
        getCollectionByEntity(entityType) ?? '${entityType}s';
  }

  final parsedEntityType =
      EntityType.tryFromString(entityType) ?? EntityType.unknown;
  final cloudSaveChange = IsarChangeLogEntry(
    cid: generateCid(entityType: parsedEntityType, userId: 'test'),
    domainType: domainType,
    domainId: domainId,
    entityType: entityType,
    entityId: entityId,
    changeBy: 'test',
    changeAt: changeAt,
    operation: kChangeOperationCreate,
    dataJson: jsonEncode(mergedData),
    storageId: '',
    stateChanged: false,
  );

  final request = CreateChangesRequest(
    changes: [cloudSaveChange],
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
    storageMode: 'save',
  );

  final response = await http.post(
    Uri.parse('$cloudBaseUrl/api/changes'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(request.toJson()),
  );

  expect(
    response.statusCode,
    anyOf([200, 201]),
    reason:
        'Saving cloud change via HTTP should succeed, got ${response.statusCode}: ${response.body}',
  );

  final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
  expect(
    responseBody['errors'],
    isEmpty,
    reason: 'Cloud change save should have no errors: ${response.body}',
  );
}

Future<void> _initializeIsarCoreForTests() async {
  await Isar.initializeIsarCore(download: true);
  // final localAppData = Platform.environment['LOCALAPPDATA'];
  // if (localAppData == null || localAppData.isEmpty) {
  //   throw StateError('LOCALAPPDATA is required to locate Isar test DLLs.');
  // }

  // final hostedPub = Directory('$localAppData\\Pub\\Cache\\hosted\\pub.dev');
  // if (!hostedPub.existsSync()) {
  //   throw StateError('Pub cache not found: ${hostedPub.path}');
  // }

  // File? sourceDll;
  // for (final entry in hostedPub.listSync()) {
  //   if (entry is! Directory) continue;
  //   final name = p.basename(entry.path);
  //   if (!name.startsWith('isar_flutter_libs-') && !name.startsWith('isar-')) {
  //     continue;
  //   }
  //   final candidate = File(p.join(entry.path, 'windows', 'isar.dll'));
  //   if (candidate.existsSync()) {
  //     sourceDll = candidate;
  //     break;
  //   }
  // }

  // if (sourceDll == null) {
  //   throw StateError('Could not locate isar.dll in pub cache.');
  // }

  // final stableDir = Directory(p.join(Directory.systemTemp.path, 'sltt_isar'));
  // stableDir.createSync(recursive: true);
  // final stableDll = File(p.join(stableDir.path, 'libisar.dll'));
  // sourceDll.copySync(stableDll.path);

  // await Isar.initializeIsarCore(libraries: {Abi.current(): stableDll.path});
}

Future<void> _resetDomainId(
  String baseUrl,
  String domainId, {
  String domainCollection = kCollectionProject,
}) async {
  final result = await http.delete(
    Uri.parse('$baseUrl/api/storage/__test/reset/$domainCollection/$domainId'),
  );
  expect(
    result.statusCode,
    equals(200),
    reason:
        'Resetting test domain $domainId should return HTTP 200, but got ${result.statusCode}: ${result.body}',
  );
}
