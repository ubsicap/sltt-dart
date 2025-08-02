import 'dart:convert';
import 'package:test/test.dart';
import '../lib/src/shared_storage_service.dart';
import '../lib/src/models/change_log_entry.dart';
import 'package:sltt_core/sltt_core.dart';

void main() {
  group('Step 4 Validation Tests', () {
    late CloudStorageService cloudStorage;

    setUpAll(() async {
      cloudStorage = CloudStorageService.instance;
      await cloudStorage.initialize();
    });

    tearDownAll(() async {
      await cloudStorage.close();
    });

    test('Project entity changelog_to_state integration works', () async {
      // Create a project changelog entry
      final changeLogEntry = ClientChangeLogEntry(
        projectId: 'test-project-step4',
        entityType: EntityType.project,
        operation: 'create',
        changeAt: DateTime.now().toUtc(),
        entityId: 'test-project-step4',
        dataJson: jsonEncode({
          'name': 'Step 4 Test Project',
          'description': 'Testing changelog to state integration',
        }),
        changeBy: 'test-user',
        cid: 'test-cid-123',
      );

      // Apply the changelog entry to state
      final projectState = await cloudStorage.applyChangelogToState(
        changeLogEntry,
      );

      // Verify the state was created correctly
      expect(projectState, isNotNull);
      expect(projectState.entityId, equals('test-project-step4'));
      expect(projectState.name, equals('Step 4 Test Project'));
      expect(
        projectState.description,
        equals('Testing changelog to state integration'),
      );

      // Verify we can retrieve the state
      final retrievedState = await cloudStorage.getProjectState(
        'test-project-step4',
      );
      expect(retrievedState, isNotNull);
      expect(retrievedState!.name, equals('Step 4 Test Project'));
    });

    test('Team entity changelog_to_state integration works', () async {
      // Create a team changelog entry
      final changeLogEntry = ClientChangeLogEntry(
        projectId: 'test-project-step4',
        entityType: EntityType.team,
        operation: 'create',
        changeAt: DateTime.now().toUtc(),
        entityId: 'test-team-step4',
        dataJson: jsonEncode({
          'name': 'Step 4 Test Team',
          'description': 'Testing team changelog to state integration',
        }),
        changeBy: 'test-user',
        cid: 'test-cid-456',
      );

      // Apply the changelog entry to state
      final teamState = await cloudStorage.applyChangelogToState(
        changeLogEntry,
      );

      // Verify the state was created correctly
      expect(teamState, isNotNull);
      expect(teamState.entityId, equals('test-team-step4'));
      expect(teamState.name, equals('Step 4 Test Team'));
      expect(
        teamState.description,
        equals('Testing team changelog to state integration'),
      );

      // Verify we can retrieve the state
      final retrievedState = await cloudStorage.getTeamState('test-team-step4');
      expect(retrievedState, isNotNull);
      expect(retrievedState!.name, equals('Step 4 Test Team'));
    });

    test('Unsupported entity types are rejected correctly', () async {
      // Create a document changelog entry (unsupported)
      final changeLogEntry = ClientChangeLogEntry(
        projectId: 'test-project-step4',
        entityType: EntityType.document,
        operation: 'create',
        changeAt: DateTime.now().toUtc(),
        entityId: 'test-document-step4',
        dataJson: jsonEncode({
          'title': 'Step 4 Test Document',
          'content': 'This should be rejected',
        }),
        changeBy: 'test-user',
        cid: 'test-cid-789',
      );

      // Attempt to apply the changelog entry to state
      expect(
        () async => await cloudStorage.applyChangelogToState(changeLogEntry),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
