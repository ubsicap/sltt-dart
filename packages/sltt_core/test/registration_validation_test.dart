import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  group('validateRegistrationForProfile selfRegistration', () {
    test('returns required code for missing userId', () {
      final details = validateRegistrationForProfile(
        profile: RegistrationValidationProfile.selfRegistration,
        fields: const RegistrationValidationFields(
          userId: ' ',
          name: 'Jane Doe',
          dateOfBirth: '1990-06-15',
          email: 'jane@example.com',
          password: 'secret123',
        ),
      );

      expect(
        details,
        equals({'userId': RegistrationValidationErrorCode.required}),
      );
    });

    test('validates name, email, dob and password constraints', () {
      final details = validateRegistrationForProfile(
        profile: RegistrationValidationProfile.selfRegistration,
        fields: const RegistrationValidationFields(
          userId: 'user-jane',
          name: 'J',
          dateOfBirth: 'not-a-date',
          email: 'not-an-email',
          password: '1234567',
        ),
      );

      expect(
        details,
        equals({
          'name': RegistrationValidationErrorCode.minLength,
          'email': RegistrationValidationErrorCode.invalidEmailFormat,
          'dateOfBirth': RegistrationValidationErrorCode.invalidDateFormat,
          'password': RegistrationValidationErrorCode.passwordTooWeak,
        }),
      );
    });

    test('validates age boundaries', () {
      final now = DateTime.utc(2026, 4, 16);
      final tooYoung = DateTime.utc(2015, 4, 17).toIso8601String();
      final tooOld = DateTime.utc(1900, 1, 1).toIso8601String();

      final youngDetails = validateRegistrationForProfile(
        profile: RegistrationValidationProfile.selfRegistration,
        fields: RegistrationValidationFields(
          userId: 'user-jane',
          name: 'Jane Doe',
          dateOfBirth: tooYoung,
          email: 'jane@example.com',
          password: 'secret123',
        ),
        now: now,
      );

      final oldDetails = validateRegistrationForProfile(
        profile: RegistrationValidationProfile.selfRegistration,
        fields: RegistrationValidationFields(
          userId: 'user-jane',
          name: 'Jane Doe',
          dateOfBirth: tooOld,
          email: 'jane@example.com',
          password: 'secret123',
        ),
        now: now,
      );

      expect(
        youngDetails,
        equals({'dateOfBirth': RegistrationValidationErrorCode.ageOutOfRange}),
      );
      expect(
        oldDetails,
        equals({'dateOfBirth': RegistrationValidationErrorCode.ageOutOfRange}),
      );
    });

    test('validates confirm password when provided', () {
      final details = validateRegistrationForProfile(
        profile: RegistrationValidationProfile.selfRegistration,
        fields: const RegistrationValidationFields(
          userId: 'user-jane',
          name: 'Jane Doe',
          dateOfBirth: '1990-06-15',
          email: 'jane@example.com',
          password: 'secret123',
          confirmPassword: 'different',
        ),
      );

      expect(
        details,
        equals({
          'confirmPassword': RegistrationValidationErrorCode.passwordMismatch,
        }),
      );
    });

    test('supports field key overrides for schema adapters', () {
      final details = validateRegistrationForProfile(
        profile: RegistrationValidationProfile.selfRegistration,
        fields: const RegistrationValidationFields(
          userId: '',
          name: '',
          dateOfBirth: '',
          email: '',
          password: '',
        ),
        fieldKeyOverrides: const {
          RegistrationValidationField.userId: 'uid',
          RegistrationValidationField.name: 'fullName',
          RegistrationValidationField.dateOfBirth: 'dob',
          RegistrationValidationField.email: 'mail',
          RegistrationValidationField.password: 'pwd',
        },
      );

      expect(
        details,
        equals({
          'uid': RegistrationValidationErrorCode.required,
          'fullName': RegistrationValidationErrorCode.required,
          'mail': RegistrationValidationErrorCode.required,
          'dob': RegistrationValidationErrorCode.required,
          'pwd': RegistrationValidationErrorCode.required,
        }),
      );
    });

    test('strict mode rejects leading or trailing whitespace', () {
      final details = validateRegistrationForProfile(
        profile: RegistrationValidationProfile.selfRegistration,
        whitespaceMode: RegistrationValidationWhitespaceMode.strict,
        fields: const RegistrationValidationFields(
          userId: ' user-jane',
          name: 'Jane Doe ',
          dateOfBirth: ' 1990-06-15',
          email: 'jane@example.com ',
          password: '   exception: permit leading/trailing ws in passwords  ',
        ),
      );

      expect(
        details,
        equals({
          'userId': RegistrationValidationErrorCode.leadingOrTrailingWhitespace,
          'name': RegistrationValidationErrorCode.leadingOrTrailingWhitespace,
          'dateOfBirth':
              RegistrationValidationErrorCode.leadingOrTrailingWhitespace,
          'email': RegistrationValidationErrorCode.leadingOrTrailingWhitespace,
        }),
      );
    });

    test('tolerant mode preserves existing trim-acceptance behavior', () {
      final details = validateRegistrationForProfile(
        profile: RegistrationValidationProfile.selfRegistration,
        fields: const RegistrationValidationFields(
          userId: ' user-jane ',
          name: ' Jane Doe ',
          dateOfBirth: ' 1990-06-15 ',
          email: ' jane@example.com ',
          password: 'secret123',
        ),
      );

      expect(details, isEmpty);
    });
  });

  group('validateRegistrationForProfile adHocAdminRegistration', () {
    test('supports optional dob and required username', () {
      final details = validateRegistrationForProfile(
        profile: RegistrationValidationProfile.adHocAdminRegistration,
        fields: const RegistrationValidationFields(
          userId: 'adhoc-1',
          name: 'John Doe',
          username: '',
          dateOfBirth: '',
          password: 'secret123',
        ),
      );

      expect(
        details,
        equals({'username': RegistrationValidationErrorCode.required}),
      );
    });
  });
}
