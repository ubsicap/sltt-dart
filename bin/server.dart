import 'dart:io';
import '../lib/core/server/multi_server_launcher.dart';
import '../lib/core/server/server_ports.dart';

Future<void> main(List<String> args) async {
  final launcher = MultiServerLauncher.instance;
  print('Starting Dart Enhanced REST API Servers...');

  // Determine which servers to start
  final validTypes = ['downsyncs', 'outsyncs', 'cloud'];
  List<String> serversToStart = validTypes;
  if (args.isNotEmpty) {
    serversToStart = args.where((type) => validTypes.contains(type)).toList();
    if (serversToStart.isEmpty) {
      print('No valid server types specified. Valid types: downsyncs, outsyncs, cloud');
      exit(1);
    }
  }

  try {
    if (serversToStart.length == validTypes.length) {
      await launcher.startAllServers();
      print('All servers started.');
    } else {
      for (final type in serversToStart) {
        final port = type == 'downsyncs'
            ? kDownsyncsPort
            : type == 'outsyncs'
                ? kOutsyncsPort
                : kCloudStoragePort;
        await launcher.startServer(type, port);
        print('$type server started on port $port.');
      }
    }

    print('\nPress Ctrl+C to stop the servers');
    ProcessSignal.sigint.watch().listen((_) async {
      print('\nShutting down servers...');
      await launcher.stopAllServers();
      exit(0);
    });

    // Keep the servers running
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
    }
  } catch (e) {
    print('Error starting servers: $e');
    exit(1);
  }
}
