import 'dart:convert';
import 'dart:io';
import '../models/base_entity.dart';
import '../models/document.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance => _instance ??= LocalStorageService._();
  
  LocalStorageService._();
  
  late File _dataFile;
  List<Document> _documents = [];
  
  Future<void> initialize() async {
    // Create local directory for database
    final dir = Directory('./data');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    _dataFile = File('./data/documents.json');
    await _loadDocuments();
  }
  
  Future<void> _loadDocuments() async {
    if (await _dataFile.exists()) {
      try {
        final content = await _dataFile.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _documents = jsonList.map((json) => Document.fromJson(json)).toList();
      } catch (e) {
        print('Error loading documents: $e');
        _documents = [];
      }
    }
  }
  
  Future<void> _saveDocuments() async {
    final jsonList = _documents.map((doc) => doc.toJson()).toList();
    await _dataFile.writeAsString(jsonEncode(jsonList));
  }
  
  // Document operations
  Future<Document> createDocument(Document document) async {
    _documents.add(document);
    await _saveDocuments();
    return document;
  }
  
  Future<Document?> getDocument(String uuid) async {
    try {
      return _documents.firstWhere((doc) => doc.uuid == uuid);
    } catch (e) {
      return null;
    }
  }
  
  Future<List<Document>> getAllDocuments() async {
    return List.from(_documents);
  }
  
  Future<List<Document>> getDocumentsByType(String type) async {
    return _documents.where((doc) => doc.type == type).toList();
  }
  
  Future<List<Document>> getPendingSyncDocuments() async {
    return _documents.where((doc) => doc.syncStatus == SyncStatus.pending).toList();
  }
  
  Future<Document> updateDocument(Document document) async {
    final index = _documents.indexWhere((doc) => doc.uuid == document.uuid);
    if (index != -1) {
      document.markUpdated();
      _documents[index] = document;
      await _saveDocuments();
    }
    return document;
  }
  
  Future<bool> deleteDocument(String uuid) async {
    final index = _documents.indexWhere((doc) => doc.uuid == uuid);
    if (index != -1) {
      _documents.removeAt(index);
      await _saveDocuments();
      return true;
    }
    return false;
  }
  
  Future<void> markDocumentSynced(String uuid, SyncTarget target) async {
    final document = await getDocument(uuid);
    if (document != null) {
      document.markSynced(target);
      await updateDocument(document);
    }
  }
  
  Future<int> getDocumentCount() async {
    return _documents.length;
  }
  
  Future<List<Document>> searchDocuments(String query) async {
    final lowerQuery = query.toLowerCase();
    return _documents.where((doc) =>
      doc.title.toLowerCase().contains(lowerQuery) ||
      doc.content.toLowerCase().contains(lowerQuery)
    ).toList();
  }
  
  // Sync status operations
  Future<Map<String, int>> getSyncStats() async {
    final total = _documents.length;
    final pending = _documents.where((doc) => doc.syncStatus == SyncStatus.pending).length;
    final synced = _documents.where((doc) => doc.syncStatus == SyncStatus.synced).length;
    final conflicts = _documents.where((doc) => doc.syncStatus == SyncStatus.conflict).length;
    final local = _documents.where((doc) => doc.syncStatus == SyncStatus.local).length;
    
    return {
      'total': total,
      'pending': pending,
      'synced': synced,
      'conflicts': conflicts,
      'local': local,
    };
  }
  
  Future<void> close() async {
    await _saveDocuments();
  }
}
