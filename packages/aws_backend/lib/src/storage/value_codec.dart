String encodeKeyValue(String value) {
  return value
      .replaceAll('%', '%25')
      .replaceAll('#', '%23')
      .replaceAll('@', '%40');
}

String decodeKeyValue(String value) {
  return value
      .replaceAll('%23', '#')
      .replaceAll('%40', '@')
      .replaceAll('%25', '%');
}

bool needsEncoding(String value) {
  return value.contains('%') || value.contains('#') || value.contains('@');
}

void assertSafeSortKeyValue(String value) {
  if (needsEncoding(value)) {
    throw SortKeyEncodingViolation(
      'Sort key values may not contain #, @, or %: $value',
    );
  }
}

class SortKeyEncodingViolation extends FormatException {
  SortKeyEncodingViolation(super.message);
}
