#!/bin/bash

# Script to delete DynamoDB table via Serverless and redeploy with new schema
#
# Usage: ./serverless_recreate_table.sh <stage>
# Example: ./serverless_recreate_table.sh dev
#
# WARNING: This will delete all existing data!

set -e

STAGE="${1:-dev}"

echo "⚠️  WARNING: This will delete ALL data in the DynamoDB table for stage '$STAGE'"
echo "This action cannot be undone!"
echo ""
echo "The process will:"
echo "1. Remove the existing Serverless stack (including DynamoDB table)"
echo "2. Redeploy with the new schema that includes:"
echo "   - Primary Index: pk=PROJECT_ID#{projectId}#ENTITY_ID#{entityId}, sk=CID#{cid}"
echo "   - GSI1: gsi1pk=PROJECT_ID#{projectId}, gsi1sk=SEQ#{seq}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirmation

if [ "$confirmation" != "yes" ] && [ "$confirmation" != "y" ]; then
    echo "Operation cancelled."
    exit 0
fi

# Check if serverless.yml exists
if [ ! -f "serverless.yml" ]; then
    echo "❌ Error: serverless.yml not found in current directory"
    echo "Please run this script from the directory containing your serverless.yml file"
    exit 1
fi

echo "🔄 Removing existing Serverless stack for stage '$STAGE'..."
serverless remove --stage "$STAGE" --aws-profile sltt-dart-dev

echo "⏳ Waiting a moment for AWS resources to be fully cleaned up..."
sleep 5

echo "🚀 Deploying new stack with updated schema for stage '$STAGE'..."
serverless deploy --stage "$STAGE" --aws-profile sltt-dart-dev

echo "✅ Stack recreated successfully with new DynamoDB schema!"
echo ""
echo "New table features:"
echo "- Supports querying by entity ID for change history"
echo "- Optimized for high write throughput"
echo "- Efficient project-wide sequence queries via GSI1"
echo ""
echo "You can now test the new schema with your application."
