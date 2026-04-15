#!/usr/bin/env node
/**
 * Post-deployment script to set SSM parameters from shared-infra CloudFormation outputs
 * and keep auth configuration parameters in sync for secondary deployments.
 *
 * Usage:
 *   node setup_ssm_parameters.js [options]
 *
 * Options:
 *   --shared-infra-stage: Shared infra stage (default: prd)
 *   --aws-profile: AWS profile to use (default: sltt-dart-prd)
 *   --aws-region: AWS region (default: us-east-1)
 *   --auth-only: Skip shared-infra CloudFormation/SSM sync and only set /sltt/auth/* params
 *   --auth-stage: Auth parameter stage (default: shared-infra-stage)
 *   --auth-email-mode: AUTH_EMAIL_MODE value (default: ses)
 *   --auth-ses-from-email: AUTH_SES_FROM_EMAIL value (default: no-reply@sltt-bible.net)
 *   --auth-access-token-ttl-minutes: AUTH_ACCESS_TOKEN_TTL_MINUTES value (default: 60)
 *   --auth-refresh-token-ttl-days: AUTH_REFRESH_TOKEN_TTL_DAYS value (default: 30)
 *   --auth-jwt-secret: Optional AUTH_JWT_SECRET value to write as SecureString
 *   --verification-code-secret: Optional AUTH_VERIFICATION_CODE_SECRET value to write as SecureString
 *
 * Example:
 *   node setup_ssm_parameters.js --shared-infra-stage prd --aws-profile sltt-dart-prd
 */

const { execSync } = require('node:child_process');
const path = require('node:path');
const fs = require('node:fs');
const os = require('node:os');

function parseArgs() {
  const args = {};
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg.startsWith('--')) {
      const key = arg.substring(2);
      if (key.includes('=')) {
        const [k, v] = key.split('=');
        args[k] = v;
      } else if (i + 1 < argv.length && !argv[i + 1].startsWith('--')) {
        args[key] = argv[++i];
      } else {
        args[key] = true;
      }
    }
  }
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

function putSsmParameter(name, value, { profile, region, type = 'String' } = {}) {
  const profileArg = profile ? ` --profile ${profile}` : '';
  const regionArg = region ? ` --region ${region}` : '';

  // For values with special characters/newlines, write to temp file and use file:// syntax
  if (value.includes('\n') || value.includes('"')) {
    const tempFile = path.join(os.tmpdir(), `ssm-param-${Date.now()}.txt`);
    try {
      fs.writeFileSync(tempFile, value, 'utf8');
      const command = `aws ssm put-parameter --name "${name}" --value file://${tempFile} --type ${type} --overwrite${profileArg}${regionArg}`;
      execSync(command, { stdio: ['ignore', 'pipe', 'pipe'] });
    } finally {
      // Clean up temp file
      try {
        fs.unlinkSync(tempFile);
      } catch (e) {
        // Ignore cleanup errors
      }
    }
  } else {
    const command = `aws ssm put-parameter --name "${name}" --value "${value}" --type ${type} --overwrite${profileArg}${regionArg}`;
    try {
      execSync(command, { stdio: ['ignore', 'pipe', 'pipe'] });
    } catch (error) {
      throw new Error(
        `Failed to put SSM parameter: ${error.stderr || error.message}`
      );
    }
  }
}

function getSsmParameter(name, { profile, region, withDecryption = false } = {}) {
  const decryptArg = withDecryption ? ' --with-decryption' : '';
  try {
    return runAws(
      `ssm get-parameter --name "${name}"${decryptArg} --query "Parameter.Value" --output text`,
      { profile, region }
    );
  } catch (error) {
    if (`${error.message}`.includes('ParameterNotFound')) {
      return null;
    }
    throw error;
  }
}

