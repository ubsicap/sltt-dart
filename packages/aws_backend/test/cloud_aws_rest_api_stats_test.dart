import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

import 'helpers/test_utils.dart';

void main() {
  final baseUrl = Uri.parse(
    Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl,
  );

  group('cloud - GET /api/stats', () {
    test(
      'GET stats for empty project returns consistent empty stats',
      () async {
        final projectId = '__test_empty_stats_proj__';
        await resetTestProject(baseUrl, projectId);

        // Call stats endpoint multiple times
        for (int i = 0; i < 3; i++) {
          final resp = await http.get(
            Uri.parse('$baseUrl/api/stats/projects/$projectId'),
            headers: {'Accept': 'application/json'},
          );

          expect(
            resp.statusCode,
            equals(200),
            reason: 'Call $i: Should return 200 OK, got ${resp.body}',
          );

          final body = jsonDecode(resp.body) as Map<String, dynamic>;

          // Verify project ID
          expect(
            body,
            equals({
              'projectId': projectId,
              'changeStats': {
                'creates': 0,
                'updates': 0,
                'deletes': 0,
                'total': 0,
                'latestChangeAt': '1970-01-01T00:00:00.000Z',
                'latestSeq': 0,
              },
              'entityTypeStats': {
                'entityTypes': {},
                'totals': {
                  'creates': 0,
                  'updates': 0,
                  'deletes': 0,
                  'total': 0,
                  'latestChangeAt': '1970-01-01T00:00:00.000Z',
                  'latestSeq': -1,
                },
              },
              'timestamp': isA<String>(),
              'storageType': 'AWS DynamoDB',
            }),
            reason: 'Expected empty/zero result values in body',
          );
        }
      },
      tags: ['internet', 'integration'],
      timeout: Timeout.none,
    );
  });
}
