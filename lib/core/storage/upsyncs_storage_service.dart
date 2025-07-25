import 'dart:convert';
import 'dart:io';
import 'package:isar/isar.dart';
import '../models/change_log_entry.dart';

class OutsyncsStorageService {
  static OutsyncsStorageService? _instance;
  static OutsyncsStorageService get instance =>
      _instance ??= OutsyncsStorageService._();

  OutsyncsStorageService._();

  late Isar _isar;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Create local directory for database
    final dir = Directory('./isar_db');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Initialize Isar with outsyncs database name
    _isar = await Isar.open(
      [ChangeLogEntrySchema],
      directory: dir.path,
      name: 'outsyncs',
    );

    _initialized = true;
    print('[OutsyncsStorage] Isar database initialized at: ${dir.path}');
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

  Future<ChangeLogEntry?> getChange(int seq) async {
    return await _isar.changeLogEntrys.get(seq);
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
      int seq, Map<String, dynamic> data) async {
    final existing = await _isar.changeLogEntrys.get(seq);
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

  Future<bool> deleteChange(int seq) async {
    return await _isar.writeTxn(() async {
      return await _isar.changeLogEntrys.delete(seq);
    });
  }

  Future<int> getChangeCount() async {
    return await _isar.changeLogEntrys.count();
  }

  // Delete multiple changes by seq numbers (for cleanup after successful outsync)
  Future<int> deleteChanges(List<int> seqs) async {
    int deletedCount = 0;
    await _isar.writeTxn(() async {
      for (final seq in seqs) {
        if (await _isar.changeLogEntrys.delete(seq)) {
          deletedCount++;
        }
      }
    });
    return deletedCount;
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
      print('[OutsyncsStorage] Isar database closed');
    }
  }

  // Cursor-based pagination and filtering
  Future<List<Map<String, dynamic>>> getChangesWithCursor({
    int? cursor,
    int? limit,
  }) async {
    var query = _isar.changeLogEntrys.where();
    var results = await query.seqGreaterThan(cursor ?? 0).findAll();
    if (limit != null && results.length > limit) {
      results = results.sublist(0, limit);
    }
    return results.map((e) => e.toJson()).toList();
  }

  // Get changes since a specific sequence number (for syncing)
  Future<List<Map<String, dynamic>>> getChangesSince(int seq) async {
    final results = await _isar.changeLogEntrys
        .where()
        .seqGreaterThan(seq)
        .findAll();
    // Sort by seq in ascending order
    results.sort((a, b) => a.seq.compareTo(b.seq));
    return results.map((e) => e.toJson()).toList();
  }
}
