# AWS Backend Package

This package provides AWS DynamoDB storage services for the Dart SLTT (Sign Language Translation Tool) system, optimized for serverless deployment with minimal cold start time.

## Features

- **Lightweight DynamoDB Storage**: HTTP API-based implementation instead of heavy AWS SDK
- **Project-Based Multi-Tenancy**: Multiple projects can share the same DynamoDB table with isolated data
- **Local Development Support**: Compatible with DynamoDB Local for offline development
- **Serverless-Ready**: Optimized for AWS Lambda deployment with minimal dependencies
- **Compatible API**: Same interface as local Isar-based storage services

## Architecture

```
aws_backend/
├── lib/
│   ├── src/
│   │   ├── storage/
│   │   │   └── dynamodb_storage_service.dart    # DynamoDB implementation
│   │   └── api/
│   │       └── aws_rest_api_server.dart         # REST API server for testing
│   └── aws_backend.dart                         # Main export file
├── bin/
│   ├── demo_dynamodb.old                        # Archived local demo script
│   ├── integration_demo.dart                    # Hybrid local/cloud demo
│   └── aws_lambda_server.dart                   # AWS Lambda handler
├── serverless-shared-infra.yml                 # Shared infra (DynamoDB, S3, CloudFront)
├── serverless-secondary-infra.yml              # Secondary API stack (Lambda only)
├── serverless.yml                              # Legacy single-stack config
└── pubspec.yaml                                # Minimal dependencies
```

## Usage

### Local Development with DynamoDB Local

1. **Install DynamoDB Local**:
   ```bash
   # Download from AWS and extract
   wget https://s3.us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.zip
   unzip dynamodb_local_latest.zip
   ```

2. **Start DynamoDB Local**:
   ```bash
   java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb -port 8000
   ```

3. **Smoke test the API locally**:
  ```bash
  cd packages/aws_backend
  dart run bin/debug_server.dart
  ```
  > _Note_: The legacy `demo_dynamodb.dart` script has been archived as
  > `demo_dynamodb.old`. Prefer the debug server or the new automated tests
  > (`dart test`) when validating changes.

### Using DynamoDB Storage Service

```dart
import 'package:aws_backend/aws_backend.dart';

// For local development
final storage = DynamoDBStorageService(
  tableName: 'sltt-changes-dev',
  projectId: 'my-project-123',
  region: 'us-east-1',
  useLocalDynamoDB: true,
  localEndpoint: 'http://localhost:8000',
);

// For AWS production
final storage = DynamoDBStorageService(
  tableName: 'sltt-changes-prod',
  projectId: 'my-project-123',
  region: 'us-east-1',
  useLocalDynamoDB: false,
);

await storage.initialize();

// Use the same API as LocalStorageService
final change = await storage.createChange({
  'entityType': 'document',
  'operation': 'create',
  'entityId': 'doc-001',
  'data': {'title': 'My Document'},
});
```

### REST API Server

```dart
import 'package:aws_backend/aws_backend.dart';

final storage = DynamoDBStorageService(/* ... */);
final server = AwsRestApiServer(
  serverName: 'AWS-Backend',
  storage: storage,
);

await server.start(port: 8080);
```

## Project Management

### Multiple Projects in One Table

```dart
// Project A
final projectA = DynamoDBStorageService(
  tableName: 'sltt-changes-shared',
  projectId: 'project-a-123',
  region: 'us-east-1',
);

// Project B (completely isolated from A)
final projectB = DynamoDBStorageService(
  tableName: 'sltt-changes-shared',  // Same table!
  projectId: 'project-b-456',       // Different partition
  region: 'us-east-1',
);

// Each project has independent sequence numbering
await projectA.createChange({...}); // Gets seq: 1
await projectB.createChange({...}); // Also gets seq: 1 (isolated)
```

### Project-Specific Deployment

Deploy separate Lambda functions for different projects:

```bash
# Deploy for Project A
serverless deploy --stage prod --project project-a-123

# Deploy for Project B
serverless deploy --stage prod --project project-b-456
```

Or use a single Lambda that handles multiple projects based on request context.

## Serverless Deployment

This package now uses two Serverless stacks:

- **Shared infra**: [packages/aws_backend/serverless-shared-infra.yml](packages/aws_backend/serverless-shared-infra.yml)
  - DynamoDB table
  - S3 media bucket
  - CloudFront distribution
- **Secondary (API)**: [packages/aws_backend/serverless-secondary-infra.yml](packages/aws_backend/serverless-secondary-infra.yml)
  - Lambda API deployment that references shared infra via SSM parameters

The legacy single-stack config remains in [packages/aws_backend/serverless.yml](packages/aws_backend/serverless.yml).

### Prerequisites

