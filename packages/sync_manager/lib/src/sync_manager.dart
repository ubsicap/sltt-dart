import 'package:dio/dio.dart';
import 'package:sltt_core/sltt_core.dart';

import 'shared_storage_service.dart';

class SyncManager {
  static SyncManager? _instance;
  static SyncManager get instance => _instance ??= SyncManager._();

  SyncManager._();

  final Dio _dio = Dio();
  final OutsyncsStorageService _outsyncsStorage =
      OutsyncsStorageService.instance;
  final DownsyncsStorageService _downsyncsStorage =
      DownsyncsStorageService.instance;

  // API endpoints - defaults to AWS dev cloud, can be overridden for testing
  String _cloudStorageUrl = kCloudDevUrl;

  bool _initialized = false;

  /// Configure the cloud storage URL (useful for testing with localhost)
  void configureCloudUrl(String cloudUrl) {
    _cloudStorageUrl = cloudUrl;
    print('[SyncManager] Cloud URL configured to: $_cloudStorageUrl');
  }

  Future<void> initialize() async {
    if (_initialized) return;

    await _outsyncsStorage.initialize();
    await _downsyncsStorage.initialize();

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _initialized = true;
    print('[SyncManager] Initialized with cloud URL: $_cloudStorageUrl');
  }

  // Get all projects that have changes to sync

