import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/isar_storage_service.dart';
import 'package:sync_manager/src/models/isar_change_log_entry.dart';
import 'package:sync_manager/src/test_helpers/isar_change_log_serializer.dart';
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

  test('auto-increments seq when not provided', () async {
    final projectId = 'proj-seq-auto';
    final payload = {
      'domainId': projectId,
      'domainType': 'project',
      'entityType': 'project',
      'entityId': 'e-auto-1',
      'changeBy': 'tester',
      'changeAt': DateTime.now().toUtc().toIso8601String(),
      'cid': 'cid-auto-1',
      'storageId': '',
      'operation': 'create',
      'operationInfoJson': '{}',
      'stateChanged': false,
      'unknownJson': '{}',
      'dataJson': jsonEncode({'parentId': 'root', 'parentProp': 'pList'}),
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
    expect(createdChange!.seq, greaterThan(0));
  });

  test('honors explicit seq when provided', () async {
    final projectId = 'proj-seq-explicit';
    final entityId = 'e-explicit-1';
    final changeAt = DateTime.now().toUtc();
    final payload = {
      'domainId': projectId,
      'domainType': 'project',
      'entityType': 'project',
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

    final result = await storage.updateChangeLogAndState(
      domainType: 'project',
      changeLogEntry: change,
      changeUpdates: {'seq': 42, 'stateChanged': true},
      stateUpdates: {
        'domainType': 'project',
        'entityId': entityId,
        'entityType': 'project',
        'change_domainId': projectId,
        'change_changeAt': changeAt.toIso8601String(),
        'change_cid': change.cid,
        'change_changeBy': 'tester',
        'change_domainId_orig_': '',
        'change_changeAt_orig_': BaseEntityState.defaultOrigDateTime()
            .toIso8601String(),
        'change_cid_orig_': '',
        'change_changeBy_orig_': '',
        'data_nameLocal': 'X',
        'data_parentId': 'root',
        'data_parentId_changeAt_': changeAt.toIso8601String(),
        'data_parentId_cid_': change.cid,
        'data_parentId_changeBy_': 'tester',
        'data_parentProp': 'pList',
        'data_parentProp_dataSchemaRev_': 0,
        'data_parentProp_changeAt_': changeAt.toIso8601String(),
        'data_parentProp_cid_': change.cid,
        'data_parentProp_changeBy_': 'tester',
        'unknownJson': '{}',
      },
    );

    expect(result.newChangeLogEntry.seq, equals(42));
  });

  test('seq values increase monotonically for multiple inserts', () async {
    final projectId = 'proj-seq-monotonic';
    final baseCid = DateTime.now().microsecondsSinceEpoch;
    final seqs = <int>[];
    for (int i = 0; i < 3; i++) {
      final payload = {
        'domainId': projectId,
        'domainType': 'project',
        'entityType': 'project',
        'entityId': 'e-mon-$i',
        'changeBy': 'tester',
        'changeAt': DateTime.now().toUtc().toIso8601String(),
        'cid': 'cid-mon-$baseCid-$i',
        'storageId': '',
        'operation': 'create',
        'operationInfoJson': '{}',
        'stateChanged': false,
        'unknownJson': '{}',
        'dataJson': jsonEncode({'parentId': 'root', 'parentProp': 'pList'}),
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
    expect(seqs[0] < seqs[1] && seqs[1] < seqs[2], isTrue);
  });
}