1. **Install Docker** (required for Windows/macOS only):
   ```bash
   # Docker is ONLY required for Windows and macOS
   # Linux and WSL2 can compile natively without Docker

   # Windows/macOS users: Get Docker at https://docs.docker.com/get-docker/
   # Linux/WSL2 users: Skip this step - no Docker needed!
   ```

2. **Install Serverless Framework**:
   ```bash
   npm install -g serverless
   ```

3. **Configure AWS credentials** (if not already done):
   ```bash
   # Option 1: Using AWS CLI
   aws configure

   # Option 2: Using environment variables
   export AWS_ACCESS_KEY_ID=your-access-key
   export AWS_SECRET_ACCESS_KEY=your-secret-key
   export AWS_DEFAULT_REGION=us-east-1
   ```

### Deployment

#### 0) cloudfront public/private key setup

Before the first shared infra deploy (or whenever rotating keys), publish the
CloudFront signing keys to SSM. Use the profile that owns the shared infra (e.g. sltt-dart-prd):

```bash
# One-time (or on rotation) for shared infra in prd
npm run cloudfront:public-key-set-ssm:prd
npm run cloudfront:private-key-set-ssm:prd
```

#### 1) Deploy shared infrastructure (once)

```bash
npm run deploy:shared-infra
```

#### 2) Populate shared SSM parameters (required)

Run after the shared infra stack so `/sltt/infra/prd` exists in the shared account:

```bash
npm run setup:ssm-parameters
```

#### 3) Choose how secondary stacks read shared SSM values

Option A: cross-account read (resource policies + IAM in target account)

If a developer account needs to deploy the secondary API stack, run the access script
from the shared infra account:

```bash
node packages\aws_backend\scripts\grant_shared_infra_access.js <target-account-id> <target-role-name> [shared-infra-stage] [aws-profile] [aws-region]
```

Example:

```bash
node packages\aws_backend\scripts\grant_shared_infra_access.js 123456789012 sltt-secondary-infra-dev-role prd sltt-dart-prd us-east-1
```

or from package.json (pass args after `--`):

```bash
npm run shared-infra:grant-access -- 123456789012 sltt-secondary-infra-dev-role prd sltt-dart-prd us-east-1
```

Option B: mirror SSM into the target account (simpler, no cross-account read)

```bash
npm run mirror:ssm-to-dev
```

#### 4) Deploy the secondary API stack

```bash
npm run deploy:secondary:dev
```

If you maintain separate dev/tst CloudFront keys for testing, set them in SSM
before deploying a secondary stack that points at those keys:

```bash
npm run cloudfront:public-key-set-ssm:dev
npm run cloudfront:private-key-set-ssm:dev

npm run cloudfront:public-key-set-ssm:tst
npm run cloudfront:private-key-set-ssm:tst
```

```bash
# Deploy to AWS with the secondary stack
serverless deploy --config serverless-secondary-infra.yml --stage dev --aws-profile sltt-dart-dev

# Or use the provided npm script (build + deploy)
npm run deploy:secondary:dev

# The build will:
# 1. Compile the Dart application
# 2. Package as 'bootstrap' for AWS Lambda custom runtime
# 3. Deploy Lambda functions only (shared infra is separate)
```

### Platform-Specific Notes

- **Linux/WSL2**: ✅ Native compilation - no Docker required
- **Windows**: ❌ Requires Docker for cross-compilation to Linux x64
- **macOS**: ❌ Requires Docker for cross-compilation to Linux x64
- **Alternative**: Build on Linux/WSL2 machine or use CI/CD pipeline

### Environment Variables

- `DYNAMODB_TABLE`: DynamoDB table name (e.g., 'sltt-changes-prod')
- `DYNAMODB_REGION`: AWS region (e.g., 'us-east-1')
- `USE_LOCAL_DYNAMODB`: Set to 'true' for local DynamoDB (development only)

**Note**: `PROJECT_ID` is no longer needed as an environment variable. Projects are now identified by the `projectId` field in the change data itself.

## DynamoDB Schema

The service uses a project-based multi-tenant DynamoDB schema:

### Main Table Schema
- **Table Name**: Configurable (e.g., `sltt-changes-prod`)
- **Partition Key**: `pk` (String) - Project ID (e.g., 'project-123')
- **Sort Key**: `seq` (Number) - Auto-incremented sequence number per project
- **Attributes**:
  - `entityType` (String) - Type of entity being tracked
  - `operation` (String) - Operation performed ('create', 'update', 'delete')
  - `timestamp` (String) - ISO 8601 timestamp
  - `entityId` (String) - ID of the entity being tracked
  - `dataJson` (String) - JSON-encoded entity data
  - `outdatedBy` (Number, optional) - Sequence that made this change obsolete

