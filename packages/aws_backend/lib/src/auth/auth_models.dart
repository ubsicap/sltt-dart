// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'auth_models.g.dart';

enum AuthIdentityKind {
  emailPassword('email_password'),
  usernamePassword('username_password');

  const AuthIdentityKind(this.value);

  final String value;

  static AuthIdentityKind fromValue(String value) {
    return AuthIdentityKind.values.firstWhere(
      (kind) => kind.value == value,
      orElse: () => AuthIdentityKind.emailPassword,
    );
  }
}

enum AuthAccountStatus {
  pendingVerification('pending_verification'),
  active('active'),
  deleted('deleted');

  const AuthAccountStatus(this.value);

  final String value;

  static AuthAccountStatus fromValue(String value) {
    return AuthAccountStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AuthAccountStatus.pendingVerification,
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

class AuthPrincipal {
  AuthPrincipal({
    required this.userId,
    required this.identityKind,
    required this.passwordHash,
    required this.passwordSalt,
    required this.passwordIterations,
    required this.accountStatus,
    required this.emailVerified,
    required this.isAdHoc,
    required this.displayName,
    this.dateOfBirth,
    this.email,
    this.normalizedEmail,
    this.username,
    this.normalizedUsername,
    this.verifiedAt,
    this.deletedAt,
    required this.assignedProjectIds,
    required this.verificationVersion,
    this.registrationAttemptAt_orig_,
    this.registrationAttemptAt_last_,
    this.registrationOutcome_orig_,
    this.registrationOutcome_last_,
    this.registrationSourceIp_orig_,
    this.registrationSourceIp_last_,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final AuthIdentityKind identityKind;
  final String? email;
  final String? normalizedEmail;
  final String? username;
  final String? normalizedUsername;
  final String passwordHash;
  final String passwordSalt;
  final int passwordIterations;
  final AuthAccountStatus accountStatus;
  final bool emailVerified;
  final bool isAdHoc;
  final String displayName;
  final String? dateOfBirth;
  final DateTime? verifiedAt;
  final DateTime? deletedAt;
  final List<String> assignedProjectIds;
  final int verificationVersion;
  final DateTime? registrationAttemptAt_orig_;
  final DateTime? registrationAttemptAt_last_;
  final String? registrationOutcome_orig_;
  final String? registrationOutcome_last_;
  final String? registrationSourceIp_orig_;
  final String? registrationSourceIp_last_;
  final DateTime createdAt;
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
    return AuthPrincipal(
      userId: userId,
      identityKind: identityKind ?? this.identityKind,
      email: email ?? this.email,
      normalizedEmail: normalizedEmail ?? this.normalizedEmail,
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

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'identityKind': identityKind.value,
    'email': email,
    'normalizedEmail': normalizedEmail,
    'username': username,
    'normalizedUsername': normalizedUsername,
    'passwordHash': passwordHash,
    'passwordSalt': passwordSalt,
    'passwordIterations': passwordIterations,
    'accountStatus': accountStatus.value,
    'emailVerified': emailVerified,
    'isAdHoc': isAdHoc,
    'displayName': displayName,
    'dateOfBirth': dateOfBirth,
    'verifiedAt': verifiedAt?.toUtc().toIso8601String(),
    'deletedAt': deletedAt?.toUtc().toIso8601String(),
    'assignedProjectIds': assignedProjectIds,
    'verificationVersion': verificationVersion,
    'registrationAttemptAt_orig_': registrationAttemptAt_orig_
        ?.toUtc()
        .toIso8601String(),
    'registrationAttemptAt_last_': registrationAttemptAt_last_
        ?.toUtc()
        .toIso8601String(),
    'registrationOutcome_orig_': registrationOutcome_orig_,
    'registrationOutcome_last_': registrationOutcome_last_,
    'registrationSourceIp_orig_': registrationSourceIp_orig_,
    'registrationSourceIp_last_': registrationSourceIp_last_,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  }..removeWhere((key, value) => value == null);

  factory AuthPrincipal.fromJson(Map<String, dynamic> json) {
    return AuthPrincipal(
      userId: json['userId'] as String,
      identityKind: AuthIdentityKind.fromValue(
        json['identityKind'] as String? ?? AuthIdentityKind.emailPassword.value,
      ),
      email: json['email'] as String?,
      normalizedEmail: json['normalizedEmail'] as String?,
      username: json['username'] as String?,
      normalizedUsername: json['normalizedUsername'] as String?,
      passwordHash: json['passwordHash'] as String? ?? '',
      passwordSalt: json['passwordSalt'] as String? ?? '',
      passwordIterations: (json['passwordIterations'] as num?)?.toInt() ?? 0,
      accountStatus: AuthAccountStatus.fromValue(
        json['accountStatus'] as String? ??
            AuthAccountStatus.pendingVerification.value,
      ),
      emailVerified: json['emailVerified'] as bool? ?? false,
      isAdHoc: json['isAdHoc'] as bool? ?? false,
      displayName: json['displayName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String?,
      verifiedAt: _parseDateTime(json['verifiedAt']),
      deletedAt: _parseDateTime(json['deletedAt']),
      assignedProjectIds:
          (json['assignedProjectIds'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<String>()
              .toList(growable: false),
      verificationVersion: (json['verificationVersion'] as num?)?.toInt() ?? 0,
      registrationAttemptAt_orig_: _parseDateTime(
        json['registrationAttemptAt_orig_'],
      ),
      registrationAttemptAt_last_: _parseDateTime(
        json['registrationAttemptAt_last_'],
      ),
      registrationOutcome_orig_: json['registrationOutcome_orig_'] as String?,
      registrationOutcome_last_: json['registrationOutcome_last_'] as String?,
      registrationSourceIp_orig_: json['registrationSourceIp_orig_'] as String?,
      registrationSourceIp_last_: json['registrationSourceIp_last_'] as String?,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now().toUtc(),
    );
  }
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

class AuthenticatedResponse extends AuthStatusResponse {
  const AuthenticatedResponse({
    required super.status,
    required this.userId,
    required this.tokens,
  });

  final String userId;
  final AuthTokenPair tokens;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userId': userId,
    ...tokens.toJson(),
  };
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

List<String> _stringListFromJson(dynamic value) =>
    (value is List ? value : const <dynamic>[]).whereType<String>().toList(
      growable: false,
    );

Object? _readLoginIdentifier(Map json, String key) =>
    json[key] ?? json['email'] ?? json['username'];

String encodeJsonString(Map<String, dynamic> value) => jsonEncode(value);
