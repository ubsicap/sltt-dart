import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as path;
import 'package:sltt_core/src/models/base_entity_state.dart';
import 'package:sync_manager/src/isar_storage_service.dart';
import 'package:sync_manager/src/localhost_rest_api_server.dart';
import 'package:sync_manager/src/models/passage_translation.entity_state.isar.dart';
import 'package:sync_manager/src/models/portion_translation.entity_state.isar.dart';

void main(List<String> args) async {
  String? dbPath;
  int port = 8081;
  bool inspector = true; // Default to true for this inspector-focused server

  // Parse command line arguments
  for (int i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--db-path':
      case '--db':
        if (i + 1 < args.length) {
          dbPath = args[i + 1];
          i++;
        }
        break;
      case '--port':
        if (i + 1 < args.length) {
          port = int.tryParse(args[i + 1]) ?? 8081;
          i++;
        }
        break;
      case '--inspector':
        if (i + 1 < args.length) {
          inspector = args[i + 1].toLowerCase() == 'true';
          i++;
        }
        break;
      case '--help':
      case '-h':
        _printUsage();
        exit(0);
    }
  }

  if (dbPath == null) {
    print('Error: --db-path is required\n');
    _printUsage();
    exit(1);
  }

  // Validate the database file exists
  final dbFile = File(dbPath);
  if (!await dbFile.exists()) {
    print('Error: Database file not found: $dbPath');
    exit(1);
  }

  // Extract database name from path (without .isar extension)
  final dbName = path.basenameWithoutExtension(dbPath);

  print('🔍 Starting Local Storage Server with Inspector');
  print('   Database: $dbPath');
  print('   DB Name: $dbName');
  print('   Port: $port');
  print('   Inspector: ${inspector ? "enabled" : "disabled"}');
  print('');

  // Create a custom IsarStorageService with the specified database
  final storage = IsarStorageService(
    dbName,
    'Inspector-$dbName',
    dbDirectory: path.dirname(dbPath),
  );

  // Create server with the custom storage
  final server = LocalhostRestApiServer(
    StorageType.local,
    'LocalStorage-Inspector',
    storage: storage,
  );

  // Initialize storage with inspector enabled
  // if dbPath has sltt-standalone-app in its path, switch to using
  // its schemas:
  late final List<CollectionSchema<BaseEntityState>>?
  providedEntityStateSchemas;
  if (dbPath.contains('sltt-standalone-app')) {
    providedEntityStateSchemas = [
      IsarPortionDataEntityStateSchema,
      IsarPassageDataEntityStateSchema,
      // Add any other schemas specific to sltt-standalone-app here
    ];
  } else {
    providedEntityStateSchemas = null;
  }
  await storage.initialize(
    providedEntityStateSchemas: providedEntityStateSchemas,
    inspector: inspector,
  );

  // Start the server
  await server.start(port: port);

  final baseUrl = 'http://localhost:$port';
  print('');
  print('✅ Local Storage Server started successfully!');
  print('');
  print('🌐 Server URL: $baseUrl');
  print(
    '🔍 Isar Inspector: ${inspector ? "http://localhost:$port (check Isar Inspector UI)" : "disabled"}',
  );
  print('📊 Database: ${storage.databasePath}');
  print('');
  print('Available endpoints:');
  print('   GET  /health                            - Health check');
  print('   GET  /api/help                          - API documentation');
  print('   POST /api/changes                       - Create changes');
  print('   GET  /api/projects                      - List all projects');
  print('   GET  /api/changes/projects/{id}         - Get project changes');
  print('   GET  /api/state/projects/{id}/portions  - Get entity states');
  print('');
  print('Press CTRL+C to stop the server');
  print('');

  // Keep process alive until terminated
  await ProcessSignal.sigint.watch().first;
  print('\n🛑 Shutting down server...');
  await server.storage.close();
  print('✅ Server stopped');
  exit(0);
}

void _printUsage() {
  print('Local Storage Server with Isar Inspector');
  print('');
  print('Usage: dart run bin/run_local_server_with_inspector.dart [options]');
  print('');
  print('Required options:');
  print('  --db-path <path>    Path to the Isar database file (.isar)');
  print('');
  print('Optional options:');
  print('  --port <number>     Port to run the server on (default: 8081)');
  print('  --inspector <bool>  Enable Isar inspector (default: true)');
  print('  --help, -h          Show this help message');
  print('');
  print('Example:');
  print(
    '  dart run bin/run_local_server_with_inspector.dart --db-path ./isar_db/local_storage.isar --port 8081',
  );
  print('');
}
