import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';

import '../models/change_log_entry.dart';
import 'base_storage_service.dart';

class LocalStorageService implements BaseStorageService {
  final String _databaseName;
  final String _logPrefix;

  late Isar _isar;
  bool _initialized = false;

  LocalStorageService(this._databaseName, this._logPrefix);

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    // Create local directory for database
    final dir = Directory('./isar_db');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Initialize Isar with the specified database name
    _isar = await Isar.open(
      [ChangeLogEntrySchema],
      directory: dir.path,
      name: _databaseName,
    );

    _initialized = true;
    print(
      '[$_logPrefix] Isar database initialized at: ${dir.path}/$_databaseName.isar',
    );
  }

  /// Create a new change log entry in the storage.
  ///
  /// Returns the created change log entry with auto-generated sequence number.
  @override
  Future<Map<String, dynamic>> createChange(
    Map<String, dynamic> changeData,
  ) async {
    final change = ChangeLogEntry(
      projectId: changeData['projectId'] ?? '',
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

  @override
  Future<Map<String, dynamic>?> getChange(String projectId, int seq) async {
    final change = await _isar.changeLogEntrys
        .where()
        .seqEqualTo(seq)
        .filter()
        .projectIdEqualTo(projectId)
        .findFirst();
    return change?.toJson();
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
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _isar.changeLogEntrys
        .filter()
        .timestampBetween(startDate, endDate)
        .sortByTimestampDesc()
        .findAll();
  }

  /// Get the total count of change log entries.
  Future<int> getChangeCount() async {
    return await _isar.changeLogEntrys.count();
  }

  /// Delete multiple changes by sequence numbers.
  ///
  /// Used for cleanup after successful outsync operations.
  /// Returns the number of changes actually deleted.
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
  @override
  Future<Map<String, dynamic>> getChangeStats(String projectId) async {
    final total = await _isar.changeLogEntrys
        .filter()
        .projectIdEqualTo(projectId)
        .count();
    final creates = await _isar.changeLogEntrys
        .filter()
        .projectIdEqualTo(projectId)
        .and()
        .operationEqualTo('create')
        .count();
    final updates = await _isar.changeLogEntrys
        .filter()
        .projectIdEqualTo(projectId)
        .and()
        .operationEqualTo('update')
        .count();
    final deletes = await _isar.changeLogEntrys
        .filter()
        .projectIdEqualTo(projectId)
        .and()
        .operationEqualTo('delete')
        .count();

    return {
      'total': total,
      'creates': creates,
      'updates': updates,
      'deletes': deletes,
    };
  }

  @override
  Future<Map<String, dynamic>> getEntityTypeStats(String projectId) async {
    final allEntries = await _isar.changeLogEntrys
        .filter()
        .projectIdEqualTo(projectId)
        .findAll();
    final stats = <String, int>{};

    for (final entry in allEntries) {
      stats[entry.entityType] = (stats[entry.entityType] ?? 0) + 1;
    }

    return stats;
  }

  @override
  Future<void> close() async {
    if (_initialized) {
      await _isar.close();
      _initialized = false;
      print('[$_logPrefix] Isar database closed');
    }
  }

  /// Delete outdated changes to save storage space.
  ///
  /// This removes change log entries that have been marked as outdated
  /// by newer changes, helping to keep the storage size manageable.
  Future<int> deleteOutdatedChanges() async {
    final outdatedChanges = await _isar.changeLogEntrys
        .filter()
        .outdatedByIsNotNull()
        .findAll();
    final seqsToDelete = outdatedChanges.map((e) => e.seq).toList();

    int deletedCount = 0;
    await _isar.writeTxn(() async {
      for (final seq in seqsToDelete) {
        if (await _isar.changeLogEntrys.delete(seq)) {
          deletedCount++;
        }
      }
    });

    return deletedCount;
  }

  // Cursor-based pagination and filtering
  @override
  Future<List<Map<String, dynamic>>> getChangesWithCursor({
    required String projectId,
    int? cursor,
    int? limit,
  }) async {
    var query = _isar.changeLogEntrys
        .where()
        .seqGreaterThan(cursor ?? 0)
        .filter()
        .projectIdEqualTo(projectId);

    var results = await query.findAll();
    if (limit != null && results.length > limit) {
      results = results.sublist(0, limit);
    }
    return results.map((e) => e.toJson()).toList();
  }

  /// Get changes for syncing - excludes outdated changes.
  ///
  /// Returns only changes that haven't been marked as outdated,
  /// which prevents syncing obsolete change log entries.
  @override
  Future<List<Map<String, dynamic>>> getChangesNotOutdated(
    String projectId,
  ) async {
    var results = await _isar.changeLogEntrys
        .where()
        .filter()
        .projectIdEqualTo(projectId)
        .and()
        .outdatedByIsNull()
        .findAll();
    return results.map((e) => e.toJson()).toList();
  }

  /// Get changes for syncing - excludes outdated changes.
  ///
  /// Returns only changes that haven't been marked as outdated,
  /// which prevents syncing obsolete change log entries.
  Future<List<Map<String, dynamic>>> getChangesForSync({
    int? cursor,
    int? limit,
  }) async {
    var query = _isar.changeLogEntrys.where();
    var results = await query
        .seqGreaterThan(cursor ?? 0)
        .filter()
        .outdatedByIsNull()
        .findAll();
    if (limit != null && results.length > limit) {
      results = results.sublist(0, limit);
    }
    return results.map((e) => e.toJson()).toList();
  }

  /// Mark a change as outdated by another change.
  ///
  /// Updates the outdatedBy field to indicate this change has been
  /// superseded by a newer change with the specified sequence number.
  @override
  Future<void> markAsOutdated(int seq, int outdatedBySeq) async {
    await _isar.writeTxn(() async {
      final change = await _isar.changeLogEntrys.get(seq);
      if (change != null) {
        change.outdatedBy = outdatedBySeq;
        await _isar.changeLogEntrys.put(change);
      }
    });
  }

  // Get the highest sequence number in the database
  Future<int> getLastSeq() async {
    final result = await _isar.changeLogEntrys.where().findAll();
    if (result.isEmpty) {
      return 0;
    }
    return result.map((e) => e.seq).reduce((a, b) => a > b ? a : b);
  }

  // Get changes since a specific sequence number (for syncing)
  @override
  Future<List<Map<String, dynamic>>> getChangesSince(
    String projectId,
    int seq,
  ) async {
    final results = await _isar.changeLogEntrys
        .where()
        .seqGreaterThan(seq)
        .filter()
        .projectIdEqualTo(projectId)
        .findAll();
    // Sort by seq in ascending order
    results.sort((a, b) => a.seq.compareTo(b.seq));
    return results.map((e) => e.toJson()).toList();
  }

  // Store multiple changes (for batch operations)
  Future<List<Map<String, dynamic>>> createChanges(
    List<Map<String, dynamic>> changesData,
  ) async {
    final changes = changesData
        .map(
          (changeData) => ChangeLogEntry(
            projectId: changeData['projectId'] ?? '',
            entityType: changeData['entityType'] ?? '',
            operation: changeData['operation'] ?? '',
            timestamp: DateTime.now(),
            entityId: changeData['entityId'] ?? '',
            dataJson: jsonEncode(changeData['data'] ?? {}),
          ),
        )
        .toList();

    await _isar.writeTxn(() async {
      await _isar.changeLogEntrys.putAll(changes);
    });

    return changes.map((e) => e.toJson()).toList();
  }

  /// Get all unique project IDs from changes with entityType 'project'
  @override
  Future<List<String>> getAllProjects() async {
    final projectChanges = await _isar.changeLogEntrys
        .filter()
        .entityTypeEqualTo('project')
        .findAll();

    // Extract unique project IDs
    final projectIds = <String>{};
    for (final change in projectChanges) {
      if (change.projectId.isNotEmpty) {
        projectIds.add(change.projectId);
      }
    }

    return projectIds.toList()..sort();
  }
}

// Singleton wrappers for each storage type
class OutsyncsStorageService extends LocalStorageService {
  static OutsyncsStorageService? _instance;
  static OutsyncsStorageService get instance =>
      _instance ??= OutsyncsStorageService._();

  OutsyncsStorageService._() : super('outsyncs', 'OutsyncsStorage');
}

class DownsyncsStorageService extends LocalStorageService {
  static DownsyncsStorageService? _instance;
  static DownsyncsStorageService get instance =>
      _instance ??= DownsyncsStorageService._();

  DownsyncsStorageService._() : super('downsyncs', 'DownsyncsStorage');
}

class CloudStorageService extends LocalStorageService {
  static CloudStorageService? _instance;
  static CloudStorageService get instance =>
      _instance ??= CloudStorageService._();

  CloudStorageService._() : super('cloud_storage', 'CloudStorage');
}
