import 'dart:math';

import 'package:aws_common/aws_common.dart';
import 'package:sltt_core/sltt_core.dart';
import 'package:uuid/uuid.dart';

import 'auth_app_state_store.dart';
import 'auth_email_sender.dart';
import 'auth_models.dart';
import 'auth_record_store.dart';
import 'password_hash_service.dart';
import 'token_service.dart';

class BackendAuthService {
  BackendAuthService({
    required AuthRecordStore recordStore,
    required AuthAppStateStore appStateStore,
    required PasswordHashService passwordHashService,
    required TokenService tokenService,
    required AuthEmailSender emailSender,
    Duration? verificationLifetime,
    Duration? refreshLifetime,
    Random? random,
    Uuid? uuid,
  }) : _recordStore = recordStore,
       _appStateStore = appStateStore,
       _passwordHashService = passwordHashService,
       _tokenService = tokenService,
       _emailSender = emailSender,
       _verificationLifetime = verificationLifetime ?? const Duration(minutes: 10),
       _refreshLifetime = refreshLifetime ?? const Duration(days: 30),
       _random = random ?? Random.secure(),
       _uuid = uuid ?? const Uuid();

  final AuthRecordStore _recordStore;
  final AuthAppStateStore _appStateStore;
  final PasswordHashService _passwordHashService;
  final TokenService _tokenService;
  final AuthEmailSender _emailSender;
  final Duration _verificationLifetime;
  final Duration _refreshLifetime;
  final Random _random;
  final Uuid _uuid;

  Future<void> initialize() => _recordStore.initialize();
  Future<void> close() => _recordStore.close();

  AuthenticatedSession authenticateBearerToken(String authorizationHeader) {
    final value = authorizationHeader.trim();
    if (!value.toLowerCase().startsWith('bearer ')) {
      throw AuthException(
        'Invalid credentials',
        statusCode: 401,
        code: 'invalid_credentials',
      );
    }
    return _tokenService.verifyAccessToken(value.substring(7));
  }

  Future<AuthStatusResponse> register(RegisterRequest request) async {
    final name = request.name.trim();
    final dateOfBirth = request.dateOfBirth.trim();
    final email = request.email.trim();
    final password = request.password;

    if (name.isEmpty || dateOfBirth.isEmpty || email.isEmpty || password.isEmpty) {
      throw AuthException('Unable to complete this action', code: 'invalid_request');
    }
    final normalizedEmail = _normalizeEmail(email);
    final existing = await _recordStore.getPrincipalByEmail(normalizedEmail);
    if (existing != null && existing.emailVerified) {
      return const AuthStatusResponse(status: 'pending_verification');
    }

    final passwordHash = await _passwordHashService.hashPassword(password);
    final now = DateTime.now().toUtc();
    final principal = (existing ??
            AuthPrincipal(
              userId: _uuid.v4(),
              identityKind: AuthIdentityKind.emailPassword,
              email: email,
              normalizedEmail: normalizedEmail,
              passwordHash: passwordHash.hash,
              passwordSalt: passwordHash.salt,
              passwordIterations: passwordHash.iterations,
              accountStatus: AuthAccountStatus.pendingVerification,
              emailVerified: false,
              isAdHoc: false,
              displayName: name,
              dateOfBirth: dateOfBirth,
              assignedProjectIds: const <String>[],
              verificationVersion: 0,
              createdAt: now,
              updatedAt: now,
            ))
        .copyWith(
          email: email,
          normalizedEmail: normalizedEmail,
          displayName: name,
          dateOfBirth: dateOfBirth,
          passwordHash: passwordHash.hash,
          passwordSalt: passwordHash.salt,
          passwordIterations: passwordHash.iterations,
          accountStatus: AuthAccountStatus.pendingVerification,
          emailVerified: false,
          updatedAt: now,
        );

    await _recordStore.putPrincipal(principal);
    await _recordStore.putEmailLookup(normalizedEmail, principal.userId);
    await _issueVerificationChallenge(principal, resendCount: existing == null ? 0 : 1);
    return const AuthStatusResponse(status: 'pending_verification');
  }

