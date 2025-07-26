import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import '../storage/shared_storage_service.dart';

enum StorageType { outsyncs, downsyncs, cloudStorage }

class EnhancedRestApiServer {
  final StorageType storageType;
  final String serverName;

  HttpServer? _server;
  bool _initialized = false;

  // Storage service based on type
  BaseStorageService? _storage;

  EnhancedRestApiServer(this.storageType, this.serverName);

  Future<void> start({required int port}) async {
    if (_server != null) {
      print('[$serverName] Server is already running');
      return;
    }

    // Initialize the appropriate storage service
    await _initializeStorage();

    final router = _buildRouter();

    // Add CORS and logging middleware
    final handler = Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(customLogRequests(serverName: serverName, port: port))
        .addHandler(router);

    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    print('[$serverName] Server started on http://localhost:$port');
  }

  Future<void> _initializeStorage() async {
    if (_initialized) return;

    switch (storageType) {
      case StorageType.outsyncs:
        _storage = OutsyncsStorageService.instance;
        break;
      case StorageType.downsyncs:
        _storage = DownsyncsStorageService.instance;
        break;
      case StorageType.cloudStorage:
        _storage = CloudStorageService.instance;
        break;
    }

    await _storage!.initialize();
    _initialized = true;
  }

  Router _buildRouter() {
    final router = Router();

    // Health check
    router.get('/health', _handleHealth);

    // API documentation
    router.get('/api/help', _handleApiDocs);

    // Change log endpoints - append-only operations
    router.post('/api/changes', _handleCreateChanges);
    router.get('/api/changes', _handleGetChanges);
    router.get('/api/changes/<seq>', _handleGetChange);

    // Statistics
    router.get('/api/stats', _handleGetStats);

    // 404 handler
    router.all('/<ignored|.*>', _handleNotFound);

    return router;
  }

