// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailAuthPrincipal _$EmailAuthPrincipalFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EmailAuthPrincipal', json, ($checkedConvert) {
      final val = EmailAuthPrincipal(
        userId: $checkedConvert('userId', (v) => v as String),
        identityKind: $checkedConvert(
          'identityKind',
          (v) =>
              $enumDecodeNullable(_$AuthIdentityKindEnumMap, v) ??
              AuthIdentityKind.emailPassword,
        ),
        email: $checkedConvert('email', (v) => v as String),
        normalizedEmail: $checkedConvert('normalizedEmail', (v) => v as String),
        passwordHash: $checkedConvert('passwordHash', (v) => v as String),
        passwordSalt: $checkedConvert('passwordSalt', (v) => v as String),
        passwordIterations: $checkedConvert(
          'passwordIterations',
          (v) => (v as num).toInt(),
        ),
        accountStatus: $checkedConvert(
          'accountStatus',
          (v) => $enumDecode(_$AuthAccountStatusEnumMap, v),
        ),
        emailVerified: $checkedConvert('emailVerified', (v) => v as bool),
        isAdHoc: $checkedConvert('isAdHoc', (v) => v as bool),
        displayName: $checkedConvert('displayName', (v) => v as String),
        dateOfBirth: $checkedConvert('dateOfBirth', (v) => v as String?),
        verifiedAt: $checkedConvert(
          'verifiedAt',
          (v) => _nullableUtcDateTimeFromJson(v),
        ),
        deletedAt: $checkedConvert(
          'deletedAt',
          (v) => _nullableUtcDateTimeFromJson(v),
        ),
        assignedProjectIds: $checkedConvert(
          'assignedProjectIds',
          (v) => _stringListFromJson(v),
        ),
        verificationVersion: $checkedConvert(
          'verificationVersion',
          (v) => (v as num).toInt(),
        ),
        registrationAttemptAt_orig_: $checkedConvert(
          'registrationAttemptAt_orig_',
          (v) => _nullableUtcDateTimeFromJson(v),
        ),
        registrationAttemptAt_last_: $checkedConvert(
          'registrationAttemptAt_last_',
          (v) => _nullableUtcDateTimeFromJson(v),
        ),
        registrationOutcome_orig_: $checkedConvert(
          'registrationOutcome_orig_',
          (v) => v as String?,
        ),
        registrationOutcome_last_: $checkedConvert(
          'registrationOutcome_last_',
          (v) => v as String?,
        ),
        registrationSourceIp_orig_: $checkedConvert(
          'registrationSourceIp_orig_',
          (v) => v as String?,
        ),
        registrationSourceIp_last_: $checkedConvert(
          'registrationSourceIp_last_',
          (v) => v as String?,
        ),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => _requiredUtcDateTimeFromJson(v),
        ),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => _requiredUtcDateTimeFromJson(v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$EmailAuthPrincipalToJson(EmailAuthPrincipal instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'identityKind': _$AuthIdentityKindEnumMap[instance.identityKind]!,
      'passwordHash': instance.passwordHash,
      'passwordSalt': instance.passwordSalt,
      'passwordIterations': instance.passwordIterations,
      'accountStatus': _$AuthAccountStatusEnumMap[instance.accountStatus]!,
      'emailVerified': instance.emailVerified,
      'isAdHoc': instance.isAdHoc,
      'displayName': instance.displayName,
      'dateOfBirth': ?instance.dateOfBirth,
      'verifiedAt': ?_nullableUtcDateTimeToJson(instance.verifiedAt),
      'deletedAt': ?_nullableUtcDateTimeToJson(instance.deletedAt),
      'assignedProjectIds': instance.assignedProjectIds,
      'verificationVersion': instance.verificationVersion,
      'registrationAttemptAt_orig_': ?_nullableUtcDateTimeToJson(
        instance.registrationAttemptAt_orig_,
      ),
      'registrationAttemptAt_last_': ?_nullableUtcDateTimeToJson(
        instance.registrationAttemptAt_last_,
      ),
      'registrationOutcome_orig_': ?instance.registrationOutcome_orig_,
      'registrationOutcome_last_': ?instance.registrationOutcome_last_,
      'registrationSourceIp_orig_': ?instance.registrationSourceIp_orig_,
      'registrationSourceIp_last_': ?instance.registrationSourceIp_last_,
      'createdAt': _requiredUtcDateTimeToJson(instance.createdAt),
      'updatedAt': _requiredUtcDateTimeToJson(instance.updatedAt),
      'email': instance.email,
      'normalizedEmail': instance.normalizedEmail,
    };

const _$AuthIdentityKindEnumMap = {
  AuthIdentityKind.emailPassword: 'email_password',
  AuthIdentityKind.usernamePassword: 'username_password',
};

const _$AuthAccountStatusEnumMap = {
  AuthAccountStatus.pendingVerification: 'pending_verification',
  AuthAccountStatus.active: 'active',
  AuthAccountStatus.deleted: 'deleted',
};

UsernameAuthPrincipal _$UsernameAuthPrincipalFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UsernameAuthPrincipal', json, ($checkedConvert) {
  final val = UsernameAuthPrincipal(
    userId: $checkedConvert('userId', (v) => v as String),
    identityKind: $checkedConvert(
      'identityKind',
      (v) =>
          $enumDecodeNullable(_$AuthIdentityKindEnumMap, v) ??
          AuthIdentityKind.usernamePassword,
    ),
    username: $checkedConvert('username', (v) => v as String),
    normalizedUsername: $checkedConvert(
      'normalizedUsername',
      (v) => v as String,
    ),
    passwordHash: $checkedConvert('passwordHash', (v) => v as String),
    passwordSalt: $checkedConvert('passwordSalt', (v) => v as String),
    passwordIterations: $checkedConvert(
      'passwordIterations',
      (v) => (v as num).toInt(),
    ),
    accountStatus: $checkedConvert(
      'accountStatus',
      (v) => $enumDecode(_$AuthAccountStatusEnumMap, v),
    ),
    emailVerified: $checkedConvert('emailVerified', (v) => v as bool),
    isAdHoc: $checkedConvert('isAdHoc', (v) => v as bool),
    displayName: $checkedConvert('displayName', (v) => v as String),
    dateOfBirth: $checkedConvert('dateOfBirth', (v) => v as String?),
    verifiedAt: $checkedConvert(
      'verifiedAt',
      (v) => _nullableUtcDateTimeFromJson(v),
    ),
    deletedAt: $checkedConvert(
      'deletedAt',
      (v) => _nullableUtcDateTimeFromJson(v),
    ),
    assignedProjectIds: $checkedConvert(
      'assignedProjectIds',
      (v) => _stringListFromJson(v),
    ),
    verificationVersion: $checkedConvert(
      'verificationVersion',
      (v) => (v as num).toInt(),
    ),
    registrationAttemptAt_orig_: $checkedConvert(
      'registrationAttemptAt_orig_',
      (v) => _nullableUtcDateTimeFromJson(v),
    ),
    registrationAttemptAt_last_: $checkedConvert(
      'registrationAttemptAt_last_',
      (v) => _nullableUtcDateTimeFromJson(v),
    ),
    registrationOutcome_orig_: $checkedConvert(
      'registrationOutcome_orig_',
      (v) => v as String?,
    ),
    registrationOutcome_last_: $checkedConvert(
      'registrationOutcome_last_',
      (v) => v as String?,
    ),
    registrationSourceIp_orig_: $checkedConvert(
      'registrationSourceIp_orig_',
      (v) => v as String?,
    ),
    registrationSourceIp_last_: $checkedConvert(
      'registrationSourceIp_last_',
      (v) => v as String?,
    ),
    createdAt: $checkedConvert(
      'createdAt',
      (v) => _requiredUtcDateTimeFromJson(v),
    ),
    updatedAt: $checkedConvert(
      'updatedAt',
      (v) => _requiredUtcDateTimeFromJson(v),
    ),
  );
  return val;
});