  Future<AuthenticatedResponse> verifyEmail(VerifyEmailRequest request) async {
    final normalizedEmail = _normalizeEmail(request.email);
    final principal = await _recordStore.getPrincipalByEmail(normalizedEmail);
    if (principal == null || principal.isDeleted) {
      throw AuthException(
        'Invalid or expired code',
        statusCode: 400,
        code: 'invalid_or_expired_code',
      );
    }

    final challenge = await _recordStore.getEmailChallenge(principal.userId);
    if (challenge == null || challenge.expiresAt.isBefore(DateTime.now().toUtc())) {
      throw AuthException(
        'Invalid or expired code',
        statusCode: 400,
        code: 'invalid_or_expired_code',
      );
    }
    final isCodeValid = await _passwordHashService.verifyPassword(
      password: request.code.trim(),
      expectedHash: challenge.codeHash,
      salt: challenge.codeSalt,
      iterations: challenge.hashIterations,
    );
    if (!isCodeValid) {
      throw AuthException(
        'Invalid or expired code',
        statusCode: 400,
        code: 'invalid_or_expired_code',
      );
    }

    final now = DateTime.now().toUtc();
    final verifiedPrincipal = principal.copyWith(
      accountStatus: AuthAccountStatus.active,
      emailVerified: true,
      verifiedAt: now,
      updatedAt: now,
      verificationVersion: challenge.challengeVersion,
    );
    await _recordStore.putPrincipal(verifiedPrincipal);
    await _recordStore.deleteEmailChallenge(verifiedPrincipal.userId);
    await _appStateStore.upsertVerifiedUser(verifiedPrincipal);
    final tokens = await _issueSessionTokens(verifiedPrincipal, now: now);
    return AuthenticatedResponse(
      status: 'verified',
      userId: verifiedPrincipal.userId,
      tokens: tokens,
    );
  }

  Future<AuthStatusResponse> resendVerificationCode(
    ResendVerificationCodeRequest request,
  ) async {
    final principal = await _recordStore.getPrincipalByEmail(
      _normalizeEmail(request.email),
    );
    if (principal == null || principal.emailVerified || principal.isDeleted) {
      return const AuthStatusResponse(status: 'sent');
    }
    final existing = await _recordStore.getEmailChallenge(principal.userId);
    await _issueVerificationChallenge(
      principal,
      resendCount: (existing?.resendCount ?? 0) + 1,
    );
    return const AuthStatusResponse(status: 'sent');
  }

  Future<AuthenticatedResponse> login(LoginRequest request) async {
    final identifier = request.identifier.trim();
    final password = request.password;
    if (identifier.isEmpty || password.isEmpty) {
      throw AuthException(
        'Invalid credentials',
        statusCode: 401,
        code: 'invalid_credentials',
      );
    }
    final principal = await _findPrincipalByIdentifier(identifier);
    if (principal == null || principal.isDeleted || !principal.isActive) {
      throw AuthException(
        'Invalid credentials',
        statusCode: 401,
        code: 'invalid_credentials',
      );
    }
    final isPasswordValid = await _passwordHashService.verifyPassword(
      password: password,
      expectedHash: principal.passwordHash,
      salt: principal.passwordSalt,
      iterations: principal.passwordIterations,
    );
    if (!isPasswordValid) {
      throw AuthException(
        'Invalid credentials',
        statusCode: 401,
        code: 'invalid_credentials',
      );
    }
    final tokens = await _issueSessionTokens(principal);
    return AuthenticatedResponse(
      status: 'authenticated',
      userId: principal.userId,
      tokens: tokens,
    );
  }

