import 'dart:convert';
import 'dart:math';

import 'entity_type.dart';

/// Abstract base class for ChangeLogEntry without Isar dependencies
/// Can be used by backend services that don't need Isar
abstract class BaseChangeLogEntry {
  int seq = -9223372036854775808; // Default to Isar.autoIncrement equivalent
  String projectId; // Project identifier for multi-tenancy
  EntityType entityType; // Normalized entity type
  String operation; // e.g., 'create', 'update', 'delete'
  DateTime changeAt; // When the change was originally made by the client
  String entityId; // UUID or primary key of the entity
  String dataJson; // JSON-encoded entity data
  int? outdatedBy; // id of the change that this entry is outdated by
  DateTime? cloudAt; // When the cloud storage received this change (optional)
  String
  cid; // unique id for changeLogEntry: YYYY-mmdd-HHMMss-sss±HHmm-{4-character-random}

  Map<String, dynamic> get data => jsonDecode(dataJson);
  set data(Map<String, dynamic> value) => dataJson = jsonEncode(value);

  BaseChangeLogEntry({
    required this.projectId,
    required this.entityType,
    required this.operation,
    required this.changeAt,
    required this.entityId,
    required this.dataJson,
    this.outdatedBy,
    this.cloudAt,
    String? cid,
  }) : cid = cid ?? generateCid();

  BaseChangeLogEntry.empty()
    : projectId = '',
      entityType = EntityType.document,
      operation = '',
      changeAt = DateTime.now(),
      entityId = '',
      dataJson = '',
      cid = generateCid();

  /// Generates a unique CID (Change ID) in format: YYYY-mmdd-HHMMss-sss±HHmm-{4-character-random}
  static String generateCid([DateTime? timestamp]) {
    final now = timestamp ?? DateTime.now();
    final utc = now.toUtc();

    // Format: YYYY-mmdd-HHMMss-sss
    final datePart =
        '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}${utc.day.toString().padLeft(2, '0')}-'
        '${utc.hour.toString().padLeft(2, '0')}${utc.minute.toString().padLeft(2, '0')}${utc.second.toString().padLeft(2, '0')}-'
        '${utc.millisecond.toString().padLeft(3, '0')}';

    // Timezone offset: ±HHmm
    final offset = now.timeZoneOffset;
    final offsetSign = offset.isNegative ? '-' : '+';
    final offsetHours = offset.inHours.abs().toString().padLeft(2, '0');
    final offsetMinutes = (offset.inMinutes.abs() % 60).toString().padLeft(
      2,
      '0',
    );
    final timezonePart = '$offsetSign$offsetHours$offsetMinutes';

    // 4-character random part
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final randomPart = String.fromCharCodes(
      Iterable.generate(
        4,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );

    return '$datePart$timezonePart-$randomPart';
  }

  Map<String, dynamic> toJson() {
    return {
      'seq': seq,
      'projectId': projectId,
      'entityType': entityType.value,
      'operation': operation,
      'changeAt': changeAt.toUtc().toIso8601String(),
      'entityId': entityId,
      'data': data,
      'outdatedBy': outdatedBy,
      'cloudAt': cloudAt?.toIso8601String(),
      'cid': cid,
    };
  }

  static BaseChangeLogEntry fromJson(Map<String, dynamic> json) {
    final entry = ChangeLogEntry(
      projectId: json['projectId'] as String,
      entityType: EntityType.fromString(json['entityType'] as String),
      operation: json['operation'] as String,
      changeAt: DateTime.parse(json['changeAt'] as String),
      entityId: json['entityId'] as String,
      dataJson: json['data'] is String
          ? json['data'] as String
          : jsonEncode(json['data']),
      outdatedBy: json['outdatedBy'] as int?,
      cloudAt: json['cloudAt'] != null
          ? DateTime.parse(json['cloudAt'] as String)
          : null,
      cid: json['cid'] as String?,
    );

    if (json['seq'] != null) {
      entry.seq = json['seq'] as int;
    }

    return entry;
  }

  /// Factory method to create BaseChangeLogEntry from API data (Map<String, dynamic>)
  /// Handles proper data conversion and provides defaults for missing fields
  static BaseChangeLogEntry fromApiData(Map<String, dynamic> changeData) {
    final entry = ChangeLogEntry(
      projectId: changeData['projectId'] as String? ?? '',
      entityType:
          EntityType.tryFromString(changeData['entityType'] as String?) ??
          EntityType.document,
      operation: changeData['operation'] as String? ?? 'create',
      changeAt: changeData['changeAt'] != null
          ? DateTime.parse(changeData['changeAt'] as String)
          : DateTime.now().toUtc(),
      entityId: changeData['entityId'] as String? ?? '',
      dataJson: jsonEncode(changeData['data'] ?? {}),
      outdatedBy: changeData['outdatedBy'] as int?,
      cloudAt: changeData['cloudAt'] != null
          ? DateTime.parse(changeData['cloudAt'] as String)
          : null,
      cid: changeData['cid'] as String?,
    );

    // Set the seq field if provided in the API data
    if (changeData['seq'] != null) {
      entry.seq = changeData['seq'] as int;
    }

    return entry;
  }
}

/// Concrete implementation of BaseChangeLogEntry for cases where we need to instantiate it directly
/// Used internally by factory methods and can be used by backend services
class ChangeLogEntry extends BaseChangeLogEntry {
  ChangeLogEntry({
    required super.projectId,
    required super.entityType,
    required super.operation,
    required super.changeAt,
    required super.entityId,
    required super.dataJson,
    super.outdatedBy,
    super.cloudAt,
    super.cid,
  });

  ChangeLogEntry.empty() : super.empty();
}
