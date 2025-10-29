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

  group('Integration POST /api/changes', () {
    test('POST invalid JSON returns 400', () async {
      final resp = await http.post(
        baseUrl.replace(path: '/api/changes'),
        body: 'not-a-json',
        headers: {'Content-Type': 'application/json'},
      );
      expect(
        resp.statusCode,
        anyOf([400, 422]),
        reason: 'Should return 400 or 422 for invalid JSON, got ${resp.body}',
      );
    }, tags: ['internet', 'integration']);

    test(
      'POST minimal valid payload returns 200 or 201',
      () async {
        final projectData = BaseDataFields(
          parentId: 'parentId',
          parentProp: 'parentProp',
        );
        final projectId = '__test_project_post_minimal_valid_payload__';
        // delete project if it exists
        await resetTestProject(baseUrl, projectId);

        final change =
            ChangeLogEntryFactoryService.forChangeSave<
              DynamoChangeLogEntry,
              int,
              BaseDataFields
            >(
              factory: DynamoChangeLogEntry.new,
              domainType: 'project',
              domainId: projectId,
              entityType: 'project',
              entityId: projectId,
              changeBy: 'userId',
              data: projectData,
            );

        final request = CreateChangesRequest(
          changes: [change],
          srcStorageType: 'cloud',
          srcStorageId: 'test',
          storageMode: 'save',
        );
        final payload = jsonEncode(request.toJson());
        final resp = await http.post(
          baseUrl.replace(path: '/api/changes'),
          body: payload,
          headers: {'Content-Type': 'application/json'},
        );
        expect(resp.statusCode, anyOf([200, 201]), reason: 'Got ${resp.body}');
      },
      tags: ['internet', 'integration'],
      timeout: Timeout.none,
    );
  });
}