  Future<AuthenticatedResponse> refresh(RefreshRequest request) async {
    if (request.refreshToken.trim().isEmpty) {
      throw AuthException(
        'Invalid credentials',
        statusCode: 401,
        code: 'invalid_credentials',
      );
    }
    final tokenHash = _tokenService.hashRefreshToken(request.refreshToken.trim());
    final session = await _recordStore.getSessionByTokenHash(tokenHash);
    if (session == null || session.isRevoked || session.expiresAt.isBefore(DateTime.now().toUtc())) {
      throw AuthException(
        'Invalid credentials',
        statusCode: 401,
        code: 'invalid_credentials',
      );
    }
    final principal = await _recordStore.getPrincipalByUserId(session.userId);
    if (principal == null || principal.isDeleted || !principal.isActive) {
      throw AuthException(
        'Invalid credentials',
        statusCode: 401,
        code: 'invalid_credentials',
      );
    }
    final tokenPair = _tokenService.issueTokens(
      principal: principal,
      sessionId: session.sessionId,
      now: DateTime.now().toUtc(),
    );
    return AuthenticatedResponse(
      status: 'authenticated',
      userId: principal.userId,
      tokens: tokenPair,
    );
  }

  Future<AuthStatusResponse> logout({
    required AuthenticatedSession session,
    LogoutRequest? request,
  }) async {
    await _recordStore.revokeSession(
      session.userId,
      session.sessionId,
      DateTime.now().toUtc(),
    );
    if (request?.refreshToken != null && request!.refreshToken!.trim().isNotEmpty) {
      final tokenHash = _tokenService.hashRefreshToken(request.refreshToken!.trim());
      final storedSession = await _recordStore.getSessionByTokenHash(tokenHash);
      if (storedSession != null) {
        await _recordStore.revokeSession(
          storedSession.userId,
          storedSession.sessionId,
          DateTime.now().toUtc(),
        );
      }
    }
    return const AuthStatusResponse(status: 'logged_out');
  }

  Future<AdHocUserSummary> createAdHocUser({
    required AuthenticatedSession session,
    required CreateAdHocUserRequest request,
  }) async {
    await _confirmAdminPassword(session.userId, request.adminPassword);
    await _requireAdminForProjects(session.userId, request.projectIds);
    final username = request.username.trim();
    final name = request.name.trim();
    final password = request.password;
    if (username.isEmpty || name.isEmpty || password.isEmpty) {
      throw AuthException('Unable to complete this action', code: 'invalid_request');
    }
    final normalizedUsername = _normalizeUsername(username);
    final existing = await _recordStore.getPrincipalByUsername(normalizedUsername);
    if (existing != null && !existing.isDeleted) {
      throw AuthException(
        'Unable to complete this action',
        statusCode: 400,
        code: 'unable_to_complete_action',
      );
    }
    final hash = await _passwordHashService.hashPassword(password);
    final now = DateTime.now().toUtc();
    final principal = AuthPrincipal(
      userId: _uuid.v4(),
      identityKind: AuthIdentityKind.usernamePassword,
      username: username,
      normalizedUsername: normalizedUsername,
      passwordHash: hash.hash,
      passwordSalt: hash.salt,
      passwordIterations: hash.iterations,
      accountStatus: AuthAccountStatus.active,
      emailVerified: true,
      isAdHoc: true,
      displayName: name,
      dateOfBirth: request.dateOfBirth?.trim().isEmpty == true
          ? null
          : request.dateOfBirth?.trim(),
      assignedProjectIds: request.projectIds,
      verificationVersion: 0,
      createdAt: now,
      updatedAt: now,
      verifiedAt: now,
    );
    await _recordStore.putPrincipal(principal);
    await _recordStore.putUsernameLookup(normalizedUsername, principal.userId);
    await _appStateStore.upsertVerifiedUser(principal);
    await _appStateStore.syncProjectAssignments(
      principal: principal,
      previousProjectIds: const <String>[],
    );
    return _toAdHocSummary(principal);
  }

  Future<AdHocUsersResponse> listAdHocUsers({required AuthenticatedSession session}) async {
    final adminProjects = await _appStateStore.getAdminProjectIdsForUser(session.userId);
    if (adminProjects.isEmpty) {
      return const AdHocUsersResponse(items: <AdHocUserSummary>[]);
    }
    final items = await _recordStore.listAdHocPrincipals();
    final visible = items
        .where(
          (principal) => principal.assignedProjectIds.any(adminProjects.contains),
        )
        .map(_toAdHocSummary)
        .toList(growable: false);
    return AdHocUsersResponse(items: visible);
  }

