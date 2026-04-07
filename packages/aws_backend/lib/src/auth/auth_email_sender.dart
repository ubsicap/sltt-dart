import 'package:sltt_core/sltt_core.dart';

abstract class AuthEmailSender {
  Future<void> sendVerificationCode({
    required String toEmail,
    required String code,
    required DateTime expiresAt,
  });
}

class LogAuthEmailSender implements AuthEmailSender {
  @override
  Future<void> sendVerificationCode({
    required String toEmail,
    required String code,
    required DateTime expiresAt,
  }) async {
    SlttLogger.logger.info(
      '[Auth] Verification code for $toEmail: $code (expires ${expiresAt.toUtc().toIso8601String()})',
    );
  }
}
