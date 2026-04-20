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
      defaultFileName: 'verification-code-secret.secret',
    };
  }
  throw new Error(
    `Unsupported --kind value: ${rawKind}. Use jwt|verification-code|verification-code-secret.`,
  );
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

function main() {
  const args = parseArgs();
  const { defaultFileName, normalizedKind } = normalizeKind(args.kind);
  const force = String(args.force || 'false') === 'true';
  const secretsDir = String(args['secrets-dir'] || '.secrets');
  const outputFile = String(
    args.file || path.join(secretsDir, defaultFileName),
  );

  const secret = generateHexSecret();

  fs.mkdirSync(path.dirname(outputFile), { recursive: true });
  if (fs.existsSync(outputFile) && !force) {
    throw new Error(
      `${outputFile} already exists. Pass --force true to overwrite.`,
    );
  }

  fs.writeFileSync(outputFile, `${secret}\n`, {
    encoding: 'utf8',
    mode: 0o600,
  });

  console.log(`Generated ${normalizedKind} secret file: ${outputFile}`);
  console.log(`Length: ${secret.length}`);
  console.log('Keep this file private; it is intended to remain gitignored.');
}

try {
  main();
} catch (error) {
  console.error(error?.message || error);
  process.exit(1);
}
