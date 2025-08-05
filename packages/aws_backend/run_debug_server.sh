#!/bin/bash

# Script to run the debug server with AWS credentials from a profile
# Usage: ./run_debug_server.sh [--aws-profile profile-name] [--stage stage-name] [--port port-number]

# Default values
AWS_PROFILE="sltt-dart-dev"
STAGE="dev"
PORT="8080"
USE_CLOUD_STORAGE="true"
LOCAL_DEBUGGER="true"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --aws-profile)
      AWS_PROFILE="$2"
      shift 2
      ;;
    --stage)
      STAGE="$2"
      shift 2
      ;;
    --port)
      PORT="$2"
      shift 2
      ;;
    --use-cloud-storage)
      USE_CLOUD_STORAGE="$2"
      shift 2
      ;;
    --local-debugger)
      LOCAL_DEBUGGER="$2"
      shift 2
      ;;
    --help)
      echo "Debug Server for AWS Backend"
      echo ""
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  --aws-profile <profile>       AWS profile to use (default: sltt-dart-dev)"
      echo "  --stage <stage>               Deployment stage (default: dev)"
      echo "  --port <port>                Local server port (default: 8080)"
      echo "  --use-cloud-storage <bool>    Use cloud DynamoDB (default: true)"
      echo "  --local-debugger <bool>       Enable local debugger mode (default: true)"
      echo "  --help                       Show this help message"
      echo ""
      echo "This tool:"
      echo "1. Gets AWS credentials from the specified profile"
      echo "2. Sets AWS environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)"
      echo "3. Configures storage and debugger options"
      echo "4. Runs the debug server with credentials available to Platform.environment"
      echo "5. Allows VS Code debugging while using real or local AWS DynamoDB"
      echo ""
      echo "Options explained:"
      echo "  --use-cloud-storage true   = Connect to real AWS DynamoDB (requires credentials)"
      echo "  --use-cloud-storage false  = Use local DynamoDB instance on localhost:8000"
      echo "  --local-debugger true      = Enable debug-specific logging and features"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

echo "🔧 Setting up debug environment..."
echo "   AWS Profile: $AWS_PROFILE"
echo "   Stage: $STAGE"
echo "   Port: $PORT"
echo "   Use Cloud Storage: $USE_CLOUD_STORAGE"
echo "   Local Debugger: $LOCAL_DEBUGGER"

# Get AWS credentials from the profile
echo "🔑 Getting AWS credentials from profile: $AWS_PROFILE"

AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile "$AWS_PROFILE" 2>/dev/null)
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile "$AWS_PROFILE" 2>/dev/null)

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "❌ Failed to get AWS credentials from profile: $AWS_PROFILE"
  echo "   Make sure the profile exists and has valid credentials"
  echo "   You can list profiles with: aws configure list-profiles"
  exit 1
fi

echo "✅ AWS credentials retrieved successfully"
echo "   Access Key ID: ${AWS_ACCESS_KEY_ID:0:8}..."

# Set up environment variables for the dart process
# might be able to use serverless info --verbose (?) to get these values
AWS_REGION="us-east-1"
DYNAMODB_REGION="us-east-1"
DYNAMODB_TABLE="sltt-backend-changes-$STAGE"

echo "🗄️  Environment variables:"
echo "   AWS_REGION: $AWS_REGION"
echo "   DYNAMODB_TABLE: $DYNAMODB_TABLE"
echo "   USE_CLOUD_STORAGE: $USE_CLOUD_STORAGE"
echo "   LOCAL_DEBUGGER: $LOCAL_DEBUGGER"

echo "🚀 Starting debug server..."

# Run the debug server with environment variables passed directly to the command
exec env \
  AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  AWS_REGION="$AWS_REGION" \
  DYNAMODB_REGION="$DYNAMODB_REGION" \
  DYNAMODB_TABLE="$DYNAMODB_TABLE" \
  STAGE="$STAGE" \
  USE_CLOUD_STORAGE="$USE_CLOUD_STORAGE" \
  LOCAL_DEBUGGER="$LOCAL_DEBUGGER" \
  dart run --observe=8181 bin/debug_server.dart --aws-profile "$AWS_PROFILE" --stage "$STAGE" --port "$PORT"
