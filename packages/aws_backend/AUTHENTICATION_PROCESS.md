# Authentication Process and Security Review

This document summarizes the authentication flow implemented in the AWS backend and provides a practical security review for each stage.

## 1. Authentication process: basic outline

### 1.1 Registration

Flow:

1. Client calls `POST /api/auth/register`.
2. The API layer reads the JSON body and delegates to `BackendAuthService.register(...)`.
3. The service validates required profile fields such as email, password, user id, and name.
4. It normalizes the email and checks for collisions:
   - same email already used by another user
   - same user id already assigned to a different email
   - existing pending or stale verification states
5. A password is hashed using PBKDF2-HMAC-SHA256 with a random per-user salt and the configured iteration count.
6. A principal is created or updated in the auth record store.
7. The user is placed in a pending-verification state unless the flow is a special test-user registration path.
8. A verification challenge is issued and sent to the user's email.
9. The API responds with a status such as `pending_verification`.

Security notes:

- Password hashing uses a strong KDF and unique salt.
- Existing-email checks prevent duplicate registrations.
- Registration intentionally enforces a verification gate before active account status is granted.

### 1.2 Email verification

Flow:

1. Client calls `POST /api/auth/verify-email` with email + verification code.
2. The service looks up the principal by normalized email.
3. It loads the active email challenge associated with that user.
4. It validates:
   - challenge exists
   - challenge has not expired
   - the code has not exceeded the attempt limit
5. The challenge code is verified by hashing it with a secret and challenge metadata and comparing it in constant time.
6. If valid, the principal is marked `emailVerified = true` and `accountStatus = active`.
7. The challenge is deleted.
8. The service creates a verified app profile and issues new session tokens.
9. The API returns an authenticated response with access and refresh tokens.

Security notes:

- Code verification is tied to a secret, nonce, challenge version, and expiry time.
- Expiration and failed-attempt caps reduce brute-force exposure.
- Successful verification immediately creates a usable session.

### 1.3 Login

Flow:

1. Client calls `POST /api/auth/login` with an identifier and password.
2. The service resolves the principal by email or username.
3. It rejects deleted, missing, or inactive users.
4. It verifies the submitted password against the stored PBKDF2 hash.
5. If valid, it issues a new access token and refresh token pair.
6. The refresh token hash is persisted in the session record with an expiry.
7. The API responds with authenticated data.

Security notes:

- Password verification occurs against a stored hash, not plaintext.
- Refresh tokens are not stored in plaintext; only a hash is retained.
- Session creation is server-side and associated to a specific user and session id.

### 1.4 Refresh token flow

Flow:

1. Client calls `POST /api/auth/refresh` with a refresh token.
2. The backend hashes the supplied refresh token and looks it up in the session store.
3. It rejects missing, revoked, or expired sessions.
4. It revokes the current session and issues a fresh token pair.
5. The new tokens are returned to the client.

Security notes:

- This is a rotation pattern, which is better than reusing the same refresh token indefinitely.
- Revoking the old session before issuing the new one reduces token replay risk.

### 1.5 Logout

Flow:

1. Client calls `POST /api/auth/logout` with an authenticated bearer token.
2. The backend extracts the active session from the access token.
3. It revokes the current session.
4. If a refresh token is supplied in the request body, it also revokes the session matching that refresh token hash.
5. The API responds with `logged_out`.

Security notes:

- Session revocation is the main mechanism for invalidating active client sessions.
- Matching the refresh token in the logout request helps ensure the client is not left with a valid refresh token.

---

## 2. Security review by component

### 2.1 Password hashing

Current implementation:

- `PasswordHashService` uses PBKDF2 with HMAC-SHA256.
- Default iteration count is `120000`.
- A unique random 16-byte salt is generated per password.
- Verification re-derives the hash using the stored salt and iteration count.

Safety level: High

Why it is strong:

- PBKDF2 is a well-established password hashing approach.
- Per-password salts prevent precomputed rainbow-table attacks.
- Strong hashing cost makes offline brute force slower.

Recommended changes:

- Consider Argon2id or scrypt if the project wants the strongest modern password KDF available.
- Re-evaluate the iteration count periodically as hardware improves.
- Keep the process consistent across all auth principals and admin flows.

### 2.2 JWT access tokens

Current implementation:

- `TokenService.issueTokens(...)` creates an HS256 JWT.
- Claims include `sub`, `sid`, `adhoc`, `verified`, `kind`, `iat`, and `exp`.
- `verifyAccessToken(...)` validates the signature and rejects invalid tokens.

