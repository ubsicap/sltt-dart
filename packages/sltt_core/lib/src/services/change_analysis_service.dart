import '../models/base_change_log_entry.dart';
import 'field_change_detector.dart';

/// Result of analyzing changes before storage operations
class ChangeAnalysisResult {
  /// Changes that should be created/stored
  final List<AnalyzedChange> changesToCreate;

  /// Changes that resulted in no actual updates (no-op changes)
  final List<String> noOpChangeCids;

  /// Field change details for each processed change
  final Map<String, FieldChangeResult> changeDetails;

  ChangeAnalysisResult({
    required this.changesToCreate,
    required this.noOpChangeCids,
    required this.changeDetails,
  });
}

/// A change that has been analyzed and is ready for storage
class AnalyzedChange {
  /// The change data to store
  final Map<String, dynamic> changeData;

  /// The CID for this change
  final String cid;

  /// The resolved operation (may differ from requested)
  final String resolvedOperation;

  /// The original requested operation
  final String requestedOperation;

  /// Whether the operation was changed from requested
  bool get operationChanged => resolvedOperation != requestedOperation;

  /// Reason why operation might have changed
  final String? operationChangeReason;

  AnalyzedChange({
    required this.changeData,
    required this.cid,
    required this.resolvedOperation,
    required this.requestedOperation,
    this.operationChangeReason,
  });
}

/// Pure function for analyzing changes and determining operations
///
/// This function:
/// - Analyzes requested operations against current entity state
/// - Gracefully handles mismatched operations (e.g., update on non-existent entity)
/// - Performs field-level change detection
/// - Returns enough information for storage services to decide how to proceed
///
/// Parameters:
/// - [changesData]: List of change requests to analyze
/// - [getCurrentEntityState]: Function to look up current entity state
///
/// Returns [ChangeAnalysisResult] with analyzed changes and metadata
Future<ChangeAnalysisResult> analyzeChanges(
  List<Map<String, dynamic>> changesData,
  Future<BaseChangeLogEntry?> Function(
    String projectId,
    String entityType,
    String entityId,
  )
  getCurrentEntityState,
) async {
  final changesToCreate = <AnalyzedChange>[];
  final noOpChangeCids = <String>[];
  final changeDetails = <String, FieldChangeResult>{};

  for (final changeData in changesData) {
    final projectId = changeData['projectId'] as String;
    final entityType = changeData['entityType'] as String;
    final entityId = changeData['entityId'] as String;
    final requestedOperation = changeData['operation'] as String? ?? 'create';
    final incomingData =
        (changeData['data'] as Map<dynamic, dynamic>?)
            ?.cast<String, dynamic>() ??
        <String, dynamic>{};

    // Generate CID for this change if not provided
    final cid =
        changeData['cid'] as String? ?? BaseChangeLogEntry.generateCid();

    try {
      // Get current entity state for analysis
      final currentState = await getCurrentEntityState(
        projectId,
        entityType,
        entityId,
      );

      String resolvedOperation = requestedOperation;
      String? operationChangeReason;

      // Analyze and resolve the operation
      if (requestedOperation == 'create') {
        if (currentState != null) {
          resolvedOperation = 'update';
          operationChangeReason =
              'Entity already exists, converting create to update';
        }
      } else if (requestedOperation == 'update') {
        if (currentState == null) {
          resolvedOperation = 'create';
          operationChangeReason =
              'Entity does not exist, converting update to create';
        }
      }

      // For delete operations, always proceed as requested
      if (requestedOperation == 'delete') {
        final optimizedChangeData = Map<String, dynamic>.from(changeData);
        optimizedChangeData['cid'] = cid;
        optimizedChangeData['operation'] = resolvedOperation;

        changesToCreate.add(
          AnalyzedChange(
            changeData: optimizedChangeData,
            cid: cid,
            resolvedOperation: resolvedOperation,
            requestedOperation: requestedOperation,
            operationChangeReason: operationChangeReason,
          ),
        );

        changeDetails[cid] = FieldChangeResult(
          updatedFields: incomingData.keys.toList(),
          noOpFields: [],
          totalFields: incomingData.keys.length,
        );
        continue;
      }

      // For create operations (including converted ones), always proceed
      if (resolvedOperation == 'create') {
        final optimizedChangeData = Map<String, dynamic>.from(changeData);
        optimizedChangeData['cid'] = cid;
        optimizedChangeData['operation'] = resolvedOperation;

        changesToCreate.add(
          AnalyzedChange(
            changeData: optimizedChangeData,
            cid: cid,
            resolvedOperation: resolvedOperation,
            requestedOperation: requestedOperation,
            operationChangeReason: operationChangeReason,
          ),
        );

        changeDetails[cid] = FieldChangeResult(
          updatedFields: incomingData.keys.toList(),
          noOpFields: [],
          totalFields: incomingData.keys.length,
        );
        continue;
      }

      // For update operations, perform field-level change detection
      if (resolvedOperation == 'update' && currentState != null) {
        final currentData = currentState.getData();
        final updatedFields = <String>[];
        final noOpFields = <String>[];

        for (final entry in incomingData.entries) {
          final fieldName = entry.key;
          final incomingValue = entry.value;
          final currentValue = currentData[fieldName];

          if (hasValueChanged(currentValue, incomingValue)) {
            updatedFields.add(fieldName);
          } else {
            noOpFields.add(fieldName);
          }
        }

        final result = FieldChangeResult(
          updatedFields: updatedFields,
          noOpFields: noOpFields,
          totalFields: incomingData.keys.length,
        );

        changeDetails[cid] = result;

        if (result.hasUpdates) {
          // Create the change - only include fields that actually changed
          final optimizedData = <String, dynamic>{};
          for (final field in updatedFields) {
            optimizedData[field] = incomingData[field];
          }

          final optimizedChangeData = Map<String, dynamic>.from(changeData);
          optimizedChangeData['data'] = optimizedData;
          optimizedChangeData['cid'] = cid;
          optimizedChangeData['operation'] = resolvedOperation;

          changesToCreate.add(
            AnalyzedChange(
              changeData: optimizedChangeData,
              cid: cid,
              resolvedOperation: resolvedOperation,
              requestedOperation: requestedOperation,
              operationChangeReason: operationChangeReason,
            ),
          );
        } else {
          // No-op change - track the CID but don't create the change
          noOpChangeCids.add(cid);
        }
      }
    } catch (e) {
      // For analysis errors, still include the change but mark the issue
      final optimizedChangeData = Map<String, dynamic>.from(changeData);
      optimizedChangeData['cid'] = cid;
      optimizedChangeData['operation'] = requestedOperation;

      changesToCreate.add(
        AnalyzedChange(
          changeData: optimizedChangeData,
          cid: cid,
          resolvedOperation: requestedOperation,
          requestedOperation: requestedOperation,
          operationChangeReason: 'Analysis failed: $e',
        ),
      );

      changeDetails[cid] = FieldChangeResult(
        updatedFields: incomingData.keys.toList(),
        noOpFields: [],
        totalFields: incomingData.keys.length,
      );
    }
  }

  return ChangeAnalysisResult(
    changesToCreate: changesToCreate,
    noOpChangeCids: noOpChangeCids,
    changeDetails: changeDetails,
  );
}