### Sequence Management (Per-Project)
- **Partition Key**: `pk` (String) - 'SEQUENCE#project-id'
- **Sort Key**: `seq` (Number) - Always 0
- **Attributes**:
  - `value` (Number) - Next sequence number to assign for this project

### Multi-Project Benefits
- **Cost Efficient**: Multiple projects share one DynamoDB table
- **Data Isolation**: Each project's data is completely separate
- **Independent Sequencing**: Each project starts sequence numbering from 1
- **Scalable**: Single table can handle many projects efficiently

## Dependencies

The package is designed with minimal dependencies to reduce Lambda cold start time:

- `sltt_core`: Core interfaces and models (path dependency)
- `http`: HTTP client for DynamoDB API calls
- `json_annotation`: JSON serialization support

**No heavy dependencies like:**
- ❌ Full AWS SDK packages
- ❌ Isar database (not needed in Lambda)
- ❌ Large serialization frameworks

## Testing

The demo script provides comprehensive testing of all DynamoDB operations:

```bash
cd packages/aws_backend
dart run bin/debug_server.dart
```

This will:
1. Initialize DynamoDB storage (creates table if needed)
2. Test change creation and retrieval with project isolation
3. Test cursor-based pagination
4. Test statistics generation
5. Start a REST API server for manual testing

You can also test the integration demo:

```bash
dart run bin/integration_demo.dart
```

This demonstrates hybrid local/cloud synchronization.

### Automated route checks

Run the focused unit tests that exercise the health and help routes via the
Lambda handler adaptor:

```bash
cd packages/aws_backend
dart test test/aws_rest_api_server_test.dart
```

## Development vs Production

### Development (DynamoDB Local)
- Uses fake AWS credentials
- Creates tables automatically
- Runs on localhost:8000
- Perfect for offline development

### Production (AWS DynamoDB)
- Uses IAM roles/credentials from environment
- Requires pre-created tables (via serverless.yml)
- Automatic scaling and backups
- Full AWS integration

## Performance Considerations

- **Cold Start Optimization**: Uses HTTP API calls instead of heavy AWS SDK
- **Minimal Dependencies**: Only essential packages included
- **Efficient Queries**: Uses DynamoDB Query operations with project-based partitioning
- **Batch Operations**: Supports creating multiple changes in one request
- **Pagination**: Cursor-based pagination prevents memory issues
- **Project Isolation**: Each project's queries are scoped to its own partition

## Troubleshooting

### Docker Issues (Windows/macOS only)
- **Problem**: "Cannot connect to Docker daemon"
  - **Solution**: Ensure Docker Desktop is running
  - **WSL2/Linux users**: You can skip Docker entirely!

### Compilation Issues
- **Problem**: "dart2native: No such file or directory"
  - **Solution**: Ensure Dart SDK ≥ 2.6 is installed (or use `dart compile exe` in newer versions)
  - **Check**: `dart --version`
- **Problem**: "Cross-compilation not supported"
  - **Solution**: Use Docker on Windows/macOS, or build on Linux/WSL2

### Deployment Issues
- **Problem**: "serverless-dart plugin not found"
  - **Solution**: `npm install -D serverless-dart` in your project
- **Problem**: Permission denied on AWS
  - **Solution**: Configure AWS credentials: `aws configure`

### Runtime Issues
- **Problem**: "Runtime.ImportModuleError" in Lambda
  - **Solution**: Ensure binary is named `bootstrap` (serverless-dart handles this)
  - **Check**: Your handler in serverless.yml matches your Dart main function
- **Problem**: "fork/exec /var/task/bootstrap: exec format error"
  - **Solution**: Binary was compiled for wrong architecture (Windows vs Linux)
  - **Fix**: Use `npm run build` (Docker-based) instead of `dart compile exe` directly on Windows

### Debugging Lambda Issues

When your deployed Lambda returns errors, use these commands to investigate:

```bash
# Get recent CloudWatch logs (last 1 hour)
npm run logs:dev     # For dev stage
npm run logs:prod    # For prod stage

# Get deployment info (URLs, function names)
npm run info:dev     # For dev stage
npm run info:prod    # For prod stage

# Manual CloudWatch access (if npm scripts don't work)
npx serverless logs --function api --stage dev --aws-profile sltt-dart-dev --startTime 1h
```

Common error patterns in logs:
- `Runtime.InvalidEntrypoint` + `exec format error` → Wrong architecture (use Docker build)
- `Could not load credentials` → AWS credentials not available to Lambda
- `ValidationException` → DynamoDB table/permissions issue
- `Process exited before completing request` → Dart runtime crash (check initialization)

## Future Enhancements

- [ ] CloudWatch metrics and logging
- [ ] DynamoDB Streams integration for real-time sync
- [ ] Multi-region replication support
- [ ] Enhanced error handling and retry logic
- [ ] Project-level access controls and permissions
