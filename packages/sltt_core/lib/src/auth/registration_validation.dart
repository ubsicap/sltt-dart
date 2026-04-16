enum RegistrationValidationProfile { selfRegistration, adHocAdminRegistration }

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
  static const String invalidEmailFormat = 'invalid_email_format';
  static const String invalidDateFormat = 'invalid_date_format';
  static const String ageOutOfRange = 'age_out_of_range';
  static const String passwordTooWeak = 'password_too_weak';
  static const String passwordMismatch = 'password_mismatch';
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
const int kMinimumRegistrationPasswordLength = 8;

Map<String, String> validateRegistrationForProfile({
  required RegistrationValidationProfile profile,
  required RegistrationValidationFields fields,
  DateTime? now,
  Map<String, String>? fieldKeyOverrides,
}) {
  switch (profile) {
    case RegistrationValidationProfile.selfRegistration:
      return _validateSelfRegistration(
        fields: fields,
        now: now,
        fieldKeyOverrides: fieldKeyOverrides,
      );
    case RegistrationValidationProfile.adHocAdminRegistration:
      return _validateAdHocAdminRegistration(
        fields: fields,
        now: now,
        fieldKeyOverrides: fieldKeyOverrides,
      );
  }
}

Map<String, String> _validateSelfRegistration({
  required RegistrationValidationFields fields,
  required DateTime? now,
  required Map<String, String>? fieldKeyOverrides,
}) {
  final details = <String, String>{};

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
}) {
  final details = <String, String>{};

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
  if ((value ?? '').trim().isEmpty) {
    details[_fieldKey(field, fieldKeyOverrides)] =
        RegistrationValidationErrorCode.required;
  }
}

void _validateFullName(
  Map<String, String> details, {
  required String? value,
  required Map<String, String>? fieldKeyOverrides,
}) {
  final name = (value ?? '').trim();
  final field = _fieldKey(RegistrationValidationField.name, fieldKeyOverrides);
  if (name.isEmpty) {
    details[field] = RegistrationValidationErrorCode.required;
    return;
  }
  if (name.length < kMinimumRegistrationNameLength) {
    details[field] = RegistrationValidationErrorCode.minLength;
  }
}

void _validateEmail(
  Map<String, String> details, {
  required String? value,
  required Map<String, String>? fieldKeyOverrides,
}) {
  final email = (value ?? '').trim();
  final field = _fieldKey(RegistrationValidationField.email, fieldKeyOverrides);
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
