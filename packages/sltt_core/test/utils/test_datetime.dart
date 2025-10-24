import 'package:test/test.dart';

/// datetime utils for tests
///

DateTime? maybeValidDateTime(String input) {
  try {
    return DateTime.parse(input);
  } catch (e) {
    return null;
  }
}

void expectAllDateTimeFieldsAreUtc(Map<String, dynamic> json) {
  // test to make sure all dateTime fields are utc
  final dateTimeFields = json.entries
      .where((e) => e.value is String)
      .map((e) => MapEntry(e.key, maybeValidDateTime(e.value as String)))
      .where((e) => e.value != null)
      .toList();

  for (final entry in dateTimeFields) {
    expect(entry.value!.isUtc, isTrue, reason: '${entry.key} is not in UTC');
  }
}