  /// Health check endpoint.
  ///
  /// Returns server status information including timestamp, server name,
  /// and storage type. Used for monitoring and debugging purposes.
  Future<Response> _handleHealth(Request request) async {
    return Response.ok(
      jsonEncode({
        'status': 'healthy',
        'timestamp': DateTime.now().toIso8601String(),
        'server': serverName,
        'storageType': storageType.toString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// API documentation endpoint.
  ///
  /// Returns comprehensive API documentation including all available endpoints,
  /// parameters, and usage examples. Can be used programmatically by demos
  /// and testing tools.
  Future<Response> _handleApiDocs(Request request) async {
    final docs = getApiDocumentation();
    return Response.ok(
      jsonEncode(docs),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Get API documentation data structure.
  ///
  /// Returns a structured map containing all API documentation that can be
  /// used by demos, tests, or converted to different formats.
  Map<String, dynamic> getApiDocumentation() {
    return {
      'server': {
        'name': serverName,
        'storageType': storageType.toString(),
        'description': _getStorageDescription(),
      },
      'endpoints': [
        {
          'method': 'GET',
          'path': '/health',
          'description': 'Health check - returns server status',
          'parameters': [],
          'example': 'GET /health',
        },
        {
          'method': 'GET',
          'path': '/api/help',
          'description': 'API documentation - returns this documentation',
          'parameters': [],
          'example': 'GET /api/help',
        },
        {
          'method': 'GET',
          'path': '/api/changes',
          'description': 'Get all changes with optional pagination',
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
          'examples': [
            'GET /api/changes',
            'GET /api/changes?cursor=50',
            'GET /api/changes?limit=20',
            'GET /api/changes?cursor=100&limit=10',
          ],
        },
        {
          'method': 'GET',
          'path': '/api/changes/{seq}',
          'description': 'Get specific change by sequence number',
          'parameters': [
            {
              'name': 'seq',
              'type': 'integer',
              'required': true,
              'description': 'Change sequence number',
            },
          ],
          'example': 'GET /api/changes/123',
        },
        {
          'method': 'POST',
          'path': '/api/changes',
          'description': 'Create new changes (array format)',
          'parameters': [],
          'requestBody': {
            'type': 'array',
            'description': 'Array of change objects',
            'schema': {
              'entityType': 'string (required)',
              'operation': 'string (optional, defaults to "create")',
              'entityId': 'string (required)',
              'data': 'object (required)',
            },
          },
          'example': 'POST /api/changes',
          'exampleBody': [
            {
              'entityType': 'Document',
              'operation': 'create',
              'entityId': 'doc-123',
              'data': {'title': 'My Document', 'content': 'Content here'},
            }
          ],
        },
        {
          'method': 'GET',
          'path': '/api/stats',
          'description': 'Get statistics about changes and entity types',
          'parameters': [],
          'example': 'GET /api/stats',
        },
      ],
      'notes': [
        'PUT and DELETE endpoints have been removed - API follows append-only change log semantics',
        'The operation field represents logical operations on application entities, not change log operations',
        'All change log entries are created with auto-generated sequence numbers',
        'Cloud storage servers create new sequences and provide sequence mappings via seqMap',
      ],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get description for the current storage type.
  String _getStorageDescription() {
    switch (storageType) {
      case StorageType.outsyncs:
        return 'Manages local changes awaiting upload to cloud';
      case StorageType.downsyncs:
        return 'Manages changes received from cloud';
      case StorageType.cloudStorage:
        return 'Simulates cloud storage with append-only operations';
    }
  }

  /// Get formatted API documentation for console output.
  ///
  /// Returns a string suitable for printing to console, used by demos
  /// and command-line tools.
  String getFormattedApiDocumentation() {
    final docs = getApiDocumentation();
    final buffer = StringBuffer();

    buffer.writeln('📚 Available endpoints on ${docs['server']['name']}:');

    for (final endpoint in docs['endpoints']) {
      final method = endpoint['method'].toString().padRight(6);
      final path = endpoint['path'].toString().padRight(25);
      buffer.writeln('   $method $path - ${endpoint['description']}');
    }

    buffer.writeln('');
    buffer.writeln('   Notes:');
    for (final note in docs['notes']) {
      buffer.writeln('   • $note');
    }

    return buffer.toString();
  }

  /// Get all changes or filter by query parameters.
  ///
  /// Supports cursor-based pagination with optional query parameters:
  /// - `cursor`: Starting sequence number (exclusive)
  /// - `limit`: Maximum number of results (max 1000)
  ///
  /// Returns a list of changes with pagination metadata.
  Future<Response> _handleGetChanges(Request request) async {
    try {
      final cursorParam = request.url.queryParameters['cursor'];
      final limitParam = request.url.queryParameters['limit'];

      // Parse cursor and limit parameters
      int? cursor;
      if (cursorParam != null) {
        cursor = int.tryParse(cursorParam);
        if (cursor == null) {
          return _errorResponse(
              'Invalid cursor format: must be an integer', 400);
        }
      }

      int? limit;
      if (limitParam != null) {
        limit = int.tryParse(limitParam);
        if (limit == null || limit <= 0) {
          return _errorResponse(
              'Invalid limit format: must be a positive integer', 400);
        }
        if (limit > 1000) {
          return _errorResponse('Limit too large: maximum is 1000', 400);
        }
      }

      // Get changes with cursor-based pagination
      final changes = await _storage!.getChangesWithCursor(
        cursor: cursor,
        limit: limit,
      );

      // Prepare response
      final responseData = <String, dynamic>{
        'changes': changes,
        'count': changes.length,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Add cursor to response if there are more changes available
      if (changes.isNotEmpty && (limit == null || changes.length == limit)) {
        // Check if there are more changes after this batch
        final lastChangeId = changes.last['seq'] as int;
        final moreChanges = await _storage!.getChangesWithCursor(
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
    } catch (e) {
      return _errorResponse('Failed to fetch changes: $e', 500);
    }
  }

  /// Get a specific change by sequence number.
  ///
  /// Returns the change log entry with the specified sequence number.
  /// Returns 404 if the change is not found.
  Future<Response> _handleGetChange(Request request, String seq) async {
    try {
      final changeSeq = int.tryParse(seq);
      if (changeSeq == null) {
        return _errorResponse('Invalid change seq format', 400);
      }

      final change = await _storage!.getChange(changeSeq);
      if (change == null) {
        return _errorResponse('Change not found', 404);
      }

      return Response.ok(
        jsonEncode(change.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to fetch change: $e', 500);
    }
  }

  /// Creates new changes in the storage.
  ///
  /// Accepts an array of change objects and creates new change log entries.
  /// The `operation` field is optional and defaults to 'create' if not provided.
  /// This field represents the logical operation on the application entity,
  /// not the change log entry operation (which is always a creation).
  ///
  /// Returns metadata about created changes including sequence mappings,
  /// but not the full payload to reduce response size.
  ///
  /// TODO: Future enhancement - validate operation field against entity state snapshots.
  Future<Response> _handleCreateChanges(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      // Expect an array of changes
      if (data is! List) {
        return _errorResponse('Request body must be an array of changes', 400);
      }

      final changesToCreate = data.cast<Map<String, dynamic>>();
      if (changesToCreate.isEmpty) {
        return _errorResponse('No changes provided', 400);
      }

      List<int> createdSeqs = [];
      List<int> originalSeqs = [];
      int? failedIndex;
      String? errorMessage;

      for (int i = 0; i < changesToCreate.length; i++) {
        try {
          final changeData = changesToCreate[i];
          final originalSeq = changeData['seq'] as int?; // Capture original seq

          // Always create with fresh data, never include 'seq' in storage
          final changeToStore = {
            'entityType': changeData['entityType'] as String,
            'operation': changeData['operation'] as String? ??
                'create', // Default to 'create' if not provided
            'entityId': changeData['entityId'] as String,
            'data': Map<String, dynamic>.from(changeData['data'] ?? {}),
          };

          final created = await _storage!.createChange(changeToStore);
          final newSeq = created['seq'] as int;
          createdSeqs.add(newSeq);
          originalSeqs.add(originalSeq ?? newSeq); // Use new seq if no original
        } catch (e) {
          // Stop processing on first error
          failedIndex = i;
          errorMessage = e.toString();
          break;
        }
      }

      final success = failedIndex == null;
      final response = <String, dynamic>{
        'success': success,
        'created': createdSeqs.length,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Build sequence mapping from old seq to new seq
      if (createdSeqs.isNotEmpty) {
        final seqMap = <String, int>{};
        for (int i = 0; i < createdSeqs.length; i++) {
          seqMap[originalSeqs[i].toString()] = createdSeqs[i];
        }
        response['seqMap'] = seqMap;
      }

      if (!success) {
        response['failedAtIndex'] = failedIndex;
        response['error'] = errorMessage;
      }

      return Response.ok(
        jsonEncode(response),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to create changes: $e', 500);
    }
  }

  /// Get statistics for the change log storage.
  ///
  /// Returns count statistics for different operation types and entity types.
  /// Useful for monitoring and debugging sync operations.
  Future<Response> _handleGetStats(Request request) async {
    try {
      final changeStats = await _storage!.getChangeStats();
      final entityTypeStats = await _storage!.getEntityTypeStats();

      return Response.ok(
        jsonEncode({
          'changeStats': changeStats,
          'entityTypeStats': entityTypeStats,
          'timestamp': DateTime.now().toIso8601String(),
          'storageType': storageType.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to fetch statistics: $e', 500);
    }
  }

  /// 404 handler for unmatched routes.
  ///
  /// Returns a standardized 404 response with error details.
  Future<Response> _handleNotFound(Request request) async {
    return Response.notFound(
      jsonEncode({'error': 'Endpoint not found', 'path': request.url.path}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Helper method to create standardized error responses.
  ///
  /// Returns a JSON response with error message, timestamp and server info.
  Response _errorResponse(String message, int statusCode) {
    return Response(
      statusCode,
      body: jsonEncode({
        'error': message,
        'timestamp': DateTime.now().toIso8601String(),
        'server': serverName,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> stop() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      print('[$serverName] Server stopped');
    }

    if (_initialized) {
      await _storage!.close();
    }
  }

  bool get isRunning => _server != null;

  String? get address =>
      _server != null ? 'http://localhost:${_server!.port}' : null;
}

// Custom logging middleware
Middleware customLogRequests({required String serverName, required int port}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);
      final timestamp = DateTime.now().toIso8601String();
      final paddedName = serverName.padLeft(12);
      print(
          '$timestamp  $paddedName:$port  ${request.method}  [${response.statusCode}]  ${request.requestedUri.path}');
      return response;
    };
  };
}
