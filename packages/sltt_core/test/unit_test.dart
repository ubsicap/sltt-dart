import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  group('Unit Tests', () {
    test('ChangeLogEntry model creation', () {
      final entry = ChangeLogEntry(
        projectId: 'test-project',
        entityType: EntityType.document,
        operation: 'create',
        changeAt: DateTime.now(),
        entityId: 'doc-123',
        dataJson: '{"title": "Test"}',
      );

      expect(entry.projectId, equals('test-project'));
      expect(entry.entityType, equals(EntityType.document));
      expect(entry.operation, equals('create'));
      expect(entry.entityId, equals('doc-123'));
      expect(entry.dataJson, equals('{"title": "Test"}'));
    });

    test('ChangeLogEntry toJson conversion', () {
      final entry = ChangeLogEntry(
        projectId: 'test-project',
        entityType: EntityType.document,
        operation: 'create',
        changeAt: DateTime.now(),
        entityId: 'doc-123',
        dataJson: '{"title": "Test"}',
      );

      final json = entry.toJson();
      expect(json['projectId'], equals('test-project'));
      expect(json['entityType'], equals('document'));
      expect(json['operation'], equals('create'));
      expect(json['entityId'], equals('doc-123'));
      expect(json['data'], isA<Map>());
    });

    test('server port constants', () {
      expect(kDownsyncsPort, isA<int>());
      expect(kOutsyncsPort, isA<int>());
      expect(kCloudStoragePort, isA<int>());

      // Ports should be different
      expect(kDownsyncsPort, isNot(equals(kOutsyncsPort)));
      expect(kDownsyncsPort, isNot(equals(kCloudStoragePort)));
      expect(kOutsyncsPort, isNot(equals(kCloudStoragePort)));

      // Ports should be in valid range
      expect(kDownsyncsPort, greaterThan(1000));
      expect(kOutsyncsPort, greaterThan(1000));
      expect(kCloudStoragePort, greaterThan(1000));
    });

    test('sync manager singleton pattern', () {
      final syncManager1 = SyncManager.instance;
      final syncManager2 = SyncManager.instance;

      expect(syncManager1, isNotNull);
      expect(syncManager2, isNotNull);
      expect(identical(syncManager1, syncManager2), isTrue);
    });

    test('multi server launcher singleton pattern', () {
      final launcher1 = MultiServerLauncher.instance;
      final launcher2 = MultiServerLauncher.instance;

      expect(launcher1, isNotNull);
      expect(launcher2, isNotNull);
      expect(identical(launcher1, launcher2), isTrue);
    });

    test('storage service singleton patterns', () {
      final outsyncs1 = OutsyncsStorageService.instance;
      final outsyncs2 = OutsyncsStorageService.instance;
      expect(identical(outsyncs1, outsyncs2), isTrue);

      final downsyncs1 = DownsyncsStorageService.instance;
      final downsyncs2 = DownsyncsStorageService.instance;
      expect(identical(downsyncs1, downsyncs2), isTrue);

      final cloud1 = CloudStorageService.instance;
      final cloud2 = CloudStorageService.instance;
      expect(identical(cloud1, cloud2), isTrue);
    });

    test('storage types enum', () {
      expect(StorageType.outsyncs, isNotNull);
      expect(StorageType.downsyncs, isNotNull);
      expect(StorageType.cloudStorage, isNotNull);

      // Test that we can create servers with different storage types
      final outsyncsServer = EnhancedRestApiServer(
        StorageType.outsyncs,
        'Test1',
      );
      final downsyncsServer = EnhancedRestApiServer(
        StorageType.downsyncs,
        'Test2',
      );
      final cloudServer = EnhancedRestApiServer(
        StorageType.cloudStorage,
        'Test3',
      );

      expect(outsyncsServer, isNotNull);
      expect(downsyncsServer, isNotNull);
      expect(cloudServer, isNotNull);
    });

    test('result class structures', () {
      final outsyncResult = OutsyncResult(
        success: true,
        syncedChanges: [],
        deletedLocalChanges: [],
        seqMap: {'1': 10, '2': 20},
        message: 'Test message',
      );

      expect(outsyncResult.success, isTrue);
      expect(outsyncResult.syncedChanges, isEmpty);
      expect(outsyncResult.deletedLocalChanges, isEmpty);
      expect(outsyncResult.seqMap, hasLength(2));
      expect(outsyncResult.message, equals('Test message'));

      final json = outsyncResult.toJson();
      expect(json['success'], isTrue);
      expect(json['seqMap'], equals({'1': 10, '2': 20}));
    });

    test('downsync result structure', () {
      final downsyncResult = DownsyncResult(
        success: true,
        newChanges: [
          {'test': 'data'},
        ],
        message: 'Downsync complete',
      );

      expect(downsyncResult.success, isTrue);
      expect(downsyncResult.newChanges, hasLength(1));
      expect(downsyncResult.message, equals('Downsync complete'));

      final json = downsyncResult.toJson();
      expect(json['success'], isTrue);
      expect(json['newChanges'], hasLength(1));
    });

    test('full sync result structure', () {
      final outsyncResult = OutsyncResult(
        success: true,
        syncedChanges: [],
        deletedLocalChanges: [],
        seqMap: {},
        message: 'Outsync done',
      );

      final downsyncResult = DownsyncResult(
        success: true,
        newChanges: [],
        message: 'Downsync done',
      );

      final fullSyncResult = FullSyncResult(
        outsyncResult: outsyncResult,
        downsyncResult: downsyncResult,
        success: true,
      );

      expect(fullSyncResult.success, isTrue);
      expect(fullSyncResult.outsyncResult, equals(outsyncResult));
      expect(fullSyncResult.downsyncResult, equals(downsyncResult));

      final json = fullSyncResult.toJson();
      expect(json['success'], isTrue);
      expect(json['outsyncResult'], isNotNull);
      expect(json['downsyncResult'], isNotNull);
    });

    test('sync status structure', () {
      final syncStatus = SyncStatus(
        outsyncsCount: 10,
        downsyncsCount: 5,
        cloudCount: 15,
        lastSyncTime: DateTime.now(),
      );

      expect(syncStatus.outsyncsCount, equals(10));
      expect(syncStatus.downsyncsCount, equals(5));
      expect(syncStatus.cloudCount, equals(15));
      expect(syncStatus.lastSyncTime, isA<DateTime>());

      final json = syncStatus.toJson();
      expect(json['outsyncsCount'], equals(10));
      expect(json['downsyncsCount'], equals(5));
      expect(json['cloudCount'], equals(15));
      expect(json['lastSyncTime'], isA<String>());
    });
  });
}
