import 'dart:convert';
import 'base_entity.dart';

class Document with BaseEntityMixin {
  late String title;
  late String content;
  String? mediaPath;
  late String type; // e.g., 'note', 'task', 'image', etc.
  Map<String, dynamic> metadata = {};
  
  Document({
    required this.title,
    required this.content,
    required this.type,
    this.mediaPath,
    Map<String, dynamic>? metadata,
  }) {
    this.metadata = metadata ?? {};
    initializeEntity();
  }
  
  Document.empty() {
    title = '';
    content = '';
    type = 'note';
    metadata = {};
    initializeEntity();
  }
  
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'title': title,
      'content': content,
      'type': type,
      'mediaPath': mediaPath,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus.name,
      'lastSyncedAt': lastSyncedAt,
    };
  }
  
  static Document fromJson(Map<String, dynamic> json) {
    final doc = Document(
      title: json['title'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      mediaPath: json['mediaPath'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
    
    doc.uuid = json['uuid'] as String;
    doc.createdAt = DateTime.parse(json['createdAt'] as String);
    doc.updatedAt = DateTime.parse(json['updatedAt'] as String);
    doc.lastSyncedAt = json['lastSyncedAt'] as String?;
    
    // Parse sync status
    final statusName = json['syncStatus'] as String?;
    if (statusName != null) {
      doc.syncStatus = SyncStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => SyncStatus.local,
      );
    }
    
    return doc;
  }
}
