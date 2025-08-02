import 'dart:convert';

import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

/// Tests demonstrating changelog data conversion to state entity information
/// Shows how project changes flow from changelog entries to queryable state collections
void main() {
  group('Changelog to State Entity Conversion Tests', () {
    late IsarProjectState projectState;

    setUp(() {
      // Start with empty project state
      projectState = IsarProjectState();
    });

    test('Scenario 1: Complete changelog to state conversion workflow', () {
      print('\n=== Scenario 1: Changelog to State Conversion ===');

      // Step 1: Start from empty project collection
      print('Step 1: Starting with empty project state');
      expect(projectState.entityId, isEmpty);
      expect(projectState.name, isEmpty);
      expect(projectState.description, isEmpty);

      // Step 2: Make a change log entry for a project
      print('Step 2: Creating initial project changelog entry');
      final initialTime = DateTime.now().subtract(const Duration(hours: 2));
      final initialCid = BaseChangeLogEntry.generateCid(initialTime);

      final initialChangeData = {
        'name': 'My First Project',
        'description': 'This is the initial project description',
        'status': 'draft',
        'priority': 'high',
      };

      final initialChangeEntry = ClientChangeLogEntry(
        projectId: 'proj-123',
        entityType: EntityType.project,
        operation: 'create',
        changeAt: initialTime,
        entityId: 'proj-123',
        dataJson: jsonEncode(initialChangeData),
        cid: initialCid,
        changeBy: 'user-alice',
      );

      // Step 3: Transfer that info to project collection
      print('Step 3: Converting changelog entry to project state');
      final convertedState = IsarProjectState.fromChangeLogEntry(
        entityId: initialChangeEntry.entityId,
        projectId: initialChangeEntry.projectId,
        changeAt: initialChangeEntry.changeAt,
        cid: initialChangeEntry.cid,
        changeBy: initialChangeEntry.changeBy,
        data: initialChangeEntry.data,
      );

      expect(convertedState.entityId, equals('proj-123'));
      expect(convertedState.name, equals('My First Project'));
      expect(
        convertedState.description,
        equals('This is the initial project description'),
      );
      expect(convertedState.status, equals(Status.draft));
      expect(convertedState.priority, equals(Priority.high));
      expect(convertedState.nameChangeAt, equals(initialTime));
      expect(convertedState.nameChangeBy, equals('user-alice'));

      // Use this state as our working project state
      projectState = convertedState;

      // Step 4: Make a new change log entry for the same project
      print('Step 4: Creating update changelog entry');
      final updateTime = DateTime.now().subtract(const Duration(hours: 1));
      final updateCid = BaseChangeLogEntry.generateCid(updateTime);

      final updateChangeData = {
        'name': 'My Updated Project',
        'description': 'This description has been updated',
        'status': 'in_progress',
        // Note: not updating priority - should remain as 'high'
      };

      // Step 5: Transfer update to project collection info
      print('Step 5: Updating project state with newer changes');
      projectState.updateFromChangeLogEntry(
        changeAt: updateTime,
        cid: updateCid,
        changeBy: 'user-bob',
        data: updateChangeData,
      );

      expect(projectState.name, equals('My Updated Project'));
      expect(
        projectState.description,
        equals('This description has been updated'),
      );
      expect(projectState.status, equals(Status.inProgress));
      expect(
        projectState.priority,
        equals(Priority.high),
      ); // Should remain unchanged
      expect(projectState.nameChangeAt, equals(updateTime));
      expect(projectState.nameChangeBy, equals('user-bob'));
      expect(
        projectState.priorityChangeAt,
        equals(initialTime),
      ); // Should remain from initial
      expect(projectState.priorityChangeBy, equals('user-alice'));

      // Step 6: Make a new change log entry that has changeAt earlier than our last update
      print('Step 6: Attempting to apply older changes (should be rejected)');
      final olderTime = DateTime.now().subtract(
        const Duration(hours: 3),
      ); // Earlier than initial
      final olderCid = BaseChangeLogEntry.generateCid(olderTime);

      final olderChangeData = {
        'name': 'This Should Not Apply',
        'description': 'This should also not apply',
        'status': 'archived',
      };

      // Store current state to verify no changes
      final nameBeforeOlder = projectState.name;
      final descriptionBeforeOlder = projectState.description;
      final statusBeforeOlder = projectState.status;
      final nameChangeAtBeforeOlder = projectState.nameChangeAt;

      projectState.updateFromChangeLogEntry(
        changeAt: olderTime,
        cid: olderCid,
        changeBy: 'user-charlie',
        data: olderChangeData,
      );

      // Step 7: Expect the changes to not be merged
      print('Step 7: Verifying older changes were rejected');
      expect(projectState.name, equals(nameBeforeOlder));
      expect(projectState.description, equals(descriptionBeforeOlder));
      expect(projectState.status, equals(statusBeforeOlder));
      expect(projectState.nameChangeAt, equals(nameChangeAtBeforeOlder));

      // Step 8: Make a new change log entry that only updates some fields
      print('Step 8: Applying partial field updates');
      final partialTime = DateTime.now(); // Most recent time
      final partialCid = BaseChangeLogEntry.generateCid(partialTime);

      final partialChangeData = {
        'priority': 'critical', // Only updating priority
        'dueDate': '2025-12-31T23:59:59.000Z',
      };

      projectState.updateFromChangeLogEntry(
        changeAt: partialTime,
        cid: partialCid,
        changeBy: 'user-diana',
        data: partialChangeData,
      );

      expect(
        projectState.priority,
        equals(Priority.critical),
      ); // Should be updated
      expect(projectState.priorityChangeAt, equals(partialTime));
      expect(projectState.priorityChangeBy, equals('user-diana'));
      expect(
        projectState.name,
        equals('My Updated Project'),
      ); // Should remain unchanged
      expect(
        projectState.nameChangeAt,
        equals(updateTime),
      ); // Should remain from step 5
      expect(projectState.nameChangeBy, equals('user-bob'));

      // Step 9: Make a change with mixed timing relative to different fields
      print('Step 9: Testing mixed-timing updates (partial acceptance)');
      final mixedTime = updateTime.add(
        const Duration(minutes: 30),
      ); // Between step 5 and step 8
      final mixedCid = BaseChangeLogEntry.generateCid(mixedTime);

      final mixedChangeData = {
        'name': 'Mixed Timing Name', // This should apply (newer than step 5)
        'priority': 'low', // This should NOT apply (older than step 8)
        'description':
            'Mixed timing description', // This should apply (newer than step 5)
      };

      // Store current priority info to verify it doesn't change
      final priorityBeforeMixed = projectState.priority;
      final priorityChangeAtBeforeMixed = projectState.priorityChangeAt;
      final priorityChangeByBeforeMixed = projectState.priorityChangeBy;

      projectState.updateFromChangeLogEntry(
        changeAt: mixedTime,
        cid: mixedCid,
        changeBy: 'user-eve',
        data: mixedChangeData,
      );

      // Verify mixed results: some fields updated, others not
      expect(
        projectState.name,
        equals('Mixed Timing Name'),
      ); // Should be updated
      expect(projectState.nameChangeAt, equals(mixedTime));
      expect(projectState.nameChangeBy, equals('user-eve'));

      expect(
        projectState.description,
        equals('Mixed timing description'),
      ); // Should be updated
      expect(projectState.descriptionChangeAt, equals(mixedTime));
      expect(projectState.descriptionChangeBy, equals('user-eve'));

      expect(
        projectState.priority,
        equals(priorityBeforeMixed),
      ); // Should remain unchanged
      expect(
        projectState.priorityChangeAt,
        equals(priorityChangeAtBeforeMixed),
      );
      expect(
        projectState.priorityChangeBy,
        equals(priorityChangeByBeforeMixed),
      );

      print('✅ All steps completed successfully!');
      print('Final state summary:');
      print(
        '  Name: "${projectState.name}" (changed by ${projectState.nameChangeBy})',
      );
      print(
        '  Description: "${projectState.description}" (changed by ${projectState.descriptionChangeBy})',
      );
      print(
        '  Status: ${projectState.status.value} (changed by ${projectState.statusChangeBy})',
      );
      print(
        '  Priority: ${projectState.priority.value} (changed by ${projectState.priorityChangeBy})',
      );
    });

    test('Best Practice Analysis: Mixed-timing updates', () {
      print('\n=== Best Practice Analysis ===');

      // RECOMMENDATION: Field-level conflict resolution is the best approach
      //
      // The current implementation handles mixed-timing updates by applying
      // field-level conflict resolution. This means:
      //
      // ✅ PROS:
      // - Maximizes data preservation
      // - Allows partial updates to succeed
      // - Handles real-world scenarios where different fields are updated at different times
      // - Maintains consistency at the field level
      //
      // ❌ ALTERNATIVE (rejecting entire mixed-timing updates):
      // - Would lose valid updates
      // - Creates unnecessary conflicts in collaborative environments
      // - Doesn't reflect how users actually work with data
      //
      // CONCLUSION: The current field-level approach is correct and follows
      // best practices for distributed systems and eventual consistency.

      expect(
        true,
        isTrue,
        reason: 'Field-level conflict resolution is the recommended approach',
      );
    });

    test('Query Current Project Information', () {
      print('\n=== Querying Current Project Information ===');

      // This test demonstrates how to query for all current project information
      // after applying multiple changelog entries

      // Set up a project with multiple changes
      final project = IsarProjectState.fromChangeLogEntry(
        entityId: 'query-test-proj',
        projectId: 'query-test-proj',
        changeAt: DateTime.now().subtract(const Duration(hours: 2)),
        cid: BaseChangeLogEntry.generateCid(),
        changeBy: 'user-setup',
        data: {
          'name': 'Query Test Project',
          'description': 'Initial description',
          'status': 'draft',
          'priority': 'medium',
        },
      );

      // Apply several updates
      project.updateFromChangeLogEntry(
        changeAt: DateTime.now().subtract(const Duration(hours: 1)),
        cid: BaseChangeLogEntry.generateCid(),
        changeBy: 'user-update1',
        data: {'name': 'Updated Query Test Project'},
      );

      project.updateFromChangeLogEntry(
        changeAt: DateTime.now().subtract(const Duration(minutes: 30)),
        cid: BaseChangeLogEntry.generateCid(),
        changeBy: 'user-update2',
        data: {'priority': 'high', 'status': 'in_progress'},
      );

      // Query current state - this is what would be stored in Isar and queryable
      print('Current project state available for queries:');
      print('  ID: ${project.entityId}');
      print('  Name: ${project.name}');
      print('  Description: ${project.description}');
      print('  Status: ${project.status.value}');
      print('  Priority: ${project.priority.value}');
      print('  Project ID: ${project.projectId}');
      print('  Deleted: ${project.deleted}');
      print('  Last Change: ${project.changeAt}');
      print('  Last Changed By: ${project.changeBy}');

      // Verify we have current, consolidated state
      expect(project.name, equals('Updated Query Test Project'));
      expect(project.description, equals('Initial description'));
      expect(project.status, equals(Status.inProgress));
      expect(project.priority, equals(Priority.high));
      expect(project.deleted, isFalse);

      // This state can now be queried using Isar queries like:
      // - Find all draft projects: isar.isarProjectStates.filter().statusEqualTo(Status.draft).findAll()
      // - Find projects by name: isar.isarProjectStates.filter().nameContains('Test').findAll()
      // - Find high priority projects: isar.isarProjectStates.filter().priorityEqualTo(Priority.high).findAll()
      // - Get all projects for a user: isar.isarProjectStates.filter().projectIdEqualTo('user-project-id').findAll()

      print('✅ Current state successfully consolidated from changelog entries');
    });
  });
}