Map<String, dynamic> _$UsernameAuthPrincipalToJson(
  UsernameAuthPrincipal instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'identityKind': _$AuthIdentityKindEnumMap[instance.identityKind]!,
  'passwordHash': instance.passwordHash,
  'passwordSalt': instance.passwordSalt,
  'passwordIterations': instance.passwordIterations,
  'accountStatus': _$AuthAccountStatusEnumMap[instance.accountStatus]!,
  'emailVerified': instance.emailVerified,
  'isAdHoc': instance.isAdHoc,
  'displayName': instance.displayName,
  'dateOfBirth': ?instance.dateOfBirth,
  'verifiedAt': ?_nullableUtcDateTimeToJson(instance.verifiedAt),
  'deletedAt': ?_nullableUtcDateTimeToJson(instance.deletedAt),
  'assignedProjectIds': instance.assignedProjectIds,
  'verificationVersion': instance.verificationVersion,
  'registrationAttemptAt_orig_': ?_nullableUtcDateTimeToJson(
    instance.registrationAttemptAt_orig_,
  ),
  'registrationAttemptAt_last_': ?_nullableUtcDateTimeToJson(
    instance.registrationAttemptAt_last_,
  ),
  'registrationOutcome_orig_': ?instance.registrationOutcome_orig_,
  'registrationOutcome_last_': ?instance.registrationOutcome_last_,
  'registrationSourceIp_orig_': ?instance.registrationSourceIp_orig_,
  'registrationSourceIp_last_': ?instance.registrationSourceIp_last_,
  'createdAt': _requiredUtcDateTimeToJson(instance.createdAt),
  'updatedAt': _requiredUtcDateTimeToJson(instance.updatedAt),
  'username': instance.username,
  'normalizedUsername': instance.normalizedUsername,
};

