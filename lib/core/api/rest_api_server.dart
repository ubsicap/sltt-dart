import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import '../storage/local_storage_service.dart';
import '../sync/sync_manager.dart';
import '../models/document.dart';

class RestApiServer {
  static RestApiServer? _instance;
  static RestApiServer get instance => _instance ??= RestApiServer._();
  
  RestApiServer._();
  
  HttpServer? _server;
  final LocalStorageService _storage = LocalStorageService.instance;
  final SyncManager _syncManager = SyncManager.instance;
  
  Future<void> start({int port = 8080}) async {
    if (_server != null) {
      print('[RestAPI] Server is already running');
      return;
    }
    
    // Initialize dependencies
    await _storage.initialize();
    await _syncManager.initialize();
    
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
    
    // Document endpoints
    router.get('/api/documents', _handleGetDocuments);
    router.get('/api/documents/<uuid>', _handleGetDocument);
    router.post('/api/documents', _handleCreateDocument);
    router.put('/api/documents/<uuid>', _handleUpdateDocument);
    router.delete('/api/documents/<uuid>', _handleDeleteDocument);
    
    // Search
    router.get('/api/documents/search/<query>', _handleSearchDocuments);
    
    // Sync endpoints
    router.get('/api/sync/status', _handleGetSyncStatus);
    router.post('/api/sync/trigger', _handleTriggerSync);
    router.post('/api/sync/document/<uuid>', _handleSyncDocument);
    
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
  
  // Document endpoints
  Future<Response> _handleGetDocuments(Request request) async {
    try {
      final typeParam = request.url.queryParameters['type'];
      
      final documents = typeParam != null
          ? await _storage.getDocumentsByType(typeParam)
          : await _storage.getAllDocuments();
      
      return Response.ok(
        jsonEncode({
          'documents': documents.map((d) => d.toJson()).toList(),
          'count': documents.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to fetch documents: $e', 500);
    }
  }
  
  Future<Response> _handleGetDocument(Request request, String uuid) async {
    try {
      final document = await _storage.getDocument(uuid);
      
      if (document == null) {
        return _errorResponse('Document not found', 404);
      }
      
      return Response.ok(
        jsonEncode(document.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to fetch document: $e', 500);
    }
  }
  
  Future<Response> _handleCreateDocument(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final document = Document(
        title: data['title'] as String? ?? '',
        content: data['content'] as String? ?? '',
        type: data['type'] as String? ?? 'note',
        mediaPath: data['mediaPath'] as String?,
        metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      );
      
      final created = await _storage.createDocument(document);
      
      return Response.ok(
        jsonEncode({
          'message': 'Document created successfully',
          'document': created.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to create document: $e', 400);
    }
  }
  
  Future<Response> _handleUpdateDocument(Request request, String uuid) async {
    try {
      final document = await _storage.getDocument(uuid);
      if (document == null) {
        return _errorResponse('Document not found', 404);
      }
      
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      // Update fields
      if (data['title'] != null) document.title = data['title'] as String;
      if (data['content'] != null) document.content = data['content'] as String;
      if (data['type'] != null) document.type = data['type'] as String;
      if (data['mediaPath'] != null) document.mediaPath = data['mediaPath'] as String?;
      if (data['metadata'] != null) {
        document.metadata = Map<String, dynamic>.from(data['metadata']);
      }
      
      final updated = await _storage.updateDocument(document);
      
      return Response.ok(
        jsonEncode({
          'message': 'Document updated successfully',
          'document': updated.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to update document: $e', 400);
    }
  }
  
  Future<Response> _handleDeleteDocument(Request request, String uuid) async {
    try {
      final deleted = await _storage.deleteDocument(uuid);
      
      if (!deleted) {
        return _errorResponse('Document not found', 404);
      }
      
      return Response.ok(
        jsonEncode({'message': 'Document deleted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to delete document: $e', 500);
    }
  }
  
  Future<Response> _handleSearchDocuments(Request request, String query) async {
    try {
      final documents = await _storage.searchDocuments(Uri.decodeComponent(query));
      
      return Response.ok(
        jsonEncode({
          'query': query,
          'documents': documents.map((d) => d.toJson()).toList(),
          'count': documents.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to search documents: $e', 500);
    }
  }
  
  // Sync endpoints
  Future<Response> _handleGetSyncStatus(Request request) async {
    try {
      final status = await _syncManager.getSyncStatus();
      
      return Response.ok(
        jsonEncode(status),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to get sync status: $e', 500);
    }
  }
  
  Future<Response> _handleTriggerSync(Request request) async {
    try {
      // Trigger async sync without waiting
      _syncManager.syncPendingChanges().catchError((e) {
        print('[RestAPI] Sync error: $e');
      });
      
      return Response.ok(
        jsonEncode({'message': 'Sync triggered successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to trigger sync: $e', 500);
    }
  }
  
  Future<Response> _handleSyncDocument(Request request, String uuid) async {
    try {
      await _syncManager.syncDocument(uuid);
      
      return Response.ok(
        jsonEncode({'message': 'Document sync completed'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to sync document: $e', 500);
    }
  }
  
  // Statistics endpoint
  Future<Response> _handleGetStats(Request request) async {
    try {
      final stats = await _storage.getSyncStats();
      final syncStatus = await _syncManager.getSyncStatus();
      
      return Response.ok(
        jsonEncode({
          'storage': stats,
          'sync': syncStatus,
          'server': {
            'uptime': DateTime.now().toIso8601String(),
            'port': _server?.port,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse('Failed to get statistics: $e', 500);
    }
  }
  
  Response _handleNotFound(Request request) {
    return _errorResponse('Endpoint not found', 404);
  }
  
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
    
    await _syncManager.dispose();
    await _storage.close();
  }
  
  bool get isRunning => _server != null;
  
  String? get address => _server != null 
      ? 'http://localhost:${_server!.port}' 
      : null;
}
