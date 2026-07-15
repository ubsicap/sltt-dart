#!/usr/bin/env node
/**
 * Setup IAM policy in target account to allow reading shared-infra SSM params.
 *
 * Usage:
 *   node setup_target_account_ssm_access.js \
 *     --target-profile sltt-dart-dev \
 *     --principal user:epyle-sltt-dart \
 *     --shared-account 379334555674 \
 *     --stage prd \
 *     --region us-east-1
 *
 * Principal formats:
 *   - root
 *   - user:<userName>
 *   - role:<roleName>
 */

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

function runAwsArgs(args) {
  const result = spawnSync('aws', args, { stdio: ['ignore', 'pipe', 'pipe'], shell: false });
  if (result.status !== 0) {
    const stderr = result.stderr?.toString().trim();
    throw new Error(stderr || `aws ${args.join(' ')} failed`);
  }
  return result.stdout?.toString().trim() ?? '';
}

function main() {
  const args = parseArgs();
  const targetProfile = String(args['target-profile'] || 'sltt-dart-dev');
  const principal = String(args['principal'] || 'root');
  const sharedAccount = String(args['shared-account'] || '379334555674');
  const stage = String(args['stage'] || 'prd');
  const region = String(args['region'] || 'us-east-1');

  const resourceArn = `arn:aws:ssm:${region}:${sharedAccount}:parameter/sltt/infra/${stage}/*`;
  const crossAccountRoleArn = `arn:aws:iam::${sharedAccount}:role/sltt-v1-shared-infra-cross-account-access`;

  const basePolicy = {
    Version: '2012-10-17',
    Statement: [
      {
        Effect: 'Allow',
        Action: ['ssm:GetParameter', 'ssm:GetParameters'],
        Resource: resourceArn,
      },
      {
        Effect: 'Allow',
        Action: ['sts:AssumeRole'],
        Resource: crossAccountRoleArn,
        Condition: {
          StringEquals: {
            'sts:ExternalId': 'sltt-cross-account-access'
          }
        }
      },
    ],
  };

  const principalParts = String(principal).split(':');
  const principalType = principalParts[0];
  const principalName = principalParts[1];

  console.log(`Granting IAM SSM read to ${principal} on ${resourceArn} (profile=${targetProfile})`);

  if (principalType === 'user') {
    runAwsArgs([
      'iam',
      'put-user-policy',
      '--user-name',
      principalName,
      '--policy-name',
      'CrossAccountSSMAccess',
      '--policy-document',
      JSON.stringify(basePolicy),
      '--profile',
      targetProfile,
      '--region',
      region,
    ]);
  } else if (principalType === 'role') {
    runAwsArgs([
      'iam',
      'put-role-policy',
      '--role-name',
      principalName,
      '--policy-name',
      'CrossAccountSSMAccess',
      '--policy-document',
      JSON.stringify(basePolicy),
      '--profile',
      targetProfile,
      '--region',
      region,
    ]);
  } else if (principalType === 'root') {
    console.warn('Warning: Cannot attach IAM policies to root. Provide user:<name> or role:<name>.');
    process.exit(2);
  } else {
    console.error('Error: Unknown principal format. Use root | user:<name> | role:<name>.');
    process.exit(2);
  }

  console.log('Done. IAM policy attached.');
}

try {
  main();
} catch (e) {
  console.error(e?.message || e);
  process.exit(1);
}
