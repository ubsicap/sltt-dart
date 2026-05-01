// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'auth_models.g.dart';

@JsonEnum(valueField: 'value')
enum AuthIdentityKind {
  emailPassword('email_password'),
  usernamePassword('username_password');

  const AuthIdentityKind(this.value);

  final String value;

  static AuthIdentityKind fromValue(String value) {
    return _enumByValue(
      AuthIdentityKind.values,
      value,
      'identityKind',
      (kind) => kind.value,
    );
  }
}

@JsonEnum(valueField: 'value')
enum AuthAccountStatus {
  pendingVerification('pending_verification'),
  active('active'),
  deleted('deleted');

  const AuthAccountStatus(this.value);

  final String value;

  static AuthAccountStatus fromValue(String value) {
    return _enumByValue(
      AuthAccountStatus.values,
      value,
      'accountStatus',
      (status) => status.value,
    );
  }
}

class AuthException implements Exception {
  AuthException(
    this.message, {
    this.statusCode = 400,
    this.code = 'auth_error',
    this.details,
  });

  final String message;
  final int statusCode;
  final String code;
  final Map<String, String>? details;

  Map<String, dynamic> toJson() => {
    'error': message,
    'code': code,
    if (details != null && details!.isNotEmpty) 'details': details,
  };

  @override
  String toString() => 'AuthException($statusCode, $code, $message)';
}

