import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/isar_change_log_entry.dart';

import 'isar_storage_service.dart';

class SyncManager {
  static SyncManager? _instance;
  static SyncManager get instance => _instance ??= SyncManager._();

  SyncManager._();

  final Dio _dio = Dio();
  late final IsarStorageService _localStorage;

  // API endpoints - defaults to AWS dev cloud, can be overridden for testing
  String _cloudStorageUrl =
      Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;

  bool _initialized = false;

  // Debounced sync state
  Timer? _syncDebounceTimer;
  StreamSubscription<void>? _changeLogSubscription;
  bool _autoOutsyncEnabled = false;

  // Public getters for testing
  bool get autoOutsyncEnabled => _autoOutsyncEnabled;
  StreamSubscription<void>? get changeLogSubscription => _changeLogSubscription;

  /// Configure the cloud storage URL (useful for testing with localhost)
  void configureCloudUrl(String cloudUrl) {
    _cloudStorageUrl = cloudUrl;
    SlttLogger.logger.info(
      '[SyncManager] Cloud URL configured to: $_cloudStorageUrl',
    );
  }

  Future<void> initialize({IsarStorageService? localStorage}) async {
    if (_initialized) return;

    _localStorage = localStorage ?? LocalStorageService.instance;
    await _localStorage.initialize();

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 300);
    _dio.options.sendTimeout = const Duration(seconds: 300);

