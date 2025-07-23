import 'dart:io';
import '../lib/core/api/rest_api_server.dart';

Future<void> main() async {
  final server = RestApiServer.instance;
  
  print('Starting Flutter-2 Local Storage Server...');
  
  try {
    await server.start(port: 8080);
    print('Server is running at ${server.address}');
    print('\nAvailable endpoints:');
    print('  GET  /health                    - Health check');
    print('  GET  /api/documents             - Get all documents');
    print('  GET  /api/documents/{uuid}      - Get specific document');
    print('  POST /api/documents             - Create new document');
    print('  PUT  /api/documents/{uuid}      - Update document');
    print('  DELETE /api/documents/{uuid}    - Delete document');
    print('  GET  /api/documents/search/{q}  - Search documents');
    print('  GET  /api/sync/status           - Get sync status');
    print('  POST /api/sync/trigger          - Trigger sync');
    print('  POST /api/sync/document/{uuid}  - Sync specific document');
    print('  GET  /api/stats                 - Get server statistics');
    print('\nPress Ctrl+C to stop the server');
    
    // Handle shutdown gracefully
    ProcessSignal.sigint.watch().listen((_) async {
      print('\nShutting down server...');
      await server.stop();
      exit(0);
    });
    
    // Keep the server running
    while (server.isRunning) {
      await Future.delayed(const Duration(seconds: 1));
    }
    
  } catch (e) {
    print('Error starting server: $e');
    exit(1);
  }
}
