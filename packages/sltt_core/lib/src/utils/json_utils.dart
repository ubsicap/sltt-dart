import 'dart:convert';

import 'package:crypto/crypto.dart';

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

/// Compute a stable state data hash from an arbitrary state-like map.
///
/// Internally, this keeps `data_` fields including metadata
/// keys (for example `data_x_changeAt_`, `data_x_cid_`).
///
/// Throws an exception when there are no non-null `data_` fields.
String computeStateDataHash(Map<String, dynamic> stateMap) {
  final filtered = Map<String, dynamic>.fromEntries(
    stateMap.entries.where((e) => e.key.startsWith('data_') && e.value != null),
  );
  if (filtered.isEmpty) {
    return throw Exception(
      'No non-null data_ fields found for stateDataHash computation',
    );
  }
  final stable = stableStringify(filtered);
  final bytes = utf8.encode(stable);
  final digest = md5.convert(bytes);
  return base64Url.encode(digest.bytes);
}
