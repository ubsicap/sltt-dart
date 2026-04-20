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
      defaultFileName: 'jwt-secret.secret',
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
      defaultFileName: 'verification-code-secret.secret',
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

function main() {
  const args = parseArgs();
  const profile = String(args.profile || 'sltt-dart-prd');
  const stage = String(args.stage || 'prd');
  const region = String(args.region || 'us-east-1');
  const secretsDir = String(args['secrets-dir'] || '.secrets');
  const { normalizedKind, parameterSuffix, defaultFileName } = normalizeKind(
    args.kind,
  );

  const secretFile = String(args.file || path.join(secretsDir, defaultFileName));
  if (!fs.existsSync(secretFile)) {
    throw new Error(`Secret file not found: ${secretFile}`);
  }

  const secret = fs.readFileSync(secretFile, 'utf8').trim();
  if (!/^[0-9a-f]{128}$/i.test(secret)) {
    throw new Error(
      `${secretFile} does not contain a valid 128-char hex secret.`,
    );
  }

  const parameterName = `/sltt/auth/${stage}/${parameterSuffix}`;
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

  console.log(`Updated ${normalizedKind} secret in SSM: ${parameterName}`);
  console.log(`Source file: ${secretFile}`);
}

try {
  main();
} catch (error) {
  console.error(error?.message || error);
  process.exit(1);
}
