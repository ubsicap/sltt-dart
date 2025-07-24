import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import '../models/change_log_entry.dart';
import '../models/document.dart';

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
      [DocumentSchema],
      directory: dir.path,
      name: 'local_storage',
    );

    _initialized = true;
    print('[LocalStorage] Isar database initialized at: ${dir.path}');
  }

  // Change log operations
  Future<ChangeLogEntry> createChange(ChangeLogEntry change) async {
    return await _isar.writeTxn(() async {
      await _isar.changeLogEntrys.put(change);
      return change;
    });
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

  Future<ChangeLogEntry> updateChange(ChangeLogEntry change) async {
    return await _isar.writeTxn(() async {
      await _isar.changeLogEntrys.put(change);
      return change;
    });
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
}
