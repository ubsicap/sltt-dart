import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/cursor_sync_state.dart';
import 'package:sync_manager/src/models/isar_change_log_entry.dart';

import 'entity_state_pagination_service.dart';
import 'isar_storage_service.dart';

class SyncManager {
  static SyncManager? _instance;
  static SyncManager get instance => _instance ??= SyncManager._();

  SyncManager._();

  final Dio _dio = Dio();
  late final IsarStorageService _localStorage;
  bool _ownsLocalStorage = true;

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
  EntityStatePaginationService? _entityStatePaginationService;

  EntityStatePaginationService get entityStatePaginationService {
    _entityStatePaginationService ??= EntityStatePaginationService(
      baseUrl: _cloudStorageUrl,
    )..startProcessing();
    return _entityStatePaginationService!;
  }

  /// Configure the cloud storage URL (useful for testing with localhost)
  void configureCloudUrl(String cloudUrl) {
    _cloudStorageUrl = cloudUrl;
    _entityStatePaginationService?.updateBaseUrl(cloudUrl);
    SlttLogger.logger.info(
      '[SyncManager] Cloud URL configured to: $_cloudStorageUrl',
    );
  }

  Stream<EntityStateFetchEvent> enqueueJobFetchEntityState({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
    String? parentId,
  }) {
    return entityStatePaginationService.enqueueJobFetchEntityState(
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      entityId: entityId,
      parentId: parentId,
    );
  }

  Stream<EntityStateFetchEvent> enqueueJobFetchEntityStateCollection({
    required String domainType,
    required String domainId,
    required String entityType,
    String? parentId,
    int limit = 100,
    String? cursor,
  }) {
    return entityStatePaginationService.enqueueJobFetchEntityStateCollection(
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      parentId: parentId,
      limit: limit,
      cursor: cursor,
    );
  }