  Future<AdHocUserSummary> updateAdHocProjects({
    required AuthenticatedSession session,
    required String userId,
    required UpdateAdHocProjectsRequest request,
  }) async {
    await _confirmAdminPassword(session.userId, request.adminPassword);
    final principal = await _requireAdHocPrincipal(userId);
    final authorizationProjects = {
      ...principal.assignedProjectIds,
      ...request.projectIds,
    }.toList(growable: false);
    await _requireAdminForProjects(session.userId, authorizationProjects);
    final updated = principal.copyWith(
      assignedProjectIds: request.projectIds,
      updatedAt: DateTime.now().toUtc(),
    );
    await _recordStore.putPrincipal(updated);
    await _appStateStore.syncProjectAssignments(
      principal: updated,
      previousProjectIds: principal.assignedProjectIds,
    );
    return _toAdHocSummary(updated);
  }

  Future<AuthStatusResponse> resetAdHocPassword({
    required AuthenticatedSession session,
    required String userId,
    required ResetAdHocPasswordRequest request,
  }) async {
    await _confirmAdminPassword(session.userId, request.adminPassword);
    final principal = await _requireAdHocPrincipal(userId);
    await _requireAdminForProjects(session.userId, principal.assignedProjectIds);
    final hash = await _passwordHashService.hashPassword(request.newPassword);
    await _recordStore.putPrincipal(
      principal.copyWith(
        passwordHash: hash.hash,
        passwordSalt: hash.salt,
        passwordIterations: hash.iterations,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    await _recordStore.revokeAllSessionsForUser(userId, DateTime.now().toUtc());
    return const AuthStatusResponse(status: 'password_updated');
  }

  Future<AuthStatusResponse> deleteAdHocUser({
    required AuthenticatedSession session,
    required String userId,
    required DeleteAdHocUserRequest request,
  }) async {
    await _confirmAdminPassword(session.userId, request.adminPassword);
    final principal = await _requireAdHocPrincipal(userId);
    await _requireAdminForProjects(session.userId, principal.assignedProjectIds);
    final deleted = principal.copyWith(
      accountStatus: AuthAccountStatus.deleted,
      deletedAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    await _recordStore.putPrincipal(deleted);
    await _recordStore.revokeAllSessionsForUser(userId, DateTime.now().toUtc());
    await _appStateStore.markUserDeleted(deleted);
    return const AuthStatusResponse(status: 'deleted');
  }

  Future<AuthPrincipal?> _findPrincipalByIdentifier(String identifier) async {
    if (identifier.contains('@')) {
      return _recordStore.getPrincipalByEmail(_normalizeEmail(identifier));
    }
    return _recordStore.getPrincipalByUsername(_normalizeUsername(identifier));
  }

  Future<AuthTokenPair> _issueSessionTokens(
    AuthPrincipal principal, {
    DateTime? now,
  }) async {
    final issuedAt = (now ?? DateTime.now()).toUtc();
    final sessionId = _uuid.v4();
    final tokenPair = _tokenService.issueTokens(
      principal: principal,
      sessionId: sessionId,
      now: issuedAt,
    );
    final session = AuthSessionRecord(
      userId: principal.userId,
      sessionId: sessionId,
      refreshTokenHash: _tokenService.hashRefreshToken(tokenPair.refreshToken),
      createdAt: issuedAt,
      expiresAt: issuedAt.add(_refreshLifetime),
    );
    await _recordStore.putSession(session);
    return tokenPair;
  }

  Future<void> _issueVerificationChallenge(
    AuthPrincipal principal, {
    required int resendCount,
  }) async {
    final code = _generateCode();
    final now = DateTime.now().toUtc();
    final codeHash = await _passwordHashService.hashPassword(code);
    final challenge = AuthEmailChallenge(
      userId: principal.userId,
      codeHash: codeHash.hash,
      codeSalt: codeHash.salt,
      hashIterations: codeHash.iterations,
      expiresAt: now.add(_verificationLifetime),
      createdAt: now,
      resendCount: resendCount,
      challengeVersion: principal.verificationVersion + 1,
    );
    await _recordStore.putEmailChallenge(challenge);
    await _emailSender.sendVerificationCode(
      toEmail: principal.email ?? '',
      code: code,
      expiresAt: challenge.expiresAt,
    );
  }

  Future<void> _confirmAdminPassword(String userId, String adminPassword) async {
    final principal = await _recordStore.getPrincipalByUserId(userId);
    if (principal == null || principal.isDeleted) {
      throw AuthException(
        'Invalid credentials',
        statusCode: 401,
        code: 'invalid_credentials',
      );
    }
    final isValid = await _passwordHashService.verifyPassword(
      password: adminPassword,
      expectedHash: principal.passwordHash,
      salt: principal.passwordSalt,
      iterations: principal.passwordIterations,
    );
    if (!isValid) {
      throw AuthException(
        'Invalid credentials',
        statusCode: 401,
        code: 'invalid_credentials',
      );
    }
  }

  Future<void> _requireAdminForProjects(String userId, List<String> projectIds) async {
    final requested = projectIds.where((id) => id.trim().isNotEmpty).toSet();
    if (requested.isEmpty) {
      return;
    }
    final adminProjects = await _appStateStore.getAdminProjectIdsForUser(userId);
    if (!requested.every(adminProjects.contains)) {
      throw AuthException(
        'Unable to complete this action',
        statusCode: 403,
        code: 'insufficient_permissions',
      );
    }
  }

  Future<AuthPrincipal> _requireAdHocPrincipal(String userId) async {
    final principal = await _recordStore.getPrincipalByUserId(userId);
    if (principal == null || !principal.isAdHoc || principal.isDeleted) {
      throw AuthException(
        'Unable to complete this action',
        statusCode: 404,
        code: 'unable_to_complete_action',
      );
    }
    return principal;
  }

  String _generateCode() {
    final value = _random.nextInt(1000000);
    return value.toString().padLeft(6, '0');
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();
  String _normalizeUsername(String username) => username.trim().toLowerCase();

  AdHocUserSummary _toAdHocSummary(AuthPrincipal principal) {
    return AdHocUserSummary(
      userId: principal.userId,
      name: principal.displayName,
      username: principal.username ?? '',
      dateOfBirth: principal.dateOfBirth,
      projectIds: principal.assignedProjectIds,
      status: principal.accountStatus.value,
    );
  }
}

class BackendAuthServiceFactory {
  static BackendAuthService? createFromEnvironment({
    required AWSCredentials credentials,
    required BaseStorageService appStorage,
    required Map<String, String> environment,
    bool useLocalDynamoDB = false,
  }) {
    final authTable = (environment['AUTH_TABLE'] ?? '').trim();
    final jwtSecret = (environment['AUTH_JWT_SECRET'] ?? '').trim();
    if (authTable.isEmpty || jwtSecret.isEmpty) {
      return null;
    }
    final accessMinutes = int.tryParse(
      environment['AUTH_ACCESS_TOKEN_TTL_MINUTES'] ?? '',
    );
    final refreshDays = int.tryParse(
      environment['AUTH_REFRESH_TOKEN_TTL_DAYS'] ?? '',
    );
    final region =
        environment['AWS_REGION'] ??
        environment['AWS_DEFAULT_REGION'] ??
        'us-east-1';

    final store = DynamoAuthRecordStore(
      tableName: authTable,
      credentials: credentials,
      region: region,
      useLocalDynamoDB: useLocalDynamoDB,
    );
    return BackendAuthService(
      recordStore: store,
      appStateStore: AuthAppStateStore(storage: appStorage),
      passwordHashService: PasswordHashService(),
      tokenService: TokenService(
        jwtSecret: jwtSecret,
        accessTokenLifetime: Duration(minutes: accessMinutes ?? 60),
      ),
      emailSender: LogAuthEmailSender(),
      refreshLifetime: Duration(days: refreshDays ?? 30),
    );
  }
}
