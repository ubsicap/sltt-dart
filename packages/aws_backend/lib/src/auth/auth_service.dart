import 'dart:convert';
import 'dart:math';

import 'package:aws_common/aws_common.dart';
import 'package:crypto/crypto.dart' as crypto;
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
    required String verificationCodeSecret,
    Duration? verificationLifetime,
    Duration? refreshLifetime,
    Random? random,
    Uuid? uuid,
  }) : _recordStore = recordStore,
       _appStateStore = appStateStore,
       _passwordHashService = passwordHashService,
       _tokenService = tokenService,
       _emailSender = emailSender,
       _verificationCodeSecret = verificationCodeSecret,
       _verificationLifetime =
           verificationLifetime ?? const Duration(minutes: 10),
       _refreshLifetime = refreshLifetime ?? const Duration(days: 30),
       _random = random ?? Random.secure(),
       _uuid = uuid ?? const Uuid();

  final AuthRecordStore _recordStore;
  final AuthAppStateStore _appStateStore;
  final PasswordHashService _passwordHashService;
  final TokenService _tokenService;
  final AuthEmailSender _emailSender;
  final String _verificationCodeSecret;
  final Duration _verificationLifetime;
  final Duration _refreshLifetime;
  final Random _random;
  final Uuid _uuid;

  static const int _fastVerificationCodeMode = 0;

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
    final total = _startTiming();
    final name = request.name.trim();
    final dateOfBirth = request.dateOfBirth.trim();
    final email = request.email.trim();
    final password = request.password;

    try {
      if (name.isEmpty ||
          dateOfBirth.isEmpty ||
          email.isEmpty ||
          password.isEmpty) {
        throw AuthException(
          'Unable to complete this action',
          code: 'invalid_request',
        );
      }
      final normalizedEmail = _normalizeEmail(email);

      var stage = _startTiming();
      final existing = await _recordStore.getPrincipalByEmail(normalizedEmail);
      _logTiming(
        'register.lookupPrincipal',
        stage,
        extra: {'email': normalizedEmail, 'found': existing != null},
      );

      if (existing != null && existing.emailVerified) {
        return const AuthStatusResponse(status: 'pending_verification');
      }

      stage = _startTiming();
      final passwordHash = await _passwordHashService.hashPassword(password);
      _logTiming(
        'register.hashPassword',
        stage,
        extra: {'email': normalizedEmail},
      );

      final now = DateTime.now().toUtc();
      final principal =
          (existing ??
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

      stage = _startTiming();
      await _recordStore.putPrincipal(principal);
      _logTiming(
        'register.putPrincipal',
        stage,
        extra: {'userId': principal.userId},
      );

      stage = _startTiming();
      await _recordStore.putEmailLookup(normalizedEmail, principal.userId);
      _logTiming(
        'register.putEmailLookup',
        stage,
        extra: {'email': normalizedEmail},
      );

      stage = _startTiming();
      await _issueVerificationChallenge(
        principal,
        resendCount: existing == null ? 0 : 1,
      );
      _logTiming(
        'register.issueVerificationChallenge',
        stage,
        extra: {'email': normalizedEmail},
      );
      return const AuthStatusResponse(status: 'pending_verification');
    } finally {
      _logTiming(
        'register.total',
        total,
        extra: {'email': email.trim().toLowerCase()},
      );
    }
  }

  Future<AuthenticatedResponse> verifyEmail(VerifyEmailRequest request) async {
    final total = _startTiming();
    final normalizedEmail = _normalizeEmail(request.email);
    try {
      var stage = _startTiming();
      final principal = await _recordStore.getPrincipalByEmail(normalizedEmail);
      _logTiming(
        'verify.lookupPrincipal',
        stage,
        extra: {'email': normalizedEmail, 'found': principal != null},
      );
      if (principal == null || principal.isDeleted) {
        throw AuthException(
          'Invalid or expired code',
          statusCode: 400,
          code: 'invalid_or_expired_code',
        );
      }

      stage = _startTiming();
      final challenge = await _recordStore.getEmailChallenge(principal.userId);
      _logTiming(
        'verify.getChallenge',
        stage,
        extra: {'userId': principal.userId},
      );
      if (challenge == null ||
          challenge.expiresAt.isBefore(DateTime.now().toUtc())) {
        throw AuthException(
          'Invalid or expired code',
          statusCode: 400,
          code: 'invalid_or_expired_code',
        );
      }

      stage = _startTiming();
      final isCodeValid = await _verifyChallengeCode(
        challenge: challenge,
        code: request.code.trim(),
      );
      _logTiming('verify.checkCode', stage, extra: {'email': normalizedEmail});
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

      stage = _startTiming();
      await _recordStore.putPrincipal(verifiedPrincipal);
      _logTiming(
        'verify.putPrincipal',
        stage,
        extra: {'userId': verifiedPrincipal.userId},
      );

      stage = _startTiming();
      await _recordStore.deleteEmailChallenge(verifiedPrincipal.userId);
      _logTiming(
        'verify.deleteChallenge',
        stage,
        extra: {'userId': verifiedPrincipal.userId},
      );

      stage = _startTiming();
      await _appStateStore.upsertVerifiedUser(verifiedPrincipal);
      _logTiming(
        'verify.upsertVerifiedUser',
        stage,
        extra: {'userId': verifiedPrincipal.userId},
      );

      stage = _startTiming();
      final tokens = await _issueSessionTokens(verifiedPrincipal, now: now);
      _logTiming(
        'verify.issueSessionTokens',
        stage,
        extra: {'userId': verifiedPrincipal.userId},
      );
      return AuthenticatedResponse(
        status: 'verified',
        userId: verifiedPrincipal.userId,
        tokens: tokens,
      );
    } finally {
      _logTiming('verify.total', total, extra: {'email': normalizedEmail});
    }
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
    final total = _startTiming();
    final identifier = request.identifier.trim();
    final password = request.password;
    try {
      if (identifier.isEmpty || password.isEmpty) {
        throw AuthException(
          'Invalid credentials',
          statusCode: 401,
          code: 'invalid_credentials',
        );
      }
      var stage = _startTiming();
      final principal = await _findPrincipalByIdentifier(identifier);
      _logTiming(
        'login.lookupPrincipal',
        stage,
        extra: {'identifier': identifier, 'found': principal != null},
      );
      if (principal == null || principal.isDeleted || !principal.isActive) {
        throw AuthException(
          'Invalid credentials',
          statusCode: 401,
          code: 'invalid_credentials',
        );
      }

      stage = _startTiming();
      final isPasswordValid = await _passwordHashService.verifyPassword(
        password: password,
        expectedHash: principal.passwordHash,
        salt: principal.passwordSalt,
        iterations: principal.passwordIterations,
      );
      _logTiming(
        'login.checkPassword',
        stage,
        extra: {'userId': principal.userId},
      );
      if (!isPasswordValid) {
        throw AuthException(
          'Invalid credentials',
          statusCode: 401,
          code: 'invalid_credentials',
        );
      }

      stage = _startTiming();
      final tokens = await _issueSessionTokens(principal);
      _logTiming(
        'login.issueSessionTokens',
        stage,
        extra: {'userId': principal.userId},
      );
      return AuthenticatedResponse(
        status: 'authenticated',
        userId: principal.userId,
        tokens: tokens,
      );
    } finally {
      _logTiming('login.total', total, extra: {'identifier': identifier});
    }
  }

  Future<AuthenticatedResponse> refresh(RefreshRequest request) async {
    final total = _startTiming();
    if (request.refreshToken.trim().isEmpty) {
      throw AuthException(
        'Invalid credentials',
        statusCode: 401,
        code: 'invalid_credentials',
      );
    }
    try {
      final tokenHash = _tokenService.hashRefreshToken(
        request.refreshToken.trim(),
      );
      var stage = _startTiming();
      final session = await _recordStore.getSessionByTokenHash(tokenHash);
      _logTiming(
        'refresh.getSessionByTokenHash',
        stage,
        extra: {'found': session != null},
      );
      if (session == null ||
          session.isRevoked ||
          session.expiresAt.isBefore(DateTime.now().toUtc())) {
        throw AuthException(
          'Invalid credentials',
          statusCode: 401,
          code: 'invalid_credentials',
        );
      }

      stage = _startTiming();
      final principal = await _recordStore.getPrincipalByUserId(session.userId);
      _logTiming(
        'refresh.getPrincipal',
        stage,
        extra: {'userId': session.userId},
      );
      if (principal == null || principal.isDeleted || !principal.isActive) {
        throw AuthException(
          'Invalid credentials',
          statusCode: 401,
          code: 'invalid_credentials',
        );
      }
      final now = DateTime.now().toUtc();

      stage = _startTiming();
      await _recordStore.revokeSession(session.userId, session.sessionId, now);
      _logTiming(
        'refresh.revokeSession',
        stage,
        extra: {'sessionId': session.sessionId},
      );

      stage = _startTiming();
      final tokenPair = await _issueSessionTokens(principal, now: now);
      _logTiming(
        'refresh.issueSessionTokens',
        stage,
        extra: {'userId': principal.userId},
      );
      return AuthenticatedResponse(
        status: 'authenticated',
        userId: principal.userId,
        tokens: tokenPair,
      );
    } finally {
      _logTiming('refresh.total', total);
    }
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
    if (request?.refreshToken != null &&
        request!.refreshToken!.trim().isNotEmpty) {
      final tokenHash = _tokenService.hashRefreshToken(
        request.refreshToken!.trim(),
      );
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
      throw AuthException(
        'Unable to complete this action',
        code: 'invalid_request',
      );
    }
    final normalizedUsername = _normalizeUsername(username);
    final existing = await _recordStore.getPrincipalByUsername(
      normalizedUsername,
    );
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

  Future<AdHocUsersResponse> listAdHocUsers({
    required AuthenticatedSession session,
  }) async {
    final adminProjects = await _appStateStore.getAdminProjectIdsForUser(
      session.userId,
    );
    if (adminProjects.isEmpty) {
      return const AdHocUsersResponse(items: <AdHocUserSummary>[]);
    }
    final items = await _recordStore.listAdHocPrincipals();
    final visible = items
        .where(
          (principal) =>
              principal.assignedProjectIds.any(adminProjects.contains),
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
    await _requireAdminForProjects(
      session.userId,
      principal.assignedProjectIds,
    );
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
    await _requireAdminForProjects(
      session.userId,
      principal.assignedProjectIds,
    );
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
    final total = _startTiming();
    final issuedAt = (now ?? DateTime.now()).toUtc();
    final sessionId = _uuid.v4();
    try {
      var stage = _startTiming();
      final tokenPair = _tokenService.issueTokens(
        principal: principal,
        sessionId: sessionId,
        now: issuedAt,
      );
      _logTiming(
        'session.issueTokens',
        stage,
        extra: {'userId': principal.userId},
      );

      final session = AuthSessionRecord(
        userId: principal.userId,
        sessionId: sessionId,
        refreshTokenHash: _tokenService.hashRefreshToken(
          tokenPair.refreshToken,
        ),
        createdAt: issuedAt,
        expiresAt: issuedAt.add(_refreshLifetime),
      );

      stage = _startTiming();
      await _recordStore.putSession(session);
      _logTiming('session.putSession', stage, extra: {'sessionId': sessionId});
      return tokenPair;
    } finally {
      _logTiming('session.total', total, extra: {'userId': principal.userId});
    }
  }

  Future<void> _issueVerificationChallenge(
    AuthPrincipal principal, {
    required int resendCount,
  }) async {
    final total = _startTiming();
    final code = _generateCode();
    final now = DateTime.now().toUtc();
    try {
      var stage = _startTiming();
      final challengeVersion = principal.verificationVersion + 1;
      final expiresAt = now.add(_verificationLifetime);
      final codeNonce = _generateNonce();
      final codeHash = _hashVerificationCode(
        userId: principal.userId,
        code: code,
        nonce: codeNonce,
        challengeVersion: challengeVersion,
        expiresAt: expiresAt,
      );
      _logTiming(
        'challenge.hashCode',
        stage,
        extra: {'userId': principal.userId},
      );

      final challenge = AuthEmailChallenge(
        userId: principal.userId,
        codeHash: codeHash,
        codeSalt: codeNonce,
        hashIterations: _fastVerificationCodeMode,
        expiresAt: expiresAt,
        createdAt: now,
        resendCount: resendCount,
        challengeVersion: challengeVersion,
      );

      stage = _startTiming();
      await _recordStore.putEmailChallenge(challenge);
      _logTiming(
        'challenge.putEmailChallenge',
        stage,
        extra: {'userId': principal.userId},
      );

      stage = _startTiming();
      await _emailSender.sendVerificationCode(
        toEmail: principal.email ?? '',
        code: code,
        expiresAt: challenge.expiresAt,
      );
      _logTiming(
        'challenge.sendVerificationCode',
        stage,
        extra: {'email': principal.email ?? ''},
      );
    } finally {
      _logTiming('challenge.total', total, extra: {'userId': principal.userId});
    }
  }

  Future<void> _confirmAdminPassword(
    String userId,
    String adminPassword,
  ) async {
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

  Future<void> _requireAdminForProjects(
    String userId,
    List<String> projectIds,
  ) async {
    final requested = projectIds.where((id) => id.trim().isNotEmpty).toSet();
    if (requested.isEmpty) {
      return;
    }
    final adminProjects = await _appStateStore.getAdminProjectIdsForUser(
      userId,
    );
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

  Future<bool> _verifyChallengeCode({
    required AuthEmailChallenge challenge,
    required String code,
  }) async {
    final expected = _hashVerificationCode(
      userId: challenge.userId,
      code: code,
      nonce: challenge.codeSalt,
      challengeVersion: challenge.challengeVersion,
      expiresAt: challenge.expiresAt,
    );
    return _constantTimeEquals(expected, challenge.codeHash);
  }

  String _generateNonce() {
    final nonceBytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64UrlEncode(nonceBytes);
  }

  String _hashVerificationCode({
    required String userId,
    required String code,
    required String nonce,
    required int challengeVersion,
    required DateTime expiresAt,
  }) {
    final payload =
        '$userId|$nonce|$challengeVersion|${expiresAt.toUtc().toIso8601String()}|$code';
    final hmac = crypto.Hmac(
      crypto.sha256,
      utf8.encode(_verificationCodeSecret),
    );
    return base64UrlEncode(hmac.convert(utf8.encode(payload)).bytes);
  }

  bool _constantTimeEquals(String left, String right) {
    if (left.length != right.length) {
      return false;
    }
    var diff = 0;
    for (var i = 0; i < left.length; i++) {
      diff |= left.codeUnitAt(i) ^ right.codeUnitAt(i);
    }
    return diff == 0;
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();
  String _normalizeUsername(String username) => username.trim().toLowerCase();

  Stopwatch _startTiming() => Stopwatch()..start();

  void _logTiming(
    String operation,
    Stopwatch stopwatch, {
    Map<String, Object?> extra = const {},
  }) {
    final context = extra.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${entry.value}')
        .join(' ');
    final suffix = context.isEmpty ? '' : ' $context';
    SlttLogger.logger.info(
      '[AuthTiming] operation=$operation elapsedMs=${stopwatch.elapsedMilliseconds}$suffix',
    );
  }

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
      verificationCodeSecret: jwtSecret,
      refreshLifetime: Duration(days: refreshDays ?? 30),
    );
  }
}
