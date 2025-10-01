import 'dart:io';

import 'package:sltt_core/src/logging.dart';
import 'package:sync_manager/sync_manager.dart';

void main(List<String> args) async {
  final launcher = MultiServerLauncher.instance;
  final syncManager = SyncManager.instance;

  if (args.isEmpty) {
    SlttLogger.logger.info(
      'Usage: dart bin/server_runner.dart <command> [options]',
    );
    SlttLogger.logger.info('Commands:');
    SlttLogger.logger.info(
      '  start-all              - Start all three servers',
    );
    SlttLogger.logger.info(
      '  start <type>           - Start specific storage server (local, cloud)',
    );
    SlttLogger.logger.info('  stop-all               - Stop all servers');
    SlttLogger.logger.info('  stop <type>            - Stop specific server');
    SlttLogger.logger.info('  status                 - Show server status');
    SlttLogger.logger.info('  sync                   - Perform full sync');
    SlttLogger.logger.info('  outsync                 - Perform outsync only');
    SlttLogger.logger.info('  downsync               - Perform downsync only');
    SlttLogger.logger.info('  sync-status            - Show sync status');
    return;
  }

  final command = args[0].toLowerCase();

  try {
    switch (command) {
      case 'start-all':
        await launcher.startAllServers();
        SlttLogger.logger.info('All servers started. Press Ctrl+C to stop.');

        // Keep the servers running
        ProcessSignal.sigint.watch().listen((signal) async {
          SlttLogger.logger.info('\nShutting down servers...');
          await launcher.stopAllServers();
          exit(0);
        });

        // Keep the process alive
        while (true) {
          await Future.delayed(const Duration(seconds: 1));
        }

      case 'start':
        if (args.length < 2) {
          SlttLogger.logger.info(
            'Usage: dart bin/server_runner.dart start <type>',
          );
          SlttLogger.logger.info('Types: local, cloud');
          return;
        }

        final storageType = args[1];
        final port = _getDefaultPort(storageType);
        final parsedStorageType = StorageType.values.byName(
          storageType.toLowerCase(),
        );
        await launcher.startServer(parsedStorageType, port);
        SlttLogger.logger.info(
          '$storageType server started on port $port. Press Ctrl+C to stop.',
        );

        ProcessSignal.sigint.watch().listen((signal) async {
          SlttLogger.logger.info('\nShutting down $storageType server...');
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
          SlttLogger.logger.info(
            'Usage: dart bin/server_runner.dart stop <type>',
          );
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

        SlttLogger.logger.info('Server Status:');
        SlttLogger.logger.info(
          '  Local: ${status['local']! ? 'Running' : 'Stopped'} ${addresses['local'] ?? ''}',
        );
        SlttLogger.logger.info(
          '  Cloud: ${status['cloud']! ? 'Running' : 'Stopped'} ${addresses['cloud'] ?? ''}',
        );
        break;

      case 'sync':
        await syncManager.initialize();
        SlttLogger.logger.info('Performing full sync...');
        final result = await syncManager.performFullSync();
        SlttLogger.logger.info('Sync result: ${result.toJson()}');
        await syncManager.close();
        break;

      case 'outsync':
        await syncManager.initialize();
        SlttLogger.logger.info('Performing outsync...');
        final result = await syncManager.outsyncToCloud();
        SlttLogger.logger.info('Outsync result: ${result.toJson()}');
        await syncManager.close();
        break;

      case 'downsync':
        await syncManager.initialize();
        SlttLogger.logger.info('Performing downsync...');
        final result = await syncManager.downsyncFromCloud();
        SlttLogger.logger.info('Downsync result: ${result.toJson()}');
        await syncManager.close();
        break;

      case 'sync-status':
        await syncManager.initialize();
        final syncedProjects = await syncManager.getSyncedProjects();
        SlttLogger.logger.info('Synced Projects: $syncedProjects');
        for (final projectId in syncedProjects) {
          final status = await syncManager.getSyncStatus(projectId);
          SlttLogger.logger.info(
            'Project $projectId Sync Status: ${status.toJson()}',
          );
        }
        await syncManager.close();
        break;

      default:
        SlttLogger.logger.warning('Unknown command: $command');
        SlttLogger.logger.info(
          'Use "dart bin/server_runner.dart" without arguments to see usage.',
        );
    }
  } catch (e) {
    SlttLogger.logger.severe('Error: $e');
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
