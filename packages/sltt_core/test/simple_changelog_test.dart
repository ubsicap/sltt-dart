import 'dart:convert';

import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

/// Simple test to verify changelog to state conversion basics
void main() {
  group('Simple Changelog to State Tests', () {
    test('BaseEntityState creation and updates', () {
      print('Testing BaseEntityState operations...');

      // Create a base entity state
      final baseState = BaseEntityState();
      baseState.entityId = 'test-entity-123';
      baseState.entityType = EntityType.project;
      baseState.projectId = 'proj-456';

      expect(baseState.entityId, equals('test-entity-123'));
      expect(baseState.entityType, equals(EntityType.project));
      expect(baseState.projectId, equals('proj-456'));

      print('✅ BaseEntityState creation works');
    });

    test('ChangeLogEntry creation', () {
      print('Testing ChangeLogEntry creation...');

      final changeData = {
        'name': 'Test Project',
        'description': 'A test project',
      };

      final entry = ClientChangeLogEntry(
        projectId: 'proj-123',
        entityType: EntityType.project,
        operation: 'create',
        changeAt: DateTime.now(),
        entityId: 'proj-123',
        dataJson: jsonEncode(changeData),
        cid: BaseChangeLogEntry.generateCid(),
        changeBy: 'test-user',
      );

      expect(entry.projectId, equals('proj-123'));
      expect(entry.entityType, equals(EntityType.project));
      expect(entry.operation, equals('create'));
      expect(entry.changeBy, equals('test-user'));

      final data = entry.getData();
      expect(data['name'], equals('Test Project'));
      expect(data['description'], equals('A test project'));

      print('✅ ChangeLogEntry creation works');
    });

    test('BaseEntityState.fromChangeLogEntry factory', () {
      print('Testing BaseEntityState factory method...');

      final changeData = {
        'rank': '1.0',
        'deleted': false,
        'parentId': 'parent-123',
      };

      final baseState = BaseEntityState.fromChangeLogEntry(
        entityId: 'entity-789',
        entityType: EntityType.project,
        projectId: 'proj-789',
        changeAt: DateTime.now(),
        cid: BaseChangeLogEntry.generateCid(),
        changeBy: 'factory-user',
        data: changeData,
      );

      expect(baseState.entityId, equals('entity-789'));
      expect(baseState.entityType, equals(EntityType.project));
      expect(baseState.projectId, equals('proj-789'));
      expect(baseState.rank, equals('1.0'));
      expect(baseState.deleted, equals(false));
      expect(baseState.parentId, equals('parent-123'));
      expect(baseState.changeBy, equals('factory-user'));

      // Debug output
      print('Debug: parentId = "${baseState.parentId}"');
      print('Debug: parentIdChangeBy = "${baseState.parentIdChangeBy}"');

      print('✅ BaseEntityState factory method works');
    });

    test('BaseEntityState conflict resolution', () {
      print('Testing BaseEntityState conflict resolution...');

      final time1 = DateTime.now().subtract(const Duration(hours: 2));
      final time2 = DateTime.now().subtract(const Duration(hours: 1));
      final time3 = DateTime.now(); // Most recent

      // Create initial state
      final baseState = BaseEntityState.fromChangeLogEntry(
        entityId: 'conflict-test',
        entityType: EntityType.project,
        projectId: 'proj-conflict',
        changeAt: time1,
        cid: BaseChangeLogEntry.generateCid(time1),
        changeBy: 'user1',
        data: {'rank': '1.0', 'parentId': 'parent1'},
      );

      print('After initial creation:');
      print('  rank: "${baseState.rank}" by ${baseState.rankChangeBy}');
      print(
        '  parentId: "${baseState.parentId}" by ${baseState.parentIdChangeBy}',
      );

      // Apply newer change
      baseState.updateFromChangeLogEntry(
        changeAt: time2,
        cid: BaseChangeLogEntry.generateCid(time2),
        changeBy: 'user2',
        data: {'rank': '2.0'}, // Only update rank
      );

      print('After rank update:');
      print('  rank: "${baseState.rank}" by ${baseState.rankChangeBy}');
      print(
        '  parentId: "${baseState.parentId}" by ${baseState.parentIdChangeBy}',
      );
      expect(baseState.rank, equals('2.0'));
      expect(baseState.rankChangeBy, equals('user2'));
      expect(baseState.parentId, equals('parent1')); // Should remain unchanged
      expect(baseState.parentIdChangeBy, equals('user1'));

      // Try to apply older change (should be rejected)
      final oldTime = time1.subtract(const Duration(hours: 1));
      baseState.updateFromChangeLogEntry(
        changeAt: oldTime,
        cid: BaseChangeLogEntry.generateCid(oldTime),
        changeBy: 'user3',
        data: {'rank': '0.5'},
      );

      expect(baseState.rank, equals('2.0')); // Should remain unchanged
      expect(baseState.rankChangeBy, equals('user2'));

      // Apply newest change to different field
      baseState.updateFromChangeLogEntry(
        changeAt: time3,
        cid: BaseChangeLogEntry.generateCid(time3),
        changeBy: 'user4',
        data: {'parentId': 'parent3'},
      );

      expect(baseState.rank, equals('2.0')); // Should remain unchanged
      expect(baseState.rankChangeBy, equals('user2'));
      expect(baseState.parentId, equals('parent3')); // Should be updated
      expect(baseState.parentIdChangeBy, equals('user4'));

      print('✅ BaseEntityState conflict resolution works correctly');
    });
  });
}