abstract class AuthPrincipal {
  AuthPrincipal._({
    required this.userId,
    required this.identityKind,
    required this.passwordHash,
    required this.passwordSalt,
    required this.passwordIterations,
    required this.accountStatus,
    required this.emailVerified,
    required this.isAdHoc,
    required this.displayName,
    required this.dateOfBirth,
    required this.verifiedAt,
    required this.deletedAt,
    required this.assignedProjectIds,
    this.memberships,
    required this.verificationVersion,
    required this.registrationAttemptAt_orig_,
    required this.registrationAttemptAt_last_,
    required this.registrationOutcome_orig_,
    required this.registrationOutcome_last_,
    required this.registrationSourceIp_orig_,
    required this.registrationSourceIp_last_,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthPrincipal.fromJson(Map<String, dynamic> json) {
    final identityKind = _strictIdentityKindFromJson(json['identityKind']);
    switch (identityKind) {
      case AuthIdentityKind.emailPassword:
        _requireNonEmptyIdentityField('email', json['email'] as String?);
        _requireNonEmptyIdentityField(
          'normalizedEmail',
          json['normalizedEmail'] as String?,
        );
        return EmailAuthPrincipal.fromJson(json);
      case AuthIdentityKind.usernamePassword:
        _requireNonEmptyIdentityField('username', json['username'] as String?);
        _requireNonEmptyIdentityField(
          'normalizedUsername',
          json['normalizedUsername'] as String?,
        );
        return UsernameAuthPrincipal.fromJson(json);
    }
  }

  @JsonKey()
  final String userId;
  @JsonKey()
  final AuthIdentityKind identityKind;
  abstract final String? email;
  abstract final String? normalizedEmail;
  abstract final String? username;
  abstract final String? normalizedUsername;
  @JsonKey()
  final String passwordHash;
  @JsonKey()
  final String passwordSalt;
  @JsonKey()
  final int passwordIterations;
  @JsonKey()
  final AuthAccountStatus accountStatus;
  @JsonKey()
  final bool emailVerified;
  @JsonKey()
  final bool isAdHoc;
  @JsonKey()
  final String displayName;
  @JsonKey()
  final String? dateOfBirth;
  @JsonKey(
    fromJson: _nullableUtcDateTimeFromJson,
    toJson: _nullableUtcDateTimeToJson,
  )
  final DateTime? verifiedAt;
  @JsonKey(
    fromJson: _nullableUtcDateTimeFromJson,
    toJson: _nullableUtcDateTimeToJson,
  )
  final DateTime? deletedAt;
  @JsonKey(fromJson: _stringListFromJson)
  final List<String> assignedProjectIds;
  @JsonKey(fromJson: _nullableStringStringMapFromJson, includeIfNull: false)
  final Map<String, String>? memberships;
  @JsonKey()
  final int verificationVersion;
  @JsonKey(
    fromJson: _nullableUtcDateTimeFromJson,
    toJson: _nullableUtcDateTimeToJson,
  )
  final DateTime? registrationAttemptAt_orig_;
  @JsonKey(
    fromJson: _nullableUtcDateTimeFromJson,
    toJson: _nullableUtcDateTimeToJson,
  )
  final DateTime? registrationAttemptAt_last_;
  @JsonKey()
  final String? registrationOutcome_orig_;
  @JsonKey()
  final String? registrationOutcome_last_;
  @JsonKey()
  final String? registrationSourceIp_orig_;
  @JsonKey()
  final String? registrationSourceIp_last_;
  @JsonKey(
    fromJson: _requiredUtcDateTimeFromJson,
    toJson: _requiredUtcDateTimeToJson,
  )
  final DateTime createdAt;
  @JsonKey(
    fromJson: _requiredUtcDateTimeFromJson,
    toJson: _requiredUtcDateTimeToJson,
  )
  final DateTime updatedAt;

  bool get isDeleted => accountStatus == AuthAccountStatus.deleted;
  bool get isActive => accountStatus == AuthAccountStatus.active && !isDeleted;

  AuthPrincipal copyWith({
    AuthIdentityKind? identityKind,
    String? email,
    String? normalizedEmail,
    String? username,
    String? normalizedUsername,
    String? passwordHash,
    String? passwordSalt,
    int? passwordIterations,
    AuthAccountStatus? accountStatus,
    bool? emailVerified,
    bool? isAdHoc,
    String? displayName,
    String? dateOfBirth,
    DateTime? verifiedAt,
    DateTime? deletedAt,
    List<String>? assignedProjectIds,
    Map<String, String>? memberships,
    int? verificationVersion,
    DateTime? registrationAttemptAt_orig_,
    DateTime? registrationAttemptAt_last_,
    String? registrationOutcome_orig_,
    String? registrationOutcome_last_,
    String? registrationSourceIp_orig_,
    String? registrationSourceIp_last_,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  Map<String, dynamic> toJson();
}

@JsonSerializable(includeIfNull: false, checked: true)
class EmailAuthPrincipal extends AuthPrincipal {
  EmailAuthPrincipal({
    required super.userId,
    super.identityKind = AuthIdentityKind.emailPassword,
    required String email,
    required String normalizedEmail,
    required super.passwordHash,
    required super.passwordSalt,
    required super.passwordIterations,
    required super.accountStatus,
    required super.emailVerified,
    required super.isAdHoc,
    required super.displayName,
    super.dateOfBirth,
    super.verifiedAt,
    super.deletedAt,
    required super.assignedProjectIds,
    super.memberships,
    required super.verificationVersion,
    super.registrationAttemptAt_orig_,
    super.registrationAttemptAt_last_,
    super.registrationOutcome_orig_,
    super.registrationOutcome_last_,
    super.registrationSourceIp_orig_,
    super.registrationSourceIp_last_,
    required super.createdAt,
    required super.updatedAt,
  }) : email = _requireNonEmptyIdentityField('email', email),
       normalizedEmail = _requireNonEmptyIdentityField(
         'normalizedEmail',
         normalizedEmail,
       ),
       super._() {
    if (identityKind != AuthIdentityKind.emailPassword) {
      throw ArgumentError.value(
        identityKind,
        'identityKind',
        'EmailAuthPrincipal requires identityKind=email_password',
      );
    }
  }

  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String normalizedEmail;
  @override
  String? get username => null;
  @override
  String? get normalizedUsername => null;

  @override
  EmailAuthPrincipal copyWith({
    AuthIdentityKind? identityKind,
    String? email,
    String? normalizedEmail,
    String? username,
    String? normalizedUsername,
    String? passwordHash,
    String? passwordSalt,
    int? passwordIterations,
    AuthAccountStatus? accountStatus,
    bool? emailVerified,
    bool? isAdHoc,
    String? displayName,
    String? dateOfBirth,
    DateTime? verifiedAt,
    DateTime? deletedAt,
    List<String>? assignedProjectIds,
    Map<String, String>? memberships,
    int? verificationVersion,
    DateTime? registrationAttemptAt_orig_,
    DateTime? registrationAttemptAt_last_,
    String? registrationOutcome_orig_,
    String? registrationOutcome_last_,
    String? registrationSourceIp_orig_,
    String? registrationSourceIp_last_,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    if (identityKind != null && identityKind != this.identityKind) {
      throw ArgumentError('Cannot change identityKind for EmailAuthPrincipal');
    }
    if (username != null || normalizedUsername != null) {
      throw ArgumentError(
        'EmailAuthPrincipal does not support username fields',
      );
    }
    return EmailAuthPrincipal(
      userId: userId,
      email: email ?? this.email,
      normalizedEmail: normalizedEmail ?? this.normalizedEmail,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      passwordIterations: passwordIterations ?? this.passwordIterations,
      accountStatus: accountStatus ?? this.accountStatus,
      emailVerified: emailVerified ?? this.emailVerified,
      isAdHoc: isAdHoc ?? this.isAdHoc,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      assignedProjectIds: assignedProjectIds ?? this.assignedProjectIds,
      memberships: memberships ?? this.memberships,
      verificationVersion: verificationVersion ?? this.verificationVersion,
      registrationAttemptAt_orig_:
          registrationAttemptAt_orig_ ?? this.registrationAttemptAt_orig_,
      registrationAttemptAt_last_:
          registrationAttemptAt_last_ ?? this.registrationAttemptAt_last_,
      registrationOutcome_orig_:
          registrationOutcome_orig_ ?? this.registrationOutcome_orig_,
      registrationOutcome_last_:
          registrationOutcome_last_ ?? this.registrationOutcome_last_,
      registrationSourceIp_orig_:
          registrationSourceIp_orig_ ?? this.registrationSourceIp_orig_,
      registrationSourceIp_last_:
          registrationSourceIp_last_ ?? this.registrationSourceIp_last_,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory EmailAuthPrincipal.fromJson(Map<String, dynamic> json) =>
      _$EmailAuthPrincipalFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EmailAuthPrincipalToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class UsernameAuthPrincipal extends AuthPrincipal {
  UsernameAuthPrincipal({
    required super.userId,
    super.identityKind = AuthIdentityKind.usernamePassword,
    required String username,
    required String normalizedUsername,
    required super.passwordHash,
    required super.passwordSalt,
    required super.passwordIterations,
    required super.accountStatus,
    required super.emailVerified,
    required super.isAdHoc,
    required super.displayName,
    super.dateOfBirth,
    super.verifiedAt,
    super.deletedAt,
    required super.assignedProjectIds,
    super.memberships,
    required super.verificationVersion,
    super.registrationAttemptAt_orig_,
    super.registrationAttemptAt_last_,
    super.registrationOutcome_orig_,
    super.registrationOutcome_last_,
    super.registrationSourceIp_orig_,
    super.registrationSourceIp_last_,
    required super.createdAt,
    required super.updatedAt,
  }) : username = _requireNonEmptyIdentityField('username', username),
       normalizedUsername = _requireNonEmptyIdentityField(
         'normalizedUsername',
         normalizedUsername,
       ),
       super._() {
    if (identityKind != AuthIdentityKind.usernamePassword) {
      throw ArgumentError.value(
        identityKind,
        'identityKind',
        'UsernameAuthPrincipal requires identityKind=username_password',
      );
    }
  }

  @override
  String? get email => null;
  @override
  String? get normalizedEmail => null;
  @override
  @JsonKey()
  final String username;
  @override
  @JsonKey()
  final String normalizedUsername;

  @override
  UsernameAuthPrincipal copyWith({
    AuthIdentityKind? identityKind,
    String? email,
    String? normalizedEmail,
    String? username,
    String? normalizedUsername,
    String? passwordHash,
    String? passwordSalt,
    int? passwordIterations,
    AuthAccountStatus? accountStatus,
    bool? emailVerified,
    bool? isAdHoc,
    String? displayName,
    String? dateOfBirth,
    DateTime? verifiedAt,
    DateTime? deletedAt,
    List<String>? assignedProjectIds,
    Map<String, String>? memberships,
    int? verificationVersion,
    DateTime? registrationAttemptAt_orig_,
    DateTime? registrationAttemptAt_last_,
    String? registrationOutcome_orig_,
    String? registrationOutcome_last_,
    String? registrationSourceIp_orig_,
    String? registrationSourceIp_last_,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    if (identityKind != null && identityKind != this.identityKind) {
      throw ArgumentError(
        'Cannot change identityKind for UsernameAuthPrincipal',
      );
    }
    if (email != null || normalizedEmail != null) {
      throw ArgumentError(
        'UsernameAuthPrincipal does not support email fields',
      );
    }
    return UsernameAuthPrincipal(
      userId: userId,
      username: username ?? this.username,
      normalizedUsername: normalizedUsername ?? this.normalizedUsername,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      passwordIterations: passwordIterations ?? this.passwordIterations,
      accountStatus: accountStatus ?? this.accountStatus,
      emailVerified: emailVerified ?? this.emailVerified,
      isAdHoc: isAdHoc ?? this.isAdHoc,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      assignedProjectIds: assignedProjectIds ?? this.assignedProjectIds,
      memberships: memberships ?? this.memberships,
      verificationVersion: verificationVersion ?? this.verificationVersion,
      registrationAttemptAt_orig_:
          registrationAttemptAt_orig_ ?? this.registrationAttemptAt_orig_,
      registrationAttemptAt_last_:
          registrationAttemptAt_last_ ?? this.registrationAttemptAt_last_,
      registrationOutcome_orig_:
          registrationOutcome_orig_ ?? this.registrationOutcome_orig_,
      registrationOutcome_last_:
          registrationOutcome_last_ ?? this.registrationOutcome_last_,
      registrationSourceIp_orig_:
          registrationSourceIp_orig_ ?? this.registrationSourceIp_orig_,
      registrationSourceIp_last_:
          registrationSourceIp_last_ ?? this.registrationSourceIp_last_,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UsernameAuthPrincipal.fromJson(Map<String, dynamic> json) =>
      _$UsernameAuthPrincipalFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UsernameAuthPrincipalToJson(this);
}

@JsonSerializable(includeIfNull: true, checked: true)
class AuthEmailChallenge {
  AuthEmailChallenge({
    required this.userId,
    required this.codeHash,
    required this.codeSalt,
    required this.hashIterations,
    required this.expiresAt,
    required this.createdAt,
    required this.resendCount,
    required this.failedAttemptCount,
    required this.challengeVersion,
  });

  final String userId;
  @JsonKey(defaultValue: '')
  final String codeHash;
  @JsonKey(defaultValue: '')
  final String codeSalt;
  @JsonKey(defaultValue: 1)
  final int hashIterations;
  @JsonKey(
    fromJson: _requiredUtcDateTimeFromJson,
    toJson: _requiredUtcDateTimeToJson,
  )
  final DateTime expiresAt;
  @JsonKey(
    fromJson: _requiredUtcDateTimeFromJson,
    toJson: _requiredUtcDateTimeToJson,
  )
  final DateTime createdAt;
  @JsonKey(defaultValue: 0)
  final int resendCount;
  @JsonKey(defaultValue: 0)
  final int failedAttemptCount;
  @JsonKey(defaultValue: 0)
  final int challengeVersion;

  int get ttlEpochSeconds => expiresAt.toUtc().millisecondsSinceEpoch ~/ 1000;

  Map<String, dynamic> toJson() => {
    ..._$AuthEmailChallengeToJson(this),
    'ttlEpochSeconds': ttlEpochSeconds,
  };

  AuthEmailChallenge copyWith({
    String? codeHash,
    String? codeSalt,
    int? hashIterations,
    DateTime? expiresAt,
    DateTime? createdAt,
    int? resendCount,
    int? failedAttemptCount,
    int? challengeVersion,
  }) {
    return AuthEmailChallenge(
      userId: userId,
      codeHash: codeHash ?? this.codeHash,
      codeSalt: codeSalt ?? this.codeSalt,
      hashIterations: hashIterations ?? this.hashIterations,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      resendCount: resendCount ?? this.resendCount,
      failedAttemptCount: failedAttemptCount ?? this.failedAttemptCount,
      challengeVersion: challengeVersion ?? this.challengeVersion,
    );
  }

  factory AuthEmailChallenge.fromJson(Map<String, dynamic> json) =>
      _$AuthEmailChallengeFromJson(json);
}

@JsonSerializable(includeIfNull: false, checked: true)
class AuthSessionRecord {
  AuthSessionRecord({
    required this.userId,
    required this.sessionId,
    required this.refreshTokenHash,
    required this.createdAt,
    required this.expiresAt,
    this.revokedAt,
  });

  final String userId;
  final String sessionId;
  @JsonKey(defaultValue: '')
  final String refreshTokenHash;
  @JsonKey(
    fromJson: _requiredUtcDateTimeFromJson,
    toJson: _requiredUtcDateTimeToJson,
  )
  final DateTime createdAt;
  @JsonKey(
    fromJson: _requiredUtcDateTimeFromJson,
    toJson: _requiredUtcDateTimeToJson,
  )
  final DateTime expiresAt;
  @JsonKey(
    fromJson: _nullableUtcDateTimeFromJson,
    toJson: _nullableUtcDateTimeToJson,
  )
  final DateTime? revokedAt;

  bool get isRevoked => revokedAt != null;
  int get ttlEpochSeconds => expiresAt.toUtc().millisecondsSinceEpoch ~/ 1000;

  AuthSessionRecord copyWith({DateTime? revokedAt, DateTime? expiresAt}) {
    return AuthSessionRecord(
      userId: userId,
      sessionId: sessionId,
      refreshTokenHash: refreshTokenHash,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      revokedAt: revokedAt ?? this.revokedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    ..._$AuthSessionRecordToJson(this),
    'ttlEpochSeconds': ttlEpochSeconds,
  };

  factory AuthSessionRecord.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionRecordFromJson(json);
}

@JsonSerializable(includeIfNull: false, checked: true)
class AuthenticatedSession {
  const AuthenticatedSession({
    required this.userId,
    required this.sessionId,
    required this.isAdHoc,
    required this.emailVerified,
  });

  @JsonKey(defaultValue: '')
  final String userId;
  @JsonKey(defaultValue: '')
  final String sessionId;
  @JsonKey(defaultValue: false)
  final bool isAdHoc;
  @JsonKey(defaultValue: false)
  final bool emailVerified;

  factory AuthenticatedSession.fromJson(Map<String, dynamic> json) =>
      _$AuthenticatedSessionFromJson(json);

  Map<String, dynamic> toJson() => _$AuthenticatedSessionToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class AuthTokenPair {
  const AuthTokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  @JsonKey(defaultValue: '')
  final String accessToken;
  @JsonKey(defaultValue: '')
  final String refreshToken;
  @JsonKey(
    fromJson: _requiredUtcDateTimeFromJson,
    toJson: _requiredUtcDateTimeToJson,
  )
  final DateTime expiresAt;

  factory AuthTokenPair.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenPairFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenPairToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class RegisterRequest {
  RegisterRequest({
    required this.userId,
    required this.name,
    required this.dateOfBirth,
    required this.email,
    required this.password,
  });

  @JsonKey(defaultValue: '')
  final String userId;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String dateOfBirth;
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(defaultValue: '')
  final String password;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class VerifyEmailRequest {
  VerifyEmailRequest({required this.email, required this.code});

  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(defaultValue: '')
  final String code;

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class ResendVerificationCodeRequest {
  ResendVerificationCodeRequest({required this.email});

  @JsonKey(defaultValue: '')
  final String email;

  factory ResendVerificationCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$ResendVerificationCodeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResendVerificationCodeRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class LoginRequest {
  LoginRequest({required this.identifier, required this.password});

  @JsonKey(defaultValue: '', readValue: _readLoginIdentifier)
  final String identifier;
  @JsonKey(defaultValue: '')
  final String password;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class RefreshRequest {
  RefreshRequest({required this.refreshToken});

  @JsonKey(defaultValue: '')
  final String refreshToken;

  factory RefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class LogoutRequest {
  LogoutRequest({this.refreshToken});

  final String? refreshToken;

  factory LogoutRequest.fromJson(Map<String, dynamic> json) =>
      _$LogoutRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class CreateAdHocUserRequest {
  CreateAdHocUserRequest({
    required this.userId,
    required this.name,
    required this.username,
    required this.password,
    this.dateOfBirth,
    required this.projectIds,
    required this.adminPassword,
  });

  @JsonKey(defaultValue: '')
  final String userId;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String username;
  @JsonKey(defaultValue: '')
  final String password;
  final String? dateOfBirth;
  @JsonKey(fromJson: _stringListFromJson, defaultValue: <String>[])
  final List<String> projectIds;
  @JsonKey(defaultValue: '')
  final String adminPassword;

  factory CreateAdHocUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAdHocUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAdHocUserRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class UpdateAdHocProjectsRequest {
  UpdateAdHocProjectsRequest({
    required this.addProjectIds,
    required this.removeProjectIds,
    required this.adminPassword,
  });

  @JsonKey(fromJson: _stringListFromJson, defaultValue: <String>[])
  final List<String> addProjectIds;
  @JsonKey(fromJson: _stringListFromJson, defaultValue: <String>[])
  final List<String> removeProjectIds;
  @JsonKey(defaultValue: '')
  final String adminPassword;

  factory UpdateAdHocProjectsRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateAdHocProjectsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAdHocProjectsRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class UpdateUserMembershipsRequest {
  UpdateUserMembershipsRequest({
    required this.memberAdditions,
    required this.memberRemovals,
    required this.adminPassword,
  });

  @JsonKey(fromJson: _stringStringMapFromJson, defaultValue: <String, String>{})
  final Map<String, String> memberAdditions;
  @JsonKey(fromJson: _stringListFromJson, defaultValue: <String>[])
  final List<String> memberRemovals;
  @JsonKey(defaultValue: '')
  final String adminPassword;

  factory UpdateUserMembershipsRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserMembershipsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserMembershipsRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class ResetAdHocPasswordRequest {
  ResetAdHocPasswordRequest({
    required this.adminPassword,
    required this.newPassword,
  });

  @JsonKey(defaultValue: '')
  final String adminPassword;
  @JsonKey(defaultValue: '')
  final String newPassword;

  factory ResetAdHocPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetAdHocPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResetAdHocPasswordRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class DeleteAdHocUserRequest {
  DeleteAdHocUserRequest({required this.adminPassword});

  @JsonKey(defaultValue: '')
  final String adminPassword;

  factory DeleteAdHocUserRequest.fromJson(Map<String, dynamic> json) =>
      _$DeleteAdHocUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteAdHocUserRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class AuthStatusResponse {
  const AuthStatusResponse({required this.status, this.message});

  @JsonKey(defaultValue: '')
  final String status;
  final String? message;

  factory AuthStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthStatusResponseToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class AuthenticatedResponse {
  const AuthenticatedResponse({
    required this.status,
    this.message,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthenticatedResponse.fromTokenPair({
    required String status,
    String? message,
    required String userId,
    required AuthTokenPair tokens,
  }) {
    return AuthenticatedResponse(
      status: status,
      message: message,
      userId: userId,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: tokens.expiresAt,
    );
  }

  @JsonKey(defaultValue: '')
  final String status;
  final String? message;
  @JsonKey(defaultValue: '')
  final String userId;
  @JsonKey(defaultValue: '')
  final String accessToken;
  @JsonKey(defaultValue: '')
  final String refreshToken;
  @JsonKey(
    fromJson: _requiredUtcDateTimeFromJson,
    toJson: _requiredUtcDateTimeToJson,
  )
  final DateTime expiresAt;

  factory AuthenticatedResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthenticatedResponseFromJson(json);

  AuthTokenPair get tokens => AuthTokenPair(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresAt: expiresAt,
  );

  AuthTokenPair toAuthTokenPair() => tokens;

  Map<String, dynamic> toJson() => _$AuthenticatedResponseToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true)
class AdHocUserSummary {
  const AdHocUserSummary({
    required this.userId,
    required this.name,
    required this.username,
    required this.dateOfBirth,
    required this.projectIds,
    required this.status,
  });

  @JsonKey(defaultValue: '')
  final String userId;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String username;
  final String? dateOfBirth;
  @JsonKey(fromJson: _stringListFromJson, defaultValue: <String>[])
  final List<String> projectIds;
  @JsonKey(defaultValue: '')
  final String status;

  factory AdHocUserSummary.fromJson(Map<String, dynamic> json) =>
      _$AdHocUserSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AdHocUserSummaryToJson(this);
}

@JsonSerializable(includeIfNull: false, checked: true, explicitToJson: true)
class AdHocUsersResponse {
  const AdHocUsersResponse({required this.items});

  @JsonKey(defaultValue: <AdHocUserSummary>[])
  final List<AdHocUserSummary> items;

  factory AdHocUsersResponse.fromJson(Map<String, dynamic> json) =>
      _$AdHocUsersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AdHocUsersResponseToJson(this);
}

DateTime? _parseDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toUtc();
  }
  return null;
}

DateTime _requiredUtcDateTimeFromJson(dynamic value) =>
    _parseDateTime(value) ?? DateTime.now().toUtc();

String _requiredUtcDateTimeToJson(DateTime value) =>
    const UtcDateTimeConverter().toJson(value);

DateTime? _nullableUtcDateTimeFromJson(dynamic value) => _parseDateTime(value);

String? _nullableUtcDateTimeToJson(DateTime? value) =>
    value == null ? null : const UtcDateTimeConverter().toJson(value);

AuthIdentityKind _strictIdentityKindFromJson(dynamic value) {
  if (value is! String || value.isEmpty) {
    throw ArgumentError.value(
      value,
      'identityKind',
      'identityKind is required',
    );
  }
  return _enumByValue(
    AuthIdentityKind.values,
    value,
    'identityKind',
    (kind) => kind.value,
  );
}

T _enumByValue<T>(
  Iterable<T> values,
  String value,
  String field,
  String Function(T) toValue,
) {
  return values.firstWhere(
    (candidate) => toValue(candidate) == value,
    orElse: () => throw ArgumentError.value(value, field, 'Unsupported $field'),
  );
}

String _requireNonEmptyIdentityField(String field, String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    throw ArgumentError.value(value, field, '$field is required');
  }
  return trimmed;
}

List<String> _stringListFromJson(dynamic value) =>
    (value is List ? value : const <dynamic>[]).whereType<String>().toList(
      growable: false,
    );

Map<String, String> _stringStringMapFromJson(dynamic value) {
  if (value is! Map) {
    return const <String, String>{};
  }
  final normalized = <String, String>{};
  value.forEach((key, mapValue) {
    if (key is! String || mapValue is! String) {
      return;
    }
    final normalizedKey = key.trim();
    final normalizedValue = mapValue.trim();
    if (normalizedKey.isEmpty || normalizedValue.isEmpty) {
      return;
    }
    normalized[normalizedKey] = normalizedValue;
  });
  return normalized;
}

Map<String, String>? _nullableStringStringMapFromJson(dynamic value) {
  if (value == null) {
    return null;
  }
  return _stringStringMapFromJson(value);
}

Object? _readLoginIdentifier(Map json, String key) =>
    json[key] ?? json['email'] ?? json['username'];

String encodeJsonString(Map<String, dynamic> value) => jsonEncode(value);