function main() {
  const args = parseArgs();
  const sharedInfraStage = args['shared-infra-stage'] || 'prd';
  const awsProfile = args['aws-profile'] || 'sltt-dart-prd';
  const awsRegion = args['aws-region'] || 'us-east-1';
  const authOnly =
    args['auth-only'] === true ||
    String(args['auth-only'] || '').toLowerCase() === 'true';
  const authStage = args['auth-stage'] || sharedInfraStage;
  const authEmailMode = args['auth-email-mode'] || 'ses';
  const authSesFromEmail =
    args['auth-ses-from-email'] || 'no-reply@sltt-bible.net';
  const authAccessTokenTtlMinutes =
    args['auth-access-token-ttl-minutes'] || '60';
  const authRefreshTokenTtlDays =
    args['auth-refresh-token-ttl-days'] || '30';
  const authJwtSecret = args['auth-jwt-secret'];
  const verificationCodeSecret = args['verification-code-secret'];

  const stackName = `sltt-shared-infra-${sharedInfraStage}`;
  const ssmPrefix = `/sltt/infra/${sharedInfraStage}`;
  const authPrefix = `/sltt/auth/${authStage}`;

  if (!authOnly) {
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
      AuthTableName: `${ssmPrefix}/auth/table-name`,
      AuthTableArn: `${ssmPrefix}/auth/table-arn`,
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
      if (privateKeyValue && privateKeyValue.length > 0) {
        // Use safe parameter setting for values with newlines
        putSsmParameter(cloudFrontPrivateKeyParamName, privateKeyValue, {
          profile: awsProfile,
          region: awsRegion,
        });
        // Display truncated version for verification
        const truncated = privateKeyValue.substring(0, 50) + '...';
        console.log(`  ✓ ${cloudFrontPrivateKeyParamName} (already set - ${truncated})`);
      } else {
        throw new Error('CloudFront private key parameter is empty');
      }
    } catch (error) {
      if (error.message.includes('ParameterNotFound')) {
        console.log(`  ⓘ ${cloudFrontPrivateKeyParamName} (not yet set)`);
        console.log(
          `    To set it, run: npm run cloudfront:private-key-set-ssm:${sharedInfraStage}`
        );
      } else {
        console.error(`  ✗ ${cloudFrontPrivateKeyParamName}`);
        console.error(`    Error: ${error.message}`);
        process.exit(1);
      }
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
  } else {
    console.log(
      `Auth-only mode enabled: skipping shared-infra stack sync and updating only ${authPrefix} parameters.`
    );
  }

  console.log(`\nSetting auth SSM parameters:`);
  const authParameters = [
    {
      name: `${authPrefix}/access-token-ttl-minutes`,
      value: authAccessTokenTtlMinutes,
      type: 'String',
    },
    {
      name: `${authPrefix}/refresh-token-ttl-days`,
      value: authRefreshTokenTtlDays,
      type: 'String',
    },
    {
      name: `${authPrefix}/email-mode`,
      value: authEmailMode,
      type: 'String',
    },
    {
      name: `${authPrefix}/ses-from-email`,
      value: authSesFromEmail,
      type: 'String',
    },
  ];

  for (const parameter of authParameters) {
    try {
      putSsmParameter(parameter.name, parameter.value, {
        profile: awsProfile,
        region: awsRegion,
        type: parameter.type,
      });
      console.log(`  ✓ ${parameter.name}`);
    } catch (error) {
      console.error(`  ✗ ${parameter.name}`);
      console.error(`    ${error.message}`);
      process.exit(1);
    }
  }

  const secretParameters = [
    {
      name: `${authPrefix}/jwt-secret`,
      value: authJwtSecret,
      helpLabel: '--auth-jwt-secret',
    },
    {
      name: `${authPrefix}/verification-code-secret`,
      value: verificationCodeSecret,
      helpLabel: '--verification-code-secret',
    },
  ];

  for (const parameter of secretParameters) {
    if (parameter.value) {
      try {
        putSsmParameter(parameter.name, parameter.value, {
          profile: awsProfile,
          region: awsRegion,
          type: 'SecureString',
        });
        console.log(`  ✓ ${parameter.name} (updated)`);
      } catch (error) {
        console.error(`  ✗ ${parameter.name}`);
        console.error(`    ${error.message}`);
        process.exit(1);
      }
      continue;
    }

    const existingValue = getSsmParameter(parameter.name, {
      profile: awsProfile,
      region: awsRegion,
      withDecryption: true,
    });
    if (existingValue) {
      console.log(`  ✓ ${parameter.name} (already set)`);
    } else {
      console.log(`  ⓘ ${parameter.name} (not set)`);
      console.log(`    Provide ${parameter.helpLabel} to create it.`);
    }
  }

  console.log(
    `\nDone. SSM parameters created. Run 'npm run setup:ssm-resource-policies' to enable cross-account access.`
  );
}

try {
  main();
} catch (error) {
  console.error(error?.message || error);
  process.exit(1);
}
