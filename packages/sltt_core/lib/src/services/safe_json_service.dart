import '../services/json_serialization_service.dart';
import '../services/date_time_service.dart';
import '../services/uid_service.dart';

/// Common service for generating safe JSON fallbacks during deserialization recovery.
///
/// This service provides standardized default values for required fields when
/// deserialization fails or when creating safe recovery JSON shapes.
class SafeJsonService {
  /// Generate a safe JSON shape for BaseChangeLogEntry recovery.
  ///
  /// Uses simple fallback values:
  /// - Empty strings for required string fields
  /// - 'unknown' for operation
  /// - Current timestamp for time fields
  /// - Normalized JSON for complex fields
  static Map<String, dynamic> generateSafeChangeLogJson(
    Map<String, dynamic> original,
  ) {
    final now = HlcTimestampGenerator.generate();

    return {
      'entityId': original['entityId'] ?? '',
      'entityType': original['entityType'] ?? 'unknown',
      'domainId': original['domainId'] ?? '',
      'domainType': original['domainType'] ?? '',
      'changeAt': original['changeAt'] ?? now.toIso8601String(),
      'cid': original['cid'] ?? generateCid(now),
      'storageId': original['storageId'] ?? '',
      'changeBy': original['changeBy'] ?? '',
      'dataJson': JsonUtils.normalize(original['dataJson']),
      'operation': original['operation'] ?? 'unknown',
      'operationInfoJson': JsonUtils.normalize(original['operationInfoJson']),
      'stateChanged': original['stateChanged'] ?? false,
      'unknownJson': JsonUtils.normalize(original['unknownJson']),
      'dataSchemaRev': original['dataSchemaRev'] ?? 0,
      'schemaVersion': original['schemaVersion'] ?? 1,
    };
  }
}
