import 'dart:async';
import '../storage/local_storage_service.dart';
import '../models/document.dart';
import '../models/base_entity.dart';
import 'sync_providers.dart';

class SyncManager {
  static SyncManager? _instance;
  static SyncManager get instance => _instance ??= SyncManager._();
  
  SyncManager._();
  
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final LANSyncProvider _lanProvider = LANSyncProvider();
  final CloudSyncProvider _cloudProvider = CloudSyncProvider();
  
  Timer? _syncTimer;
  bool _isInitialized = false;
  bool _isSyncing = false;
  
  final StreamController<SyncStatus> _syncStatusController = 
      StreamController<SyncStatus>.broadcast();
  
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('[SyncManager] Initializing sync manager...');
    
    // Initialize providers
    await Future.wait([
      _lanProvider.initialize(),
      _cloudProvider.initialize(),
    ]);
    
    // Start periodic sync
    _startPeriodicSync();
    
    _isInitialized = true;
    print('[SyncManager] Sync manager initialized');
  }
  
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncPendingChanges();
    });
  }
  
  Future<void> syncPendingChanges() async {
    if (_isSyncing) {
      print('[SyncManager] Sync already in progress, skipping...');
      return;
    }
    
    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);
    
    try {
      print('[SyncManager] Starting sync of pending changes...');
      
      // Get all pending documents
      final pendingDocs = await _localStorage.getPendingSyncDocuments();
      print('[SyncManager] Found ${pendingDocs.length} pending documents');
      
      if (pendingDocs.isEmpty) {
        print('[SyncManager] No pending changes to sync');
        return;
      }
      
      // Sync to LAN if available
      if (await _lanProvider.isAvailable()) {
        print('[SyncManager] LAN is available, syncing...');
        for (final doc in pendingDocs) {
          try {
            await _lanProvider.syncDocument(doc);
            await _localStorage.markDocumentSynced(doc.uuid, SyncTarget.lan);
          } catch (e) {
            print('[SyncManager] Failed to sync ${doc.uuid} to LAN: $e');
          }
        }
      } else {
        print('[SyncManager] LAN is not available');
      }
      
      // Sync to cloud if available
      if (await _cloudProvider.isAvailable()) {
        print('[SyncManager] Cloud is available, syncing...');
        for (final doc in pendingDocs) {
          try {
            await _cloudProvider.syncDocument(doc);
            await _localStorage.markDocumentSynced(doc.uuid, SyncTarget.cloud);
          } catch (e) {
            print('[SyncManager] Failed to sync ${doc.uuid} to cloud: $e');
          }
        }
      } else {
        print('[SyncManager] Cloud is not available');
      }
      
      // Fetch updates from providers
      await _fetchUpdatesFromProviders();
      
      print('[SyncManager] Sync completed successfully');
      _syncStatusController.add(SyncStatus.synced);
      
    } catch (e) {
      print('[SyncManager] Sync failed: $e');
      _syncStatusController.add(SyncStatus.conflict);
    } finally {
      _isSyncing = false;
    }
  }
  
  Future<void> _fetchUpdatesFromProviders() async {
    final lastSyncTime = DateTime.now().subtract(const Duration(hours: 24)); // TODO: Store actual last sync time
    
    // Fetch from LAN
    if (await _lanProvider.isAvailable()) {
      try {
        final lanUpdates = await _lanProvider.getUpdatedDocuments(lastSyncTime);
        await _mergeUpdates(lanUpdates, SyncTarget.lan);
      } catch (e) {
        print('[SyncManager] Failed to fetch LAN updates: $e');
      }
    }
    
    // Fetch from cloud
    if (await _cloudProvider.isAvailable()) {
      try {
        final cloudUpdates = await _cloudProvider.getUpdatedDocuments(lastSyncTime);
        await _mergeUpdates(cloudUpdates, SyncTarget.cloud);
      } catch (e) {
        print('[SyncManager] Failed to fetch cloud updates: $e');
      }
    }
  }
  
  Future<void> _mergeUpdates(List<Document> updates, SyncTarget source) async {
    for (final update in updates) {
      final existing = await _localStorage.getDocument(update.uuid);
      
      if (existing == null) {
        // New document, just save it
        await _localStorage.createDocument(update);
        print('[SyncManager] Added new document ${update.uuid} from $source');
      } else {
        // Check for conflicts
        if (existing.updatedAt.isAfter(update.updatedAt)) {
          // Local version is newer, mark as conflict
          existing.syncStatus = SyncStatus.conflict;
          await _localStorage.updateDocument(existing);
          print('[SyncManager] Conflict detected for document ${update.uuid}');
        } else {
          // Remote version is newer or same, update local
          update.syncStatus = SyncStatus.synced;
          await _localStorage.updateDocument(update);
          print('[SyncManager] Updated document ${update.uuid} from $source');
        }
      }
    }
  }
  
  Future<void> syncDocument(String uuid) async {
    final document = await _localStorage.getDocument(uuid);
    if (document == null) {
      throw ArgumentError('Document with UUID $uuid not found');
    }
    
    // Mark as pending and trigger sync
    document.markUpdated();
    await _localStorage.updateDocument(document);
    
    // Trigger immediate sync for this document
    await syncPendingChanges();
  }
  
  Future<Map<String, dynamic>> getSyncStatus() async {
    final stats = await _localStorage.getSyncStats();
    final lanAvailable = await _lanProvider.isAvailable();
    final cloudAvailable = await _cloudProvider.isAvailable();
    
    return {
      'isInitialized': _isInitialized,
      'isSyncing': _isSyncing,
      'lanAvailable': lanAvailable,
      'cloudAvailable': cloudAvailable,
      'documentStats': stats,
      'lastSyncAttempt': DateTime.now().toIso8601String(), // TODO: Store actual timestamp
    };
  }
  
  Future<void> dispose() async {
    print('[SyncManager] Disposing sync manager...');
    
    _syncTimer?.cancel();
    _syncTimer = null;
    
    await Future.wait([
      _lanProvider.dispose(),
      _cloudProvider.dispose(),
    ]);
    
    await _syncStatusController.close();
    
    _isInitialized = false;
    _isSyncing = false;
    
    print('[SyncManager] Sync manager disposed');
  }
}
