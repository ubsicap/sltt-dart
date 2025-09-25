import 'dart:io';

import 'package:sync_manager/sync_manager.dart';

void main(List<String> args) async {
  final launcher = MultiServerLauncher.instance;
  final syncManager = SyncManager.instance;

  if (args.isEmpty) {
    print('Usage: dart bin/server_runner.dart <command> [options]');
    print('Commands:');
    print('  start-all              - Start all three servers');
    print(
      '  start <type>           - Start specific storage server (local, cloud)',
    );
    print('  stop-all               - Stop all servers');
    print('  stop <type>            - Stop specific server');
    print('  status                 - Show server status');
    print('  sync                   - Perform full sync');
    print('  outsync                 - Perform outsync only');
    print('  downsync               - Perform downsync only');
    print('  sync-status            - Show sync status');
    return;
  }

  final command = args[0].toLowerCase();

  try {
    switch (command) {
      case 'start-all':
        await launcher.startAllServers();
        print('All servers started. Press Ctrl+C to stop.');

        // Keep the servers running
        ProcessSignal.sigint.watch().listen((signal) async {
          print('\nShutting down servers...');
          await launcher.stopAllServers();
          exit(0);
        });

        // Keep the process alive
        while (true) {
          await Future.delayed(const Duration(seconds: 1));
        }

      case 'start':
        if (args.length < 2) {
          print('Usage: dart bin/server_runner.dart start <type>');
          print('Types: local, cloud');
          return;
        }

        final storageType = args[1];
        final port = _getDefaultPort(storageType);
        final parsedStorageType = StorageType.values.byName(
          storageType.toLowerCase(),
        );
        await launcher.startServer(parsedStorageType, port);
        print(
          '$storageType server started on port $port. Press Ctrl+C to stop.',
        );

        ProcessSignal.sigint.watch().listen((signal) async {
          print('\nShutting down $storageType server...');
          await launcher.stopServer(parsedStorageType);
          exit(0);
        });

        while (true) {
          await Future.delayed(const Duration(seconds: 1));
        }

      case 'stop-all':
        await launcher.stopAllServers();
        break;

      case 'stop':
        if (args.length < 2) {
          print('Usage: dart bin/server_runner.dart stop <type>');
          return;
        }
        final storageType = args[1];
        final parsedStorageType = StorageType.values.byName(
          storageType.toLowerCase(),
        );
        await launcher.stopServer(parsedStorageType);
        break;

      case 'status':
        final status = launcher.getServerStatus();
        final addresses = launcher.getServerAddresses();

        print('Server Status:');
        print(
          '  Local: ${status['local']! ? 'Running' : 'Stopped'} ${addresses['local'] ?? ''}',
        );
        print(
          '  Cloud: ${status['cloud']! ? 'Running' : 'Stopped'} ${addresses['cloud'] ?? ''}',
        );
        break;

      case 'sync':
        await syncManager.initialize();
        print('Performing full sync...');
        final result = await syncManager.performFullSync();
        print('Sync result: ${result.toJson()}');
        await syncManager.close();
        break;

      case 'outsync':
        await syncManager.initialize();
        print('Performing outsync...');
        final result = await syncManager.outsyncToCloud();
        print('Outsync result: ${result.toJson()}');
        await syncManager.close();
        break;

      case 'downsync':
        await syncManager.initialize();
        print('Performing downsync...');
        final result = await syncManager.downsyncFromCloud();
        print('Downsync result: ${result.toJson()}');
        await syncManager.close();
        break;

      case 'sync-status':
        await syncManager.initialize();
        final syncedProjects = await syncManager.getSyncedProjects();
        print('Synced Projects: $syncedProjects');
        for (final projectId in syncedProjects) {
          final status = await syncManager.getSyncStatus(projectId);
          print('Project $projectId Sync Status: ${status.toJson()}');
        }
        await syncManager.close();
        break;

      default:
        print('Unknown command: $command');
        print(
          'Use "dart bin/server_runner.dart" without arguments to see usage.',
        );
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

int _getDefaultPort(String storageType) {
  switch (storageType) {
    case 'local':
      return kLocalStoragePort;
    case 'cloud':
      return kCloudStoragePort;
    default:
      return 8283;
  }
}
