import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:isar_community/isar.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/test_helpers/isar_change_log_serializer.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  late IsarStorageService storage;
  late String testDbName;

  setUpAll(() async {
    // Register IsarChangeLogEntry factory group for deserialization used by ChangeProcessingService
    registerIsarChangeLogSerializableGroup();
  });

  setUp(() async {
    testDbName =
        'test_seq_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 31)}';
    storage = IsarStorageService(testDbName, 'SeqTest');
    await storage.initialize();
  });

  tearDown(() async {
    await storage.close();
    final dir = Directory('./isar_db');
    if (await dir.exists()) {
      final files = await dir.list().toList();
      for (final file in files) {
        if (file.path.contains(testDbName)) {
          try {
            await file.delete();
          } catch (e) {
            // Ignore errors during cleanup
          }
        }
      }
    }
  });

  test('save auto-increments seq when autoIncrement provided', () async {
    final projectId = 'proj-seq-auto-inc';
    final payload = {
      'seq': Isar.autoIncrement,
      'domainId': projectId,
      'domainType': 'project',
      // Use a non-project entityType so entityId may differ from domainId in tests
      'entityType': 'task',
      'entityId': 'e-auto-inc-1',
      'changeBy': 'tester',
      'changeAt': DateTime.now().toUtc().toIso8601String(),
      'cid': 'cid-auto-inc-',
      'storageId': '',
      'operation': '',
      'operationInfoJson': '{}',
      'stateChanged': false,
      'unknownJson': '{}',
      // Include required task fields for IsarTaskState
      'dataJson': jsonEncode({
        'parentId': 'root',
        'parentProp': 'pList',
        'nameLocal': 'Auto Inc Task',
      }),
    };

    for (int i = 1; i <= 3; i++) {
      payload['cid'] = 'cid-auto-inc-$i';
      payload['entityId'] = 'e-auto-inc-$i';
      print(
        'Processing payload with cid: ${payload['cid']}, entityId: ${payload['entityId']}',
      );
      final r = await ChangeProcessingService.processChanges(
        storageMode: 'save',
        changes: [payload],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(r.isSuccess, isTrue, reason: r.errorMessage);
      final createdCid = r.resultsSummary!.created.first;
      final createdChange = await storage.getChange(
        domainType: 'project',
        domainId: projectId,
        cid: createdCid,
      );
      expect(createdChange, isNotNull);
      expect(createdChange!.seq, equals(i));
    }
  });

  test('save auto-increments seq when null', () async {
    final projectId = 'proj-seq-auto';
    final payload = {
      'seq': null,
      'domainId': projectId,
      'domainType': 'project',
      // Use a non-project entityType so entityId may differ from domainId in tests
      'entityType': 'task',
      'entityId': 'e-auto-1',
      'changeBy': 'tester',
      'changeAt': DateTime.now().toUtc().toIso8601String(),
      'cid': 'cid-auto-1',
      'storageId': '',
      'operation': 'create',
      'operationInfoJson': '{}',
      'stateChanged': false,
      'unknownJson': '{}',
      // Include required task fields for IsarTaskState
      'dataJson': jsonEncode({
        'parentId': 'root',
        'parentProp': 'pList',
        'nameLocal': 'Auto Task',
      }),
    };

    final r = await ChangeProcessingService.processChanges(
      storageMode: 'save',
      changes: [payload],
      srcStorageType: 'local',
      srcStorageId: 'local-client',
      storage: storage,
      includeChangeUpdates: false,
      includeStateUpdates: false,
    );
    expect(r.isSuccess, isTrue, reason: r.errorMessage);
    final createdCid = r.resultsSummary!.created.first;
    final createdChange = await storage.getChange(
      domainType: 'project',
      domainId: projectId,
      cid: createdCid,
    );
    expect(createdChange, isNotNull);
    expect(createdChange!.seq, equals(1));
  });

  test('deserialize uses autoIncrement when seq is absent or null', () {
    final deserializedSeqNull = null; // deserialize seq
    final projectId = 'proj-seq-explicit';
    final entityId = 'e-explicit-1';
    final changeAt = DateTime.now().toUtc();
    final payload = {
      'seq': deserializedSeqNull,
      'domainId': projectId,
      'domainType': 'project',
      // Use a non-project entityType so entityId may differ from domainId in tests
      'entityType': 'task',
      'entityId': entityId,
      'changeBy': 'tester',
      'changeAt': changeAt.toIso8601String(),
      'cid': 'cid-explicit-1',
      'storageId': '',
      'operation': 'create',
      'operationInfoJson': '{}',
      'stateChanged': false,
      'unknownJson': '{}',
      'dataJson': jsonEncode({
        'nameLocal': 'X',
        'parentId': 'root',
        'parentProp': 'pList',
      }),
    };

    final change = IsarChangeLogEntry.fromJson(payload);
    expect(change.seq, equals(Isar.autoIncrement));
  });

  test('deserialization preserves seq (before sync)', () {
    final deserializedSeq = 12345; // deserialize seq
    final projectId = 'proj-seq-explicit';
    final entityId = 'e-explicit-1';
    final changeAt = DateTime.now().toUtc();
    final payload = {
      'seq': deserializedSeq,
      'domainId': projectId,
      'domainType': 'project',
      // Use a non-project entityType so entityId may differ from domainId in tests
      'entityType': 'task',
      'entityId': entityId,
      'changeBy': 'tester',
      'changeAt': changeAt.toIso8601String(),
      'cid': 'cid-explicit-1',
      'storageId': '',
      'operation': 'create',
      'operationInfoJson': '{}',
      'stateChanged': false,
      'unknownJson': '{}',
      'dataJson': jsonEncode({
        'nameLocal': 'X',
        'parentId': 'root',
        'parentProp': 'pList',
      }),
    };

    final change = IsarChangeLogEntry.fromJson(payload);
    expect(change.seq, equals(deserializedSeq));
  });

  test('seq values increase monotonically for multiple saves', () async {
    final projectId = 'proj-seq-monotonic';
    final baseCid = DateTime.now().microsecondsSinceEpoch;
    final seqs = <int>[];
    for (int i = 0; i < 3; i++) {
      final payload = {
        'domainId': projectId,
        'domainType': 'project',
        // Use a non-project entityType so multiple different entityIds are allowed
        'entityType': 'task',
        'entityId': 'e-mon-$i',
        'changeBy': 'tester',
        'changeAt': DateTime.now().toUtc().toIso8601String(),
        'cid': 'cid-mon-$baseCid-$i',
        'storageId': '',
        'operation': 'create',
        'operationInfoJson': '{}',
        'stateChanged': false,
        'unknownJson': '{}',
        'dataJson': jsonEncode({
          'parentId': 'root',
          'parentProp': 'pList',
          'nameLocal': 'Mon $i',
        }),
      };

      final r = await ChangeProcessingService.processChanges(
        storageMode: 'save',
        changes: [payload],
        srcStorageType: 'local',
        srcStorageId: 'local-client',
        storage: storage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );
      expect(r.isSuccess, isTrue, reason: r.errorMessage);
      final createdCid = r.resultsSummary!.created.first;
      final createdChange = await storage.getChange(
        domainType: 'project',
        domainId: projectId,
        cid: createdCid,
      );
      expect(createdChange, isNotNull);
      seqs.add(createdChange!.seq);
    }

    expect(seqs.length, equals(3));
    // DB is fresh per test setup; expect first seq == 1 and incrementing by 1
    expect(seqs, equals([1, 2, 3]));
  });

  test('save-mode should reject positive caller-provided seq', () async {
    final cloud = CloudStorageService.instance;
    await cloud.initialize();
    await cloud.testResetDomainStorage(
      domainType: 'project',
      domainId: '__test_save_conflict',
    );

    final payload = {
      'seq': 9999,
      'changeAt': DateTime.now().toUtc().toIso8601String(),
      'cid': 'cid-save-conflict-1',
      'domainType': 'project',
      'domainId': '__test_save_conflict',
      'entityType': 'project',
      'operation': 'create',
      'entityId': '__test_save_conflict',
      'dataJson': stableStringify(
        BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
      ),
      'changeBy': 'tester',
      'stateChanged': true,
      'storageId': '',
      'unknownJson': '{}',
      'operationInfoJson': '{}',
    };

    final res = await ChangeProcessingService.processChanges(
      storageMode: 'save',
      changes: [payload],
      srcStorageType: 'cloud',
      srcStorageId: 'test-save-conflict',
      storage: cloud,
      includeChangeUpdates: true,
      includeStateUpdates: false,
    );

    // Desired behavior: save mode should reject a caller-provided seq that
    // conflicts with storage auto-increment. Assert we receive an error.
    expect(
      res.isSuccess,
      isFalse,
      reason: 'Save-mode should reject conflicting seq',
    );
  });

  test('sync-mode should reject negative seq', () async {
    final payload = {
      'seq': -1,
      'changeAt': DateTime.now().toUtc().toIso8601String(),
      'cid': 'cid-sync-nonpositive-1',
      'domainType': 'project',
      'domainId': '__test_sync_nonpositive',
      'entityType': 'project',
      'operation': 'create',
      'entityId': '__test_sync_nonpositive',
      'dataJson': stableStringify(
        BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
      ),
      'changeBy': 'tester',
      'stateChanged': true,
      'storageId': 'cloud-storage-1',
      'unknownJson': '{}',
      'operationInfoJson': '{}',
    };

    final res = await ChangeProcessingService.processChanges(
      storageMode: 'sync',
      changes: [payload],
      srcStorageType: 'cloud',
      srcStorageId: 'test-sync-nonpositive',
      storage: storage,
      includeChangeUpdates: true,
      includeStateUpdates: false,
    );

    // Desired behavior: sync mode should reject a non-positive seq.
    expect(
      res.isSuccess,
      isFalse,
      reason: 'Sync-mode should reject non-positive seq',
    );
  });

  test('sync-mode should reject 0 seq', () async {
    final payload = {
      'seq': 0,
      'changeAt': DateTime.now().toUtc().toIso8601String(),
      'cid': 'cid-sync-nonpositive-1',
      'domainType': 'project',
      'domainId': '__test_sync_nonpositive',
      'entityType': 'project',
      'operation': 'create',
      'entityId': '__test_sync_nonpositive',
      'dataJson': stableStringify(
        BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
      ),
      'changeBy': 'tester',
      'stateChanged': true,
      'storageId': 'cloud-storage-1',
      'unknownJson': '{}',
      'operationInfoJson': '{}',
    };

    final res = await ChangeProcessingService.processChanges(
      storageMode: 'sync',
      changes: [payload],
      srcStorageType: 'cloud',
      srcStorageId: 'test-sync-nonpositive',
      storage: storage,
      includeChangeUpdates: true,
      includeStateUpdates: false,
    );

    // Desired behavior: sync mode should reject a non-positive seq.
    expect(
      res.isSuccess,
      isFalse,
      reason: 'Sync-mode should reject non-positive seq',
    );
  });

  test('sync-mode should accept (but overwrite) positive seq', () async {
    final deserializedSeq = 12345; // Simulate a deserialized seq
    final change = IsarChangeLogEntry(
      seq: deserializedSeq,
      changeAt: DateTime.now().toUtc(),
      cid: 'cid-sync-1',
      domainType: 'project',
      domainId: '__test_sync_positive_seq',
      entityType: 'project',
      operation: 'create',
      entityId: '__test_sync_positive_seq',
      dataJson: stableStringify(
        BaseDataFields(parentId: 'root', parentProp: 'projects').toJson(),
      ),
      changeBy: 'tester',
      stateChanged: true,
      storageId: 'cloud-storage-1',
      unknownJson: '{}',
      operationInfoJson: '{}',
    );

    final res = await ChangeProcessingService.processChanges(
      storageMode: 'sync',
      changes: [change.toJson()],
      srcStorageType: 'cloud',
      srcStorageId: 'test-sync-authoritative',
      storage: storage,
      includeChangeUpdates: true,
      includeStateUpdates: false,
    );

    expect(res.isSuccess, isTrue, reason: res.errorMessage);

    final entries = await storage.getChangesWithCursor(
      domainType: 'project',
      domainId: '__test_sync_positive_seq',
    );
    expect(entries, isNotEmpty);
    final stored = entries.first as IsarChangeLogEntry;
    // In sync mode the payload seq should be preserved
    expect(stored.seq, isNot(deserializedSeq));
  });
}
