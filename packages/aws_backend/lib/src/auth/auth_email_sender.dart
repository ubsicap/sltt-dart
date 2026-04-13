import 'dart:convert';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;
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

class SesAuthEmailSender implements AuthEmailSender {
  SesAuthEmailSender({
    required this.credentials,
    required this.region,
    required this.fromEmail,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final AWSCredentials credentials;
  final String region;
  final String fromEmail;
  final http.Client _httpClient;

  @override
  Future<void> sendVerificationCode({
    required String toEmail,
    required String code,
    required DateTime expiresAt,
  }) async {
    final normalizedRecipient = toEmail.trim();
    if (normalizedRecipient.isEmpty) {
      throw StateError('Recipient email is required for verification send');
    }

    final uri = Uri.parse(
      'https://email.$region.amazonaws.com/v2/email/outbound-emails',
    );
    final textBody =
        'SLTT verification code\n\n'
        'Use this six-digit code to verify your email address in the app:\n\n'
        '$code\n\n'
        'This code expires at ${expiresAt.toUtc().toIso8601String()}.\n\n'
        'For your security:\n'
        '- Enter this code only in the SLTT verification screen.\n'
        '- Do not share this code with anyone.\n'
        '- If you did not request this code, you can ignore this message.';
    final payload = <String, dynamic>{
      'FromEmailAddress': fromEmail,
      'Destination': {
        'ToAddresses': [normalizedRecipient],
      },
      'Content': {
        'Simple': {
          'Subject': {'Data': 'Your SLTT verification code'},
          'Body': {
            'Text': {'Data': textBody},
          },
        },
      },
    };

    final body = jsonEncode(payload);
    final encodedBody = utf8.encode(body);
    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(credentials),
    );
    final signedRequest = await signer.sign(
      AWSHttpRequest(
        method: AWSHttpMethod.post,
        uri: uri,
        headers: {'Content-Type': 'application/json', 'host': uri.host},
        body: encodedBody,
      ),
      credentialScope: AWSCredentialScope(
        region: region,
        service: AWSService.ses,
      ),
    );

    final request = http.Request('POST', signedRequest.uri)
      ..headers.addAll(signedRequest.headers)
      ..bodyBytes = encodedBody;
    final streamed = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'SES send failed with status ${response.statusCode}: ${response.body}',
      );
    }

    final responseJson =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final messageId = responseJson['MessageId'] as String?;
    SlttLogger.logger.info(
      '[Auth] SES verification email sent to $normalizedRecipient messageId=${messageId ?? 'unknown'}',
    );
  }
}
