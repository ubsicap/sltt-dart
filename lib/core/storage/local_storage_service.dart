import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import '../models/base_entity.dart';
import '../models/document.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance => _instance ??= LocalStorageService._();
  
  LocalStorageService._();
  
  late Isar _isar;
  bool _initialized = false;
  
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Create local directory for database
    final dir = Directory('./isar_db');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    // Initialize Isar
    _isar = await Isar.open(
      [DocumentSchema],
      directory: dir.path,
      name: 'local_storage',
    );
    
    _initialized = true;
    print('[LocalStorage] Isar database initialized at: ${dir.path}');
  }
  
  // Document operations
  Future<Document> createDocument(Document document) async {
    return await _isar.writeTxn(() async {
      await _isar.documents.put(document);
      return document;
    });
  }
  
  Future<Document?> getDocument(String uuid) async {
    return await _isar.documents.filter().uuidEqualTo(uuid).findFirst();
  }
  
  Future<List<Document>> getAllDocuments() async {
    return await _isar.documents.where().findAll();
  }
  
  Future<List<Document>> getDocumentsByType(String type) async {
    return await _isar.documents.filter().typeEqualTo(type).findAll();
  }
  
  Future<List<Document>> getPendingSyncDocuments() async {
    return await _isar.documents.filter().syncStatusEqualTo(SyncStatus.pending).findAll();
  }
  
  Future<Document> updateDocument(Document document) async {
    return await _isar.writeTxn(() async {
      document.markUpdated();
      await _isar.documents.put(document);
      return document;
    });
  }
  
  Future<bool> deleteDocument(String uuid) async {
    return await _isar.writeTxn(() async {
      final document = await _isar.documents.filter().uuidEqualTo(uuid).findFirst();
      if (document != null) {
        await _isar.documents.delete(document.id);
        return true;
      }
      return false;
    });
  }
  
  Future<void> markDocumentSynced(String uuid, SyncTarget target) async {
    await _isar.writeTxn(() async {
      final document = await _isar.documents.filter().uuidEqualTo(uuid).findFirst();
      if (document != null) {
        document.markSynced(target);
        await _isar.documents.put(document);
      }
    });
  }
  
  Future<int> getDocumentCount() async {
    return await _isar.documents.count();
  }
  
  Future<List<Document>> searchDocuments(String query) async {
    final lowerQuery = query.toLowerCase();
    return await _isar.documents.filter()
        .titleContains(lowerQuery, caseSensitive: false)
        .or()
        .contentContains(lowerQuery, caseSensitive: false)
        .findAll();
  }
  
  // Sync status operations
  Future<Map<String, int>> getSyncStats() async {
    final total = await _isar.documents.count();
    final pending = await _isar.documents.filter().syncStatusEqualTo(SyncStatus.pending).count();
    final synced = await _isar.documents.filter().syncStatusEqualTo(SyncStatus.synced).count();
    final conflicts = await _isar.documents.filter().syncStatusEqualTo(SyncStatus.conflict).count();
    final local = await _isar.documents.filter().syncStatusEqualTo(SyncStatus.local).count();
    
    return {
      'total': total,
      'pending': pending,
      'synced': synced,
      'conflicts': conflicts,
      'local': local,
    };
  }
  
  Future<void> close() async {
    if (_initialized) {
      await _isar.close();
      _initialized = false;
      print('[LocalStorage] Isar database closed');
    }
  }
}
