import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/test_helpers/isar_change_log_serializer.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  SlttLogger.init();

  group('[isar] EntityStatePaginationService integration (Isar cloud)', () {
    late String cloudBaseUrl;

    setUpAll(() async {
      registerIsarChangeLogSerializableGroup();
    });

    setUp(() async {
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
  });

  group('[aws_backend] EntityStatePaginationService integration', () {
    late String cloudBaseUrl;

    setUpAll(() async {
      registerIsarChangeLogSerializableGroup();
    });

    setUp(() async {
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
  const entityType = kEntityTypeMarker;
  const domainId = '__test_state_queue_debounce';

  if (useCloudDb) {
    await _resetDomainId(cloudBaseUrl, domainId);
  }

  final marker1 = generateCid(entityType: EntityType.marker, userId: 't1');
  final marker2 = generateCid(entityType: EntityType.marker, userId: 't2');
  final marker3 = generateCid(entityType: EntityType.marker, userId: 't3');

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
    data: {'name': 'marker-1', 'rank': '1'},
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
    data: {'name': 'marker-2', 'rank': '2'},
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
    data: {'name': 'marker-3', 'rank': '3'},
  );

  final service = EntityStatePaginationService(
    baseUrl: cloudBaseUrl,
    singleRequestDebounce: const Duration(milliseconds: 300),
    maxConcurrentRequests: 4,
  )..startProcessing();

  final eventsForFirst = <EntityStateFetchEvent>[];
  final eventsForSecond = <EntityStateFetchEvent>[];

  final firstDone = Completer<void>();
  final secondDone = Completer<void>();

  final sub1 = service
      .enqueueEntityState(
        domainType: domainType,
        domainId: domainId,
        entityType: entityType,
        entityId: marker1,
      )
      .listen((event) {
        eventsForFirst.add(event);
        if (event.isComplete && !firstDone.isCompleted) {
          firstDone.complete();
        }
      });

  final sub2 = service
      .enqueueEntityState(
        domainType: domainType,
        domainId: domainId,
        entityType: entityType,
        entityId: marker2,
      )
      .listen((event) {
        eventsForSecond.add(event);
        if (event.isComplete && !secondDone.isCompleted) {
          secondDone.complete();
        }
      });

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
    (i) => generateCid(entityType: EntityType.marker, userId: 'ym$i'),
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
      entityType: kEntityTypeMarker,
      entityId: markerIds[i],
      changeAt: now.add(Duration(milliseconds: i)),
      data: {'name': 'marker-$i', 'rank': '$i'},
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
  )..startProcessing();

  final collectionEvents = <EntityStateFetchEvent>[];
  final collectionDone = Completer<void>();
  final singleDone = Completer<void>();

  var collectionComplete = false;
  var singleCompletedBeforeCollection = false;
  var requestedSingleDuringCollection = false;

  late final StreamSubscription<EntityStateFetchEvent> collectionSub;
  collectionSub = service
      .enqueueEntityStateCollection(
        domainType: domainType,
        domainId: domainId,
        entityType: kEntityTypeMarker,
        limit: 1,
      )
      .listen((event) {
        collectionEvents.add(event);

        if (!requestedSingleDuringCollection &&
            !event.isComplete &&
            event.items.isNotEmpty) {
          requestedSingleDuringCollection = true;
          service
              .enqueueEntityState(
                domainType: domainType,
                domainId: domainId,
                entityType: kEntityTypeProject,
                entityId: projectId,
              )
              .listen((singleEvent) {
                if (singleEvent.isComplete && !singleDone.isCompleted) {
                  if (!collectionComplete) {
                    singleCompletedBeforeCollection = true;
                  }
                  singleDone.complete();
                }
              });
        }

        if (event.isComplete && !collectionDone.isCompleted) {
          collectionComplete = true;
          collectionDone.complete();
        }
      });

  await Future.wait([
    collectionDone.future.timeout(const Duration(seconds: 30)),
    singleDone.future.timeout(const Duration(seconds: 30)),
  ]);

  await collectionSub.cancel();

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
    singleCompletedBeforeCollection,
    isTrue,
    reason:
        'Expected prioritized single request to complete before the full collection pagination finishes.',
  );

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
  mergedData.putIfAbsent('parentId', () => domainId);
  mergedData.putIfAbsent(
    'parentProp',
    () => getCollectionByEntity(entityType) ?? '${entityType}s',
  );

  final parsedEntityType =
      EntityType.tryFromString(entityType) ?? EntityType.unknown;
  final cloudSaveChange =
      ChangeLogEntryFactoryService.forChangeSave<
        IsarChangeLogEntry,
        Id,
        UnknownDataFields
      >(
        factory: IsarChangeLogEntry.new,
        domainType: domainType,
        domainId: domainId,
        entityType: entityType,
        entityId: entityId,
        changeBy: 'test',
        changeAt: changeAt,
        cid: generateCid(entityType: parsedEntityType, userId: 'test'),
        data: UnknownDataFields.fromJson(mergedData),
        operation: kChangeOperationCreate,
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
