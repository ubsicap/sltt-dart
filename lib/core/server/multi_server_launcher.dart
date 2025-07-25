import '../api/enhanced_rest_api_server.dart';

class MultiServerLauncher {
  static MultiServerLauncher? _instance;
  static MultiServerLauncher get instance => _instance ??= MultiServerLauncher._();

  MultiServerLauncher._();

  EnhancedRestApiServer? _outsyncsServer;
  EnhancedRestApiServer? _downsyncsServer;
  EnhancedRestApiServer? _cloudStorageServer;

  Future<void> startAllServers() async {
    print('[MultiServerLauncher] Starting all servers...');

    // Start downsyncs server on port 8081
    _downsyncsServer = EnhancedRestApiServer(StorageType.downsyncs, 'DownsyncsServer');
    await _downsyncsServer!.start(port: 8081);

    // Start outsyncs server on port 8082
    _outsyncsServer = EnhancedRestApiServer(StorageType.outsyncs, 'OutsyncsServer');
    await _outsyncsServer!.start(port: 8082);

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
      case 'outsyncs':
        if (_outsyncsServer == null) {
          _outsyncsServer = EnhancedRestApiServer(StorageType.outsyncs, 'OutsyncsServer');
          await _outsyncsServer!.start(port: port);
        } else {
          print('[MultiServerLauncher] Outsyncs server is already running');
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

    if (_outsyncsServer != null) {
      await _outsyncsServer!.stop();
      _outsyncsServer = null;
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
      case 'outsyncs':
        if (_outsyncsServer != null) {
          await _outsyncsServer!.stop();
          _outsyncsServer = null;
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
      'outsyncs': _outsyncsServer?.isRunning ?? false,
      'cloudStorage': _cloudStorageServer?.isRunning ?? false,
    };
  }

  Map<String, String?> getServerAddresses() {
    return {
      'downsyncs': _downsyncsServer?.address,
      'outsyncs': _outsyncsServer?.address,
      'cloudStorage': _cloudStorageServer?.address,
    };
  }
}
