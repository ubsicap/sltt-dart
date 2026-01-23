#!/usr/bin/env node
/**
 * Add resource-based policies to SSM parameters in shared account for cross-account access.
 *
 * Usage:
 *   node setup_ssm_resource_policies.js \
 *     --shared-profile sltt-dart-prd \
 *     --target-account 662482841188 \
 *     --stage prd \
 *     --region us-east-1
 */

const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');

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
  const sharedProfile = String(args['shared-profile'] || 'sltt-dart-prd');
  const targetAccount = String(args['target-account'] || '662482841188');
  const stage = String(args['stage'] || 'prd');
  const region = String(args['region'] || 'us-east-1');

  // Get shared account ID
  const sharedAccount = runAwsArgs([
    'sts',
    'get-caller-identity',
    '--query',
    'Account',
    '--output',
    'text',
    '--profile',
    sharedProfile,
    '--region',
    region,
  ]);

  console.log(`Setting SSM parameter resource policies for cross-account access:`);
  console.log(`  Shared account: ${sharedAccount} (profile=${sharedProfile})`);
  console.log(`  Target account: ${targetAccount}`);
  console.log(`  Stage: ${stage}, Region: ${region}\n`);

  // List of SSM parameters to grant access to
  const ssmPrefix = `/sltt/infra/${stage}`;
  const parametersToGrant = [
    `${ssmPrefix}/dynamodb/table-name`,
    `${ssmPrefix}/dynamodb/table-arn`,
    `${ssmPrefix}/s3/bucket-name`,
    `${ssmPrefix}/s3/bucket-arn`,
    `${ssmPrefix}/cloudfront/domain`,
    `${ssmPrefix}/cloudfront/keypair-id`,
    `${ssmPrefix}/cloudfront/private-key`,
    `${ssmPrefix}/cross-account-role-arn`,
    `${ssmPrefix}/account-id`,
    `${ssmPrefix}/region`,
  ];

  parametersToGrant.forEach((paramName) => {
    const paramArn = `arn:aws:ssm:${region}:${sharedAccount}:parameter${paramName}`;

    const resourcePolicy = {
      Version: '2012-10-17',
      Statement: [
        {
          Effect: 'Allow',
          Principal: {
            AWS: `arn:aws:iam::${targetAccount}:root`
          },
          Action: ['ssm:GetParameter', 'ssm:GetParameters'],
          Resource: paramArn
        }
      ]
    };

    // Write policy to temp file to avoid shell escaping issues
    const tmpFile = `${os.tmpdir()}/ssm-policy-${Date.now()}.json`;
    fs.writeFileSync(tmpFile, JSON.stringify(resourcePolicy));

    try {
      runAwsArgs([
        'ssm',
        'put-resource-policy',
        '--resource-arn',
        paramArn,
        '--policy',
        `file://${tmpFile}`,
        '--profile',
        sharedProfile,
        '--region',
        region,
      ]);
      console.log(`  ✓ ${paramName}`);
    } catch (error) {
      if (error.message.includes('ParameterNotFound')) {
        console.log(`  ⓘ ${paramName} (parameter doesn't exist, skipping)`);
      } else if (error.message.includes('already exists')) {
        console.log(`  ✓ ${paramName} (policy already exists)`);
      } else {
        console.error(`  ✗ ${paramName}`);
        console.error(`    ${error.message}`);
      }
    } finally {
      // Clean up temp file
      try {
        fs.unlinkSync(tmpFile);
      } catch (e) {
        // Ignore cleanup errors
      }
    }
  });

  console.log('\nDone. SSM parameters now allow cross-account access.');
}

try {
  main();
} catch (e) {
  console.error(e?.message || e);
  process.exit(1);
}
