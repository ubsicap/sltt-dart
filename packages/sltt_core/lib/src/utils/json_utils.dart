import 'dart:convert';

/// Provides stable JSON string representation by sorting object keys recursively.
/// This ensures deterministic serialization for consistent comparisons and storage.
dynamic _stableStructure(dynamic value) {
  if (value is Map) {
    final sortedKeys = value.keys.toList()..sort();
    return {for (var k in sortedKeys) k: _stableStructure(value[k])};
  } else if (value is List) {
    return value.map(_stableStructure).toList();
  } else {
    return value;
  }
}

/// Returns a stable JSON string for any value, avoiding double-encoding if already a JSON string.
String stableStringify(dynamic value) {
  // Always recursively sort maps, even inside lists
  final stable = _stableStructure(value);
  // If input is a string, return as-is (do not encode)
  if (value is String) {
    return value;
  }
  return jsonEncode(stable);
}
