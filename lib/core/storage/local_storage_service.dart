import 'dart:convert';
import 'dart:io';
import 'package:isar/isar.dart';
import '../models/change_log_entry.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance =>
      _instance ??= LocalStorageService._();

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
      [ChangeLogEntrySchema],
      directory: dir.path,
      name: 'local_storage',
    );

    _initialized = true;
    print('[LocalStorage] Isar database initialized at: ${dir.path}');
  }

  // Change log operations
  Future<Map<String, dynamic>> createChange(
      Map<String, dynamic> changeData) async {
    final change = ChangeLogEntry(
      entityType: changeData['entityType'] ?? '',
      operation: changeData['operation'] ?? '',
      timestamp: DateTime.now(),
      entityId: changeData['entityId'] ?? '',
      dataJson: jsonEncode(changeData['data'] ?? {}),
    );
    await _isar.writeTxn(() async {
      await _isar.changeLogEntrys.put(change);
    });
    return change.toJson();
  }

  Future<ChangeLogEntry?> getChange(int id) async {
    return await _isar.changeLogEntrys.get(id);
  }

  Future<List<ChangeLogEntry>> getAllChanges() async {
    return await _isar.changeLogEntrys.where().sortByTimestampDesc().findAll();
  }

  Future<List<ChangeLogEntry>> getChangesByEntityType(String entityType) async {
    return await _isar.changeLogEntrys
        .filter()
        .entityTypeEqualTo(entityType)
        .sortByTimestampDesc()
        .findAll();
  }

  Future<List<ChangeLogEntry>> getChangesByOperation(String operation) async {
    return await _isar.changeLogEntrys
        .filter()
        .operationEqualTo(operation)
        .sortByTimestampDesc()
        .findAll();
  }

  Future<List<ChangeLogEntry>> getChangesByEntityId(String entityId) async {
    return await _isar.changeLogEntrys
        .filter()
        .entityIdEqualTo(entityId)
        .sortByTimestampDesc()
        .findAll();
  }

  Future<List<ChangeLogEntry>> getChangesInDateRange(
      DateTime startDate, DateTime endDate) async {
    return await _isar.changeLogEntrys
        .filter()
        .timestampBetween(startDate, endDate)
        .sortByTimestampDesc()
        .findAll();
  }

  Future<Map<String, dynamic>?> updateChange(
      int id, Map<String, dynamic> data) async {
    final existing = await _isar.changeLogEntrys.get(id);
    if (existing == null) return null;
    if (data.containsKey('entityType'))
      existing.entityType = data['entityType'];
    if (data.containsKey('operation')) existing.operation = data['operation'];
    if (data.containsKey('entityId')) existing.entityId = data['entityId'];
    if (data.containsKey('data'))
      existing.data = Map<String, dynamic>.from(data['data']);
    existing.timestamp = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.changeLogEntrys.put(existing);
    });
    return existing.toJson();
  }

  Future<bool> deleteChange(int id) async {
    return await _isar.writeTxn(() async {
      return await _isar.changeLogEntrys.delete(id);
    });
  }

  Future<int> getChangeCount() async {
    return await _isar.changeLogEntrys.count();
  }

  // Statistics operations
  Future<Map<String, int>> getChangeStats() async {
    final total = await _isar.changeLogEntrys.count();
    final creates =
        await _isar.changeLogEntrys.filter().operationEqualTo('create').count();
    final updates =
        await _isar.changeLogEntrys.filter().operationEqualTo('update').count();
    final deletes =
        await _isar.changeLogEntrys.filter().operationEqualTo('delete').count();

    return {
      'total': total,
      'creates': creates,
      'updates': updates,
      'deletes': deletes,
    };
  }

  Future<Map<String, int>> getEntityTypeStats() async {
    final allEntries = await _isar.changeLogEntrys.where().findAll();
    final stats = <String, int>{};

    for (final entry in allEntries) {
      stats[entry.entityType] = (stats[entry.entityType] ?? 0) + 1;
    }

    return stats;
  }

  Future<void> close() async {
    if (_initialized) {
      await _isar.close();
      _initialized = false;
      print('[LocalStorage] Isar database closed');
    }
  }

  // Cursor-based pagination and filtering
  Future<List<Map<String, dynamic>>> getChangesWithCursor({
    int? cursor,
    int? limit,
  }) async {
    var query = _isar.changeLogEntrys.where();
    var results = await query.idGreaterThan(cursor ?? 0).findAll();
    if (limit != null && results.length > limit) {
      results = results.sublist(0, limit);
    }
    return results.map((e) => e.toJson()).toList();
  }
}
