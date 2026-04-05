import 'dart:convert';

import 'package:aws_backend/aws_backend.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

import 'helpers/fake_storage.dart';

void main() {
  group('offline - AwsRestApiServer additional unit routes', () {
    late AwsRestApiServer server;
    late Router router;
    late FakeDynamoDBStorageService storage;

    setUp(() {
      storage = FakeDynamoDBStorageService();
      server = AwsRestApiServer(
        serverName: 'TestServer',
        storage: storage,
        healthEnvironmentOverrides: {
          'DYNAMODB_TABLE': 'sltt-shared-infra-changes-states',
          'DYNAMODB_TABLE_ARN':
              'arn:aws:dynamodb:us-east-1:123456789012:table/sltt-shared-infra-changes-states',
          'MEDIA_BUCKET': 'bucket-a',
        },
      );
      router = server.getRouter();
    });

    test('GET /api/ids/projects returns domain ids', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'GET',
        'path': '/api/ids/projects',
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(200));
      final body =
          jsonDecode(response['body'] as String) as Map<String, dynamic>;
      expect(body['items'], isA<List>());
      expect(body['count'], isA<int>());
      expect(body['timestamp'], isA<String>());
    });

    test('GET /api/stats/projects/__test1 returns stats', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'GET',
        'path': '/api/stats/projects/__test1',
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(200));
      final body =
          jsonDecode(response['body'] as String) as Map<String, dynamic>;
      expect(body['projectId'], equals('__test1'));
      expect(body['changeStats'], isA<Map<String, dynamic>>());
      expect(body['entityTypeStats'], isA<Map<String, dynamic>>());
    });

    test(
      'GET /api/state/projects/__test1/document returns state structure',
      () async {
        final response = await server.handleApiGatewayEvent({
          'httpMethod': 'GET',
          'path': '/api/state/projects/__test1/documents',
          'headers': <String, String>{},
        }, router);

        expect(response['statusCode'], equals(200));
        final body =
            jsonDecode(response['body'] as String) as Map<String, dynamic>;
        expect(body['projectId'], equals('__test1'));
        expect(body['entityType'], equals('document'));
        expect(body['items'], isA<List>());
      },
    );

    test('DELETE storage reset for __test1 returns message', () async {
      final response = await server.handleApiGatewayEvent({
        'httpMethod': 'DELETE',
        'path': '/api/storage/__test/reset/projects/__test1',
        'headers': <String, String>{},
      }, router);

      expect(response['statusCode'], equals(200));
      final body =
          jsonDecode(response['body'] as String) as Map<String, dynamic>;
      expect(body['message'], contains('__test1'));
    });

    test(
      'POST /api/admin/storage/export/create injects table and bucket defaults',
      () async {
        final response = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/admin/storage/export/create',
          'headers': <String, String>{'Content-Type': 'application/json'},
          'body': jsonEncode({
            'ExportFormat': 'DYNAMODB_JSON',
            'ExportType': 'INCREMENTAL_EXPORT',
            'S3Bucket': 'client-bucket-should-be-ignored',
            'S3Prefix': 'client-prefix-should-be-ignored',
            'IncrementalExportSpecification': {
              'ExportFromTime': '2026-04-04T00:00:00Z',
              'ExportToTime': '2026-04-04T01:00:00Z',
            },
          }),
        }, router);

        expect(response['statusCode'], equals(200));
        expect(storage.startExportRequests, hasLength(1));

        final request = storage.startExportRequests.single;
        expect(request['ExportFormat'], equals('DYNAMODB_JSON'));
        expect(request['ExportType'], equals('INCREMENTAL_EXPORT'));
        expect(
          request['TableArn'],
          equals(
            'arn:aws:dynamodb:us-east-1:123456789012:table/sltt-shared-infra-changes-states',
          ),
        );
        expect(request['S3Bucket'], equals('bucket-a'));
        expect(request['S3Prefix'], equals('dynamodb-exports/diag'));
      },
    );

    test(
      'POST /api/admin/storage/export/create returns 500 when ExportFormat is missing',
      () async {
        final response = await server.handleApiGatewayEvent({
          'httpMethod': 'POST',
          'path': '/api/admin/storage/export/create',
          'headers': <String, String>{'Content-Type': 'application/json'},
          'body': jsonEncode({'ExportType': 'FULL_EXPORT'}),
        }, router);

        expect(response['statusCode'], equals(500));
        final body =
            jsonDecode(response['body'] as String) as Map<String, dynamic>;
        expect(body['error'], contains('ExportFormat is required'));
      },
    );

    test(
      'GET /api/admin/storage/export/list includeDetails enriches summaries',
      () async {
        storage.listExportsResponse = {
          'ExportSummaries': [
            {
              'ExportArn':
                  'arn:aws:dynamodb:us-east-1:123456789012:table/test/export/exp-1',
              'ExportStatus': 'COMPLETED',
              'ExportType': 'FULL_EXPORT',
            },
          ],
        };
        storage
            .describeExportResponses['arn:aws:dynamodb:us-east-1:123456789012:table/test/export/exp-1'] = {
          'ExportDescription': {
            'ExportArn':
                'arn:aws:dynamodb:us-east-1:123456789012:table/test/export/exp-1',
            'S3Bucket': 'bucket-a',
            'S3Prefix': 'exports/diag',
            'ExportTime': '2026-01-01T00:00:00Z',
            'StartTime': '2026-01-01T00:01:00Z',
            'EndTime': '2026-01-01T00:02:00Z',
          },
        };

        final response = await server.handleApiGatewayEvent({
          'httpMethod': 'GET',
          'path': '/api/admin/storage/export/list',
          'queryStringParameters': {'includeDetails': 'true'},
          'headers': <String, String>{},
        }, router);

        expect(response['statusCode'], equals(200));
        final body =
            jsonDecode(response['body'] as String) as Map<String, dynamic>;
        final summaries = body['ExportSummaries'] as List<dynamic>;
        expect(summaries, hasLength(1));
        expect(
          (summaries.first as Map<String, dynamic>)['S3Bucket'],
          equals('bucket-a'),
        );
        expect(storage.describeExportRequests, hasLength(1));
      },
    );

    test(
      'GET /api/admin/storage/export/list-files resolves exportArn to manifest prefix',
      () async {
        final media = FakeAwsMediaStorage()
          ..listResponse = {
            'items': [
              {'key': 'exports/diag/AWSDynamoDB/exp-1/manifest-summary.json'},
            ],
            'isTruncated': false,
            'nextContinuationToken': null,
          };
        storage
            .describeExportResponses['arn:aws:dynamodb:us-east-1:123456789012:table/test/export/exp-1'] = {
          'ExportDescription': {
            'ExportArn':
                'arn:aws:dynamodb:us-east-1:123456789012:table/test/export/exp-1',
            'ExportManifest':
                'exports/diag/AWSDynamoDB/exp-1/manifest-summary.json',
            'S3Prefix': 'exports/diag',
          },
        };
        server = AwsRestApiServer(
          serverName: 'TestServer',
          storage: storage,
          mediaStorage: media,
        );
        router = server.getRouter();

        final response = await server.handleApiGatewayEvent({
          'httpMethod': 'GET',
          'path': '/api/admin/storage/export/list-files',
          'queryStringParameters': {
            'exportArn':
                'arn:aws:dynamodb:us-east-1:123456789012:table/test/export/exp-1',
          },
          'headers': <String, String>{},
        }, router);

        expect(response['statusCode'], equals(200));
        expect(media.lastPrefix, equals('exports/diag/AWSDynamoDB/exp-1/'));
        final body =
            jsonDecode(response['body'] as String) as Map<String, dynamic>;
        expect(body['items'], isA<List<dynamic>>());
      },
    );
  });
}
