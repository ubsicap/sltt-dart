import 'package:test/test.dart';

import 'test_datetime.dart';

void main() {
  group('expectAllDateTimeFieldsAreUtc', () {
    test('passes when all DateTime fields are UTC', () {
      final json = {
        'createdAt': '2023-01-01T00:00:00.000Z',
        'updatedAt': '2023-12-31T23:59:59.999Z',
        'someString': 'not a date',
        'someNumber': 42,
      };

      expect(() => expectAllDateTimeFieldsAreUtc(json), returnsNormally);
    });

    test('fails when a DateTime field is not UTC', () {
      final json = {
        'createdAt': '2023-01-01T00:00:00.000Z', // UTC
        'updatedAt': '2023-12-31T23:59:59.999', // Not UTC (no Z)
      };

      expect(
        () => expectAllDateTimeFieldsAreUtc(json),
        throwsA(isA<TestFailure>()),
      );
    });

    test('passes when there are no DateTime fields', () {
      final json = {'name': 'test', 'count': 123, 'active': true};

      expect(() => expectAllDateTimeFieldsAreUtc(json), returnsNormally);
    });

    test('passes with empty map', () {
      expect(() => expectAllDateTimeFieldsAreUtc({}), returnsNormally);
    });

    test('ignores non-DateTime string values', () {
      final json = {
        'email': 'test@example.com',
        'description': 'Some random text',
        'validDate': '2023-01-01T00:00:00.000Z',
      };

      expect(() => expectAllDateTimeFieldsAreUtc(json), returnsNormally);
    });

    test('fails with helpful message indicating which field is not UTC', () {
      final json = {
        'goodDate': '2023-01-01T00:00:00.000Z',
        'badDate': '2023-01-01T12:00:00',
      };

      expect(
        () => expectAllDateTimeFieldsAreUtc(json),
        throwsA(
          predicate(
            (e) =>
                e is TestFailure &&
                e.message!.contains('badDate is not in UTC'),
          ),
        ),
      );
    });

    test('handles multiple DateTime fields correctly', () {
      final json = {
        'date1': '2023-01-01T00:00:00.000Z',
        'date2': '2023-02-01T00:00:00.000Z',
        'date3': '2023-03-01T00:00:00.000Z',
        'name': 'test',
      };

      expect(() => expectAllDateTimeFieldsAreUtc(json), returnsNormally);
    });
  });

  group('maybeValidDateTime', () {
    test('returns DateTime for valid ISO 8601 string', () {
      final result = maybeValidDateTime('2023-01-01T00:00:00.000Z');
      expect(result, isNotNull);
      expect(result, isA<DateTime>());
      expect(result!.year, equals(2023));
    });

    test('returns null for invalid date string', () {
      expect(maybeValidDateTime('not a date'), isNull);
    });

    test('returns null for empty string', () {
      expect(maybeValidDateTime(''), isNull);
    });

    test('returns DateTime for various valid formats', () {
      expect(maybeValidDateTime('2023-01-01'), isNotNull);
      expect(maybeValidDateTime('2023-01-01T12:00:00'), isNotNull);
      expect(maybeValidDateTime('2023-01-01T12:00:00.000Z'), isNotNull);
      expect(maybeValidDateTime('2023-01-01T12:00:00+05:00'), isNotNull);
    });

    test('preserves UTC flag from parsed DateTime', () {
      final utcDate = maybeValidDateTime('2023-01-01T00:00:00.000Z');
      expect(utcDate!.isUtc, isTrue);

      final nonUtcDate = maybeValidDateTime('2023-01-01T00:00:00');
      expect(nonUtcDate!.isUtc, isFalse);
    });
  });
}
