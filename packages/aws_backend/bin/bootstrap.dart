#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

import 'aws_lambda_server.dart' as lambda;

/// AWS Lambda Bootstrap entry point
///
/// This file serves as the main entry point for the Lambda function
/// and implements the Lambda Runtime API protocol for the provided.al2 runtime.
Future<void> main() async {
  final runtimeApi = Platform.environment['AWS_LAMBDA_RUNTIME_API'];

  if (runtimeApi == null) {
    print('ERROR: AWS_LAMBDA_RUNTIME_API environment variable not set');
    exit(1);
  }

  print('Starting Lambda runtime loop...');

  // Lambda runtime loop
  while (true) {
    String? requestId;
    try {
      // Get next event from Lambda Runtime API
      final nextEventResponse = await HttpClient()
          .getUrl(
            Uri.parse('http://$runtimeApi/2018-06-01/runtime/invocation/next'),
          )
          .then((request) => request.close());

      if (nextEventResponse.statusCode != 200) {
        print('Failed to get next event: ${nextEventResponse.statusCode}');
        continue;
      }

      // Extract request ID from headers
      requestId = nextEventResponse.headers.value(
        'lambda-runtime-aws-request-id',
      );
      if (requestId == null) {
        print('Missing request ID in response headers');
        continue;
      }

      // Read event data
      final eventData = await nextEventResponse.transform(utf8.decoder).join();
      final event = jsonDecode(eventData) as Map<String, dynamic>;

      print('Processing event with request ID: $requestId');

      // Call our Lambda handler. Anything thrown in here is caught below,
      // where we now have requestId in scope to report it properly.
      final result = await lambda.handler(event);

      // Send response back to Lambda Runtime API
      final responseBody = jsonEncode(result);
      final responseRequest = await HttpClient()
          .postUrl(
            Uri.parse(
              'http://$runtimeApi/2018-06-01/runtime/invocation/$requestId/response',
            ),
          )
          .then((request) {
            request.headers.contentType = ContentType.json;
            request.write(responseBody);
            return request.close();
          });

      if (responseRequest.statusCode != 202) {
        print('Failed to send response: ${responseRequest.statusCode}');
      } else {
        print('Successfully processed event $requestId');
      }
    } catch (error, stackTrace) {
      print('Error in Lambda runtime loop: $error');
      print('Stack trace: $stackTrace');

      // Without this, a thrown error means the Runtime API never gets a
      // response for this invocation, so Lambda just waits out the full
      // function timeout and reports a platform-level timeout instead of
      // the actual error - which is what "Endpoint request timed out"
      // on the websocket client turned out to be.
      if (requestId != null) {
        try {
          final errorResponse = {
            'errorMessage': error.toString(),
            'errorType': error.runtimeType.toString(),
            'stackTrace': stackTrace.toString().split('\n'),
          };

          await HttpClient()
              .postUrl(
                Uri.parse(
                  'http://$runtimeApi/2018-06-01/runtime/invocation/$requestId/error',
                ),
              )
              .then((request) {
                request.headers.contentType = ContentType.json;
                request.write(jsonEncode(errorResponse));
                return request.close();
              });
        } catch (e) {
          print('Failed to send error response: $e');
        }
      } else {
        // We failed before even getting a request ID (e.g. the initial
        // GET to /next itself failed) - nothing to report to, just log
        // and loop again.
        print('No request ID available to report error against.');
      }
    }
  }
}
