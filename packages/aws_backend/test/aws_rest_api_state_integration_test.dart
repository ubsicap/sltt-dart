import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/src/server/server_urls.dart' show kCloudDevUrl;
import 'package:test/test.dart';

void main() {
  group('AWS REST /api/state integration', () {
    final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;

    test('GET /api/state/projects/__test1/documents', () async {
      if (baseUrl.contains('REPLACE_ME')) {
        // No cloud URL configured in generated file; skip integration test.
        return;
      }

      final url = Uri.parse('$baseUrl/api/state/projects/__test1/documents');
      final resp = await http.get(url, headers: {'Accept': 'application/json'});
      expect(resp.statusCode, anyOf([200, 404]));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        expect(body['items'], isA<List>());
        expect(body.containsKey('hasMore'), isTrue);
      }
    }, tags: ['internet', 'integration']);
  });
}
