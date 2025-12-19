import 'dart:io';

import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/isar_storage_service.dart';

class LocalTestServer extends BaseRestApiServer {
  LocalTestServer({
    required super.serverName,
    required super.storage,
    BaseMediaStorage? mediaStorage,
  }) : super(mediaStorage: mediaStorage ?? NullMediaStorage());

  @override
  String get storageTypeDescription => storage.getStorageType();
}

void main(List<String> args) async {
  final portArgIndex = args.indexOf('--port');
  final port = (portArgIndex != -1 && args.length > portArgIndex + 1)
      ? int.tryParse(args[portArgIndex + 1]) ?? 8081
      : 8081;

  final storage = LocalStorageService.instance;
  final mediaStorage = NullMediaStorage();
  final server = LocalTestServer(
    serverName: 'sync-manager-local',
    storage: storage,
    mediaStorage: mediaStorage,
  );

  // Start server (this will initialize storage)
  await server.start(port: port);

  final baseUrl = 'http://localhost:$port';
  SlttLogger.logger.info('Local test server started at: $baseUrl');
  SlttLogger.logger.info('Press CTRL+C to stop');

  // Keep process alive until terminated
  await ProcessSignal.sigint.watch().first;
  SlttLogger.logger.info('Shutting down server...');
  await server.stop();
  exit(0);
}
