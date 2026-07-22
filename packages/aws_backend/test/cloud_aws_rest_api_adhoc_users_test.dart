import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  SlttLogger.logger.info(
    'cloud adhoc user integration tests against: $baseUrl',
  );

  group('cloud - adhoc users endpoints', () {
    test(
      'GET /api/admin/adhoc-users returns unauthorized without auth',
      () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/admin/adhoc-users'),
        );

        expect(response.statusCode, equals(401));
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        expect(body['error'], isNotNull);
      },
      tags: ['internet', 'integration'],
    );

    test(
      'GET /api/super/admin/adhoc-users returns unauthorized without auth',
      () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/super/admin/adhoc-users'),
        );

        expect(response.statusCode, equals(401));
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        expect(body['error'], isNotNull);
      },
      tags: ['internet', 'integration'],
    );

    test(
      'POST /api/admin/adhoc-users returns unauthorized without auth',
      () async {
        final response = await http.post(
          Uri.parse('$baseUrl/api/admin/adhoc-users'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': '__test_adhoc_user__',
            'name': 'Test Adhoc User',
            'username': 'testadhocuser',
            'password': 'secret123',
            'projectIds': ['__test_project__'],
            'adminPassword': 'admin-pass',
          }),
        );

        expect(response.statusCode, equals(401));
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        expect(body['error'], isNotNull);
      },
      tags: ['internet', 'integration'],
    );
  });
}
