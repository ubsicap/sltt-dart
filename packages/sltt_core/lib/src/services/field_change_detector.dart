/// Result of a field change detection operation
class FieldChangeResult {
  /// Fields that were actually updated with new values
  final List<String> updatedFields;

  /// Fields that had newer timestamps but the same values (no-op changes)
  final List<String> noOpFields;

  /// Total number of fields processed
  final int totalFields;

  /// Whether any fields were actually updated
  bool get hasUpdates => updatedFields.isNotEmpty;

  /// Whether any changes were no-ops
  bool get hasNoOps => noOpFields.isNotEmpty;

  /// Whether all changes were no-ops
  bool get allNoOps => totalFields > 0 && updatedFields.isEmpty;

  FieldChangeResult({
    required this.updatedFields,
    required this.noOpFields,
    required this.totalFields,
  });

  Map<String, dynamic> toJson() => {
    'updatedFields': updatedFields,
    'noOpFields': noOpFields,
    'totalFields': totalFields,
    'hasUpdates': hasUpdates,
    'hasNoOps': hasNoOps,
    'allNoOps': allNoOps,
  };
}

/// Service for detecting field-level changes with conflict resolution
///
/// This implements the core business logic for:
/// - Field-level conflict resolution (only update if newer)
/// - Value change detection (only update metadata if value actually changed)
/// - No-op change tracking (for cleanup and optimization)
class FieldChangeDetector {
  /// Detect and apply field changes with conflict resolution
  ///
  /// Returns information about which fields were updated vs no-ops
  static FieldChangeResult detectAndApplyChanges({
    required Map<String, dynamic> incomingData,
    required DateTime incomingChangeAt,
    required String incomingCid,
    required String incomingChangeBy,
    required Map<String, dynamic> currentState,
    required Map<String, DateTime?> fieldChangeAts,
    required Function(
      String field,
      dynamic value,
      DateTime changeAt,
      String cid,
      String changeBy,
    )
    updateFieldCallback,
  }) {
    final updatedFields = <String>[];
    final noOpFields = <String>[];

    for (final entry in incomingData.entries) {
      final fieldName = entry.key;
      final incomingValue = entry.value;
      final currentChangeAt = fieldChangeAts[fieldName];

      // Check if this change is newer than current field timestamp
      if (currentChangeAt == null ||
          incomingChangeAt.isAfter(currentChangeAt)) {
        // Get current field value
        final currentValue = currentState[fieldName];

        // Check if the value has actually changed
        final valueChanged = _hasValueChanged(currentValue, incomingValue);

        if (valueChanged) {
          // Value has changed - update both value and metadata
          updateFieldCallback(
            fieldName,
            incomingValue,
            incomingChangeAt,
            incomingCid,
            incomingChangeBy,
          );
          updatedFields.add(fieldName);
        } else {
          // Value is the same - this is a no-op change
          // Update metadata only if the timestamp is newer
          // (some implementations may choose to update metadata, others may not)
          noOpFields.add(fieldName);
        }
      }
      // If timestamp is older, ignore the change entirely (existing conflict resolution)
    }

    return FieldChangeResult(
      updatedFields: updatedFields,
      noOpFields: noOpFields,
      totalFields: incomingData.length,
    );
  }

  /// Check if two values are different
  /// Handles various data types and null comparisons
  static bool _hasValueChanged(dynamic currentValue, dynamic incomingValue) {
    // Handle null cases
    if (currentValue == null && incomingValue == null) return false;
    if (currentValue == null || incomingValue == null) return true;

    // Handle different types
    if (currentValue.runtimeType != incomingValue.runtimeType) return true;

    // Handle lists
    if (currentValue is List && incomingValue is List) {
      if (currentValue.length != incomingValue.length) return true;
      for (int i = 0; i < currentValue.length; i++) {
        if (_hasValueChanged(currentValue[i], incomingValue[i])) return true;
      }
      return false;
    }

    // Handle maps
    if (currentValue is Map && incomingValue is Map) {
      if (currentValue.length != incomingValue.length) return true;
      for (final key in currentValue.keys) {
        if (!incomingValue.containsKey(key)) {
          return true;
        }
        if (_hasValueChanged(currentValue[key], incomingValue[key])) {
          return true;
        }
      }
      for (final key in incomingValue.keys) {
        if (!currentValue.containsKey(key)) return true;
      }
      return false;
    }

    // Handle primitives (String, int, double, bool)
    return currentValue != incomingValue;
  }

  /// Utility method to convert field change result to a response format
  static Map<String, dynamic> createChangeResponse({
    required String cid,
    required FieldChangeResult result,
    bool includeDetails = false,
  }) {
    final response = <String, dynamic>{
      'cid': cid,
      'hasUpdates': result.hasUpdates,
      'allNoOps': result.allNoOps,
    };

    if (includeDetails) {
      response.addAll({
        'updatedFields': result.updatedFields,
        'noOpFields': result.noOpFields,
        'totalFields': result.totalFields,
      });
    }

    return response;
  }
}
