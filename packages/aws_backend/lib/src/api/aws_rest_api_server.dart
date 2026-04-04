import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart';

import '../storage/dynamodb_storage_service.dart';
import '../storage/media/aws_media_storage.dart';

/// AWS DynamoDB-backed REST API server.
///
/// This server extends the base functionality with DynamoDB storage
/// and provides the same API endpoints as local servers.
class AwsRestApiServer extends BaseRestApiServer {
  final Map<String, String> _healthEnvironment;

  AwsRestApiServer({
    required super.serverName,
    required DynamoDBStorageService super.storage,
    BaseMediaStorage? mediaStorage,
    Map<String, String>? healthEnvironmentOverrides,
  }) : _healthEnvironment = {
         ...Platform.environment,
         ...?healthEnvironmentOverrides,
       },
       super(mediaStorage: mediaStorage ?? NullMediaStorage());

  @override
  String get storageTypeDescription => 'AWS DynamoDB';

  @override
  Map<String, String> get healthEnvironment => _healthEnvironment;

  @override
  List<Map<String, dynamic>> get customApiDocEndpoints => [
    {
      'method': 'POST',
      'path': '/api/admin/storage/export/create',
      'description':
          'Start a DynamoDB ExportTableToPointInTime job using the supplied AWS export payload.',
      'requestBody': {
        'type': 'object',
        'description':
            'AWS ExportTableToPointInTime request payload. Typical fields include TableArn, S3Bucket, S3Prefix, ExportFormat, and ExportType.',
      },
      'response': {
        'type': 'object',
        'description':
            'Raw AWS ExportTableToPointInTime response payload, including ExportDescription when successful.',
      },
    },
    {
      'method': 'GET',
      'path': '/api/admin/storage/export/list',
      'description': 'List DynamoDB export jobs via AWS ListExports.',
      'parameters': [
        {
          'name': 'TableArn',
          'type': 'string',
          'required': false,
          'description': 'Optional DynamoDB table ARN to filter exports.',
        },
        {
          'name': 'MaxResults',
          'type': 'integer',
          'required': false,
          'description': 'Optional maximum number of export records to return.',
        },
        {
          'name': 'NextToken',
          'type': 'string',
          'required': false,
          'description': 'AWS pagination token returned from a previous call.',
        },
      ],
      'response': {
        'type': 'object',
        'description':
            'Raw AWS ListExports response payload, including ExportSummaries and NextToken when present.',
      },
    },
    {
      'method': 'GET',
      'path': '/api/admin/storage/export/list-files',
      'description':
          'List exported files under an S3 prefix and return presigned GET URLs for each object.',
      'parameters': [
        {
          'name': 'prefix',
          'type': 'string',
          'required': true,
          'description': 'S3 prefix for a specific export output folder.',
        },
        {
          'name': 'maxKeys',
          'type': 'integer',
          'required': false,
          'description': 'Optional maximum number of objects to return.',
        },
        {
          'name': 'continuationToken',
          'type': 'string',
          'required': false,
          'description': 'S3 continuation token for paginated listing.',
        },
      ],
      'response': {
        'type': 'object',
        'properties': {
          'items': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'key': {'type': 'string'},
                'size': {'type': 'integer'},
                'lastModified': {'type': 'string', 'format': 'ISO8601'},
                'getUrl': {'type': 'string'},
              },
            },
          },
          'isTruncated': {'type': 'boolean'},
          'nextContinuationToken': {'type': 'string'},
        },
      },
    },
  ];

  /// Get the router for use in debugging or custom server setups
  Router getRouter() => buildRouter();

  @override
  void addCustomRoutes(Router router) {
    // Admin export endpoints: start export, list exports, and list exported files
    router.post('/api/admin/storage/export/create', _handleExportCreate);
    router.get('/api/admin/storage/export/list', _handleExportList);
    router.get('/api/admin/storage/export/list-files', _handleExportListFiles);
  }

  Future<Response> _handleExportCreate(Request request) async {
    try {
      final body = await request.readAsString();
      final payload = body.isNotEmpty
          ? jsonDecode(body) as Map<String, dynamic>
          : <String, dynamic>{};
      final dynamo = storage as DynamoDBStorageService;
      final result = await dynamo.startExportToS3(payload);
      return Response.ok(
        jsonEncode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, st) {
      SlttLogger.logger.severe('Export create failed: $e\n$st');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _handleExportList(Request request) async {
    try {
      final params = <String, dynamic>{};
      // Use query parameters as-is for simplicity (convert common numeric values)
      request.url.queryParameters.forEach((k, v) {
        final numVal = int.tryParse(v);
        params[k] = numVal ?? v;
      });
      final dynamo = storage as DynamoDBStorageService;
      final result = await dynamo.listExports(params);
      return Response.ok(
        jsonEncode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, st) {
      SlttLogger.logger.severe('Export list failed: $e\n$st');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _handleExportListFiles(Request request) async {
    try {
      final prefix = request.url.queryParameters['prefix']?.trim() ?? '';
      final maxKeys = int.tryParse(
        request.url.queryParameters['maxKeys'] ?? '',
      );
      final continuationToken =
          request.url.queryParameters['continuationToken'];

      if (prefix.isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'Query parameter "prefix" is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (mediaStorage is! AwsMediaStorage) {
        return Response(
          400,
          body: jsonEncode({
            'error': 'Media storage does not support S3 listing',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final media = mediaStorage as AwsMediaStorage;
      final result = await media.listObjectsWithPresignedUrls(
        prefix: prefix,
        maxKeys: maxKeys,
        continuationToken: continuationToken,
      );

      return Response.ok(
        jsonEncode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, st) {
      SlttLogger.logger.severe('Export list-files failed: $e\n$st');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Handle AWS API Gateway event (for Lambda deployment)
  Future<Map<String, dynamic>> handleApiGatewayEvent(
    Map<String, dynamic> event,
    Router router,
  ) async {
    try {
      // Convert API Gateway event to Shelf request
      final request = _convertApiGatewayEventToRequest(event);

      // Process with provided router
      final response = await router(request);

      // Convert Shelf response to API Gateway response
      return _convertResponseToApiGateway(response);
    } catch (e) {
      return {
        'statusCode': 500,
        'body': jsonEncode({'error': 'Internal server error: $e'}),
        'headers': {'Content-Type': 'application/json'},
      };
    }
  }

  /// Convert API Gateway event to Shelf Request
  Request _convertApiGatewayEventToRequest(Map<String, dynamic> event) {
    final method = event['httpMethod'] as String? ?? 'GET';
    final path = event['path'] as String? ?? '/';
    final queryParams = event['queryStringParameters'] as Map<String, dynamic>?;
    final headers = event['headers'] as Map<String, dynamic>? ?? {};
    final body = event['body'] as String? ?? '';

    // Create an absolute URI for the Request constructor
    final uri = Uri(
      scheme: 'https',
      host: 'api.lambda.local',
      path: path,
      queryParameters: queryParams?.cast<String, String>(),
    );

    return Request(
      method,
      uri,
      headers: headers.cast<String, String>(),
      body: body,
    );
  }

  /// Convert Shelf Response to API Gateway response
  Future<Map<String, dynamic>> _convertResponseToApiGateway(
    Response response,
  ) async {
    final body = await response.readAsString();

    return {
      'statusCode': response.statusCode,
      'headers': {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        ...response.headers,
      },
      'body': body,
    };
  }
}