  // Outsync changes from outsyncs to cloud storage
  Future<OutsyncResult> outsyncToCloud() async {
    try {
      print('[SyncManager] Starting outsync to cloud...');

      // Get changes for sync (excludes outdated changes)
      final changes = await _outsyncsStorage.getChangesForSync();

      if (changes.isEmpty) {
        print('[SyncManager] No changes to outsync');
        return OutsyncResult(
          success: true,
          syncedChanges: [],
          deletedLocalChanges: [],
          seqMap: {},
          message: 'No changes to sync',
        );
      }

      print('[SyncManager] Found ${changes.length} changes to outsync');

      // Send changes to cloud storage
      final response = await _dio.post(
        '$_cloudStorageUrl/api/changes',
        data: changes,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final success = responseData['success'] as bool;
        final createdCount = responseData['created'] as int;
        final seqMap = Map<String, int>.from(responseData['seqMap'] ?? {});

        if (success) {
          // Immediately delete the outsynced changes to clean up local storage
          print(
            '[SyncManager] Successfully outsynced $createdCount changes to cloud',
          );
          print(
            '[SyncManager] Deleting outsynced changes from local storage...',
          );

          final seqsToDelete = seqMap.keys.map(int.parse).toList();

          if (seqsToDelete.isNotEmpty) {
            final deletedCount = await _outsyncsStorage.deleteChanges(
              seqsToDelete,
            );
            print(
              '[SyncManager] Deleted $deletedCount outsynced changes from local storage',
            );
          }

          return OutsyncResult(
            success: true,
            syncedChanges: [], // No longer return full payload
            deletedLocalChanges: seqsToDelete,
            seqMap: seqMap,
            message: 'Successfully outsynced $createdCount changes',
          );
        } else {
          // Handle partial failure
          final failedAtIndex = responseData['failedAtIndex'] as int?;
          final error = responseData['error'] as String?;

          print(
            '[SyncManager] Partial outsync failed at index $failedAtIndex: $error',
          );

          return OutsyncResult(
            success: false,
            syncedChanges: [],
            deletedLocalChanges: [],
            seqMap: seqMap,
            message: 'Partial outsync failed at index $failedAtIndex: $error',
          );
        }
      } else {
        throw Exception('Outsync failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('[SyncManager] Outsync failed: $e');
      return OutsyncResult(
        success: false,
        syncedChanges: [],
        deletedLocalChanges: [],
        seqMap: {},
        message: 'Outsync failed: $e',
      );
    }
  }

  // Downsync changes from cloud storage to downsyncs
  Future<DownsyncResult> downsyncFromCloud() async {
    try {
      print('[SyncManager] Starting downsync from cloud...');

      // First, get all projects from the cloud storage (authoritative source)
      final projectsResponse = await _dio.get('$_cloudStorageUrl/api/projects');
      if (projectsResponse.statusCode != 200) {
        throw Exception(
          'Failed to get projects from cloud: ${projectsResponse.statusCode}',
        );
      }

      final responseData = projectsResponse.data as Map<String, dynamic>;
      final projects =
          (responseData['projects'] as List<dynamic>).cast<String>();
      print(
        '[SyncManager] Found ${projects.length} projects in cloud: $projects',
      );

      if (projects.isEmpty) {
        print('[SyncManager] No projects found in cloud to downsync');
        return DownsyncResult(
          success: true,
          newChanges: [],
          message: 'No projects found in cloud to downsync',
        );
      }

      final allNewChanges = <Map<String, dynamic>>[];

      // For each project, downsync its changes with cursor-based pagination
      for (final projectId in projects) {
        print('[SyncManager] Downsyncing project: $projectId');

        // Get the last sequence number for this project from downsyncs storage
        int lastSeq = await _downsyncsStorage.getLastSeq();
        print('[SyncManager] Starting from seq: $lastSeq');

        String? cursor = lastSeq.toString();
        int totalChangesForProject = 0;

        // Continue fetching with cursor until no more changes
        do {
          final encodedProjectId = Uri.encodeComponent(projectId);
          final url =
              '$_cloudStorageUrl/api/projects/$encodedProjectId/changes?cursor=$cursor';

          final response = await _dio.get(url);

          if (response.statusCode == 200) {
            final responseData = response.data as Map<String, dynamic>;
            final changesBatch = responseData['changes'] as List<dynamic>;
            final nextCursor = responseData['cursor'] as int?;

            if (changesBatch.isEmpty) {
              print('[SyncManager] No more changes for project $projectId');
              break;
            }

            // Immediately store changes in downsyncs storage for crash recovery
            final newChanges = changesBatch
                .map((c) => c.toJson())
                .cast<Map<String, dynamic>>()
                .toList();
            final storedChanges = await _downsyncsStorage.createChanges(
              newChanges,
            );
            allNewChanges.addAll(storedChanges.map((c) => c.toJson()).toList());
            totalChangesForProject += storedChanges.length;

            print(
              '[SyncManager] Stored ${storedChanges.length} changes for project $projectId (batch)',
            );

            // Update cursor for next iteration
            cursor = nextCursor?.toString();
          } else {
            print(
              '[SyncManager] Failed to downsync project $projectId: ${response.statusCode}',
            );
            break; // Exit cursor loop for this project
          }
        } while (cursor != null);

        print(
          '[SyncManager] Completed downsyncing project $projectId: $totalChangesForProject total changes',
        );
      }

      print(
        '[SyncManager] Downsync completed. Total changes: ${allNewChanges.length}',
      );

      return DownsyncResult(
        success: true,
        newChanges: allNewChanges,
        message:
            'Successfully downsynced ${allNewChanges.length} changes from ${projects.length} projects',
      );
    } catch (e) {
      print('[SyncManager] Downsync failed: $e');
      return DownsyncResult(
        success: false,
        newChanges: [],
        message: 'Downsync failed: $e',
      );
    }
  }

  // Perform full sync: outsync first, then downsync
  Future<FullSyncResult> performFullSync() async {
    print('[SyncManager] Starting full sync...');

    // Step 1: Outsync to cloud (deletes local changes immediately)
    final outsyncResult = await outsyncToCloud();

    // Step 2: Downsync from cloud
    final downsyncResult = await downsyncFromCloud();

    // Create final outsync result with the sequences that were originally outsynced
    final deletedLocalSeqs = outsyncResult.seqMap.keys.map(int.parse).toList();

    final finalOutsyncResult = OutsyncResult(
      success: outsyncResult.success,
      syncedChanges: outsyncResult.syncedChanges,
      deletedLocalChanges: deletedLocalSeqs,
      seqMap: outsyncResult.seqMap,
      message: outsyncResult.message,
    );

    return FullSyncResult(
      outsyncResult: finalOutsyncResult,
      downsyncResult: downsyncResult,
      success: outsyncResult.success && downsyncResult.success,
    );
  }

  // Check sync status and statistics
  Future<SyncStatus> getSyncStatus() async {
    try {
      final outsyncsCount = await _outsyncsStorage.getChangeCount();
      final downsyncsCount = await _downsyncsStorage.getChangeCount();

      // Try to get cloud storage stats
      int cloudCount = 0;
      try {
        final response = await _dio.get('$_cloudStorageUrl/api/stats');
        if (response.statusCode == 200) {
          final stats = response.data as Map<String, dynamic>;
          cloudCount = stats['changeStats']['total'] as int;
        }
      } catch (e) {
        print('[SyncManager] Could not fetch cloud storage stats: $e');
      }

      return SyncStatus(
        outsyncsCount: outsyncsCount,
        downsyncsCount: downsyncsCount,
        cloudCount: cloudCount,
        lastSyncTime:
            DateTime.now(), // In a real implementation, this would be persisted
      );
    } catch (e) {
      print('[SyncManager] Failed to get sync status: $e');
      return SyncStatus(
        outsyncsCount: 0,
        downsyncsCount: 0,
        cloudCount: 0,
        lastSyncTime: DateTime.now(),
      );
    }
  }

  Future<void> close() async {
    if (_initialized) {
      await _outsyncsStorage.close();
      await _downsyncsStorage.close();
      _initialized = false;
      print('[SyncManager] Closed');
    }
  }
}

// Result classes
class OutsyncResult {
  final bool success;
  final List<Map<String, dynamic>> syncedChanges;
  final List<int> deletedLocalChanges;
  final Map<String, int> seqMap; // Maps old seq (as string) to new seq
  final String message;

  OutsyncResult({
    required this.success,
    required this.syncedChanges,
    required this.deletedLocalChanges,
    required this.seqMap,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'success': success,
        'syncedChanges': syncedChanges,
        'deletedLocalChanges': deletedLocalChanges,
        'seqMap': seqMap,
        'message': message,
      };
}

class DownsyncResult {
  final bool success;
  final List<Map<String, dynamic>> newChanges;
  final String message;

  DownsyncResult({
    required this.success,
    required this.newChanges,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'success': success,
        'newChanges': newChanges,
        'message': message,
      };
}

class FullSyncResult {
  final OutsyncResult outsyncResult;
  final DownsyncResult downsyncResult;
  final bool success;

  FullSyncResult({
    required this.outsyncResult,
    required this.downsyncResult,
    required this.success,
  });

  Map<String, dynamic> toJson() => {
        'outsyncResult': outsyncResult.toJson(),
        'downsyncResult': downsyncResult.toJson(),
        'success': success,
      };
}

class SyncStatus {
  final int outsyncsCount;
  final int downsyncsCount;
  final int cloudCount;
  final DateTime lastSyncTime;

  SyncStatus({
    required this.outsyncsCount,
    required this.downsyncsCount,
    required this.cloudCount,
    required this.lastSyncTime,
  });

  Map<String, dynamic> toJson() => {
        'outsyncsCount': outsyncsCount,
        'downsyncsCount': downsyncsCount,
        'cloudCount': cloudCount,
        'lastSyncTime': lastSyncTime.toIso8601String(),
      };
}
