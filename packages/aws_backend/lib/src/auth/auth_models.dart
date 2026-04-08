// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

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

class AuthEmailChallenge {
  AuthEmailChallenge({
    required this.userId,
    required this.codeHash,
    required this.codeSalt,
    required this.hashIterations,
    required this.expiresAt,
    required this.createdAt,
    required this.resendCount,
    required this.challengeVersion,
  });

  final String userId;
  final String codeHash;
  final String codeSalt;
  final int hashIterations;
  final DateTime expiresAt;
  final DateTime createdAt;
  final int resendCount;
  final int challengeVersion;

  int get ttlEpochSeconds => expiresAt.toUtc().millisecondsSinceEpoch ~/ 1000;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'codeHash': codeHash,
    'codeSalt': codeSalt,
    'hashIterations': hashIterations,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'resendCount': resendCount,
    'challengeVersion': challengeVersion,
    'ttlEpochSeconds': ttlEpochSeconds,
  };

  factory AuthEmailChallenge.fromJson(Map<String, dynamic> json) {
    return AuthEmailChallenge(
      userId: json['userId'] as String,
      codeHash: json['codeHash'] as String? ?? '',
      codeSalt: json['codeSalt'] as String? ?? '',
      hashIterations: (json['hashIterations'] as num?)?.toInt() ?? 1,
      expiresAt: _parseDateTime(json['expiresAt']) ?? DateTime.now().toUtc(),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
      resendCount: (json['resendCount'] as num?)?.toInt() ?? 0,
      challengeVersion: (json['challengeVersion'] as num?)?.toInt() ?? 0,
    );
  }
}

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
  final String refreshTokenHash;
  final DateTime createdAt;
  final DateTime expiresAt;
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
    'userId': userId,
    'sessionId': sessionId,
    'refreshTokenHash': refreshTokenHash,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'revokedAt': revokedAt?.toUtc().toIso8601String(),
    'ttlEpochSeconds': ttlEpochSeconds,
  }..removeWhere((key, value) => value == null);

  factory AuthSessionRecord.fromJson(Map<String, dynamic> json) {
    return AuthSessionRecord(
      userId: json['userId'] as String,
      sessionId: json['sessionId'] as String,
      refreshTokenHash: json['refreshTokenHash'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
      expiresAt: _parseDateTime(json['expiresAt']) ?? DateTime.now().toUtc(),
      revokedAt: _parseDateTime(json['revokedAt']),
    );
  }
}

class AuthenticatedSession {
  const AuthenticatedSession({
    required this.userId,
    required this.sessionId,
    required this.isAdHoc,
    required this.emailVerified,
  });

  final String userId;
  final String sessionId;
  final bool isAdHoc;
  final bool emailVerified;
}

class AuthTokenPair {
  const AuthTokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  };
}

class RegisterRequest {
  RegisterRequest({
    required this.userId,
    required this.name,
    required this.dateOfBirth,
    required this.email,
    required this.password,
  });

  final String userId;
  final String name;
  final String dateOfBirth;
  final String email;
  final String password;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }
}

class VerifyEmailRequest {
  VerifyEmailRequest({required this.email, required this.code});

  final String email;
  final String code;

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) {
    return VerifyEmailRequest(
      email: json['email'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }
}

class ResendVerificationCodeRequest {
  ResendVerificationCodeRequest({required this.email});

  final String email;

  factory ResendVerificationCodeRequest.fromJson(Map<String, dynamic> json) {
    return ResendVerificationCodeRequest(email: json['email'] as String? ?? '');
  }
}

class LoginRequest {
  LoginRequest({required this.identifier, required this.password});

  final String identifier;
  final String password;

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      identifier:
          (json['identifier'] ?? json['email'] ?? json['username'] ?? '')
              as String,
      password: json['password'] as String? ?? '',
    );
  }
}

class RefreshRequest {
  RefreshRequest({required this.refreshToken});

  final String refreshToken;

  factory RefreshRequest.fromJson(Map<String, dynamic> json) {
    return RefreshRequest(refreshToken: json['refreshToken'] as String? ?? '');
  }
}

class LogoutRequest {
  LogoutRequest({this.refreshToken});

  final String? refreshToken;

  factory LogoutRequest.fromJson(Map<String, dynamic> json) {
    return LogoutRequest(refreshToken: json['refreshToken'] as String?);
  }
}

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

  final String userId;
  final String name;
  final String username;
  final String password;
  final String? dateOfBirth;
  final List<String> projectIds;
  final String adminPassword;

  factory CreateAdHocUserRequest.fromJson(Map<String, dynamic> json) {
    return CreateAdHocUserRequest(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String?,
      projectIds: (json['projectIds'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      adminPassword: json['adminPassword'] as String? ?? '',
    );
  }
}

class UpdateAdHocProjectsRequest {
  UpdateAdHocProjectsRequest({
    required this.addProjectIds,
    required this.removeProjectIds,
    required this.adminPassword,
  });

  final List<String> addProjectIds;
  final List<String> removeProjectIds;
  final String adminPassword;

  factory UpdateAdHocProjectsRequest.fromJson(Map<String, dynamic> json) {
    return UpdateAdHocProjectsRequest(
      addProjectIds:
          (json['addProjectIds'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<String>()
              .toList(growable: false),
      removeProjectIds:
          (json['removeProjectIds'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<String>()
              .toList(growable: false),
      adminPassword: json['adminPassword'] as String? ?? '',
    );
  }
}

class ResetAdHocPasswordRequest {
  ResetAdHocPasswordRequest({
    required this.adminPassword,
    required this.newPassword,
  });

  final String adminPassword;
  final String newPassword;

  factory ResetAdHocPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetAdHocPasswordRequest(
      adminPassword: json['adminPassword'] as String? ?? '',
      newPassword: json['newPassword'] as String? ?? '',
    );
  }
}

class DeleteAdHocUserRequest {
  DeleteAdHocUserRequest({required this.adminPassword});

  final String adminPassword;

  factory DeleteAdHocUserRequest.fromJson(Map<String, dynamic> json) {
    return DeleteAdHocUserRequest(
      adminPassword: json['adminPassword'] as String? ?? '',
    );
  }
}

class AuthStatusResponse {
  const AuthStatusResponse({required this.status, this.message});

  final String status;
  final String? message;

  Map<String, dynamic> toJson() =>
      {'status': status, 'message': message}
        ..removeWhere((key, value) => value == null);
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

class AdHocUserSummary {
  const AdHocUserSummary({
    required this.userId,
    required this.name,
    required this.username,
    required this.dateOfBirth,
    required this.projectIds,
    required this.status,
  });

  final String userId;
  final String name;
  final String username;
  final String? dateOfBirth;
  final List<String> projectIds;
  final String status;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'username': username,
    'dateOfBirth': dateOfBirth,
    'projectIds': projectIds,
    'status': status,
  }..removeWhere((key, value) => value == null);
}

class AdHocUsersResponse {
  const AdHocUsersResponse({required this.items});

  final List<AdHocUserSummary> items;

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(growable: false),
  };
}

DateTime? _parseDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toUtc();
  }
  return null;
}

String encodeJsonString(Map<String, dynamic> value) => jsonEncode(value);
