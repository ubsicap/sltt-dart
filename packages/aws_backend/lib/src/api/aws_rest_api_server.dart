import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart';

import '../auth/auth_models.dart';
import '../auth/auth_service.dart';
import '../storage/dynamodb_storage_service.dart';
import '../storage/media/aws_media_storage.dart';

/// AWS DynamoDB-backed REST API server.
///
/// This server extends the base functionality with DynamoDB storage
/// and provides the same API endpoints as local servers.
class AwsRestApiServer extends BaseRestApiServer {
  static const String _defaultExportS3Prefix = 'dynamodb-exports/diag';
  static const int _exportCreateConflictScanLimit = 20;
  static const Set<String> _activeExportStatuses = {'IN_PROGRESS'};

  final Map<String, String> _healthEnvironment;
  final BackendAuthService? authService;

  AwsRestApiServer({
    required super.serverName,
    required DynamoDBStorageService super.storage,
    BaseMediaStorage? mediaStorage,
    Map<String, String>? healthEnvironmentOverrides,
    this.authService,
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
      'path': '/api/auth/register',
      'description':
          'Start self-registration for standard users and send a 6-digit verification code valid for 10 minutes. Response remains neutral when the email already exists.',
      'requestBody': {
        'type': 'object',
        'required': ['userId', 'name', 'dateOfBirth', 'email', 'password'],
        'properties': {
          'userId': {'type': 'string'},
          'name': {'type': 'string'},
          'dateOfBirth': {'type': 'string', 'format': 'yyyy-MM-dd'},
          'email': {'type': 'string'},
          'password': {'type': 'string'},
        },
      },
      'response': {
        'type': 'object',
        'properties': {
          'status': {'type': 'string', 'example': 'pending_verification'},
        },
      },
    },
    {
      'method': 'POST',
      'path': '/api/auth/verify-email',
      'description':
          'Verify the 6-digit email code and issue access and refresh tokens.',
      'requestBody': {
        'type': 'object',
        'required': ['email', 'code'],
        'properties': {
          'email': {'type': 'string'},
          'code': {'type': 'string'},
        },
      },
      'response': {
        'type': 'object',
        'properties': {
          'status': {'type': 'string', 'example': 'verified'},
          'userId': {'type': 'string'},
          'accessToken': {'type': 'string'},
          'refreshToken': {'type': 'string'},
          'expiresAt': {'type': 'string', 'format': 'ISO8601'},
        },
      },
    },
    {
      'method': 'POST',
      'path': '/api/auth/resend-verification-code',
      'description':
          'Resend the verification code for an unverified email registration. Response remains neutral.',
      'requestBody': {
        'type': 'object',
        'required': ['email'],
        'properties': {
          'email': {'type': 'string'},
        },
      },
      'response': {
        'type': 'object',
        'properties': {
          'status': {'type': 'string', 'example': 'sent'},
        },
      },
    },
    {
      'method': 'POST',
      'path': '/api/auth/login',
      'description':
          'Authenticate with email or username plus password and issue access and refresh tokens.',
      'requestBody': {
        'type': 'object',
        'required': ['identifier', 'password'],
        'properties': {
          'identifier': {'type': 'string'},
          'password': {'type': 'string'},
        },
      },
      'response': {
        'type': 'object',
        'properties': {
          'status': {'type': 'string', 'example': 'authenticated'},
          'userId': {'type': 'string'},
          'accessToken': {'type': 'string'},
          'refreshToken': {'type': 'string'},
          'expiresAt': {'type': 'string', 'format': 'ISO8601'},
        },
      },
    },
    {
      'method': 'POST',
      'path': '/api/auth/refresh',
      'description': 'Exchange a refresh token for a new access token.',
      'requestBody': {
        'type': 'object',
        'required': ['refreshToken'],
        'properties': {
          'refreshToken': {'type': 'string'},
        },
      },
      'response': {
        'type': 'object',
        'properties': {
          'status': {'type': 'string', 'example': 'authenticated'},
          'accessToken': {'type': 'string'},
          'refreshToken': {'type': 'string'},
          'expiresAt': {'type': 'string', 'format': 'ISO8601'},
        },
      },
    },
    {
      'method': 'POST',
      'path': '/api/auth/logout',
      'description': 'Revoke the current authenticated session.',
      'requestBody': {
        'type': 'object',
        'properties': {
          'refreshToken': {'type': 'string'},
        },
      },
      'response': {
        'type': 'object',
        'properties': {
          'status': {'type': 'string', 'example': 'logged_out'},
        },
      },
    },
    {
      'method': 'GET',
      'path': '/api/admin/adhoc-users',
      'description':
          'List AdHoc users visible to the authenticated administrator across the projects they manage.',
      'security': [
        {'bearerAuth': []},
      ],
    },
    {
      'method': 'POST',
      'path': '/api/admin/adhoc-users',
      'description':
          'Create an AdHoc user with username/password credentials and assign managed projects.',
      'security': [
        {'bearerAuth': []},
      ],
      'requestBody': {
        'type': 'object',
        'required': [
          'userId',
          'name',
          'username',
          'password',
          'projectIds',
          'adminPassword',
        ],
        'properties': {
          'userId': {'type': 'string'},
          'name': {'type': 'string'},
          'username': {'type': 'string'},
          'password': {'type': 'string'},
          'dateOfBirth': {'type': 'string', 'format': 'yyyy-MM-dd'},
          'projectIds': {
            'type': 'array',
            'items': {'type': 'string'},
          },
          'adminPassword': {'type': 'string'},
        },
      },
    },
    {
      'method': 'PUT',
      'path': '/api/admin/adhoc-users/{userId}/projects',
      'description':
          'Apply explicit project assignment changes for an AdHoc user. Caller must be an admin of every project listed in addProjectIds or removeProjectIds.',
      'security': [
        {'bearerAuth': []},
      ],
      'requestBody': {
        'type': 'object',
        'required': ['adminPassword'],
        'properties': {
          'addProjectIds': {
            'type': 'array',
            'items': {'type': 'string'},
          },
          'removeProjectIds': {
            'type': 'array',
            'items': {'type': 'string'},
          },
          'adminPassword': {'type': 'string'},
        },
      },
    },
    {
      'method': 'POST',
      'path': '/api/admin/adhoc-users/{userId}/reset-password',
      'description':
          'Reset an AdHoc user password after administrator password confirmation.',
      'security': [
        {'bearerAuth': []},
      ],
    },
    {
      'method': 'DELETE',
      'path': '/api/admin/adhoc-users/{userId}',
      'description':
          'Delete an AdHoc user and revoke all project access after administrator password confirmation.',
      'security': [
        {'bearerAuth': []},
      ],
    },
    {
      'method': 'POST',
      'path': '/api/admin/storage/export/create',
      'description':
          'Start a DynamoDB ExportTableToPointInTime job using server-managed table and S3 destination defaults. The server always uses DYNAMODB_TABLE/DYNAMODB_TABLE_ARN for the table, MEDIA_BUCKET for the bucket, dynamodb-exports/diag for the S3 prefix, and a generated ClientToken for idempotency. Before creating a new export, the server checks recent exports and rejects a request when another export of the same type is already in progress.',
      'requestBody': {
        'type': 'object',
        'required': ['ExportFormat'],
        'description':
            'Client-supplied export options. The client should provide only export format, whether the export is full or incremental, and optional export timestamps. TableArn, S3Bucket, and S3Prefix are supplied by the server.',
        'properties': {
          'ExportFormat': {
            'type': 'string',
            'description':
                'Required export file format. Typical values are DYNAMODB_JSON or ION.',
          },
          'ExportType': {
            'type': 'string',
            'description':
                'Optional export mode. Use FULL_EXPORT or INCREMENTAL_EXPORT. AWS defaults to FULL_EXPORT when omitted.',
          },
          'ExportTime': {
            'type': 'string',
            'format': 'ISO8601',
            'description':
                'Optional point-in-time timestamp for a full export.',
          },
          'IncrementalExportSpecification': {
            'type': 'object',
            'description':
                'Required for incremental exports. Supply the incremental time window and optional view type.',
            'properties': {
              'ExportFromTime': {'type': 'string', 'format': 'ISO8601'},
              'ExportToTime': {'type': 'string', 'format': 'ISO8601'},
              'ExportViewType': {
                'type': 'string',
                'description':
                    'Optional AWS incremental view type such as NEW_AND_OLD_IMAGES or NEW_IMAGES.',
              },
            },
          },
        },
        'serverDefaults': {
          'table': 'DYNAMODB_TABLE / DYNAMODB_TABLE_ARN',
          'bucket': 'MEDIA_BUCKET',
          'prefix': _defaultExportS3Prefix,
          'clientToken': 'server-generated',
        },
        'examples': [
          {'ExportFormat': 'DYNAMODB_JSON', 'ExportType': 'FULL_EXPORT'},
          {
            'ExportFormat': 'DYNAMODB_JSON',
            'ExportType': 'INCREMENTAL_EXPORT',
            'IncrementalExportSpecification': {
              'ExportFromTime': '2026-04-04T00:00:00Z',
              'ExportToTime': '2026-04-04T01:00:00Z',
            },
          },
        ],
      },
      'response': {
        'type': 'object',
        'description':
            'Raw AWS ExportTableToPointInTime response payload, including ExportDescription when successful. Returns HTTP 409 when a recent export of the same type is already in progress.',
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
        {
          'name': 'includeDetails',
          'type': 'boolean',
          'required': false,
          'description':
              'When true, hydrate each export summary with DescribeExport fields such as S3Bucket, S3Prefix, ExportTime, StartTime, EndTime, and ExportManifest.',
        },
      ],
      'response': {
        'type': 'object',
        'description':
            'AWS ListExports response payload. When includeDetails=true, each entry in ExportSummaries is enriched with DescribeExport fields.',
      },
    },
    {
      'method': 'GET',
      'path': '/api/admin/storage/export/list-files',
      'description':
          'List exported files under an S3 prefix or by export ARN and return presigned GET URLs for each object.',
      'parameters': [
        {
          'name': 'prefix',
          'type': 'string',
          'required': false,
          'description':
              'S3 prefix for a specific export output folder. Provide this or exportArn.',
        },
        {
          'name': 'exportArn',
          'type': 'string',
          'required': false,
          'description':
              'DynamoDB export ARN to resolve into the export output folder automatically. Provide this or prefix.',
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
    router.post('/api/auth/register', _handleAuthRegister);
    router.post('/api/auth/verify-email', _handleAuthVerifyEmail);
    router.post(
      '/api/auth/resend-verification-code',
      _handleAuthResendVerificationCode,
    );
    router.post('/api/auth/login', _handleAuthLogin);
    router.post('/api/auth/refresh', _handleAuthRefresh);
    router.post('/api/auth/logout', _handleAuthLogout);
    router.get('/api/admin/adhoc-users', _handleAdminListAdHocUsers);
    router.post('/api/admin/adhoc-users', _handleAdminCreateAdHocUser);
    router.put(
      '/api/admin/adhoc-users/<userId>/projects',
      _handleAdminUpdateAdHocProjects,
    );
    router.post(
      '/api/admin/adhoc-users/<userId>/reset-password',
      _handleAdminResetAdHocPassword,
    );
    router.delete(
      '/api/admin/adhoc-users/<userId>',
      _handleAdminDeleteAdHocUser,
    );
    // Admin export endpoints: start export, list exports, and list exported files
    router.post('/api/admin/storage/export/create', _handleExportCreate);
    router.get('/api/admin/storage/export/list', _handleExportList);
    router.get('/api/admin/storage/export/list-files', _handleExportListFiles);
  }

  Future<Response> _handleAuthRegister(Request request) async {
    return _handleAuthRequest(() async {
      final body = await _readBodyMap(request);
      final result = await _requireAuthService().register(
        RegisterRequest.fromJson(body),
      );
      return _jsonResponse(200, result.toJson());
    });
  }

  Future<Response> _handleAuthVerifyEmail(Request request) async {
    return _handleAuthRequest(() async {
      final body = await _readBodyMap(request);
      final result = await _requireAuthService().verifyEmail(
        VerifyEmailRequest.fromJson(body),
      );
      return _jsonResponse(200, result.toJson());
    });
  }

  Future<Response> _handleAuthResendVerificationCode(Request request) async {
    return _handleAuthRequest(() async {
      final body = await _readBodyMap(request);
      final result = await _requireAuthService().resendVerificationCode(
        ResendVerificationCodeRequest.fromJson(body),
      );
      return _jsonResponse(200, result.toJson());
    });
  }

  Future<Response> _handleAuthLogin(Request request) async {
    return _handleAuthRequest(() async {
      final body = await _readBodyMap(request);
      final result = await _requireAuthService().login(
        LoginRequest.fromJson(body),
      );
      return _jsonResponse(200, result.toJson());
    });
  }

  Future<Response> _handleAuthRefresh(Request request) async {
    return _handleAuthRequest(() async {
      final body = await _readBodyMap(request);
      final result = await _requireAuthService().refresh(
        RefreshRequest.fromJson(body),
      );
      return _jsonResponse(200, result.toJson());
    });
  }

  Future<Response> _handleAuthLogout(Request request) async {
    return _handleAuthRequest(() async {
      final session = _requireAuthenticatedSession(request);
      final body = await _readBodyMap(request);
      final result = await _requireAuthService().logout(
        session: session,
        request: LogoutRequest.fromJson(body),
      );
      return _jsonResponse(200, result.toJson());
    });
  }

  Future<Response> _handleAdminListAdHocUsers(Request request) async {
    return _handleAuthRequest(() async {
      final session = _requireAuthenticatedSession(request);
      final result = await _requireAuthService().listAdHocUsers(
        session: session,
      );
      return _jsonResponse(200, result.toJson());
    });
  }

  Future<Response> _handleAdminCreateAdHocUser(Request request) async {
    return _handleAuthRequest(() async {
      final session = _requireAuthenticatedSession(request);
      final body = await _readBodyMap(request);
      final result = await _requireAuthService().createAdHocUser(
        session: session,
        request: CreateAdHocUserRequest.fromJson(body),
      );
      return _jsonResponse(201, result.toJson());
    });
  }

  Future<Response> _handleAdminUpdateAdHocProjects(Request request) async {
    return _handleAuthRequest(() async {
      final session = _requireAuthenticatedSession(request);
      final body = await _readBodyMap(request);
      final result = await _requireAuthService().updateAdHocProjects(
        session: session,
        userId: request.params['userId'] ?? '',
        request: UpdateAdHocProjectsRequest.fromJson(body),
      );
      return _jsonResponse(200, result.toJson());
    });
  }

  Future<Response> _handleAdminResetAdHocPassword(Request request) async {
    return _handleAuthRequest(() async {
      final session = _requireAuthenticatedSession(request);
      final body = await _readBodyMap(request);
      final result = await _requireAuthService().resetAdHocPassword(
        session: session,
        userId: request.params['userId'] ?? '',
        request: ResetAdHocPasswordRequest.fromJson(body),
      );
      return _jsonResponse(200, result.toJson());
    });
  }

  Future<Response> _handleAdminDeleteAdHocUser(Request request) async {
    return _handleAuthRequest(() async {
      final session = _requireAuthenticatedSession(request);
      final body = await _readBodyMap(request);
      final result = await _requireAuthService().deleteAdHocUser(
        session: session,
        userId: request.params['userId'] ?? '',
        request: DeleteAdHocUserRequest.fromJson(body),
      );
      return _jsonResponse(200, result.toJson());
    });
  }

  Future<Response> _handleExportCreate(Request request) async {
    try {
      final body = await request.readAsString();
      final payload = body.isNotEmpty
          ? jsonDecode(body) as Map<String, dynamic>
          : <String, dynamic>{};
      final exportRequest = _buildExportCreatePayload(payload);
      final dynamo = storage as DynamoDBStorageService;
      final conflict = await _findInProgressExportConflict(
        dynamo,
        exportRequest,
      );
      if (conflict != null) {
        return Response(
          409,
          body: jsonEncode({
            'error':
                'An ${conflict.exportType} export is already in progress for this table.',
            'conflict': conflict.toJson(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
      final result = await dynamo.startExportToS3(exportRequest);
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
      var includeDetails = false;
      // Use query parameters as-is for simplicity (convert common numeric values)
      request.url.queryParameters.forEach((k, v) {
        if (k == 'includeDetails') {
          includeDetails =
              v.toLowerCase() == 'true' || v == '1' || v.toLowerCase() == 'yes';
          return;
        }
        final numVal = int.tryParse(v);
        params[k] = numVal ?? v;
      });
      final dynamo = storage as DynamoDBStorageService;
      final result = await dynamo.listExports(params);
      final responseBody = includeDetails
          ? await _enrichExportListResponse(dynamo, result)
          : result;
      return Response.ok(
        jsonEncode(responseBody),
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
      var prefix = request.url.queryParameters['prefix']?.trim() ?? '';
      final exportArn = request.url.queryParameters['exportArn']?.trim() ?? '';
      final maxKeys = int.tryParse(
        request.url.queryParameters['maxKeys'] ?? '',
      );
      final continuationToken =
          request.url.queryParameters['continuationToken'];

      if (_looksLikeExportArn(prefix) && exportArn.isEmpty) {
        prefix = await _resolveExportPrefixFromArn(prefix);
      } else if (prefix.isEmpty && exportArn.isNotEmpty) {
        prefix = await _resolveExportPrefixFromArn(exportArn);
      }

      if (prefix.isEmpty) {
        return Response(
          400,
          body: jsonEncode({
            'error': 'Query parameter "prefix" or "exportArn" is required',
          }),
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

  Future<Map<String, dynamic>> _enrichExportListResponse(
    DynamoDBStorageService dynamo,
    Map<String, dynamic> listResponse,
  ) async {
    final summaries = (listResponse['ExportSummaries'] as List?) ?? const [];
    final enriched = <Map<String, dynamic>>[];

    for (final summary in summaries) {
      if (summary is! Map) continue;
      final summaryMap = Map<String, dynamic>.from(summary);
      final exportArn = summaryMap['ExportArn'] as String?;
      if (exportArn == null || exportArn.isEmpty) {
        enriched.add(summaryMap);
        continue;
      }

      final detailResponse = await dynamo.describeExport({
        'ExportArn': exportArn,
      });
      final detail = detailResponse['ExportDescription'];
      if (detail is Map) {
        enriched.add({...summaryMap, ...Map<String, dynamic>.from(detail)});
      } else {
        enriched.add(summaryMap);
      }
    }

    return {...listResponse, 'ExportSummaries': enriched};
  }

  bool _looksLikeExportArn(String value) {
    return value.startsWith('arn:aws:dynamodb:') && value.contains('/export/');
  }

  Future<String> _resolveExportPrefixFromArn(String exportArn) async {
    final dynamo = storage as DynamoDBStorageService;
    final detailResponse = await dynamo.describeExport({
      'ExportArn': exportArn,
    });
    final detail = detailResponse['ExportDescription'];
    if (detail is! Map) {
      throw StateError('DescribeExport did not return ExportDescription');
    }

    final manifest = detail['ExportManifest'] as String?;
    if (manifest != null && manifest.isNotEmpty) {
      final slashIndex = manifest.lastIndexOf('/');
      if (slashIndex > 0) {
        return manifest.substring(0, slashIndex + 1);
      }
    }

    final s3Prefix = (detail['S3Prefix'] as String?)?.trim() ?? '';
    final exportId = exportArn.split('/').last.trim();
    if (s3Prefix.isEmpty || exportId.isEmpty) {
      throw StateError('Unable to resolve export files prefix from exportArn');
    }

    return '$s3Prefix/AWSDynamoDB/$exportId/';
  }

  Map<String, dynamic> _buildExportCreatePayload(
    Map<String, dynamic> clientPayload,
  ) {
    final exportFormat = (clientPayload['ExportFormat'] as String?)?.trim();
    if (exportFormat == null || exportFormat.isEmpty) {
      throw StateError('ExportFormat is required');
    }

    final tableArn = _resolveConfiguredExportTableArn();
    final bucket = _requireHealthEnvironmentValue('MEDIA_BUCKET');
    final clientToken = _buildExportClientToken(clientPayload);

    return {
      ...clientPayload,
      'TableArn': tableArn,
      'S3Bucket': bucket,
      'S3Prefix': _defaultExportS3Prefix,
      'ClientToken': clientToken,
    };
  }

  String _buildExportClientToken(Map<String, dynamic> clientPayload) {
    final exportType = _normalizedExportType(
      clientPayload['ExportType'] as String?,
    ).toLowerCase();
    final timestamp = DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch
        .toRadixString(36);
    final typeHash = exportType.hashCode.abs().toRadixString(36);
    return 'sltt$timestamp$typeHash';
  }

  Future<_ExportConflict?> _findInProgressExportConflict(
    DynamoDBStorageService dynamo,
    Map<String, dynamic> exportRequest,
  ) async {
    final tableArn = exportRequest['TableArn'] as String;
    final requestedType = _normalizedExportType(
      exportRequest['ExportType'] as String?,
    );
    final listResponse = await dynamo.listExports({
      'TableArn': tableArn,
      'MaxResults': _exportCreateConflictScanLimit,
    });
    final summaries = listResponse['ExportSummaries'];
    if (summaries is! List) {
      return null;
    }

    for (final summary in summaries) {
      if (summary is! Map) continue;
      final summaryMap = Map<String, dynamic>.from(summary);
      final exportType = _normalizedExportType(
        summaryMap['ExportType'] as String?,
      );
      final exportStatus = (summaryMap['ExportStatus'] as String?)
          ?.trim()
          .toUpperCase();
      if (exportType != requestedType ||
          exportStatus == null ||
          !_activeExportStatuses.contains(exportStatus)) {
        continue;
      }

      return _ExportConflict(
        exportArn: summaryMap['ExportArn'] as String?,
        exportType: exportType,
        exportStatus: exportStatus,
      );
    }

    return null;
  }

  String _normalizedExportType(String? exportType) {
    final normalized = exportType?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      return 'FULL_EXPORT';
    }
    return normalized;
  }

  String _resolveConfiguredExportTableArn() {
    final explicitArn = (healthEnvironment['DYNAMODB_TABLE_ARN'] ?? '').trim();
    if (explicitArn.isNotEmpty) {
      return explicitArn;
    }

    final configuredTable = _requireHealthEnvironmentValue('DYNAMODB_TABLE');
    if (configuredTable.startsWith('arn:aws:dynamodb:')) {
      return configuredTable;
    }

    throw StateError(
      'DYNAMODB_TABLE_ARN environment variable is required when DYNAMODB_TABLE is not already a table ARN',
    );
  }

  String _requireHealthEnvironmentValue(String key) {
    final value = (healthEnvironment[key] ?? '').trim();
    if (value.isEmpty) {
      throw StateError('$key environment variable is required');
    }
    return value;
  }

  BackendAuthService _requireAuthService() {
    if (authService == null) {
      throw AuthException(
        'Authentication service is not configured',
        statusCode: 503,
        code: 'auth_unavailable',
      );
    }
    return authService!;
  }

  AuthenticatedSession _requireAuthenticatedSession(Request request) {
    final header = request.headers['authorization'];
    if (header == null || header.trim().isEmpty) {
      throw AuthException(
        'Invalid credentials',
        statusCode: 401,
        code: 'invalid_credentials',
      );
    }
    return _requireAuthService().authenticateBearerToken(header);
  }

  Future<Map<String, dynamic>> _readBodyMap(Request request) async {
    final body = await request.readAsString();
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw AuthException(
        'Unable to complete this action',
        code: 'invalid_request',
      );
    }
    return decoded;
  }

  Response _jsonResponse(int statusCode, Map<String, dynamic> payload) {
    return Response(
      statusCode,
      body: jsonEncode(payload),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _handleAuthRequest(
    Future<Response> Function() action,
  ) async {
    try {
      return await action();
    } on AuthException catch (e) {
      return _jsonResponse(e.statusCode, e.toJson());
    } catch (e, st) {
      SlttLogger.logger.severe('Auth request failed: $e\n$st');
      return _jsonResponse(500, const {
        'error': 'Unable to complete this action',
        'code': 'internal_error',
      });
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

class _ExportConflict {
  const _ExportConflict({
    required this.exportArn,
    required this.exportType,
    required this.exportStatus,
  });

  final String? exportArn;
  final String exportType;
  final String exportStatus;

  Map<String, dynamic> toJson() => {
    'exportArn': exportArn,
    'exportType': exportType,
    'exportStatus': exportStatus,
  };
}