AuthEmailChallenge _$AuthEmailChallengeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AuthEmailChallenge', json, ($checkedConvert) {
      final val = AuthEmailChallenge(
        userId: $checkedConvert('userId', (v) => v as String),
        codeHash: $checkedConvert('codeHash', (v) => v as String? ?? ''),
        codeSalt: $checkedConvert('codeSalt', (v) => v as String? ?? ''),
        hashIterations: $checkedConvert(
          'hashIterations',
          (v) => (v as num?)?.toInt() ?? 1,
        ),
        expiresAt: $checkedConvert(
          'expiresAt',
          (v) => _requiredUtcDateTimeFromJson(v),
        ),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => _requiredUtcDateTimeFromJson(v),
        ),
        resendCount: $checkedConvert(
          'resendCount',
          (v) => (v as num?)?.toInt() ?? 0,
        ),
        failedAttemptCount: $checkedConvert(
          'failedAttemptCount',
          (v) => (v as num?)?.toInt() ?? 0,
        ),
        challengeVersion: $checkedConvert(
          'challengeVersion',
          (v) => (v as num?)?.toInt() ?? 0,
        ),
      );
      return val;
    });

Map<String, dynamic> _$AuthEmailChallengeToJson(AuthEmailChallenge instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'codeHash': instance.codeHash,
      'codeSalt': instance.codeSalt,
      'hashIterations': instance.hashIterations,
      'expiresAt': _requiredUtcDateTimeToJson(instance.expiresAt),
      'createdAt': _requiredUtcDateTimeToJson(instance.createdAt),
      'resendCount': instance.resendCount,
      'failedAttemptCount': instance.failedAttemptCount,
      'challengeVersion': instance.challengeVersion,
    };

AuthSessionRecord _$AuthSessionRecordFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AuthSessionRecord', json, ($checkedConvert) {
      final val = AuthSessionRecord(
        userId: $checkedConvert('userId', (v) => v as String),
        sessionId: $checkedConvert('sessionId', (v) => v as String),
        refreshTokenHash: $checkedConvert(
          'refreshTokenHash',
          (v) => v as String? ?? '',
        ),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => _requiredUtcDateTimeFromJson(v),
        ),
        expiresAt: $checkedConvert(
          'expiresAt',
          (v) => _requiredUtcDateTimeFromJson(v),
        ),
        revokedAt: $checkedConvert(
          'revokedAt',
          (v) => _nullableUtcDateTimeFromJson(v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AuthSessionRecordToJson(AuthSessionRecord instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'sessionId': instance.sessionId,
      'refreshTokenHash': instance.refreshTokenHash,
      'createdAt': _requiredUtcDateTimeToJson(instance.createdAt),
      'expiresAt': _requiredUtcDateTimeToJson(instance.expiresAt),
      'revokedAt': ?_nullableUtcDateTimeToJson(instance.revokedAt),
    };

AuthenticatedSession _$AuthenticatedSessionFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AuthenticatedSession', json, ($checkedConvert) {
  final val = AuthenticatedSession(
    userId: $checkedConvert('userId', (v) => v as String? ?? ''),
    sessionId: $checkedConvert('sessionId', (v) => v as String? ?? ''),
    isAdHoc: $checkedConvert('isAdHoc', (v) => v as bool? ?? false),
    emailVerified: $checkedConvert('emailVerified', (v) => v as bool? ?? false),
  );
  return val;
});

Map<String, dynamic> _$AuthenticatedSessionToJson(
  AuthenticatedSession instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'sessionId': instance.sessionId,
  'isAdHoc': instance.isAdHoc,
  'emailVerified': instance.emailVerified,
};

