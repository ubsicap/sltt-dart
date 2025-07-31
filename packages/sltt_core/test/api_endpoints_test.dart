import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  group('API Endpoints Tests', () {
    late EnhancedRestApiServer server;
    late Dio dio;
    const int testPort = 8080;
    const String baseUrl = 'http://localhost:$testPort';

    setUpAll(() async {
      server = EnhancedRestApiServer(StorageType.outsyncs, 'Test Server');
      await server.start(port: testPort);

      dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      // Wait for server to be ready
      await Future.delayed(const Duration(milliseconds: 500));
    });

    tearDownAll(() async {
      await server.stop();
    });

    test('health endpoint', () async {
      final response = await dio.get('$baseUrl/health');

      expect(response.statusCode, equals(200));
      expect(response.data['status'], equals('healthy'));
      expect(response.data['server'], equals('Test Server'));
    });

    test('API help endpoint', () async {
      final response = await dio.get('$baseUrl/api/help');

      expect(response.statusCode, equals(200));

      final helpData = response.data as Map<String, dynamic>;
      expect(helpData['server'], isNotNull);
      expect(helpData['endpoints'], isA<List>());

      final endpoints = helpData['endpoints'] as List;
      expect(endpoints, isNotEmpty);

      // Check for key endpoints
      final endpointPaths = endpoints.map((e) => e['path']).toList();
      expect(endpointPaths, contains('/health'));
      expect(endpointPaths, contains('/api/projects'));
      expect(endpointPaths, contains('/api/changes'));
    });

    test('projects endpoint', () async {
      // First create some project changes
      final projectChanges = [
        {
          'projectId': 'project-alpha',
          'entityType': 'project',
          'operation': 'create',
          'entityId': 'project-alpha',
          'data': {
            'name': 'Alpha Project',
            'description': 'First test project',
          },
        },
        {
          'projectId': 'project-beta',
          'entityType': 'project',
          'operation': 'create',
          'entityId': 'project-beta',
          'data': {
            'name': 'Beta Project',
            'description': 'Second test project',
          },
        },
      ];

      for (final change in projectChanges) {
        final response = await dio.post('$baseUrl/api/changes', data: [change]);
        expect(response.statusCode, equals(200));
      }

      // Test projects endpoint
      final projectsResponse = await dio.get('$baseUrl/api/projects');
      expect(projectsResponse.statusCode, equals(200));

      final projectsData = projectsResponse.data as Map<String, dynamic>;
      expect(projectsData['projects'], isA<List>());
      expect(projectsData['count'], isA<int>());

      final projects = projectsData['projects'] as List<dynamic>;
      expect(projects, contains('project-alpha'));
      expect(projects, contains('project-beta'));
    });

    test('project-specific endpoints with URL encoding', () async {
      final testProjectIds = [
        'test-project-123', // Simple case
        'org/team/project', // With forward slashes
        'project@domain.com', // With @ symbol
        'my project name', // With spaces
        'project-v1.2.3+build_456', // With + symbol
      ];

      for (final projectId in testProjectIds) {
        final encodedProjectId = Uri.encodeComponent(projectId);

        // Create a test change
        final changeData = [
          {
            'projectId': projectId,
            'entityType': 'Document',
            'operation': 'create',
            'entityId': 'doc-${DateTime.now().millisecondsSinceEpoch}',
            'data': {
              'title': 'Test Document for $projectId',
              'content': 'Testing URL encoding with special characters',
            },
          },
        ];

        final createResponse = await dio.post(
          '$baseUrl/api/changes',
          data: changeData,
        );
        expect(createResponse.statusCode, equals(200));

        final createResult = createResponse.data as Map<String, dynamic>;
        expect(createResult['success'], isTrue);

        // Verify projectId in response matches original
        final returnedProjectId = createResult['projectId'];
        expect(returnedProjectId, equals(projectId));

        // Get changes for the project
        final changesResponse = await dio.get(
          '$baseUrl/api/projects/$encodedProjectId/changes',
        );
        expect(changesResponse.statusCode, equals(200));

        final changesResult = changesResponse.data as Map<String, dynamic>;
        final changes = changesResult['changes'] as List;
        expect(changes, isNotEmpty);

        // Verify projectId in retrieved change
        if (changes.isNotEmpty) {
          final change = changes[0];
          expect(change['projectId'], equals(projectId));
        }

        // Get project statistics
        final statsResponse = await dio.get(
          '$baseUrl/api/projects/$encodedProjectId/stats',
        );
        expect(statsResponse.statusCode, equals(200));

        final statsResult = statsResponse.data as Map<String, dynamic>;
        expect(statsResult['projectId'], equals(projectId));
        expect(statsResult['changeStats'], isNotNull);
      }
    });

    test('error handling with malformed URLs', () async {
      // Test empty projectId
      try {
        await dio.get('$baseUrl/api/projects//changes');
        fail('Should have thrown an exception');
      } on DioException catch (e) {
        expect(e.response?.statusCode, greaterThanOrEqualTo(400));
      }

      // Test invalid change sequence
      try {
        await dio.get(
          '$baseUrl/api/projects/valid-project/changes/invalid-seq',
        );
        fail('Should have thrown an exception');
      } on DioException catch (e) {
        expect(e.response?.statusCode, greaterThanOrEqualTo(400));
      }
    });

    test('batch changes creation', () async {
      final batchChanges = [
        {
          'projectId': 'batch-test',
          'entityType': 'Document',
          'operation': 'create',
          'entityId': 'batch-doc-1',
          'data': {'title': 'Batch Document 1'},
        },
        {
          'projectId': 'batch-test',
          'entityType': 'Document',
          'operation': 'create',
          'entityId': 'batch-doc-2',
          'data': {'title': 'Batch Document 2'},
        },
        {
          'projectId': 'batch-test',
          'entityType': 'User',
          'operation': 'create',
          'entityId': 'batch-user-1',
          'data': {'name': 'Batch User 1'},
        },
      ];

      final response = await dio.post(
        '$baseUrl/api/changes',
        data: batchChanges,
      );
      expect(response.statusCode, equals(200));

      final responseData = response.data as Map<String, dynamic>;
      expect(responseData['success'], isTrue);
      expect(responseData['created'], equals(3));
      expect(responseData['createdSeqs'], isA<List>());

      final createdSeqs = responseData['createdSeqs'] as List;
      expect(createdSeqs.length, equals(3));
    });

    test('pagination with cursor', () async {
      // Create several changes for pagination testing
      final changes = List.generate(
        5,
        (index) => {
          'projectId': 'pagination-test',
          'entityType': 'Document',
          'operation': 'create',
          'entityId': 'pagination-doc-$index',
          'data': {'title': 'Pagination Document $index'},
        },
      );

      await dio.post('$baseUrl/api/changes', data: changes);

      // Test pagination with limit
      final paginatedResponse = await dio.get(
        '$baseUrl/api/projects/pagination-test/changes?limit=2',
      );
      expect(paginatedResponse.statusCode, equals(200));

      final paginatedData = paginatedResponse.data as Map<String, dynamic>;
      final paginatedChanges = paginatedData['changes'] as List;
      expect(paginatedChanges.length, lessThanOrEqualTo(2));

      // If there's a cursor, test using it
      if (paginatedData.containsKey('cursor')) {
        final cursor = paginatedData['cursor'];
        final nextPageResponse = await dio.get(
          '$baseUrl/api/projects/pagination-test/changes?cursor=$cursor&limit=2',
        );
        expect(nextPageResponse.statusCode, equals(200));
      }
    });

    test('changeAt preservation and cloudAt generation', () async {
      final testProjectId = 'changeat-test-project';
      final now = DateTime.now().toUtc();
      final customChangeAt = now
          .subtract(const Duration(minutes: 10))
          .toIso8601String();

      // Create a change with a custom changeAt
      final changeData = [
        {
          'projectId': testProjectId,
          'entityType': 'document',
          'operation': 'create',
          'entityId': 'doc-changeat-test',
          'changeAt': customChangeAt,
          'data': {
            'title': 'ChangeAt Test Document',
            'content': 'Testing changeAt preservation',
          },
        },
      ];

      final createResponse = await dio.post(
        '$baseUrl/api/changes',
        data: changeData,
      );
      expect(createResponse.statusCode, equals(200));

      final createResult = createResponse.data as Map<String, dynamic>;
      expect(createResult['success'], isTrue);
      expect(createResult['created'], equals(1));

      // Get the created sequence number
      final seqMap = createResult['seqMap'] as Map<String, dynamic>;
      final createdSeq = seqMap.values.first as int;
      print('seqMap: ${jsonEncode(seqMap)}');

      // Fetch the specific change to verify preservation
      final getResponse = await dio.get(
        '$baseUrl/api/projects/$testProjectId/changes/$createdSeq',
      );
      expect(getResponse.statusCode, equals(200));

      final retrievedChange = getResponse.data as Map<String, dynamic>;

      // Verify changeAt is preserved exactly
      expect(
        retrievedChange['changeAt'],
        equals(customChangeAt),
        reason: 'changeAt should match the custom value',
      );

      // Verify cloudAt exists and is after changeAt
      expect(retrievedChange['cloudAt'], isNotNull);

      final changeAtTime = DateTime.parse(retrievedChange['changeAt']).toUtc();
      final cloudAtTime = DateTime.parse(retrievedChange['cloudAt']).toUtc();

      expect(
        cloudAtTime.isAfter(changeAtTime) ||
            cloudAtTime.isAtSameMomentAs(changeAtTime),
        isTrue,
        reason: 'cloudAt should be at or after changeAt',
      );

      print('✅ ChangeAt preservation test passed!');
      print('   Original changeAt: $customChangeAt');
      print('   Retrieved changeAt: ${retrievedChange['changeAt']}');
      print('   Generated cloudAt: ${retrievedChange['cloudAt']}');
    });
  });
}
