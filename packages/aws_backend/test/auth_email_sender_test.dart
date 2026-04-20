import 'dart:convert';

import 'package:aws_backend/src/auth/auth_email_sender.dart';
import 'package:aws_backend/src/auth/verification_email_template.dart';
import 'package:aws_common/aws_common.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('SesAuthEmailSender', () {
    test('sends SES payload with html and text bodies', () async {
      late Map<String, dynamic> payloadJson;
      final httpClient = MockClient((request) async {
        payloadJson = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({'MessageId': 'message-123'}), 200);
      });

      final sender = SesAuthEmailSender(
        credentials: const AWSCredentials('test-access-key', 'test-secret-key'),
        region: 'us-east-1',
        fromEmail: 'no-reply@example.com',
        httpClient: httpClient,
        templateRenderer: VerificationEmailTemplateRenderer(
          nowProvider: () => DateTime.utc(2026, 4, 14, 18, 20, 20),
        ),
      );

      await sender.sendVerificationCode(
        toEmail: 'jane@example.com',
        code: '123456',
        expiresAt: DateTime.utc(2026, 4, 14, 18, 30),
      );

      expect(payloadJson['FromEmailAddress'], equals('no-reply@example.com'));
      expect(
        payloadJson['Destination']['ToAddresses'],
        equals(<String>['jane@example.com']),
      );
      expect(
        payloadJson['Content']['Simple']['Subject']['Data'],
        equals('Your SLTT verification code'),
      );
      expect(
        payloadJson['Content']['Simple']['Body']['Html']['Data'] as String,
        contains('123456'),
      );
      expect(
        payloadJson['Content']['Simple']['Body']['Text']['Data'],
        equals(
          'Your SLTT verification code\n\n'
          'Use this six-digit code to verify your email address in the app.\n\n'
          '123456\n\n'
          'This code expires in about 10 minutes.\n\n'
          'For your security:\n\n'
          '- Enter this code only in the SLTT verification screen.\n'
          '- Do not share this code with anyone.\n'
          '- If you did not request this code, you can ignore this message.',
        ),
      );
    });
  });
}
