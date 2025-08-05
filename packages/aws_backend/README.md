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
│   ├── demo_dynamodb.dart                       # Demo script for testing
│   ├── integration_demo.dart                    # Hybrid local/cloud demo
│   └── aws_lambda_server.dart                   # AWS Lambda handler
├── serverless.yml                              # Serverless Framework config
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

3. **Run the demo**:
   ```bash
   cd packages/aws_backend
   dart run bin/demo_dynamodb.dart
   ```

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

The package includes a `serverless.yml` configuration optimized for AWS Lambda deployment:

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

```bash
# Deploy to AWS with project-specific configuration
serverless deploy --stage dev --aws-profile sltt-dart-dev

# The serverless-dart plugin will automatically:
# 1. Build your Dart application (natively on Linux/WSL2, or in Docker on Windows/macOS)
# 2. Compile to native binary using dart compile exe (or dart2native)
# 3. Package as 'bootstrap' executable for AWS Lambda custom runtime
# 4. Deploy to AWS with DynamoDB table creation
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
dart run bin/demo_dynamodb.dart
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

## Future Enhancements

- [ ] CloudWatch metrics and logging
- [ ] DynamoDB Streams integration for real-time sync
- [ ] Multi-region replication support
- [ ] Enhanced error handling and retry logic
- [ ] Project-level access controls and permissions
