import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  SlttLogger.logger.info(
    'cloud test-user auth integration tests against: $baseUrl',
  );

  group('cloud - auth test user register/login/logout', () {
    test(
      'special-case test user can register, login, and logout',
      () async {
        final suffix = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
        final email = 'cloud-test-user-$suffix@example.com';
        final name = 'Test User Cloud $suffix';
        final expectedUserId = '__test_user_cloud$suffix';

        final registerResponse = await http.post(
          Uri.parse('$baseUrl/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': 'ignored-test-id',
            'name': name,
            'dateOfBirth': '1990-01-01',
            'email': email,
            'password': 'secret123',
          }),
        );

        expect(registerResponse.statusCode, equals(200));
        final registerBody =
            jsonDecode(registerResponse.body) as Map<String, dynamic>;
        expect(registerBody['status'], equals('verified'));

        final loginResponse = await http.post(
          Uri.parse('$baseUrl/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'identifier': email, 'password': 'secret123'}),
        );

        expect(loginResponse.statusCode, equals(200));
        final loginBody =
            jsonDecode(loginResponse.body) as Map<String, dynamic>;
        expect(loginBody['status'], equals('authenticated'));
        expect(loginBody['userId'], equals(expectedUserId));
        expect(loginBody['accessToken'] as String?, isNotEmpty);
        expect(loginBody['refreshToken'] as String?, isNotEmpty);

        final logoutResponse = await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer ${loginBody['accessToken']}',
          },
          body: jsonEncode({'refreshToken': loginBody['refreshToken']}),
        );

        expect(logoutResponse.statusCode, equals(200));
        final logoutBody =
            jsonDecode(logoutResponse.body) as Map<String, dynamic>;
        expect(logoutBody['status'], equals('logged_out'));

        final refreshRetry = await http.post(
          Uri.parse('$baseUrl/api/auth/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': loginBody['refreshToken']}),
        );

        expect(refreshRetry.statusCode, equals(401));

        final secondRegisterResponse = await http.post(
          Uri.parse('$baseUrl/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': 'ignored-test-id',
            'name': name,
            'dateOfBirth': '1990-01-01',
            'email': email,
            'password': 'secret123',
          }),
        );

        expect(secondRegisterResponse.statusCode, equals(200));
        final secondRegisterBody =
            jsonDecode(secondRegisterResponse.body) as Map<String, dynamic>;
        expect(
          secondRegisterBody['status'],
          anyOf(equals('verified'), equals('pending_verification')),
        );
      },
      tags: ['internet', 'integration'],
    );
  });
}
