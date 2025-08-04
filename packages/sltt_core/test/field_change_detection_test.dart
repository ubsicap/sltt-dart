import 'dart:convert';

import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

/// Mock storage service for testing field change detection logic
class MockStorageService extends BaseStorageService {
  final Map<String, ChangeLogEntry> _entities = {};
  int _nextSeq = 1;

  @override
  Future<void> initialize() async {
    // Mock implementation - no initialization needed
  }

  @override
  Future<void> close() async {
    // Mock implementation - no cleanup needed
  }

  @override
  Future<ChangeLogEntry> createChange(Map<String, dynamic> changeData) async {
    final projectId = changeData['projectId'] as String;
    final entityTypeString = changeData['entityType'] as String;
    final entityType = EntityType.fromString(entityTypeString);
    final entityId = changeData['entityId'] as String;
    final operation = changeData['operation'] as String? ?? 'create';
    final data = changeData['data'] as Map<String, dynamic>? ?? {};
    final cid =
        changeData['cid'] as String? ?? BaseChangeLogEntry.generateCid();

    final change = ChangeLogEntry(
      projectId: projectId,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      dataJson: jsonEncode(data),
      changeAt: DateTime.now(),
      cid: cid,
      changeBy: 'test-user',
    );
    change.seq = _nextSeq++;

    // Store as current state for future lookups
    final key = '$projectId:$entityTypeString:$entityId';
    _entities[key] = change;

    return change;
  }

  @override
  Future<ChangeLogEntry?> getCurrentEntityState(
    String projectId,
    String entityType,
    String entityId,
  ) async {
    final key = '$projectId:$entityType:$entityId';
    return _entities[key];
  }

  // Required abstract methods from BaseStorageService
  @override
  Future<ChangeLogEntry?> getChange(String projectId, int seq) async {
    throw UnimplementedError();
  }