  Future<void> initialize({
    IsarStorageService? localStorage,
    bool closeStorageOnDispose = true,
  }) async {
    if (_initialized) return;

    _localStorage = localStorage ?? LocalStorageService.instance;
    _ownsLocalStorage = closeStorageOnDispose || localStorage == null;
    if (localStorage == null) {
      await _localStorage.initialize();
    }

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

  Map<String, String?> _handleError(
    String context,
    dynamic e,
    StackTrace stackTrace,
  ) {
    final response = (e as dynamic).response;
    if (response != null) {
      SlttLogger.logger.severe(
        '[SyncManager] [$context] [Error ${response.statusCode} (${response.statusMessage})] Error details: $response',
      );
    } else {
      SlttLogger.logger.severe(
        '[SyncManager] [$context] Error details: ${e.toString()}',
      );
    }
    SlttLogger.logger.severe(
      '[SyncManager] [$context] Stack trace: $stackTrace',
    );

    return {
      'error': (e as dynamic).response?.toString() ?? e.toString(),
      'errorStackTrace': stackTrace.toString(),
    };
  }

  String _entityStateKey({
    required String domainType,
    required String domainId,
    required String entityType,
    required String entityId,
  }) {
    return '$domainType/$domainId/$entityType/$entityId';
  }

  String? _extractIncomingStateDataHashWarning(
    Map<String, dynamic> incomingChange,
  ) {
    final operationInfoRaw = incomingChange['operationInfoJson'];
    if (operationInfoRaw == null) {
      return null;
    }

    try {
      dynamic operationInfo;
      if (operationInfoRaw is String && operationInfoRaw.isNotEmpty) {
        operationInfo = jsonDecode(operationInfoRaw);
      } else if (operationInfoRaw is Map) {
        operationInfo = operationInfoRaw;
      }
      if (operationInfo is! Map) {
        return null;
      }

      final warnings = operationInfo['warnings'];
      if (warnings is! Map) {
        return null;
      }

      return warnings['stateDataHash']?.toString();
    } catch (_) {
      return null;
    }
  }

  // Get all projects that have changes to sync

  // Outsync changes from outsyncs to cloud storage
  Future<OutsyncResult> outsyncToCloud({
    List<String>? domainIds,
    String domainType = 'project',
  }) async {
    late final List<IsarChangeLogEntry> changesToSync;
    try {
      SlttLogger.logger.info('[SyncManager] Starting outsync to cloud...');

      // Get changes for sync
      changesToSync = await _localStorage.getChangesForSync(
        domainIds: domainIds,
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
      final handled = _handleError('OutsyncToCloud', e, stackTrace);
      return OutsyncResult(
        success: false,
        changeSummary: null,
        changesRequested: changesToSync,
        deletedLocalChanges: [],
        message: 'Outsync failed: $e',
        error: handled['error'],
        errorStackTrace: handled['errorStackTrace'],
      );
    }
  }

  // Downsync changes from cloud storage to local state
  Future<DownsyncResult> downsyncFromCloud({
    List<String>? domainIds,
    String domainType = 'project',
    Function? onProgress,
  }) async {
    ProjectCursorChanges projectCursorChanges = {};
    StorageSummaries storageSummaries = {};
    final finalStateHashesByKey = <String, _StateHashSnapshot>{};
    final queuedEntityStateFetchKeys = <String>{};
    try {
      final currentStorageId = await _localStorage.getStorageId();
      SlttLogger.logger.info('[SyncManager] Starting downsync from cloud...');

      if (domainIds != null && domainIds.isNotEmpty) {
        SlttLogger.logger.fine(
          '[SyncManager] Downsync limited to specified domainIds: $domainIds',
        );
      } else {
        SlttLogger.logger.info(
          '[SyncManager] Downsyncing all domains of type: $domainType',
        );

        final collection = getCollectionByDomain(domainType);
        if (collection == null) {
          throw ArgumentError('Unknown domainType: $domainType');
        }

        // First, get all domain ids from the cloud storage (authoritative source)
        final response = await _dio.get(
          '$_cloudStorageUrl/api/ids/$collection',
        );
        if (response.statusCode != 200) {
          throw Exception(
            'Failed to get $collection ids from cloud: ${response.statusCode}',
          );
        }

        final responseData = response.data as Map<String, dynamic>;
        final ids = (responseData['items'] as List<dynamic>).cast<String>();
        SlttLogger.logger.info(
          '[SyncManager] Found ${ids.length} $collection ids: $ids',
        );

        if (ids.isEmpty) {
          SlttLogger.logger.info(
            '[SyncManager] No $collection found in cloud to downsync',
          );
          return DownsyncResult(
            success: true,
            projectCursorChanges: {},
            storageSummaries: {},
            message: 'No $collection found in cloud to downsync',
            error: null,
            errorStackTrace: null,
          );
        }
        domainIds = ids.toList();
      }

      // For each project, downsync its changes with cursor-based pagination
      final collection = getCollectionByDomain(domainType) ?? 'projects';
      for (final domainId in domainIds) {
        SlttLogger.logger.info(
          '[SyncManager] Downsyncing $domainType: $domainId',
        );

        // Get the last sync state for this specific project
        final syncState = await _localStorage.getCursorSyncState(domainId);
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
          final encodedDomainId = Uri.encodeComponent(domainId);
          // router.get('/api/changes/<domainCollection>/<domainId>', _handleGetChanges);
          final url =
              '$_cloudStorageUrl/api/changes/$collection/$encodedDomainId?cursor=$cursor';

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
                '[SyncManager] No more changes for $domainType $domainId',
              );
              if (lastSeq < highestSeqForProject) {
                // Update sync state even if no changes were returned
                await _localStorage.upsertCursorSyncState(
                  domainType: domainType,
                  domainId: domainId,
                  srcStorageType: srcStorageType,
                  srcStorageId: srcStorageId,
                  seq: highestSeqForProject,
                  cid: cid,
                  changeAt: changeAt,
                );
                SlttLogger.logger.fine(
                  '[SyncManager] Updated sync state for $domainType $domainId: lastSeq=$highestSeqForProject',
                );
              }
              break;
            }

            // Apply changes directly to state storage without storing in downsyncs
            final incomingChanges = changesBatch
                .cast<Map<String, dynamic>>()
                .toList();
            final changesToApply = incomingChanges
                .where((change) => change['stateChanged'] == true)
                .toList();
            final changesStateFalse = incomingChanges
                .where((change) => change['stateChanged'] != true)
                .toList();
            projectCursorChanges['$domainId/$cursor'] = incomingChanges;
            _updateCloudStateDataHashes(
              incomingChanges: incomingChanges,
              finalStateHashesByKey: finalStateHashesByKey,
              domainTypeContext: domainType,
              domainIdContext: domainId,
            );
            _updateStateChangedFalseStateDataHashes(
              changesStateFalse: changesStateFalse,
              finalStateHashesByKey: finalStateHashesByKey,
              domainTypeContext: domainType,
              domainIdContext: domainId,
              currentStorageId: currentStorageId,
            );

            // Apply only stateChanged=true changes to avoid sync pre-validation
            // rejection for stateChanged=false entries.
            final results = changesToApply.isEmpty
                ? const ChangeProcessingResult(resultsSummary: null)
                : await ChangeProcessingService.storeChanges(
                    storageMode: 'sync',
                    changes: changesToApply,
                    srcStorageType: srcStorageType,
                    srcStorageId: srcStorageId,
                    storage: _localStorage,
                    includeChangeUpdates: true,
                    includeStateUpdates: true,
                  );

            // TODO: how to handle more gracefully so we don't get stuck?
            if (results.isError) {
              final error =
                  'Downsync processing error for $domainType $domainId: '
                  '${results.errorMessage}'
                  '${const JsonEncoder.withIndent('  ').convert(results.resultsSummary?.toJson())}';
              SlttLogger.logger.severe(error);
              return DownsyncResult(
                success: false,
                projectCursorChanges: projectCursorChanges,
                storageSummaries: storageSummaries,
                message: 'Downsync processing error for $domainType $domainId',
                error: error,
                errorStackTrace: null,
              );
            }

            storageSummaries['$domainId/$cursor'] = results.resultsSummary;
            _updateLocalStateDataHashes(
              stateUpdates: results.resultsSummary?.stateUpdates ?? const [],
              finalStateHashesByKey: finalStateHashesByKey,
              domainTypeContext: domainType,
              domainIdContext: domainId,
            );

            totalChangesForProject += incomingChanges.length;

            SlttLogger.logger.info(
              '[SyncManager] Downloaded ${incomingChanges.length} changes for $domainType $domainId (batch); applied ${changesToApply.length}',
            );

            // Update sync state for this project if we processed any changes
            if (totalChangesForProject > 0) {
              await _localStorage.upsertCursorSyncState(
                domainType: domainType,
                domainId: domainId,
                srcStorageType: srcStorageType,
                srcStorageId: srcStorageId,
                seq: highestSeqForProject,
                cid: cid,
                changeAt: changeAt,
              );
              SlttLogger.logger.fine(
                '[SyncManager] Updated sync state for $domainType $domainId: lastSeq=$highestSeqForProject',
              );
            }

            onProgress?.call(
              domainId,
              totalChangesForProject + incomingChanges.length,
            );

            // Update cursor for next iteration
            cursor = nextCursor.toString();
          } else {
            SlttLogger.logger.warning(
              '[SyncManager] Failed to downsync $domainType $domainId: ${response.statusCode}',
            );
            break; // Exit cursor loop for this project
          }
        } while (hasMore);
        SlttLogger.logger.info(
          '[SyncManager] Completed downsyncing $domainType $domainId: $totalChangesForProject total changes',
        );
      }
      final totalDownloadedCount = projectCursorChanges.values
          .expand((changes) => changes)
          .length;
      SlttLogger.logger.info(
        '[SyncManager] Downsync completed. Total changes: $totalDownloadedCount',
      );

