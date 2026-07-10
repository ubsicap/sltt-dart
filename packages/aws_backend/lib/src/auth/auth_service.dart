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
  static const String _authEventSchema = 'auth_event_v1';
  static const int _maxVerificationEmailsPerWindow = 3;
  static const int _maxVerificationCodeAttemptsPerChallenge = 5;

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

  Future<AuthStatusResponse> register(
    RegisterRequest request, {
    String? sourceIp,
  }) async {
    final total = _startTiming();
    final rawUserId = request.userId;
    final rawName = request.name;
    final rawDateOfBirth = request.dateOfBirth;
    final rawEmail = request.email;
    final password = request.password;

    try {
      final validationDetails = validateRegistrationForProfile(
        profile: RegistrationValidationProfile.selfRegistration,
        fields: RegistrationValidationFields(
          userId: rawUserId,
          name: rawName,
          dateOfBirth: rawDateOfBirth,
          email: rawEmail,
          password: password,
        ),
        whitespaceMode: RegistrationValidationWhitespaceMode.strict,
      );
      if (validationDetails.isNotEmpty) {
        _throwInvalidRequest(
          event: 'register_invalid_request',
          details: validationDetails,
          email: rawEmail.trim().isEmpty ? null : _normalizeEmail(rawEmail),
          userId: rawUserId.trim().isEmpty ? null : rawUserId.trim(),
          sourceIp: sourceIp,
          detail: 'invalid_fields',
        );
      }

      final userId = rawUserId.trim();
      final name = rawName.trim();
      final dateOfBirth = rawDateOfBirth.trim();
      final email = rawEmail.trim();
      final normalizedEmail = _normalizeEmail(email);

      var stage = _startTiming();
      final existing = await _recordStore.getPrincipalByEmail(normalizedEmail);
      _logTiming(
        'register.lookupPrincipal',
        stage,
        extra: {'email': normalizedEmail, 'found': existing != null},
      );

      var existingForRegistration = existing;
      var reclaimedStalePendingEmailFromUserId = false;

      if (existing != null && existing.userId != userId) {
        final canReclaimStalePendingEmail =
            existing is EmailAuthPrincipal &&
            !existing.emailVerified &&
            !existing.isDeleted &&
            existing.accountStatus == AuthAccountStatus.pendingVerification &&
            await _isChallengeMissingOrExpired(existing.userId);
        if (canReclaimStalePendingEmail) {
          existingForRegistration = null;
          reclaimedStalePendingEmailFromUserId = true;
          _logAuthEvent(
            'register_reclaimed_stale_pending_email_different_user',
            email: normalizedEmail,
            userId: userId,
            principalUserId: existing.userId,
            sourceIp: sourceIp,
            detail: 'previous_verification_missing_or_expired',
          );
        } else {
          await _recordStore.putPrincipal(
            _withRegistrationMetadata(
              existing,
              outcome: 'register_existing_email_different_user',
              attemptAt: DateTime.now().toUtc(),
              sourceIp: sourceIp,
            ),
          );
          _logAuthEvent(
            'register_existing_email_different_user',
            email: normalizedEmail,
            userId: userId,
            principalUserId: existing.userId,
            sourceIp: sourceIp,
          );
          return const AuthStatusResponse(status: 'pending_verification');
        }
      }

      if (existingForRegistration != null &&
          existingForRegistration.emailVerified) {
        await _recordStore.putPrincipal(
          _withRegistrationMetadata(
            existingForRegistration,
            outcome: 'register_existing_email_same_user_verified',
            attemptAt: DateTime.now().toUtc(),
            sourceIp: sourceIp,
          ),
        );
        _logAuthEvent(
          'register_existing_email_same_user_verified',
          email: normalizedEmail,
          userId: userId,
          principalUserId: existingForRegistration.userId,
          sourceIp: sourceIp,
        );
        return const AuthStatusResponse(status: 'pending_verification');
      }

      stage = _startTiming();
      final existingByUserId = await _recordStore.getPrincipalByUserId(userId);
      _logTiming(
        'register.lookupUserId',
        stage,
        extra: {'userId': userId, 'found': existingByUserId != null},
      );
      if (existingByUserId != null &&
          existingByUserId.normalizedEmail != normalizedEmail) {
        await _recordStore.putPrincipal(
          _withRegistrationMetadata(
            existingByUserId,
            outcome: 'register_existing_user_different_email',
            attemptAt: DateTime.now().toUtc(),
            sourceIp: sourceIp,
          ),
        );
        _logAuthEvent(
          'register_existing_user_different_email',
          email: normalizedEmail,
          userId: userId,
          principalUserId: existingByUserId.userId,
          sourceIp: sourceIp,
        );
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
          (existingForRegistration ??
                  EmailAuthPrincipal(
                    userId: userId,
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
                    registrationAttemptAt_orig_: now,
                    registrationAttemptAt_last_: now,
                    registrationOutcome_orig_: 'register_new',
                    registrationOutcome_last_: 'register_new',
                    registrationSourceIp_orig_: sourceIp,
                    registrationSourceIp_last_: sourceIp,
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
                registrationAttemptAt_orig_: existingForRegistration == null
                    ? now
                    : null,
                registrationAttemptAt_last_: now,
                registrationOutcome_orig_: existingForRegistration == null
                    ? 'register_new'
                    : null,
                registrationOutcome_last_: reclaimedStalePendingEmailFromUserId
                    ? 'register_reclaimed_stale_pending_email_different_user'
                    : existingForRegistration == null
                    ? 'register_new'
                    : 'register_existing_pending_same_user',
                registrationSourceIp_orig_: existingForRegistration == null
                    ? sourceIp
                    : null,
                registrationSourceIp_last_: sourceIp,
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
      final emailPrincipal = _requireEmailPrincipal(
        principal,
        operation: 'register',
      );
      final challengeIssue = await _maybeIssueVerificationChallenge(
        emailPrincipal,
        existingChallenge: existingForRegistration == null
            ? null
            : await _recordStore.getEmailChallenge(emailPrincipal.userId),
        sourceIp: sourceIp,
        clampEvent: 'register_email_clamped',
      );
      _logTiming(
        'register.issueVerificationChallenge',
        stage,
        extra: {'email': normalizedEmail},
      );
      _logAuthEvent(
        reclaimedStalePendingEmailFromUserId
            ? 'register_reclaimed_stale_pending_email_different_user'
            : existingForRegistration == null
            ? 'register_new'
            : 'register_existing_pending_same_user',
        email: normalizedEmail,
        userId: principal.userId,
        sourceIp: sourceIp,
        resendCount: challengeIssue.resendCount,
        detail: challengeIssue.sent
            ? 'verification_email_sent'
            : 'verification_email_clamped',
      );
      return const AuthStatusResponse(status: 'pending_verification');
    } finally {
      _logTiming(
        'register.total',
        total,
        extra: {'email': rawEmail.trim().toLowerCase()},
      );
    }
  }

  Future<AuthenticatedResponse> verifyEmail(
    VerifyEmailRequest request, {
    String? sourceIp,
  }) async {
    final total = _startTiming();
    final email = request.email.trim();
    final code = request.code.trim();
    final normalizedEmail = email.isEmpty ? '' : _normalizeEmail(email);
    try {
      final validationDetails = _requiredFieldDetails({
        'email': email,
        'code': code,
      });
      if (validationDetails.isNotEmpty) {
        _throwInvalidRequest(
          event: 'verify_invalid_request',
          details: validationDetails,
          email: normalizedEmail.isEmpty ? null : normalizedEmail,
          sourceIp: sourceIp,
        );
      }
      var stage = _startTiming();
      final principal = await _recordStore.getPrincipalByEmail(normalizedEmail);
      _logTiming(
        'verify.lookupPrincipal',
        stage,
        extra: {'email': normalizedEmail, 'found': principal != null},
      );
      if (principal == null || principal.isDeleted) {
        _logAuthEvent(
          'verify_invalid_code',
          email: normalizedEmail,
          sourceIp: sourceIp,
          detail: 'principal_missing_or_deleted',
        );
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
      if (challenge == null) {
        _logTiming(
          'verify.challengeState',
          _startTiming(),
          extra: {'userId': principal.userId, 'exists': false},
        );
        _logAuthEvent(
          'verify_invalid_code',
          email: normalizedEmail,
          userId: principal.userId,
          sourceIp: sourceIp,
          detail: 'challenge_not_found',
        );
        throw AuthException(
          'Invalid or expired code',
          statusCode: 400,
          code: 'invalid_or_expired_code',
        );
      }

      final challengeNow = DateTime.now().toUtc();
      final isChallengeExpired = challenge.expiresAt.isBefore(challengeNow);
      final secondsUntilExpiry = challenge.expiresAt
          .difference(challengeNow)
          .inSeconds;
      _logTiming(
        'verify.challengeState',
        _startTiming(),
        extra: {
          'userId': principal.userId,
          'exists': true,
          'isExpired': isChallengeExpired,
          'secondsUntilExpiry': secondsUntilExpiry,
          'expiresAt': challenge.expiresAt.toIso8601String(),
          'resendCount': challenge.resendCount,
          'failedAttemptCount': challenge.failedAttemptCount,
        },
      );
      if (isChallengeExpired) {
        _logAuthEvent(
          'verify_invalid_code',
          email: normalizedEmail,
          userId: principal.userId,
          sourceIp: sourceIp,
          detail: 'challenge_expired',
        );
        throw AuthException(
          'Invalid or expired code',
          statusCode: 400,
          code: 'invalid_or_expired_code',
        );
      }

      stage = _startTiming();
      final isCodeValid = await _verifyChallengeCode(
        challenge: challenge,
        code: code,
      );
      _logTiming('verify.checkCode', stage, extra: {'email': normalizedEmail});
      if (!isCodeValid) {
        final failedAttemptCount = challenge.failedAttemptCount + 1;
        stage = _startTiming();
        if (failedAttemptCount >= _maxVerificationCodeAttemptsPerChallenge) {
          await _recordStore.deleteEmailChallenge(principal.userId);
          _logTiming(
            'verify.deleteChallengeAfterFailedAttempts',
            stage,
            extra: {'userId': principal.userId},
          );
        } else {
          await _recordStore.putEmailChallenge(
            challenge.copyWith(failedAttemptCount: failedAttemptCount),
          );
          _logTiming(
            'verify.putChallengeFailedAttempts',
            stage,
            extra: {
              'userId': principal.userId,
              'failedAttemptCount': failedAttemptCount,
            },
          );
        }
        _logAuthEvent(
          'verify_invalid_code',
          email: normalizedEmail,
          userId: principal.userId,
          sourceIp: sourceIp,
          detail: failedAttemptCount >= _maxVerificationCodeAttemptsPerChallenge
              ? 'code_mismatch_challenge_invalidated'
              : 'code_mismatch',
        );
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
      await _appStateStore.upsertVerifiedUserProfile(
        principal: verifiedPrincipal,
        changeBy: verifiedPrincipal.userId,
      );
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
      _logAuthEvent(
        'verify_success',
        email: normalizedEmail,
        userId: verifiedPrincipal.userId,
        sourceIp: sourceIp,
      );
      return AuthenticatedResponse.fromTokenPair(
        status: 'verified',
        userId: verifiedPrincipal.userId,
        tokens: tokens,
      );
    } finally {
      _logTiming('verify.total', total, extra: {'email': normalizedEmail});
    }
  }

  Future<AuthStatusResponse> resendVerificationCode(
    ResendVerificationCodeRequest request, {
    String? sourceIp,
  }) async {
    final email = request.email.trim();
    final normalizedEmail = email.isEmpty ? '' : _normalizeEmail(email);
    final validationDetails = _requiredFieldDetails({'email': email});
    if (validationDetails.isNotEmpty) {
      _throwInvalidRequest(
        event: 'resend_invalid_request',
        details: validationDetails,
        email: normalizedEmail.isEmpty ? null : normalizedEmail,
        sourceIp: sourceIp,
      );
    }
    final principal = await _recordStore.getPrincipalByEmail(normalizedEmail);
    if (principal == null || principal.emailVerified || principal.isDeleted) {
      _logAuthEvent(
        principal == null
            ? 'resend_missing_email'
            : 'resend_ignored_non_pending_account',
        email: normalizedEmail,
        userId: principal?.userId,
        sourceIp: sourceIp,
      );
      return const AuthStatusResponse(status: 'sent');
    }
    final existing = await _recordStore.getEmailChallenge(principal.userId);
    final emailPrincipal = _requireEmailPrincipal(
      principal,
      operation: 'resendVerificationCode',
    );
    final challengeIssue = await _maybeIssueVerificationChallenge(
      emailPrincipal,
      existingChallenge: existing,
      sourceIp: sourceIp,
      clampEvent: 'resend_email_clamped',
    );
    _logAuthEvent(
      challengeIssue.sent ? 'resend_sent' : 'resend_clamped',
      email: normalizedEmail,
      userId: principal.userId,
      sourceIp: sourceIp,
      resendCount: challengeIssue.resendCount,
    );
    return const AuthStatusResponse(status: 'sent');
  }

  Future<AuthenticatedResponse> login(
    LoginRequest request, {
    String? sourceIp,
  }) async {
    final total = _startTiming();
    final identifier = request.identifier.trim();
    final password = request.password;
    try {
      final validationDetails = _requiredFieldDetails({
        'identifier': identifier,
        'password': password,
      });
      if (validationDetails.isNotEmpty) {
        _throwInvalidRequest(
          event: 'login_invalid_request',
          details: validationDetails,
          identifier: identifier.isEmpty ? null : identifier,
          sourceIp: sourceIp,
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
        _logAuthEvent(
          'login_invalid_credentials',
          identifier: identifier,
          userId: principal?.userId,
          sourceIp: sourceIp,
          detail: 'principal_missing_or_inactive',
        );
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
        _logAuthEvent(
          'login_invalid_credentials',
          identifier: identifier,
          userId: principal.userId,
          sourceIp: sourceIp,
          detail: 'password_mismatch',
        );
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
      _logAuthEvent(
        'login_success',
        identifier: identifier,
        userId: principal.userId,
        sourceIp: sourceIp,
      );
      return AuthenticatedResponse.fromTokenPair(
        status: 'authenticated',
        userId: principal.userId,
        tokens: tokens,
      );
    } finally {
      _logTiming('login.total', total, extra: {'identifier': identifier});
    }
  }

  Future<AuthenticatedResponse> refresh(
    RefreshRequest request, {
    String? sourceIp,
  }) async {
    final total = _startTiming();
    final refreshToken = request.refreshToken.trim();
    if (refreshToken.isEmpty) {
      _throwInvalidRequest(
        event: 'refresh_invalid_request',
        details: const {'refreshToken': 'required'},
        sourceIp: sourceIp,
      );
    }
    try {
      final tokenHash = _tokenService.hashRefreshToken(refreshToken);
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
        _logAuthEvent(
          'refresh_invalid_credentials',
          sourceIp: sourceIp,
          detail: 'session_missing_revoked_or_expired',
        );
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
        _logAuthEvent(
          'refresh_invalid_credentials',
          userId: session.userId,
          sourceIp: sourceIp,
          detail: 'principal_missing_or_inactive',
        );
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
      _logAuthEvent(
        'refresh_success',
        userId: principal.userId,
        sourceIp: sourceIp,
      );
      return AuthenticatedResponse.fromTokenPair(
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

  Map<String, String> _normalizeAdHocProjectRoles(Map<String, String>? roles) {
    final normalized = <String, String>{};
    for (final entry in (roles ?? const <String, String>{}).entries) {
      final projectId = entry.key.trim();
      final role = entry.value.trim();
      if (projectId.isEmpty || role.isEmpty) {
        continue;
      }
      final memberType = MemberType.values.firstWhere(
        (type) => type.name.toLowerCase() == role.toLowerCase(),
        orElse: () => MemberType.unknown,
      );
      if (memberType == MemberType.system ||
          memberType == MemberType.admin ||
          memberType == MemberType.unknown) {
        throw AuthException(
          'Unable to complete this action',
          code: 'invalid_request',
        );
      }
      normalized[projectId] = memberType.name;
    }
    return normalized;
  }

  Future<AdHocUserSummary> createAdHocUser({
    required AuthenticatedSession session,
    required CreateAdHocUserRequest request,
  }) async {
    await _confirmAdminPassword(session.userId, request.adminPassword);
    await _requireAdminForProjects(session.userId, request.projectIds);
    final userId = request.userId.trim();
    final username = request.username.trim();
    final name = request.name.trim();
    final password = request.password;
    final validationDetails = validateRegistrationForProfile(
      profile: RegistrationValidationProfile.adHocAdminRegistration,
      fields: RegistrationValidationFields(
        userId: userId,
        name: name,
        username: username,
        password: password,
        dateOfBirth: request.dateOfBirth,
      ),
      whitespaceMode: RegistrationValidationWhitespaceMode.strict,
    );
    if (validationDetails.isNotEmpty) {
      _throwInvalidRequest(
        event: 'create_adhoc_user_invalid_request',
        details: validationDetails,
      );
    }
    final existingByUserId = await _recordStore.getPrincipalByUserId(userId);
    if (existingByUserId != null) {
      throw AuthException(
        'Unable to complete this action',
        statusCode: 400,
        code: 'invalid_request',
        details: const {
          RegistrationValidationField.userId:
              RegistrationValidationErrorCode.alreadyExists,
        },
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
        code: 'invalid_request',
        details: const {
          RegistrationValidationField.username:
              RegistrationValidationErrorCode.alreadyExists,
        },
      );
    }
    final hash = await _passwordHashService.hashPassword(password);
    final now = DateTime.now().toUtc();
    final requestedRoles = _normalizeAdHocProjectRoles(request.projectRoles);
    final principal = UsernameAuthPrincipal(
      userId: userId,
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
      memberships: {
        for (final projectId in request.projectIds)
          projectId: requestedRoles[projectId] ?? MemberType.translator.name,
      },
      verificationVersion: 0,
      createdAt: now,
      updatedAt: now,
      verifiedAt: now,
    );
    await _recordStore.putPrincipal(principal);
    await _recordStore.putUsernameLookup(normalizedUsername, principal.userId);
    await _appStateStore.upsertVerifiedUserProfile(
      principal: principal,
      changeBy: session.userId,
    );
    await _appStateStore.applyProjectAssignmentChanges(
      principal: principal,
      projectIdsToAdd: request.projectIds,
      projectIdsToRemove: const <String>[],
      changeBy: session.userId,
      projectRoles: {
        for (final projectId in request.projectIds)
          projectId: requestedRoles[projectId] ?? MemberType.translator.name,
      },
    );
    return _toAdHocSummary(principal);
  }

  Future<AdHocUsersResponse> listAdHocUsers({
    required AuthenticatedSession session,
    bool superMode = false,
  }) async {
    final items = await _recordStore.listAdHocPrincipals();
    if (superMode) {
      final all = items
          .whereType<UsernameAuthPrincipal>()
          .map(_toAdHocSummary)
          .toList(growable: false);
      return AdHocUsersResponse(items: all);
    }
    final adminProjects = await _appStateStore.getAdminProjectIdsForUser(
      session.userId,
    );
    if (adminProjects.isEmpty) {
      return const AdHocUsersResponse(items: <AdHocUserSummary>[]);
    }
    final visible = items
        .whereType<UsernameAuthPrincipal>()
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
    final addProjectIds = request.addProjectIds
        .map((projectId) => projectId.trim())
        .where((projectId) => projectId.isNotEmpty)
        .toSet();
    final removeProjectIds = request.removeProjectIds
        .map((projectId) => projectId.trim())
        .where((projectId) => projectId.isNotEmpty)
        .toSet();
    final overlap = addProjectIds.intersection(removeProjectIds);
    if (overlap.isNotEmpty) {
      throw AuthException(
        'Unable to complete this action',
        code: 'invalid_request',
      );
    }
    final requestedRoles = _normalizeAdHocProjectRoles(request.projectRoles);
    await _requireAdminForProjects(
      session.userId,
      {...addProjectIds, ...removeProjectIds}.toList(growable: false),
    );
    final updatedProjectIds = {
      ...principal.assignedProjectIds,
      ...addProjectIds,
    }..removeAll(removeProjectIds);
    final updatedMemberships = Map<String, String>.from(
      principal.memberships ?? const <String, String>{},
    );
    for (final projectId in addProjectIds) {
      updatedMemberships[projectId] =
          requestedRoles[projectId] ?? MemberType.translator.name;
    }
    for (final projectId in removeProjectIds) {
      updatedMemberships.remove(projectId);
    }
    for (final entry in requestedRoles.entries) {
      final projectId = entry.key;
      if (addProjectIds.contains(projectId) ||
          removeProjectIds.contains(projectId)) {
        continue;
      }
      if (!updatedProjectIds.contains(projectId)) {
        continue;
      }
      updatedMemberships[projectId] = entry.value;
    }
    final updated = principal.copyWith(
      assignedProjectIds: updatedProjectIds.toList(growable: false),
      memberships: updatedMemberships,
      updatedAt: DateTime.now().toUtc(),
    );
    await _recordStore.putPrincipal(updated);
    await _appStateStore.applyProjectAssignmentChanges(
      principal: principal,
      projectIdsToAdd: addProjectIds,
      projectIdsToRemove: removeProjectIds,
      changeBy: session.userId,
      projectRoles: {
        for (final projectId in requestedRoles.keys)
          if (!removeProjectIds.contains(projectId))
            projectId: requestedRoles[projectId] ?? MemberType.translator.name,
      },
    );
    return _toAdHocSummary(updated);
  }

  Future<Map<String, dynamic>> updateUserMemberships({
    required AuthenticatedSession session,
    required String userId,
    required UpdateUserMembershipsRequest request,
  }) async {
    await _confirmAdminPassword(session.userId, request.adminPassword);

    final memberAdditions = <String, String>{
      for (final entry in request.memberAdditions.entries)
        entry.key.trim(): entry.value.trim(),
    }..removeWhere((key, value) => key.isEmpty || value.isEmpty);
    final validatedMemberAdditions = <String, String>{};
    for (final entry in memberAdditions.entries) {
      final normalizedRole = entry.value.trim().toLowerCase();
      MemberType? memberType;
      try {
        memberType = MemberType.values.firstWhere(
          (type) => type.name.toLowerCase() == normalizedRole,
        );
      } catch (_) {
        memberType = null;
      }
      if (memberType == null ||
          memberType == MemberType.system ||
          memberType == MemberType.unknown) {
        throw AuthException(
          'Unable to complete this action',
          code: 'invalid_request',
        );
      }
      validatedMemberAdditions[entry.key] = memberType.name;
    }
    final memberRemovals = request.memberRemovals
        .map((projectId) => projectId.trim())
        .where((projectId) => projectId.isNotEmpty)
        .toSet();
    final overlap = validatedMemberAdditions.keys.toSet().intersection(
      memberRemovals,
    );
    if (overlap.isNotEmpty) {
      throw AuthException(
        'Unable to complete this action',
        code: 'invalid_request',
      );
    }

    final principal = await _recordStore.getPrincipalByUserId(userId);
    if (principal == null || principal.isDeleted) {
      throw AuthException(
        'Unable to complete this action',
        statusCode: 404,
        code: 'unable_to_complete_action',
      );
    }

    await _requireAdminForProjects(session.userId, <String>[
      ...validatedMemberAdditions.keys,
      ...memberRemovals,
    ]);

    final updatedProjectIds = {
      ...principal.assignedProjectIds,
      ...validatedMemberAdditions.keys,
    }..removeAll(memberRemovals);
    final updatedMemberships =
        Map<String, String>.from(
            principal.memberships ?? const <String, String>{},
          )
          ..addAll(validatedMemberAdditions)
          ..removeWhere((projectId, _) => memberRemovals.contains(projectId));

    final updated = principal.copyWith(
      assignedProjectIds: updatedProjectIds.toList(growable: false),
      memberships: updatedMemberships,
      updatedAt: DateTime.now().toUtc(),
    );
    await _recordStore.putPrincipal(updated);
    await _appStateStore.upsertVerifiedUserProfile(
      principal: updated,
      changeBy: session.userId,
    );
    await _appStateStore.applyProjectAssignmentChanges(
      principal: updated,
      projectIdsToAdd: validatedMemberAdditions.keys,
      projectIdsToRemove: memberRemovals,
      changeBy: session.userId,
      projectRoles: validatedMemberAdditions,
    );

    return <String, dynamic>{
      'userId': updated.userId,
      'assignedProjectIds': updated.assignedProjectIds,
      'memberships': updated.memberships ?? const <String, String>{},
    };
  }

  Future<void> assignCurrentUserAsAdminToProject({
    required AuthenticatedSession session,
    required String projectId,
  }) async {
    final principal = await _recordStore.getPrincipalByUserId(session.userId);
    if (principal == null || principal.isDeleted) {
      throw AuthException(
        'Unable to complete this action',
        statusCode: 404,
        code: 'unable_to_complete_action',
      );
    }

    final updatedProjectIds = {...principal.assignedProjectIds, projectId}
      ..removeWhere((id) => id.trim().isEmpty);
    final updatedMemberships = Map<String, String>.from(
      principal.memberships ?? const <String, String>{},
    );
    updatedMemberships[projectId] = MemberType.admin.name;

    final updated = principal.copyWith(
      assignedProjectIds: updatedProjectIds.toList(growable: false),
      memberships: updatedMemberships,
      updatedAt: DateTime.now().toUtc(),
    );

    await _recordStore.putPrincipal(updated);
    // await _appStateStore.upsertVerifiedUserProfile(
    //   principal: updated,
    //   changeBy: session.userId,
    // );
    await _appStateStore.applyProjectAssignmentChanges(
      principal: updated,
      projectIdsToAdd: {projectId},
      projectIdsToRemove: const <String>[],
      changeBy: session.userId,
      projectRoles: {projectId: MemberType.admin.name},
    );
  }

  Future<AuthStatusResponse> resetAdHocPassword({
    required AuthenticatedSession session,
    required String userId,
    required ResetAdHocPasswordRequest request,
  }) async {
    await _confirmAdminPassword(session.userId, request.adminPassword);
    final newPassword = request.newPassword;
    if (newPassword.isEmpty) {
      _throwInvalidRequest(
        event: 'reset_adhoc_password_invalid_request',
        details: const {
          RegistrationValidationField.password:
              RegistrationValidationErrorCode.required,
        },
      );
    }
    if (newPassword.length < kMinimumRegistrationPasswordLength) {
      _throwInvalidRequest(
        event: 'reset_adhoc_password_invalid_request',
        details: const {
          RegistrationValidationField.password:
              RegistrationValidationErrorCode.passwordTooWeak,
        },
      );
    }
    final principal = await _requireAdHocPrincipal(userId);
    await _requireAdminForAnyAssignedProject(
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
    await _appStateStore.markUserDeleted(
      principal: deleted,
      changeBy: session.userId,
    );
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
    EmailAuthPrincipal principal, {
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
        failedAttemptCount: 0,
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
        toEmail: principal.email,
        code: code,
        expiresAt: challenge.expiresAt,
      );
      _logTiming(
        'challenge.sendVerificationCode',
        stage,
        extra: {'email': principal.email},
      );
    } finally {
      _logTiming('challenge.total', total, extra: {'userId': principal.userId});
    }
  }

  Future<({bool sent, int resendCount})> _maybeIssueVerificationChallenge(
    EmailAuthPrincipal principal, {
    required AuthEmailChallenge? existingChallenge,
    required String? sourceIp,
    required String clampEvent,
  }) async {
    final now = DateTime.now().toUtc();
    if (existingChallenge != null && existingChallenge.expiresAt.isAfter(now)) {
      final emailsAlreadySent = existingChallenge.resendCount + 1;
      if (emailsAlreadySent >= _maxVerificationEmailsPerWindow) {
        _logAuthEvent(
          clampEvent,
          email: principal.normalizedEmail,
          userId: principal.userId,
          sourceIp: sourceIp,
          resendCount: existingChallenge.resendCount,
          detail: 'max_verification_emails_reached',
        );
        return (sent: false, resendCount: existingChallenge.resendCount);
      }

      final nextResendCount = existingChallenge.resendCount + 1;
      await _issueVerificationChallenge(
        principal,
        resendCount: nextResendCount,
      );
      return (sent: true, resendCount: nextResendCount);
    }

    await _issueVerificationChallenge(principal, resendCount: 0);
    return (sent: true, resendCount: 0);
  }

  Future<bool> _isChallengeMissingOrExpired(String userId) async {
    final challenge = await _recordStore.getEmailChallenge(userId);
    if (challenge == null) {
      return true;
    }

    final now = DateTime.now().toUtc();
    return !challenge.expiresAt.isAfter(now);
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

  Future<void> _requireAdminForAnyAssignedProject(
    String userId,
    List<String> projectIds,
  ) async {
    final requested = projectIds.where((id) => id.trim().isNotEmpty).toSet();
    if (requested.isEmpty) {
      throw AuthException(
        'Unable to complete this action',
        statusCode: 403,
        code: 'insufficient_permissions',
      );
    }
    final adminProjects = await _appStateStore.getAdminProjectIdsForUser(
      userId,
    );
    if (!requested.any(adminProjects.contains)) {
      throw AuthException(
        'Unable to complete this action',
        statusCode: 403,
        code: 'insufficient_permissions',
      );
    }
  }

  Future<UsernameAuthPrincipal> _requireAdHocPrincipal(String userId) async {
    final principal = await _recordStore.getPrincipalByUserId(userId);
    if (principal == null ||
        principal is! UsernameAuthPrincipal ||
        !principal.isAdHoc ||
        principal.isDeleted) {
      throw AuthException(
        'Unable to complete this action',
        statusCode: 404,
        code: 'unable_to_complete_action',
      );
    }
    return principal;
  }

  EmailAuthPrincipal _requireEmailPrincipal(
    AuthPrincipal principal, {
    required String operation,
  }) {
    if (principal is! EmailAuthPrincipal) {
      throw StateError(
        'Expected EmailAuthPrincipal during $operation for user ${principal.userId}',
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
  String _normalizeUsername(String username) =>
      normalizeRegistrationUsername(username);

  Map<String, String> _requiredFieldDetails(Map<String, String> fields) {
    final details = <String, String>{};
    fields.forEach((field, value) {
      if (value.isEmpty) {
        details[field] = 'required';
      }
    });
    return details;
  }

  Never _throwInvalidRequest({
    required String event,
    required Map<String, String> details,
    String? email,
    String? identifier,
    String? userId,
    String? sourceIp,
    String detail = 'missing_required_fields',
  }) {
    _logAuthEvent(
      event,
      email: email,
      identifier: identifier,
      userId: userId,
      sourceIp: sourceIp,
      detail: detail,
      validationDetails: details,
    );
    throw AuthException(
      'Unable to complete this action',
      code: 'invalid_request',
      details: details,
    );
  }

  AuthPrincipal _withRegistrationMetadata(
    AuthPrincipal principal, {
    required String outcome,
    required DateTime attemptAt,
    required String? sourceIp,
  }) {
    return principal.copyWith(
      registrationAttemptAt_orig_:
          principal.registrationAttemptAt_orig_ ?? attemptAt,
      registrationAttemptAt_last_: attemptAt,
      registrationOutcome_orig_: principal.registrationOutcome_orig_ ?? outcome,
      registrationOutcome_last_: outcome,
      registrationSourceIp_orig_:
          principal.registrationSourceIp_orig_ ?? sourceIp,
      registrationSourceIp_last_: sourceIp,
      updatedAt: attemptAt,
    );
  }

  void _logAuthEvent(
    String event, {
    String? email,
    String? identifier,
    String? userId,
    String? principalUserId,
    String? sourceIp,
    int? resendCount,
    String? detail,
    Map<String, String>? validationDetails,
  }) {
    final payload = <String, Object?>{
      'schema': _authEventSchema,
      'event': event,
      'at': DateTime.now().toUtc().toIso8601String(),
      'emailMasked': email == null ? null : _maskEmailForLog(email),
      'emailHash': email == null ? null : _stableHash(email),
      'identifierMasked': identifier == null
          ? null
          : _maskIdentifierForLog(identifier),
      'userId': userId,
      'principalUserId': principalUserId,
      'sourceIpMasked': sourceIp == null ? null : _maskIpForLog(sourceIp),
      'resendCount': resendCount,
      'detail': detail,
      'validationDetails': validationDetails,
    }..removeWhere((key, value) => value == null);
    SlttLogger.logger.info('[AuthEvent] ${jsonEncode(payload)}');
  }

  String _maskEmailForLog(String email) {
    final parts = email.split('@');
    if (parts.length != 2) {
      return _maskIdentifierForLog(email);
    }
    final local = parts.first;
    final maskedLocal = local.length <= 2
        ? '${local.isEmpty ? '*' : local[0]}*'
        : '${local.substring(0, 2)}***';
    return '$maskedLocal@${parts.last}';
  }

  String _maskIdentifierForLog(String identifier) {
    final trimmed = identifier.trim();
    if (trimmed.length <= 3) {
      return '${trimmed.isEmpty ? '*' : trimmed[0]}**';
    }
    return '${trimmed.substring(0, 3)}***';
  }

  String _maskIpForLog(String sourceIp) {
    final trimmed = sourceIp.trim();
    if (trimmed.contains('.')) {
      final parts = trimmed.split('.');
      if (parts.length == 4) {
        return '${parts[0]}.${parts[1]}.${parts[2]}.0';
      }
    }
    if (trimmed.contains(':')) {
      final parts = trimmed.split(':');
      return parts.length <= 2
          ? '$trimmed::*'
          : '${parts.take(2).join(':')}::*';
    }
    return 'unknown';
  }

  String _stableHash(String value) {
    return crypto.sha256
        .convert(utf8.encode(value))
        .toString()
        .substring(0, 16);
  }

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

  AdHocUserSummary _toAdHocSummary(UsernameAuthPrincipal principal) {
    return AdHocUserSummary(
      userId: principal.userId,
      name: principal.displayName,
      username: principal.username,
      dateOfBirth: principal.dateOfBirth,
      projectIds: principal.assignedProjectIds,
      projectRoles: principal.memberships,
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
    Future<AWSCredentials> Function()? credentialsResolver,
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
    final emailMode = (environment['AUTH_EMAIL_MODE'] ?? 'log')
        .trim()
        .toLowerCase();
    final sesFromEmail = (environment['AUTH_SES_FROM_EMAIL'] ?? '').trim();
    final verificationCodeSecret =
        (environment['AUTH_VERIFICATION_CODE_SECRET'] ?? '').trim();
    final region =
        environment['AWS_REGION'] ??
        environment['AWS_DEFAULT_REGION'] ??
        'us-east-1';

    final AuthEmailSender emailSender;
    if (emailMode == 'ses') {
      if (sesFromEmail.isEmpty) {
        throw StateError(
          'AUTH_SES_FROM_EMAIL is required when AUTH_EMAIL_MODE=ses',
        );
      }
      emailSender = SesAuthEmailSender(
        credentials: credentials,
        region: region,
        fromEmail: sesFromEmail,
        credentialsResolver: credentialsResolver,
      );
    } else {
      emailSender = LogAuthEmailSender();
    }

    final store = DynamoAuthRecordStore(
      tableName: authTable,
      credentials: credentials,
      region: region,
      useLocalDynamoDB: useLocalDynamoDB,
      credentialsResolver: credentialsResolver,
    );
    return BackendAuthService(
      recordStore: store,
      appStateStore: AuthAppStateStore(storage: appStorage),
      passwordHashService: PasswordHashService(),
      tokenService: TokenService(
        jwtSecret: jwtSecret,
        accessTokenLifetime: Duration(minutes: accessMinutes ?? 60),
      ),
      emailSender: emailSender,
      verificationCodeSecret: verificationCodeSecret.isEmpty
          ? jwtSecret
          : verificationCodeSecret,
      refreshLifetime: Duration(days: refreshDays ?? 30),
    );
  }
}
