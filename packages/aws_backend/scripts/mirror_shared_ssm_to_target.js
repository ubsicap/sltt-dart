#!/usr/bin/env node
/**
 * Mirror shared-infra SSM parameters into a target account under the same path.
 * Unblocks Serverless variable resolution without relying on cross-account reads.
 *
 * Usage:
 *   node mirror_shared_ssm_to_target.js \
 *     --source-profile sltt-dart-prd \
 *     --target-profile sltt-dart-dev \
 *     --stage prd \
 *     --region us-east-1
 */

const { execSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
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

function runAws(command, profile, region) {
  const profileArg = profile ? ` --profile ${profile}` : '';
  const regionArg = region ? ` --region ${region}` : '';
  const full = `aws ${command}${profileArg}${regionArg}`;
  return execSync(full, { stdio: ['ignore', 'pipe', 'pipe'] }).toString().trim();
}

function getParameterValue(name, profile, region, withDecryption = false) {
  const decryptArg = withDecryption ? ' --with-decryption' : '';
  try {
    return runAws(
      `ssm get-parameter --name "${name}"${decryptArg} --query "Parameter.Value" --output text`,
      profile,
      region,
    );
  } catch (error) {
    if (`${error.message}`.includes('ParameterNotFound')) {
      return null;
    }
    throw error;
  }
}

function putParameter(name, value, type, profile, region) {
  const tempPath = path.join(os.tmpdir(), `sltt-ssm-${Date.now()}-${Math.random()}.txt`);
  try {
    fs.writeFileSync(tempPath, value, { encoding: 'utf8', mode: 0o600 });
    const fileUri = `file://${tempPath.replace(/\\/g, '/')}`;
    runAws(
      `ssm put-parameter --name "${name}" --type ${type} --value "${fileUri}" --overwrite`,
      profile,
      region,
    );
  } finally {
    fs.rmSync(tempPath, { force: true });
  }
}

function main() {
  const args = parseArgs();
  const sourceProfile = String(args['source-profile'] || 'sltt-dart-prd');
  const targetProfile = String(args['target-profile'] || 'sltt-dart-dev');
  const stage = String(args['stage'] || 'prd');
  const region = String(args['region'] || 'us-east-1');

  const stackName = `sltt-shared-infra-${stage}`;
  const ssmPrefix = `/sltt/infra/${stage}`;
  const authPrefix = `/sltt/auth/${stage}`;

  console.log(`Mirroring SSM from '${sourceProfile}' to '${targetProfile}' for ${ssmPrefix} (${region}).`);

  const outputsJson = runAws(
    `cloudformation describe-stacks --stack-name ${stackName} --query "Stacks[0].Outputs" --output json`,
    sourceProfile,
    region,
  );
  const outputs = JSON.parse(outputsJson);
  const values = {};
  for (const o of outputs) values[o.OutputKey] = o.OutputValue;

  const map = {
    DynamoDbTableName: `${ssmPrefix}/dynamodb/table-name`,
    DynamoDbTableArn: `${ssmPrefix}/dynamodb/table-arn`,
    AuthTableName: `${ssmPrefix}/auth/table-name`,
    AuthTableArn: `${ssmPrefix}/auth/table-arn`,
    MediaBucketName: `${ssmPrefix}/s3/bucket-name`,
    MediaBucketArn: `${ssmPrefix}/s3/bucket-arn`,
    MediaCloudFrontDomainName: `${ssmPrefix}/cloudfront/domain`,
    MediaCloudFrontKeyPairId: `${ssmPrefix}/cloudfront/keypair-id`,
  };

  for (const [outputKey, paramName] of Object.entries(map)) {
    const val = values[outputKey];
    if (!val) {
      console.warn(`Skip missing output: ${outputKey}`);
      continue;
    }
    runAws(
      `ssm put-parameter --name "${paramName}" --type String --value "${val}" --overwrite`,
      targetProfile,
      region,
    );
    console.log(`  ✓ ${paramName}`);
  }

  // Private key: copy encrypted value from source account secret to target as String (or SecureString if desired)
  try {
    const tmpPath = path.join(os.tmpdir(), `sltt-mirror-priv-${Date.now()}.pem`);
    const privVal = runAws(
      `ssm get-parameter --name "/sltt/media/cloudfront/${stage}/MEDIA_CLOUDFRONT_PRIVATE_KEY" --with-decryption --query "Parameter.Value" --output text`,
      sourceProfile,
      region,
    );
    if (!privVal) {
      throw new Error('Source private key returned empty value');
    }

    // Write to a temp file to avoid shell quoting issues with multiline values.
    fs.writeFileSync(tmpPath, privVal, { encoding: 'utf8', mode: 0o600 });
    const fileUri = `file://${tmpPath.replace(/\\/g, '/')}`;

    runAws(
      `ssm put-parameter --name "${ssmPrefix}/cloudfront/private-key" --type SecureString --value "${fileUri}" --overwrite`,
      targetProfile,
      region,
    );
    console.log(`  ✓ ${ssmPrefix}/cloudfront/private-key`);

    fs.rmSync(tmpPath, { force: true });
  } catch (e) {
    console.error(`  ✗ ${ssmPrefix}/cloudfront/private-key (source copy failed)`);
    console.error(`    ${e?.message || e}`);
    process.exit(1);
  }

  // Account-id and region
  const accountId = runAws('sts get-caller-identity --query Account --output text', sourceProfile, region);
  runAws(
    `ssm put-parameter --name "${ssmPrefix}/account-id" --type String --value "${accountId}" --overwrite`,
    targetProfile,
    region,
  );
  console.log(`  ✓ ${ssmPrefix}/account-id`);
  runAws(
    `ssm put-parameter --name "${ssmPrefix}/region" --type String --value "${region}" --overwrite`,
    targetProfile,
    region,
  );
  console.log(`  ✓ ${ssmPrefix}/region`);

  const authStringParameters = [
    'access-token-ttl-minutes',
    'refresh-token-ttl-days',
    'email-mode',
    'ses-from-email',
  ];
  for (const key of authStringParameters) {
    const sourceName = `${authPrefix}/${key}`;
    const sourceValue = getParameterValue(sourceName, sourceProfile, region);
    if (!sourceValue) {
      console.warn(`  ⓘ ${sourceName} (not set in source, skipping)`);
      continue;
    }
    runAws(
      `ssm put-parameter --name "${sourceName}" --type String --value "${sourceValue}" --overwrite`,
      targetProfile,
      region,
    );
    console.log(`  ✓ ${sourceName}`);
  }

  const authSecretParameters = ['jwt-secret', 'verification-code-secret'];
  for (const key of authSecretParameters) {
    const sourceName = `${authPrefix}/${key}`;
    const sourceValue = getParameterValue(
      sourceName,
      sourceProfile,
      region,
      true,
    );
    if (!sourceValue) {
      console.warn(`  ⓘ ${sourceName} (not set in source, skipping)`);
      continue;
    }
    putParameter(sourceName, sourceValue, 'SecureString', targetProfile, region);
    console.log(`  ✓ ${sourceName}`);
  }

  console.log('Done. Mirrored SSM parameters into target account.');
}

try {
  main();
} catch (e) {
  console.error(e?.message || e);
  process.exit(1);
}
