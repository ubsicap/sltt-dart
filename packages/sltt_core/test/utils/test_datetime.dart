import 'package:test/test.dart';

/// datetime utils for tests

void expectAllDateTimeFieldsAreUtc(Map<String, dynamic> json) {
  // test to make sure all dateTime fields are utc
  final dateTimeFields = json.entries
      .whereType<MapEntry<String, String>>()
      .map((e) => MapEntry(e.key, DateTime.parse(e.value)))
      .toList();

  for (final entry in dateTimeFields) {
    expect(entry.value.isUtc, isTrue, reason: '${entry.key} is not in UTC');
  }
}