AuthTokenPair _$AuthTokenPairFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AuthTokenPair', json, ($checkedConvert) {
      final val = AuthTokenPair(
        accessToken: $checkedConvert('accessToken', (v) => v as String? ?? ''),
        refreshToken: $checkedConvert(
          'refreshToken',
          (v) => v as String? ?? '',
        ),
        expiresAt: $checkedConvert(
          'expiresAt',
          (v) => _requiredUtcDateTimeFromJson(v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AuthTokenPairToJson(AuthTokenPair instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresAt': _requiredUtcDateTimeToJson(instance.expiresAt),
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RegisterRequest', json, ($checkedConvert) {
      final val = RegisterRequest(
        userId: $checkedConvert('userId', (v) => v as String? ?? ''),
        name: $checkedConvert('name', (v) => v as String? ?? ''),
        dateOfBirth: $checkedConvert('dateOfBirth', (v) => v as String? ?? ''),
        email: $checkedConvert('email', (v) => v as String? ?? ''),
        password: $checkedConvert('password', (v) => v as String? ?? ''),
      );
      return val;
    });

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'dateOfBirth': instance.dateOfBirth,
      'email': instance.email,
      'password': instance.password,
    };

VerifyEmailRequest _$VerifyEmailRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VerifyEmailRequest', json, ($checkedConvert) {
      final val = VerifyEmailRequest(
        email: $checkedConvert('email', (v) => v as String? ?? ''),
        code: $checkedConvert('code', (v) => v as String? ?? ''),
      );
      return val;
    });

Map<String, dynamic> _$VerifyEmailRequestToJson(VerifyEmailRequest instance) =>
    <String, dynamic>{'email': instance.email, 'code': instance.code};

ResendVerificationCodeRequest _$ResendVerificationCodeRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ResendVerificationCodeRequest', json, ($checkedConvert) {
  final val = ResendVerificationCodeRequest(
    email: $checkedConvert('email', (v) => v as String? ?? ''),
  );
  return val;
});

Map<String, dynamic> _$ResendVerificationCodeRequestToJson(
  ResendVerificationCodeRequest instance,
) => <String, dynamic>{'email': instance.email};

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LoginRequest', json, ($checkedConvert) {
      final val = LoginRequest(
        identifier: $checkedConvert(
          'identifier',
          (v) => v as String? ?? '',
          readValue: _readLoginIdentifier,
        ),
        password: $checkedConvert('password', (v) => v as String? ?? ''),
      );
      return val;
    });

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'password': instance.password,
    };

RefreshRequest _$RefreshRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RefreshRequest', json, ($checkedConvert) {
      final val = RefreshRequest(
        refreshToken: $checkedConvert(
          'refreshToken',
          (v) => v as String? ?? '',
        ),
      );
      return val;
    });

Map<String, dynamic> _$RefreshRequestToJson(RefreshRequest instance) =>
    <String, dynamic>{'refreshToken': instance.refreshToken};

LogoutRequest _$LogoutRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LogoutRequest', json, ($checkedConvert) {
      final val = LogoutRequest(
        refreshToken: $checkedConvert('refreshToken', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$LogoutRequestToJson(LogoutRequest instance) =>
    <String, dynamic>{'refreshToken': ?instance.refreshToken};

CreateAdHocUserRequest _$CreateAdHocUserRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateAdHocUserRequest', json, ($checkedConvert) {
  final val = CreateAdHocUserRequest(
    userId: $checkedConvert('userId', (v) => v as String? ?? ''),
    name: $checkedConvert('name', (v) => v as String? ?? ''),
    username: $checkedConvert('username', (v) => v as String? ?? ''),
    password: $checkedConvert('password', (v) => v as String? ?? ''),
    dateOfBirth: $checkedConvert('dateOfBirth', (v) => v as String?),
    projectIds: $checkedConvert(
      'projectIds',
      (v) => v == null ? [] : _stringListFromJson(v),
    ),
    adminPassword: $checkedConvert('adminPassword', (v) => v as String? ?? ''),
  );
  return val;
});

Map<String, dynamic> _$CreateAdHocUserRequestToJson(
  CreateAdHocUserRequest instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'name': instance.name,
  'username': instance.username,
  'password': instance.password,
  'dateOfBirth': ?instance.dateOfBirth,
  'projectIds': instance.projectIds,
  'adminPassword': instance.adminPassword,
};

UpdateAdHocProjectsRequest _$UpdateAdHocProjectsRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateAdHocProjectsRequest', json, ($checkedConvert) {
  final val = UpdateAdHocProjectsRequest(
    addProjectIds: $checkedConvert(
      'addProjectIds',
      (v) => v == null ? [] : _stringListFromJson(v),
    ),
    removeProjectIds: $checkedConvert(
      'removeProjectIds',
      (v) => v == null ? [] : _stringListFromJson(v),
    ),
    adminPassword: $checkedConvert('adminPassword', (v) => v as String? ?? ''),
  );
  return val;
});

