import 'package:unorm_dart/unorm_dart.dart' as unorm;

enum RegistrationValidationProfile { selfRegistration, adHocAdminRegistration }

enum RegistrationValidationWhitespaceMode { tolerant, strict }

class RegistrationValidationField {
  static const String userId = 'userId';
  static const String name = 'name';
  static const String dateOfBirth = 'dateOfBirth';
  static const String email = 'email';
  static const String username = 'username';
  static const String password = 'password';
  static const String confirmPassword = 'confirmPassword';
  static const String adminPassword = 'adminPassword';
}

class RegistrationValidationErrorCode {
  static const String required = 'required';
  static const String minLength = 'min_length';
  static const String maxLength = 'max_length';
  static const String invalidEmailFormat = 'invalid_email_format';
  static const String invalidDateFormat = 'invalid_date_format';
  static const String ageOutOfRange = 'age_out_of_range';
  static const String invalidUsernameFormat = 'invalid_username_format';
  static const String passwordTooWeak = 'password_too_weak';
  static const String passwordMismatch = 'password_mismatch';
  static const String leadingOrTrailingWhitespace =
      'leading_or_trailing_whitespace';
  static const String alreadyExists = 'already_exists';
  static const String invalidCredentials = 'invalid_credentials';
}

class RegistrationValidationFields {
  const RegistrationValidationFields({
    this.userId,
    this.name,
    this.dateOfBirth,
    this.email,
    this.username,
    this.password,
    this.confirmPassword,
    this.adminPassword,
  });

  final String? userId;
  final String? name;
  final String? dateOfBirth;
  final String? email;
  final String? username;
  final String? password;
  final String? confirmPassword;
  final String? adminPassword;
}

const int kMinimumRegistrationAgeYears = 13;
const int kMaximumRegistrationAgeYears = 100;
const int kMinimumRegistrationNameLength = 2;
const int kMaximumRegistrationNameLength = 32;
const int kMinimumRegistrationPasswordLength = 8;
const int kMaximumRegistrationUsernameLength = 20;
const int kRegistrationUsernameSuffixLength = 3;
const int kMaximumRegistrationUsernamePrefixLength =
    kMaximumRegistrationUsernameLength - kRegistrationUsernameSuffixLength;

Map<String, String> validateRegistrationForProfile({
  required RegistrationValidationProfile profile,
  required RegistrationValidationFields fields,
  DateTime? now,
  Map<String, String>? fieldKeyOverrides,
  RegistrationValidationWhitespaceMode whitespaceMode =
      RegistrationValidationWhitespaceMode.tolerant,
}) {
  switch (profile) {
    case RegistrationValidationProfile.selfRegistration:
      return _validateSelfRegistration(
        fields: fields,
        now: now,
        fieldKeyOverrides: fieldKeyOverrides,
        whitespaceMode: whitespaceMode,
      );
    case RegistrationValidationProfile.adHocAdminRegistration:
      return _validateAdHocAdminRegistration(
        fields: fields,
        now: now,
        fieldKeyOverrides: fieldKeyOverrides,
        whitespaceMode: whitespaceMode,
      );
  }
}

