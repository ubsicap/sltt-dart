import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import '../storage/local_storage_service.dart';
import '../models/change_log_entry.dart';

class RestApiServer {
  static RestApiServer? _instance;
  static RestApiServer get instance => _instance ??= RestApiServer._();
  
  RestApiServer._();
  
  HttpServer? _server;
  final LocalStorageService _storage = LocalStorageService.instance;
  
  Future<void> start({int port = 8080}) async {
    if (_server != null) {
      print('[RestAPI] Server is already running');
      return;
    }
    
    // Initialize dependencies
    await _storage.initialize();
    
    final router = _buildRouter();
    
    // Add CORS and logging middleware
    final handler = Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(logRequests())
        .addHandler(router);
    
    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    print('[RestAPI] Server started on http://localhost:$port');
  }
  
  Router _buildRouter() {
    final router = Router();
    
    // Health check
    router.get('/health', _handleHealth);
    
    // Change log endpoints
    router.get('/api/changes', _handleGetChanges);
    router.get('/api/changes/<id>', _handleGetChange);
    router.post('/api/changes', _handleCreateChange);
    router.put('/api/changes/<id>', _handleUpdateChange);
    router.delete('/api/changes/<id>', _handleDeleteChange);
    
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
        'server': 'flutter-2-local-storage',
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
  
  // Get all changes or filter by query parameters
  Future<Response> _handleGetChanges(Request request) async {
    try {
      final entityType = request.url.queryParameters['entityType'];
      final operation = request.url.queryParameters['operation'];
      final entityId = request.url.queryParameters['entityId'];
      
      List<ChangeLogEntry> changes;
      
      if (entityType != null) {
        changes = await _storage.getChangesByEntityType(entityType);
      } else if (operation != null) {
        changes = await _storage.getChangesByOperation(operation);
      } else if (entityId != null) {
        changes = await _storage.getChangesByEntityId(entityId);
      } else {
        changes = await _storage.getAllChanges();
      }
      
      return Response.ok(
        jsonEncode({
          'changes': changes.map((c) => c.toJson()).toList(),
          'count': changes.length,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to fetch changes: $e', 500);
    }
  }
  
  // Get a specific change by ID
  Future<Response> _handleGetChange(Request request, String id) async {
    try {
      final changeId = int.tryParse(id);
      if (changeId == null) {
        return _errorResponse('Invalid change ID format', 400);
      }
      
      final change = await _storage.getChange(changeId);
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
      
      final change = ChangeLogEntry(
        entityType: data['entityType'] as String,
        operation: data['operation'] as String,
        timestamp: data['timestamp'] != null 
            ? DateTime.parse(data['timestamp'] as String)
            : DateTime.now(),
        entityId: data['entityId'] as String,
        data: Map<String, dynamic>.from(data['data'] ?? {}),
      );
      
      final created = await _storage.createChange(change);
      
      return Response.ok(
        jsonEncode(created.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to create change: $e', 500);
    }
  }
  
  // Update an existing change
  Future<Response> _handleUpdateChange(Request request, String id) async {
    try {
      final changeId = int.tryParse(id);
      if (changeId == null) {
        return _errorResponse('Invalid change ID format', 400);
      }
      
      final change = await _storage.getChange(changeId);
      if (change == null) {
        return _errorResponse('Change not found', 404);
      }
      
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      // Update fields if provided
      if (data['entityType'] != null) change.entityType = data['entityType'] as String;
      if (data['operation'] != null) change.operation = data['operation'] as String;
      if (data['timestamp'] != null) change.timestamp = DateTime.parse(data['timestamp'] as String);
      if (data['entityId'] != null) change.entityId = data['entityId'] as String;
      if (data['data'] != null) change.data = Map<String, dynamic>.from(data['data']);
      
      final updated = await _storage.updateChange(change);
      
      return Response.ok(
        jsonEncode(updated.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to update change: $e', 500);
    }
  }
  
  // Delete a change
  Future<Response> _handleDeleteChange(Request request, String id) async {
    try {
      final changeId = int.tryParse(id);
      if (changeId == null) {
        return _errorResponse('Invalid change ID format', 400);
      }
      
      final deleted = await _storage.deleteChange(changeId);
      
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
      final changeStats = await _storage.getChangeStats();
      final entityTypeStats = await _storage.getEntityTypeStats();
      
      return Response.ok(
        jsonEncode({
          'changeStats': changeStats,
          'entityTypeStats': entityTypeStats,
          'timestamp': DateTime.now().toIso8601String(),
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
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
  
  Future<void> stop() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      print('[RestAPI] Server stopped');
    }
    
    await _storage.close();
  }
  
  bool get isRunning => _server != null;
  
  String? get address => _server != null 
      ? 'http://localhost:${_server!.port}' 
      : null;
}
