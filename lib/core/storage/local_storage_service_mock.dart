import 'dart:io';

class LocalStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance =>
      _instance ??= LocalStorageService._();

  LocalStorageService._();

  bool _initialized = false;
  int _nextId = 1;
  final Map<int, Map<String, dynamic>> _changes = {};

  Future<void> initialize() async {
    if (_initialized) return;

    // Create local directory for database
    final dir = Directory('./isar_db');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    _initialized = true;
    print('[LocalStorage] Service initialized at: ${dir.path}');
  }

  // Mock implementations for the change log service
  Future<Map<String, dynamic>> createChange(
      Map<String, dynamic> changeData) async {
    final now = DateTime.now();
    final id = _nextId++;
    final change = {
      'id': id,
      'entityType': changeData['entityType'],
      'operation': changeData['operation'],
      'timestamp': now.toIso8601String(),
      'entityId': changeData['entityId'],
      'data': changeData['data'],
    };

    _changes[id] = change;
    print('[LocalStorage] Created change: $id');
    return change;
  }

  Future<Map<String, dynamic>?> getChange(int id) async {
    return _changes[id];
  }

  Future<List<Map<String, dynamic>>> getAllChanges() async {
    return _changes.values.toList()
      ..sort((a, b) => DateTime.parse(b['timestamp'])
          .compareTo(DateTime.parse(a['timestamp'])));
  }

  Future<List<Map<String, dynamic>>> getChangesWithCursor({
    int? cursor,
    int? limit,
    String? entityType,
    String? operation,
    String? entityId,
  }) async {
    // Get all changes sorted by timestamp descending (newest first)
    var changes = _changes.values.toList()
      ..sort((a, b) => DateTime.parse(b['timestamp'])
          .compareTo(DateTime.parse(a['timestamp'])));

    // Apply filters
    if (entityType != null) {
      changes = changes
          .where((change) => change['entityType'] == entityType)
          .toList();
    }
    if (operation != null) {
      changes =
          changes.where((change) => change['operation'] == operation).toList();
    }
    if (entityId != null) {
      changes =
          changes.where((change) => change['entityId'] == entityId).toList();
    }

    // Apply cursor (exclusive starting point)
    if (cursor != null) {
      final cursorIndex =
          changes.indexWhere((change) => change['id'] == cursor);
      if (cursorIndex != -1) {
        changes = changes.sublist(cursorIndex + 1);
      }
    }

    // Apply limit
    if (limit != null && limit > 0 && changes.length > limit) {
      changes = changes.take(limit).toList();
    }

    return changes;
  }

  Future<List<Map<String, dynamic>>> getChangesByEntityType(
      String entityType) async {
    final allChanges = await getAllChanges();
    return allChanges
        .where((change) => change['entityType'] == entityType)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getChangesByOperation(
      String operation) async {
    final allChanges = await getAllChanges();
    return allChanges
        .where((change) => change['operation'] == operation)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getChangesByEntityId(
      String entityId) async {
    final allChanges = await getAllChanges();
    return allChanges
        .where((change) => change['entityId'] == entityId)
        .toList();
  }

  Future<Map<String, dynamic>> updateChange(
      int id, Map<String, dynamic> updateData) async {
    final existing = _changes[id];
    if (existing != null) {
      // Update specific fields
      if (updateData.containsKey('operation'))
        existing['operation'] = updateData['operation'];
      if (updateData.containsKey('entityType'))
        existing['entityType'] = updateData['entityType'];
      if (updateData.containsKey('entityId'))
        existing['entityId'] = updateData['entityId'];
      if (updateData.containsKey('data')) existing['data'] = updateData['data'];

      existing['timestamp'] = DateTime.now().toIso8601String();
      print('[LocalStorage] Updated change: $id');
      return existing;
    }
    throw Exception('Change not found');
  }

  Future<bool> deleteChange(int id) async {
    final removed = _changes.remove(id);
    if (removed != null) {
      print('[LocalStorage] Deleted change: $id');
      return true;
    }
    return false;
  }

  Future<int> getChangeCount() async {
    return _changes.length;
  }

  Future<Map<String, int>> getChangeStats() async {
    final changes = await getAllChanges();
    final stats = <String, int>{
      'total': changes.length,
      'creates': 0,
      'updates': 0,
      'deletes': 0,
    };

    for (final change in changes) {
      final operation = change['operation'] as String;
      if (stats.containsKey('${operation}s')) {
        stats['${operation}s'] = (stats['${operation}s'] ?? 0) + 1;
      }
    }

    return stats;
  }

  Future<Map<String, int>> getEntityTypeStats() async {
    final changes = await getAllChanges();
    final stats = <String, int>{};

    for (final change in changes) {
      final entityType = change['entityType'] as String;
      stats[entityType] = (stats[entityType] ?? 0) + 1;
    }

    return stats;
  }

  Future<void> close() async {
    _initialized = false;
    print('[LocalStorage] Service closed');
  }
}