Map<String, String> _validateSelfRegistration({
  required RegistrationValidationFields fields,
  required DateTime? now,
  required Map<String, String>? fieldKeyOverrides,
  required RegistrationValidationWhitespaceMode whitespaceMode,
}) {
  final details = <String, String>{};

  _validateNoEdgeWhitespaceIfStrict(
    details,
    field: RegistrationValidationField.userId,
    value: fields.userId,
    whitespaceMode: whitespaceMode,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateNoEdgeWhitespaceIfStrict(
    details,
    field: RegistrationValidationField.name,
    value: fields.name,
    whitespaceMode: whitespaceMode,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateNoEdgeWhitespaceIfStrict(
    details,
    field: RegistrationValidationField.dateOfBirth,
    value: fields.dateOfBirth,
    whitespaceMode: whitespaceMode,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateNoEdgeWhitespaceIfStrict(
    details,
    field: RegistrationValidationField.email,
    value: fields.email,
    whitespaceMode: whitespaceMode,
    fieldKeyOverrides: fieldKeyOverrides,
  );

  _validateRequired(
    details,
    field: RegistrationValidationField.userId,
    value: fields.userId,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateFullName(
    details,
    value: fields.name,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateEmail(
    details,
    value: fields.email,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateDateOfBirth(
    details,
    value: fields.dateOfBirth,
    required: true,
    now: now,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validatePassword(
    details,
    value: fields.password,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateConfirmPasswordIfProvided(
    details,
    password: fields.password,
    confirmPassword: fields.confirmPassword,
    fieldKeyOverrides: fieldKeyOverrides,
  );

  return details;
}

Map<String, String> _validateAdHocAdminRegistration({
  required RegistrationValidationFields fields,
  required DateTime? now,
  required Map<String, String>? fieldKeyOverrides,
  required RegistrationValidationWhitespaceMode whitespaceMode,
}) {
  final details = <String, String>{};

  _validateNoEdgeWhitespaceIfStrict(
    details,
    field: RegistrationValidationField.userId,
    value: fields.userId,
    whitespaceMode: whitespaceMode,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateNoEdgeWhitespaceIfStrict(
    details,
    field: RegistrationValidationField.name,
    value: fields.name,
    whitespaceMode: whitespaceMode,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateNoEdgeWhitespaceIfStrict(
    details,
    field: RegistrationValidationField.username,
    value: fields.username,
    whitespaceMode: whitespaceMode,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateNoEdgeWhitespaceIfStrict(
    details,
    field: RegistrationValidationField.dateOfBirth,
    value: fields.dateOfBirth,
    whitespaceMode: whitespaceMode,
    fieldKeyOverrides: fieldKeyOverrides,
  );

  _validateRequired(
    details,
    field: RegistrationValidationField.userId,
    value: fields.userId,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateFullName(
    details,
    value: fields.name,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateRequired(
    details,
    field: RegistrationValidationField.username,
    value: fields.username,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateUsername(
    details,
    value: fields.username,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateDateOfBirth(
    details,
    value: fields.dateOfBirth,
    required: false,
    now: now,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validatePassword(
    details,
    value: fields.password,
    fieldKeyOverrides: fieldKeyOverrides,
  );
  _validateConfirmPasswordIfProvided(
    details,
    password: fields.password,
    confirmPassword: fields.confirmPassword,
    fieldKeyOverrides: fieldKeyOverrides,
  );

  return details;
}

void _validateRequired(
  Map<String, String> details, {
  required String field,
  required String? value,
  required Map<String, String>? fieldKeyOverrides,
}) {
  final resolvedField = _fieldKey(field, fieldKeyOverrides);
  if (details.containsKey(resolvedField)) {
    return;
  }

  if ((value ?? '').trim().isEmpty) {
    details[resolvedField] = RegistrationValidationErrorCode.required;
  }
}

void _validateFullName(
  Map<String, String> details, {
  required String? value,
  required Map<String, String>? fieldKeyOverrides,
}) {
  final name = (value ?? '').trim();
  final field = _fieldKey(RegistrationValidationField.name, fieldKeyOverrides);
  if (details.containsKey(field)) {
    return;
  }
  if (name.isEmpty) {
    details[field] = RegistrationValidationErrorCode.required;
    return;
  }
  if (name.length < kMinimumRegistrationNameLength) {
    details[field] = RegistrationValidationErrorCode.minLength;
    return;
  }
  if (name.length > kMaximumRegistrationNameLength) {
    details[field] = RegistrationValidationErrorCode.maxLength;
  }
}

void _validateUsername(
  Map<String, String> details, {
  required String? value,
  required Map<String, String>? fieldKeyOverrides,
}) {
  final field = _fieldKey(
    RegistrationValidationField.username,
    fieldKeyOverrides,
  );
  if (details.containsKey(field)) {
    return;
  }

  final raw = (value ?? '').trim();
  if (raw.isEmpty) {
    details[field] = RegistrationValidationErrorCode.required;
    return;
  }
  if (raw.length > kMaximumRegistrationUsernameLength) {
    details[field] = RegistrationValidationErrorCode.maxLength;
    return;
  }

  final normalized = normalizeRegistrationUsername(raw);
  if (normalized != raw) {
    details[field] = RegistrationValidationErrorCode.invalidUsernameFormat;
    return;
  }
  if (!_usernameFormat.hasMatch(raw)) {
    details[field] = RegistrationValidationErrorCode.invalidUsernameFormat;
  }
}

final RegExp _usernameFormat = RegExp(
  '^'
  '[a-z0-9]{1,$kMaximumRegistrationUsernamePrefixLength}'
  '[0-9]{$kRegistrationUsernameSuffixLength}'
  r'$',
);

void _validateEmail(
  Map<String, String> details, {
  required String? value,
  required Map<String, String>? fieldKeyOverrides,
}) {
  final email = (value ?? '').trim();
  final field = _fieldKey(RegistrationValidationField.email, fieldKeyOverrides);
  if (details.containsKey(field)) {
    return;
  }
  if (email.isEmpty) {
    details[field] = RegistrationValidationErrorCode.required;
    return;
  }
  const emailPattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
  if (!RegExp(emailPattern).hasMatch(email)) {
    details[field] = RegistrationValidationErrorCode.invalidEmailFormat;
  }
}

void _validateDateOfBirth(
  Map<String, String> details, {
  required String? value,
  required bool required,
  required DateTime? now,
  required Map<String, String>? fieldKeyOverrides,
}) {
  final field = _fieldKey(
    RegistrationValidationField.dateOfBirth,
    fieldKeyOverrides,
  );
  if (details.containsKey(field)) {
    return;
  }
  final dobText = (value ?? '').trim();
  if (dobText.isEmpty) {
    if (required) {
      details[field] = RegistrationValidationErrorCode.required;
    }
    return;
  }

  final parsedDob = DateTime.tryParse(dobText);
  if (parsedDob == null) {
    details[field] = RegistrationValidationErrorCode.invalidDateFormat;
    return;
  }

  final today = (now ?? DateTime.now()).toUtc();
  final age = _ageInYears(parsedDob.toUtc(), today);
  if (age < kMinimumRegistrationAgeYears ||
      age > kMaximumRegistrationAgeYears) {
    details[field] = RegistrationValidationErrorCode.ageOutOfRange;
  }
}

void _validatePassword(
  Map<String, String> details, {
  required String? value,
  required Map<String, String>? fieldKeyOverrides,
}) {
  final password = value ?? '';
  final field = _fieldKey(
    RegistrationValidationField.password,
    fieldKeyOverrides,
  );
  if (password.isEmpty) {
    details[field] = RegistrationValidationErrorCode.required;
    return;
  }
  if (password.length < kMinimumRegistrationPasswordLength) {
    details[field] = RegistrationValidationErrorCode.passwordTooWeak;
  }
}

void _validateConfirmPasswordIfProvided(
  Map<String, String> details, {
  required String? password,
  required String? confirmPassword,
  required Map<String, String>? fieldKeyOverrides,
}) {
  if (confirmPassword == null) {
    return;
  }
  final field = _fieldKey(
    RegistrationValidationField.confirmPassword,
    fieldKeyOverrides,
  );
  if (details.containsKey(field)) {
    return;
  }
  if (confirmPassword.isEmpty) {
    details[field] = RegistrationValidationErrorCode.required;
    return;
  }
  if ((password ?? '') != confirmPassword) {
    details[field] = RegistrationValidationErrorCode.passwordMismatch;
  }
}

String _fieldKey(String canonical, Map<String, String>? overrides) {
  return overrides?[canonical] ?? canonical;
}

void _validateNoEdgeWhitespaceIfStrict(
  Map<String, String> details, {
  required String field,
  required String? value,
  required RegistrationValidationWhitespaceMode whitespaceMode,
  required Map<String, String>? fieldKeyOverrides,
}) {
  if (whitespaceMode != RegistrationValidationWhitespaceMode.strict) {
    return;
  }

  final raw = value ?? '';
  final trimmed = raw.trim();
  if (trimmed.isEmpty || raw == trimmed) {
    return;
  }

  final resolvedField = _fieldKey(field, fieldKeyOverrides);
  details[resolvedField] =
      RegistrationValidationErrorCode.leadingOrTrailingWhitespace;
}

int _ageInYears(DateTime dateOfBirth, DateTime today) {
  var age = today.year - dateOfBirth.year;
  final birthdayHasNotOccurredYet =
      today.month < dateOfBirth.month ||
      (today.month == dateOfBirth.month && today.day < dateOfBirth.day);
  if (birthdayHasNotOccurredYet) {
    age -= 1;
  }
  return age;
}

String normalizeRegistrationUsernamePrefix(String input) {
  final normalized = unorm.nfkc(input).toLowerCase();
  final buffer = StringBuffer();
  for (final rune in normalized.runes) {
    if (_isAsciiLowerLetter(rune) || _isAsciiDigit(rune)) {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

String normalizeRegistrationUsername(String input) {
  final normalized = normalizeRegistrationUsernamePrefix(input);
  if (normalized.length <= kMaximumRegistrationUsernameLength) {
    return normalized;
  }
  return normalized.substring(0, kMaximumRegistrationUsernameLength);
}

bool _isAsciiLowerLetter(int rune) => rune >= 97 && rune <= 122;

bool _isAsciiDigit(int rune) => rune >= 48 && rune <= 57;
