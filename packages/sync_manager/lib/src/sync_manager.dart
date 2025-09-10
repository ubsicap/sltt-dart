import 'package:dio/dio.dart';
import 'package:sltt_core/sltt_core.dart';

import 'isar_storage_service.dart';

class SyncManager {
  static SyncManager? _instance;
  static SyncManager get instance => _instance ??= SyncManager._();

  SyncManager._();

  final Dio _dio = Dio();
  final OutsyncsStorageService _outsyncsStorage =
      OutsyncsStorageService.instance;

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
      final changesToSync = await _outsyncsStorage.getChangesForSync();

      if (changesToSync.isEmpty) {
        print('[SyncManager] No changes to outsync');
        return OutsyncResult(
          success: true,
          changeSummary: null,
          deletedLocalChanges: [],
          message: 'No changes to sync',
        );
      }

      print('[SyncManager] Found ${changesToSync.length} changes to outsync');

      // Send changes to cloud storage
      final response = await _dio.post(
        '$_cloudStorageUrl/api/changes',
        data: changesToSync.map((c) => c.toJson()).toList(),
      );

      if (response.statusCode == 200) {
        final summary = ChangeProcessingSummary.fromJson(response.data);
        final cidsSynced = summary.processed;

        if (cidsSynced.isNotEmpty) {
          // Immediately delete the outsynced changes to clean up local storage
          print(
            '[SyncManager] Successfully outsynced ${cidsSynced.length} changes to cloud',
          );
          print(
            '[SyncManager] Deleting outsynced changes from local storage...',
          );

          final deletedCount = await _outsyncsStorage.deleteChanges(cidsSynced);
          print(
            '[SyncManager] Deleted $deletedCount outsynced changes from local storage',
          );

          return OutsyncResult(
            success: true,
            message: 'Successfully outsynced ${cidsSynced.length} changes',
            changeSummary: summary,
            deletedLocalChanges: cidsSynced,
          );
        } else {
          // Handle partial failure

          print('[SyncManager] Partial outsync nothing processed');

          return OutsyncResult(
            success: false,
            message: 'Partial nothing processed',
            changeSummary: summary,
            deletedLocalChanges: [],
            error: 'Partial nothing processed',
            errorStackTrace: null,
          );
        }
      } else {
        final errorBody = response.data;
        throw Exception(
          'Outsync failed with status: ${response.statusCode}, body: $errorBody',
        );
      }
    } catch (e, stackTrace) {
      print('[SyncManager] Outsync failed: $e');
      print('[SyncManager] Stack trace: $stackTrace');
      return OutsyncResult(
        success: false,
        changeSummary: null,
        deletedLocalChanges: [],
        message: 'Outsync failed: $e',
        error: e.toString(), // Capture original error
        errorStackTrace: stackTrace
            .toString(), // Include error stack for debugging
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
      final projects = (responseData['projects'] as List<dynamic>)
          .cast<String>();
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

        // Get the last sync state for this specific project
        final syncState = await _outsyncsStorage.getSyncState(projectId);
        int lastSeq = syncState?.lastSeq ?? 0;
        print('[SyncManager] Starting from seq: $lastSeq');

        String? cursor = lastSeq.toString();
        int totalChangesForProject = 0;
        int highestSeqForProject =
            lastSeq; // Track highest sequence for this project

        // Continue fetching with cursor until no more changes
        do {
          final encodedProjectId = Uri.encodeComponent(projectId);
          final url =
              '$_cloudStorageUrl/api/projects/$encodedProjectId/changes?cursor=$cursor';

          final response = await _dio.get(url);

          if (response.statusCode == 200) {
            // TODO Deserialize response data
            final responseData = response.data as Map<String, dynamic>;
            final srcStorageId = responseData['storageId'] as String? ?? 'cloud';
            final changesBatch = responseData['changes'] as List<dynamic>;
            final nextCursor = responseData['cursor'] as int?;

            if (changesBatch.isEmpty) {
              print('[SyncManager] No more changes for project $projectId');
              break;
            }

            // Apply changes directly to state storage without storing in downsyncs
            final newChanges = changesBatch
                .cast<Map<String, dynamic>>()
                .toList();

            // Apply changes directly to state storage
            await ChangeProcessingService.processChanges(changesToCreate: changesToCreate, storage: _outsyncsStorage, srcStorageType: 'cloud', srcStorageId: srcStorageId, storageMode: storageMode, includeChangeUpdates: includeChangeUpdates, includeStateUpdates: includeStateUpdates)

            allNewChanges.addAll(newChanges);
            totalChangesForProject += newChanges.length;

            // Track the highest sequence number for this project
            for (final change in newChanges) {
              final seq = change['seq'] as int;
              if (seq > highestSeqForProject) {
                highestSeqForProject = seq;
              }
            }

            print(
              '[SyncManager] Applied ${newChanges.length} changes for project $projectId (batch)',
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

        // Update sync state for this project if we processed any changes
        if (totalChangesForProject > 0) {
          await _outsyncsStorage.upsertSyncState(
            projectId,
            lastSeq: highestSeqForProject,
            lastChangeAt: DateTime.now().toUtc(),
          );
          print(
            '[SyncManager] Updated sync state for project $projectId: lastSeq=$highestSeqForProject',
          );
        }
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

    // Use the already computed deleted local sequences from outsync result
    final finalOutsyncResult = OutsyncResult(
      success: outsyncResult.success,
      changeUpdates: outsyncResult.changeUpdates,
      deletedLocalChanges: outsyncResult.deletedLocalChanges,
      seqMap: outsyncResult.seqMap,
      message: outsyncResult.message,
      error: outsyncResult.error,
      errorStackTrace: outsyncResult.errorStackTrace,
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
        cloudCount: cloudCount,
        lastSyncTime:
            DateTime.now(), // In a real implementation, this would be persisted
      );
    } catch (e) {
      print('[SyncManager] Failed to get sync status: $e');
      return SyncStatus(
        outsyncsCount: 0,
        cloudCount: 0,
        lastSyncTime: DateTime.now(),
      );
    }
  }

  /// Clear all sync states (useful for testing)
  Future<void> clearAllSyncStates() async {
    await _outsyncsStorage.clearAllSyncStates();
  }

  Future<void> close() async {
    if (_initialized) {
      await _outsyncsStorage.close();
      _initialized = false;
      print('[SyncManager] Closed');
    }
  }
}

// Result classes
class OutsyncResult {
  final bool success;
  ChangeProcessingSummary? changeSummary;
  final List<String> deletedLocalChanges;
  final String message;
  final String? error; // Optional error for debugging
  final String? errorStackTrace;

  OutsyncResult({
    required this.success,
    required this.changeSummary,
    required this.deletedLocalChanges,
    required this.message,
    this.error,
    this.errorStackTrace,
  });

  Map<String, dynamic> toJson() => {
    'success': success,
    'changeSummary': changeSummary.toJson(),
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
  final int cloudCount;
  final DateTime lastSyncTime;

  SyncStatus({
    required this.outsyncsCount,
    required this.cloudCount,
    required this.lastSyncTime,
  });

  Map<String, dynamic> toJson() => {
    'outsyncsCount': outsyncsCount,
    'cloudCount': cloudCount,
    'lastSyncTime': lastSyncTime.toIso8601String(),
  };
}
