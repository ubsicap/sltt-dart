#!/usr/bin/env node

const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

function parseArgs() {
  const args = {};
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i++) {
    const token = argv[i];
    if (!token.startsWith('--')) continue;
    const eqIdx = token.indexOf('=');
    if (eqIdx !== -1) {
      const k = token.substring(2, eqIdx);
      const v = token.substring(eqIdx + 1);
      args[k] = v || true;
    } else {
      const k = token.substring(2);
      const next = argv[i + 1];
      if (next && !next.startsWith('--')) {
        args[k] = next;
        i++;
      } else {
        args[k] = true;
      }
    }
  }
  return args;
}

function normalizeKind(rawKind) {
  const kind = String(rawKind || '').trim().toLowerCase();
  if (kind === 'jwt') {
    return {
      normalizedKind: 'jwt',
      parameterSuffix: 'jwt-secret',
      label: 'JWT secret',
      fileName: 'jwt-secret.secret',
      ensureScriptName: 'ensure-jwt-secret:sltt-dart-prd',
    };
  }
  if (
    kind === 'verification-code' ||
    kind === 'verification-code-secret' ||
    kind === 'verification'
  ) {
    return {
      normalizedKind: 'verification-code',
      parameterSuffix: 'verification-code-secret',
      label: 'verification code secret',
      fileName: 'verification-code-secret.secret',
      ensureScriptName: 'ensure-verification-code-secret:sltt-dart-prd',
    };
  }
  throw new Error(
    `Unsupported --kind value: ${rawKind}. Use jwt|verification-code|verification-code-secret.`,
  );
}

function runAwsArgs(args) {
  const result = spawnSync('aws', args, {
    stdio: ['ignore', 'pipe', 'pipe'],
    shell: false,
  });
  if (result.status !== 0) {
    const stderr = result.stderr?.toString().trim();
    throw new Error(stderr || `aws ${args.join(' ')} failed`);
  }
  return result.stdout?.toString().trim() ?? '';
}

function getSsmValue(parameterName, { profile, region }) {
  try {
    return runAwsArgs([
      'ssm',
      'get-parameter',
      '--name',
      parameterName,
      '--with-decryption',
      '--query',
      'Parameter.Value',
      '--output',
      'text',
      '--profile',
      profile,
      '--region',
      region,
    ]);
  } catch (error) {
    const message = `${error.message || error}`;
    if (message.includes('ParameterNotFound')) {
      return null;
    }
    throw error;
  }
}

function generateHexSecret() {
  const result = spawnSync('openssl', ['rand', '-hex', '64'], {
    stdio: ['ignore', 'pipe', 'pipe'],
    shell: false,
  });
  if (result.status !== 0) {
    const stderr = result.stderr?.toString().trim();
    throw new Error(
      stderr || 'Failed to execute openssl rand -hex 64. Is openssl installed?',
    );
  }
  const value = result.stdout?.toString().trim() ?? '';
  if (!/^[0-9a-f]{128}$/i.test(value)) {
    throw new Error('Generated secret is not a 128-char hex string.');
  }
  return value.toLowerCase();
}

function writeSecretFile(secretFile, secret) {
  fs.mkdirSync(path.dirname(secretFile), { recursive: true });
  fs.writeFileSync(secretFile, `${secret}\n`, {
    encoding: 'utf8',
    mode: 0o600,
  });
}

function putSsmSecureString(parameterName, secret, { profile, region }) {
  runAwsArgs([
    'ssm',
    'put-parameter',
    '--name',
    parameterName,
    '--type',
    'SecureString',
    '--value',
    secret,
    '--overwrite',
    '--profile',
    profile,
    '--region',
    region,
  ]);
}

function printBootstrapGuidance({ ensureScriptName }) {
  console.error('Next steps to allow one-time bootstrap for missing secret:');
  console.error('macOS/Linux (bash/zsh):');
  console.error(`  ALLOW_SECRET_BOOTSTRAP=true npm run ${ensureScriptName}`);
  console.error('Windows cmd.exe:');
  console.error(
    `  set ALLOW_SECRET_BOOTSTRAP=true && npm run ${ensureScriptName}`,
  );
  console.error('Windows PowerShell:');
  console.error(
    `  $env:ALLOW_SECRET_BOOTSTRAP='true'; npm run ${ensureScriptName}`,
  );
}

function main() {
  const args = parseArgs();
  const profile = String(args.profile || 'sltt-dart-prd');
  const stage = String(args.stage || 'prd');
  const region = String(args.region || 'us-east-1');
  const secretsDir = String(args['secrets-dir'] || '.secrets');
  const { label, parameterSuffix, fileName, ensureScriptName } = normalizeKind(
    args.kind,
  );

  const bootstrapEnabled =
    String(process.env.ALLOW_SECRET_BOOTSTRAP || 'false').toLowerCase() ===
    'true';

  const parameterName = `/sltt/auth/${stage}/${parameterSuffix}`;
  const existing = getSsmValue(parameterName, { profile, region });
  if (existing && existing.length > 0) {
    console.log(`Found ${label} in SSM: ${parameterName}`);
    return;
  }

  if (!bootstrapEnabled) {
    console.error(`Missing ${label} in SSM: ${parameterName}`);
    console.error(
      'Refusing to auto-create because ALLOW_SECRET_BOOTSTRAP is not true.',
    );
    printBootstrapGuidance({ ensureScriptName });
    process.exit(1);
  }

  const secret = generateHexSecret();
  const secretFile = path.join(secretsDir, fileName);
  writeSecretFile(secretFile, secret);
  putSsmSecureString(parameterName, secret, { profile, region });

  console.log(`Created ${label} in SSM: ${parameterName}`);
  console.log(`Saved generated secret file: ${secretFile}`);
}

try {
  main();
} catch (error) {
  console.error(error?.message || error);
  process.exit(1);
}
