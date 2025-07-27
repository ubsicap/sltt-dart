import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

import '../storage/base_storage_service.dart';

/// Base REST API server that provides common functionality for all storage types.
///
/// This eliminates code duplication between different server implementations
/// by providing shared endpoints, middleware, and error handling.
abstract class BaseRestApiServer {
  final String serverName;
  final BaseStorageService storage;

  HttpServer? _server;

  BaseRestApiServer({
    required this.serverName,
    required this.storage,
  });

  /// Storage type description for API documentation
  String get storageTypeDescription;

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
    router.post('/api/changes', _handleCreateChanges);
    router.get('/api/changes', _handleGetChanges);
    router.get('/api/changes/<seq>', _handleGetChange);
    router.get('/api/stats', _handleGetStats);

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
    final docs = {
      'server': {
        'name': serverName,
        'storageType': storageTypeDescription,
        'description': 'SLTT API server with $storageTypeDescription storage',
      },
      'endpoints': [
        {
          'method': 'GET',
          'path': '/health',
          'description': 'Health check - returns server status',
        },
        {
          'method': 'GET',
          'path': '/api/help',
          'description': 'API documentation - returns this documentation',
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
        },
        {
          'method': 'GET',
          'path': '/api/changes/{seq}',
          'description': 'Get specific change by sequence number',
        },
        {
          'method': 'POST',
          'path': '/api/changes',
          'description': 'Create new changes (array format)',
        },
        {
          'method': 'GET',
          'path': '/api/stats',
          'description': 'Get statistics about changes and entity types',
        },
      ],
      'timestamp': DateTime.now().toIso8601String(),
    };

    return Response.ok(
      jsonEncode(docs),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Get changes with optional pagination
  Future<Response> _handleGetChanges(Request request) async {
    try {
      final cursorParam = request.url.queryParameters['cursor'];
      final limitParam = request.url.queryParameters['limit'];

      int? cursor;
      if (cursorParam != null) {
        cursor = int.tryParse(cursorParam);
        if (cursor == null) {
          return _errorResponse('Invalid cursor format: must be an integer', 400);
        }
      }

      int? limit;
      if (limitParam != null) {
        limit = int.tryParse(limitParam);
        if (limit == null || limit <= 0) {
          return _errorResponse('Invalid limit format: must be a positive integer', 400);
        }
        if (limit > 1000) {
          return _errorResponse('Limit too large: maximum is 1000', 400);
        }
      }

      final changes = await storage.getChangesWithCursor(
        cursor: cursor,
        limit: limit,
      );

      final responseData = <String, dynamic>{
        'changes': changes,
        'count': changes.length,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Add cursor to response if there are more changes available
      if (changes.isNotEmpty && (limit == null || changes.length == limit)) {
        final lastChangeId = changes.last['seq'] as int;
        final moreChanges = await storage.getChangesWithCursor(
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

  /// Get specific change by sequence number
  Future<Response> _handleGetChange(Request request, String seq) async {
    try {
      final changeSeq = int.tryParse(seq);
      if (changeSeq == null) {
        return _errorResponse('Invalid change seq format', 400);
      }

      final change = await storage.getChange(changeSeq);
      if (change == null) {
        return _errorResponse('Change not found', 404);
      }

      return Response.ok(
        jsonEncode(change),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to fetch change: $e', 500);
    }
  }

  /// Create new changes
  Future<Response> _handleCreateChanges(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

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
          final originalSeq = changeData['seq'] as int?;

          final changeToStore = {
            'entityType': changeData['entityType'] as String,
            'operation': changeData['operation'] as String? ?? 'create',
            'entityId': changeData['entityId'] as String,
            'data': Map<String, dynamic>.from(changeData['data'] ?? {}),
          };

          final created = await storage.createChange(changeToStore);
          final newSeq = created['seq'] as int;
          createdSeqs.add(newSeq);
          originalSeqs.add(originalSeq ?? newSeq);
        } catch (e) {
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

  /// Get statistics
  Future<Response> _handleGetStats(Request request) async {
    try {
      final changeStats = await storage.getChangeStats();
      final entityTypeStats = await storage.getEntityTypeStats();

      return Response.ok(
        jsonEncode({
          'changeStats': changeStats,
          'entityTypeStats': entityTypeStats,
          'timestamp': DateTime.now().toIso8601String(),
          'storageType': storageTypeDescription,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to fetch statistics: $e', 500);
    }
  }

  /// 404 handler
  Future<Response> _handleNotFound(Request request) async {
    return Response.notFound(
      jsonEncode({'error': 'Endpoint not found', 'path': request.url.path}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Helper method for error responses
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
  String? get address => _server != null ? 'http://localhost:${_server!.port}' : null;
}

/// Custom logging middleware
Middleware _customLogRequests({required String serverName, required int port}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);
      final timestamp = DateTime.now().toIso8601String();
      final paddedName = serverName.padLeft(12);
      print('$timestamp  $paddedName:$port  ${request.method}  [${response.statusCode}]  ${request.requestedUri.path}');
      return response;
    };
  };
}
