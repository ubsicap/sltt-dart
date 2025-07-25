import '../api/enhanced_rest_api_server.dart';

class MultiServerLauncher {
  static MultiServerLauncher? _instance;
  static MultiServerLauncher get instance => _instance ??= MultiServerLauncher._();

  MultiServerLauncher._();

  EnhancedRestApiServer? _upsyncsServer;
  EnhancedRestApiServer? _downsyncsServer;
  EnhancedRestApiServer? _cloudStorageServer;

  Future<void> startAllServers() async {
    print('[MultiServerLauncher] Starting all servers...');

    // Start downsyncs server on port 8081
    _downsyncsServer = EnhancedRestApiServer(StorageType.downsyncs, 'DownsyncsServer');
    await _downsyncsServer!.start(port: 8081);

    // Start upsyncs server on port 8082
    _upsyncsServer = EnhancedRestApiServer(StorageType.upsyncs, 'UpsyncsServer');
    await _upsyncsServer!.start(port: 8082);

    // Start cloud storage server on port 8083
    _cloudStorageServer = EnhancedRestApiServer(StorageType.cloudStorage, 'CloudStorageServer');
    await _cloudStorageServer!.start(port: 8083);

    print('[MultiServerLauncher] All servers started successfully');
  }

  Future<void> startServer(String serverType, int port) async {
    switch (serverType.toLowerCase()) {
      case 'downsyncs':
        if (_downsyncsServer == null) {
          _downsyncsServer = EnhancedRestApiServer(StorageType.downsyncs, 'DownsyncsServer');
          await _downsyncsServer!.start(port: port);
        } else {
          print('[MultiServerLauncher] Downsyncs server is already running');
        }
        break;
      case 'upsyncs':
        if (_upsyncsServer == null) {
          _upsyncsServer = EnhancedRestApiServer(StorageType.upsyncs, 'UpsyncsServer');
          await _upsyncsServer!.start(port: port);
        } else {
          print('[MultiServerLauncher] Upsyncs server is already running');
        }
        break;
      case 'cloud':
      case 'cloudstorage':
        if (_cloudStorageServer == null) {
          _cloudStorageServer = EnhancedRestApiServer(StorageType.cloudStorage, 'CloudStorageServer');
          await _cloudStorageServer!.start(port: port);
        } else {
          print('[MultiServerLauncher] Cloud storage server is already running');
        }
        break;
      default:
        print('[MultiServerLauncher] Unknown server type: $serverType');
    }
  }

  Future<void> stopAllServers() async {
    print('[MultiServerLauncher] Stopping all servers...');

    if (_downsyncsServer != null) {
      await _downsyncsServer!.stop();
      _downsyncsServer = null;
    }

    if (_upsyncsServer != null) {
      await _upsyncsServer!.stop();
      _upsyncsServer = null;
    }

    if (_cloudStorageServer != null) {
      await _cloudStorageServer!.stop();
      _cloudStorageServer = null;
    }

    print('[MultiServerLauncher] All servers stopped');
  }

  Future<void> stopServer(String serverType) async {
    switch (serverType.toLowerCase()) {
      case 'downsyncs':
        if (_downsyncsServer != null) {
          await _downsyncsServer!.stop();
          _downsyncsServer = null;
        }
        break;
      case 'upsyncs':
        if (_upsyncsServer != null) {
          await _upsyncsServer!.stop();
          _upsyncsServer = null;
        }
        break;
      case 'cloud':
      case 'cloudstorage':
        if (_cloudStorageServer != null) {
          await _cloudStorageServer!.stop();
          _cloudStorageServer = null;
        }
        break;
      default:
        print('[MultiServerLauncher] Unknown server type: $serverType');
    }
  }

  Map<String, bool> getServerStatus() {
    return {
      'downsyncs': _downsyncsServer?.isRunning ?? false,
      'upsyncs': _upsyncsServer?.isRunning ?? false,
      'cloudStorage': _cloudStorageServer?.isRunning ?? false,
    };
  }

  Map<String, String?> getServerAddresses() {
    return {
      'downsyncs': _downsyncsServer?.address,
      'upsyncs': _upsyncsServer?.address,
      'cloudStorage': _cloudStorageServer?.address,
    };
  }
}