/// Shared utility for value comparison across change detection services.
///
/// This function is used by multiple services for detecting actual changes:
/// - change_analysis_service.dart (operation resolution)
/// - field_change_detector.dart (field-level conflict resolution)
/// - change_detection_service.dart (basic change detection)
///
/// This method performs deep comparison for complex data structures:
/// - Handles null values correctly
/// - Compares basic types directly
/// - Recursively compares Maps and Lists
/// - Falls back to string comparison for other types
bool hasValueChanged(dynamic currentValue, dynamic incomingValue) {
  // Handle null values
  if (currentValue == null && incomingValue == null) return false;
  if (currentValue == null || incomingValue == null) return true;

  // For basic types, use direct comparison
  if (currentValue is String || currentValue is num || currentValue is bool) {
    return currentValue != incomingValue;
  }

  // For maps, do deep comparison
  if (currentValue is Map && incomingValue is Map) {
    if (currentValue.length != incomingValue.length) return true;

    for (final key in currentValue.keys) {
      if (!incomingValue.containsKey(key)) return true;
      if (hasValueChanged(currentValue[key], incomingValue[key])) {
        return true;
      }
    }
    for (final key in incomingValue.keys) {
      if (!currentValue.containsKey(key)) return true;
    }
    return false;
  }

  // For lists, do deep comparison
  if (currentValue is List && incomingValue is List) {
    if (currentValue.length != incomingValue.length) return true;

    for (int i = 0; i < currentValue.length; i++) {
      if (hasValueChanged(currentValue[i], incomingValue[i])) {
        return true;
      }
    }
    return false;
  }

  // For other types, convert to string and compare
  return currentValue.toString() != incomingValue.toString();
}
