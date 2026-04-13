#!/usr/bin/env node

const { spawnSync } = require('node:child_process');

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

function mask(value) {
  if (!value) return '(empty)';
  if (value.length <= 12) return `${value.substring(0, 2)}***`;
  return `${value.substring(0, 6)}...${value.substring(value.length - 6)}`;
}

function main() {
  const args = parseArgs();
  const profile = String(args.profile || 'sltt-dart-prd');
  const stage = String(args.stage || 'prd');
  const region = String(args.region || 'us-east-1');
  const { parameterSuffix, label } = normalizeKind(args.kind);
  const showValue = String(args['show-value'] || 'false') === 'true';

  const parameterName = `/sltt/auth/${stage}/${parameterSuffix}`;
  const baseArgs = [
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
  ];

  try {
    const value = runAwsArgs(baseArgs);
    if (!value) {
      console.log(`No ${label} found at ${parameterName}.`);
      return;
    }

    console.log(`Found ${label} at ${parameterName}.`);
    console.log(`Length: ${value.length}`);
    if (showValue) {
      console.log(`Value: ${value}`);
    } else {
      console.log(`Masked: ${mask(value)}`);
      console.log('Pass --show-value true to print the full secret.');
    }
  } catch (error) {
    const message = `${error.message || error}`;
    if (message.includes('ParameterNotFound')) {
      console.log(`No ${label} found at ${parameterName}.`);
      return;
    }
    throw error;
  }
}

try {
  main();
} catch (error) {
  console.error(error?.message || error);
  process.exit(1);
}
