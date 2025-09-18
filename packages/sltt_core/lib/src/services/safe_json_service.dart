import 'package:sltt_core/sltt_core.dart';

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
      // Ensure the minimal required type identifiers exist. Tests and
      // deserializers expect non-null strings for these fields.
      'entityType': original['entityType'] ?? 'unknown',
      'domainId': original['domainId'] ?? '',
      // domainType is required by BaseEntityState deserialization (checked
      // mode). Provide an explicit fallback so failures are centralized.
      'domainType': original['domainType'] ?? 'unknown',
      'changeAt': original['changeAt'] ?? now.toIso8601String(),
      'cid': original['cid'] ?? generateCid(),
      'storageId': original['storageId'] ?? '',
      'changeBy': original['changeBy'] ?? '',
      'dataJson': JsonUtils.normalize(original['dataJson']),
      'operation': original['operation'] ?? 'unknown',
      'operationInfoJson': JsonUtils.normalize(original['operationInfoJson']),
      'stateChanged': original['stateChanged'] ?? false,
      // Ensure unknownJson is at least an empty object string; many
      // serializers expect a JSON string here.
      'unknownJson': JsonUtils.normalize(original['unknownJson'] ?? '{}'),
    };
  }
}
