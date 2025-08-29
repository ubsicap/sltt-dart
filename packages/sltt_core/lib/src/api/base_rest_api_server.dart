import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart';

/// 380KB (~400KB) Maximum payload size for DynamoDB/APIGateway (in bytes)
final dynamodbPayloadLimit = 380000;

/// Base REST API server that provides common functionality for all storage types.
///
/// This eliminates code duplication between different server implementations
/// by providing shared endpoints, middleware, and error handling.
abstract class BaseRestApiServer {
  final String serverName;
  final BaseStorageService storage;

  HttpServer? _server;

  BaseRestApiServer({required this.serverName, required this.storage});

  /// Storage type description for API documentation
  String get storageTypeDescription;

  /// Extract and URL decode projectId from request parameters
  String? _extractProjectId(Request request) {
    final projectIdRaw = request.params['projectId'];
    if (projectIdRaw == null || projectIdRaw.isEmpty) {
      return null;
    }
    // URL decode the project ID to handle special characters like spaces, @, /, etc.
    return Uri.decodeComponent(projectIdRaw);
  }

  /// Additional server-specific endpoints (override if needed)
  void addCustomRoutes(Router router) {
    // Default: no custom routes
  }

  /// Start the server on the specified port
  Future<void> start({required int port}) async {
    if (_server != null) {
      print('[$serverName] Server is already running');
      return;
    }

    // Initialize the storage service
    await storage.initialize();

    final router = buildRouter();

    // Add CORS and logging middleware
    final handler = const Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(_customLogRequests(serverName: serverName, port: port))
        .addHandler(router.call);

    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    print('[$serverName] Server started on http://localhost:$port');
  }

  /// Build the router with standard endpoints
  @protected
  Router buildRouter() {
    final router = Router();

    // Standard endpoints (same for all servers)
    router.get('/health', _handleHealth);
    router.get('/api/help', _handleApiDocs);
    router.get(
      '/api/stats',
      _handleGetGlobalStats,
    ); // Global stats across all projects
    router.post('/api/changes', _handleCreateChanges);
    router.get('/api/domains', _handleGetDomainsAndTheirCollections);
    router.get('/api/domains/<domainType>/entities', _handleGetEntities);
    router.get('/api/projects', _handleGetProjects); // List all projects
    router.get('/api/projects/<projectId>/changes', _handleGetChanges);
    router.get('/api/projects/<projectId>/changes/<seq>', _handleGetChange);
    router.get('/api/projects/<projectId>/stats', _handleGetStats);
    router.get(
      '/api/projects/<projectId>/entities/<entityType>/state',
      _handleGetEntityState,
    );

    // Handle OPTIONS requests for CORS
    router.options('/<path|.*>', _handleOptions);

    // Allow subclasses to add custom routes
    addCustomRoutes(router);

    // 404 handler
    router.all('/<ignored|.*>', _handleNotFound);

    return router;
  }

