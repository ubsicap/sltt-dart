import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import '../test_models.dart';
import 'in_memory_storage.dart';

void main() {
  SlttLogger.init();

  group('InMemoryStorage key composition', () {
    test('write then read returns persisted state', () async {
      final storage = InMemoryStorage(
        storageType: 'local',
        storageId: 'test-store',
      );
      await storage.initialize();

      final storedAt = DateTime.now().toUtc();
      final change = TestChangeLogEntry(
        cid: 'cid-test-1',
        entityId: 'entity-1',
        entityType: 'task',
        domainId: 'project-1',
        domainType: 'project',
        changeAt: DateTime.parse('2023-01-01T00:00:00Z'),
        changeBy: 'tester',
        dataJson: '{}',
        operation: 'create',
        storageId: 'required',
        stateChanged: true,
      );

      final stateUpdates = {
        'entityId': 'entity-1',
        'data_nameLocal': 'Persisted Task',
        'data_nameLocal_changeAt_': '2023-01-02T00:00:00Z',
        'entityType': 'task',
        'domainType': 'project',
        // change metadata (current and original) required by TestEntityState
        'change_storedAt': storedAt.toIso8601String(),
        'change_storedAt_orig_': storedAt.toIso8601String(),
        'change_domainId': 'project-1',
        'change_domainId_orig_': 'project-1',
        'change_changeAt': '2023-01-01T00:00:00Z',
        'change_changeAt_orig_': '2023-01-01T00:00:00Z',
        'change_cid': 'cid-test-1',
        'change_cid_orig_': 'cid-test-1',
        'change_changeBy': 'tester',
        'change_changeBy_orig_': 'tester',
        // parentId/prop metadata required by TestEntityState
        'data_parentId': 'root',
        'data_parentId_changeAt_': '2023-01-01T00:00:00Z',
        'data_parentId_cid_': 'cid-test-1',
        'data_parentId_changeBy_': 'tester',
        'data_parentProp': 'pList',
        'data_parentProp_changeAt_': '2023-01-01T00:00:00Z',
        'data_parentProp_cid_': 'cid-test-1',
        'data_parentProp_changeBy_': 'tester',
      };

      final res = await storage.updateChangeLogAndStates(
        domainType: 'project',
        changeLogEntry: change,
        changeUpdates: {'storedAt': storedAt.toIso8601String()},
        operationCounts: OperationCounts(),
        entityState: null,
        stateUpdates: stateUpdates,
      );

      expect(res.newEntityState, isNotNull);
      final persisted = await storage.getEntityState(
        domainType: 'project',
        domainId: 'project-1',
        entityType: 'task',
        entityId: 'entity-1',
      );

      expect(persisted, isNotNull);
      expect((persisted as TestEntityState).data_nameLocal, 'Persisted Task');
    });
  });
}
