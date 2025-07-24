import 'dart:io';
import '../lib/core/api/rest_api_server.dart';

Future<void> main() async {
  final server = RestApiServer.instance;

  print('Starting Flutter-2 Local Storage Server...');

  try {
    await server.start(port: 8080);
    print('Server is running at ${server.address}');
    print('\nAvailable endpoints:');
    print('  GET  /health              - Health check');
    print('  GET  /api/changes         - Get all changes');
    print('  GET  /api/changes/{id}    - Get specific change');
    print('  POST /api/changes         - Create new change');
    print('  PUT  /api/changes/{id}    - Update change');
    print('  DELETE /api/changes/{id}  - Delete change');
    print('  GET  /api/stats           - Get server statistics');
    print('\nQuery parameters for /api/changes:');
    print('  ?entityType=Document      - Filter by entity type');
    print('  ?operation=create         - Filter by operation');
    print('  ?entityId=uuid            - Filter by entity ID');
    print('  ?cursor=123               - Start after change ID (exclusive)');
    print('  ?limit=10                 - Limit number of results');
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
