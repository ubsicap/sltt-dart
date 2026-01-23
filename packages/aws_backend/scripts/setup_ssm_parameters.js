#!/usr/bin/env node
/**
 * Post-deployment script to set SSM parameters from shared-infra CloudFormation outputs.
 * This creates SSM parameters in the shared account that secondary deployments can reference.
 *
 * Usage:
 *   node setup_ssm_parameters.js [options]
 *
 * Options:
 *   --shared-infra-stage: Shared infra stage (default: prd)
 *   --aws-profile: AWS profile to use (default: sltt-dart-prd)
 *   --aws-region: AWS region (default: us-east-1)
 *
 * Example:
 *   node setup_ssm_parameters.js --shared-infra-stage prd --aws-profile sltt-dart-prd
 */

const { execSync } = require('node:child_process');
const path = require('node:path');

function parseArgs() {
  const args = {};
  process.argv.slice(2).forEach((arg) => {
    if (arg.startsWith('--')) {
      const [key, value] = arg.substring(2).split('=');
      args[key] = value || true;
    }
  });
  return args;
}

function runAws(command, { profile, region } = {}) {
  const profileArg = profile ? ` --profile ${profile}` : '';
  const regionArg = region ? ` --region ${region}` : '';
  const fullCommand = `aws ${command}${profileArg}${regionArg}`;
  try {
    return execSync(fullCommand, { stdio: ['ignore', 'pipe', 'pipe'] })
      .toString()
      .trim();
  } catch (error) {
    throw new Error(
      `AWS command failed: ${fullCommand}\n${error.stderr || error.message}`
    );
  }
}

function main() {
  const args = parseArgs();
  const sharedInfraStage = args['shared-infra-stage'] || 'prd';
  const awsProfile = args['aws-profile'] || 'sltt-dart-prd';
  const awsRegion = args['aws-region'] || 'us-east-1';

  const stackName = `sltt-shared-infra-${sharedInfraStage}`;
  const ssmPrefix = `/sltt/infra/${sharedInfraStage}`;

  console.log(
    `Setting up SSM parameters from shared-infra stack '${stackName}' with profile '${awsProfile}', region '${awsRegion}'.`
  );

  // Get CloudFormation outputs
  let outputs;
  try {
    const outputJson = runAws(
      `cloudformation describe-stacks --stack-name ${stackName} --query "Stacks[0].Outputs" --output json`,
      { profile: awsProfile, region: awsRegion }
    );
    outputs = JSON.parse(outputJson);
  } catch (error) {
    console.error(
      `Error: Unable to retrieve CloudFormation stack '${stackName}'.`
    );
    console.error(error.message);
    process.exit(1);
  }

  if (!outputs || outputs.length === 0) {
    console.error(`No outputs found in stack '${stackName}'.`);
    process.exit(1);
  }

  // Map CloudFormation outputs to SSM parameters
  const outputMap = {
    DynamoDbTableName: `${ssmPrefix}/dynamodb/table-name`,
    DynamoDbTableArn: `${ssmPrefix}/dynamodb/table-arn`,
    MediaBucketName: `${ssmPrefix}/s3/bucket-name`,
    MediaBucketArn: `${ssmPrefix}/s3/bucket-arn`,
    MediaCloudFrontDomainName: `${ssmPrefix}/cloudfront/domain`,
    MediaCloudFrontKeyPairId: `${ssmPrefix}/cloudfront/keypair-id`,
  };

  // Create a map of output keys to values
  const outputValues = {};
  outputs.forEach((output) => {
    outputValues[output.OutputKey] = output.OutputValue;
  });

  // Set SSM parameters from CloudFormation outputs
  const parametersThatShouldExist = Object.keys(outputMap);
  const missingOutputs = parametersThatShouldExist.filter(
    (key) => !outputValues[key]
  );

  if (missingOutputs.length > 0) {
    console.warn(
      `Warning: The following expected CloudFormation outputs are missing: ${missingOutputs.join(', ')}`
    );
  }

  console.log(`\nSetting SSM parameters:`);
  Object.entries(outputMap).forEach(([outputKey, paramName]) => {
    const value = outputValues[outputKey];
    if (value) {
      try {
        runAws(
          `ssm put-parameter --name "${paramName}" --value "${value}" --type String --overwrite`,
          { profile: awsProfile, region: awsRegion }
        );
        console.log(`  ✓ ${paramName}`);
      } catch (error) {
        console.error(`  ✗ ${paramName}`);
        console.error(`    ${error.message}`);
        process.exit(1);
      }
    }
  });

  // Handle CloudFront private key separately (it comes from environment or SSM)
  const cloudFrontPrivateKeyParamName = `${ssmPrefix}/cloudfront/private-key`;
  try {
    const privateKeyValue = runAws(
      `ssm get-parameter --name "/sltt/media/cloudfront/${sharedInfraStage}/MEDIA_CLOUDFRONT_PRIVATE_KEY" --with-decryption --query "Parameter.Value" --output text`,
      { profile: awsProfile, region: awsRegion }
    );
    if (privateKeyValue) {
      runAws(
        `ssm put-parameter --name "${cloudFrontPrivateKeyParamName}" --value "${privateKeyValue}" --type String --overwrite`,
        { profile: awsProfile, region: awsRegion }
      );
      console.log(`  ✓ ${cloudFrontPrivateKeyParamName}`);
    }
  } catch (e) {
    console.log(
      `  ⓘ ${cloudFrontPrivateKeyParamName} (skipped - source parameter not found)`
    );
  }

  // Set account ID and region parameters if they don't exist
  const accountId = runAws('sts get-caller-identity --query Account --output text', {
    profile: awsProfile,
    region: awsRegion,
  });

  try {
    runAws(
      `ssm put-parameter --name "${ssmPrefix}/account-id" --value "${accountId}" --type String --overwrite`,
      { profile: awsProfile, region: awsRegion }
    );
    console.log(`  ✓ ${ssmPrefix}/account-id`);
  } catch (error) {
    console.error(`  ✗ ${ssmPrefix}/account-id`);
    console.error(`    ${error.message}`);
  }

  try {
    runAws(
      `ssm put-parameter --name "${ssmPrefix}/region" --value "${awsRegion}" --type String --overwrite`,
      { profile: awsProfile, region: awsRegion }
    );
    console.log(`  ✓ ${ssmPrefix}/region`);
  } catch (error) {
    console.error(`  ✗ ${ssmPrefix}/region`);
    console.error(`    ${error.message}`);
  }

  console.log(
    `\nDone. SSM parameters are ready for secondary deployments to reference.`
  );
}

try {
  main();
} catch (error) {
  console.error(error?.message || error);
  process.exit(1);
}
