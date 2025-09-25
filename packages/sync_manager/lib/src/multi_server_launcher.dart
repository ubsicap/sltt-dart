import 'package:sltt_core/sltt_core.dart';

import 'localhost_rest_api_server.dart';
import 'server_ports.dart';

class MultiServerLauncher {
  static MultiServerLauncher? _instance;
  static MultiServerLauncher get instance =>
      _instance ??= MultiServerLauncher._();

  MultiServerLauncher._();

  LocalhostRestApiServer? _localStorageServer;
  LocalhostRestApiServer? _cloudStorageServer;

  Future<void> startAllServers() async {
    print('[MultiServerLauncher] Starting all servers...');

    await startServer(StorageType.local, kLocalStoragePort);
    await startServer(StorageType.cloud, kCloudStoragePort);

    print('[MultiServerLauncher] All servers started successfully');
  }

  Future<StartResponse> startServer(StorageType storageType, int port) async {
    switch (storageType) {
      case StorageType.local:
        if (_localStorageServer == null) {
          _localStorageServer = LocalhostRestApiServer(
            StorageType.local,
            'SlttLocalStorage',
          );
          return await _localStorageServer!.start(port: port);
        } else {
          print(
            '[MultiServerLauncher] Local storage server is already running',
          );
        }
        return StartResponse(
          storageId: await _localStorageServer!.storage.getStorageId(),
          storageType: _localStorageServer!.storage.getStorageType(),
        );
      case StorageType.cloud:
        if (_cloudStorageServer == null) {
          _cloudStorageServer = LocalhostRestApiServer(
            StorageType.cloud,
            'SlttMockCloudStorage',
          );
          return await _cloudStorageServer!.start(port: port);
        } else {
          print(
            '[MultiServerLauncher] Cloud storage server is already running',
          );
        }
        return StartResponse(
          storageId: await _cloudStorageServer!.storage.getStorageId(),
          storageType: _cloudStorageServer!.storage.getStorageType(),
        );
    }
    // print('[MultiServerLauncher] Unknown server type: $storageType');
  }

  Future<void> stopAllServers() async {
    print('[MultiServerLauncher] Stopping all servers...');

    if (_localStorageServer != null) {
      await _localStorageServer!.stop();
      _localStorageServer = null;
    }

    if (_cloudStorageServer != null) {
      await _cloudStorageServer!.stop();
      _cloudStorageServer = null;
    }

    print('[MultiServerLauncher] All servers stopped');
  }

  Future<void> stopServer(StorageType storageType) async {
    switch (storageType) {
      case StorageType.local:
        if (_localStorageServer != null) {
          await _localStorageServer!.stop();
          _localStorageServer = null;
        }
        break;
      case StorageType.cloud:
        if (_cloudStorageServer != null) {
          await _cloudStorageServer!.stop();
          _cloudStorageServer = null;
        }
        break;
      // default:
      //   print('[MultiServerLauncher] Unknown server type: $storageType');
    }
  }

  Map<String, bool> getServerStatus() {
    final storageLocalKey = StorageType.local.toString().split('.').last;
    final storageCloudKey = StorageType.cloud.toString().split('.').last;
    return {
      storageLocalKey: _localStorageServer?.isRunning ?? false,
      storageCloudKey: _cloudStorageServer?.isRunning ?? false,
    };
  }

  Map<String, String?> getServerAddresses() {
    final storageLocalKey = StorageType.local.toString().split('.').last;
    final storageCloudKey = StorageType.cloud.toString().split('.').last;
    return {
      storageLocalKey: _localStorageServer?.address,
      storageCloudKey: _cloudStorageServer?.address,
    };
  }
}
