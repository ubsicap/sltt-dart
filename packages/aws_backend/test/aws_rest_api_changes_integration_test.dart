import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Uri.parse(
    Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl,
  );

  group('Integration POST /api/changes', () {
    test('POST invalid JSON returns 400', () async {
      final uri = baseUrl.replace(path: '/api/changes');
      final resp = await http.post(
        uri,
        body: 'not-a-json',
        headers: {'Content-Type': 'application/json'},
      );
      expect(resp.statusCode, anyOf([400, 422]));
    }, tags: ['internet', 'integration']);

    test(
      'POST minimal valid payload returns 200 or 201',
      () async {
        final uri = baseUrl.replace(path: '/api/changes');
        final payload = jsonEncode({
          'changes': [
            {'domainId': '__test1', 'entityType': 'document', 'entityId': 'i1'},
          ],
          'srcStorageType': 'local',
          'srcStorageId': 'test',
          'storageMode': 'save',
        });
        final resp = await http.post(
          uri,
          body: payload,
          headers: {'Content-Type': 'application/json'},
        );
        expect(resp.statusCode, anyOf([200, 201]));
      },
      tags: ['internet', 'integration'],
    );
  });
}
