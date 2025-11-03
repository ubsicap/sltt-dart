import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sltt_core/sltt_core.dart';

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

  /// Extract and URL decode `domainId` from request parameters.
  ///
  /// For backwards compatibility this will also accept the legacy
  /// `projectId` path parameter (used by routes like `/api/projects/<projectId>/...`).
  /// Callers should prefer using `domainId` in new routes; this compatibility
  /// behavior is intentionally localized here so we can remove it later once
  /// all callers and tests move to the new domain-scoped routes.
  String? _extractDomainId(Request request) {
    // Prefer the canonical `domainId` path parameter.
    final domainIdRaw = request.params['domainId'];
    if (domainIdRaw != null && domainIdRaw.isNotEmpty) {
      return Uri.decodeComponent(domainIdRaw);
    }

    // Fall back to the legacy `projectId` path parameter if present. This
    // keeps existing tests and clients working until the codebase is fully
    // migrated to domain-scoped routes.
    final projectIdRaw = request.params['projectId'];
    if (projectIdRaw != null && projectIdRaw.isNotEmpty) {
      return Uri.decodeComponent(projectIdRaw);
    }

    return null;
  }

  /// Validate `domainCollection` path parameter and map it to a domain type.
  ///
  /// Returns a map with keys `{ 'error': String? , 'domainType': String? }`.
  /// - On success: `{ 'error': null, 'domainType': <domainType> }`.
  /// - On failure: `{ 'error': '<message>', 'domainType': null }`.
  Map<String, dynamic> _resolveDomainCollection(Request request) {
    final domainCollection = request.params['domainCollection'];
    if (domainCollection == null || domainCollection.isEmpty) {
      return {'error': 'Domain collection is required', 'domainType': null};
    }

    final domainType = getDomainByCollection(domainCollection);
    if (domainType == null) {
      return {
        'error': 'Unknown domain collection: $domainCollection',
        'domainType': null,
      };
    }

    return {'error': null, 'domainType': domainType};
  }

  /// Additional server-specific endpoints (override if needed)
  void addCustomRoutes(Router router) {
    // Default: no custom routes
  }

  /// Validate `entityCollection` path parameter and map it to an entity type.
  ///
  /// Returns a map with keys `{ 'error': String? , 'entityType': String? }`.
  /// - On success: `{ 'error': null, 'entityType': <entityType> }`.
  /// - On failure: `{ 'error': '<message>', 'entityType': null }`.
  Map<String, dynamic> _resolveEntityCollection(Request request) {
    final entityCollection = request.params['entityCollection'];
    if (entityCollection == null || entityCollection.isEmpty) {
      return {'error': 'Entity collection is required', 'entityType': null};
    }

    // Use the central mapper from entity_type.dart which provides
    // `getEntityByCollection` to convert a collection name (e.g. 'projects')
    // to the canonical entity type string (e.g. 'project').
    final entityType = getEntityByCollection(entityCollection);
    if (entityType == null) {
      return {
        'error': 'Unknown entity collection: $entityCollection',
        'entityType': null,
      };
    }

    return {'error': null, 'entityType': entityType};
  }

  /// Start the server on the specified port
  Future<StartResponse> start({required int port}) async {
    if (_server != null) {
      final storageId = await storage.getStorageId();
      final storageType = storage.getStorageType();
      SlttLogger.logger.info('[$serverName] Server is already running');
      return StartResponse(storageId: storageId, storageType: storageType);
    }

    // Initialize the storage service
    await storage.initialize();
    final storageId = await storage.ensureStorageId();
    final storageType = storage.getStorageType();

    final router = buildRouter();

    // Add CORS and logging middleware
    final handler = const Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(_customLogRequests(serverName: serverName, port: port))
        .addHandler(router.call);

    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    SlttLogger.logger.info(
      '[$serverName] Server started on http://localhost:$port (storageId="$storageId", storageType="$storageType")',
    );
    return StartResponse(storageId: storageId, storageType: storageType);
  }

  /// Build the router with standard endpoints
  @protected
  Router buildRouter() {
    final router = Router();

    // Standard endpoints (same for all servers)
    router.get('/health', _handleHealth);
    router.get('/api/help', _handleApiDocs);
    // global stats for debugging and tests only
    router.get(
      '/api/stats',
      _handleGetGlobalStats,
    ); // Global stats across all projects
    // TODO: /api/changes/sync vs. /api/changes/save
    router.post('/api/changes', _handleCreateChanges);
    router.get('/api/domains', _handleGetDomainsAndTheirCollections);
    router.get('/api/domains/<domainType>/entities', _handleGetEntities);
    router.get('/api/<domainCollection>', _handleGetDomainIds);

    /// Generalized domain-scoped endpoints
    /// Example: /api/changes/projects/{projectId}
    // New routes: move changes under /api/changes/<domainCollection>/<domainId>
    router.get('/api/changes/<domainCollection>/<domainId>', _handleGetChanges);
    router.get(
      '/api/changes/<domainCollection>/<domainId>/<cid>',
      _handleGetChange,
    );
    // Move stats under /api/stats/<domainCollection>/<domainId>
    router.get('/api/stats/<domainCollection>/<domainId>', _handleGetStats);
    router.get(
      '/api/state/<domainCollection>/<domainId>/<entityCollection>',
      _handleGetEntityStates,
    );

    router.get(
      '/api/state/<domainCollection>/<domainId>/<entityCollection>/<entityId>',
      _handleGetEntityState,
    );
    router.post('/api/storage/__test/state', _handleStorageTestStoreState);
    router.post('/api/storage/__test/change', _handleStorageTestStoreChange);
    router.delete(
      '/api/storage/__test/reset/<domainCollection>/<domainId>',
      _handleStorageTestReset,
    );

    router.delete(
      '/api/admin/storage/reset/<domainCollection>/<domainId>',
      _handleAdminStorageDomainReset,
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
        'timestamp': DateTime.now().toUtc().toIso8601String(),
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
        'dataJson': jsonEncode({
          'type': 'object',
          'description': 'Change data payload',
        }),
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
          'description':
              'Cursor value for pagination — clients can use this as a bookmark/reference for the current position (cursor is typically returned when paging)',
        },
        'hasMore': {
          'type': 'boolean',
          'description':
              'Whether more results are available beyond this response (use cursor to request the next page)',
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
                'items': {'type': 'object'},
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
            'type': 'object',
            'required': [
              'changes',
              'srcStorageType',
              'srcStorageId',
              'storageMode',
            ],
            'properties': {
              'changes': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'required': ['domainId', 'entityType', 'entityId'],
                  'properties': {
                    'domainId': {'type': 'string'},
                    'entityType': {'type': 'string'},
                    'entityId': {'type': 'string'},
                    'operation': {'type': 'string', 'default': 'create'},
                    'dataJson': {
                      'type': 'string',
                      'description': 'Change data payload (JSON string)',
                    },
                    'changeAt': {'type': 'string', 'format': 'ISO8601'},
                    'cid': {'type': 'string'},
                  },
                },
              },
              'srcStorageType': {
                'required': true,
                'type': 'string',
                'description':
                    "Source client storage type; must be 'local' or 'cloud'",
              },
              'srcStorageId': {
                'required': true,
                'type': 'string',
                'description': 'Source client storageId (required, non-empty)',
              },
              'storageMode': {
                'type': 'string',
                'description':
                    'Storage mode: "save" for new changes (empty storageId), "sync" for transferring stored changes (non-empty storageId)',
              },
              'includeChangeUpdates': {
                'type': 'boolean',
                'description':
                    'If true, include per-change `changeUpdates` details in the response',
                'default': false,
              },
              'includeStateUpdates': {
                'type': 'boolean',
                'description':
                    'If true, include per-change `stateUpdates` details in the response',
                'default': false,
              },
            },
          },
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
                    'Per-change computed changeUpdate objects (included when includeChangeUpdates=true)',
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
                    'Per-change computed state update objects (included when includeStateUpdates=true)',
              },
              'timestamp': {
                'type': 'string',
                'format': 'ISO8601',
                'description': 'When the response was generated',
              },
            },
          },
        },
        // Generalized domain-scoped endpoints
        {
          'method': 'GET',
          'path': '/api/{domainCollection}',
          'description':
              'List domain IDs for the given collection (e.g., projects)',
          'response': {
            'type': 'object',
            'properties': {
              'items': {
                'type': 'array',
                'items': {'type': 'string'},
              },
              'count': {'type': 'integer'},
              'timestamp': {'type': 'string', 'format': 'ISO8601'},
            },
          },
        },
        {
          'method': 'GET',
          'path': '/api/changes/{domainCollection}/{domainId}',
          'description': 'Get changes for a domain with optional pagination',
          'parameters': [
            {'name': 'domainCollection', 'type': 'string', 'required': true},
            {'name': 'domainId', 'type': 'string', 'required': true},
            {
              'name': 'stateChanged',
              'type': 'boolean',
              'required': false,
              'description':
                  'Filter by whether the change resulted in a state update (true/false). If omitted, returns all changes.',
            },
            {
              'name': 'cursor',
              'type': 'integer',
              'required': false,
              'description':
                  'Cursor (sequence number) to start from (exclusive). Clients can treat the returned cursor as a bookmark for the current position.',
            },
            {'name': 'limit', 'type': 'integer', 'required': false},
          ],
          'response': {
            'type': 'object',
            'properties': {
              'changes': {'type': 'array', 'items': changeObjectSchema},
              'count': {'type': 'integer'},
              'cursor': {
                'type': 'integer',
                'description':
                    'Cursor for the response; clients can use this value as a bookmark to request the next page.',
              },
              'hasMore': {
                'type': 'boolean',
                'description':
                    'True when more results are available beyond this response.',
              },
              'timestamp': {'type': 'string', 'format': 'ISO8601'},
            },
          },
        },
        {
          'method': 'GET',
          'path': '/api/changes/{domainCollection}/{domainId}/{cid}',
          'description': 'Get specific change by change ID for a domain',
          'parameters': [
            {'name': 'domainCollection', 'type': 'string', 'required': true},
            {'name': 'domainId', 'type': 'string', 'required': true},
            {'name': 'cid', 'type': 'string', 'required': true},
          ],
          'response': changeObjectSchema,
        },
        {
          'method': 'GET',
          'path': '/api/state/{domainCollection}/{domainId}/{entityCollection}',
          'description':
              'Get paginated entity states for a domain and entity type',
          'parameters': [
            {'name': 'domainCollection', 'type': 'string', 'required': true},
            {'name': 'domainId', 'type': 'string', 'required': true},
            {'name': 'entityType', 'type': 'string', 'required': true},
            {'name': 'cursor', 'type': 'string', 'required': false},
            {'name': 'limit', 'type': 'integer', 'required': false},
            {
              'name': 'parentId',
              'type': 'string',
              'required': false,
              'description': 'Filter entities by parent ID',
            },
            {
              'name': 'parentProp',
              'type': 'string',
              'required': false,
              'description':
                  'Filter entities by an arbitrary parent property extracted from change.dataJson',
            },
          ],
          'response': {
            'type': 'object',
            'properties': {
              'items': {
                'type': 'array',
                'items': {'type': 'object'},
              },
              'hasMore': {'type': 'boolean'},
              'cursor': {'type': 'string'},
            },
          },
        },
        {
          'method': 'GET',
          'path': '/api/stats/{domainCollection}/{domainId}/',
          'description':
              'Get statistics about changes and entity types for a domain',
          'parameters': [
            {'name': 'domainCollection', 'type': 'string', 'required': true},
            {'name': 'domainId', 'type': 'string', 'required': true},
          ],
          'response': {
            'type': 'object',
            'properties': {
              'changeStats': {'type': 'object'},
              'entityTypeStats': {'type': 'object'},
              'timestamp': {'type': 'string', 'format': 'ISO8601'},
              'storageType': {'type': 'string'},
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
                  'domainIdCount': {
                    'type': 'integer',
                    'description': 'Number of domain IDs with changes',
                  },
                  'creates': {
                    'type': 'integer',
                    'description':
                        'Total create operations across all projects',
                  },
                  'updates': {
                    'type': 'integer',
                    'description':
                        'Total update operations across all projects',
                  },
                  'deletes': {
                    'type': 'integer',
                    'description':
                        'Total delete operations across all projects',
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
          'path':
              '/api/state/{domainCollection}/{domainId}/{entityCollection}/{entityId}',
          'description': 'Get specific entity state by entity ID',
          'parameters': [
            {'name': 'domainCollection', 'type': 'string', 'required': true},
            {'name': 'domainId', 'type': 'string', 'required': true},
            {'name': 'entityCollection', 'type': 'string', 'required': true},
            {'name': 'entityId', 'type': 'string', 'required': true},
          ],
          'response': {
            'type': 'object',
            'properties': {
              'projectId': {
                'type': 'string',
                'description': 'The domain/project identifier',
              },
              'entityType': {
                'type': 'string',
                'description': 'The entity type',
              },
              'entityId': {
                'type': 'string',
                'description': 'The entity identifier',
              },
              'state': {
                'type': 'object',
                'description': 'The current entity state data',
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
                        'type': 'object',
                        'additionalProperties': {'type': 'string'},
                        'minProperties': 1,
                        'maxProperties': 1,
                      },
                      'description':
                          'Array of single-key mappings e.g. [{ "project": "projects" }]',
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
          'method': 'POST',
          'path': '/api/storage/__test/state',
          'description':
              'Test endpoint: Store entity state directly without updating change log or sync states',
          'requestBody': {
            'type': 'object',
            'required': [
              'entityId',
              'entityType',
              'domainType',
              'change_domainId',
            ],
            'properties': {
              'entityId': {
                'type': 'string',
                'description': 'Entity identifier',
              },
              'entityType': {'type': 'string', 'description': 'Type of entity'},
              'domainType': {
                'type': 'string',
                'description': 'Domain type (e.g., "project")',
              },
              'change_domainId': {
                'type': 'string',
                'description':
                    'Domain ID (must start with "__test" for safety)',
              },
              '... other entity state fields': {
                'description':
                    'All other fields from the entity state can be included',
              },
            },
          },
          'response': {
            'type': 'object',
            'properties': {
              'message': {'type': 'string', 'description': 'Success message'},
              'entityState': {
                'type': 'object',
                'description': 'The stored entity state',
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
          'method': 'POST',
          'path': '/api/storage/__test/change',
          'description':
              'Test endpoint: Store change log entry directly without side effects',
          'requestBody': {
            'type': 'object',
            'required': [
              'cid',
              'domainId',
              'domainType',
              'entityId',
              'entityType',
            ],
            'properties': {
              'cid': {'type': 'string', 'description': 'Change ID'},
              'domainId': {
                'type': 'string',
                'description':
                    'Domain ID (must start with "__test" for safety)',
              },
              'domainType': {
                'type': 'string',
                'description': 'Domain type (e.g., "project")',
              },
              'entityId': {
                'type': 'string',
                'description': 'Entity identifier',
              },
              'entityType': {'type': 'string', 'description': 'Type of entity'},
              '... other change log fields': {
                'description':
                    'All other fields from the change log entry can be included',
              },
            },
          },
          'response': {
            'type': 'object',
            'properties': {
              'message': {'type': 'string', 'description': 'Success message'},
              'change': {
                'type': 'object',
                'description': 'The stored change log entry',
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
          'method': 'DELETE',
          'path': '/api/storage/__test/reset/{domainCollection}/{domainId}',
          'description':
              'Test endpoint: Reset/delete all storage data for a specific test domain',
          'parameters': [
            {
              'name': 'domainCollection',
              'type': 'string',
              'required': true,
              'description':
                  'Domain collection type (e.g., "projects", "teams")',
            },
            {
              'name': 'domainId',
              'type': 'string',
              'required': true,
              'description':
                  'Domain ID to reset (must start with "__test" for safety)',
            },
          ],
          'response': {
            'type': 'object',
            'properties': {
              'message': {'type': 'string', 'description': 'Success message'},
              'domainId': {
                'type': 'string',
                'description': 'The domain ID that was reset',
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
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    return Response.ok(
      jsonEncode(docs),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// List domain IDs for a collection (currently aliases to projects list)
  Future<Response> _handleGetDomainIds(Request request) async {
    try {
      final resolved = _resolveDomainCollection(request);
      if (resolved['error'] != null) {
        return _errorResponse(resolved['error'] as String, 400);
      }
      final domainType = resolved['domainType'] as String;

      // For now, return domain ids for the requested domainType
      final items = await storage.getAllDomainIds(domainType: domainType);
      return Response.ok(
        jsonEncode({
          'items': items,
          'count': items.length,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      SlttLogger.logger.severe('Error getting domain IDs: $e', e, stackTrace);
      return _errorResponse(
        'Failed to get domain IDs: ${e.toString()}',
        500,
        stackTrace,
      );
    }
  }

  Future<Response> _handleGetDomainsAndTheirCollections(Request request) async {
    try {
      final domainTypes = getAllDomainTypes();
      final collections = domainTypes
          .map((d) => getCollectionByDomain(d))
          .whereType<String>()
          .toList();

      final response = {'domains': domainTypes, 'collections': collections};

      return Response.ok(
        jsonEncode(response),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e, stackTrace) {
      SlttLogger.logger.severe('Error getting domains: $e', e, stackTrace);
      return _errorResponse(
        'Failed to get domains: ${e.toString()}',
        500,
        stackTrace,
      );
    }
  }

  /// Get changes with optional pagination
  Future<Response> _handleGetChanges(Request request) async {
    try {
      final resolved = _resolveDomainCollection(request);
      if (resolved['error'] != null) {
        return _errorResponse(resolved['error'] as String, 400);
      }
      final domainType = resolved['domainType'] as String;
      final domainId = _extractDomainId(request);
      if (domainId == null || domainId.isEmpty) {
        return _errorResponse('Domain ID is required', 400);
      }

      final stateChangedParam = request.url.queryParameters['stateChanged'];
      final cursorParam = request.url.queryParameters['cursor'];
      final limitParam = request.url.queryParameters['limit'];

      bool? stateChanged;
      if (stateChangedParam != null) {
        if (stateChangedParam.toLowerCase() == 'true') {
          stateChanged = true;
        } else if (stateChangedParam.toLowerCase() == 'false') {
          stateChanged = false;
        } else {
          return _errorResponse(
            'Invalid stateChanged value: must be true or false',
            400,
          );
        }
      }

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

      final rawChanges = await storage.getChangesWithCursor(
        domainType: domainType,
        domainId: domainId,
        cursor: cursor,
        limit: limit,
      );
      final changes = stateChanged != null
          ? rawChanges.where((c) => c.stateChanged == stateChanged).toList()
          : rawChanges;

      final storageId = await storage.getStorageId();
      final storageType = storage.getStorageType();
      final responseData = <String, dynamic>{
        'storageId': storageId,
        'storageType': storageType,
        'changes': changes.map((c) => c.toJson()).toList(),
        'count': changes.length,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };

      responseData['hasMore'] = false;
      // Add cursor to response if there are more changes available
      if (rawChanges.isNotEmpty &&
          (limit == null || rawChanges.length == limit)) {
        final lastChangeId = rawChanges.last.seq;
        final moreChanges = await storage.getChangesWithCursor(
          domainType: domainType,
          domainId: domainId,
          cursor: lastChangeId,
          limit: 1,
        );

        if (moreChanges.isNotEmpty) {
          responseData['hasMore'] = true;
        }
        responseData['cursor'] = lastChangeId;
      }

      return Response.ok(
        jsonEncode(responseData),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e, st) {
      SlttLogger.logger.severe('Failed to fetch changes: $e', e, st);
      return _errorResponse('Failed to fetch changes: $e', 500, st);
    }
  }

  /// Get specific change by sequence number
  Future<Response> _handleGetChange(Request request) async {
    try {
      final resolved = _resolveDomainCollection(request);
      if (resolved['error'] != null) {
        return _errorResponse(resolved['error'] as String, 400);
      }

      final domainType = resolved['domainType'] as String;

      final domainId = _extractDomainId(request);
      if (domainId == null || domainId.isEmpty) {
        return _errorResponse('Domain ID is required', 400);
      }

      final cid = request.params['cid'];
      if (cid == null || cid.isEmpty) {
        return _errorResponse('Change ID is required', 400);
      }

      final change = await storage.getChange(
        domainType: domainType,
        domainId: domainId,
        cid: cid,
      );
      if (change == null) {
        return _errorResponse('Change not found', 404);
      }

      final changeJson = change.toJson();
      SlttLogger.logger.fine(
        '_handleGetChange Response: ${jsonEncode(changeJson)}',
      );
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
      final bodyJson = await request.readAsString();

      // Parse JSON body
      late final dynamic body;
      try {
        body = jsonDecode(bodyJson);
      } on FormatException catch (e) {
        return _errorResponse('Invalid JSON format: ${e.message}', 400);
      }

      late final List<Map<String, dynamic>> changes;
      String srcStorageType;
      String srcStorageId;
      String storageMode;
      bool includeChangeUpdates = false;
      bool includeStateUpdates = false;

      if (body is Map<String, dynamic>) {
        final changesField = body['changes'];
        if (changesField is! List) {
          return _errorResponse('`changes` must be an array', 400);
        }
        try {
          changes = List<Map<String, dynamic>>.from(changesField);
        } on TypeError {
          return _errorResponse(
            'Invalid change objects in `changes` array',
            400,
          );
        }

        srcStorageType = (body['srcStorageType'] as String?)?.trim() ?? '';
        srcStorageId = (body['srcStorageId'] as String?)?.trim() ?? '';
        storageMode = (body['storageMode'] as String?)?.trim() ?? '';
        includeChangeUpdates = (body['includeChangeUpdates'] as bool?) ?? false;
        includeStateUpdates = (body['includeStateUpdates'] as bool?) ?? false;
      } else {
        return _errorResponse(
          'Request body must be an object with `changes`',
          400,
        );
      }

      if (changes.isEmpty) {
        return _errorResponse('No changes provided', 400);
      }

      // Validate srcStorageType/srcStorageId (must be 'local' or 'cloud' and non-empty)
      if (!(srcStorageType == 'local' || srcStorageType == 'cloud')) {
        return _errorResponse('srcStorageType must be "local" or "cloud"', 400);
      }

      if (srcStorageId.isEmpty) {
        return _errorResponse(
          'srcStorageId is required and must be non-empty',
          400,
        );
      }

      // Validate storageMode (must be 'save' or 'sync')
      if (!(storageMode == 'save' || storageMode == 'sync')) {
        return _errorResponse('storageMode must be "save" or "sync"', 400);
      }

      // Use the change processing service
      final result = await ChangeProcessingService.storeChanges(
        storageMode: storageMode,
        returnErrorIfInResultsSummary: storageMode == 'save',
        changes: changes,
        srcStorageType: srcStorageType,
        srcStorageId: srcStorageId,
        storage: storage,
        includeChangeUpdates: includeChangeUpdates,
        includeStateUpdates: includeStateUpdates,
      );

      if (result.isError) {
        return _errorResponse(
          result.errorMessage!,
          result.errorCode!,
          result.stackTrace,
        );
      }

      if (storageMode == 'save' &&
          result.resultsSummary != null &&
          result.resultsSummary!.errors.isNotEmpty) {
        // If in 'save' mode and there were errors, return 500 Internal Server Error
        return _errorResponse(
          'Errors reported in resultsSummary',
          result.errorCode ?? 500,
          null,
          result.resultsSummary,
        );
      }

      SlttLogger.logger.fine(
        'Response: ${const JsonEncoder.withIndent('  ').convert(result.resultsSummary)}',
      );

      return Response.ok(
        jsonEncode(result.resultsSummary),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e, stackTrace) {
      SlttLogger.logger.severe('Error creating changes: $e', e, stackTrace);
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
      final resolved = _resolveDomainCollection(request);
      if (resolved['error'] != null) {
        return _errorResponse(resolved['error'] as String, 400);
      }
      final domainType = resolved['domainType'] as String;

      final domainId = _extractDomainId(request);
      if (domainId == null || domainId.isEmpty) {
        return _errorResponse('Domain ID is required', 400);
      }

      // Debugging: log parameters so tests can diagnose unexpected 404s
      SlttLogger.logger.fine(
        '[BaseRestApiServer] _handleGetStats domainCollection=${request.params["domainCollection"]} domainType=$domainType domainId=$domainId',
      );

      final changeStats = await storage.getChangeStats(
        domainType: domainType,
        domainId: domainId,
      );
      SlttLogger.logger.fine(
        '[BaseRestApiServer] storage.getChangeStats returned: ${changeStats.totals}',
      );

      final entityTypeStats = await storage.getStateStats(
        domainType: domainType,
        domainId: domainId,
      );
      SlttLogger.logger.fine(
        '[BaseRestApiServer] storage.getStateStats returned: $entityTypeStats',
      );

      // Typed results: use the EntityTypeStats API and serialize to JSON
      final changeStatsJson = changeStats.totals.toJson();
      final entityTypeStatsJson = entityTypeStats.toJson();

      return Response.ok(
        jsonEncode({
          'projectId': domainId,
          'changeStats': changeStatsJson,
          'entityTypeStats': entityTypeStatsJson,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          'storageType': storageTypeDescription,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e, st) {
      SlttLogger.logger.severe('Failed to fetch statistics: $e', e, st);
      return _errorResponse('Failed to fetch statistics: $e', 500, st);
    }
  }

  /// Get global statistics across all projects
  /// For debugging and testing only
  Future<Response> _handleGetGlobalStats(Request request) async {
    try {
      final resolved = _resolveDomainCollection(request);
      if (resolved['error'] != null) {
        return _errorResponse(resolved['error'] as String, 400);
      }
      final domainType = resolved['domainType'] as String;
      // Get all projects first
      final domainIds = await storage.getAllDomainIds(domainType: domainType);

      // Aggregate stats across all projects
      int totalChanges = 0;
      int totalCreates = 0;
      int totalUpdates = 0;
      int totalDeletes = 0;
      final Map<String, int> entityTypeTotals = {};

      for (final domainId in domainIds) {
        try {
          final changeStats = await storage.getChangeStats(
            domainType: domainType,
            domainId: domainId,
          );
          final entityTypeStats = await storage.getStateStats(
            domainType: domainType,
            domainId: domainId,
          );

          // Typed EntityTypeStats: read totals and entityTypes directly
          totalChanges += changeStats.totals.total;
          totalCreates += changeStats.totals.creates;
          totalUpdates += changeStats.totals.updates;
          totalDeletes += changeStats.totals.deletes;

          for (final entry in entityTypeStats.entityTypes.entries) {
            final entityType = entry.key;
            final count = entry.value.total;
            entityTypeTotals[entityType] =
                (entityTypeTotals[entityType] ?? 0) + count;
          }
        } catch (e) {
          // Skip individual project errors but continue aggregating
          SlttLogger.logger.warning(
            'Warning: Failed to get stats for project $domainId: $e',
          );
        }
      }

      return Response.ok(
        jsonEncode({
          'changeStats': {
            'total': totalChanges,
            'domainIdCount': domainIds.length,
            'creates': totalCreates,
            'updates': totalUpdates,
            'deletes': totalDeletes,
          },
          'entityTypeStats': entityTypeTotals,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          'storageType': storageTypeDescription,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, st) {
      SlttLogger.logger.severe('Failed to fetch global statistics: $e', e, st);
      return _errorResponse('Failed to fetch global statistics: $e', 500, st);
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

  /// Get entity state with pagination
  Future<Response> _handleGetEntityStates(Request request) async {
    try {
      final resolved = _resolveDomainCollection(request);
      if (resolved['error'] != null) {
        return _errorResponse(resolved['error'] as String, 400);
      }
      final domainType = resolved['domainType'] as String;
      final projectId = _extractDomainId(request);
      if (projectId == null || projectId.isEmpty) {
        return _errorResponse('Domain ID is required', 400);
      }

      // Resolve entityCollection -> entityType
      final resolvedEntity = _resolveEntityCollection(request);
      if (resolvedEntity['error'] != null) {
        return _errorResponse(resolvedEntity['error'] as String, 400);
      }
      final decodedEntityType = resolvedEntity['entityType'] as String;

      // Parse query parameters
      final queryParams = request.url.queryParameters;
      final cursor = queryParams['cursor'];
      final limitStr = queryParams['limit'];
      final parentId = queryParams['parentId'];
      final parentProp = queryParams['parentProp'];

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

      // Get entity state data
      final stateData = await storage.getEntityStates(
        domainType: domainType,
        domainId: projectId,
        entityType: decodedEntityType,
        cursor: cursor,
        limit: limit,
        parentId: parentId,
        parentProp: parentProp,
      );

      return Response.ok(
        jsonEncode({
          'projectId': projectId,
          'entityType': decodedEntityType,
          'items': stateData['items'],
          'cursor': stateData['nextCursor'],
          'hasMore': stateData['hasMore'],
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e) {
      return _errorResponse('Failed to fetch entity state: $e', 500);
    }
  }

  /// Get entity state
  Future<Response> _handleGetEntityState(Request request) async {
    try {
      final resolved = _resolveDomainCollection(request);
      if (resolved['error'] != null) {
        return _errorResponse(resolved['error'] as String, 400);
      }
      final domainType = resolved['domainType'] as String;
      final projectId = _extractDomainId(request);
      if (projectId == null || projectId.isEmpty) {
        return _errorResponse('Domain ID is required', 400);
      }

      // Resolve entityCollection -> entityType (route uses <entityCollection>)
      final resolvedEntity = _resolveEntityCollection(request);
      if (resolvedEntity['error'] != null) {
        return _errorResponse(resolvedEntity['error'] as String, 400);
      }
      final entityType = resolvedEntity['entityType'] as String;

      final entityId = request.params['entityId'];
      if (entityId == null || entityId.isEmpty) {
        return _errorResponse('Entity ID is required', 400);
      }

      // Get entity state data
      final stateData = await storage.getEntityState(
        domainType: domainType,
        domainId: projectId,
        entityType: entityType,
        entityId: entityId,
      );

      return Response.ok(
        jsonEncode({
          'projectId': projectId,
          'entityType': entityType,
          'entityId': entityId,
          'state': stateData?.toJson(),
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e) {
      return _errorResponse('Failed to fetch entity state: $e', 500);
    }
  }

  /// Handle storage test reset
  /// route: '/api/storage/__test/reset/<domainCollection>/<domainId>'
  /// For __testXXX domainIds only
  Future<Response> _handleStorageTestReset(Request request) async {
    try {
      final resolved = _resolveDomainCollection(request);
      if (resolved['error'] != null) {
        return _errorResponse(resolved['error'] as String, 400);
      }
      final domainType = resolved['domainType'] as String;
      final domainId = _extractDomainId(request);
      if (domainId == null || domainId.isEmpty) {
        return _errorResponse('Domain ID is required', 400);
      }

      if (!domainId.startsWith('__test')) {
        return _errorResponse(
          'Test reset is only allowed for __testXXX domain IDs',
          403,
        );
      }

      await storage.testResetDomainStorage(
        domainType: domainType,
        domainId: domainId,
      );

      return Response.ok(
        jsonEncode({
          'message': 'All data for domainId "$domainId" has been deleted',
          'domainId': domainId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e, stackTrace) {
      SlttLogger.logger.severe('Error in test reset: $e', e, stackTrace);
      return _errorResponse(
        'Failed to perform test reset: ${e.toString()}',
        500,
        stackTrace,
      );
    }
  }

  Future<Response> _handleAdminStorageDomainReset(Request request) async {
    try {
      final resolved = _resolveDomainCollection(request);
      if (resolved['error'] != null) {
        return _errorResponse(resolved['error'] as String, 400);
      }
      final domainType = resolved['domainType'] as String;
      final domainId = _extractDomainId(request);
      if (domainId == null || domainId.isEmpty) {
        return _errorResponse('Domain ID is required', 400);
      }

      final now = DateTime.now();
      // check to see that confirm is a timestamp within the past minute
      final confirm = request.url.queryParameters['confirm'];
      if (confirm == null || confirm.isEmpty) {
        return _errorResponse(
          'Admin reset requires confirm=DateTime.now() query parameter',
          403,
        );
      }
      final confirmTime = DateTime.tryParse(confirm);
      if (confirmTime == null ||
          confirmTime.isBefore(now.subtract(const Duration(minutes: 1)))) {
        final offBy = confirmTime != null
            ? now.difference(confirmTime).inSeconds.abs().toString()
            : 'unknown';
        return _errorResponse(
          'Admin reset requires confirm=DateTime.now() query parameter (off by $offBy seconds)',
          403,
        );
      }

      await storage.testResetDomainStorage(
        domainType: domainType,
        domainId: domainId,
        isAdminReset: true,
      );

      return Response.ok(
        jsonEncode({
          'message': 'All data for domainId "$domainId" has been deleted',
          'domainId': domainId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e, stackTrace) {
      SlttLogger.logger.severe('Error in test reset: $e', e, stackTrace);
      return _errorResponse(
        'Failed to perform test reset: ${e.toString()}',
        500,
        stackTrace,
      );
    }
  }

  /// Test endpoint: Store entity state directly
  Future<Response> _handleStorageTestStoreState(Request request) async {
    try {
      final bodyString = await request.readAsString();
      if (bodyString.isEmpty) {
        return _errorResponse('Request body is required', 400);
      }

      final body = jsonDecode(bodyString) as Map<String, dynamic>;

      // Validate required fields
      final entityId = body['entityId'] as String?;
      final entityType = body['entityType'] as String?;
      final domainType = body['domainType'] as String?;
      final changeDomainId = body['change_domainId'] as String?;

      if (entityId == null || entityId.isEmpty) {
        return _errorResponse('entityId is required', 400);
      }
      if (entityType == null || entityType.isEmpty) {
        return _errorResponse('entityType is required', 400);
      }
      if (domainType == null || domainType.isEmpty) {
        return _errorResponse('domainType is required', 400);
      }
      if (changeDomainId == null || changeDomainId.isEmpty) {
        return _errorResponse('change_domainId is required', 400);
      }

      // Only allow test domain IDs for safety
      if (!changeDomainId.startsWith('__test')) {
        return _errorResponse(
          'Test store state is only allowed for __testXXX domain IDs',
          403,
        );
      }

      // Deserialize using the registered factory for the entity type
      final entityState = deserializeEntityStateSafely(body);

      // Store the state
      final storedState = await storage.testStoreState(
        entityState: entityState,
      );

      return Response.ok(
        jsonEncode({
          'message': 'Entity state stored successfully',
          'entityState': storedState.toJson(),
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } on FormatException catch (e) {
      return _errorResponse('Invalid JSON format: ${e.message}', 400);
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e, stackTrace) {
      SlttLogger.logger.severe('Error storing test state: $e', e, stackTrace);
      return _errorResponse(
        'Failed to store test state: ${e.toString()}',
        500,
        stackTrace,
      );
    }
  }

  /// Test endpoint: Store change log entry directly
  Future<Response> _handleStorageTestStoreChange(Request request) async {
    try {
      final bodyString = await request.readAsString();
      if (bodyString.isEmpty) {
        return _errorResponse('Request body is required', 400);
      }

      final body = jsonDecode(bodyString) as Map<String, dynamic>;

      // Validate required fields
      final cid = body['cid'] as String?;
      final domainId = body['domainId'] as String?;
      final domainType = body['domainType'] as String?;

      if (cid == null || cid.isEmpty) {
        return _errorResponse('cid is required', 400);
      }
      if (domainId == null || domainId.isEmpty) {
        return _errorResponse('domainId is required', 400);
      }
      if (domainType == null || domainType.isEmpty) {
        return _errorResponse('domainType is required', 400);
      }

      // Only allow test domain IDs for safety
      if (!domainId.startsWith('__test')) {
        return _errorResponse(
          'Test store change is only allowed for __testXXX domain IDs',
          403,
        );
      }

      // Store the change (storage will deserialize to appropriate type)
      final storedChange = await storage.testStoreChangeFromJson(
        changeJson: body,
      );

      return Response.ok(
        jsonEncode({
          'message': 'Change log entry stored successfully',
          'change': storedChange.toJson(),
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } on FormatException catch (e) {
      return _errorResponse('Invalid JSON format: ${e.message}', 400);
    } on ArgumentError catch (e) {
      return _errorResponse('$e', 400);
    } catch (e, stackTrace) {
      SlttLogger.logger.severe('Error storing test change: $e', e, stackTrace);
      return _errorResponse(
        'Failed to store test change: ${e.toString()}',
        500,
        stackTrace,
      );
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
    ChangeProcessingSummary? resultsSummary,
  ]) {
    // Log error using the project logger so tests/CI can control verbosity.
    if (statusCode >= 500) {
      SlttLogger.logger.severe(
        '[$serverName] Error ($statusCode): $message',
        null,
        stackTrace,
      );
    } else {
      SlttLogger.logger.warning('[$serverName] Error ($statusCode): $message');
    }

    final errorBody = <String, dynamic>{
      'error': message,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'server': serverName,
    };

    // Include stack trace information if provided
    if (stackTrace != null) {
      errorBody['stackTrace'] = stackTrace.toString();
    }
    if (resultsSummary != null) {
      errorBody['resultsSummary'] = resultsSummary.toJson();
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
      SlttLogger.logger.info('[$serverName] Server stopped');
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
      SlttLogger.logger.info(
        '$timestamp  $paddedName:$port  ${request.method}  [${response.statusCode}]  ${request.requestedUri.path}',
      );
      return response;
    };
  };
}

class StartResponse {
  final String storageId;
  final String storageType;

  StartResponse({required this.storageId, required this.storageType});
}
