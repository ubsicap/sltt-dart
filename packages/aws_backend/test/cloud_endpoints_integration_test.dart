import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  SlttLogger.logger.info('Integration tests against: $baseUrl');

  test('GET /api/help returns documentation payload', () async {
    final response = await http.get(Uri.parse('$baseUrl/api/help'));
    expect(response.statusCode, equals(200));

    final data = jsonDecode(response.body);
    expect(data['server'], isA<Map<String, dynamic>>());
    expect(data['endpoints'], isA<List<dynamic>>());
  }, tags: ['internet', 'integration']);

  test('GET /api/domains returns domains list', () async {
    final response = await http.get(Uri.parse('$baseUrl/api/domains'));
    expect(response.statusCode, equals(200));

    final data = jsonDecode(response.body);
    expect(data['domains'], isA<List<dynamic>>());
    expect(data['collections'], isA<List<dynamic>>());
  }, tags: ['internet', 'integration']);

  test('Unknown route returns 404', () async {
    final response = await http.get(
      Uri.parse('$baseUrl/this-route-does-not-exist'),
    );
    expect(response.statusCode, equals(404));

    final data = jsonDecode(response.body);
    expect(data['error'], isNotNull);
  }, tags: ['internet', 'integration']);
}
