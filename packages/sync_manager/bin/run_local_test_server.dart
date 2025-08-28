import 'dart:io';

import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/shared_storage_service.dart';

class LocalTestServer extends BaseRestApiServer {
  LocalTestServer({required super.serverName, required super.storage});

  @override
  String get storageTypeDescription => storage.getStorageType();
}

void main(List<String> args) async {
  final portArgIndex = args.indexOf('--port');
  final port = (portArgIndex != -1 && args.length > portArgIndex + 1)
      ? int.tryParse(args[portArgIndex + 1]) ?? 8081
      : 8081;

  final storage = OutsyncsStorageService.instance;
  final server = LocalTestServer(
    serverName: 'sync-manager-local',
    storage: storage,
  );

  // Start server (this will initialize storage)
  await server.start(port: port);

  final baseUrl = 'http://localhost:$port';
  print('Local test server started at: $baseUrl');
  print('Press CTRL+C to stop');

  // Keep process alive until terminated
  await ProcessSignal.sigint.watch().first;
  print('Shutting down server...');
  await server.storage.close();
  exit(0);
}
