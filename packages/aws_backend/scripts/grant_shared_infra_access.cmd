@echo off
setlocal enabledelayedexpansion

set TARGET_ACCOUNT_ID=%1
set TARGET_ROLE_NAME=%2
set SHARED_INFRA_STAGE=%3
set AWS_PROFILE=%4
set AWS_REGION=%5

if "%TARGET_ACCOUNT_ID%"=="" (
  echo Usage: grant_shared_infra_access.cmd ^<target-account-id^> ^<target-role-name^> [shared-infra-stage] [aws-profile] [aws-region]
  echo Example: grant_shared_infra_access.cmd 123456789012 sltt-secondary-infra-dev-role prd sltt-dart-prd us-east-1
  exit /b 1
)

if "%TARGET_ROLE_NAME%"=="" (
  echo ERROR: target role name is required.
  exit /b 1
)

if "%SHARED_INFRA_STAGE%"=="" set SHARED_INFRA_STAGE=prd
if "%AWS_PROFILE%"=="" set AWS_PROFILE=sltt-dart-prd
if "%AWS_REGION%"=="" set AWS_REGION=us-east-1

set STACK_NAME=sltt-shared-infra-%SHARED_INFRA_STAGE%

for /f "delims=" %%i in ('aws cloudformation describe-stacks --stack-name %STACK_NAME% --query "Stacks[0].Outputs[?OutputKey=='DynamoDbTableArn'].OutputValue" --output text --profile %AWS_PROFILE% --region %AWS_REGION%') do set TABLE_ARN=%%i
for /f "delims=" %%i in ('aws cloudformation describe-stacks --stack-name %STACK_NAME% --query "Stacks[0].Outputs[?OutputKey=='MediaBucketName'].OutputValue" --output text --profile %AWS_PROFILE% --region %AWS_REGION%') do set BUCKET_NAME=%%i
for /f "delims=" %%i in ('aws cloudformation describe-stacks --stack-name %STACK_NAME% --query "Stacks[0].Outputs[?OutputKey=='MediaBucketArn'].OutputValue" --output text --profile %AWS_PROFILE% --region %AWS_REGION%') do set BUCKET_ARN=%%i
for /f "delims=" %%i in ('aws cloudformation describe-stacks --stack-name %STACK_NAME% --query "Stacks[0].Outputs[?OutputKey=='MediaCloudFrontDistributionId'].OutputValue" --output text --profile %AWS_PROFILE% --region %AWS_REGION%') do set CF_DISTRIBUTION_ID=%%i
for /f "delims=" %%i in ('aws sts get-caller-identity --query "Account" --output text --profile %AWS_PROFILE%') do set SHARED_ACCOUNT_ID=%%i

if "%TABLE_ARN%"=="" (
  echo ERROR: Unable to resolve DynamoDB table ARN from stack %STACK_NAME%.
  exit /b 1
)

if "%BUCKET_NAME%"=="" (
  echo ERROR: Unable to resolve S3 bucket name from stack %STACK_NAME%.
  exit /b 1
)

if "%CF_DISTRIBUTION_ID%"=="" (
  echo ERROR: Unable to resolve CloudFront distribution ID from stack %STACK_NAME%.
  exit /b 1
)

