import 'package:dio/dio.dart';
import '../storage/shared_storage_service.dart';

class SyncManager {
  static SyncManager? _instance;
  static SyncManager get instance => _instance ??= SyncManager._();

  SyncManager._();

  final Dio _dio = Dio();
  final UpsyncsStorageService _upsyncsStorage = UpsyncsStorageService.instance;
  final DownsyncsStorageService _downsyncsStorage = DownsyncsStorageService.instance;

  // API endpoints
  final String _cloudStorageUrl = 'http://localhost:8083';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _upsyncsStorage.initialize();
    await _downsyncsStorage.initialize();

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _initialized = true;
    print('[SyncManager] Initialized');
  }

  // Upsync changes from upsyncs to cloud storage
  Future<UpsyncResult> upsyncToCloud() async {
    try {
      print('[SyncManager] Starting upsync to cloud...');

      // Get all changes from upsyncs storage
      final changes = await _upsyncsStorage.getChangesWithCursor();
      
      if (changes.isEmpty) {
        print('[SyncManager] No changes to upsync');
        return UpsyncResult(
          success: true,
          syncedChanges: [],
          deletedLocalChanges: [],
          message: 'No changes to sync',
        );
      }

      print('[SyncManager] Found ${changes.length} changes to upsync');

      // Send changes to cloud storage using sync endpoint
      final response = await _dio.post(
        '$_cloudStorageUrl/api/changes/sync/0', // Start from seq 0 since we're pushing all changes
        data: changes,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final storedChanges = responseData['storedChanges'] as List<dynamic>;
        
        // Delete successfully synced changes from upsyncs storage
        final seqsToDelete = changes.map((c) => c['seq'] as int).toList();
        final deletedCount = await _upsyncsStorage.deleteChanges(seqsToDelete);

        print('[SyncManager] Successfully upsynced ${storedChanges.length} changes, deleted $deletedCount local changes');

        return UpsyncResult(
          success: true,
          syncedChanges: storedChanges.cast<Map<String, dynamic>>(),
          deletedLocalChanges: seqsToDelete,
          message: 'Successfully upsynced ${storedChanges.length} changes',
        );
      } else {
        throw Exception('Upsync failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('[SyncManager] Upsync failed: $e');
      return UpsyncResult(
        success: false,
        syncedChanges: [],
        deletedLocalChanges: [],
        message: 'Upsync failed: $e',
      );
    }
  }

  // Downsync changes from cloud storage to downsyncs
  Future<DownsyncResult> downsyncFromCloud() async {
    try {
      print('[SyncManager] Starting downsync from cloud...');

      // Get the last sequence number from downsyncs storage
      final lastSeq = await _downsyncsStorage.getLastSeq();
      print('[SyncManager] Last seq in downsyncs: $lastSeq');

      // Request changes from cloud since last seq
      final response = await _dio.post(
        '$_cloudStorageUrl/api/changes/sync/$lastSeq',
        data: [], // Empty array since we're only pulling, not pushing
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final changesSinceSeq = responseData['changesSinceSeq'] as List<dynamic>;

        if (changesSinceSeq.isEmpty) {
          print('[SyncManager] No new changes to downsync');
          return DownsyncResult(
            success: true,
            newChanges: [],
            message: 'No new changes to sync',
          );
        }

        // Store new changes in downsyncs storage
        final newChanges = changesSinceSeq.cast<Map<String, dynamic>>();
        final storedChanges = await _downsyncsStorage.createChanges(newChanges);

        print('[SyncManager] Successfully downsynced ${storedChanges.length} changes');

        return DownsyncResult(
          success: true,
          newChanges: storedChanges,
          message: 'Successfully downsynced ${storedChanges.length} changes',
        );
      } else {
        throw Exception('Downsync failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('[SyncManager] Downsync failed: $e');
      return DownsyncResult(
        success: false,
        newChanges: [],
        message: 'Downsync failed: $e',
      );
    }
  }

  // Perform full sync: upsync first, then downsync
  Future<FullSyncResult> performFullSync() async {
    print('[SyncManager] Starting full sync...');

    final upsyncResult = await upsyncToCloud();
    final downsyncResult = await downsyncFromCloud();

    return FullSyncResult(
      upsyncResult: upsyncResult,
      downsyncResult: downsyncResult,
      success: upsyncResult.success && downsyncResult.success,
    );
  }

  // Check sync status and statistics
  Future<SyncStatus> getSyncStatus() async {
    try {
      final upsyncsCount = await _upsyncsStorage.getChangeCount();
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
        upsyncsCount: upsyncsCount,
        downsyncsCount: downsyncsCount,
        cloudCount: cloudCount,
        lastSyncTime: DateTime.now(), // In a real implementation, this would be persisted
      );
    } catch (e) {
      print('[SyncManager] Failed to get sync status: $e');
      return SyncStatus(
        upsyncsCount: 0,
        downsyncsCount: 0,
        cloudCount: 0,
        lastSyncTime: DateTime.now(),
      );
    }
  }

  Future<void> close() async {
    if (_initialized) {
      await _upsyncsStorage.close();
      await _downsyncsStorage.close();
      _initialized = false;
      print('[SyncManager] Closed');
    }
  }
}

// Result classes
class UpsyncResult {
  final bool success;
  final List<Map<String, dynamic>> syncedChanges;
  final List<int> deletedLocalChanges;
  final String message;

  UpsyncResult({
    required this.success,
    required this.syncedChanges,
    required this.deletedLocalChanges,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
    'success': success,
    'syncedChanges': syncedChanges,
    'deletedLocalChanges': deletedLocalChanges,
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
  final UpsyncResult upsyncResult;
  final DownsyncResult downsyncResult;
  final bool success;

  FullSyncResult({
    required this.upsyncResult,
    required this.downsyncResult,
    required this.success,
  });

  Map<String, dynamic> toJson() => {
    'upsyncResult': upsyncResult.toJson(),
    'downsyncResult': downsyncResult.toJson(),
    'success': success,
  };
}

class SyncStatus {
  final int upsyncsCount;
  final int downsyncsCount;
  final int cloudCount;
  final DateTime lastSyncTime;

  SyncStatus({
    required this.upsyncsCount,
    required this.downsyncsCount,
    required this.cloudCount,
    required this.lastSyncTime,
  });

  Map<String, dynamic> toJson() => {
    'upsyncsCount': upsyncsCount,
    'downsyncsCount': downsyncsCount,
    'cloudCount': cloudCount,
    'lastSyncTime': lastSyncTime.toIso8601String(),
  };
}
