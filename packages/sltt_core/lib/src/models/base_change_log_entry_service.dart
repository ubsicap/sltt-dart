import 'dart:math';

import '../services/json_serialization_service.dart';
import 'entity_type.dart';

/// Helper used when parsing potentially unknown entityType strings
class _EntityTypeOrRaw {
  final EntityType? entityType;
  final String? raw;
  _EntityTypeOrRaw({required this.entityType, required this.raw});
}

_EntityTypeOrRaw _parseEntityType(dynamic raw) {
  if (raw == null) return _EntityTypeOrRaw(entityType: null, raw: null);
  if (raw is String) {
    final parsed = EntityType.tryFromString(raw);
    if (parsed != null) return _EntityTypeOrRaw(entityType: parsed, raw: null);
    return _EntityTypeOrRaw(entityType: null, raw: raw);
  }
  return _EntityTypeOrRaw(entityType: null, raw: raw?.toString());
}

/// Deserialize a BaseChangeLogEntry subclass using the provided factory.
/// If the json['entityType'] can't be parsed, returns an instance with
/// operation='unknownEntityType', entityType=EntityType.unknown and
/// operationInfo capturing the unparseable value.
T deserializeChangeLogEntrySafely<T extends HasUnknownField>(
  T Function(Map<String, dynamic>) fromJson,
  Map<String, dynamic> json,
  Map<String, dynamic> Function(T) baseToJson,
) {
  final parsed = _parseEntityType(json['entityType']);

  if (parsed.entityType == null && parsed.raw != null) {
    final safeJson = Map<String, dynamic>.from(json);
    safeJson['entityType'] = EntityType.unknown.value;
    // Directly set the sentinel operation and record the raw entityType so
    // the entry contains the information needed for later rehydration.
    safeJson['operation'] = 'unknownEntityType';
    safeJson['operationInfo'] = {
      ...(safeJson['operationInfo'] as Map<String, dynamic>? ?? {}),
      'entityType': parsed.raw,
    };
    return deserializeWithUnknownFieldData(fromJson, safeJson, baseToJson);
  }

  return deserializeWithUnknownFieldData(fromJson, json, baseToJson);
}

/// Generates a unique CID (Change ID) in format: YYYY-mmdd-HHMMss-sss±HHmm-{4-character-random}
String generateCid([DateTime? timestamp]) {
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
    Iterable.generate(4, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
  );

  return '$datePart$timezonePart-$randomPart';
}