    _initialized = true;
    SlttLogger.logger.info(
      '[SyncManager] Initialized with cloud URL: $_cloudStorageUrl',
    );
  }

  /// Enable automatic sync when change log entries are modified
  /// Sync is debounced to trigger 500ms after the last change
  void enableAutoOutsync({String? domainType, String? domainId}) {
    if (_autoOutsyncEnabled) {
      SlttLogger.logger.info('[SyncManager] Auto-sync already enabled');
      return;
    }

    _autoOutsyncEnabled = true;
    SlttLogger.logger.info('[SyncManager] Enabling auto-sync with debouncing');

    _changeLogSubscription = _localStorage.lazyListenToChangeLogEntryChanges(
      domainType: domainType,
      domainId: domainId,
      onChanged: _onChangeLogChanged,
      fireImmediately: false,
    );
  }

  /// Disable automatic sync
  void disableAutoOutsync() {
    if (!_autoOutsyncEnabled) return;

    _autoOutsyncEnabled = false;
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = null;
    _changeLogSubscription?.cancel();
    _changeLogSubscription = null;

    SlttLogger.logger.info('[SyncManager] Auto-sync disabled');
  }

  /// Called when change log entries are modified
  void _onChangeLogChanged() {
    // Cancel existing timer if it's running
    _syncDebounceTimer?.cancel();

    // Start a new timer for 500ms
    _syncDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      SlttLogger.logger.info('[SyncManager] Triggering debounced full sync');
      _performDebouncedOutsync();
    });
  }

  /// Perform the actual outsync (called after debounce period)
  void _performDebouncedOutsync() async {
    try {
      await outsyncToCloud();
      SlttLogger.logger.info(
        '[SyncManager] Debounced outsync completed successfully',
      );
    } catch (e, stackTrace) {
      SlttLogger.logger.severe(
        '[SyncManager] Debounced outsync failed: $e',
        e,
        stackTrace,
      );
    }
  }

  // Get all projects that have changes to sync

  // Outsync changes from outsyncs to cloud storage
  Future<OutsyncResult> outsyncToCloud({List<String>? domainIds}) async {
    late final List<IsarChangeLogEntry> changesToSync;
    try {
      SlttLogger.logger.info('[SyncManager] Starting outsync to cloud...');

      // Get changes for sync
      changesToSync = await _localStorage.getChangesForSync(
        limit:
            120 /* 10x (average 4Kb per item) batch writes 12 changes + 12 state updates (25 per-batch write limit) */,
      );

      if (changesToSync.isEmpty) {
        SlttLogger.logger.fine('[SyncManager] No changes to outsync');
        return OutsyncResult(
          success: true,
          changesRequested: changesToSync,
          changeSummary: null,
          deletedLocalChanges: [],
          message: 'No changes to sync',
        );
      }

      SlttLogger.logger.info(
        '[SyncManager] Found ${changesToSync.length} changes to outsync',
      );

      // Send changes to cloud storage using typed API model
      final srcStorageId = await _localStorage.getStorageId();
      final req = CreateChangesRequest(
        changes: changesToSync,
        srcStorageType: 'local',
        srcStorageId: srcStorageId,
        storageMode: 'sync',
        includeChangeUpdates: true,
        includeStateUpdates: true,
      );

      final response = await _dio.post(
        '$_cloudStorageUrl/api/changes',
        data: req.toJson(),
      );

      if (response.statusCode == 200) {
        final summary = ChangeProcessingSummary.fromJson(response.data);
        final cidsSynced = summary.processed;

        if (cidsSynced.isNotEmpty) {
          // Immediately delete the outsynced changes to clean up local storage
          SlttLogger.logger.info(
            '[SyncManager] Successfully outsynced ${cidsSynced.length} changes to cloud',
          );
          SlttLogger.logger.fine(
            '[SyncManager] Deleting outsynced changes from local storage...',
          );

          final deletedCount = await _localStorage.deleteChanges(cidsSynced);
          SlttLogger.logger.info(
            '[SyncManager] Deleted $deletedCount outsynced changes from local storage',
          );

          return OutsyncResult(
            success: true,
            message: 'Successfully outsynced ${cidsSynced.length} changes',
            changesRequested: changesToSync,
            changeSummary: summary,
            deletedLocalChanges: cidsSynced,
          );
        } else {
          // Handle partial failure

          final message =
              '[SyncManager] ### Partial outsync: nothing processed!';
          final error =
              '$message, errors: ${const JsonEncoder.withIndent('  ').convert(summary.errors)}';
          SlttLogger.logger.severe(error);
          return OutsyncResult(
            success: false,
            message: message,
            changesRequested: changesToSync,
            changeSummary: summary,
            deletedLocalChanges: [],
            error: error,
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
      SlttLogger.logger.severe('[SyncManager] Outsync failed: $e');
      SlttLogger.logger.severe('[SyncManager] Stack trace: $stackTrace');
      return OutsyncResult(
        success: false,
        changeSummary: null,
        changesRequested: changesToSync,
        deletedLocalChanges: [],
        message: 'Outsync failed: $e',
        error: e.toString(), // Capture original error
        errorStackTrace: stackTrace
            .toString(), // Include error stack for debugging
      );
    }
  }

  // Downsync changes from cloud storage to local state
  Future<DownsyncResult> downsyncFromCloud({
    List<String>? domainIds,
    Function? onProgress,
  }) async {
    ProjectCursorChanges projectCursorChanges = {};
    StorageSummaries storageSummaries = {};
    try {
      SlttLogger.logger.info('[SyncManager] Starting downsync from cloud...');

      if (domainIds != null && domainIds.isNotEmpty) {
        SlttLogger.logger.fine(
          '[SyncManager] Downsync limited to specified domainIds: $domainIds',
        );
      } else {
        SlttLogger.logger.info('[SyncManager] Downsyncing all projects: ');
        // First, get all projects from the cloud storage (authoritative source)
        // /api/<domainCollection>', _handleGetDomainIds
        final projectsResponse = await _dio.get(
          '$_cloudStorageUrl/api/projects',
        );
        if (projectsResponse.statusCode != 200) {
          throw Exception(
            'Failed to get projects from cloud: ${projectsResponse.statusCode}',
          );
        }

        final projectsResponseData =
            projectsResponse.data as Map<String, dynamic>;
        final projects = (projectsResponseData['items'] as List<dynamic>)
            .cast<String>();
        SlttLogger.logger.info(
          '[SyncManager] Found ${projects.length} projects in cloud: $projects',
        );

        if (projects.isEmpty) {
          SlttLogger.logger.info(
            '[SyncManager] No projects found in cloud to downsync',
          );
          return DownsyncResult(
            success: true,
            projectCursorChanges: {},
            storageSummaries: {},
            message: 'No projects found in cloud to downsync',
            error: null,
            errorStackTrace: null,
          );
        }
        domainIds = projects.toList();
      }

      // For each project, downsync its changes with cursor-based pagination
      for (final projectId in domainIds) {
        SlttLogger.logger.info('[SyncManager] Downsyncing project: $projectId');

        // Get the last sync state for this specific project
        final syncState = await _localStorage.getCursorSyncState(projectId);
        int lastSeq = syncState?.seq ?? 0;
        String cid = syncState?.cid ?? '';
        DateTime changeAt =
            syncState?.changeAt ??
            DateTime.fromMillisecondsSinceEpoch(0).toUtc();
        SlttLogger.logger.fine('[SyncManager] Starting from seq: $lastSeq');

        String? cursor = lastSeq.toString();
        int totalChangesForProject = 0;
        int highestSeqForProject =
            lastSeq; // Track highest sequence for this project
        String srcStorageId = '**TBD**';
        String srcStorageType = '**TBD**';

        bool hasMore = false;
        // Continue fetching with cursor until no more changes
        do {
          final encodedProjectId = Uri.encodeComponent(projectId);
          // router.get('/api/changes/<domainCollection>/<domainId>', _handleGetChanges);
          final url =
              '$_cloudStorageUrl/api/changes/projects/$encodedProjectId?stateChanged=true&cursor=$cursor';

          final response = await _dio.get(url);
          final changesResponseData = response.data as Map<String, dynamic>;

          hasMore = changesResponseData['hasMore'] as bool;
          if (response.statusCode == 200) {
            srcStorageId = changesResponseData['storageId'];
            srcStorageType = changesResponseData['storageType'];
            // TODO Deserialize response data
            final changesBatch =
                changesResponseData['changes'] as List<dynamic>;
            final nextCursor = changesResponseData['cursor'] as int;
            highestSeqForProject = nextCursor;
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
              SlttLogger.logger.fine(
                '[SyncManager] No more changes for project $projectId',
              );
              break;
            }

            // Apply changes directly to state storage without storing in downsyncs
            final incomingChanges = changesBatch
                .cast<Map<String, dynamic>>()
                .toList();

            projectCursorChanges['$projectId/$cursor'] = incomingChanges;

            // Apply changes directly to state storage
            final results = await ChangeProcessingService.storeChanges(
              storageMode: 'sync',
              changes: incomingChanges,
              srcStorageType: srcStorageType,
              srcStorageId: srcStorageId,
              storage: _localStorage,
              includeChangeUpdates: true,
              includeStateUpdates: true,
            );

            onProgress?.call(
              projectId,
              totalChangesForProject + incomingChanges.length,
            );

            // TODO: how to handle more gracefully so we don't get stuck?
            if (results.isError) {
              final error =
                  'Downsync processing error for project $projectId: '
                  '${results.errorMessage}'
                  '${const JsonEncoder.withIndent('  ').convert(results.resultsSummary?.toJson())}';
              SlttLogger.logger.severe(error);
              return DownsyncResult(
                success: false,
                projectCursorChanges: projectCursorChanges,
                storageSummaries: storageSummaries,
                message: 'Downsync processing error for project $projectId',
                error: error,
                errorStackTrace: null,
              );
            }

            storageSummaries['$projectId/$cursor'] = results.resultsSummary;
            totalChangesForProject += incomingChanges.length;

            SlttLogger.logger.info(
              '[SyncManager] Applied ${incomingChanges.length} changes for project $projectId (batch)',
            );

            // Update cursor for next iteration
            cursor = nextCursor.toString();
          } else {
            SlttLogger.logger.warning(
              '[SyncManager] Failed to downsync project $projectId: ${response.statusCode}',
            );
            break; // Exit cursor loop for this project
          }
        } while (hasMore);

        SlttLogger.logger.info(
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
          SlttLogger.logger.fine(
            '[SyncManager] Updated sync state for project $projectId: lastSeq=$highestSeqForProject',
          );
        }
      }

      final totalDownloadedCount = projectCursorChanges.values
          .expand((changes) => changes)
          .length;

      SlttLogger.logger.info(
        '[SyncManager] Downsync completed. Total changes: $totalDownloadedCount',
      );

      return DownsyncResult(
        success: true,
        projectCursorChanges: projectCursorChanges,
        storageSummaries: storageSummaries,
        message:
            'Successfully downsynced $totalDownloadedCount changes from ${domainIds.length} projects',
        error: null,
        errorStackTrace: null,
      );
    } catch (e, stackTrace) {
      SlttLogger.logger.severe('[SyncManager] Downsync failed: $e');
      SlttLogger.logger.severe('[SyncManager] Stack trace: $stackTrace');
      return DownsyncResult(
        success: false,
        projectCursorChanges: projectCursorChanges,
        storageSummaries: storageSummaries,
        message: 'Downsync failed: $e',
        error: e.toString(),
        errorStackTrace: stackTrace.toString(),
      );
    }
  }

  // Perform full sync: outsync first, then downsync
  Future<FullSyncResult> performFullSync({List<String>? domainIds}) async {
    SlttLogger.logger.info('[SyncManager] Starting full sync...');

    // Step 1: Outsync to cloud (deletes local changes immediately)
    final outsyncResult = await outsyncToCloud(domainIds: domainIds);

    // Step 2: Downsync from cloud
    final downsyncResult = await downsyncFromCloud(domainIds: domainIds);

    // Use the already computed deleted local sequences from outsync result
    final finalOutsyncResult = OutsyncResult(
      success: outsyncResult.success,
      changesRequested: outsyncResult.changesRequested,
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

  Future<List<String>> getSyncedProjects() async {
    final projects = await _localStorage.getAllDomainIds(domainType: 'project');
    return projects;
  }

  // Check sync status and statistics
  Future<SyncStatus> getSyncStatus(String projectId) async {
    try {
      final localChangeStats = await _localStorage.getChangeStats(
        domainType: 'project',
        domainId: projectId,
      );

      final localStateStats = await _localStorage.getStateStats(
        domainType: 'project',
        domainId: projectId,
      );

      // Try to get cloud storage stats
      EntityTypeSummary? cloudChangeStats;
      EntityTypeStats? cloudStateStats;
      try {
        final response = await _dio.get(
          '$_cloudStorageUrl/api/stats/projects/$projectId',
        );
        if (response.statusCode == 200) {
          final stats = response.data as Map<String, dynamic>;
          final ps = ProjectStatsResponse.fromJson(stats);
          cloudStateStats = ps.entityTypeStats;
          cloudChangeStats = ps.changeStats;
        }
      } catch (e) {
        SlttLogger.logger.warning(
          '[SyncManager] Could not fetch cloud storage stats: $e',
        );
      }

      return SyncStatus(
        localChangeStats: localChangeStats,
        localStateStats: localStateStats,
        cloudChangeStats: cloudChangeStats,
        cloudStateStats: cloudStateStats,
      );
    } catch (e) {
      SlttLogger.logger.severe('[SyncManager] Failed to get sync status: $e');
      return SyncStatus(
        localChangeStats: null,
        localStateStats: null,
        cloudChangeStats: null,
        cloudStateStats: null,
      );
    }
  }

  /// Clear all sync states (useful for testing)
  Future<void> clearAllSyncStates() async {
    await _localStorage.clearAllCursorSyncStates();
  }

  Future<void> close() async {
    if (_initialized) {
      // Clean up auto-sync resources
      disableAutoOutsync();

      await _localStorage.close();
      _initialized = false;
      _instance = null;
      SlttLogger.logger.info('[SyncManager] Closed');
    }
  }
}

// Result classes
class OutsyncResult {
  final bool success;
  final List<IsarChangeLogEntry> changesRequested;
  ChangeProcessingSummary? changeSummary;
  final List<String> deletedLocalChanges;
  final String message;
  final String? error; // Optional error for debugging
  final String? errorStackTrace;

  OutsyncResult({
    required this.success,
    required this.changesRequested,
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

  /// Optional error details (populated when success == false)
  final String? error;
  final String? errorStackTrace;

  DownsyncResult({
    required this.success,
    required this.message,
    required this.projectCursorChanges,
    required this.storageSummaries,
    this.error,
    this.errorStackTrace,
  });

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'projectCursorChanges': projectCursorChanges,
    'storageSummaries': storageSummaries,
    'error': error,
    'errorStackTrace': errorStackTrace,
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
  final EntityTypeStats? localChangeStats;
  final EntityTypeStats? localStateStats;
  final EntityTypeSummary? cloudChangeStats;
  final EntityTypeStats? cloudStateStats;

  SyncStatus({
    required this.localChangeStats,
    required this.localStateStats,
    required this.cloudChangeStats,
    required this.cloudStateStats,
  });

  Map<String, dynamic> toJson() => {
    'localChangeStats': localChangeStats?.toJson(),
    'localStateStats': localStateStats?.toJson(),
    'cloudChangeStats': cloudChangeStats?.toJson(),
    'cloudStateStats': cloudStateStats?.toJson(),
  };
}
