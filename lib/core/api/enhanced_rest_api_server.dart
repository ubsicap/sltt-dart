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
        .addMiddleware(logRequests())
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

    // Change log endpoints
    router.get('/api/changes', _handleGetChanges);
    router.get('/api/changes/<seq>', _handleGetChange);
    router.post('/api/changes', _handleCreateChange);
    
    // Sync endpoint - POST /changes/sync/{seq}
    router.post('/api/changes/sync/<seq>', _handleSyncChanges);

    // Conditional endpoints based on storage type
    if (storageType != StorageType.cloudStorage) {
      // Allow PUT and DELETE for outsyncs and downsyncs
      router.put('/api/changes/<seq>', _handleUpdateChange);
      router.delete('/api/changes/<seq>', _handleDeleteChange);
    }

    // Statistics
    router.get('/api/stats', _handleGetStats);

    // 404 handler
    router.all('/<ignored|.*>', _handleNotFound);

    return router;
  }

  // Health check endpoint
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

  // Get all changes or filter by query parameters
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

  // Get a specific change by seq
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

  // Create a new change
  Future<Response> _handleCreateChange(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final changeData = {
        'entityType': data['entityType'] as String,
        'operation': data['operation'] as String,
        'entityId': data['entityId'] as String,
        'data': Map<String, dynamic>.from(data['data'] ?? {}),
      };

      final created = await _storage!.createChange(changeData);

      return Response.ok(
        jsonEncode(created),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to create change: $e', 500);
    }
  }

  // Sync endpoint: POST /api/changes/sync/{seq}
  // Stores new changes and responds with changes since last seq
  Future<Response> _handleSyncChanges(Request request, String seq) async {
    try {
      final lastSeq = int.tryParse(seq);
      if (lastSeq == null) {
        return _errorResponse('Invalid seq format: must be an integer', 400);
      }

      final body = await request.readAsString();
      List<Map<String, dynamic>> newChanges = [];
      
      if (body.isNotEmpty) {
        final data = jsonDecode(body);
        if (data is List) {
          newChanges = data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          newChanges = [data];
        }
      }

      // Store new changes if any
      List<Map<String, dynamic>> storedChanges = [];
      if (newChanges.isNotEmpty) {
        for (final changeData in newChanges) {
          final changeToStore = {
            'entityType': changeData['entityType'] as String,
            'operation': changeData['operation'] as String,
            'entityId': changeData['entityId'] as String,
            'data': Map<String, dynamic>.from(changeData['data'] ?? {}),
          };
          final created = await _storage!.createChange(changeToStore);
          storedChanges.add(created);
        }
      }

      // Get changes since the provided seq
      List<Map<String, dynamic>> changesSinceSeq = [];
      if (storageType == StorageType.cloudStorage || storageType == StorageType.outsyncs) {
        changesSinceSeq = await _storage!.getChangesSince(lastSeq);
      } else {
        // For downsyncs, use cursor-based approach
        changesSinceSeq = await _storage!.getChangesWithCursor(cursor: lastSeq);
      }

      return Response.ok(
        jsonEncode({
          'storedChanges': storedChanges,
          'changesSinceSeq': changesSinceSeq,
          'lastProcessedSeq': lastSeq,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to sync changes: $e', 500);
    }
  }

  // Update an existing change (not available for cloud storage)
  Future<Response> _handleUpdateChange(Request request, String seq) async {
    try {
      final changeSeq = int.tryParse(seq);
      if (changeSeq == null) {
        return _errorResponse('Invalid change seq format', 400);
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final updated = await _storage!.updateChange(changeSeq, data);

      return Response.ok(
        jsonEncode(updated),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to update change: $e', 500);
    }
  }

  // Delete a change (not available for cloud storage)
  Future<Response> _handleDeleteChange(Request request, String seq) async {
    try {
      final changeSeq = int.tryParse(seq);
      if (changeSeq == null) {
        return _errorResponse('Invalid change seq format', 400);
      }

      final deleted = await _storage!.deleteChange(changeSeq);

      if (deleted) {
        return Response.ok(
          jsonEncode({'message': 'Change deleted successfully'}),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return _errorResponse('Change not found', 404);
      }
    } catch (e) {
      return _errorResponse('Failed to delete change: $e', 500);
    }
  }

  // Get statistics
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

  // 404 handler
  Future<Response> _handleNotFound(Request request) async {
    return Response.notFound(
      jsonEncode({'error': 'Endpoint not found', 'path': request.url.path}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Error response helper
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