set TARGET_ROLE_ARN=arn:aws:iam::%TARGET_ACCOUNT_ID%:role/%TARGET_ROLE_NAME%
set PARAM_RESOURCE_ARN=arn:aws:ssm:%AWS_REGION%:%SHARED_ACCOUNT_ID%:parameter/sltt/infra/%SHARED_INFRA_STAGE%/*

set TEMP_DIR=%TEMP%\sltt_shared_infra
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

set SSM_POLICY_FILE=%TEMP_DIR%\ssm_resource_policy.json
set DYNAMO_POLICY_FILE=%TEMP_DIR%\dynamodb_resource_policy.json
set S3_POLICY_FILE=%TEMP_DIR%\s3_bucket_policy.json

> "%SSM_POLICY_FILE%" echo {
>> "%SSM_POLICY_FILE%" echo   "Version": "2012-10-17",
>> "%SSM_POLICY_FILE%" echo   "Statement": [
>> "%SSM_POLICY_FILE%" echo     {
>> "%SSM_POLICY_FILE%" echo       "Sid": "AllowCrossAccountSsmRead",
>> "%SSM_POLICY_FILE%" echo       "Effect": "Allow",
>> "%SSM_POLICY_FILE%" echo       "Principal": {"AWS": "arn:aws:iam::%TARGET_ACCOUNT_ID%:root"},
>> "%SSM_POLICY_FILE%" echo       "Action": ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"],
>> "%SSM_POLICY_FILE%" echo       "Resource": "%PARAM_RESOURCE_ARN%"
>> "%SSM_POLICY_FILE%" echo     }
>> "%SSM_POLICY_FILE%" echo   ]
>> "%SSM_POLICY_FILE%" echo }

> "%DYNAMO_POLICY_FILE%" echo {
>> "%DYNAMO_POLICY_FILE%" echo   "Version": "2012-10-17",
>> "%DYNAMO_POLICY_FILE%" echo   "Statement": [
>> "%DYNAMO_POLICY_FILE%" echo     {
>> "%DYNAMO_POLICY_FILE%" echo       "Sid": "AllowCrossAccountApiAccess",
>> "%DYNAMO_POLICY_FILE%" echo       "Effect": "Allow",
>> "%DYNAMO_POLICY_FILE%" echo       "Principal": {"AWS": "%TARGET_ROLE_ARN%"},
>> "%DYNAMO_POLICY_FILE%" echo       "Action": [
>> "%DYNAMO_POLICY_FILE%" echo         "dynamodb:GetItem",
>> "%DYNAMO_POLICY_FILE%" echo         "dynamodb:PutItem",
>> "%DYNAMO_POLICY_FILE%" echo         "dynamodb:UpdateItem",
>> "%DYNAMO_POLICY_FILE%" echo         "dynamodb:DeleteItem",
>> "%DYNAMO_POLICY_FILE%" echo         "dynamodb:Query",
>> "%DYNAMO_POLICY_FILE%" echo         "dynamodb:Scan",
>> "%DYNAMO_POLICY_FILE%" echo         "dynamodb:BatchGetItem",
>> "%DYNAMO_POLICY_FILE%" echo         "dynamodb:BatchWriteItem",
>> "%DYNAMO_POLICY_FILE%" echo         "dynamodb:DescribeTable"
>> "%DYNAMO_POLICY_FILE%" echo       ],
>> "%DYNAMO_POLICY_FILE%" echo       "Resource": [
>> "%DYNAMO_POLICY_FILE%" echo         "%TABLE_ARN%",
>> "%DYNAMO_POLICY_FILE%" echo         "%TABLE_ARN%/index/*"
>> "%DYNAMO_POLICY_FILE%" echo       ]
>> "%DYNAMO_POLICY_FILE%" echo     }
>> "%DYNAMO_POLICY_FILE%" echo   ]
>> "%DYNAMO_POLICY_FILE%" echo }

> "%S3_POLICY_FILE%" echo {
>> "%S3_POLICY_FILE%" echo   "Version": "2012-10-17",
>> "%S3_POLICY_FILE%" echo   "Statement": [
>> "%S3_POLICY_FILE%" echo     {
>> "%S3_POLICY_FILE%" echo       "Sid": "AllowCloudFrontRead",
>> "%S3_POLICY_FILE%" echo       "Effect": "Allow",
>> "%S3_POLICY_FILE%" echo       "Principal": {"Service": "cloudfront.amazonaws.com"},
>> "%S3_POLICY_FILE%" echo       "Action": ["s3:GetObject"],
>> "%S3_POLICY_FILE%" echo       "Resource": ["%BUCKET_ARN%/*"],
>> "%S3_POLICY_FILE%" echo       "Condition": {"StringEquals": {"AWS:SourceArn": "arn:aws:cloudfront::%SHARED_ACCOUNT_ID%:distribution/%CF_DISTRIBUTION_ID%"}}
>> "%S3_POLICY_FILE%" echo     },
>> "%S3_POLICY_FILE%" echo     {
>> "%S3_POLICY_FILE%" echo       "Sid": "AllowCrossAccountApiAccess",
>> "%S3_POLICY_FILE%" echo       "Effect": "Allow",
>> "%S3_POLICY_FILE%" echo       "Principal": {"AWS": "%TARGET_ROLE_ARN%"},
>> "%S3_POLICY_FILE%" echo       "Action": [
>> "%S3_POLICY_FILE%" echo         "s3:AbortMultipartUpload",
>> "%S3_POLICY_FILE%" echo         "s3:CreateMultipartUpload",
>> "%S3_POLICY_FILE%" echo         "s3:GetObject",
>> "%S3_POLICY_FILE%" echo         "s3:HeadObject",
>> "%S3_POLICY_FILE%" echo         "s3:ListBucket",
>> "%S3_POLICY_FILE%" echo         "s3:ListBucketMultipartUploads",
>> "%S3_POLICY_FILE%" echo         "s3:ListMultipartUploadParts",
>> "%S3_POLICY_FILE%" echo         "s3:PutObject",
>> "%S3_POLICY_FILE%" echo         "s3:UploadPart"
>> "%S3_POLICY_FILE%" echo       ],
>> "%S3_POLICY_FILE%" echo       "Resource": [
>> "%S3_POLICY_FILE%" echo         "%BUCKET_ARN%",
>> "%S3_POLICY_FILE%" echo         "%BUCKET_ARN%/*"
>> "%S3_POLICY_FILE%" echo       ]
>> "%S3_POLICY_FILE%" echo     }
>> "%S3_POLICY_FILE%" echo   ]
>> "%S3_POLICY_FILE%" echo }

aws ssm put-resource-policy --resource-arn %PARAM_RESOURCE_ARN% --policy file://%SSM_POLICY_FILE% --profile %AWS_PROFILE% --region %AWS_REGION%
aws dynamodb put-resource-policy --resource-arn %TABLE_ARN% --policy file://%DYNAMO_POLICY_FILE% --profile %AWS_PROFILE% --region %AWS_REGION%
aws s3api put-bucket-policy --bucket %BUCKET_NAME% --policy file://%S3_POLICY_FILE% --profile %AWS_PROFILE% --region %AWS_REGION%

echo Done. Granted cross-account access to %TARGET_ROLE_ARN% for shared infra %STACK_NAME%.
endlocal