  /// Health check endpoint
  Future<Response> _handleHealth(Request request) async {
    return Response.ok(
      jsonEncode({
        'status': 'healthy',
        'timestamp': DateTime.now().toIso8601String(),
        'server': serverName,
        'storageType': storageTypeDescription,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// API documentation endpoint
  Future<Response> _handleApiDocs(Request request) async {
    // Shared schema definitions to reduce duplication
    final changeObjectSchema = {
      'type': 'object',
      'properties': {
        'seq': {'type': 'integer', 'description': 'Sequence number'},
        'projectId': {'type': 'string', 'description': 'Project identifier'},
        'entityType': {'type': 'string', 'description': 'Type of entity'},
        'operation': {
          'type': 'string',
          'description': 'Operation type (create, update, delete)',
        },
        'entityId': {'type': 'string', 'description': 'Entity identifier'},
        'changeAt': {
          'type': 'string',
          'format': 'ISO8601',
          'description': 'When change was made',
        },
        'data': {'type': 'object', 'description': 'Change data payload'},
        'cid': {
          'type': 'string',
          'description':
              'Change ID - unique identifier for this change (format: YYYY-mmdd-HHMMss-sss±HHmm-{4-char-random})',
        },
      },
    };

    final paginationResponseSchema = {
      'type': 'object',
      'properties': {
        'changes': {
          'type': 'array',
          'items': changeObjectSchema,
          'description': 'List of changes',
        },
        'count': {
          'type': 'integer',
          'description': 'Number of changes returned',
        },
        'cursor': {
          'type': 'integer',
          'required': false,
          'description':
              'Next cursor for pagination (if more results available)',
        },
        'timestamp': {
          'type': 'string',
          'format': 'ISO8601',
          'description': 'When the response was generated',
        },
      },
    };

    final docs = {
      'server': {
        'name': serverName,
        'storageType': storageTypeDescription,
        'description':
            'SLTT API server with $storageTypeDescription storage - supports field-level change detection and conflict resolution',
        'features': [
          'Field-level change detection',
          'Conflict resolution based on timestamps',
          'No-op change tracking for optimization',
          'Automatic sequence number generation',
          'Multi-project isolation',
        ],
      },
      'endpoints': [
        {
          'method': 'GET',
          'path': '/health',
          'description': 'Health check - returns server status',
          'response': {
            'type': 'object',
            'properties': {
              'status': {
                'type': 'string',
                'description': 'Server health status (always "healthy")',
              },
              'timestamp': {
                'type': 'string',
                'format': 'ISO8601',
                'description': 'When the health check was performed',
              },
              'server': {
                'type': 'string',
                'description': 'Server name identifier',
              },
              'storageType': {
                'type': 'string',
                'description': 'Type of storage backend',
              },
            },
          },
        },
        {
          'method': 'GET',
          'path': '/api/help',
          'description': 'API documentation - returns this documentation',
          'response': {
            'type': 'object',
            'properties': {
              'server': {'type': 'object', 'description': 'Server information'},
              'endpoints': {
                'type': 'array',
                'description':
                    'List of available API endpoints with documentation',
              },
              'timestamp': {
                'type': 'string',
                'format': 'ISO8601',
                'description': 'When the documentation was generated',
              },
            },
          },
        },
        {
          'method': 'POST',
          'path': '/api/changes',
          'description':
              'Create new changes (array format) with field-level change detection',
          'requestBody': {
            'type': 'array',
            'items': {
              'type': 'object',
              'required': ['domainId', 'entityType', 'entityId'],
              'properties': {
                'domainId': {
                  'type': 'string',
                  'description': 'Domain identifier (e.g. projectId)',
                },
                'entityType': {
                  'type': 'string',
                  'description': 'Type of entity being changed',
                },
                'entityId': {
                  'type': 'string',
                  'description': 'Unique identifier for the entity',
                },
                'operation': {
                  'type': 'string',
                  'description': 'Operation type (create, update, delete)',
                  'default': 'create',
                },
                'data': {
                  'type': 'object',
                  'description': 'Change data payload',
                },
                'changeAt': {
                  'type': 'string',
                  'format': 'ISO8601',
                  'description':
                      'When change was made (optional, defaults to current time)',
                },
                'cid': {
                  'type': 'string',
                  'description':
                      'Change ID (optional, auto-generated if not provided)',
                },
              },
            },
          },
          'parameters': [
            {
              'name': 'changeUpdates',
              'in': 'query',
              'type': 'boolean',
              'required': false,
              'description':
                  'If true, include per-change `changeUpdates` details in the response',
            },
            {
              'name': 'stateUpdates',
              'in': 'query',
              'type': 'boolean',
              'required': false,
              'description':
                  'If true, include per-change `stateUpdates` details in the response',
            },
          ],
          'response': {
            'type': 'object',
            'properties': {
              'storageType': {
                'type': 'string',
                'description': 'Type of storage backend handling the request',
              },
              'storageId': {
                'type': 'string',
                'description':
                    'Identifier for the storage instance that processed the request',
              },
              'created': {
                'type': 'array',
                'items': {'type': 'string'},
                'description':
                    'List of CIDs that resulted in create operations',
              },
              'updated': {
                'type': 'array',
                'items': {'type': 'string'},
                'description':
                    'List of CIDs that resulted in update operations',
              },
              'deleted': {
                'type': 'array',
                'items': {'type': 'string'},
                'description':
                    'List of CIDs that resulted in delete operations',
              },
              'noOps': {
                'type': 'array',
                'items': {'type': 'string'},
                'description':
                    'List of CIDs that were no-ops (no state change)',
              },
              'clouded': {
                'type': 'array',
                'items': {'type': 'string'},
                'description':
                    'List of CIDs that were duplicates from cloud and required cloud-only metadata updates',
              },
              'dups': {
                'type': 'array',
                'items': {'type': 'string'},
                'description':
                    'List of CIDs identified as duplicate (no updates)',
              },
              'unknowns': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'properties': {
                    'cid': {'type': 'string'},
                    'unknown': {'type': 'object'},
                  },
                },
                'description':
                    'Preserved unknown fields from deserialized change entries',
              },
              'info': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'properties': {
                    'cid': {'type': 'string'},
                    'operation': {'type': 'string'},
                    'info': {'type': 'object'},
                  },
                },
                'description':
                    'Informational operation details (e.g., no-op fields, outdatedBys) for non-error changes',
              },
              'errors': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'properties': {
                    'cid': {'type': 'string'},
                    'info': {'type': 'object'},
                  },
                },
                'description':
                    'List of errors encountered while processing specific changes',
              },
              'changeUpdates': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'properties': {
                    'cid': {'type': 'string'},
                    'updates': {'type': 'object'},
                  },
                },
                'description':
                    'Per-change computed changeUpdate objects (included when ?changeUpdates=true)',
              },
              'stateUpdates': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'properties': {
                    'cid': {'type': 'string'},
                    'state': {'type': 'object'},
                  },
                },
                'description':
                    'Per-change computed state update objects (included when ?stateUpdates=true)',
              },
              'timestamp': {
                'type': 'string',
                'format': 'ISO8601',
                'description': 'When the response was generated',
              },
            },
          },
        },
        {
          'method': 'GET',
          'path': '/api/projects',
          'description': 'Get list of all projects that have changes',
          'response': {
            'type': 'object',
            'properties': {
              'projects': {
                'type': 'array',
                'items': {'type': 'string'},
                'description': 'List of project identifiers',
              },
              'count': {
                'type': 'integer',
                'description': 'Number of projects returned',
              },
              'timestamp': {
                'type': 'string',
                'format': 'ISO8601',
                'description': 'When the project list was generated',
              },
            },
          },
        },
        {
          'method': 'GET',
          'path': '/api/stats',
          'description': 'Get global statistics across all projects',
          'response': {
            'type': 'object',
            'properties': {
              'changeStats': {
                'type': 'object',
                'properties': {
                  'total': {
                    'type': 'integer',
                    'description':
                        'Total number of changes across all projects',
                  },
                  'projectCount': {
                    'type': 'integer',
                    'description': 'Number of projects with changes',
                  },
                },
              },
              'entityTypeStats': {
                'type': 'object',
                'description':
                    'Count of changes by entity type across all projects',
              },
              'timestamp': {
                'type': 'string',
                'format': 'ISO8601',
                'description': 'When the stats were generated',
              },
              'storageType': {
                'type': 'string',
                'description': 'Type of storage backend',
              },
            },
          },
        },
        {
          'method': 'GET',
          'path': '/api/changes',
          'description':
              'Get all changes from all projects with optional pagination (for sync)',
          'parameters': [
            {
              'name': 'cursor',
              'type': 'integer',
              'required': false,
              'description': 'Starting sequence number (exclusive)',
            },
            {
              'name': 'limit',
              'type': 'integer',
              'required': false,
              'description': 'Maximum number of results (1-1000)',
            },
          ],
          'response': paginationResponseSchema,
        },
        {
          'method': 'GET',
          'path': '/api/projects/{projectId}/changes',
          'description':
              'Get all changes for a project with optional pagination',
          'parameters': [
            {
              'name': 'projectId',
              'type': 'string',
              'required': true,
              'description': 'Project identifier',
            },
            {
              'name': 'cursor',
              'type': 'integer',
              'required': false,
              'description': 'Starting sequence number (exclusive)',
            },
            {
              'name': 'limit',
              'type': 'integer',
              'required': false,
              'description': 'Maximum number of results (1-1000)',
            },
          ],
          'response': {
            ...paginationResponseSchema,
            'properties': {
              ...paginationResponseSchema['properties'] as Map<String, dynamic>,
              'changes': {
                'type': 'array',
                'items': changeObjectSchema,
                'description': 'List of changes for the specified project',
              },
            },
          },
        },
        {
          'method': 'GET',
          'path': '/api/projects/{projectId}/changes/{seq}',
          'description': 'Get specific change by sequence number for a project',
          'parameters': [
            {
              'name': 'projectId',
              'type': 'string',
              'required': true,
              'description': 'Project identifier',
            },
            {
              'name': 'seq',
              'type': 'integer',
              'required': true,
              'description': 'Change sequence number',
            },
          ],
          'response': changeObjectSchema,
        },
        {
          'method': 'GET',
          'path': '/api/projects/{projectId}/stats',
          'description':
              'Get statistics about changes and entity types for a project',
          'parameters': [
            {
              'name': 'projectId',
              'type': 'string',
              'required': true,
              'description': 'Project identifier',
            },
          ],
          'response': {
            'type': 'object',
            'properties': {
              'projectId': {
                'type': 'string',
                'description': 'The project identifier',
              },
              'changeStats': {
                'type': 'object',
                'properties': {
                  'total': {
                    'type': 'integer',
                    'description': 'Total number of changes for this project',
                  },
                  'creates': {
                    'type': 'integer',
                    'description': 'Number of create operations',
                  },
                  'updates': {
                    'type': 'integer',
                    'description': 'Number of update operations',
                  },
                  'deletes': {
                    'type': 'integer',
                    'description': 'Number of delete operations',
                  },
                },
              },
              'entityTypeStats': {
                'type': 'object',
                'description': 'Statistics grouped by entity type',
              },
              'timestamp': {
                'type': 'string',
                'format': 'ISO8601',
                'description': 'When the stats were generated',
              },
              'storageType': {
                'type': 'string',
                'description': 'Type of storage backend',
              },
            },
          },
        },
        {
          'method': 'GET',
          'path': '/api/domains',
          'description': 'Get list of supported domains and their collections',
          'response': {
            'type': 'object',
            'properties': {
              'domains': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'properties': {
                    'name': {'type': 'string', 'description': 'Domain name'},
                    'collections': {
                      'type': 'array',
                      'items': {
                        'type': 'string',
                        'description': 'Collection name',
                      },
                    },
                  },
                },
              },
            },
          },
        },
        {
          'method': 'GET',
          'path': '/api/domains/{domainType}/entities',
          'description': 'Get list of supported entity types for a domain',
          'parameters': [
            {
              'name': 'domainType',
              'type': 'string',
              'required': true,
              'description': 'Domain type identifier',
            },
          ],
          'response': {
            'type': 'object',
            'properties': {
              'domainType': {
                'type': 'string',
                'description': 'The domain type identifier',
              },
              'entityTypes': {
                'type': 'array',
                'items': {'type': 'string'},
                'description':
                    'List of entity types that have data in this domain',
              },
            },
          },
        },
        {
          'method': 'GET',
          'path': '/api/projects/{projectId}/entities/{entityType}/state',
          'description':
              'Get entity state data with pagination and optional metadata',
          'parameters': [
            {
              'name': 'projectId',
              'type': 'string',
              'required': true,
              'description': 'Project identifier',
            },
            {
              'name': 'entityType',
              'type': 'string',
              'required': true,
              'description': 'Entity type (e.g., document, project, team)',
            },
            {
              'name': 'cursor',
              'type': 'string',
              'required': false,
              'description':
                  'Pagination cursor (last entityId from previous page)',
            },
            {
              'name': 'limit',
              'type': 'integer',
              'required': false,
              'description':
                  'Maximum number of items to return (1-1000, default: 100)',
            },
            {
              'name': 'field_metadata',
              'type': 'boolean',
              'required': false,
              'description':
                  'Include conflict resolution metadata (default: false)',
            },
          ],
          'response': {
            'type': 'object',
            'properties': {
              'projectId': {
                'type': 'string',
                'description': 'The project identifier',
              },
              'entityType': {
                'type': 'string',
                'description': 'The entity type',
              },
              'items': {
                'type': 'array',
                'items': {'type': 'object'},
                'description': 'List of entity state objects',
              },
              'cursor': {
                'type': 'string',
                'description': 'Next pagination cursor (null if no more data)',
              },
              'hasMore': {
                'type': 'boolean',
                'description': 'Whether there are more items available',
              },
              'fieldMetadata': {
                'type': 'boolean',
                'description':
                    'Whether field metadata is included in the response',
              },
              'timestamp': {
                'type': 'string',
                'format': 'ISO8601',
                'description': 'When the response was generated',
              },
            },
          },
        },
      ],
      'timestamp': DateTime.now().toIso8601String(),
    };

    return Response.ok(
      jsonEncode(docs),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _handleGetDomainsAndTheirCollections(Request request) async {
    try {
      final domainTypes = ['project']; // todo: 'user', 'team'
      final collections = [
        {
          'project': ['projects'],
        },
      ];

      final response = {'domains': domainTypes, 'collections': collections};

      return Response.ok(
        jsonEncode(response),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e, stackTrace) {
      print('Error getting domains: $e');
      print('Stack trace: $stackTrace');
      return _errorResponse(
        'Failed to get domains: ${e.toString()}',
        500,
        stackTrace,
      );
    }
  }

  /// Get all project IDs
  Future<Response> _handleGetProjects(Request request) async {
    try {
      final projects = await storage.getAllProjects();

      final response = {
        'projects': projects,
        'count': projects.length,
        'timestamp': DateTime.now().toIso8601String(),
      };

      return Response.ok(
        jsonEncode(response),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e, stackTrace) {
      print('Error getting projects: $e');
      print('Stack trace: $stackTrace');
      return _errorResponse(
        'Failed to get projects: ${e.toString()}',
        500,
        stackTrace,
      );
    }
  }

  /// Get changes with optional pagination
  Future<Response> _handleGetChanges(Request request) async {
    try {
      final projectId = _extractProjectId(request);
      if (projectId == null || projectId.isEmpty) {
        return _errorResponse('Project ID is required', 400);
      }

      final cursorParam = request.url.queryParameters['cursor'];
      final limitParam = request.url.queryParameters['limit'];

      int? cursor;
      if (cursorParam != null) {
        cursor = int.tryParse(cursorParam);
        if (cursor == null) {
          return _errorResponse(
            'Invalid cursor format: must be an integer',
            400,
          );
        }
      }

      int? limit;
      if (limitParam != null) {
        limit = int.tryParse(limitParam);
        if (limit == null || limit <= 0) {
          return _errorResponse(
            'Invalid limit format: must be a positive integer',
            400,
          );
        }
        if (limit > 1000) {
          return _errorResponse('Limit too large: maximum is 1000', 400);
        }
      }

      final changes = await storage.getChangesWithCursor(
        projectId: projectId,
        cursor: cursor,
        limit: limit,
      );

      final responseData = <String, dynamic>{
        'changes': changes.map((c) => c.toJson()).toList(),
        'count': changes.length,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Add cursor to response if there are more changes available
      if (changes.isNotEmpty && (limit == null || changes.length == limit)) {
        final lastChangeId = changes.last.seq;
        final moreChanges = await storage.getChangesWithCursor(
          projectId: projectId,
          cursor: lastChangeId,
          limit: 1,
        );

        if (moreChanges.isNotEmpty) {
          responseData['cursor'] = lastChangeId;
        }
      }

      return Response.ok(
        jsonEncode(responseData),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e) {
      return _errorResponse('Failed to fetch changes: $e', 500);
    }
  }

  /// Get specific change by sequence number
  Future<Response> _handleGetChange(Request request) async {
    try {
      final projectId = _extractProjectId(request);
      if (projectId == null || projectId.isEmpty) {
        return _errorResponse('Project ID is required', 400);
      }

      final seq = request.params['seq'];
      if (seq == null || seq.isEmpty) {
        return _errorResponse('Sequence number is required', 400);
      }

      final changeSeq = int.tryParse(seq);
      if (changeSeq == null) {
        return _errorResponse('Invalid change seq format: "$seq"', 400);
      }

      final change = await storage.getChange(projectId, changeSeq);
      if (change == null) {
        return _errorResponse('Change not found', 404);
      }

      final changeJson = change.toJson();
      print('_handleGetChange Response: ${jsonEncode(changeJson)}');
      return Response.ok(
        jsonEncode(changeJson),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e) {
      return _errorResponse('Failed to fetch change: $e', 500);
    }
  }

  /// Create new changes
  Future<Response> _handleCreateChanges(Request request) async {
    try {
      final body = await request.readAsString();

      // Handle JSON parsing errors
      late final dynamic data;
      try {
        data = jsonDecode(body);
      } on FormatException catch (e) {
        return _errorResponse('Invalid JSON format: ${e.message}', 400);
      }

      if (data is! List) {
        return _errorResponse('Request body must be an array of changes', 400);
      }

      // Safely cast to List<Map<String, dynamic>>
      late final List<Map<String, dynamic>> changesToCreate;
      try {
        changesToCreate = data.cast<Map<String, dynamic>>();
      } on TypeError {
        return _errorResponse(
          'Invalid change format: each item must be an object',
          400,
        );
      }

      if (changesToCreate.isEmpty) {
        return _errorResponse('No changes provided', 400);
      }
      final targetStorageId = await storage.getStorageId();
      final resultsSummary = <String, dynamic>{
        'storageType': storage.getStorageType(),
        'storageId': targetStorageId,
        'stateUpdates': [],
        'changeUpdates': [],
        'created': [],
        'updated': [],
        'deleted': [],
        'noOps': [],
        'clouded': [], // duplicates from the cloud
        'dups': [],
        'unknowns': [],
        'info': [],
        'errors': [],
      };

      // Validate all changes first
      for (int i = 0; i < changesToCreate.length; i++) {
        final changeData = changesToCreate[i];
        final changeLogEntry = deserializeChangeLogEntryUsingRegistry(
          changeData,
        );
        final cid = changeLogEntry.cid;

        if (changeLogEntry.storageId == targetStorageId) {
          // treat these changes as atomic since they originated on the same system
          // so exit early on any errors
          if (changeLogEntry.operation == 'error') {
            return _errorResponse(
              'Change[$i] cid($cid) deserialization encountered error: ${changeLogEntry.getOperationInfo()}',
              400,
            );
          }
          if (changeLogEntry.operation == 'hold') {
            // how could this ever happen on the same storage??
            return _errorResponse(
              'Change[$i] cid($cid) deserialization resulted in `hold`: ${changeLogEntry.getOperationInfo()}',
              400,
            );
          }
        } else {
          // treat these as a batch from a remote or LAN storage.
          // Preserve unknown entities for future processing
          // Q. Should we also preserve errors locally or only in the cloud?
          if (changeLogEntry.operation == 'error') {}
          if (changeLogEntry.operation == 'hold') {}
        }
        final entityState = await storage.getCurrentEntityState(
          changeLogEntry.domainId,
          changeLogEntry.entityType.toString(),
          changeLogEntry.entityId,
        );

        print(
          'after getCurrentEntityState - entityState: ${const JsonEncoder.withIndent('  ').convert(entityState?.toJson())}',
        );

        // final changeLogEntryFactory = deserializeChangeLogEntryUsingRegistry;
        // final entityStateFactory = deserializeEntityStateSafely;
        // Use enhanced change detection method
        final result = getUpdatesForChangeLogEntryAndEntityState(
          changeLogEntry,
          entityState,
          targetStorageId: targetStorageId,
        );
        // return error if targetStorageId is same as changeLogEntry.storageId and total state update payload is greater than dynamodb payload limits (assume state record is greater than change record)
        // on cloud storage, dynamodb will return its own error
        if (targetStorageId == changeLogEntry.storageId) {
          final mergedState = {
            if (entityState != null) ...entityState.toJson(),
            ...result.stateUpdates,
          };
          final entityStateRecordSize = utf8
              .encode(jsonEncode(mergedState))
              .lengthInBytes;
          if (entityStateRecordSize > dynamodbPayloadLimit) {
            return _errorResponse(
              'Change[$i] cid($cid) exceeds payload limits ($dynamodbPayloadLimit bytes)',
              400,
            );
          }
        }
        final updateResults = await storage.updateChangeLogAndState(
          changeLogEntry: changeLogEntry,
          changeUpdates: result.changeUpdates,
          entityState: entityState,
          stateUpdates: result.stateUpdates,
        );
        final newOperation = updateResults.newChangeLogEntry.operation;
        if (newOperation == 'create') {
          resultsSummary['created'].add(updateResults.newChangeLogEntry.cid);
        } else if (newOperation == 'update') {
          resultsSummary['updated'].add(updateResults.newChangeLogEntry.cid);
        } else if (newOperation == 'delete') {
          resultsSummary['deleted'].add(updateResults.newChangeLogEntry.cid);
        } else if (newOperation == 'no-op') {
          resultsSummary['noOps'].add(updateResults.newChangeLogEntry.cid);
        } else if (result.isDuplicate) {
          if (result.stateUpdates.isNotEmpty) {
            resultsSummary['clouded'].add(changeLogEntry.cid);
          } else {
            resultsSummary['dups'].add(changeLogEntry.cid);
          }
        } else if (updateResults.newChangeLogEntry.operation == 'error') {
          resultsSummary['errors'].add({
            'cid': updateResults.newChangeLogEntry.cid,
            'info': updateResults.newChangeLogEntry.getOperationInfo(),
          });
        }
        // TODO: summarize unknown fields?
        if (updateResults.newChangeLogEntry.getUnknown().isNotEmpty) {
          resultsSummary['unknowns'].add({
            'cid': updateResults.newChangeLogEntry.cid,
            'unknown': updateResults.newChangeLogEntry.getUnknown(),
          });
        }
        if (updateResults.newChangeLogEntry.operation != 'error' &&
            updateResults.newChangeLogEntry.getOperationInfo().isNotEmpty) {
          resultsSummary['info'].add({
            'cid': updateResults.newChangeLogEntry.cid,
            'operation': updateResults.newChangeLogEntry.operation,
            'info': updateResults.newChangeLogEntry.getOperationInfo(),
          });
        }
        if (request.url.queryParameters['changeUpdates'] == 'true') {
          resultsSummary['changeUpdates'].add({
            'cid': updateResults.newChangeLogEntry.cid,
            'updates': result.changeUpdates,
          });
        }
        if (request.url.queryParameters['stateUpdates'] == 'true') {
          // Only add state updates if explicitly requested
          resultsSummary['stateUpdates'].add({
            'cid': updateResults.newChangeLogEntry.cid,
            'state': result.stateUpdates,
          });
        }
      }

      print(
        'Response: ${const JsonEncoder.withIndent('  ').convert(resultsSummary)}',
      );

      return Response.ok(
        jsonEncode(resultsSummary),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e, stackTrace) {
      print('Error creating changes: $e');
      print('Stack trace: $stackTrace');
      return _errorResponse(
        'Failed to create changes: ${e.toString()}',
        500,
        stackTrace,
      );
    }
  }

  /// Get statistics
  Future<Response> _handleGetStats(Request request) async {
    try {
      final projectId = _extractProjectId(request);
      if (projectId == null || projectId.isEmpty) {
        return _errorResponse('Project ID is required', 400);
      }

      final changeStats = await storage.getChangeStats(projectId);
      final entityTypeStats = await storage.getEntityTypeStats(projectId);

      return Response.ok(
        jsonEncode({
          'projectId': projectId,
          'changeStats': changeStats,
          'entityTypeStats': entityTypeStats,
          'timestamp': DateTime.now().toIso8601String(),
          'storageType': storageTypeDescription,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e) {
      return _errorResponse('Failed to fetch statistics: $e', 500);
    }
  }

  /// Get global statistics across all projects
  Future<Response> _handleGetGlobalStats(Request request) async {
    try {
      // Get all projects first
      final projects = await storage.getAllProjects();

      // Aggregate stats across all projects
      int totalChanges = 0;
      final Map<String, int> entityTypeTotals = {};

      for (final projectId in projects) {
        try {
          final changeStats = await storage.getChangeStats(projectId);
          final entityTypeStats = await storage.getEntityTypeStats(projectId);

          totalChanges += (changeStats['total'] as int? ?? 0);

          // Aggregate entity type stats
          for (final entry in entityTypeStats.entries) {
            final entityType = entry.key;
            final count = entry.value as int? ?? 0;
            entityTypeTotals[entityType] =
                (entityTypeTotals[entityType] ?? 0) + count;
          }
        } catch (e) {
          // Skip individual project errors but continue aggregating
          print('Warning: Failed to get stats for project $projectId: $e');
        }
      }

      return Response.ok(
        jsonEncode({
          'changeStats': {
            'total': totalChanges,
            'projectCount': projects.length,
          },
          'entityTypeStats': entityTypeTotals,
          'timestamp': DateTime.now().toIso8601String(),
          'storageType': storageTypeDescription,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to fetch global statistics: $e', 500);
    }
  }

  /// Get list of supported entity types for a domainType
  Future<Response> _handleGetEntities(Request request) async {
    try {
      final domainType = request.params['domainType'];
      if (domainType == null || domainType.isEmpty) {
        return _errorResponse('Domain type is required', 400);
      }

      // Get supported entity types for this domainType
      late final List<String> entityTypes;
      if (domainType == 'project') {
        entityTypes = EntityType.allValues;
      } else {
        entityTypes = [];
        return _errorResponse('Unsupported domain type: $domainType', 400);
      }

      return Response.ok(
        jsonEncode({'domainType': domainType, 'entityTypes': entityTypes}),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e) {
      return _errorResponse('Failed to fetch entity types: $e', 500);
    }
  }

  /// Get entity state with pagination and optional metadata
  Future<Response> _handleGetEntityState(Request request) async {
    try {
      final projectId = _extractProjectId(request);
      if (projectId == null || projectId.isEmpty) {
        return _errorResponse('Project ID is required', 400);
      }

      final entityType = request.params['entityType'];
      if (entityType == null || entityType.isEmpty) {
        return _errorResponse('Entity type is required', 400);
      }

      // URL decode the entity type to handle special characters
      final decodedEntityType = Uri.decodeComponent(entityType);

      // Parse query parameters
      final queryParams = request.url.queryParameters;
      final cursor = queryParams['cursor'];
      final limitStr = queryParams['limit'];
      final fieldMetadataStr = queryParams['field_metadata'];

      // Parse limit parameter
      int limit = 100; // Default limit
      if (limitStr != null && limitStr.isNotEmpty) {
        try {
          limit = int.parse(limitStr);
          if (limit <= 0 || limit > 1000) {
            return _errorResponse('Limit must be between 1 and 1000', 400);
          }
        } catch (e) {
          return _errorResponse(
            'Invalid limit format: must be a positive integer',
            400,
          );
        }
      }

      // Parse field_metadata parameter
      final includeFieldMetadata = fieldMetadataStr?.toLowerCase() == 'true';

      // Get entity state data
      final stateData = await storage.getEntityStates(
        projectId: projectId,
        entityType: decodedEntityType,
        cursor: cursor,
        limit: limit,
        includeMetadata: includeFieldMetadata,
      );

      return Response.ok(
        jsonEncode({
          'projectId': projectId,
          'entityType': decodedEntityType,
          'items': stateData['items'],
          'cursor': stateData['nextCursor'],
          'hasMore': stateData['hasMore'],
          'fieldMetadata': includeFieldMetadata,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e) {
      return _errorResponse('Failed to fetch entity state: $e', 500);
    }
  }

  /// 404 handler
  Future<Response> _handleNotFound(Request request) async {
    return Response.notFound(
      jsonEncode({'error': 'Endpoint not found', 'path': request.url.path}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Handle OPTIONS requests for CORS
  Future<Response> _handleOptions(Request request) async {
    return Response.ok(
      '',
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        'Access-Control-Max-Age': '86400',
      },
    );
  }

  /// Helper method for error responses
  Response _errorResponse(
    String message,
    int statusCode, [
    StackTrace? stackTrace,
  ]) {
    // Log error to console
    print('[$serverName] Error ($statusCode): $message');
    if (stackTrace != null) {
      print('[$serverName] Stack trace: $stackTrace');
    }

    final errorBody = <String, dynamic>{
      'error': message,
      'timestamp': DateTime.now().toIso8601String(),
      'server': serverName,
    };

    // Include stack trace information if provided
    if (stackTrace != null) {
      errorBody['stackTrace'] = stackTrace.toString();
    }

    return Response(
      statusCode,
      body: jsonEncode(errorBody),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Stop the server
  Future<void> stop() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      print('[$serverName] Server stopped');
    }

    await storage.close();
  }

  /// Check if server is running
  bool get isRunning => _server != null;

  /// Get server address
  String? get address =>
      _server != null ? 'http://localhost:${_server!.port}' : null;
}

/// Custom logging middleware
Middleware _customLogRequests({required String serverName, required int port}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);
      final timestamp = DateTime.now().toIso8601String();
      final paddedName = serverName.padLeft(12);
      print(
        '$timestamp  $paddedName:$port  ${request.method}  [${response.statusCode}]  ${request.requestedUri.path}',
      );
      return response;
    };
  };
}
