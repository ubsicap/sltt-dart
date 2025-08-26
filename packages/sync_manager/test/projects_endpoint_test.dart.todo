import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  group('Projects Endpoint Tests', () {
    late LocalhostRestApiServer server;
    const int testPort =
        8084; // Use port 8084 to avoid conflicts with other tests
    const String baseUrl = 'http://localhost:$testPort';

    setUpAll(() async {
      server = LocalhostRestApiServer(
        StorageType.outsyncs,
        'Projects Test Server',
      );
      await server.start(port: testPort);

      // Wait for server to be ready
      await Future.delayed(const Duration(milliseconds: 500));
    });

    tearDownAll(() async {
      await server.stop();
    });

    test('create test project changes', () async {
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
        final response = await http.post(
          Uri.parse('$baseUrl/api/changes'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode([change]),
        );

        expect(response.statusCode, equals(200));

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['success'], isTrue);
      }
    });

    test('projects endpoint returns created projects', () async {
      final projectsResponse = await http.get(
        Uri.parse('$baseUrl/api/projects'),
      );

      expect(projectsResponse.statusCode, equals(200));

      final projectsData =
          jsonDecode(projectsResponse.body) as Map<String, dynamic>;
      expect(projectsData['projects'], isA<List>());
      expect(projectsData['count'], isA<int>());

      final projects = projectsData['projects'] as List<dynamic>;
      expect(projects, contains('project-alpha'));
      expect(projects, contains('project-beta'));
      expect(projectsData['count'], equals(projects.length));
    });

    test('projects endpoint structure', () async {
      final projectsResponse = await http.get(
        Uri.parse('$baseUrl/api/projects'),
      );

      expect(projectsResponse.statusCode, equals(200));

      final projectsData =
          jsonDecode(projectsResponse.body) as Map<String, dynamic>;

      // Verify response structure
      expect(projectsData, containsPair('projects', isA<List>()));
      expect(projectsData, containsPair('count', isA<int>()));
      expect(projectsData, containsPair('timestamp', isA<String>()));

      // Verify timestamp is valid ISO string
      final timestamp = projectsData['timestamp'] as String;
      expect(() => DateTime.parse(timestamp), returnsNormally);
    });
  });
}
