import 'package:aws_backend/aws_backend.dart';
import 'package:sltt_core/sltt_core.dart' show SlttLogger;

/// $connect REQUEST authorizer. Validates the bearer token the desktop
/// client set on the Authorization header of the WS handshake - the same
/// check AwsRestApiServer._requireAuthenticatedSession does for REST calls,
/// just reused here since the desktop client (not a browser) can set a real
/// header on the socket upgrade request.
Future<Map<String, dynamic>> wsAuthorizerHandler(
  Map<String, dynamic> event, {
  required BackendAuthService authService,
}) async {
  final headers = (event['headers'] as Map?)?.cast<String, dynamic>() ?? {};
  final authHeader =
      headers['Authorization'] as String? ??
      headers['authorization'] as String?;

  if (authHeader == null || authHeader.trim().isEmpty) {
    return _denyPolicy(event);
  }

  try {
    final session = authService.authenticateBearerToken(authHeader);
    return _allowPolicy(
      event,
      userId: session.userId,
      isTestToken: session.isTestToken,
    );
  } on AuthException catch (e) {
    SlttLogger.logger.warning('wsAuthorizer rejected token: ${e.message}');
    return _denyPolicy(event);
  }
}

Map<String, dynamic> _allowPolicy(
  Map<String, dynamic> event, {
  required String userId,
  bool isTestToken = false,
}) {
  return {
    'principalId': userId,
    'policyDocument': {
      'Version': '2012-10-17',
      'Statement': [
        {
          'Action': 'execute-api:Invoke',
          'Effect': 'Allow',
          'Resource': event['methodArn'],
        },
      ],
    },
    'context': {'userId': userId, 'isTestToken': isTestToken},
  };
}

Map<String, dynamic> _denyPolicy(Map<String, dynamic> event) {
  return {
    'principalId': 'unauthorized',
    'policyDocument': {
      'Version': '2012-10-17',
      'Statement': [
        {
          'Action': 'execute-api:Invoke',
          'Effect': 'Deny',
          'Resource': event['methodArn'],
        },
      ],
    },
  };
}
