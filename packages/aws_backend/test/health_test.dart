import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  print('Testing against: $baseUrl');

  test('health endpoint returns server status', () async {
    final response = await http.get(Uri.parse('$baseUrl/health'));

    expect(response.statusCode, equals(200));

    final data = jsonDecode(response.body);
    expect(data['status'], equals('healthy'));
    expect(data['server'], equals('AWS Lambda API'));
    expect(data['storageType'], equals('AWS DynamoDB'));
    expect(data['timestamp'], isA<String>());

    print('✅ Health endpoint test passed!');
    print('   Server: ${data['server']}');
    print('   Status: ${data['status']}');
    print('   Storage: ${data['storageType']}');
  }, tags: ['internet', 'integration']);
}