Map<String, dynamic> _$UpdateAdHocProjectsRequestToJson(
  UpdateAdHocProjectsRequest instance,
) => <String, dynamic>{
  'addProjectIds': instance.addProjectIds,
  'removeProjectIds': instance.removeProjectIds,
  'adminPassword': instance.adminPassword,
};

ResetAdHocPasswordRequest _$ResetAdHocPasswordRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ResetAdHocPasswordRequest', json, ($checkedConvert) {
  final val = ResetAdHocPasswordRequest(
    adminPassword: $checkedConvert('adminPassword', (v) => v as String? ?? ''),
    newPassword: $checkedConvert('newPassword', (v) => v as String? ?? ''),
  );
  return val;
});

Map<String, dynamic> _$ResetAdHocPasswordRequestToJson(
  ResetAdHocPasswordRequest instance,
) => <String, dynamic>{
  'adminPassword': instance.adminPassword,
  'newPassword': instance.newPassword,
};

DeleteAdHocUserRequest _$DeleteAdHocUserRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DeleteAdHocUserRequest', json, ($checkedConvert) {
  final val = DeleteAdHocUserRequest(
    adminPassword: $checkedConvert('adminPassword', (v) => v as String? ?? ''),
  );
  return val;
});

Map<String, dynamic> _$DeleteAdHocUserRequestToJson(
  DeleteAdHocUserRequest instance,
) => <String, dynamic>{'adminPassword': instance.adminPassword};

AuthStatusResponse _$AuthStatusResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AuthStatusResponse', json, ($checkedConvert) {
      final val = AuthStatusResponse(
        status: $checkedConvert('status', (v) => v as String? ?? ''),
        message: $checkedConvert('message', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$AuthStatusResponseToJson(AuthStatusResponse instance) =>
    <String, dynamic>{'status': instance.status, 'message': ?instance.message};

AuthenticatedResponse _$AuthenticatedResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AuthenticatedResponse', json, ($checkedConvert) {
  final val = AuthenticatedResponse(
    status: $checkedConvert('status', (v) => v as String? ?? ''),
    message: $checkedConvert('message', (v) => v as String?),
    userId: $checkedConvert('userId', (v) => v as String? ?? ''),
    accessToken: $checkedConvert('accessToken', (v) => v as String? ?? ''),
    refreshToken: $checkedConvert('refreshToken', (v) => v as String? ?? ''),
    expiresAt: $checkedConvert(
      'expiresAt',
      (v) => _requiredUtcDateTimeFromJson(v),
    ),
  );
  return val;
});

Map<String, dynamic> _$AuthenticatedResponseToJson(
  AuthenticatedResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'message': ?instance.message,
  'userId': instance.userId,
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'expiresAt': _requiredUtcDateTimeToJson(instance.expiresAt),
};

AdHocUserSummary _$AdHocUserSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AdHocUserSummary', json, ($checkedConvert) {
      final val = AdHocUserSummary(
        userId: $checkedConvert('userId', (v) => v as String? ?? ''),
        name: $checkedConvert('name', (v) => v as String? ?? ''),
        username: $checkedConvert('username', (v) => v as String? ?? ''),
        dateOfBirth: $checkedConvert('dateOfBirth', (v) => v as String?),
        projectIds: $checkedConvert(
          'projectIds',
          (v) => v == null ? [] : _stringListFromJson(v),
        ),
        status: $checkedConvert('status', (v) => v as String? ?? ''),
      );
      return val;
    });

Map<String, dynamic> _$AdHocUserSummaryToJson(AdHocUserSummary instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'username': instance.username,
      'dateOfBirth': ?instance.dateOfBirth,
      'projectIds': instance.projectIds,
      'status': instance.status,
    };

AdHocUsersResponse _$AdHocUsersResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AdHocUsersResponse', json, ($checkedConvert) {
      final val = AdHocUsersResponse(
        items: $checkedConvert(
          'items',
          (v) =>
              (v as List<dynamic>?)
                  ?.map(
                    (e) => AdHocUserSummary.fromJson(e as Map<String, dynamic>),
                  )
                  .toList() ??
              [],
        ),
      );
      return val;
    });

Map<String, dynamic> _$AdHocUsersResponseToJson(AdHocUsersResponse instance) =>
    <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