  @override
  Future<List<ChangeLogEntry>> getChangesWithCursor({
    required String projectId,
    int? cursor,
    int? limit,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<ChangeLogEntry>> getChangesSince(
    String projectId,
    int seq,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getChangeStats(String projectId) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getEntityTypeStats(String projectId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getAllProjects() async {
    throw UnimplementedError();
  }
}

void main() {
  group('Pure Field Change Detection Logic', () {
    late MockStorageService storage;

    setUp(() {
      storage = MockStorageService();
    });

    test('detects no-op changes correctly - exact same data structure', () async {
      const testProjectId = '_test_field_change_detection_exact';
      const entityId = 'doc-field-test-123';

      print('🧪 Testing pure field change detection logic');

      // 1. Create project using the exact same structure as debug_exact_test.dart
      final projectData = [
        {
          'projectId': testProjectId,
          'entityType': 'project',
          'operation': 'create',
          'entityId': testProjectId,
          'cid': BaseChangeLogEntry.generateCid(),
          'data': {
            'name': 'Field Detection Test Project',
            'description': 'Test project for field-level change detection',
          },
        },
      ];

      print('Creating project...');
      final projectResult = await storage.createChangesWithChangeDetection(
        projectData,
      );
      expect(projectResult.createdChanges, hasLength(1));
      expect(projectResult.noOpChangeCids, isEmpty);
      print('✅ Project created successfully');

      // 2. Create document with EXACT same structure as debug_exact_test.dart
      final documentData = [
        {
          'projectId': testProjectId,
          'entityType': 'document',
          'operation': 'create',
          'entityId': entityId,
          'cid': BaseChangeLogEntry.generateCid(),
          'data': {
            'title': 'Original Title',
            'content': 'Original content',
            'priority': 'high',
          },
        },
      ];

      print('Creating document...');
      final documentResult = await storage.createChangesWithChangeDetection(
        documentData,
      );
      expect(documentResult.createdChanges, hasLength(1));
      expect(documentResult.noOpChangeCids, isEmpty);

      // Verify create operation details
      final createCid = documentData[0]['cid'] as String;
      final createDetails = documentResult.changeDetails[createCid];
      expect(createDetails, isNotNull);
      expect(createDetails!.updatedFields, hasLength(3));
      expect(createDetails.noOpFields, isEmpty);
      expect(createDetails.totalFields, 3);
      print('✅ Document created with expected field details');

      // 3. Try no-op update with EXACT same structure as debug_exact_test.dart
      final noOpData = [
        {
          'projectId': testProjectId,
          'entityType': 'document',
          'operation': 'update',
          'entityId': entityId,
          'cid': BaseChangeLogEntry.generateCid(),
          'data': {
            'title': 'Original Title',
            'content': 'Original content',
            'priority': 'high',
          },
        },
      ];

      print('Attempting no-op update...');
      final noOpResult = await storage.createChangesWithChangeDetection(
        noOpData,
      );

      print(
        'No-op result: ${noOpResult.createdChanges.length} created, ${noOpResult.noOpChangeCids.length} no-ops',
      );

      // This should be detected as a no-op
      expect(
        noOpResult.createdChanges,
        isEmpty,
        reason: 'No changes should be created for no-op update',
      );
      expect(
        noOpResult.noOpChangeCids,
        hasLength(1),
        reason: 'Should detect one no-op change',
      );

      // Verify no-op details
      final noOpCid = noOpData[0]['cid'] as String;
      expect(noOpResult.noOpChangeCids, contains(noOpCid));

      final noOpDetails = noOpResult.changeDetails[noOpCid];
      expect(noOpDetails, isNotNull);
      expect(
        noOpDetails!.updatedFields,
        isEmpty,
        reason: 'No fields should be updated in no-op',
      );
      expect(
        noOpDetails.noOpFields,
        hasLength(3),
        reason: 'All 3 fields should be detected as no-ops',
      );
      expect(
        noOpDetails.noOpFields,
        containsAll(['title', 'content', 'priority']),
      );
      expect(noOpDetails.totalFields, 3);
      expect(noOpDetails.allNoOps, isTrue);

      print('✅ Pure field change detection logic works correctly!');
      print('   - Created changes: ${noOpResult.createdChanges.length}');
      print('   - No-op CIDs: ${noOpResult.noOpChangeCids}');
      print('   - No-op fields: ${noOpDetails.noOpFields}');
    });

    test('detects mixed changes correctly', () async {
      const testProjectId = '_test_mixed_changes';
      const entityId = 'mixed-test-123';

      // 1. Create initial document
      final createData = [
        {
          'projectId': testProjectId,
          'entityType': 'document',
          'operation': 'create',
          'entityId': entityId,
          'cid': BaseChangeLogEntry.generateCid(),
          'data': {
            'title': 'Original Title',
            'content': 'Original content',
            'priority': 'high',
            'status': 'draft',
          },
        },
      ];

      final createResult = await storage.createChangesWithChangeDetection(
        createData,
      );
      expect(createResult.createdChanges, hasLength(1));

      // 2. Update with mixed changes (some fields same, some different)
      final mixedData = [
        {
          'projectId': testProjectId,
          'entityType': 'document',
          'operation': 'update',
          'entityId': entityId,
          'cid': BaseChangeLogEntry.generateCid(),
          'data': {
            'title': 'Original Title', // Same - should be no-op
            'content': 'Updated content', // Different - should be updated
            'priority': 'high', // Same - should be no-op
            'status': 'published', // Different - should be updated
          },
        },
      ];

      final mixedResult = await storage.createChangesWithChangeDetection(
        mixedData,
      );

      // Should create a change since some fields are different
      expect(mixedResult.createdChanges, hasLength(1));
      expect(mixedResult.noOpChangeCids, isEmpty);

      final mixedCid = mixedData[0]['cid'] as String;
      final mixedDetails = mixedResult.changeDetails[mixedCid];
      expect(mixedDetails, isNotNull);
      expect(mixedDetails!.updatedFields, hasLength(2));
      expect(mixedDetails.updatedFields, containsAll(['content', 'status']));
      expect(mixedDetails.noOpFields, hasLength(2));
      expect(mixedDetails.noOpFields, containsAll(['title', 'priority']));
      expect(mixedDetails.totalFields, 4);

      print('✅ Mixed changes detected correctly');
      print('   - Updated fields: ${mixedDetails.updatedFields}');
      print('   - No-op fields: ${mixedDetails.noOpFields}');
    });

    test('value comparison works for various data types', () async {
      const testProjectId = '_test_value_comparison';
      const entityId = 'value-test-123';

      // Create initial document with various data types
      final createData = [
        {
          'projectId': testProjectId,
          'entityType': 'document',
          'operation': 'create',
          'entityId': entityId,
          'cid': BaseChangeLogEntry.generateCid(),
          'data': {
            'stringField': 'hello',
            'numberField': 42,
            'boolField': true,
            'nullField': null,
            'arrayField': [1, 2, 3],
            'objectField': {'nested': 'value', 'count': 5},
          },
        },
      ];

      await storage.createChangesWithChangeDetection(createData);

      // Update with exactly the same values
      final sameData = [
        {
          'projectId': testProjectId,
          'entityType': 'document',
          'operation': 'update',
          'entityId': entityId,
          'cid': BaseChangeLogEntry.generateCid(),
          'data': {
            'stringField': 'hello',
            'numberField': 42,
            'boolField': true,
            'nullField': null,
            'arrayField': [1, 2, 3],
            'objectField': {'nested': 'value', 'count': 5},
          },
        },
      ];

      final sameResult = await storage.createChangesWithChangeDetection(
        sameData,
      );
      expect(sameResult.createdChanges, isEmpty);
      expect(sameResult.noOpChangeCids, hasLength(1));

      final sameCid = sameData[0]['cid'] as String;
      final sameDetails = sameResult.changeDetails[sameCid];
      expect(sameDetails!.allNoOps, isTrue);
      expect(sameDetails.noOpFields, hasLength(6));

      print('✅ Value comparison works for all data types');
    });
  });
}
