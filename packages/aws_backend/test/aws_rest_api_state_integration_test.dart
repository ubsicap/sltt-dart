import 'dart:convert';
import 'dart:io';

import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'helpers/test_utils.dart';

void main() {
  final baseUrl = Uri.parse(
    Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl,
  );

  setUpAll(() {
    // register DynamoChangeLogEntry factory for api models usage
    dynamoChangeLogEntryFactoryRegistration;
  });

  group('AWS REST /api/state integration', () {
    test(
      'POST api/changes > GET /api/state/projects/<project_id>/projects',
      () async {
        final projectId = '__test_post_changes_get_state__';
        await resetTestProject(baseUrl, projectId);

        final projectData = BaseDataFields(
          parentId: 'parentId',
          parentProp: 'parentProp',
        );

        await saveProjectChange(baseUrl, projectId, projectData: projectData);

        final resp = await http.get(
          Uri.parse('$baseUrl/api/state/projects/$projectId/projects'),
          headers: {'Accept': 'application/json'},
        );
        expect(resp.statusCode, anyOf([200, 404]));

        if (resp.statusCode == 200) {
          final body = jsonDecode(resp.body) as Map<String, dynamic>;
          expect(body['items'], isA<List>());
          expect(body.containsKey('hasMore'), isTrue);
        }
      },
      tags: ['internet', 'integration'],
    );
  });
}
