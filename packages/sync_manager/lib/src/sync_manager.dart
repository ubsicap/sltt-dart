import 'package:dio/dio.dart';
import 'package:sltt_core/sltt_core.dart';

import 'isar_storage_service.dart';

class SyncManager {
  static SyncManager? _instance;
  static SyncManager get instance => _instance ??= SyncManager._();

  SyncManager._();

  final Dio _dio = Dio();
  final LocalStorageService _localStorage = LocalStorageService.instance;

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

    await _localStorage.initialize();

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
      final changesToSync = await _localStorage.getChangesForSync();

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

          final deletedCount = await _localStorage.deleteChanges(cidsSynced);
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
    ProjectCursorChanges projectCursorChanges = {};
    StorageSummaries storageSummaries = {};
    try {
      print('[SyncManager] Starting downsync from cloud...');

      // First, get all projects from the cloud storage (authoritative source)
      // /api/<domainCollection>', _handleGetDomainIds
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
          projectCursorChanges: {},
          storageSummaries: {},
          message: 'No projects found in cloud to downsync',
        );
      }

      // For each project, downsync its changes with cursor-based pagination
      for (final projectId in projects) {
        print('[SyncManager] Downsyncing project: $projectId');

        // Get the last sync state for this specific project
        final syncState = await _localStorage.getCursorSyncState(projectId);
        int lastSeq = syncState?.seq ?? 0;
        String cid = syncState?.cid ?? '';
        DateTime changeAt =
            syncState?.changeAt ??
            DateTime.fromMillisecondsSinceEpoch(0).toUtc();
        print('[SyncManager] Starting from seq: $lastSeq');

        String? cursor = lastSeq.toString();
        int totalChangesForProject = 0;
        int highestSeqForProject =
            lastSeq; // Track highest sequence for this project
        String srcStorageId = '**TBD**';
        String srcStorageType = '**TBD**';

        // Continue fetching with cursor until no more changes
        do {
          final encodedProjectId = Uri.encodeComponent(projectId);
          // router.get('/api/changes/<domainCollection>/<domainId>', _handleGetChanges);
          final url =
              '$_cloudStorageUrl/api/changes/projects/$encodedProjectId?cursor=$cursor';

          final response = await _dio.get(url);

          srcStorageId = responseData['storageId'];
          srcStorageType = responseData['storageType'];

          if (response.statusCode == 200) {
            // TODO Deserialize response data
            final responseData = response.data as Map<String, dynamic>;
            final changesBatch = responseData['changes'] as List<dynamic>;
            final nextCursor = responseData['cursor'] as int?;
            /*
               final responseData = <String, dynamic>{
                'storageId': storageId,
                'storageType': storageType,
                'changes': changes.map((c) => c.toJson()).toList(),
                'count': changes.length,
                'timestamp': DateTime.now().toIso8601String(),
              };
            */

            if (changesBatch.isEmpty) {
              print('[SyncManager] No more changes for project $projectId');
              break;
            }

            // Apply changes directly to state storage without storing in downsyncs
            final incomingChanges = changesBatch
                .cast<Map<String, dynamic>>()
                .toList();

            projectCursorChanges['$projectId/$cursor'] = incomingChanges;

            // Apply changes directly to state storage
            final results = await ChangeProcessingService.processChanges(
              storageMode: 'sync',
              changes: incomingChanges,
              srcStorageType: srcStorageType,
              srcStorageId: srcStorageId,
              storage: _localStorage,
              includeChangeUpdates: true,
              includeStateUpdates: true,
            );

            storageSummaries['$projectId/$cursor'] = results.resultsSummary;
            totalChangesForProject += incomingChanges.length;

            // Track the highest sequence number for this project
            for (final change in incomingChanges) {
              final seq = change['seq'] as int;
              if (seq > highestSeqForProject) {
                highestSeqForProject = seq;
                cid = change['cid'] as String? ?? '';
                changeAt = DateTime.parse(change['changeAt'] as String);
              } else {
                throw Exception(
                  'Received out-of-order sequence number for project $projectId: $seq <= $highestSeqForProject, (from $_cloudStorageUrl) change:\n$change',
                );
              }
            }

            print(
              '[SyncManager] Applied ${incomingChanges.length} changes for project $projectId (batch)',
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
          await _localStorage.upsertCursorSyncState(
            domainType: 'project',
            domainId: projectId,
            srcStorageType: srcStorageType,
            srcStorageId: srcStorageId,
            seq: highestSeqForProject,
            cid: cid,
            changeAt: changeAt,
          );
          print(
            '[SyncManager] Updated sync state for project $projectId: lastSeq=$highestSeqForProject',
          );
        }
      }

      final totalDownloadedCount = projectCursorChanges.values
          .expand((changes) => changes)
          .length;

      print(
        '[SyncManager] Downsync completed. Total changes: $totalDownloadedCount',
      );

      return DownsyncResult(
        success: true,
        projectCursorChanges: projectCursorChanges,
        storageSummaries: storageSummaries,
        message:
            'Successfully downsynced $totalDownloadedCount changes from ${projects.length} projects',
      );
    } catch (e) {
      print('[SyncManager] Downsync failed: $e');
      return DownsyncResult(
        success: false,
        projectCursorChanges: projectCursorChanges,
        storageSummaries: storageSummaries,
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
      changeSummary: outsyncResult.changeSummary,
      deletedLocalChanges: outsyncResult.deletedLocalChanges,
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
  Future<SyncStatus> getSyncStatus(String domainId) async {
    try {
      final localChangeStats = await _localStorage.getChangeStats(
        domainType: 'project',
        domainId: domainId,
      );
      final outsyncsCount = localChangeStats.totals.total;

      final localEntityStats = await _localStorage.getStateStats(
        domainType: 'project',
        domainId: domainId,
      );

      // Try to get cloud storage stats
      int cloudCount = 0;
      try {
        final response = await _dio.get(
          '$_cloudStorageUrl/api/stats/projects/$domainId',
        );
        if (response.statusCode == 200) {
          final stats = response.data as Map<String, dynamic>;
          /* expect response in form of:
            {
          'projectId': domainId,
          'changeStats': changeStatsJson,
          'entityTypeStats': entityTypeStatsJson,
          'timestamp': DateTime.now().toIso8601String(),
          'storageType': storageTypeDescription,
          }
          */
          final changeStats = EntityTypeStats.fromJson(
            stats['changeStats'] as Map<String, dynamic>,
          );
          final entityTypeStats = EntityTypeStats.fromJson(
            stats['entityTypeStats'] as Map<String, dynamic>,
          );
          cloudCount = changeStats.totals.total;
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
    await _localStorage.clearAllCursorSyncStates();
  }

  Future<void> close() async {
    if (_initialized) {
      await _localStorage.close();
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
    'changeSummary': changeSummary?.toJson(),
    'message': message,
  };
}

typedef ProjectCursorChanges = Map<String, List<Map<String, dynamic>>>;
typedef StorageSummaries = Map<String, ChangeProcessingSummary?>;

class DownsyncResult {
  final bool success;
  final String message;

  /// list of each batch of changes downloaded per cursor request (keyed by $projectId/$cursor)
  final ProjectCursorChanges projectCursorChanges;

  /// list of processing summaries per cursor request (keyed by $projectId/$cursor)
  final StorageSummaries storageSummaries;

  DownsyncResult({
    required this.success,
    required this.message,
    required this.projectCursorChanges,
    required this.storageSummaries,
  });

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'projectCursorChanges': projectCursorChanges,
    'storageSummaries': storageSummaries,
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
