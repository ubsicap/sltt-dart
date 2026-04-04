import 'dart:convert';

class DynamoExportDecoder {
  const DynamoExportDecoder();

  Map<String, dynamic>? decodeExportLineObject(Map<String, dynamic> object) {
    final item = object['Item'];
    if (item is! Map) {
      return null;
    }

    return Map<String, dynamic>.fromEntries(
      item.entries.map(
        (entry) =>
            MapEntry(entry.key.toString(), decodeAttributeValue(entry.value)),
      ),
    );
  }

  dynamic decodeAttributeValue(dynamic attributeValue) {
    if (attributeValue is! Map || attributeValue.length != 1) {
      return attributeValue;
    }

    final entry = attributeValue.entries.first;
    final type = entry.key.toString();
    final value = entry.value;

    switch (type) {
      case 'S':
        return value;
      case 'N':
        return _parseNumber(value?.toString());
      case 'BOOL':
        return value == true;
      case 'NULL':
        return null;
      case 'B':
        if (value is String) {
          try {
            return base64Decode(value);
          } catch (_) {
            return value;
          }
        }
        return value;
      case 'SS':
        return (value as List?)?.map((item) => item?.toString()).toList() ??
            const [];
      case 'NS':
        return (value as List?)
                ?.map((item) => _parseNumber(item?.toString()))
                .toList() ??
            const [];
      case 'BS':
        return (value as List?)
                ?.map(
                  (item) =>
                      item is String ? _decodeBase64OrFallback(item) : item,
                )
                .toList() ??
            const [];
      case 'L':
        return (value as List?)?.map(decodeAttributeValue).toList() ?? const [];
      case 'M':
        final map = value as Map?;
        if (map == null) return const <String, dynamic>{};
        return Map<String, dynamic>.fromEntries(
          map.entries.map(
            (nested) => MapEntry(
              nested.key.toString(),
              decodeAttributeValue(nested.value),
            ),
          ),
        );
      default:
        return value;
    }
  }

  dynamic _decodeBase64OrFallback(String value) {
    try {
      return base64Decode(value);
    } catch (_) {
      return value;
    }
  }

  num? _parseNumber(String? value) {
    if (value == null) return null;
    return int.tryParse(value) ?? double.tryParse(value);
  }
}
