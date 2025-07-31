import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  group('API Endpoints Tests', () {
    // Check for environment variable to determine test configuration
    // Use USE_DEV_CLOUD=true to test against AWS, USE_CLOUD_STORAGE=true for local cloud storage
    final bool useDevCloud = Platform.environment['USE_DEV_CLOUD'] == 'true';
    final bool useCloudStorage =
        Platform.environment['USE_CLOUD_STORAGE'] == 'true';

    late EnhancedRestApiServer? server;
    late Dio dio;
    late String baseUrl;
    late String testProjectId;
    late bool shouldTestCloudAt;

    setUpAll(() async {
      if (useDevCloud) {
        // Test against AWS dev cloud directly
        baseUrl = kCloudDevUrl;
        testProjectId = '_test_cloud_api_project';
        server = null; // No local server needed
        shouldTestCloudAt = true;
        print('🌐 Testing against AWS dev cloud: $baseUrl');
      } else if (useCloudStorage) {
        // Start local cloud storage server
        const int testPort = kCloudStoragePort;
        baseUrl = 'http://localhost:$testPort';
        testProjectId = 'api-test-project';
        server = EnhancedRestApiServer(
          StorageType.cloudStorage,
          'Test Cloud Storage Server',
        );
        await server!.start(port: testPort);
        shouldTestCloudAt = true;
        print('☁️ Testing against local cloud storage server: $baseUrl');
      } else {
        // Default: test against local outsyncs server (no cloudAt)
        const int testPort = 8080;
        baseUrl = 'http://localhost:$testPort';
        testProjectId = 'api-test-project';
        server = EnhancedRestApiServer(
          StorageType.outsyncs,
          'Test Outsyncs Server',
        );
        await server!.start(port: testPort);
        shouldTestCloudAt = false;
        print('🔄 Testing against local outsyncs server: $baseUrl');
      }

      dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      // Wait for server to be ready (if using local server)
      if (server != null) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    });

    tearDownAll(() async {
      if (server != null) {
        await server!.stop();
      }
    });

    test('health endpoint', () async {
      final response = await dio.get('$baseUrl/health');

      expect(response.statusCode, equals(200));
      expect(response.data['status'], equals('healthy'));
      // Server name varies based on configuration
      expect(response.data['server'], isNotNull);
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
          'projectId': '$testProjectId-alpha',
          'entityType': 'project',
          'operation': 'create',
          'entityId': '$testProjectId-alpha',
          'data': {
            'name': 'Alpha Project',
            'description': 'First test project',
          },
        },
        {
          'projectId': '$testProjectId-beta',
          'entityType': 'project',
          'operation': 'create',
          'entityId': '$testProjectId-beta',
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
      expect(projects, contains('$testProjectId-alpha'));
      expect(projects, contains('$testProjectId-beta'));
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

        // Verify response indicates success (project creation doesn't return projectId directly)
        expect(createResult['created'], greaterThan(0));

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
          'projectId': '$testProjectId-batch',
          'entityType': 'Document',
          'operation': 'create',
          'entityId': 'batch-doc-1',
          'data': {'title': 'Batch Document 1'},
        },
        {
          'projectId': '$testProjectId-batch',
          'entityType': 'Document',
          'operation': 'create',
          'entityId': 'batch-doc-2',
          'data': {'title': 'Batch Document 2'},
        },
        {
          'projectId': '$testProjectId-batch',
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
          'projectId': '$testProjectId-pagination',
          'entityType': 'Document',
          'operation': 'create',
          'entityId': 'pagination-doc-$index',
          'data': {'title': 'Pagination Document $index'},
        },
      );

      await dio.post('$baseUrl/api/changes', data: changes);

      // Test pagination with limit
      final paginatedResponse = await dio.get(
        '$baseUrl/api/projects/$testProjectId-pagination/changes?limit=2',
      );
      expect(paginatedResponse.statusCode, equals(200));

      final paginatedData = paginatedResponse.data as Map<String, dynamic>;
      final paginatedChanges = paginatedData['changes'] as List;
      expect(paginatedChanges.length, lessThanOrEqualTo(2));

      // If there's a cursor, test using it
      if (paginatedData.containsKey('cursor')) {
        final cursor = paginatedData['cursor'];
        final nextPageResponse = await dio.get(
          '$baseUrl/api/projects/$testProjectId-pagination/changes?cursor=$cursor&limit=2',
        );
        expect(nextPageResponse.statusCode, equals(200));
      }
    });

    test('changeAt preservation and cloudAt generation', () async {
      final changeAtTestProjectId = '$testProjectId-changeat';
      final now = DateTime.now().toUtc();
      final customChangeAt = now
          .subtract(const Duration(minutes: 10))
          .toIso8601String();

      // Create a change with a custom changeAt
      final changeData = [
        {
          'projectId': changeAtTestProjectId,
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
        '$baseUrl/api/projects/$changeAtTestProjectId/changes/$createdSeq',
      );
      expect(getResponse.statusCode, equals(200));

      final retrievedChange = getResponse.data as Map<String, dynamic>;

      // Verify changeAt is preserved exactly
      expect(
        retrievedChange['changeAt'],
        equals(customChangeAt),
        reason: 'changeAt should match the custom value',
      );

      // Test cloudAt behavior based on storage type
      if (shouldTestCloudAt) {
        // Cloud storage should generate cloudAt
        expect(
          retrievedChange['cloudAt'],
          isNotNull,
          reason: 'Cloud storage should generate cloudAt timestamps',
        );

        final changeAtTime = DateTime.parse(
          retrievedChange['changeAt'],
        ).toUtc();
        final cloudAtTime = DateTime.parse(retrievedChange['cloudAt']).toUtc();

        expect(
          cloudAtTime.isAfter(changeAtTime) ||
              cloudAtTime.isAtSameMomentAs(changeAtTime),
          isTrue,
          reason: 'cloudAt should be at or after changeAt',
        );

        print('✅ Cloud storage test passed!');
        print('   Retrieved changeAt: ${retrievedChange['changeAt']}');
        print('   Generated cloudAt: ${retrievedChange['cloudAt']}');
      } else {
        // Local outsyncs storage should NOT generate cloudAt
        expect(
          retrievedChange['cloudAt'],
          isNull,
          reason:
              'Local outsyncs storage should not generate cloudAt timestamps',
        );

        print('✅ Local storage test passed!');
        print('   Retrieved changeAt: ${retrievedChange['changeAt']}');
        print('   cloudAt correctly null for local storage');
      }

      print(
        '✅ ChangeAt preservation test passed for ${shouldTestCloudAt ? 'cloud' : 'local'} storage!',
      );
    });
  });
}