      final mismatchCount = _queueMismatchedEntityStateRefetches(
        finalStateHashesByKey: finalStateHashesByKey,
        queuedEntityStateFetchKeys: queuedEntityStateFetchKeys,
      );

      if (mismatchCount > 0) {
        SlttLogger.logger.warning(
          '[SyncManager] Downsync hash reconciliation found $mismatchCount mismatched entity state hash(es); queued targeted state refetch.',
        );
      }

      return DownsyncResult(
        success: true,
        projectCursorChanges: projectCursorChanges,
        storageSummaries: storageSummaries,
        message:
            'Successfully downsynced $totalDownloadedCount changes from ${domainIds.length} $domainType(s)',
        error: null,
        errorStackTrace: null,
      );
    } catch (e, stackTrace) {
      final handled = _handleError('DownsyncFromCloud', e, stackTrace);
      return DownsyncResult(
        success: false,
        projectCursorChanges: projectCursorChanges,
        storageSummaries: storageSummaries,
        message: 'Downsync failed: $e',
        error: handled['error'],
        errorStackTrace: handled['errorStackTrace'],
      );
    }
  }

  // Perform full sync: outsync first, then downsync
  Future<FullSyncResult> performFullSync({
    List<String>? domainIds,
    String domainType = 'project',
  }) async {
    SlttLogger.logger.info('[SyncManager] Starting full sync...');

    // Step 1: Outsync to cloud (deletes local changes immediately)
    final outsyncResult = await outsyncToCloud(
      domainIds: domainIds,
      domainType: domainType,
    );

    // Step 2: Downsync from cloud
    final downsyncResult = await downsyncFromCloud(
      domainIds: domainIds,
      domainType: domainType,
    );

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

  Future<List<String>> getSyncedDomainIds({
    String domainType = 'project',
  }) async {
    final ids = await _localStorage.getAllDomainIds(domainType: domainType);
    return ids;
  }

  // Backwards-compatible wrapper
  Future<List<String>> getSyncedProjects() async =>
      getSyncedDomainIds(domainType: 'project');

  // Check sync status and statistics
  Future<SyncStatus> getSyncStatus(
    String domainId, {
    String domainType = 'project',
  }) async {
    try {
      final localChangeStats = await _localStorage.getChangeStats(
        domainType: domainType,
        domainId: domainId,
      );

      final localStateStats = await _localStorage.getStateStats(
        domainType: domainType,
        domainId: domainId,
      );

      final localCursorState = await _localStorage.getCursorSyncState(domainId);

      // Try to get cloud storage stats
      EntityTypeSummary? cloudChangeStats;
      EntityTypeStats? cloudStateStats;
      try {
        final collection = getCollectionByDomain(domainType) ?? 'projects';
        final response = await _dio.get(
          '$_cloudStorageUrl/api/stats/$collection/$domainId',
        );
        if (response.statusCode == 200) {
          final stats = response.data as Map<String, dynamic>;
          final ps = DomainStatsResponse.fromJson(stats);
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
        localCursorState: localCursorState,
        cloudChangeStats: cloudChangeStats,
        cloudStateStats: cloudStateStats,
      );
    } catch (e) {
      SlttLogger.logger.severe('[SyncManager] Failed to get sync status: $e');
      return SyncStatus(
        localChangeStats: null,
        localStateStats: null,
        localCursorState: null,
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
      _entityStatePaginationService?.dispose();
      _entityStatePaginationService = null;

      if (_ownsLocalStorage) {
        await _localStorage.close();
      }
      _initialized = false;
      _instance = null;
      SlttLogger.logger.info('[SyncManager] Closed');
    }
  }

  void _updateCloudStateDataHashes({
    required List<Map<String, dynamic>> incomingChanges,
    required Map<String, _StateHashSnapshot> finalStateHashesByKey,
    required String domainTypeContext,
    required String domainIdContext,
  }) {
    for (final incomingChange in incomingChanges) {
      final cloudStateDataHash = incomingChange['stateDataHash']?.toString();
      final updateKeys = _extractUpdateKeysFromChange(
        incomingChange,
        domainTypeContext: domainTypeContext,
        domainIdContext: domainIdContext,
        reason: 'malformed incoming change during downsync hash reconciliation',
      );
      if (updateKeys == null) continue;

      final updateDomainType = updateKeys['domainType']!;
      final updateDomainId = updateKeys['domainId']!;
      final updateEntityType = updateKeys['entityType']!;
      final updateEntityId = updateKeys['entityId']!;

      final key = _entityStateKey(
        domainType: updateDomainType,
        domainId: updateDomainId,
        entityType: updateEntityType,
        entityId: updateEntityId,
      );

      final previous = finalStateHashesByKey[key];
      finalStateHashesByKey[key] = _StateHashSnapshot(
        domainType: updateDomainType,
        domainId: updateDomainId,
        entityType: updateEntityType,
        entityId: updateEntityId,
        parentId: incomingChange['parentId']?.toString() ?? previous?.parentId,
        cloudStateDataHash: cloudStateDataHash ?? previous?.cloudStateDataHash,
        localStateDataHash: previous?.localStateDataHash,
      );
    }
  }

  void _updateLocalStateDataHashes({
    required List<Map<String, dynamic>> stateUpdates,
    required Map<String, _StateHashSnapshot> finalStateHashesByKey,
    required String domainTypeContext,
    required String domainIdContext,
  }) {
    for (final stateUpdate in stateUpdates) {
      final updateKeys = _extractUpdateKeysFromChange(
        stateUpdate,
        domainTypeContext: domainTypeContext,
        domainIdContext: domainIdContext,
        reason: 'malformed state update during downsync',
      );
      if (updateKeys == null) continue;

      final updateDomainType = updateKeys['domainType']!;
      final updateDomainId = updateKeys['domainId']!;
      final updateEntityType = updateKeys['entityType']!;
      final updateEntityId = updateKeys['entityId']!;

      final key = _entityStateKey(
        domainType: updateDomainType,
        domainId: updateDomainId,
        entityType: updateEntityType,
        entityId: updateEntityId,
      );
      final previous = finalStateHashesByKey[key];
      finalStateHashesByKey[key] = _StateHashSnapshot(
        domainType: updateDomainType,
        domainId: updateDomainId,
        entityType: updateEntityType,
        entityId: updateEntityId,
        parentId: stateUpdate['parentId']?.toString() ?? previous?.parentId,
        cloudStateDataHash: previous?.cloudStateDataHash,
        localStateDataHash: stateUpdate['stateDataHash']?.toString(),
      );
    }
  }

  void _updateStateChangedFalseStateDataHashes({
    required List<Map<String, dynamic>> changesStateFalse,
    required Map<String, _StateHashSnapshot> finalStateHashesByKey,
    required String domainTypeContext,
    required String domainIdContext,
    required String currentStorageId,
  }) {
    for (final incomingChange in changesStateFalse) {
      final warningStateDataHash = _extractIncomingStateDataHashWarning(
        incomingChange,
      );
      if (warningStateDataHash == null || warningStateDataHash.isEmpty) {
        continue;
      }

      final updateKeys = _extractUpdateKeysFromChange(
        incomingChange,
        domainTypeContext: domainTypeContext,
        domainIdContext: domainIdContext,
        reason:
            'malformed stateChanged=false change during warning-based reconciliation',
      );
      if (updateKeys == null) continue;

      final updateDomainType = updateKeys['domainType']!;
      final updateDomainId = updateKeys['domainId']!;
      final updateEntityType = updateKeys['entityType']!;
      final updateEntityId = updateKeys['entityId']!;

      final key = _entityStateKey(
        domainType: updateDomainType,
        domainId: updateDomainId,
        entityType: updateEntityType,
        entityId: updateEntityId,
      );
      final previous = finalStateHashesByKey[key];
      final incomingStorageId = incomingChange['storageId']?.toString();

      // TODO(lan-local-team-storage): revisit this when clients can share
      // changes across storage ids. At that point, prefer sender stateDataHash
      // lookup by CID rather than requiring storageId match.
      final trustedLocalStateDataHash = incomingStorageId == currentStorageId
          ? warningStateDataHash
          : previous?.localStateDataHash;

      finalStateHashesByKey[key] = _StateHashSnapshot(
        domainType: updateDomainType,
        domainId: updateDomainId,
        entityType: updateEntityType,
        entityId: updateEntityId,
        parentId: incomingChange['parentId']?.toString() ?? previous?.parentId,
        cloudStateDataHash:
            previous?.cloudStateDataHash ??
            incomingChange['stateDataHash']?.toString(),
        localStateDataHash: trustedLocalStateDataHash,
      );
    }
  }

  int _queueMismatchedEntityStateRefetches({
    required Map<String, _StateHashSnapshot> finalStateHashesByKey,
    required Set<String> queuedEntityStateFetchKeys,
  }) {
    var mismatchCount = 0;
    for (final snapshot in finalStateHashesByKey.values) {
      final cloudStateDataHash = snapshot.cloudStateDataHash;
      final localStateDataHash = snapshot.localStateDataHash;
      if (cloudStateDataHash != null &&
          localStateDataHash != null &&
          localStateDataHash != cloudStateDataHash) {
        mismatchCount++;
        final key = _entityStateKey(
          domainType: snapshot.domainType,
          domainId: snapshot.domainId,
          entityType: snapshot.entityType,
          entityId: snapshot.entityId,
        );
        if (queuedEntityStateFetchKeys.add(key)) {
          enqueueJobFetchEntityState(
            domainType: snapshot.domainType,
            domainId: snapshot.domainId,
            entityType: snapshot.entityType,
            entityId: snapshot.entityId,
            parentId: snapshot.parentId,
          );
        }
      }
    }

    return mismatchCount;
  }

  Map<String, String>? _extractUpdateKeysFromChange(
    Map<String, dynamic> change, {
    required String domainTypeContext,
    required String domainIdContext,
    required String reason,
  }) {
    final updateDomainType = change['domainType']?.toString();
    final updateDomainId = change['domainId']?.toString();
    final updateEntityType = change['entityType']?.toString();
    final updateEntityId = change['entityId']?.toString();
    if (updateDomainType == null ||
        updateDomainId == null ||
        updateEntityType == null ||
        updateEntityId == null) {
      SlttLogger.logger.warning(
        '[SyncManager] Skipping $reason for $domainTypeContext $domainIdContext: $change',
      );
      return null;
    }
    return {
      'domainType': updateDomainType,
      'domainId': updateDomainId,
      'entityType': updateEntityType,
      'entityId': updateEntityId,
    };
  }
}

class _StateHashSnapshot {
  final String domainType;
  final String domainId;
  final String entityType;
  final String entityId;
  final String? parentId;
  final String? cloudStateDataHash;
  final String? localStateDataHash;

  const _StateHashSnapshot({
    required this.domainType,
    required this.domainId,
    required this.entityType,
    required this.entityId,
    required this.parentId,
    required this.cloudStateDataHash,
    required this.localStateDataHash,
  });
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
  final CursorSyncState? localCursorState;
  final EntityTypeSummary? cloudChangeStats;
  final EntityTypeStats? cloudStateStats;

  SyncStatus({
    required this.localChangeStats,
    required this.localStateStats,
    required this.localCursorState,
    required this.cloudChangeStats,
    required this.cloudStateStats,
  });

  factory SyncStatus.fromJson(Map<String, dynamic> json) => SyncStatus(
    localChangeStats: json['localChangeStats'] != null
        ? EntityTypeStats.fromJson(json['localChangeStats'])
        : null,
    localStateStats: json['localStateStats'] != null
        ? EntityTypeStats.fromJson(json['localStateStats'])
        : null,
    localCursorState: json['localCursorState'] != null
        ? CursorSyncState.fromJson(json['localCursorState'])
        : null,
    cloudChangeStats: json['cloudChangeStats'] != null
        ? EntityTypeSummary.fromJson(json['cloudChangeStats'])
        : null,
    cloudStateStats: json['cloudStateStats'] != null
        ? EntityTypeStats.fromJson(json['cloudStateStats'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'localChangeStats': localChangeStats?.toJson(),
    'localStateStats': localStateStats?.toJson(),
    'localCursorState': localCursorState?.toJson(),
    'cloudChangeStats': cloudChangeStats?.toJson(),
    'cloudStateStats': cloudStateStats?.toJson(),
  };
}
