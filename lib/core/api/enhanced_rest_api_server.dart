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

    // Change log endpoints
    router.post('/api/changes', _handleCreateChanges);
    router.get('/api/changes', _handleGetChanges);
    router.get('/api/changes/<seq>', _handleGetChange);

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

  /// Creates new changes in the storage
  /// Returns metadata about created changes, not the full payload
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
            'operation': changeData['operation'] as String,
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
  } // Update an existing change (not available for cloud storage)

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
