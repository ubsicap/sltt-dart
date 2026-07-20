#!/usr/bin/env node
const { execSync, spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { pathToFileURL } = require('node:url');

function usage() {
  console.error(
    'Usage: grant_shared_infra_access.js <target-account-id> <target-role-name> [shared-infra-stage] [aws-profile] [aws-region]',
  );
  console.error(
    'Example: grant_shared_infra_access.js 123456789012 sltt-v2-secondary-infra-dev-role prd sltt-dart-prd us-east-1',
  );
}

function runAws(args, { profile, region }) {
  const profileArg = profile ? ` --profile ${profile}` : '';
  const regionArg = region ? ` --region ${region}` : '';
  const command = `aws ${args}${profileArg}${regionArg}`;
  return execSync(command, { stdio: ['ignore', 'pipe', 'pipe'] })
    .toString()
    .trim();
}

function runAwsArgs(args, { profile, region }) {
  const finalArgs = [...args];
  if (profile) {
    finalArgs.push('--profile', profile);
  }
  if (region) {
    finalArgs.push('--region', region);
  }
  const result = spawnSync('aws', finalArgs, {
    stdio: ['ignore', 'pipe', 'pipe'],
    shell: false,
  });
  if (result.status !== 0) {
    const stderr = result.stderr ? result.stderr.toString().trim() : '';
    throw new Error(stderr || `aws ${finalArgs.join(' ')} failed`);
  }
  return result.stdout ? result.stdout.toString().trim() : '';
}

function toFileUri(filePath) {
  if (process.platform === 'win32') {
    const normalized = filePath.replace(/\\/g, '/');
    return `file://${normalized}`;
  }
  return pathToFileURL(filePath).toString();
}

function writeJson(filePath, obj) {
  fs.writeFileSync(filePath, JSON.stringify(obj, null, 2), {
    encoding: 'utf8',
  });
}

function main() {
  const argv = process.argv.slice(2);
  const targetAccountId = argv[0] || process.env.TARGET_AWS_ACCOUNT_ID;
  const targetRoleName = argv[1] || process.env.TARGET_AWS_ROLE_NAME;
  const sharedInfraStage =
    argv[2] || process.env.SHARED_INFRA_STAGE_ENV || 'prd';
  const awsProfile = argv[3] || process.env.AWS_PROFILE_ENV || 'sltt-dart-prd';
  const awsRegion = argv[4] || process.env.AWS_REGION_ENV || 'us-east-1';
  // Optional principal override for SSM policies: root | user:<name> | role:<name>
  const principalSpec = argv[5] || process.env.TARGET_PRINCIPAL_SPEC || 'root';

  if (!targetAccountId) {
    usage();
    process.exit(1);
  }

  if (!targetRoleName) {
    console.error('ERROR: target role name is required.');
    process.exit(1);
  }

  const stackName = `sltt-v2-shared-infra-${sharedInfraStage}`;
  console.log(
    `Granting cross-account access to shared infra for account '${targetAccountId}', role '${targetRoleName}', stage '${sharedInfraStage}', profile '${awsProfile}', region '${awsRegion}'.`,
  );

  const tableArn = runAws(
    `cloudformation describe-stacks --stack-name ${stackName} --query "Stacks[0].Outputs[?OutputKey=='DynamoDbTableArn'].OutputValue" --output text`,
    { profile: awsProfile, region: awsRegion },
  );
  const bucketName = runAws(
    `cloudformation describe-stacks --stack-name ${stackName} --query "Stacks[0].Outputs[?OutputKey=='MediaBucketName'].OutputValue" --output text`,
    { profile: awsProfile, region: awsRegion },
  );
  const bucketArn = runAws(
    `cloudformation describe-stacks --stack-name ${stackName} --query "Stacks[0].Outputs[?OutputKey=='MediaBucketArn'].OutputValue" --output text`,
    { profile: awsProfile, region: awsRegion },
  );
  const cloudFrontDistributionId = runAws(
    `cloudformation describe-stacks --stack-name ${stackName} --query "Stacks[0].Outputs[?OutputKey=='MediaCloudFrontDistributionId'].OutputValue" --output text`,
    { profile: awsProfile, region: awsRegion },
  );
  const sharedAccountId = runAws(
    'sts get-caller-identity --query "Account" --output text',
    { profile: awsProfile, region: awsRegion },
  );

  if (!tableArn) {
    throw new Error(`Unable to resolve DynamoDB table ARN from stack ${stackName}.`);
  }
  if (!bucketName) {
    throw new Error(`Unable to resolve S3 bucket name from stack ${stackName}.`);
  }
  if (!cloudFrontDistributionId) {
    throw new Error(
      `Unable to resolve CloudFront distribution ID from stack ${stackName}.`,
    );
  }

  const targetRoleArn = `arn:aws:iam::${targetAccountId}:role/${targetRoleName}`;
  const targetAccountRootArn = `arn:aws:iam::${targetAccountId}:root`;
  const assumedRoleArnPattern = `arn:aws:sts::${targetAccountId}:assumed-role/${targetRoleName}/*`;
  // Resolve SSM principal ARN based on principalSpec (defaults to root)
  let ssmPrincipalArn = targetAccountRootArn;
  if (principalSpec && typeof principalSpec === 'string') {
    const [ptype, pname] = principalSpec.split(':');
    if (ptype === 'user' && pname) {
      ssmPrincipalArn = `arn:aws:iam::${targetAccountId}:user/${pname}`;
    } else if (ptype === 'role' && pname) {
      ssmPrincipalArn = `arn:aws:iam::${targetAccountId}:role/${pname}`;
    } else if (ptype === 'root') {
      ssmPrincipalArn = targetAccountRootArn;
    }
  }

  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'sltt-v2-shared-infra-'));
  const ssmPolicyTemplatePath = path.join(tempDir, 'ssm_resource_policy.json');
  const dynamoPolicyPath = path.join(tempDir, 'dynamodb_resource_policy.json');
  const s3PolicyPath = path.join(tempDir, 's3_bucket_policy.json');

  writeJson(ssmPolicyTemplatePath, {
    Version: '2012-10-17',
    Statement: [
      {
        Sid: 'AllowCrossAccountSsmRead',
        Effect: 'Allow',
        Principal: { AWS: targetAccountId },
        Action: [
          'ssm:GetParameter',
          'ssm:GetParameters',
          'ssm:GetParametersByPath',
        ],
        Resource: '*',
      },
    ],
  });

  writeJson(dynamoPolicyPath, {
    Version: '2012-10-17',
    Statement: [
      {
        Sid: 'AllowCrossAccountApiAccess',
        Effect: 'Allow',
        Principal: { AWS: targetAccountRootArn },
        Action: [
          'dynamodb:GetItem',
          'dynamodb:PutItem',
          'dynamodb:UpdateItem',
          'dynamodb:DeleteItem',
          'dynamodb:Query',
          'dynamodb:Scan',
          'dynamodb:BatchGetItem',
          'dynamodb:BatchWriteItem',
          'dynamodb:DescribeTable',
        ],
        Resource: [tableArn, `${tableArn}/index/*`],
        Condition: {
          ArnLike: { 'aws:PrincipalArn': [targetRoleArn, assumedRoleArnPattern] },
        },
      },
    ],
  });

  const ssmParamNames = runAws(
    `ssm get-parameters-by-path --path /sltt/infra/${sharedInfraStage} --recursive --query "Parameters[].Name" --output text`,
    { profile: awsProfile, region: awsRegion },
  );

  if (ssmParamNames) {
    for (const paramName of ssmParamNames.split(/\s+/).filter(Boolean)) {
      const paramArn = `arn:aws:ssm:${awsRegion}:${sharedAccountId}:parameter/${paramName.replace(/^\//, '')}`;

      // Delete existing policy if present
      try {
        const getPolicyArgs = ['ssm', 'get-resource-policies', '--resource-arn', paramArn, '--query', 'Policies[0].{PolicyId:PolicyId,PolicyHash:PolicyHash}', '--output', 'json'];
        if (awsProfile) getPolicyArgs.push('--profile', awsProfile);
        if (awsRegion) getPolicyArgs.push('--region', awsRegion);
        const getPolicyResult = spawnSync('aws', getPolicyArgs, { stdio: ['ignore', 'pipe', 'ignore'], shell: false });
        if (getPolicyResult.status === 0 && getPolicyResult.stdout) {
          const policyInfo = JSON.parse(getPolicyResult.stdout.toString().trim());
          if (policyInfo && policyInfo.PolicyId && policyInfo.PolicyHash) {
            const deleteArgs = ['ssm', 'delete-resource-policy', '--resource-arn', paramArn, '--policy-id', policyInfo.PolicyId, '--policy-hash', policyInfo.PolicyHash];
            if (awsProfile) deleteArgs.push('--profile', awsProfile);
            if (awsRegion) deleteArgs.push('--region', awsRegion);
            spawnSync('aws', deleteArgs, { stdio: ['ignore', 'ignore', 'ignore'], shell: false });
          }
        }
      } catch (e) {
        // Ignore if policy doesn't exist
      }

      const ssmPolicy = JSON.stringify({
        Version: '2012-10-17',
        Statement: [
          {
            Sid: 'AllowCrossAccountSsmRead',
            Effect: 'Allow',
            Principal: { AWS: ssmPrincipalArn },
            Action: [
              'ssm:GetParameter',
              'ssm:GetParameters',
            ],
            Resource: paramArn,
          },
        ],
      });
      runAwsArgs(
        ['ssm', 'put-resource-policy', '--resource-arn', paramArn, '--policy', ssmPolicy],
        { profile: awsProfile, region: awsRegion },
      );
    }
  }

  // Get existing S3 bucket policy and merge with new cross-account statement
  let existingS3Policy = { Version: '2012-10-17', Statement: [] };
  try {
    const existingPolicyJson = runAws(
      `s3api get-bucket-policy --bucket ${bucketName} --query "Policy" --output text`,
      { profile: awsProfile, region: awsRegion },
    );
    existingS3Policy = JSON.parse(existingPolicyJson);
  } catch (e) {
    // No existing policy, use empty one
  }

  // Remove any existing cross-account API access statement
  existingS3Policy.Statement = existingS3Policy.Statement.filter(
    stmt => stmt.Sid !== 'AllowCrossAccountApiAccess'
  );

  // Add new cross-account statement
  existingS3Policy.Statement.push({
    Sid: 'AllowCrossAccountApiAccess',
    Effect: 'Allow',
    Principal: { AWS: targetAccountRootArn },
    Action: [
      's3:AbortMultipartUpload',
      's3:GetObject',
      's3:ListBucket',
      's3:ListBucketMultipartUploads',
      's3:ListMultipartUploadParts',
      's3:PutObject',
    ],
    Resource: [bucketArn, `${bucketArn}/*`],
    Condition: {
      ArnLike: { 'aws:PrincipalArn': [targetRoleArn, assumedRoleArnPattern] },
    },
  });

  writeJson(s3PolicyPath, existingS3Policy);

  runAws(
    `dynamodb put-resource-policy --resource-arn ${tableArn} --policy ${toFileUri(dynamoPolicyPath)}`,
    { profile: awsProfile, region: awsRegion },
  );

  runAws(
    `s3api put-bucket-policy --bucket ${bucketName} --policy ${toFileUri(s3PolicyPath)}`,
    { profile: awsProfile, region: awsRegion },
  );

  console.log(
    `Done. Granted cross-account access to ${targetRoleArn} for shared infra ${stackName}.`,
  );
}

try {
  main();
} catch (error) {
  console.error(error?.message || error);
  process.exit(1);
}
