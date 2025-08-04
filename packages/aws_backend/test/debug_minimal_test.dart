import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = kCloudDevUrl;

  test('debug minimal request', () async {
    // Try the absolute minimum request that should work
    final minimalData = [
      {
        'projectId': '_debug_minimal',
        'entityType': 'project',
        'entityId': '_debug_minimal',
      },
    ];

    print('Sending minimal request: ${jsonEncode(minimalData)}');

    final response = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(minimalData),
    );

    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      print('ERROR: Minimal request failed!');

      // Try to see if it's a CORS issue with a simple GET
      final healthResponse = await http.get(Uri.parse('$baseUrl/health'));
      print('Health check status: ${healthResponse.statusCode}');
      print('Health check body: ${healthResponse.body}');
    }
  });

  test('debug malformed JSON', () async {
    print('Testing malformed JSON...');

    final response = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'application/json'},
      body: '{invalid json',
    );

    print('Malformed JSON status: ${response.statusCode}');
    print('Malformed JSON body: ${response.body}');
  });

  test('debug wrong content type', () async {
    print('Testing wrong content type...');

    final response = await http.post(
      Uri.parse('$baseUrl/api/changes'),
      headers: {'Content-Type': 'text/plain'},
      body: jsonEncode([
        {'projectId': 'test'},
      ]),
    );

    print('Wrong content type status: ${response.statusCode}');
    print('Wrong content type body: ${response.body}');
  });
}