Safety level: Moderate to High

Why it is reasonably safe:

- JWT signature validation protects against tampering.
- Access tokens are short-lived by default.
- Session identifiers are embedded in the token and checked server-side in the refresh path.

Recommended changes:

- Add issuer/audience claims (`iss`, `aud`) if the backend serves multiple trust boundaries.
- Consider rotating JWT secrets if the service is deployed across multiple environments or instances.
- Ensure the client does not store access tokens in insecure local storage for browser-based apps.
- Prefer short lifetimes and aggressive refresh rotation for high-risk devices.

### 2.3 Refresh tokens and session storage

Current implementation:

- Refresh tokens are created as random 32-byte values and base64url encoded.
- The raw token is not stored in plaintext; only a SHA-256 hash is kept.
- The backend stores a session record with expiry and revocation metadata.
- Refresh token reuse or expiry causes rejection.

Safety level: High

Why it is strong:

- Hashing refresh tokens before persistence reduces risk if storage is compromised.
- Server-side session state allows explicit invalidation.
- Refresh rotation on reuse is in place.

Recommended changes:

- Add replay detection and device binding if the system is exposed to high-risk clients.
- Track multiple active sessions per user and allow explicit “log out all devices.”
- Consider a separate refresh-token rotation policy with a reuse window for suspicious activity.

### 2.4 Email verification challenge

Current implementation:

- Verification codes are generated and HMAC-hashed with a server secret.
- Challenge metadata includes user id, nonce, challenge version, and expiry time.
- The code is compared with a constant-time equality check.
- Failed attempts can invalidate the challenge.
- A static code is used only in non-SES local/test mode.

Safety level: High in production; Moderate in local/test with static code enabled

Why it is strong:

- The code is not stored in plaintext.
- Expiry and rate-limiting reduce brute-force windows.
- The secret is used in a keyed HMAC, not a plain hash.

Recommended changes:

- Keep static verification codes disabled outside explicitly trusted local/dev environments.
- Add IP-based or account-based rate limiting for both sending and validating verification codes.
- Audit email delivery paths to ensure SES or a trusted sender is used in production.
- Do not log raw verification codes or secrets in normal telemetry.

### 2.5 Account status and authorization checks

Current implementation:

- Registration creates a pending account until email verification succeeds.
- Login rejects deleted or inactive users.
- Admin and project access checks use app-state membership checks and permission logic.
- Sensitive actions require additional password confirmation for admin or ad hoc user workflows.

Safety level: High

Why it is strong:

- There are explicit state gates between pending, active, and deleted accounts.
- Access control checks prevent unauthorized mutation of project roles or admin actions.

Recommended changes:

- Review all permission decisions for least-privilege consistency.
- Standardize the error handling and audit logging around denied actions.
- Add explicit authorization tests for each admin and super-admin path.

### 2.6 Logging and operational safety

Current implementation:

- The auth service emits timing and security event logs for registration, login, refresh, verification, and failed attempts.
- It records user ids, email identifiers, source IPs, and operational status.

Safety level: Moderate

Why it is useful:

- Good observability is important for incident response.
- Security events help support audits and abuse detection.

Recommended changes:

- Ensure logs do not contain raw passwords, verification codes, or full secrets.
- Mask or redact email addresses in high-volume logging if retention needs to be limited.
- Review whether source IP collection is appropriate and compliant with the project’s data policy.

---

## 3. Overall assessment

Overall safety level: High for normal production use, with a few operational hardening items.

Strong points:

- Passwords are hashed with a modern KDF and unique salts.
- Verification codes are time-bound and cryptographically protected.
- Refresh tokens are hashed and session-backed.
- Expiry, state checks, and admin confirmation reduce abuse risk.

Recommended priority improvements:

1. Keep static verification-code mode disabled outside local testing.
2. Add stronger abuse controls: rate limiting on login and email verification attempts.
3. Review JWT claims and deployment secret rotation policy.
4. Add stronger refresh-token replay detection and session-device tracking if this service is exposed to user-facing production traffic.
5. Audit logs to ensure they do not expose sensitive authentication data.

## 4. Bottom line

The current authentication design is solid and follows common production patterns: salted password hashing, HMAC-protected verification challenges, JWT access tokens, and hashed server-side refresh sessions. The main remaining work is operational hardening and abuse prevention rather than fundamental redesign.
