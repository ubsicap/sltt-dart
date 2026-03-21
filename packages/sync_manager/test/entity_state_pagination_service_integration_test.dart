import 'dart:async';
import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/test_helpers/isar_change_log_serializer.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  SlttLogger.init();

  group('[isar] EntityStatePaginationService integration (Isar cloud)', () {
    late String cloudBaseUrl;

    setUpAll(() async {
      await _initializeIsarCoreForTests();
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

    setUpAll(() async {});

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
  const entityType = kEntityTypeTask;
  const domainId = '__test_state_queue_debounce';

  if (useCloudDb) {
    await _resetDomainId(cloudBaseUrl, domainId);
  }

  final marker1 = generateCid(entityType: EntityType.task, userId: 't1');
  final marker2 = generateCid(entityType: EntityType.task, userId: 't2');
  final marker3 = generateCid(entityType: EntityType.task, userId: 't3');

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
    data: {'nameLocal': 'task-1', 'rank': '1'},
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
    data: {'nameLocal': 'task-2', 'rank': '2'},
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
    data: {'nameLocal': 'task-3', 'rank': '3'},
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
  )..startProcessing();

  final collectionEvents = <EntityStateFetchEvent>[];
  final collectionDone = Completer<void>();
  final singleDone = Completer<void>();

  var collectionComplete = false;
  var requestedSingleDuringCollection = false;

  late final StreamSubscription<EntityStateFetchEvent> collectionSub;
  collectionSub = service
      .enqueueEntityStateCollection(
        domainType: domainType,
        domainId: domainId,
        entityType: kEntityTypeTask,
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
    requestedSingleDuringCollection,
    isTrue,
    reason:
        'Expected to enqueue a prioritized single request while collection pagination was active.',
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
  final localAppData = Platform.environment['LOCALAPPDATA'];
  if (localAppData == null || localAppData.isEmpty) {
    throw StateError('LOCALAPPDATA is required to locate Isar test DLLs.');
  }

  final hostedPub = Directory('$localAppData\\Pub\\Cache\\hosted\\pub.dev');
  if (!hostedPub.existsSync()) {
    throw StateError('Pub cache not found: ${hostedPub.path}');
  }

  File? sourceDll;
  for (final entry in hostedPub.listSync()) {
    if (entry is! Directory) continue;
    final name = p.basename(entry.path);
    if (!name.startsWith('isar_flutter_libs-') && !name.startsWith('isar-')) {
      continue;
    }
    final candidate = File(p.join(entry.path, 'windows', 'isar.dll'));
    if (candidate.existsSync()) {
      sourceDll = candidate;
      break;
    }
  }

  if (sourceDll == null) {
    throw StateError('Could not locate isar.dll in pub cache.');
  }

  final stableDir = Directory(p.join(Directory.systemTemp.path, 'sltt_isar'));
  stableDir.createSync(recursive: true);
  final stableDll = File(p.join(stableDir.path, 'libisar.dll'));
  sourceDll.copySync(stableDll.path);

  await Isar.initializeIsarCore(libraries: {Abi.current(): stableDll.path});
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
