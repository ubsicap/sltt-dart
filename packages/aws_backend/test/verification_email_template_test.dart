import 'package:aws_backend/src/auth/verification_email_template.dart';
import 'package:test/test.dart';

void main() {
  group('VerificationEmailTemplateRenderer', () {
    test(
      'renders html with centered code content and matching text body',
      () async {
        final renderer = VerificationEmailTemplateRenderer(
          nowProvider: () => DateTime.utc(2026, 4, 14, 18, 20, 20),
        );

        final emailContent = await renderer.render(
          code: '123456',
          expiresAt: DateTime.utc(2026, 4, 14, 18, 30),
        );

        expect(emailContent.subject, equals('Your SLTT verification code'));
        expect(emailContent.htmlBody, contains('Verification code'));
        expect(emailContent.htmlBody, contains('123456'));
        expect(emailContent.htmlBody, contains('Verify your email'));
        expect(emailContent.htmlBody, contains('in about 10 minutes'));
        expect(emailContent.htmlBody, isNot(contains('{{verification_code}}')));
        expect(emailContent.htmlBody, isNot(contains('{{expires_in}}')));
        expect(
          emailContent.textBody,
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
      },
    );

    test('escapes html-sensitive values before substitution', () async {
      final renderer = VerificationEmailTemplateRenderer(
        nowProvider: () => DateTime.utc(2026, 4, 14, 18, 20),
      );

      final emailContent = await renderer.render(
        code: '<123&456>',
        expiresAt: DateTime.utc(2026, 4, 14, 18, 30),
      );

      expect(emailContent.htmlBody, contains('&lt;123&amp;456&gt;'));
      expect(emailContent.htmlBody, isNot(contains('><123&456><')));
      expect(emailContent.textBody, contains('<123&456>'));
    });

    test('uses singular wording for one minute remaining', () async {
      final renderer = VerificationEmailTemplateRenderer(
        nowProvider: () => DateTime.utc(2026, 4, 14, 18, 29, 31),
      );

      final emailContent = await renderer.render(
        code: '123456',
        expiresAt: DateTime.utc(2026, 4, 14, 18, 30),
      );

      expect(emailContent.htmlBody, contains('in about 1 minute'));
      expect(
        emailContent.textBody,
        contains('This code expires in about 1 minute.'),
      );
    });
  });
}
